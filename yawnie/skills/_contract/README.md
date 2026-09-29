# Skill contract

Every folder in `skills/` is one product skill the Daily runs.

- `SKILL.md`: frontmatter with `name` (equal to the folder) and `description` (1024 characters at most), then the steps.
- `tools.json`: the MCP servers and tools this skill may call. The runner passes nothing else.
- `tests/`: cases the skill must pass, run against fixtures.
- `fixtures/`: fake emails, forecasts, tracks and pages. No real data, ever.

The block a skill returns is defined in `Backend/supabase/functions/_shared/blocks.ts`.
Known MCP servers are listed in `mcp-servers.json`; `tools/check-skills.py` rejects unknown ones.
