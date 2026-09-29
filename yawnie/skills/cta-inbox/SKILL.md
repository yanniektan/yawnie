---
name: cta-inbox
description: Lists promotional senders in yannietan.work@gmail.com with buttons to trash and unsubscribe. Use when the user opens the clean inbox action.
---

# Cta inbox

## Steps

1. Use search_threads to find promotions and newsletters in the inbox.
2. Group them by sender with a count and the latest subject.
3. Skip any sender on the protected list.
4. After the user confirms a sender, call trash_thread for its threads and unsubscribe for its list.

## Returns

a list block: one row per sender.

## Guardrails

- Nothing moves until the user confirms.
- Trash only. Never delete permanently.

Call only the tools listed in tools.json.
