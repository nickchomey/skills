---
name: brainstorm
description: "Run a collaborative brainstorming session that weighs the ways forward and leaves them open: no decision, no build. Use when the direction is not yet clear and the user does not know which way to go, whether comparing approaches or mechanisms, or working through something still foggy. A plan or a decision already in hand is grilling, not this."
---

# Brainstorm

A collaborative session that puts the ways forward beside each other and
stops short of choosing. What it produces is the comparison, plus the
questions that would decide between the candidates. Not a decision.

The user's own message is the inventory, not the preamble. Start from what
they have already said.

Nothing is built in this session, and nothing is decided in it.

The skill may be invoked at any time, on any ticket, and from inside another
skill's session: a brainstorm within a `grilling` session is ordinary, and a
ticket's `Type:` line does not gate it (`docs/issue-tracker.md`).

## What this session is not

- **Settling the decisions** — `grilling`. It converges on answers, and it is
  finished when no question is left open.
- **Navigating a foggy effort too big for one session** — `wayfinder`, which
  turns that fog into decision tickets on the tracker.

## The candidate set

The session has one working artifact: a set of candidates, each given the
same consequences. Everything below maintains it, and all of it is put in
front of the user — the comparison is the deliverable, never your private
working, and never something you reason out internally and answer from.

Keep it in a working file inside the effort, beside the issue it answers:
`docs/<effort>/brainstorm/<NN>-candidates.md`. A round adds to that file
and reads it back; the user sees the same set restated in the chat each
round. That file is the session's scratch; the ticket's own section is the
record, and it is where the set goes at the end. A set held only in the
conversation is gone the moment the answer to a round arrives.

**1. Take inventory before you ask anything.** Write down what they have
already given you: the candidates they named, what they are judging by, and
any leaning they have stated. That list is the session's state, and every
round adds to it. Do not ask them a question their own message already
answers.

If they have given you nothing yet, one open question gets them talking,
anchored in their situation rather than in a template. Their own words carry
intent your candidates cannot.

**2. The candidate set is yours to complete, not theirs to supply.** What
they named is a starting set. Make it complete and distinct:

- **add** candidates they have not named, and say that you are adding them
- **collapse** two that are the same idea wearing different words
- **separate** two that are not the same kind of thing — a separate process
  from something inside the current one, an existing mechanism from a new
  one. That difference is often the whole answer.

A list can be a category error rather than a set of alternatives: what starts
a job, where a resident process lives, and whether there is a bus, handed
over as one list. Those compose instead of competing, so comparing them
settles nothing. Split the list into the questions it is actually asking, say
which of them this session is deciding, and put that to the user first.

**3. Give every candidate the same consequences**, and render them as a table
— candidates down one side, those consequences across the top, plus a column
for anything the user said they are judging by — so a hole in the comparison
is visible instead of buried in prose. For each candidate:

- what it commits the user to, now and later
- what it forecloses — what gets hard or impossible once it is taken
- what it costs, in whichever currency matters here: time, complexity,
  coupling, a dependency, or the user's own attention
- what would have to be true for it to be the right one

A pick is provisional or absent. If you would pick one, say so and say what
makes you uneasy about it, marked clearly as provisional. The unease is part
of the comparison; a pick presented flat is a decision made on the user's
behalf.

**4. A round is a group of candidates, not a single question.** Take the ones
that can be judged together, put the comparison to the user, and wait for the
answer. Their answer reshapes the set, so recompute what is still unjudged
before the next round.

**5. Nothing is settled, so nothing is a prerequisite.** A candidate drawn
above another is a place to look, not a gate. The one real prerequisite is a
fact.

**6. Keep the fog as fog.** A patch they can feel but not yet phrase does not
have to become a candidate. Leave it, and say that you are leaving it.

## Asking

Every question in a round goes to the user through the active harness's question UI, in one call, with the choices as `options` and freeform left open. A question whose job is to make them **describe** something is asked the same way, in that same call, with the options left out and freeform carrying the answer. Nothing is asked in the chat prose that the tool could ask.

## Facts are yours, intent is theirs

- A fact about this repo or the environment: go and look, or dispatch a
  subagent.
- Knowledge from outside: `research`.
- A candidate that can only be judged by seeing it: `prototype`. A rough
  artifact to react to beats a description of it.
- A claim the user makes about how something behaves — "the workers share no
  state", "that endpoint is eventually consistent" — is a fact, and it is
  yours to check against the code or the docs. Look before you build on it or
  argue with it.

Never ask the user for something you could look up. A missing fact is a
reason to go and find it, not to hold the round up: go, and put the rest of
the round to them meanwhile.

Only what the user said goes in as theirs; mark everything else as your
guess. A guess they can correct often beats a question: "I'm guessing this
bites because X, right?"

## What each round reports back

After a round, restate the set: the candidates, the consequences applied, and
the cells still empty. That restatement is the progress, and it is how the
user sees the shape of a set too large to hold in their head.

## Regrounding the vocabulary

If the words stop matching what they mean, stop and re-agree them before
going on. `domain-modeling` is the skill for it: it resolves a word doing
several jobs, and records a hard decision once one has actually been made.
Any decision made in this session is theirs, and goes down as theirs.

## Ending

- The session ends when the user says the thinking is done, not when the
  questions run out. An empty question set is `grilling`'s stopping
  condition, not this one's.
- Nothing is recorded as a decision.
- Close by naming what is still open: **the facts still missing**, and **the
  questions that would decide between the candidates**. Those two lists are
  what makes the comparison usable later.
- The landscape is written into the ticket this session answers — the file
  under `docs/<effort>/issues/NN-<slug>.md` — as a section of its own,
  headed so that it reads as alternatives rather than decisions. That
  ticket's `Status:` line is left alone: this session does not resolve it.
   Ask for leave to write it in the first round's question-UI call,
  as a question of its own rather than folded into another, and do not repeat
  it at the end. Where there is no ticket to write into, ask where the
  landscape should go rather than inventing a directory.
- Where the ticket already carries a reading of its own — an earlier pass
  written while the user was away, say — the new section stands beside it. Do
  not edit or delete the older one; say in the new section what it overturns,
  and on what evidence.
- Hand off when the direction settles: `grilling` for the decisions, `to-spec`
  and `to-tickets` when the build spans more than one session, and `implement`
  to build each ticket. If the effort turns out bigger than one session can
  hold, `wayfinder` charts it as a map of decision tickets, and this landscape
  is what it reads.

## Red flags

| Thought | Reality |
| --- | --- |
| "I'll ask them to describe the problem" | Read their message first. The cold-start question is for when they have given you nothing; after a position, work that. |
| "Their list of options is the list" | It is a starting set. Complete it, collapse it, separate it. |
| "I'll warm up with an easy open question" | After they have given you a position, a warm-up is a stall and it reads as not listening. |
| "I'll work the comparison out privately and answer from it" | The comparison is the deliverable. |
| "I'll pick one, to save them the effort" | A pick closes a question they wanted open. Mark it provisional, and name the unease. |
| "I have enough — time to decide" | Deciding is `grilling`. |
| "The questions have run out" | Not the end here. The session ends when the user says it does. |
