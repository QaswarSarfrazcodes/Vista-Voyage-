-- supabase_setup.sql
-- Run this in Supabase Dashboard → SQL Editor → New Query
-- This creates the tables needed for VistaVoyage

-- ── destinations table (public read) ────────────────────────────────────────
create table if not exists public.destinations (
  id          text primary key,
  name        text not null,
  country     text not null,
  "imageUrl"  text not null,
  "isAsset"   boolean default false,
  description text not null,
  rating      numeric(3,1) not null,
  tags        jsonb default '[]',
  highlights  jsonb default '[]',
  "bestTime"  text default '',
  "avgBudget" text default '',
  created_at  timestamptz default now()
);

-- ── favorites table (per user) ───────────────────────────────────────────────
create table if not exists public.favorites (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid references auth.users(id) on delete cascade not null,
  dest_id    text not null,
  dest_data  jsonb not null,
  created_at timestamptz default now(),
  unique(user_id, dest_id)
);

-- ── Row Level Security ───────────────────────────────────────────────────────

-- destinations: anyone logged in can read, nobody can write from client
alter table public.destinations enable row level security;

create policy "Anyone can read destinations"
  on public.destinations for select
  using (auth.role() = 'authenticated');

-- favorites: users can only see and edit their own favorites
alter table public.favorites enable row level security;

create policy "Users can read own favorites"
  on public.favorites for select
  using (auth.uid() = user_id);

create policy "Users can insert own favorites"
  on public.favorites for insert
  with check (auth.uid() = user_id);

create policy "Users can delete own favorites"
  on public.favorites for delete
  using (auth.uid() = user_id);

create policy "Users can update own favorites"
  on public.favorites for update
  using (auth.uid() = user_id);
