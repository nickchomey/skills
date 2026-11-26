---
name: wayfinder
description: Plan a huge chunk of work (more than one agent session can hold) as a shared map of decision tickets on your issue tracker, and resolve them one at a time until the way to the destination is clear.
disable-model-invocation: true
---

A loose idea has arrived, too big for one agent session, and wrapped in fog: the way from here to the **destination** isn't visible yet. Wayfinding is about finding that way, not charging at the destination. This skill charts the way as a **shared map** on the repo's issue tracker, then works its **decision tickets** (questions whose resolution is a decision, not slices of a build to execute) one at a time until the route is clear.

The destination varies per effort, and naming it is the first act of charting: it shapes every ticket. It might be a spec to hand off and iterate on, a decision to lock before planning starts, or a change made in place like a data-structure migration. The map is domain-agnostic: engineering work, course content, whatever fits the shape.

## Plan, don't do

Wayfinder is **planning** by default: each ticket resolves a decision, and the map is done when the way is clear, with nothing left to decide before someone goes and does the thing. The pull to just do the work is usually the signal you've reached the edge of the map and it's time to hand off.

An effort can override this in its **Notes**, carrying execution into the map itself; absent that, produce decisions, not deliverables. Carrying execution means each ticket is resolved by deciding it **and building it**, and two things follow:

- **Ordering is per ticket, not per phase.** The decision and its implementation are one sitting, because the implementation wants the reasoning verbatim rather than a summary of it. If the destination is a spec, the spec stops being a gate and becomes an output of the closed tickets.
- **An edge changes meaning.** It reads _"don't build before that"_ rather than _"don't decide before that"_. The two coincide until a ticket is decided without being built, and **such a ticket still blocks its dependents.**

Reach for the spec-splitting skills (`/to-spec`, `/to-tickets`) **inside** a ticket that turns out multi-session, rather than once for the whole map.

## Refer by name

