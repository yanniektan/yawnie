---
name: sad-songs
description: Lists songs played on repeat and which look sad, for the Daily. Use when the edition builder asks for the sad songs block.
---

# Sad songs

## Steps

1. Call recently_played (the last 50 tracks at most).
2. Group by track and keep tracks played three or more times (a setting).
3. For each, judge from title and artist whether it looks sad.

## Returns

a text block: track, artist, play count and a sad or not-sad mark, under the heading 'a guess'.

## Guardrails

- Always label the mood as a guess.
- Send nothing but titles and artists to the model.

Call only the tools listed in tools.json.
