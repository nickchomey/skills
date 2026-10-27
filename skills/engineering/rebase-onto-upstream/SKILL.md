---
name: rebase-onto-upstream
description: '**WORKFLOW SKILL** — Rebase a local jj patch chain onto a newer upstream release, resolve the conflicts, and prove that no upstream change was silently dropped. USE FOR: "rebase our patches onto upstream <rev>", "port our branch onto the new upstream", "sync our fork with upstream", "resolve the rebase conflicts", "upstream released X", auditing whether a conflict resolution dropped an upstream change. Bundles scripts/verify-port.sh. INVOKES: jj, the repo linter. DO NOT USE FOR: plain git rebase questions; merges that should not keep local patches; upstream work that touches no local patch.'
argument-hint: 'rebase onto <upstream-rev>'
user-invocable: true
---

# Rebase a patch chain onto upstream

A long-lived patch chain rebased onto a new upstream release produces conflicts that a merge tool — including jj's own `--tool=:ours|:theirs` — will resolve **wrongly and silently**: no error, no leftover markers, a clean linter. This skill is the procedure that makes each resolution auditable, plus the audit that shows what it did.

## When to use

- "rebase our patches onto upstream `<rev>`", "port our branch onto the new upstream"
- "sync our fork with upstream", "upstream released X, rebase onto it"
- "resolve the rebase conflicts"
- auditing an existing port — "did the rebase drop anything from upstream?"

## Authority

Discovery is read-only. A port request authorises: the duplicate line, resolution revisions in it, file edits inside those, read-only checks. It does **not** authorise: pushing; abandoning originals or deleting `pre-port`; touching revisions outside `<NEW>::`; destructive shortcuts (`abandon` elsewhere, `reset --hard`, `clean`, force-push, unrelated reformatting); deciding a genuinely incompatible conflict — especially one touching public interface, migration, data format, or security boundary. Report what you did and did not do; a clean tree is not a finished port.

## The mental model — this is what keeps the job small

jj's three-way merge loses nothing **by itself**. It applies upstream's side wherever our side left a region alone, and it reports a **conflict** wherever the two sides disagree. Therefore:

- every upstream change is either applied silently and correctly, or it is sitting in a conflict;
- a bad merge decision can **only** exist at a conflict;
- the audit is bounded to the **conflicted files**, not to upstream's whole delta — which is routinely enormous (334 files / ~82k added lines in the port this skill was built from).

Corollary: never review "the whole diff". Review the conflicts, and only the conflicts.

## 0. Establish OLD and NEW, and write them down

`OLD` = the upstream revision the chain sits on; `NEW` = the revision it is being ported onto. Walk the chain's parents until a revision's parent is the upstream tip — that parent is `OLD`. Record both in the report and in `references/repo-notes.md`. Auditing against the wrong revision is the one mistake the audit cannot catch. Safety net: `jj op log`; `jj undo` is progressive, `jj op restore <op-id>` jumps to an explicit state.

Read upstream's changelog for `OLD..NEW` **before** the diff: it states what changed and why, which the diff cannot tell you, and it makes a good skeleton for the report.

## 1. Port the chain — duplicate it, do not rebase it

```bash
jj log -r 'all()' --no-graph -T 'change_id.shortest() ++ "  " ++ description.first_line() ++ "\n"'
jj bookmark create pre-port -r <our-tip>
jj duplicate '<first-revision-of-ours>::<our-tip>' -o <NEW>
```

The first command checks for an interrupted previous port, whose duplicate line is still in `all()` — continue it or abandon it before starting a second one.

`jj duplicate -o <NEW>` is the same three-way merge `jj rebase` would do, but as a **second line of history**: the originals stay reachable under their own change ids, which is what the verification steps need. Verified on jj 0.45.1:

- Duplicates get **new change ids**; originals keep theirs and stay in a plain `jj log`.
- Bookmarks do **not** move — they still point at the originals. Repoint deliberately, and check `jj log -r @` first: after a squash or commit `@` is empty and the work sits at `@-`.
- `jj abandon '<old chain>'` at the end reproduces a rebase exactly — and **deletes those revisions' bookmarks**, `pre-port` included. Abandon after the audit passes, not before.
- `-o/--onto` is the flag (`-d/--destination` is deprecated).

