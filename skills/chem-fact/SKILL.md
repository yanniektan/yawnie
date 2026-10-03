---
name: chem-fact
description: Writes the Chemistry section: an original IB HL-style question, its answer, and a real-world use. Use when the edition builder asks for the chemistry block.
---

# Chem fact

## Steps

1. Use nimble_search to find one recent real-world item, such as a materials-science paper or an engineering use at Boeing.
2. Write one original IB HL-style question on the chemistry behind it.
3. Write the answer.
4. Write one or two sentences on the real-world use, with the source link.

## Returns

a qa block.

## Guardrails

- Never copy text from IB past papers. Write the question fresh.
- The real-world line may use only a page you actually retrieved.

Call only the tools listed in tools.json.
