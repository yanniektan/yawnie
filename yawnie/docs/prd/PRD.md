# Yawnie Daily: PRD and Skill Agents

2026-09-29 · @Yannie

## Overview

Yawnie Daily is one iPhone app that assembles a typewriter-style morning paper from small skill agents and prints it when you tap Print. There is no second version.

**What changed.** The plan is now built around skills, not data connectors. Each part of the paper (weather and outfit, market insights, stock bars, the comic and so on) is one skill: a `SKILL.md` that says what it reads, what it does and what it returns. Each skill gets one builder agent in Conductor. Skills reach your accounts through MCP servers instead of hand-written API code. MCP saves that code, but it does not open anything Apple or a vendor keeps closed, and you still sign in to each account once.

**What I need from you.** The skill catalog has a Use / Maybe / Cut column for every skill. Set it, and I will cut the doc down to what you will really build.

**Where reality differs from the list.** Four requests do not work the way they are written:

- **Journal.** iOS gives apps no way to read your Journal entries. Apple offers only a picker for moments you choose to share, and it works on iPhone but not iPad. So the comic reads a short note you type or paste into Yawnie.
- **Hours on social media.** Screen Time data can only be shown inside a sandboxed Apple view in the app. It cannot be copied onto the printed page or saved to a backend.
- **The Amazon Buy button.** No API exists for consumers. The button opens Amazon's add-to-cart link with your usual items loaded, and you tap checkout yourself.
- **Sending to your parents.** iOS lets an app prepare the message and photo, but you press Send.

The rest of the catalog lists each skill's catch.

**Working assumptions** (challenge any of these)

- One user, one iPhone, New York City by default, US Letter paper, one page, front side only.
- Body text in Courier Prime and headlines in Special Elite, both open-licensed typewriter fonts. Check their licence files when you bundle them.
- The Print button opens the system print sheet. After you pick your printer once, the app remembers it.
- A small backend (I suggest Supabase) stores your counters and saved editions, and runs each skill as an AI call that is allowed to use only its own MCP servers. No key ever sits inside the app.
- Personal data now goes to an AI service: your note, your emails, your spending and your song titles. That reverses the last draft. Each skill spec says exactly what leaves the phone.

## The page

The paper reads top to bottom: your four counters first, then the day's information, then the comic. A strip of five buttons sits under it on screen and never prints.



**Look.** Typewriter type throughout, black ink on white, thin double rules between sections. No colour, so it prints cleanly on any printer. The comic is black-and-white line art with typed captions.

**Counters, top of the page**

- Ate out and Buckled are tap counters. Each tap adds one and saves to the backend.
- Piano and Stretched are yes or no for the day.
- The printed page shows today's value and the last seven days.

**The Print button.** It builds a one-page US Letter PDF from the same HTML the screen uses and opens the system print sheet. After you choose a printer once, later taps print straight to it. Nothing prints unless you tap.

### Screens

1. **The Daily.** The page itself, with the five buttons underneath.
2. **Action screens.** One per button: grocery checklist, amenities checklist, unsubscribe list, parents message.
3. **Sources.** Connect Gmail and Spotify, and grant Photos and Contacts.
4. **Settings.** Your city (New York by default), daily budget cap, staples list, and printer.

### Success metrics

| Metric | Target |
|---|---|
| App open to page in the printer tray | Under 60 seconds |
| Counter tap saved | Under 1 second |
| A failed skill stops the paper | Never. Its box says "Not available this morning" |

### Technical notes

- SwiftUI shell, iOS 18 or later, iPhone first.
- The paper is an HTML and CSS template shown in a `WKWebView` and turned into a PDF with `WKWebView.createPDF`. Bar charts are inline SVG in the same HTML.
- The edition builds when you open the app, or earlier if iOS grants background time. A saved copy shows instantly while the new one builds.
- Bundle ID `com.yawnie.app`, Team ID `3MW3WVL926`.

## Skill catalog

Fifteen skills. Ready-made MCP servers cover weather, market data, Gmail and web reading. Three skills need a small custom MCP server: sad songs, the comic, and one-click unsubscribe. Set the last column for each row.

