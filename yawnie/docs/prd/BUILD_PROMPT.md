# Build prompts for Conductor

Paste **Prompt 1** into the first Conductor workspace (Claude Code). Paste **Prompt 2** into each later workspace, filling in the agent name. Run waves in the order in `PRD.md` ("Run plan").

## Prompt 1: kick-off (one workspace, run once)

```text
You are building Yawnie Daily, one iOS app (SwiftUI, iOS 18) that assembles a
typewriter-style morning newspaper from small "skill" agents and prints it from a
Print button. Bundle ID com.yawnie.app, Team ID 3MW3WVL926. One app, no v2.

Read, in this order: CLAUDE.md, docs/prd/PRD.md, skills/_contract/README.md,
.claude/agents/core.md.

Then act as the "core" agent (Wave 0):
1. Make Backend/supabase/functions/_shared/blocks.ts the single source of truth for
   the Block types (it must match the block union in PRD.md, including `number`).
2. Finish the parallel skill runner in Backend/supabase/functions/edition/: one
   Claude call per skill, each allowed only the MCP servers in that skill's
   tools.json, 45 s timeout, an `unavailable` block on any failure.
3. Make the counters and editions migrations apply cleanly with RLS on.
4. Get `.conductor/scripts/test-all.sh` green using fixtures and the mock MCP
   servers in mcp/mocks only. Never use real accounts.
5. Open a pull request and stop. Do not merge. List anything in the PRD you
   believe is wrong or impossible under "Questions" in the PR description.

Rules: stay inside the folders you own; no keys or secrets in the repo; every
SKILL.md must pass `python3 tools/check-skills.py`.
```

## Prompt 2: per-agent (one workspace each, from Wave 1 on)

```text
You are the <agent-name> agent. Read CLAUDE.md, then .claude/agents/<agent-name>.md.
Load the builder skill it names before you start.
Task: <copy this agent's "Builds" cell from the roster in docs/prd/PRD.md>.
Stay inside the folders you own. Test only against fixtures and the mock MCP
servers in .mcp.json. When tests, tools/check-skills.py and the build pass,
open a pull request and stop. Do not merge.
```

## Prompt 3: if you want Claude to write the skills themselves

```text
Open skills/<skill-name>/SKILL.md. Rewrite it so that:
- the description says exactly when the edition builder should call it;
- the steps name only the MCP tools listed in tools.json;
- it returns exactly one Block (see Backend/supabase/functions/_shared/blocks.ts);
- it has a guardrail line and an "if the source fails" line;
- it includes one worked example of the output.
Add a fixture in skills/<skill-name>/fixtures/ and a test in tests/ that runs the
skill against the mock MCP server. Run tools/check-skills.py.
```
