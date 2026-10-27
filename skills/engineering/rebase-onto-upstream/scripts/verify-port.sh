#!/usr/bin/env bash
# Audit a rebase-onto-upstream port.
#
# Lists every line upstream introduced between the two upstream revisions that is NOT in
# the tree now, for the files a conflict resolution actually touched. See the skill's
# SKILL.md for why the audit is bounded to those files and how to read the output.
#
# Usage:
#   verify-port.sh [-C <repo-dir>] <OLD_UPSTREAM> <NEW_UPSTREAM>
#
#   OLD_UPSTREAM  the upstream revision the patch chain was written against
#   NEW_UPSTREAM  the upstream revision the chain was rebased onto
#
#   -C  repo to audit (default: the current directory)
#
# Exit status: 1 if any upstream line is absent (each one needs a reason), 0 if none are.
#
# Deliberately takes the revisions as arguments and ships no defaults: hard-coded revision
# ids from a past migration are stale the moment that migration lands.

set -uo pipefail

REPO="."
while getopts ':C:' opt; do
	case "$opt" in
		C) REPO="$OPTARG" ;;
		*) echo "Usage: $(basename "$0") [-C repo-dir] <OLD_UPSTREAM> <NEW_UPSTREAM>" >&2; exit 2 ;;
	esac
done
shift $((OPTIND - 1))

OLD="${1:-}"
NEW="${2:-}"
if [ -z "$OLD" ] || [ -z "$NEW" ]; then
	echo "Usage: $(basename "$0") [-C repo-dir] <OLD_UPSTREAM> <NEW_UPSTREAM>" >&2
	echo >&2
	echo "OLD = the upstream revision the chain was written against." >&2
	echo "NEW = the upstream revision it was rebased onto." >&2
	exit 2
fi

[ -d "$REPO" ] || { echo "Not a directory: $REPO" >&2; exit 2; }
cd "$REPO" || exit 2

export JJ_PAGER=cat

jj log -r "$OLD" --no-graph -T '' >/dev/null 2>&1 || { echo "Unknown revision: $OLD" >&2; exit 2; }
jj log -r "$NEW" --no-graph -T '' >/dev/null 2>&1 || { echo "Unknown revision: $NEW" >&2; exit 2; }

echo "Port audit in $(pwd)"
echo "Upstream delta: $OLD -> $NEW"
echo

# Every revision in the PORTED CHAIN still carrying an unresolved conflict, and the paths it
# reports. An inherited conflict is reported by each descendant too, so the union of these is
# the complete set of files a human had to decide something about.
#
# Scoped on purpose: `conflicts()` is repo-wide, and a repository can hold conflicted
# revisions with nothing to do with this port. The chain is everything descending from the
# upstream revision the chain was rebased onto. Conflicts outside it are listed separately
# rather than silently ignored.
conflicted_revs=$(jj log -r "conflicts() & ${NEW}::" --no-graph -T 'change_id.shortest() ++ "\n"')
outside_revs=$(jj log -r "conflicts() ~ ${NEW}::" --no-graph \
	-T 'change_id.shortest() ++ "  " ++ description.first_line() ++ "\n"')

conflicted_files=$(
	for rev in $conflicted_revs; do
		jj resolve --list -r "$rev" 2>/dev/null | awk 'NF { print $1 }'
	done | sort -u
)

if [ -z "$conflicted_files" ]; then
	echo "No conflicted revisions under $NEW — nothing was merged by hand."
	echo "If you expected conflicts, check that NEW is the revision you rebased onto."
else
	echo "Conflicted revisions, and the revision that resolves each:"
	for rev in $conflicted_revs; do
		printf '  %-28s %s\n' "$(jj log -r "$rev" --no-graph -T 'change_id.shortest()')" \
			"$(jj log -r "$rev" --no-graph -T 'description.first_line()')"
		jj log -r "children($rev)" --no-graph \
			-T '"    resolved by  " ++ change_id.shortest() ++ "  " ++ description.first_line() ++ "\n"'
	done
	echo
fi

if [ -n "$outside_revs" ]; then
	echo "Conflicted revisions OUTSIDE the ported chain — not audited here:"
	printf '%s\n' "$outside_revs" | sed 's/^/  /'
	echo
fi

total_absent=0

for path in $conflicted_files; do
	if [ ! -f "$path" ]; then
		printf '### %s\n' "$path"
		printf '    NOT IN THE TREE — a revision deleted or renamed it. Confirm that was intended.\n'
		total_absent=$((total_absent + 1))
		continue
	fi

	upstream_added=0
	missing=()

	# Whitespace-insensitive: whitespace runs collapse to one space and the ends are trimmed,
	# on both sides. A rebase re-nests AND re-aligns the arrays these lines live in, so
	# upstream's statement sits at a different depth with a different column of `=>`, and an
	# exact-line match reports a phantom miss on every one of those. The flip side is that a
	# line counts as present when the token sequence exists, not when it sits in the right
	# place: this is a tripwire for "upstream's change is nowhere in this file", not proof.
	file_body=$(sed -E 's/[[:space:]]+/ /g; s/^ //; s/ $//' "$path")

	while IFS= read -r line; do
		[ -z "$line" ] && continue
		upstream_added=$((upstream_added + 1))
		line_body=$(printf '%s\n' "$line" | sed -E 's/[[:space:]]+/ /g; s/^ //; s/ $//')
		[ -z "$line_body" ] && continue
		if ! grep -Fqx -- "$line_body" <<< "$file_body"; then
			missing+=("$line")
		fi
	done < <(
		jj diff --git --from "$OLD" --to "$NEW" -- "$path" |
			awk '/^\+\+\+ / { next } /^\+/ { print substr($0, 2) }'
	)

	printf '### %s\n' "$path"
	printf '    upstream added %s lines; %s not found in the tree\n' "$upstream_added" "${#missing[@]}"
	for line in "${missing[@]}"; do
		printf '    ABSENT | %s\n' "$line"
	done
	total_absent=$((total_absent + ${#missing[@]}))
	echo
done

echo "----------------------------------------------------------------"
printf 'Files decided by hand: %s. Upstream lines not carried: %s.\n' \
	"$(printf '%s\n' "$conflicted_files" | grep -c .)" "$total_absent"
echo
echo "Each ABSENT line needs a reason. The acceptable ones are:"
echo "  - the code it lands in is deleted by a revision whose stated purpose is that deletion,"
echo "  - or its intent is present under different wording (a rename applied to moved code)."
echo "Anything else is a dropped upstream change and wants a fix."
echo
echo "This audit cannot judge those reasons, and cannot tell whether a deliberate deletion"
echo "was wise. It finds candidates; you decide. It also cannot see a hunk upstream did NOT"
echo "touch but a resolution changed anyway — check the resolution diffs themselves."

[ "$total_absent" -eq 0 ]
