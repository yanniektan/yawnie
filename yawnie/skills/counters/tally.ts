// Reference implementation of the counters skill. It makes no tool calls, so the
// runner can call tallyCounters() directly instead of asking a model.
import type { Block } from "../../Backend/supabase/functions/_shared/blocks.ts";

export const KINDS = ["ate_out", "buckled", "piano", "stretched"] as const;
export type Kind = (typeof KINDS)[number];

/** Tap counters sum their rows. The other kinds are yes or no for the day. */
export const TAP_KINDS: readonly Kind[] = ["ate_out", "buckled"];

/** A tap before this local hour counts for the previous day. */
export const CUTOFF_HOUR = 12;

export type CounterRow = { day: string; kind: string; value: number };

const DAY = /^\d{4}-\d{2}-\d{2}$/;

/** The counter day `now` belongs to in `timeZone`, as YYYY-MM-DD. */
export function counterDay(now: Date, timeZone: string): string {
  const parts = new Intl.DateTimeFormat("en-CA", {
    timeZone,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    hourCycle: "h23",
  }).formatToParts(now);
  const part = (type: string) => parts.find((p) => p.type === type)?.value ?? "";
  const date = `${part("year")}-${part("month")}-${part("day")}`;
  return Number(part("hour")) < CUTOFF_HOUR ? addDays(date, -1) : date;
}

export function addDays(day: string, n: number): string {
  const d = new Date(`${day}T00:00:00Z`);
  d.setUTCDate(d.getUTCDate() + n);
  return d.toISOString().slice(0, 10);
}

/**
 * Builds the counters block for `today` from the counters rows.
 * `day` on each row already has the noon rule applied by the app, so it is used as is.
 * Rows are only read, never changed.
 */
export function tallyCounters(rows: readonly CounterRow[] | null | undefined, today: string): Block {
  if (!Array.isArray(rows) || !DAY.test(today)) {
    return { type: "unavailable", skill: "counters", reason: "Not available this morning" };
  }

  const days = Array.from({ length: 7 }, (_, i) => addDays(today, i - 6));
  const sums = new Map<Kind, number[]>(KINDS.map((k) => [k, days.map(() => 0)]));
  for (const row of rows) {
    const series = sums.get(row?.kind as Kind);
    const i = days.indexOf(row?.day);
    if (!series || i < 0 || !Number.isInteger(row.value)) continue;
    series[i] += row.value;
  }

  const week: Record<string, number[]> = {};
  const todayValues: Record<string, number | boolean> = {};
  for (const kind of KINDS) {
    const tap = TAP_KINDS.includes(kind);
    week[kind] = sums.get(kind)!.map((s) => (tap ? Math.max(0, s) : s > 0 ? 1 : 0));
    todayValues[kind] = tap ? week[kind][6] : week[kind][6] === 1;
  }
  return { type: "counters", today: todayValues, week };
}