If I had to pick the first four: Counters, Weather and outfit, Chemistry, and the Budget bar. Together they exercise the database, a ready-made MCP, a web-reading MCP and Gmail, so the whole engine is proven early.

| Skill | Reads through | Verdict | The catch | Your call |
|---|---|---|---|---|
| Counters | Your Supabase database | Easy | Taps made before noon count for yesterday (my assumption) |  |
| Weather and outfit | AccuWeather MCP for the forecast, Nimble MCP for fashion articles | Easy | Trends come from articles only. Social apps have no usable feed |  |
| Prof G Markets insights | Nimble MCP for show notes and newsletter, Gmail MCP if you subscribe, Twelve Data MCP for company news | Medium | The show is audio with no transcript, so insights come from show notes and the newsletter |  |
| Stock bar: groceries | Gmail MCP, reading Amazon order emails | Medium | No Amazon API, and email wording can change |  |
| Stock bar: yoga | Nimble MCP, reading Life Time's schedule page | Hard | The schedule is a live app page, and reading it may breach the site's terms. Confirm the club is Life Time Midtown, 110 W 56th St |  |
| Stock bar: budget | Gmail MCP, reading Chase alert emails | Medium | Chase emails each purchase over a threshold you set, not a daily summary. Set it very low |  |
| Hours on social media | No MCP. A Screen Time view on the phone | Awkward | The data cannot leave Apple's sandboxed view, so it cannot print. It needs the Family Controls entitlement |  |
| Sad songs on repeat | A custom Spotify history MCP, because the official one has no history tool | Awkward | Last 50 plays only, and no mood data, so the AI guesses "sad" from title and artist |  |
| Replenish groceries | Gmail MCP for the last order date, your checklist, an add-to-cart link the app builds | Medium | No Amazon shopper MCP. The link fills your cart and you check out |  |
| Replenish amenities | Same as groceries | Medium | Same catch |  |
| Clean inbox | Gmail MCP to list and trash, plus a custom one-click unsubscribe tool | Medium | MCP can list and trash. Unsubscribing needs each sender's own link |  |
| Message parents | Photos and Contacts on the phone. The skill writes the text | Easy | You press Send. An app cannot send silently |  |
| Deep dive: why buy | Twelve Data, FMP or Morningstar MCP for analyst data | Medium | A reported analyst view, not advice. Some data tiers are paid |  |
| Chemistry Q and A | Nimble MCP for a recent real-world source | Easy | IB past papers are copyrighted, so the questions are original, in HL style |  |
| Comic | A custom image-model MCP. The lesson comes from a note you type | Hard | Journal cannot be read, and the registry has no image-generation MCP |  |

No Amazon shopper MCP exists in the registry; the Amazon one there is for sellers. Shipt has a grocery MCP if you ever want to switch stores.

**Sources.** Apple: Journaling Suggestions picker, Apple forum: Screen Time report sandbox, Life Time Midtown yoga classes, Amazon Add to Cart form, Chase: credit card alerts, Spotify developer mode changes, Prof G Markets feed. MCP servers checked in the connector registry on 2026-09-29.

## Skill specs

Each skill is a `SKILL.md` in `skills/<name>/`. Every spec says what it reads, what it returns, and the guardrail. A skill may call only the MCP tools listed under Reads.

### counters

- **Reads:** the `counters` table in Supabase. The app writes it; no MCP.
- **Returns:** a `counters` block with today's values and the last seven days.
- **Guardrail:** a tap saves at once, and the skill never edits a past day.

### weather-outfit

- **Reads:** AccuWeather MCP for New York City (or your saved city). On weekends, Nimble MCP `nimble_search` for fashion trend articles.
- **Returns:** a forecast line and one outfit. Weekdays: a work outfit that suits the weather. Weekends: a Y2K look, with the article it came from.
- **Guardrail:** no article, no trend claim.

### profg-insights

