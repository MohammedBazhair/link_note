-- Image Memories: Database + RLS (Supabase)
-- Run this in Supabase SQL editor (or add to migrations if you use them).

create table if not exists public.image_memories (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  image_url text not null,
  title text null,
  description text null,
  tags text[] not null default '{}',
  memory_date date not null default current_date,
  created_at timestamp with time zone not null default now()
);

alter table public.image_memories enable row level security;

-- User isolation
drop policy if exists "image_memories_select_own" on public.image_memories;
create policy "image_memories_select_own"
on public.image_memories
for select
using (auth.uid() = user_id);

drop policy if exists "image_memories_insert_own" on public.image_memories;
create policy "image_memories_insert_own"
on public.image_memories
for insert
with check (auth.uid() = user_id);

drop policy if exists "image_memories_update_own" on public.image_memories;
create policy "image_memories_update_own"
on public.image_memories
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "image_memories_delete_own" on public.image_memories;
create policy "image_memories_delete_own"
on public.image_memories
for delete
using (auth.uid() = user_id);

-- Storage bucket: memories_images (PRIVATE)
-- Create bucket in dashboard:
--   name: memories_images
--   public: false
--
-- Store files as:
--   memories_images/{user_id}/{image_id}.jpg
--
-- Storage RLS (Policies) idea:
-- Allow users to read/write only their folder (path begins with `${auth.uid()}/`).
--
-- Example policies (adjust for your project):
-- Note: storage.objects is a system table. These policies are standard for private buckets.
--
-- Read own objects:
-- create policy "memories_images_read_own"
-- on storage.objects for select
-- using (
--   bucket_id = 'memories_images'
--   and (storage.foldername(name))[1] = auth.uid()::text
-- );
--
-- Insert own objects:
-- create policy "memories_images_insert_own"
-- on storage.objects for insert
-- with check (
--   bucket_id = 'memories_images'
--   and (storage.foldername(name))[1] = auth.uid()::text
-- );
--
-- Delete own objects:
-- create policy "memories_images_delete_own"
-- on storage.objects for delete
-- using (
--   bucket_id = 'memories_images'
--   and (storage.foldername(name))[1] = auth.uid()::text
-- );


