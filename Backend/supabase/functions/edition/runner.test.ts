import { assertEquals } from "jsr:@std/assert";
import { runEdition } from "./runner.ts";

Deno.test("an empty edition has no results yet", async () => {
  const edition = await runEdition({});
  assertEquals(edition.results.length, 0);
});