- **Reads:** Nimble MCP for the latest Prof G Markets show notes. Gmail MCP `search_threads` for the Monday newsletter. Twelve Data MCP `get_company_news` for any tech ticker mentioned.
- **Returns:** up to three bullets: a tech stock, why it came up, and any feature launch or major news, each with a source link.
- **Guardrail:** paraphrase only, no quote over 15 words, and label the bullets "from show notes" because there is no transcript.

### stock-groceries

- **Reads:** Gmail MCP `search_threads` for Amazon order emails, then `get_message` for the item lines.
- **Returns:** a `bar` block: days since your last order, next to your staples (grapes, strawberries, yogurt, granola, salad).
- **Guardrail:** read-only. If an email will not parse, it prints "check Amazon".

### stock-yoga

- **Reads:** Nimble MCP `nimble_extract` on Life Time Midtown's class schedule.
- **Returns:** a `bar` block: the next Flow (Vinyasa) or SOL (Guided Vinyasa) class after your finish time (a setting, default 6:00 p.m.).
- **Guardrail:** if the schedule cannot be read, it says so and never guesses a time.

### stock-budget

- **Reads:** Gmail MCP `search_threads` for yesterday's Chase alert emails, then `get_message` to read each amount.
- **Returns:** a `bar` block: yesterday's total against your daily cap (monthly budget divided by days).
- **Guardrail:** read-only, and it prints how many alerts it counted so a missing email is visible.

### social-hours

- **Reads:** nothing over MCP. The app shows Apple's Screen Time report view, and a field where you type the number.
- **Returns:** a `number` block from what you typed.
- **Guardrail:** never estimated.

### sad-songs

- **Reads:** a custom Spotify MCP tool `recently_played`, up to the last 50 tracks.
- **Returns:** tracks played three or more times in that window (a setting), and which of them look sad.
- **Guardrail:** labelled a guess, because the AI judges mood from title and artist alone.

### cta-groceries and cta-amenities

- **Reads:** the checklist you keep in Settings (item name plus its Amazon product link), and Gmail MCP for the last order date.
- **Returns:** a `checklist` block. The Buy button builds one Amazon add-to-cart link from the ticked items.
- **Guardrail:** never checks out. It opens your cart and you finish there.

### cta-inbox

- **Reads:** Gmail MCP on yannietan.work@gmail.com: `search_threads` for promotions and newsletters, grouped by sender.
- **Returns:** a `list` block: each sender with a count and latest subject, a Trash button, and an Unsubscribe button.
- **Guardrail:** nothing moves until you confirm. Trash only, never permanent delete, and a protected-senders list is skipped.

### cta-parents

- **Reads:** your latest five photos on the phone, your Contacts picker, and the day's blocks above.
- **Returns:** a `message` block: five photos to choose from, and a short text written from the day's facts, such as "I went for a long run".
- **Guardrail:** you press Send. The AI writes from the day's facts and never sees the photo.

### deep-dive

- **Reads:** Twelve Data, FMP or Morningstar MCP analyst tools, plus Nimble MCP `nimble_search`.
- **Returns:** a `text` block of at most 200 characters: one stock with a recent buy rating, the reported reason, and the source and date.
- **Guardrail:** always printed with "Reported analyst view, not advice."

### chem-fact

- **Reads:** Nimble MCP `nimble_search` for one recent real-world item, such as a materials-science paper or an engineering use at Boeing.
- **Returns:** a `qa` block: one original IB HL-style question, its answer, and one or two sentences on real-world use with a source link.
- **Guardrail:** the question is written fresh, never copied from an IB paper, and the real-world line comes only from a page the skill actually retrieved.

### comic

- **Reads:** the note you type today, through the app, and a custom image-model MCP.
- **Returns:** a `comic` block: four panels of black-and-white art with no lettering, and typed captions stating the life lesson.
- **Guardrail:** step one, the language model, turns the note into a lesson and a four-panel script with names removed. Step two, the image model, sees only that script and never the note.

## Edition engine and backend

One backend service runs your skills in parallel and hands the app a finished edition. Each skill is its own AI call, and each can use only its own MCP servers.

