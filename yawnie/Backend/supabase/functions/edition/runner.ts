import type { SkillResult } from "../_shared/blocks.ts";

// TODO(core): run every enabled skill in parallel. For each one, call Claude with its
// SKILL.md as instructions and its tools.json allowlist through the MCP connector.
// Give each skill 45 seconds. Replace any failure with an "unavailable" block.
export async function runEdition(
  _deviceContext: unknown,
): Promise<{ day: string; results: SkillResult[] }> {
  return { day: new Date().toISOString().slice(0, 10), results: [] };
}
