---
name: stock-budget
description: Builds the budget bar of the Daily: yesterday's spending from Chase alert emails against a daily cap. Use when the edition builder asks for the budget bar.
---

# Stock budget

## Steps

1. Use search_threads for Chase alert emails dated yesterday.
2. Use get_message to read each amount, then sum them.
3. Compare the total with the daily cap the runner passes in.

## Returns

a bar block: yesterday's total against the cap, unit dollars, with a note saying how many alerts were counted.

## Guardrails

- Read-only.
- Always print the number of alerts counted so a missing email is visible.

Call only the tools listed in tools.json.