### How an edition is built

1. The app opens and sends a **device context**: your typed note, the social-media number you typed, and anything else only the phone has.
2. The backend starts every skill you set to Use, all at once. Each is a Claude call with that skill's `SKILL.md` as its instructions.
3. Each call gets only its own MCP servers, and within them only the tools its spec lists.
4. Each skill returns one block of JSON. A skill that fails or runs past 45 seconds returns "Not available this morning".
5. The backend fills the HTML template, saves the edition, and returns it. The app shows it and can print it.

### What MCP does and does not do

- Claude's MCP connector reaches **remote** MCP servers over HTTP only. It cannot run a local server on your machine, and the server must be reachable from the internet.
- The connector needs a beta header, currently `mcp-client-2025-11-20`. A newer beta, `mcp-client-2026-09-15`, lets you pin each server's tool list so a server that changes its tools cannot change what a skill sees mid-run.
- Your backend gets and stores each account's sign-in token and passes it to the connector. So you still sign in once per account. MCP removes the per-API code, not the sign-in.
- Three servers do not exist yet, so we build them and host them at a public address: Spotify history, image generation, and one-click unsubscribe. They live in `mcp/`.

**Things only the phone can do** are not MCP at all: the Screen Time view, Photos, Contacts, the Messages sheet, and printing. The app does them and passes the results in as device context.

### Two ways to run it

- **A. Your own backend (my pick for the product).** It builds on demand, and a scheduler can pre-build at 6:00 a.m. so the paper is ready when you open the app.
- **B. Fastest first look.** Run the skills inside Claude on a schedule, using connectors you already have (Gmail is connected), and write the edition to Supabase for the app to read. Less code, but no on-demand build, and you depend on Claude's scheduling.

### The block each skill returns

```ts
type SkillResult = { skill: string; generatedAt: string; block: Block };

type Block =
  | { type: "text"; title: string; lines: string[]; sources?: string[] }
  | { type: "number"; title: string; value: number; unit: string }
  | { type: "counters"; today: Record<string, number | boolean>; week: Record<string, number[]> }
  | { type: "bar"; title: string; bars: { label: string; value: number; unit: string; note?: string }[] }
  | { type: "checklist"; title: string; items: { name: string; checked: boolean; buyUrl?: string }[] }
  | { type: "list"; title: string; rows: { primary: string; secondary?: string; count?: number }[] }
  | { type: "qa"; question: string; answer: string; realWorld: string; source: string }
  | { type: "message"; draft: string }
  | { type: "comic"; lesson: string; panels: { imageUrl: string; caption: string }[] }
  | { type: "unavailable"; skill: string; reason: string };
```

### An example skill

```markdown
---
name: weather-outfit
description: Writes the Weather section of the Daily, the New York City forecast and one outfit. Use when the edition builder asks for the weather block.
---

# Weather and outfit

1. Get today's forecast for the saved city (default New York City) from the AccuWeather MCP.
2. Monday to Friday: suggest one work outfit that suits the forecast.
3. Saturday and Sunday: use nimble_search to find two recent articles on Y2K fashion, then suggest one Y2K outfit.
4. Return a text block: a one-line forecast, then the outfit. On weekends, put the article titles and links in sources.
5. If no article is found, give a weather-based outfit and make no trend claim.

Call only the tools named above.
```

### Where data lives

```sql
create table counters (
  id uuid primary key default gen_random_uuid(),
  day date not null,
  kind text not null check (kind in ('ate_out', 'buckled', 'piano', 'stretched')),
  value integer not null default 1,
  created_at timestamptz not null default now()
);

create table editions (
  day date primary key,
  html text not null,
  blocks jsonb not null,
  created_at timestamptz not null default now()
);
```

Sign-in tokens are stored encrypted on the backend, never in the app. Row-level security limits every table to you.

### What leaves your phone

