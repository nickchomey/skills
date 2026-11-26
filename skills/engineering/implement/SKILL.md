---
name: implement
description: Implement a ticket or spec item by following the project's own working rules. Use when a supervising session dispatches implementation work, or when the user asks you to implement a ticket or spec.
---

Implement the work described by the user in the spec or tickets.

Do not reopen the plan. If the ticket is ambiguous or contradicts the code, report the conflict instead of redesigning the work.

If the user passes a ticket reference, fetch it from the issue tracker and state its title before starting. If the reference is ambiguous, ask.

Read the project's agent instructions first. Follow their verification tiers and report contract instead of a fixed suite or a fixed report shape.

Call the Skill tool with "tdd" where possible, at pre-agreed seams.

Work in one logical unit. When the work is done, leave the working copy in the state the project expects: a jj revision with a full description, a git commit on the current branch, or whatever its instructions name. Do not merge, land or publish the work yourself unless the project says to.

Before an edit, confirm `@` is the revision that should hold it. If `@` is a merge, a docs child, or another revision that must stay pure, run `jj new -m "<intent>"` first: a test or gate run does not move `@`, so an earlier merge is still the working copy when the next edit starts.

## Pre-flight before handoff

Do this in the implementer session before the internal review loop and before `retro`. The supervisor repeats the acceptance read from the diff, so hand them a map they can disprove rather than a list of claims.

### Acceptance-to-proof map

Quote each acceptance line from the ticket. Against each line, name the check that would fail if that line were false — the owning unit file, the exact browser block, a fast audit, or a read of the diff — and mark whether the proof is on the final head. Confirm every ticked line has a proof there. A clause deferred to another gate stays unchecked; a ticked line without a proof is not done.

### Negative-path checklist

Apply this to the diff, not only to the paths you wrote:

- For each new branch, exercise the other failure mode: a function that returns false must also be checked when it throws; a lookup by id as well as by card key; a record from another owner; a moved or missing first stage; a reference cycle.
- For each new set of ids, test an unselected member and a cross-owner member.
- For each rollback, make the operation throw, not just return false.
- For each new wire or persisted value, check the reader as well as the writer.

Record the paths you exercised and the result in the ticket evidence. If one cannot be exercised, say so in the report instead of ticking the line.

### Fast audits

Run these in the edit loop; they are per-edit and per-revision commands, not gates. Use the owning check files the ticket and the spec index name; do not infer the suite from the diff.

- Per edit: `mise run test:changed` (affected tests for the current revision, no file arguments) or `mise run test:related <source>` / `mise run test:file <test files>`; `mise run test:self <selftest file>` for one `scripts/**/*.selftest.mjs` file; `mise run check-mutation-anchors` (anchor audit); `mise run check-unit-coverage`; the spec-index audit (compare the ticket's owning check files with `docs/ledger/spec-index.md`); `mise run test:self app/scripts/build/test-unit-chain-parity.selftest.mjs` for unit-chain parity; `mise run check-script-modes`; `mise run tsc` only on type changes; `mise run check-i18n` only on copy; `mise run test-spec <spec> --grep "<title>"` for one owning browser block.
- Per revision: the owning unit file(s), the exact browser block(s) in one `test-spec` call, `mise run check-mutation-anchors` and `mise run check-unit-coverage`, plus one `mise run mutate-units --recipe <new>` proof for each new check. No full `test-unit`, no other engine and no full mutation suite.

Fix a red fast audit inside the revision; do not defer it to the wave. Read the final diff against the ticket scope before reporting: claimed files, marker leaks, the ticket's Status line, acceptance boxes and evidence counts.

## Internal review loop

For tickets that need independent context, run this loop before `retro`:

- Create at most two review sub-agents using the Standards and Spec briefs from the `code-review` skill, one per axis. Create each once, with fresh context: the diff command, the ticket path and the repo instruction paths only. Do not pass your reasoning, a summary of what you already checked, or your conclusions.
- Send a follow-up to those same two sessions with the new head on every iteration; do not create a new reviewer pair each round. They hold the earlier findings and verify closure.
- Tier by what needs independent context: a small mechanical ticket uses neither reviewer; a standard ticket uses the Spec reviewer alone unless the diff crosses files you did not open; cross-cutting work uses both axes, with the effort variant the `code-review` skill scales to the difficulty.
- Record the findings and their closure in the ticket evidence.

`retro` runs only after this loop closes, so its process notes include what the internal review caught.

## Report

End with the report the project's instructions require. When they ask for process notes, call the Skill tool with "retro" on your own session, after the internal loop closes, and make its output the process-notes section. Do not compress it.

The supervisor's independent review at landing stays theirs: do not treat your internal loop as that review or call `code-review` as the final authority. Use its briefs only inside the loop above, and check every acceptance criterion against its proving test before reporting.