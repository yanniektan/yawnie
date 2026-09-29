---
name: stock-yoga
description: Builds the yoga bar of the Daily: the next Vinyasa class at Life Time Midtown after work. Use when the edition builder asks for the yoga bar.
---

# Stock yoga

## Steps

1. Use nimble_extract on the Life Time Midtown class schedule page.
2. Keep today's Flow (Vinyasa) and SOL (Guided Vinyasa) classes that start after the finish time (default 6:00 p.m.).
3. Return the next one.

## Returns

a bar block with one bar: minutes until the next class, labelled with its name and time.

## Guardrails

- If the schedule cannot be read, return an unavailable block. Never guess a time.
- Respect the site's terms. If the page disallows automated reading, return unavailable.

Call only the tools listed in tools.json.