Note the op id first.

## 2. Walk the conflicts, bottom-up

```bash
jj log -r '<first-revision>::' --no-graph \
  -T 'change_id.shortest() ++ "  " ++ if(conflict,"CONFLICT","clean   ") ++ " " ++ description.first_line() ++ "\n"'
jj resolve --list -r <rev>          # the paths this revision reports
```

Work **bottom-up**: a conflict is inherited by every descendant, so resolving an ancestor usually clears a run below it at once — but only for descendants that **do not themselves edit** the conflicted file. One that does keeps its conflict and needs its own resolution. Re-run the listing after every resolution; do not assume the count dropped. Repeated resolutions of the same conflict must stay consistent.

Scope everything to `<NEW>::` — the pre-port originals are not descendants of `NEW`, and this repository also carries unrelated conflicted revisions.

- **The end state is a conflicted root with a clean resolution child directly after it, once per root — that is the shape, not damage.** Resolving a root clears every descendant that was only
  *inheriting* its conflict, so the count falls in steps rather than by one. The reference port produced 36 conflicted revisions from the duplicate; they fell to 13 roots as resolutions landed, with the tip clean. Only roots are yours to resolve.
- **A descendant that is still conflicted after its root is resolved is a *new* root, not a leftover.** It happens whenever a later revision in the chain meets an upstream change to the same file on its own terms. Three of the thirteen roots in the reference port appeared this way, only after the previous root cleared — so re-run the listing after every resolution, and treat a count that refuses to drop as a new root rather than a failed resolution.

## 3. Make the resolution its own revision

```bash
jj new -A <conflicted-rev> -m "resolve conflict <short-change-id>: <conflicted description>"
```

- `-A` / `--insert-after` reparents the conflict's children onto the new revision. Plain `jj new` leaves a **sibling fork**, which resolves nothing.
- The conflicted revision keeps its markers; the resolution carries the fix. That split is the point — **the resolution's diff IS the audit record**, so it holds only the resolution, no drive-by fixes. Create it **before** touching any file. Before any later squash, re-run `jj st` and the conflict listing — a moved working copy or new conflicts mean the prior resolution is stale.
- Verify the insertion: the conflicted revision's old child must now be a child of the resolution.

## 4. Resolve by hand — never with `--tool=:ours|:theirs`

Verified three times in the reference port: **`jj resolve --tool=:theirs` returns the `+++++++` side, which is OUR rebased revision's raw *pre-rebase* blob for the WHOLE FILE.** It discards every upstream change in that file, leaves zero markers, and passes the language's syntax check. It prints success. Nothing warns you.

**Decide with both intents in hand, not from the markers.** Before touching a hunk, read what each side was trying to do: our revision's full description, and the descriptions of the upstream commits that changed this file (`jj log -r '<OLD>::<NEW>' -- <file>`). Markers show the bytes that disagree; they cannot tell you which side is right.

Triage each hunk — state what each side adds, removes, or changes — then:

- **Same intent**: pick the better implementation; if upstream already merged that fix, drop ours.
- **Orthogonal changes**: merge both, building our additions onto upstream's new structure.
- **Contradictory changes**: do not guess. Flag it to the user.
- Where incompatible, take the side matching the revision's stated purpose and report the trade-off. Never decide by newer, larger, or more convenient.
- Do not invent behaviour to make both sides compose. A design decision is an escalation.
- Generated artifacts and lockfiles are never hand-merged: regenerate from source.
- A green linter does not make a resolution correct.

Reading jj's markers, which is all you need:

```
<<<<<<< conflict 1 of 1
%%%%%%% diff from: <A> to: <B>      <- the other side, shown as a diff
 <diff lines>
+++++++ <C>                         <- our side, verbatim
>>>>>>> conflict 1 of 1 ends
```

