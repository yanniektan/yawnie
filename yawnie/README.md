# Yawnie Daily

A typewriter-style morning paper for iPhone. Small skill agents read your accounts
through MCP servers, a backend assembles the page, and a Print button sends it to your printer.

## Layout

| Folder | What lives there |
| --- | --- |
| `App/` | The SwiftUI app. Xcode project generated from `project.yml` |
| `Paper/` | The HTML and CSS newspaper page, shared by the app and the backend |
| `Backend/` | Supabase: database migrations and the edition function |
| `skills/` | Product skills the Daily runs each morning |
| `mcp/` | Custom MCP servers we host, plus mock servers for tests |
| `tools/` | Repo scripts, including the skill linter |
| `.claude/` | Builder agents and builder skills for Conductor |
| `.conductor/` | Conductor settings and scripts |
| `docs/` | PRD, decisions, QA notes |

## Quick start (macOS)

```bash
brew install xcodegen supabase/tap/supabase deno
cd App && xcodegen generate     # creates Yawnie.xcodeproj (gitignored)
python3 tools/check-skills.py   # lints skills/
supabase start                  # local database (needs Docker)
```

## Status

This is a skeleton. Folders, config and stubs exist; no feature is built yet.
`App/project.yml` and the Swift stubs were written without Xcode, so generate
and build once on your Mac and fix anything Xcode flags.
