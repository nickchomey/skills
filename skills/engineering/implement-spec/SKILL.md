---
name: implement-spec
description: "Implement the result of /to-spec and /to-tickets in code."
disable-model-invocation: true
---

You have been provided a spec. This spec should have tickets associated with it, describing how to implement the spec.

The issue tracker should have been provided to you. If not, tell the user to run `/setup-matt-pocock-skills`.

The goal is the entire spec implemented on one **integration target**, with every ticket resolved the way the issue tracker closes work.

The tickets are not a list of steps. They are a **task graph** with blocking relationships between them. This means there is always a **frontier** of tickets which are ready to be grabbed.

Start a subagent with a fresh context window for new, distinct work. Continue the same implementer session through its ticket's review fixes, and the same review sessions through re-reviews of the same landing; re-anchor each to the new head first.

Communication to and from subagents should be sparse. Communicate primarily through **context pointers**: to the spec, tickets, research notes, and previous commits. Don't duplicate information already available via pointers.

**Implementer subagents** should be run in the background where possible for maximum concurrency.

## Steps

1. Read the spec and tickets to understand the task graph.

2. (optional) Use an **exploration subagent** to conduct any exploration required by the tickets - relevant codebase files or external documentation. Ensure the exploration subagent can save files - it should save its markdown notes in a directory outside the repo, accessible by all future subagents. This lets **implementer subagents** focus on implementation rather than exploration.

3. Create the integration target. Use the repo's isolation mechanism for implementers: a jj workspace or a git worktree. If the tracker closes work through PRs, or the user asks for one, open a draft PR after the first landing (a target with no commits ahead of main cannot open one), marked as closing the spec and tickets.

4. Use a fresh **implementer subagent** for each ticket, each in its own isolated checkout based on the integration target. Fixes for the same ticket stay in that implementer's session; a new implementer is for a new ticket. Each implementer subagent:
   - confirms its checkout is based on the integration target before starting, and resets onto it if not;
   - calls the Skill tool with `implement`, which drives `tdd` and ends with `retro` and the project's report;
   - syncs with the integration head before reporting (jj rebase or git merge, per the repo).

5. When an **implementer subagent** completes, the supervising session reviews the landing with `code-review` and dispositions its process notes. Re-reviewing the same landing after fixes continues the same Standards and Spec sessions, re-anchored to the new head. Merge only after the review is clean.

6. If this changes the **frontier** of available tickets, kick off more **implementer subagents** to work on the new tickets. This allows for maximum concurrency.

7. If the project reviews per landing, the final `code-review` over the integration target is optional. Run it when the project reviews at the end instead.

8. If a draft PR exists, mark it ready for review. Otherwise, resolve each ticket the way the issue tracker closes work, and report the integration target.

9. Clean up all **implementer subagent** workspaces.
