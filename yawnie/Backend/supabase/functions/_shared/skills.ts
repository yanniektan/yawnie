// TODO(core): load skills/<name>/SKILL.md and tools.json for every enabled skill.
export type SkillDefinition = {
  name: string;
  prompt: string;
  servers: { name: string; tools: string[] }[];
};