- An **empty** `+++++++` side means our side **deleted** that region — take the deletion only if deleting it is that revision's stated purpose. The reverse: code absent from `NEW` (`jj file show -r <NEW> <file>`) was deleted upstream — do not resurrect it.
- **An empty `+++++++` side is not proof there is nothing to preserve.** Check whether upstream
  *added* inside the region our revision removes. Upstream's newest work sits where upstream last edited, which is often the very block our revision exists to delete: in the reference port, our revision deleted a registration block while upstream had added two new registrations inside it. Taking our side would have dropped them with no trace beyond anonymous ABSENT lines in the audit; they were **relocated** to the one place our chain performs that registration instead. When the addition is upstream's, find where our design puts the same job and move it there.
- **Establish each hunk's provenance with one command per symbol** instead of reasoning about which side looks newer: `jj file show -r <rev> -- <path> | grep -c <symbol>`, run against `NEW`, `OLD` and the pre-port tip. That is how the reference port told upstream's added symbols apart from revisions that were ours alone. Do not use `jj grep` for it: it answered about the working copy despite being given `-r <rev>`, printing zero for symbols the revision demonstrably contained.
- **A mechanical resolver is worth having, but it cannot decide a hunk that needs both sides.** If the repo provides a script that keeps our side of every conflict block and drops the diff side, check what it dropped per conflict rather than its exit code. Know its limitations before trusting it: it does not merge, and block orderings it doesn't expect slip past it.
- The marker labels name the **pre-port revisions**, still live thanks to step 1 — open them with `jj show -r <change-id>` instead of reading them out of the markers.

Read the **whole** file first — markers are inline and only the surrounding context makes them interpretable. Write one coherent merged block per hunk; never concatenate alternatives.

Then delete the marker block and **verify on disk immediately**: grep each marker family separately (`<<<<<<<`, `>>>>>>>`, `%%%%%%%`, `+++++++`), inspect leftovers starting with a backslash or diff `+`/`-` prefix (a line copied from a jj diff is not source until its prefix is gone), and grep for the upstream hunk you expected to keep. `jj st` should confirm: `Hint: Conflict in parent commit has been resolved in working copy.` Never retype a marker label's backslashes into an edit — a failed match beats literal `\\` in source. After two misses, re-read fresh and rewrite the whole region from that read.

## 5. Prove each resolution — five oracles

1. **Upstream's delta for that file first.** `jj diff --git --from OLD --to NEW -- <file>` — small (1–4 hunks in the reference port) against an enormous total delta. Know what you must not lose before choosing a side.

2. **Byte-identity, for files upstream did not touch.** If that diff is empty, the ported file must equal our pre-port file byte for byte: `diff <(jj file show -r <pre-port-rev> <file>) <file>` → identical. Not valid on the conflicted file itself — it legitimately contains upstream's edit too, so byte-identity there would be a bug. For that file the per-conflict record is the check.

3. **Functions our side never touched must be byte-identical to upstream.** Extract from both sides and `diff` them:
   ```bash
   diff <(awk 'index($0,"<signature>"){f=1} f{print} f&&$0=="\t}"{exit}' <file>) \
        <(jj file show -r <NEW> <file> | awk 'index($0,"<signature>"){f=1} f{print} f&&$0=="\t}"{exit}')
   ```
 This catches "we took our side wholesale and lost upstream's fix".

4. **A ported revision that came out empty means upstream already did that work.** `jj log -r '<NEW>:: & empty()'`. Its description now misdescribes the tree — usually abandon it, don't keep a no-op patch.

5. **The ported tip must differ from `NEW` in exactly the files the chain changes.** Put `jj diff --summary --from <NEW> --to <ported tip>` beside `jj diff --summary --from <OLD> --to <pre-port tip>` and compare the file sets. Identical sets mean nothing outside the chain moved and nothing inside it was dropped at file level; the line-level audit in step 6 then only has to explain the lines, not the files. One command, and it catches a resolution that edited a file it should not have touched.

## 6. Audit the whole port

```bash
./scripts/verify-port.sh -C <repo> <OLD> <NEW>
```

For every conflicted file it lists each line upstream introduced that is **absent** from the tree. Each ABSENT line needs a reason: the code it lands in was deleted on purpose, or its intent survives under different wording. Anything else is a dropped upstream change. The script finds candidates; you decide — and it also reports conflicted revisions **outside** the chain.

