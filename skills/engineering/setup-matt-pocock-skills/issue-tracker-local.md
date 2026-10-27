# Issue tracker: Local Markdown

Issues and specs for this repo live as markdown files in `docs/`.

## Conventions

- One feature per directory: `docs/<feature-slug>/`
- The spec is `docs/<feature-slug>/spec.md`
- Implementation issues are one file per ticket at `docs/<feature-slug>/issues/<NN>-<slug>.md`, numbered from `01`, never a single combined tickets file
- Triage state is recorded as a `Status:` line near the top of each issue file (see `triage-labels.md` for the role strings)
- Comments and conversation history append to the bottom of the file under a `## Comments` heading

## When a skill says "publish to the issue tracker"

Create a new file under `docs/<feature-slug>/` (creating the directory if needed).

## When a skill says "fetch the relevant ticket"

Read the file at the referenced path. The user will normally pass the path or the issue number directly.

## Wayfinding operations

Used by `/wayfinder`. The **map** is a file with one **child** file per ticket.

- **Map**: `docs/<effort>/map.md` (the Notes / Decisions-so-far / Fog body).
- **Child ticket**: `docs/<effort>/issues/NN-<slug>.md`, numbered from `01`, with the question in the body. A `Type:` line records the ticket type (`research`/`prototype`/`grilling`/`task`); a `Status:` line records `open`/`parked`/`claimed`/`resolved`; an `Epic:` line optionally names the epic the ticket belongs to (epics are defined in the map's Notes — see wayfinder Epics).
- **Links**: the map keeps a clickable catalog (`## Open tickets`, one `[Name](issues/NN-slug.md)` line per live ticket) and links each closed ticket from Decisions-so-far; every ticket links back with a `Map:` line (`[map](../map.md)`). Refer to tickets by name, never bare numbers.
- **Blocking**: a `Blocked by: NN, NN` line near the top. A ticket is unblocked when every file it lists is `resolved`.
- **Frontier**: scan `docs/<effort>/issues/` for files that are open, unblocked, and unclaimed; first by number wins. Parked tickets sit off the frontier without being foreclosed (see wayfinder Parked).
- **Claim**: set `Status: claimed` and save before any work.
- **Resolve**: append the answer under an `## Answer` heading, set `Status: resolved`, then append a context pointer (gist + link) to the map's Decisions-so-far in `map.md`.
