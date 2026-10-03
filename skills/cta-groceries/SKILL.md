---
name: cta-groceries
description: Builds the replenish-groceries checklist: staples to tick and a Buy link. Use when the user opens the groceries action.
---

# Cta groceries

## Steps

1. Read the staples list the runner passes in (grapes, strawberries, yogurt, granola, salad, and any others).
2. Use search_threads and get_message to find the last order date for each.
3. Pre-tick items whose last order is older than the threshold (default 7 days).

## Returns

a checklist block. Each item carries its own buyUrl, which the app combines into one add-to-cart link.

## Guardrails

- Never check out. The app opens the cart and the user finishes there.

Call only the tools listed in tools.json.