Exit status is the contract: `0` clean, `1` lines missing, `2` the script could not run.
**Exit 2 is not a pass.**

## 7. Run the suite, and classify every failure

A resolution can be byte-correct and still wrong: an invariant test that passed at `OLD` fails at `NEW` because of what our patches do to the code, and the audit in step 6 cannot see it. Run both suites and account for every failure.

The commands are per repository: run the suites recorded under **Tests** in `references/repo-notes.md` for the target repo, and bring up whatever harness that section says they need.

**Bring the harness up before reading any red.** A missing harness usually prints its own "test suite not found"/bootstrap line and exits non-zero, which reads exactly like a failing suite and is not one; an interrupted run can also leave state that makes every test fail until it is repaired. `references/repo-notes.md` records what each repo needs, and how long a full run costs.

**Upstream's tests pass at `OLD`** — that is the whole reason this step is mandatory. It makes a red test caused by our patch, categorically: never by upstream, and never "expected friction". Classify each failure before touching anything.

- **Our patch is incomplete or wrong → fix the patch, never the test.** The commonest form is a change that is right in one place and missing its counterpart. A table added to `schema()` and not to the registry that enumerates owned tables is one: the presence check builds its list from the registry while the column-count check reads `schema()`, so the table counts as permanently absent and the migrator re-runs on every load. Upstream's test caught a real defect there; it is not a test to be adjusted.
- **Our patch deleted the mechanism the test guards → rewrite the test to assert the new mechanism, naming what replaced it.** The guard is the asset; move its subject rather than deleting it. When the mechanism has genuinely gone with nothing in its place, deleting the test is right — and the per-conflict record says which of the two it was.
- **Engine or environment → decide which of the two is wrong, and say which.** Do not let this category absorb the other two. A failure is far more often our patch than the platform, and reaching for it first is how a real defect survives a port.

Extend the per-conflict record with a `Tests:` line for every test file the port touched.

### Conflicts inside `tests/` hide dropped upstream assertions

Step 6's audit compares upstream's *source* lines. A test file that both sides edited is where a resolution silently loses an assertion upstream added, because a test has no runtime caller and nothing downstream fails when an assertion goes missing.

Before resolving one, read what upstream was doing there — `jj log -r '<OLD>::<NEW>' -- <path>`. Taking our side wholesale is right only when upstream's whole delta for that file lies inside the conflicted region: the same rule as `--tool=:theirs` in step 4, and for the same reason.

## 8. Verify, then report

- `jj resolve --list` clean; marker grep clean; repo linter clean.
- Inspect the complete resolved files, not only the former hunks — surrounding invariants (ordering, validation, error handling, interfaces) may have moved.
- For every symbol upstream renamed or removed, grep the ported chain for the old name. A caller our side added will not conflict textually — it just breaks.
- **Where a symbol survives beside a new one, the audit cannot see the gap — adopt deliberately.** Upstream added `login_url()`, which appends a return destination and runs a filter, without removing the bare `auth_url()`. Nothing conflicted, the suite stayed green, and our rewritten nav went on calling the old accessor — losing the filter and the return destination at once. A renamed symbol is easy because it conflicts; a *new better accessor next to the old one* is the invisible case. Walk the call sites at the end of the port, decide for each whether it wants the new contract, and land that work as its own revision after the resolutions — never inside one.
- Judge checks by **output**, never exit status: jj exits 0 on an empty revset, so empty + 0 means "nothing found", not "all clear".
- Report with evidence — commands and counts, judgement calls called out, what the audit cannot decide, which upstream hunks you deliberately dropped and why.

### The per-conflict record — one block per conflicted file, required output

```markdown
### <path> — conflicted in <short-change-id>, resolved in <short-change-id>
- Our intent:      <the revision's stated purpose, for the code this file holds>
- Upstream intent: <the upstream revision that changed this file, and why>
- Upstream delta:  <n> hunks, <n> added lines (`jj diff --git --from OLD --to NEW -- <path>`)
- Compatibility:   compatible | incompatible | intent not stated anywhere
- Resolution:      <what the resolved hunk now does, and which side each part came from>
- Evidence:        <the commands run, and their observed output>
- Confidence:      <high | moderate | low>
- Not covered:     <what this record does not establish — say it, do not leave it implied>
- Tests:           <per test file this change touched: the failures seen, the step-7 class, and what changed>
```

