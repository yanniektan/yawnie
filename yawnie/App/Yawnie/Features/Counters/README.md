Owned by the counters agent.

`CountersView` is the strip of four counters for the top of the Daily. Give it a
`CountersViewModel` built with a `CountersService` (`SupabaseCountersService` in the app,
`InMemoryCountersService` in previews and tests). The tally rules mirror `skills/counters/tally.ts`
and are checked against the fixtures in `skills/counters/fixtures/`.
