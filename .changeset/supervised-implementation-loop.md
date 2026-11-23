---
"mattpocock-skills": minor
---

`implement` is now model-invoked and follows the project's own agent instructions instead of a fixed suite and git branch. It leaves independent review to the supervising session and ends with `retro`, whose output becomes the process-notes section of the report. `retro` is model-invoked, formats each candidate as category, evidence and proposed change, and can run from the live session when its log is unreadable. `code-review` is VCS-neutral, accepts a jj change ID as the fixed point, reads the repo's agent instructions and process docs as standards sources, and can run per landing. `implement-spec` uses the repo's isolation mechanism, has each implementer call `implement`, and has the supervisor review each landing before merge. The router and READMEs follow the new flow.
