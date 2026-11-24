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

End with the report the project's instructions require. When they ask for process notes, call the Skill tool with "retro" on your own session and make its output the process-notes section. Do not compress it.

Independent review is the supervising session's job. Do not call "code-review" on your own work; do check every acceptance criterion against its proving test before reporting.