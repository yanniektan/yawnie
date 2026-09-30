create table public.counters (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id),
  day date not null,
  kind text not null check (kind in ('ate_out', 'buckled', 'piano', 'stretched')),
  value integer not null default 1,
  created_at timestamptz not null default now()
);

alter table public.counters enable row level security;

create policy "own counters" on public.counters
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());
