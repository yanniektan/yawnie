---
name: deep-dive
description: Writes the Deep dive: one niche stock and the reported reason an analyst says to buy, in 200 characters. Use when the edition builder asks for the deep dive block.
---

# Deep dive

## Steps

1. Use get_analyst_data to find a niche stock with a recent buy rating.
2. Use nimble_search or get_company_news to confirm the analyst's reason and its date.
3. Write at most 200 characters: ticker, the reported reason, source and date.

## Returns

a text block.

## Guardrails

- Always end with 'Reported analyst view, not advice.'
- Report the analyst's view. Do not add your own.

Call only the tools listed in tools.json.
