// Runs with `deno test skills/counters` or `npx tsx --test skills/counters/tests/*.test.ts`.
import { test } from "node:test";
import assert from "node:assert/strict";
import { readdirSync, readFileSync } from "node:fs";
import { counterDay, KINDS, tallyCounters } from "../tally.ts";

const FIXTURES = new URL("../fixtures/", import.meta.url);
const load = (name: string) => JSON.parse(readFileSync(new URL(name, FIXTURES), "utf8"));
const blockFixtures = readdirSync(FIXTURES).filter((f) => f.endsWith(".json") && f !== "counter-days.json");

for (const file of blockFixtures) {
  test(`fixture ${file}`, () => {
    const { rows, today, expected } = load(file);
    assert.deepEqual(tallyCounters(rows, today), expected);
  });
}

for (const { now, timeZone, day } of load("counter-days.json").cases) {
  test(`counter day for ${now} in ${timeZone} is ${day}`, () => {
    assert.equal(counterDay(new Date(now), timeZone), day);
  });
}

test("every kind has today's value and a seven-day series ending today", () => {
  const { rows, today } = load("typical-week.json");
  const block = tallyCounters(rows, today);
  assert.equal(block.type, "counters");
  if (block.type !== "counters") return;
  for (const kind of KINDS) {
    assert.equal(block.week[kind].length, 7);
    assert.equal(Number(block.today[kind]), block.week[kind][6]);
  }
});

test("never changes the rows it reads", () => {
  const { rows, today } = load("edge-rows.json");
  const before = structuredClone(rows);
  tallyCounters(Object.freeze(rows), today);
  assert.deepEqual(rows, before);
});

test("a malformed today is unavailable, not a crash", () => {
  assert.deepEqual(tallyCounters([], "yesterday"), {
    type: "unavailable",
    skill: "counters",
    reason: "Not available this morning",
  });
});
