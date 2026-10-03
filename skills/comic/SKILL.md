---
name: comic
description: Turns the user's typed note into a four-panel black-and-white comic with a life lesson. Use when the edition builder asks for the comic block.
---

# Comic

## Steps

1. Read the note from the device context.
2. Step one: write the lesson and a four-panel script with all names removed.
3. Step two: call draw_panel once per panel, passing the script line only.
4. Write a short typed caption for each panel.

## Returns

a comic block: the lesson, and four panels each with an imageUrl and a caption.

## Guardrails

- The image model never sees the note, only the script.
- Art has no lettering. Captions are typed by the template.
- Black-and-white line art only, so it prints cleanly.

Call only the tools listed in tools.json.