| Skill | What is sent | To whom |
|---|---|---|
| comic | Your typed note with names removed, then only a four-panel script | A language model, then an image model |
| cta-parents | The day's facts, never the photo | A language model |
| stock-groceries, stock-budget, cta-inbox | Subjects and bodies of matching emails | A language model, through the Gmail MCP |
| sad-songs | Track titles and artists | A language model |
| weather-outfit | Your city | The weather MCP |
| Everything else | Nothing personal | Public sources only |

## Conductor file structure and roster

One repository holds the app, the backend, the custom MCP servers and the skills. There are two kinds of skill, and it helps to keep them apart. **Product skills** in `skills/` are what the Daily runs each morning. **Builder skills** in `.claude/skills/` teach the Conductor agents how to build the app.

```text
yawnie/
├── CLAUDE.md, AGENTS.md          # rules every agent reads first
├── README.md, .editorconfig, .gitignore
├── .mcp.json                     # MOCK servers and a dev Supabase project only
├── .github/workflows/ci.yml
├── App/                          # SwiftUI app (XcodeGen: project.yml, no .pbxproj in git)
│   ├── project.yml
│   ├── Yawnie/
│   │   ├── YawnieApp.swift, Yawnie.entitlements
│   │   ├── Features/             # Daily, Counters, Actions/{Groceries,Amenities,Inbox,Parents}, Sources, Settings
│   │   ├── Services/             # edition client, print, photos, messages
│   │   └── Resources/Fonts/
│   ├── ScreenTimeReport/         # DeviceActivityReport extension
│   └── YawnieTests/
├── Paper/                        # template.html, paper.css, fonts/, sample/edition.sample.json
├── Backend/supabase/
│   ├── config.toml, seed.sql
│   ├── migrations/               # counters, editions (RLS)
│   └── functions/
│       ├── _shared/              # blocks.ts, skills.ts
│       ├── edition/              # runs the skills in parallel, saves editions
│       └── counters/
├── skills/                       # PRODUCT skills, one folder each (15)
│   ├── _contract/                # README.md, mcp-servers.json (registry)
│   └── <skill>/                  # SKILL.md, tools.json, tests/, fixtures/
├── mcp/                          # custom MCP servers we host
│   ├── spotify-history/, comic-art/, unsubscribe/
│   └── mocks/                    # accuweather, gmail, nimble, spotify, twelvedata, comic-art
├── tools/check-skills.py         # lints every SKILL.md, tools.json and server name
├── .claude/
│   ├── agents/                   # one builder agent per roster row (14)
│   └── skills/                   # BUILDER skills
│       ├── swiftui-screen/, mcp-server-builder/, newspaper-template/
│       └── skill-writer/, xcode-build-test/
├── .conductor/
│   ├── settings.toml
│   └── scripts/                  # setup.sh, test-all.sh, archive.sh
└── docs/                         # prd/, decisions/, qa/
```

**Real accounts never touch the builders.** `.mcp.json` lists only mock MCP servers that return fixture emails, fixture forecasts and fixture tracks, plus a development Supabase project. Your real Gmail, Spotify and Amazon sign-ins exist only in the deployed backend.

### `.conductor/settings.toml`

Conductor's current recommendation is a `settings.toml` in `.conductor/`; the older `conductor.json` still works but is legacy. This follows the documented shape. Check it against the schema line before committing.

```toml
"$schema" = "https://conductor.build/schemas/settings.repo.schema.json"

[scripts]
setup = "./.conductor/scripts/setup.sh"
archive = "./.conductor/scripts/archive.sh"
run_mode = "nonconcurrent"

[scripts.run.test]
command = "./.conductor/scripts/test-all.sh"
default = true
icon = "play"

[scripts.run.build]
command = "xcodegen generate --spec App/project.yml --project App && xcodebuild -project App/Yawnie.xcodeproj -scheme Yawnie -destination 'generic/platform=iOS Simulator' -derivedDataPath \"$HOME/.yawnie-build/$CONDUCTOR_WORKSPACE_NAME\" build"
```

The per-workspace `-derivedDataPath` stops parallel agents from overwriting each other's Xcode builds.

