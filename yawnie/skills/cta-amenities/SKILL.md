---
name: cta-amenities
description: Builds the replenish-amenities checklist: facial towels, toothpaste, lotion, soap, shampoo. Use when the user opens the amenities action.
---

# Cta amenities

## Steps

1. Read the amenities list the runner passes in.
2. Use search_threads and get_message to find the last order date for each.
3. Pre-tick items whose last order is older than the threshold (default 30 days).

## Returns

a checklist block with a buyUrl per item.

## Guardrails

- Never check out. The app opens the cart and the user finishes there.

Call only the tools listed in tools.json.
