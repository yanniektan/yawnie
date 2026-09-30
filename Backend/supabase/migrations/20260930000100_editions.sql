create table public.editions (
  user_id uuid not null default auth.uid() references auth.users (id),
  day date not null,
  html text not null,
  blocks jsonb not null,
  created_at timestamptz not null default now(),
  primary key (user_id, day)
);

alter table public.editions enable row level security;

create policy "own editions" on public.editions
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());
