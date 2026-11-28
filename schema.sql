create table if not exists public.lessons (
    id uuid primary key default gen_random_uuid(),
    teacher_id uuid not null references auth.users(id) on delete cascade,
    title text not null,
    subject text not null,
    level text not null,
    grade text not null,
    content text not null,
    audio_url text,
    created_at timestamptz default now()
);

create index if not exists lessons_teacher_created_idx
    on public.lessons (teacher_id, created_at desc);

alter table public.lessons enable row level security;

create policy "Teachers can read their lessons"
on public.lessons for select to authenticated
using (auth.uid() = teacher_id);

create policy "Teachers can insert their lessons"
on public.lessons for insert to authenticated
with check (auth.uid() = teacher_id);

create policy "Teachers can delete their lessons"
on public.lessons for delete to authenticated
using (auth.uid() = teacher_id);

create policy "Teachers can update their lessons"
on public.lessons for update to authenticated
using (auth.uid() = teacher_id)
with check (auth.uid() = teacher_id);
