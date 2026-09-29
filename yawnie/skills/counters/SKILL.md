---
name: counters
description: Builds the Counters strip at the top of the Daily: ate out, buckled, piano and stretched, with today's values and the last seven days. Use when the edition builder asks for the counters block.
---

# Counters

`tally.ts` implements these steps exactly. The runner may call `tallyCounters(rows, today)` instead of a model.

## Steps

1. Read the counters rows the runner passes in: `day`, `kind` and `value` for the last seven days, and `today`, the current counter day.
2. Use each row's `day` as it is. The app already counts a tap made before noon toward the previous day, so never shift a row again.
3. Keep the seven days ending on `today`, oldest first. Drop rows outside them, rows of any other kind, and rows whose value is not a whole number.
4. Add up the values for each kind on each day. A value of -1 is an undo.
5. Ate out and buckled: the day's sum, never below zero.
6. Piano and stretched: yes if the day's sum is above zero, otherwise no. In the seven-day series, yes is 1 and no is 0.

## Returns

A `counters` block. `today` holds each kind's value for `today`: a number for ate out and buckled, true or false for piano and stretched. `week` holds a seven-number series for each of the four kinds, oldest first, ending with today.

If the rows cannot be read, return `{ "type": "unavailable", "skill": "counters", "reason": "Not available this morning" }`.

## Example

Rows for 2026-09-23 to 2026-09-29 (see `fixtures/typical-week.json`), `today` = `2026-09-29`:

```json
{
  "type": "counters",
  "today": { "ate_out": 1, "buckled": 0, "piano": true, "stretched": false },
  "week": {
    "ate_out": [0, 1, 0, 2, 1, 0, 1],
    "buckled": [0, 0, 1, 0, 0, 0, 0],
    "piano": [1, 0, 1, 1, 0, 0, 1],
    "stretched": [0, 0, 1, 0, 1, 0, 0]
  }
}
```

## Guardrails

- Make no tool calls.
- Never change a past day's rows. Only read them.
- Never guess a missing day. A day with no rows is zero, or no.

Call only the tools listed in tools.json.
