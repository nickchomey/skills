# Repo notes

The procedure in `SKILL.md` is generic. These are the bits that vary per repository — fill this in for the target repo **before** starting, or the verification steps will be wrong.

## Template

- **Repo layout**: where the jj repo root is, and whether nested repos exist.
- **Upstream base**: the upstream revision this chain last sat on, written down. The next port needs it as `OLD`; rediscovering it from the op log is avoidable work.
- **Indentation**: tabs or spaces; check with `sed -n 'X,Yp' <file> | cat -A`.
- **Lint one file**: e.g. `python -m py_compile <file>`, or the language's syntax-only check.
- **Lint sweep**: the exact command, and roughly how long it takes.
- **Style checker**: e.g. the project's linter/formatter, and any formatter whose alignment rules mean a small edit legitimately reflows neighbouring lines.
- **Full gate**: the command, and which of its stages cannot run locally.
- **Pre-existing debt**: files and counts, so a resolution is not blamed for them.
- **Tests**: what can actually run here, and what cannot.
- **Naming/description conventions** for revisions.

---

## Worked examples

Record each finished port below: its `OLD`/`NEW`, chain range, conflict count, and anything the next port should reuse (harness quirks, permanent conflict sites, adopted accessors).
