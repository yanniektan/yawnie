---
name: stock-groceries
description: Builds the groceries bar of the Daily: days since the last Amazon order for each staple. Use when the edition builder asks for the groceries bar.
---

# Stock groceries

## Steps

1. Use search_threads for Amazon order emails, then get_message to read the item lines.
2. For each staple the runner passes in, find the most recent order date.
3. Compute days since that order.

## Returns

a bar block: one bar per staple, unit days.

## Guardrails

- Read-only.
- If an email will not parse, say 'check Amazon' for that staple.

Call only the tools listed in tools.json.
