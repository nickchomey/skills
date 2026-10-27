---
name: merge-trunk-into-branch
description: '**WORKFLOW SKILL** — Merge trunk (or main/upstream tip) into a PR branch in a jj repo, resolve the conflicts by folding upstream changes into the PR, and prove nothing was dropped. USE FOR: "merge trunk into <branch>", "sync PR with trunk", "resolve the merge conflicts", "fold upstream into the PR", updating a pull request branch to a newer trunk. INVOKES: jj, git, the repo linter/typecheck/tests. DO NOT USE FOR: rebasing a patch chain onto a new upstream release (use rebase-onto-upstream); plain git merge questions outside jj.'
argument-hint: 'merge <trunk-rev> into <pr-tip>'
user-invocable: true
---

# Merge trunk into a PR branch

A PR branch that has fallen behind trunk needs one merge commit on top: upstream's changes folded in, the PR's behaviour preserved. The merge tool applies non-overlapping changes silently and reports the rest as conflicts — so a bad merge decision can only exist at a conflict, and the audit is bounded to the conflicted files, not trunk's whole delta.

## 0. Establish PR tip and trunk tip, and write them down

`PR` = the PR branch tip; `TRUNK` = the trunk revision to merge in. Record both change ids and commit ids. Find them with:

```bash
jj log -r 'all()' --no-graph -T 'change_id.shortest() ++ "  " ++ description.first_line() ++ "\n"'
```

Safety net: note the op id first (`jj op log`); `jj undo` is progressive, `jj op restore <op-id>` jumps to an explicit state.

## 1. Create the merge with the PR tip as FIRST parent

```bash
jj new -r <pr-tip> -r <trunk-tip> -m "Merge trunk into <branch>"
```

Parent order is the whole game: jj parent order becomes the git merge's parent order on push, and GitHub follows the first parent to list PR commits. Trunk-first (`jj new -r <trunk> -r <pr>`) lists trunk history as PR commits (measured 1862 on one PR); PR-first lists only the PR's commits plus the merge. There is no config or hook that enforces this — verify before pushing:

```bash
git log -1 --format="%P" <merge-commit>
```

The first hash must be the PR tip, the second the trunk tip. Or in jj: `jj log -r "parents(<merge>)"` — the PR tip must list first.

## 2. Walk the conflicts

```bash
jj resolve --list
```

For each conflicted file, get the three sides without guessing:

```bash
git ls-files -u -- <path>   # stage 1 = base, 2 = trunk, 3 = PR
```

Or: `jj file show -r <trunk-tip> -- <path>` and `jj file show -r <pr-tip> -- <path>`.

## 3. Resolve by hand — never with `--tool=:ours|:theirs`

Decide with both intents in hand, not from the markers. Before touching a hunk, read what each side was trying to do: the PR revision's description, and the trunk commits that changed the file. Markers show the bytes that disagree; they cannot tell you which side is right.

Triage each hunk — state what each side adds, removes, or changes — then:

- **Same intent**: pick the better implementation; if trunk already did that work, drop the PR's version.
- **Orthogonal changes**: merge both, building the PR's additions onto trunk's new structure.
- **Contradictory changes**: do not guess. Flag it to the user.
- Do not invent behaviour to make both sides compose. A design decision is an escalation.
- Generated artifacts and lockfiles are never hand-merged: regenerate from source.
- A green linter does not make a resolution correct.

Verify on disk immediately: grep each marker family separately (`<<<<<<<`, `>>>>>>>`, `%%%%%%%`, `+++++++`). `jj st` should confirm the conflict cleared. Never retype a marker label's backslashes into an edit — a failed match beats literal `\\` in source.

## 4. Prove each resolution

1. **Diff against trunk**: the merged file minus trunk must show only the PR's additions.
2. **Diff against the PR tip**: the merged file minus the PR tip must show only trunk's additions.
3. **Both clean = nothing dropped on either side.** For files trunk did not touch, the merged file must equal the PR tip byte for byte.

## 5. Run the checks, and classify every failure

Lint the merged files, typecheck, and run the affected unit tests. Account for every failure: a red test caused by the merge is a dropped change until proven otherwise. Flakes (pass in isolation, fail under full-suite load) get recorded as flakes with the isolation evidence, not fixed by editing the test.

## 6. Verify, then report

- `jj resolve --list` clean; marker grep clean; linter clean.
- Inspect the complete resolved files, not only the former hunks — surrounding invariants may have moved.
- Judge checks by **output**, never exit status: jj exits 0 on an empty revset, so empty + 0 means "nothing found", not "all clear".
- Report with evidence — commands and counts, judgement calls called out, which trunk hunks were deliberately dropped and why.

### The per-conflict record — one block per conflicted file, required output

```markdown
### <path> — conflicted in merge, resolved in working copy
- PR intent:     <the PR revision's stated purpose, for the code this file holds>
- Trunk intent:  <the trunk revision that changed this file, and why>
- Compatibility: compatible | incompatible | intent not stated anywhere
- Resolution:    <what the resolved hunk now does, and which side each part came from>
- Evidence:      <the commands run, and their observed output>
- Confidence:    <high | moderate | low>
- Not covered:   <what this record does not establish — say it, do not leave it implied>
```

Every claim needs the command that produced it. Unstated intent gets written down, not inferred.

## Traps — each cost a real mistake

- **Parent order is silent.** Nothing warns you; the merge looks identical locally either way. The damage only shows on GitHub as hundreds of extra commits. Check `git log -1 --format="%P"` before every push of a merge.
- **`:ours`/`:theirs` are whole-file landmines.** They return one side's raw blob for the whole file, discarding the other side's changes with no trace. Never use them on a conflicted file.
- **Terminal dumps render tabs as spaces**, so text copied out of a terminal dump does not match the file's bytes. Take edit anchors from `read_file` only.
- **An editor with the file open can clobber jj's disk writes.** Verify with grep after every file mutation.
