## What it does

`jujutsu` is the discipline for driving Jujutsu instead of git. It tells the [agent](https://www.aihero.dev/ai-coding-dictionary/agent) which jj command replaces each git reflex, how to select the intended change before editing, and how to split, merge, bookmark, recover, and retire workspaces without losing evidence.

It never lets the agent touch git for version control. In a colocated repository the git CLI still works, which is exactly the trap: a `git log` or `git checkout` there reads or writes metadata jj also owns, and the two disagree about the working copy afterward. The skill keeps one tool in charge.

## When to reach for it

Type `/jujutsu`, or the agent reaches for it automatically when a task turns into version-control work beyond a status check.

| Your situation | Reach for |
| --- | --- |
| A task touches history, branches, bookmarks, or workspaces | `jujutsu` |
| Merging trunk into a branch while keeping local patches intact | [merge-trunk-into-branch](https://aihero.dev/skills-merge-trunk-into-branch) |
| Rebasing local patches onto a newer upstream release | [rebase-onto-upstream](https://aihero.dev/skills-rebase-onto-upstream) |
| WordPress updater, DDEV workspace, or upstream-export work in the Bedrock repo | That repo's own overlay skill, which builds on this one |

## Prerequisites

Jujutsu installed, and the working directory inside a jj repository. The skill is otherwise stateless: it writes no config and assumes no issue tracker or doc layout.

## Think in changes

The skill's leading word is **change**. Jujutsu has no staging area and no stash: the working copy *is* a commit, and `jj new` starts the next one with the current work as its parent. So every task begins the same way, by selecting the change it belongs to: continue the active one, or open a fresh change per independent unit, never amending someone else's work by accident.

The same unit thinking governs the rest. A split peels one file set into its own change. A merge keeps both lines of history as parents instead of rewriting one onto the other, and a conflicted merge stays in history with its resolution recorded in a clean child. The evidence of how the code got here survives, which is what makes a later question like "where did this hunk come from" answerable.

## Common questions

**Do I need this for a quick status check?**

No. Snapshotting with `jj status` at task boundaries belongs in always-on instructions, not in a skill. Reach for the skill when the operation is non-trivial: revsets, rewrites, merges, bookmarks, publication, or anything involving workspaces.

**Why not git commands in a colocated repo, if the git history is right there?**

Because the git view is a one-way mirror. Colocation exports jj state to git, but git commands that move branches or the working copy write state jj did not plan for, and recovery means reconciling two tools instead of one. `jj git ...` remains fine for transport (fetch, push), since that is the subcommand built for talking to git remotes.

## It's working if

- The first version-control command in a task is `jj status`, not `git status`.
- No git CLI appears in the trace for reads or writes; `jj git ...` appears only for fetch and push.
- Merges keep both parents, and a conflicted merge is followed by a child resolution rather than a rewrite.
- A new checkout goes through the workspace procedure instead of an ad-hoc copy or `git worktree add`.

## Where it fits

A reach-for-it-anytime standalone: it runs underneath whatever else you are doing the moment version control gets involved, rather than chaining into the idea-to-ship flow. Its closest neighbours are [merge-trunk-into-branch](https://aihero.dev/skills-merge-trunk-into-branch), which syncs a branch with trunk while folding upstream in, and [rebase-onto-upstream](https://aihero.dev/skills-rebase-onto-upstream), which ports a patch chain onto a newer release; both assume this skill's discipline and add the procedure for their specific shape. The full map lives in [ask-matt](https://aihero.dev/skills-ask-matt).
