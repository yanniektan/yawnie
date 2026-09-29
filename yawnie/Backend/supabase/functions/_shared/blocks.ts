// The block every skill returns. Keep this file the single source of truth.
export type Block =
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

export type SkillResult = { skill: string; generatedAt: string; block: Block };
