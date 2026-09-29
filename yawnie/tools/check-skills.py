#!/usr/bin/env python3
"""Lints every product skill in skills/. Exits 1 on any problem."""
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
SKILLS = ROOT / "skills"
registry = json.loads((SKILLS / "_contract" / "mcp-servers.json").read_text())
errors = []

for d in sorted(p for p in SKILLS.iterdir() if p.is_dir() and not p.name.startswith("_")):
    md = d / "SKILL.md"
    if not md.exists():
        errors.append("%s: missing SKILL.md" % d.name)
        continue
    m = re.match(r"^---\n(.*?)\n---\n", md.read_text(), re.S)
    if not m:
        errors.append("%s: SKILL.md has no frontmatter" % d.name)
        continue
    front = dict(
        line.split(":", 1) for line in m.group(1).splitlines() if ":" in line
    )
    name = front.get("name", "").strip()
    desc = front.get("description", "").strip()
    if name != d.name:
        errors.append("%s: name '%s' must equal the folder" % (d.name, name))
    if not desc:
        errors.append("%s: description is empty" % d.name)
    if len(desc) > 1024:
        errors.append("%s: description is over 1024 characters" % d.name)
    tj = d / "tools.json"
    if not tj.exists():
        errors.append("%s: missing tools.json" % d.name)
        continue
    try:
        servers = json.loads(tj.read_text()).get("servers", [])
    except json.JSONDecodeError as e:
        errors.append("%s: tools.json is not valid JSON (%s)" % (d.name, e))
        continue
    for s in servers:
        if s.get("name") not in registry:
            errors.append("%s: unknown MCP server '%s'" % (d.name, s.get("name")))

if errors:
    print("\n".join(errors))
    sys.exit(1)
print("skills ok")
