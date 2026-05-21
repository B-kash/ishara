-- Ishara dictionary schema (PostgreSQL)

create table categories (
  id text primary key,
  name text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table concepts (
  id text primary key,
  category_id text not null references categories (id) on delete restrict,
  meaning_english text not null,
  meaning_nepali text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index concepts_category_id_idx on concepts (category_id);

create table words (
  id uuid primary key default gen_random_uuid(),
  concept_id text not null references concepts (id) on delete cascade,
  language text not null check (language in ('en', 'ne')),
  word text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (concept_id, language)
);

create index words_language_word_idx on words (language, word);
create index words_word_lower_idx on words (lower(word));
create index words_concept_id_idx on words (concept_id);

create table signs (
  id text primary key,
  concept_id text not null unique references concepts (id) on delete cascade,
  video_url text,
  thumbnail_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index signs_concept_id_idx on signs (concept_id);