```bash
#!/usr/bin/env bash
# .conductor/scripts/test-all.sh
set -euo pipefail
python3 tools/check-skills.py
if command -v deno >/dev/null; then
  deno test --allow-all Backend/supabase/functions
else
  echo "deno not installed, skipping backend tests"
fi
for d in mcp/*/; do
  case "$d" in mcp/mocks/) continue ;; esac
  if [ -f "$d/package.json" ]; then (cd "$d" && npm test --silent); fi
done
```

### Roster

| Agent | Owns | Builds | MCP used in its tests | Wave |
|---|---|---|---|---|
| core | `Backend/``supabase/functions/``edition/` | Block types, the parallel skill runner, the two Supabase tables | Supabase (dev project) | 0 |
| paper-designer | `Paper/`, `App/Print/` | The HTML and CSS page, bar charts, PDF, the Print button | None | 1 |
| app-shell | `App/` screens | The Daily screen, the five buttons, Settings, Sources | None | 1 |
| counters | `skills/counters/`, `App/Counters/` | Four counters and the seven-day tally | Supabase (dev) | 1 |
| weather-outfit | `skills/weather-outfit/` | The Weather section | AccuWeather, Nimble | 2 |
| chem-fact | `skills/chem-fact/` | Chemistry Q and A | Nimble | 2 |
| comic | `skills/comic/`, `mcp/comic-art/` | Note field, script step, image server | Image model (mock) | 2 |
| markets | `skills/profg-insights/`, `skills/deep-dive/` | Both market skills | Nimble, Twelve Data, Gmail (fixture) | 3 |
| gmail-skills | `skills/stock-groceries/`, `stock-budget/`, `cta-inbox/`, `mcp/unsubscribe/` | Three skills and the unsubscribe server | Gmail (fixture emails) | 3 |
| amazon-ctas | `skills/cta-groceries/`, `cta-amenities/` | Checklists and the add-to-cart link | Gmail (fixture) | 3 |
| parents-message | `skills/cta-parents/`, `App/Parents/` | Photos, Contacts, the Messages sheet | None | 4 |
| yoga-schedule | `skills/stock-yoga/` | The Life Time bar | Nimble | 4 |
| sad-songs | `skills/sad-songs/`, `mcp/spotify-history/` | The skill and its custom server | Spotify (fixture) | 4 |
| social-hours | `App/ScreenTime/` | The Screen Time report extension and typed number | None | 5 |

Any skill you mark Cut in the catalog drops its row.

### Run plan

1. **Wave 0, alone.** core. Merge it first; every other agent depends on its Block types.
2. **Wave 1, in parallel.** paper-designer, app-shell, counters.
3. **Wave 2, in parallel.** weather-outfit, chem-fact, comic. You can now read and print a real paper.
4. **Wave 3, in parallel.** markets, gmail-skills, amazon-ctas.
5. **Wave 4, in parallel.** parents-message, yoga-schedule, sad-songs.
6. **Wave 5, alone.** social-hours, the most restricted piece.

### First prompt for each workspace

```text
You are the <agent-name> agent. Read CLAUDE.md, then your agent file at
.claude/agents/<agent-name>.md. Load the builder skill it names before you start.
Task: <the row's Builds column>.
Stay inside the folders you own. Test only against fixtures and the mock MCP
servers in .mcp.json. When tests, tools/check-skills.py and the build pass,
open a pull request and stop. Do not merge.
```

### Rules that keep parallel agents safe

- One owner per folder. A change elsewhere is a request to another agent, written in the pull request.
- Every `SKILL.md` must pass `tools/check-skills.py`: it has a `name` and `description`, and lists only MCP tools that exist.
- A human merges every pull request into `main`. Agents never push to it.
- Three concurrent workspaces is the cap.
- No keys in the repo. Backend secrets live in `Backend/.env.local`, which is gitignored.

**Sources.** Conductor settings reference, Configure your project, Scripts, Claude MCP connector. Read on 2026-09-29.

## Apple configuration for com.yawnie.app

