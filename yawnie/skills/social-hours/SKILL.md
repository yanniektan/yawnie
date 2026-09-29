---
name: social-hours
description: Shows hours spent on social media in the Daily, from a number the user types. Use when the edition builder asks for the social media block.
---

# Social hours

## Steps

1. Read socialHours from the device context. It is a number the user typed.

## Returns

a number block with the value and unit hours.

## Guardrails

- Make no tool calls.
- Never estimate. If nothing was typed, return an unavailable block.

Call only the tools listed in tools.json.
