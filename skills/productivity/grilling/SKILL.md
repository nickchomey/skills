---
name: grilling
description: Grill the user relentlessly about a plan, decision, or idea. Use when the user wants to stress-test their thinking, or uses any 'grill' trigger phrases.
---

Interview the user relentlessly until you reach a shared understanding. Map this as a **design tree**: every decision branches into the decisions that hang off it.

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled: the questions you can ask _now_ without guessing at answers you haven't heard yet. Ask the whole frontier in one round, with your recommended answer on each. Then wait for the user's answers before the next round.

Deliver each round through the session's **interactive question tool** (the one that presents options with a freeform answer box): one call per round, the whole frontier in a single questions array. Map each question onto an entry:

- **header/title**: the question title (unique within the call, short).
- **question/body**: background, the choices spelled out, and your recommended answer with the reason for it.
- **options**: the concrete choices, your pick marked as recommended; freeform input stays enabled so answers outside the options survive.

A round too large for one call splits across consecutive calls — it still arrives as questions through the tool, never as a wall of prose.

Word each question so "yes" accepts your recommended answer.

Each round the user answers reshapes the tree: settled decisions push the frontier outward and unblock questions that depended on them. Recompute the frontier and ask the next round. A question whose answer depends on another question still open in this round belongs to a _later_ round, not this one.

Finding _facts_ is your job, never the user's. When a frontier question needs a fact from the environment (filesystem, tools, etc.), dispatch a sub-agent to find it; don't ask the user for anything you could look up yourself. Don't block on it: a running exploration is an unsettled prerequisite, so only the questions downstream of it wait for the sub-agent to report; ask the rest of the frontier now. The _decisions_ are the user's: put each to them and wait.

The session is done when the frontier is empty: every branch of the design tree visited, nothing left silently assumed. Do not act on it until the user confirms you have reached a shared understanding.