Every claim needs the command that produced it. Unstated intent gets written down, not inferred. "No conflicts" is a result too — include the audit output. A green linter proves nothing about correctness.

## Traps — each cost a real mistake

- **`:ours`/`:theirs` are whole-file landmines.** Trap 4 above. Never — despite guides recommending them as the fast path.
- **No scratch files in the audited repo.** The shell creates a redirect target *before* the command runs, so jj snapshots it mid-task and rebases descendants. Use process substitution.
- **`conflicts()` is repo-wide.** Scope every audit with `conflicts() & <NEW>::`.
- **`jj -T` needs literal text quoted**: `'"resolved by " ++ change_id.shortest()'`. `change_id.short()` is the **full** id; `change_id.shortest()` matches `jj log`. `description("x")` is a full-string *glob* that matches nothing (trailing newline) — use `subject("x")` or `description(substring:"x")`.
- **Bare `jj restore` resets all of `@`**, brand-new files included. Restore exact paths only.
- **One port strategy.** Duplicate and rebase produce the same conflicts, but switching halfway leaves two half-histories no audit can reconcile.
- **Editor tripwire**: prefix a suspect command with `JJ_EDITOR=false` — fast failure (`Failed to edit description`) instead of a hang tells you a `-m`/`-u` is missing.
- **Ambiguous prefixes** (`yp` collided): use 3+ characters. **Check flags exist** (`jj help <cmd>`) — jj 0.45 here.
- **Interactive commands hang an agent**: bare `jj resolve`/`describe`, `jj split` without paths, `jj squash -i`, `jj diffedit`. Always `--list`/`-m`, always `JJ_PAGER=cat`. `jj resolve` with no flag is not a safe read.
- **`jj interdiff` against a revision's own duplicate is empty by construction** — it proves nothing. Do not cite it.
- **Nested repos**: `jj` answers for the *parent* repo outside a jj dir. Run `jj root` before anything that writes.
- **Re-run the audit after every resolution.** It is cheap, and the only thing between you and a silent drop.
- **A test that only runs under a condition the harness doesn't establish fails for the wrong reason.** Running the suite is not enough to read its result: if the code under test only wires itself up when a theme, flag, or feature is active and the fixture doesn't establish it, every assertion fails for a reason that has nothing to do with the port — and the failure message reads like a regression in the code under test, so check the guard before rewriting the assertion.

- **An edit-tool write can drop a closing brace from a CSS file and report success.** Measured in the reference port: replacing one declaration in `assets/css/shell.css` left the rule's `}` deleted and the file one brace short — 182 `{` against 181 `}` — so every rule after that point stopped applying. The header menu rendered as a vertical list, and the stylesheet parsed to 128 rules instead of 142. The anchor was the trap: the dump it was copied from had rendered the file's tabs as spaces, so the matched text was not the file's text. **After editing any CSS file, compare `grep -o '{' | wc -l` with `grep -o '}' | wc -l`, confirm the diff is exactly the lines you intended, and look at the rendered page — checking the rule you changed proves nothing, because a broken rule takes the rest of the file with it.** When the anchor cannot be trusted, restore the file from its parent revision and re-apply by line number.

## House style (adopt per repo)

- **One concern per revision, described fully.** A later edit belonging to an earlier revision gets squashed back (`jj squash --into <rev> -u -- <path>`), not left as an add-then-remove pair across two revisions.
- **No narration comments.** Comments describe what the code IS. Rationale goes in the revision description.
- Baseline pre-existing lint debt before blaming a resolution for it.

## Reference

- [scripts/verify-port.sh](./scripts/verify-port.sh) — the audit; takes `-C <repo> OLD NEW`.
- [references/repo-notes.md](./references/repo-notes.md) — repo-specific conventions to fill in for the target repo.
