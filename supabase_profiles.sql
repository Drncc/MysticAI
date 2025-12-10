-- PROFILES TABLE (KOD İLE UYUMLU VERSİYON)
-- Not: Kodunuz verileri 'bio_metrics' adlı bir JSON kutusu içinde gönderdiği için
-- yaş/boy/kilo sütunları yerine 'bio_metrics' (jsonb) sütunu kullanıyoruz.
-- Bu yapı kodu BOZMADAN çalışmasını sağlar.

-- 1. Tabloyu oluştur
create table public.profiles (
  id uuid references auth.users not null primary key,
  username text,
  digital_consent boolean default false,
  bio_metrics jsonb, -- { "age": 25, "height": 180, "weight": 70 } formatında tutulur
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 2. Güvenliği (RLS) Aç
alter table public.profiles enable row level security;

-- 3. Politikaları Tanımla (Kullanıcılar sadece kendi verisini yönetebilir)
create policy "Users can view own profile" on profiles for select using (auth.uid() = id);
create policy "Users can insert own profile" on profiles for insert with check (auth.uid() = id);
create policy "Users can update own profile" on profiles for update using (auth.uid() = id);
