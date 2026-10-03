---
name: weather-outfit
description: Writes the Weather section of the Daily: the New York City forecast and one outfit. Use when the edition builder asks for the weather block.
---

# Weather outfit

## Steps

1. Get today's forecast for the saved city (default New York City) from the AccuWeather MCP.
2. Monday to Friday: suggest one work outfit that suits the forecast.
3. Saturday and Sunday: use nimble_search to find two recent articles on Y2K fashion, then suggest one Y2K outfit.
4. On weekends, put the article titles and links in sources.

## Returns

a text block: a one-line forecast, then the outfit.

## Guardrails

- If no article is found, give a weather-based outfit and make no trend claim.

Call only the tools listed in tools.json.
