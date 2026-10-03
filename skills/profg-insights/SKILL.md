---
name: profg-insights
description: Summarises tech-stock mentions and product news from Prof G Markets for the Daily. Use when the edition builder asks for the market insights block.
---

# Profg insights

## Steps

1. Use nimble_search to find the latest Prof G Markets episode notes.
2. Use search_threads to look for the Monday Prof G Markets newsletter, then get_message to read it.
3. Pick up to three tech stocks or product launches that were mentioned.
4. For each one, call get_company_news and keep a source link.

## Returns

a text block of up to three bullets, each with a source link, labelled 'from show notes'.

## Guardrails

- Paraphrase. Never quote more than 15 words.
- There is no transcript, so never imply the skill heard the episode.

Call only the tools listed in tools.json.
