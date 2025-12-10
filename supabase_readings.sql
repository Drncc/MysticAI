-- Create readings table
create table readings (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null,
  prompt text not null,
  response text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable Row Level Security
alter table readings enable row level security;

-- Create policies
create policy "Users can view their own readings." on readings
  for select using (auth.uid() = user_id);

create policy "Users can insert their own readings." on readings
  for insert with check (auth.uid() = user_id);
