-- Create daily_insights table
create table daily_insights (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null,
  message text not null,
  date date not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique (user_id, date) -- Ensure one insight per user per day
);

-- Enable Row Level Security
alter table daily_insights enable row level security;

-- Create policies
create policy "Users can view their own daily insights." on daily_insights
  for select using (auth.uid() = user_id);

create policy "Users can insert their own daily insights." on daily_insights
  for insert with check (auth.uid() = user_id);
