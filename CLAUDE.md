# Yawnie Daily: rules for every agent

Yawnie Daily is an iPhone app that prints a typewriter-style morning paper.
Small product skills in `skills/` each produce one block; a backend assembles them.

## Repo map

See README.md. Product skills live in `skills/`. Builder skills for you live in `.claude/skills/`.

## Ownership

You own only the folders named in your agent file (`.claude/agents/`).
A change anywhere else is a request to another agent: write it in your pull request.

## Contracts

- A skill returns one block. Block types are in `Backend/supabase/functions/_shared/blocks.ts`.
- A skill may call only the MCP tools in its own `tools.json`.
- A failed skill returns an `unavailable` block. It must never stop the paper.

## Definition of done

`.conductor/scripts/test-all.sh` passes, the build passes, and a pull request is open.

## Never

- Commit a key, token or personal data.
- Test against real accounts. Use `fixtures/` and the mock servers in `mcp/mocks/`.
- Push to `main`, or merge your own pull request.

## Where the spec lives
The product spec is docs/prd/PRD.md. Build prompts are in docs/prd/BUILD_PROMPT.md. Read the PRD before building anything.