Register one explicit App ID. This version needs far fewer capabilities than the last draft: only Family Controls for the Screen Time view, and App Groups for that view's extension. HealthKit, WeatherKit and push notifications are gone.

| Setting | Value |
|---|---|
| Team ID / App ID Prefix | `3MW3WVL926` |
| Bundle ID (explicit) | `com.yawnie.app` |
| Full App ID | `3MW3WVL926.com.yawnie.app` |
| App ID description | `Yawnie Daily App` (no `@`, `&`, `*` or `"`) |
| Platforms on the ID | iOS, iPadOS, macOS, tvOS, watchOS, visionOS |
| Built | iPhone first, iPad later |
| Capabilities to enable | Family Controls, App Groups |
| Extension ID to register | `com.yawnie.app.screentime-report` (the Device Activity Report extension) |

**Family Controls has a catch.** Builds you install from Xcode onto your own phone can use the development entitlement. TestFlight and App Store builds need Apple to approve a distribution entitlement first. For a personal app installed from Xcode, you can start today.

**Confirm the spelling before you register.** A bundle ID cannot be changed once the App Store Connect record exists. Check that "yawnie" is what you want to live with.

### Info.plist privacy strings

| Key | Text to show |
|---|---|
| `NSPhotoLibraryUsageDescription` | Yawnie shows your latest photos so you can choose one to send to your parents. |

Use the system contact picker for your parents, and no Contacts permission is needed. Screen Time asks for its own permission through Apple's Family Controls prompt, with no plist string.

### Setup checklist

- [ ] Register the explicit App ID `com.yawnie.app` with the description `Yawnie Daily App`
- [ ] Enable Family Controls and App Groups on it
- [ ] Register `com.yawnie.app.screentime-report` for the Screen Time extension
- [ ] In Xcode, set the bundle identifier and team `3MW3WVL926`, with automatic signing
- [ ] Add the photo-library privacy string to Info.plist
- [ ] Create a Supabase project, one for development and one for real use
- [ ] Get keys for the language model and the image model, and sign in to Gmail once for the backend
- [ ] Spotify: create the app (the owner account needs Premium)
- [ ] Install on your phone from Xcode

## Risks and open questions

The biggest risk is data access, not code. Several skills depend on something a vendor or Apple controls, so each one is built to fail politely and leave the rest of the paper intact.

| Risk | Why it matters | Fallback |
|---|---|---|
| The MCP connector reaches only public HTTP servers | The custom servers cannot run on your laptop | Host the three small servers at a public address |
| A third-party MCP server changes or breaks | A skill could lose a tool overnight | Pin each server's tool list with the newer beta header, and print "Not available this morning" on failure |
| Sign-in tokens expire | Google's test mode ends tokens after 7 days, and Spotify's rules keep changing | Publish the Google project "In production", and add a re-sign-in screen |
| Life Time's schedule cannot be read, or reading it breaches the site's terms | It is a live app page | Show the class formats and a link to the schedule, or cut the bar |
| Screen Time is fragile and cannot print | Apple sandboxes the data, and developers report the permission being lost on iOS 26 | Live view on screen and a typed number for print |
| The AI misreads a Chase or Amazon email | Wording changes and amounts can be missed | Print how many emails were counted, or "check Amazon" |
| Private data reaches AI services | Your note, emails, spending and song titles are sent | Send the minimum, strip names, and cut any skill you dislike |
| "Why buy" reads like advice | It concerns a stock you might act on | Always print "Reported analyst view, not advice" |
| The comic art looks off | Image models draw lettering badly | No lettering in the art, typed captions, and you approve one style up front |

### Open questions

- Do you want the engine on your own backend (A), or a quick first look inside Claude with the connectors you already have (B)?
- Is "Lifetime" the Life Time club at 110 W 56th St in Midtown?
- Should a counter tap before noon count for yesterday?
- Which image model do you want for the comic, and is black-and-white line art right?
- Which items belong on the grocery and amenities checklists? Paste one product link each, once.
- Do you want the sad-songs skill at all, given it needs a custom server and can only guess?
