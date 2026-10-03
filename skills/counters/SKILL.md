---
name: counters
description: Builds the Counters strip at the top of the Daily: ate out, buckled, piano and stretched, with today's values and the last seven days. Use when the edition builder asks for the counters block.
---

# Counters

## Steps

1. Read the counters rows the runner passes in: day, kind and value for the last seven days.
2. Count a row added before noon toward the previous day.
3. Sum ate_out and buckled per day. Treat piano and stretched as yes or no.

## Returns

a counters block with today's values and a seven-day series for each kind.

## Guardrails

- Make no tool calls.
- Never change a past day's rows.

Call only the tools listed in tools.json.