Every map and ticket is an issue, so it has a **name**: its title. In everything the human reads (narration, the map's Decisions-so-far), refer to it by that name, never by a bare id, number, or slug. A wall of `#42, #43, #44` is illegible; names read at a glance. The id and URL don't vanish; a name wraps its link, but they ride _inside_ the name, never stand in for it.

**Tables are the exception.** A lookup row may key on the number, because the reader arrives holding one and wants the row. Prose still names the ticket.

## The Map

The map is a single issue on this repo's issue tracker, labelled `wayfinder:map`, the canonical artifact. Its tickets are child issues of the map.

The map is an **index**, not a store. It lists the decisions made and points at the tickets that hold their detail; a decision lives in exactly one place, its ticket, so the map never restates it, only gists it and links.

**The skill outranks the map.** The Notes carry preferences, not permissions: where a note conflicts with this skill, the skill wins and the note is a standing decision to revisit. A session that says so is more useful than one that quietly obeys the note.

**Where the map, its child tickets, blocking, and frontier queries physically live is tracker-specific.** The issue tracker should have been provided to you. If not, tell the user to run `/setup-matt-pocock-skills`. Consult the tracker doc's "Wayfinding operations" section for how _this_ repo expresses them. If no tracker has been provided, default to the local-markdown tracker.

**With no tracker doc, these are that default:** the map is `docs/<effort>/map.md`; a ticket is `docs/<effort>/issues/NN-<slug>.md`, numbered from `01`, carrying `Type:`, `Status:`, `Epic:` and `Blocked by:` lines above the question and a `Map:` line linking back; a resolved ticket moves to `docs/<effort>/issues/resolved/NN-<slug>.md`, keeping its number, with every link to it repointed, its own `Map:` line included.

### The map body

The whole map at low resolution, loaded once per session. Every ticket has a row in `## Tickets`, and the epics group those rows in `## Epics and their tickets`; both tables are kept in sync on create, close and park, so a session reads state from them rather than loading every ticket body.

```markdown
## Destination

<what reaching the end of this map looks like: the spec, decision, or change this effort is finding its way to. One or two lines; every session orients to it before choosing a ticket.>

## Notes

<domain; skills every session should consult; standing preferences the human set for this effort, never an agent's own workaround for a rule it found inconvenient>

### Decisions taken while charting

<!-- only when charting ran without an interview: the calls made on the user's behalf, one line each, each naming the ticket that constrains it. Not Decisions-so-far (no ticket holds them yet) and not fog (they are sharp enough to state). -->

### Epics

<one entry per epic: a name, then a paragraph. See "Epics" below for what the paragraph has to say.>

- **<Epic name>**: <what this epic delivers, which tickets cluster in it and what they share, where it sits in the order of work and why, and what it deliberately does not cover.>

## Order of work

<!-- the sequence the effort is taken in, stated once, at ticket granularity. This is the only place that orders anything: numbers never express order. Strike through an entry when it is taken and leave its number alone, so references keep pointing at the same item; a parked entry stays unstruck and is annotated instead. Omit the section when first-by-number is the order you want. -->

1. <ticket name>: <why it comes first>
2. <ticket name>: <what it waits for>

## Tickets

<!-- every ticket, one row, keyed by number: this table exists for lookup, so numbers belong here. State is frontier / blocked by <number, number> / parked / resolved. Keep it in sync on create, claim, close and park. -->

| # | Ticket | Epic | Type | State |
| - | ------ | ---- | ---- | ----- |
| 01 | [<ticket title>](link) | <Epic name, or none> | research | frontier |

## Epics and their tickets

<!-- one row per epic, in the order the epics begin. Every ticket appears in exactly one row; a ticket with no Epic: line goes in the "No epic" row. This table exists for reading, so it carries names, not numbers alone. -->

| Epic | Open | Parked | Resolved |
| ---- | ---- | ------ | -------- |
| **<Epic name>**: <one-clause reminder of what it delivers> | [<NN> <title>](link) | none | [<NN> <title>](link) |
| *No epic* | none | none | [<NN> <title>](link) |

## Decisions so far

<!-- the index: one line per closed ticket, enough to judge relevance, then zoom the link for the detail the ticket holds -->

- [<closed ticket title>](link): <one-line gist of the answer>

## Not yet specified

<!-- see "Fog of war": in-scope fog you can't ticket yet; graduates as the frontier advances -->

## Parked

<!-- see "Parked": in scope, deliberately not being worked now, not foreclosed; a HITL ticket waiting on a human belongs here, with its questions written on it. Omit the section while nothing is parked. -->

## Out of scope

<!-- see "Out of scope": work ruled beyond the destination; closed, never graduates -->
```

[`MAP-EXAMPLE.md`](./MAP-EXAMPLE.md) beside this skill is one map filled to the minimum: copy its section order and the depth of its epic paragraphs. Anything thinner is under-filled; anything much longer belongs in a ticket.

**When charting runs without an interview**, an autonomous chart or one delegated to another session, the calls made in the user's place go in `### Decisions taken while charting` under Notes: one line each, each naming the ticket it constrains, each open to challenge on that ticket. They are not **Decisions so far**, because no ticket holds them, and not fog, because they are sharp enough to state. Say plainly that they were chosen rather than settled, and by whom: **the agent's call, never the human's instruction.**

### Tickets

Each ticket is a **child issue** of the map; the tracker's issue id is its identity. Each ticket links back to its map using the tracker doc's link convention (local markdown: a `Map:` line with a relative link; GitHub/GitLab: a `Part of #<map>` line at the top). Its body is the question, sized to one 100K token agent session:

```markdown
## Question

<the decision or investigation this ticket resolves>
```

Each ticket carries a `wayfinder:<type>` label, one of `research`, `prototype`, `grilling`, `task` (see [Ticket Types](#ticket-types)). `wayfinder:` labels are the only labels a map and its tickets carry, never a triage label like `ready-for-agent`: they are decisions, not implementation work.

The tracker's header lines sit above the question: type, status, blocking, and an `Epic:` line naming the epic the map's Notes describes. The `Epic:` line is what `## Epics and their tickets` groups by; a ticket without one is legal and lands in *No epic*.

A session **claims** a ticket by assigning it to the dev driving the map, **first**, before any work, so concurrent sessions skip it. That assignee _is_ the claim: an open, unassigned ticket is unclaimed.

Blocking uses the tracker's **native** dependency relationship: essential because it renders the frontier _visually_ in the tracker's own UI, so the human sees what's takeable without opening the map. Only a tracker that lacks native blocking falls back to a body convention. A ticket is **unblocked** when every ticket blocking it is closed; the **frontier** is the open, unblocked, unclaimed children, the edge of the known. The map's `## Order of work` picks among them; where it is absent, first by number. A **parked** ticket is neither open nor closed, so it sits off the frontier without being foreclosed; see [Parked](#parked).

The answer isn't part of the body; it's recorded on resolution (see [Work through the map](#work-through-the-map)). Assets created while resolving a ticket are linked from the issue, not pasted in.

### Epics

A map big enough to be worth wayfinding usually has clusters: tickets that share blocking edges because they deliver one thing together. Naming those clusters, an `Epic:` line on each member ticket, makes the map legible as a handful of deliverables rather than a flat list of twenty questions.

**An epic is described by a paragraph, never a label.** Each names four things: what the epic delivers when it is done, which tickets cluster in it and what they share, where it sits in the order of work and why, and what it deliberately does not cover, which is the boundary with the epic beside it. "Shell emission and delivery" is a label. "The shell's bytes do not vary by route, and the shell is delivered per viewer: the split, the artifact the shell is filed as, and the three shell-owned blocks. It comes before universalization because a route document cannot be shared until the shell already is" is a description.

**Two tables carry the clustering.** `## Tickets` indexes every ticket once by number with its epic, type and state; it exists for lookup, so it keys on numbers. `## Epics and their tickets` groups the same tickets under their epics, split by open, parked and resolved; it exists for reading the effort as a handful of deliverables, so it carries names. Both are kept in sync on every create, close and park.

It is a **naming convention and nothing more**: no files, no tracker objects, and blocking edges remain the only thing that decides what *can* start. The order of work only breaks ties among tickets that are equally takeable, which is why it never disagrees with an edge. Two notes on the vocabulary. This is Agile's "epic", not the `task` ticket type below, which means something else entirely: the type for manual work that unblocks a decision. And the *names* belong to the effort, not to this skill; they go in the map, beside the order of work.

**A ticket may belong to no epic**, and saying so is better than inventing a home for it: charting tickets and one-off decisions often belong to none. They go in the epic table's *No epic* row.

### Parked

An open ticket is on the route, and if it is unblocked it is on the frontier. **Parked** is the state for work that genuinely belongs to this effort but is deliberately not being worked now. A parked ticket keeps its question, the facts its answer recorded and its blocking edges; it sits off the frontier; and it is **not foreclosed**, so no redraw of the destination is needed to pick it up.

**Waiting on a human is a parking reason.** A HITL ticket whose questions went unanswered is parked with those questions written on it, so the next session with a person present picks it up where it stopped. Parking is a state, not a verdict on the question.

**A parked ticket's order-of-work entry is not struck.** It has not been taken, and the map should still show it as the next thing the moment a human is present, so annotate the entry *parked, awaiting a human* instead. Strike it only when it actually resolves.

Parked is the third of three ways work sits off the route, and the boundaries between them are the whole point:

- **Parked**: in scope, and the question is sharp. Not being worked now.
- **Not yet specified** (fog): in scope, but the question can't yet be stated sharply.
- **Out of scope**: past the destination.

Parking is the right move when the reason for not working something is **sequencing** rather than scope. Closing it instead forecloses it, and getting it back takes a redrawn destination and a fresh effort.

## Ticket Types

Every ticket is either **HITL** (human in the loop, worked _with_ a human who speaks for themselves) or **AFK**, driven by the agent alone. A HITL ticket only resolves through that live exchange; the agent never stands in for the human's side of it (a grilling agent that answers its own questions has broken this).

**Put the questions to the human through the session's question tool**, a round at a time, with a recommended answer on each. A run that is declared unattended, or whose prompt forbids questions, does not ask at all: it **parks the ticket** with the unanswered questions written on it, sets its state to parked, moves it to the map's Parked column, and leaves its dependents blocked. An invented answer that keeps the run moving is worse than a parked ticket, because it reads afterwards exactly like a decision the human made.

**No map note waives this, and the map cannot vouch for who wrote it.** A note saying the owner opted out of interviews is either the human's preference or an agent's workaround, and nothing in the file tells them apart. So an unattended run **parks the ticket and puts the waiver itself to the human** as that ticket's open question (*the map says interviews are skipped for this effort; did you set that?*) rather than guessing in either direction. A session where the human confirms it may then work on the record; one where they deny it removes the note and restores the interview. More generally: **never record a preference on the human's behalf, and never attribute to them something they did not say.**

**The question belongs in the session that asks it**, because that is where the human will look, so a dispatched session is the right place to ask, and waiting on the answer is the right thing to do. Three outcomes: **answered**, and the work proceeds on the record; **dismissed**, which is a no, so park the ticket and notify the human that it waits on them; **declared unattended** (by the human, or by the run's own instructions), which parks it without asking. Never treat silence as consent, and never write a dispatch prompt that forbids questions when the ticket is HITL.

- **Research** (AFK): Reading documentation, third-party APIs, or local resources like knowledge bases to surface a fact a decision waits on. Resolved by a subagent that calls the Skill tool with "research". Use when knowledge outside the current working directory is required.
- **Prototype** (HITL): Raise the fidelity of the discussion by making a cheap, rough, concrete artifact to react to (an outline, a rough take, a stub, or UI/logic code) by calling the Skill tool with "prototype". Links the prototype as an asset. Use when "how should it look" or "how should it behave" is the key question.
- **Grilling** (HITL): Conversation. The default case. Always call the Skill tool twice, for "grilling" and "domain-modeling".
- **Task** (HITL or AFK): Manual work that must happen before a _decision_ can be made: nothing to decide, prototype, or research, but the discussion is blocked until it's done. Signing up for a service so its API can be judged, provisioning access, moving data so its shape can be seen. This is the one type that _does_ rather than decides, and it earns its place by unblocking a decision, not by delivering the destination. The agent drives it alone where it can (AFK); otherwise it hands the human a precise checklist (HITL). Resolved when the work is done; the answer records what was done and any resulting facts (credentials location, new URLs, row counts) later tickets depend on.

## Fog of war

The map is _deliberately_ incomplete: don't chart what you can't yet see. Beyond the live tickets lies the **fog of war**: the dim view of decisions and investigations you can tell are coming but can't yet pin down, because they hang on questions still open. Resolving a ticket clears the fog ahead of it, graduating whatever's now specifiable into fresh tickets, one at a time, until the way to the destination is clear and no tickets remain.

The map's **Not yet specified** section is where that dim view is written down: the suspected question, the area to revisit later. It's the undiscovered frontier _toward_ the destination: everything here is in scope, just not sharp enough to ticket. Write as loosely or as fully as the view allows; it doubles as a signpost for collaborators reading where the effort is headed.

**Fog or ticket?** The test is whether you can state the question precisely now, _not_ whether you can answer it now.

- **Ticket when** the question is already sharp, even if it's blocked and you can't act on it yet.
- **Not yet specified when** you can't yet phrase it that sharply. Don't pre-slice the fog into ticket-sized pieces: it's coarser than a ticket, and one patch may graduate into several tickets, or none, once the frontier reaches it.

**Not yet specified** excludes what's already decided (Decisions so far), what's already a live ticket, and what's out of scope (the next section).

## Out of scope

Fog only ever gathers _toward_ the destination. The destination fixes the scope, so work beyond it is **out of scope**: it isn't fog, and it doesn't belong in **Not yet specified**. It gets its own **Out of scope** section on the map: work you've consciously ruled out of _this_ effort. Scope, not sharpness, lands it here.

Out-of-scope work never graduates (the frontier stops at the destination), so it returns only if the destination is redrawn, and then as a fresh effort, not a resumption.

Ruling something out of scope is a scoping act, not a step on the route. When a ticket that already exists turns out to sit past the destination (mis-scoped in while charting, or exposed by a resolution), **close it** (a closed ticket is unambiguously off the frontier) and leave one line in the **Out of scope** section: the gist plus why it's out of scope, linking the closed ticket. It stays out of **Decisions so far**, which records the route actually walked; a scope boundary isn't a step on it.

**Scope decides this section, never urgency.** If a ticket belongs to this effort but is simply not being worked now, closing it is the wrong move, because closing forecloses it. **Park it instead** (see [Parked](#parked)), which keeps the question, the facts its answer recorded and its blocking edges. Reaching for Out of scope to mean _"later"_ is the one way to lose work permanently on this map.

## Invocation

Two modes. Either way, **never resolve more than one ticket per session**, with the exception of research tickets.

### Chart the map

User invokes with a loose idea.

1. **Name the destination.** Call the Skill tool twice, for "grilling" and "domain-modeling", to pin down what this map is finding its way to: the spec, decision, or change. The destination fixes the scope, so it's settled first.
2. **Map the frontier.** Grill again, **breadth-first** this time: fan out across the whole space rather than deep on any one thread, surfacing the open decisions and the first steps takeable now. Settle the **epic vocabulary** here too: the clusters the tickets fall into, named and ordered, because an epic decides which tickets exist, not the other way round. **If this surfaces no fog** (the way to the destination is already clear, the whole journey small enough for one session), you don't need a map. Stop and ask the user how they'd like to proceed.
3. **Create the map** (label `wayfinder:map`): Destination and Notes filled in, **a paragraph per epic**, the order of work stated when first-by-number isn't it, `## Tickets` and `## Epics and their tickets` populated, Decisions-so-far empty, the fog sketched into **Not yet specified**.
4. **Create the tickets you can specify now** as child issues of the map, then wire blocking edges in a **second pass** (issues need ids before they can reference each other). Write cross-references in that pass too, with real ids: a placeholder `#<n>` auto-links to an unrelated issue. Every new ticket gets a row in `## Tickets`, a place in its epic's row of `## Epics and their tickets`, and a link back to the map. Wiring sorts them into the frontier and the blocked; everything you can't yet specify stays in the fog: the **Not yet specified** section.
5. **Fire the research subagents.** For each `research` ticket you just created, spin up a subagent that calls the Skill tool with "research" to resolve it in parallel, capturing its findings on a throwaway `research/<name>` branch with a context pointer from the ticket. Push the branch but open no PR: it is never merged.
6. **Check the map against the format before stopping.** Every epic has a paragraph naming what it delivers, which tickets cluster in it, where it sits in the order and why, and what it excludes, and none is a bare label. `## Tickets` has one row per ticket with its epic, type and state, and no state reads "blocked" without naming the blockers. `## Epics and their tickets` holds the same tickets, once each, and its counts agree with that table. The order of work is stated whenever it differs from first-by-number. Fog is in-scope and merely unsharpened; out-of-scope items say why they are past the destination. Each ticket links back to the map.
7. Stop: charting is one session's work; it hand-resolves nothing.

### Work through the map

User invokes with a map (URL or number). A ticket is **optional**: without one, you pick the next decision, not the user.

1. Load the **map**: the low-res view, not every ticket body.
2. Choose the ticket. If the user named one, use it. Otherwise take the first frontier ticket in the map's `## Order of work`, or by number when the map states none. **Claim it**: assign it to yourself before any work.
3. Resolve it as the type its `wayfinder:<type>` label names (see [Ticket Types](#ticket-types)). Read the label, not just the body: the body never states the type. **Zoom as needed**: fetch the full body of any related or closed ticket on demand; call the Skill tool for whichever skills the `## Notes` block names. If in doubt, call the Skill tool twice, for "grilling" and "domain-modeling". A HITL ticket goes to the question tool **before** the work starts; if the run has no human to answer, park it as [Ticket Types](#ticket-types) says rather than deciding on their behalf.
4. Record the resolution: post the answer as a **resolution comment**, **close** the issue, set its row in `## Tickets` to resolved, move it between columns in `## Epics and their tickets`, and add its gist to Decisions-so-far as a **context pointer** (gist + link). Where the tracker files closed tickets somewhere else, that move happens in this step and every link to the ticket is repointed in it; and **a resolved ticket found sitting in the live folder is stale, not local custom**, so move it as you go rather than matching it. The same edit applies on a park: change the state, move the row, leave the question alone. When the effort carries execution, the implementation ships in this same step: the ticket is not resolved until it is built.
5. Add newly-surfaced tickets (create-then-wire, each with a row in `## Tickets` and a place in its epic's row, plus a link back to the map); graduate any fog the answer has made specifiable, clearing each graduated patch from **Not yet specified** so it lives only as its new ticket. If the answer reveals that a ticket (this one or another) sits beyond the destination, **rule it out of scope** rather than resolving it on the route. If the decision invalidates other parts of the map, update or delete those tickets.

The user may run unblocked tickets in parallel, so expect other sessions to be editing the tracker concurrently.
