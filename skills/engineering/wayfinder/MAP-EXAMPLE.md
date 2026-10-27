# A map at minimum viable detail

Illustrative, not a real effort. Copy the section order and the depth of the epic paragraphs, not the content. Anything thinner than this is under-filled; anything much longer belongs in a ticket, not the map.

```markdown
# Household budget: Wayfinding Map

## Destination

A spec a bookkeeper can build from without asking how a transaction is attributed or how a month closes. Nothing is built during this map.

## Notes

**Domain.** A single-household budget: transactions arrive from a CSV export, get attributed to categories, and roll up to a month. CSV in, reports out; no bank connection.

### Epics

- **Ingest**: transactions arrive from the bank's export exactly once. It delivers the import command and the identity rule that makes a re-import idempotent, and it comes first because every later decision reads a transaction set that this one fills; the identity key is the column the store is shaped around. It does not cover what a transaction means once it is stored, which is the other two epics' work.

- **Attribution**: every transaction carries exactly one category, and categories survive being renamed. It delivers the category vocabulary and the rule for the transactions that fit none of them, and it follows Ingest because attribution is an edit over rows that must exist first. It does not cover reporting: how a category rolls up is the Report epic's work, and a category's visual identity is nobody's yet.

- **Reporting**: a month closes and can be read. It delivers the monthly rollup, the comparison against the previous month, and the one screen that shows both. It comes last because it reads categories and transactions both. It does not cover export of the report, which is out of scope.

## Order of work

The epics give the phases; this is the order tickets are taken in, and it is the only place that orders anything.

1. ~~[01 Import identity](issues/01-import-identity.md): taken, and nothing else has rows to work on without it.~~
2. [02 Category vocabulary](issues/02-category-vocabulary.md): the shape the store and the report both inherit.
3. [03 Attribute on import](issues/03-attribute-on-import.md): needs a vocabulary to attribute to.
4. [04 Monthly rollup](issues/04-monthly-rollup.md): needs attributed rows.
5. [05 The report screen](issues/05-report-screen.md): the last thing, and the one that prototyped.

## Tickets

| # | Ticket | Epic | Type | State |
| - | ------ | ---- | ---- | ----- |
| 01 | [Import identity](issues/01-import-identity.md) | Ingest | research | resolved |
| 02 | [Category vocabulary](issues/02-category-vocabulary.md) | Attribution | grilling | frontier |
| 03 | [Attribute on import](issues/03-attribute-on-import.md) | Attribution | grilling | blocked by 02 |
| 04 | [Monthly rollup](issues/04-monthly-rollup.md) | Reporting | grilling | blocked by 03 |
| 05 | [The report screen](issues/05-report-screen.md) | Reporting | prototype | blocked by 04 |

## Epics and their tickets

| Epic | Open | Parked | Resolved |
| ---- | ---- | ------ | -------- |
| **Ingest**: a statement arrives once, under one identity rule | none | none | [01 Import identity](issues/01-import-identity.md) |
| **Attribution**: one category per transaction, from a vocabulary that survives renames | [02 Category vocabulary](issues/02-category-vocabulary.md), [03 Attribute on import](issues/03-attribute-on-import.md) | none | none |
| **Reporting**: a month closes and can be read | [04 Monthly rollup](issues/04-monthly-rollup.md), [05 The report screen](issues/05-report-screen.md) | none | none |
| *No epic* | none | none | [06 Throwaway charting decision](issues/06-throwaway.md) |

## Decisions so far

- [Import identity](issues/01-import-identity.md): **a transaction's identity is date, amount and a normalised description; the bank's own id is stored but not trusted.** Re-importing the same statement inserts nothing, and the normalisation drops case and collapsing whitespace only.

## Not yet specified

- **Transfers between the household's own accounts.** They should not count as spending, but the rule needs a second account to exist first.
- **What a category's colour is for.** Whether categories carry presentation at all, and whether the report imposes one.

## Parked

- **Multi-currency.** In scope for the household, deliberately not on this map's route: the destination names one currency.

## Out of scope

- **Bank connections and automatic sync**, because the destination stops at a CSV export.
```
