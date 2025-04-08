begin;
-- Enable necessary extensions
create extension if not exists "uuid-ossp";

-- Create enum types
create type match_status as enum ('in_progress', 'completed', 'disputed');
create type challenge_status as enum ('pending', 'accepted', 'declined', 'expired');
create type transaction_type as enum ('initial_balance', 'match_wager', 'match_win', 'match_loss', 'dispute_resolution');

-- Create profiles table (extends Supabase auth.users)
create table profiles (
    id uuid references auth.users on delete cascade primary key,
    phone_number text unique not null,
    user_id text not null,  -- Unique, permanent identifier
    display_name text not null,  -- Non-unique, can hypothetically be changed
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create public profiles view (only exposes public data)
create view public_profiles as
select id, user_id, display_name
from profiles;

-- Create tournaments table
create table tournaments (
    id uuid default uuid_generate_v4() primary key,
    name text not null,
    created_by uuid references profiles(id) not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    updated_at timestamp with time zone default timezone('utc'::text, now()) not null,
    start_time timestamp with time zone,
    end_time timestamp with time zone,
    is_active boolean default false not null
);

-- Create tournament_users table (combined hosts and entrants)
create table tournament_users (
    tournament_id uuid references tournaments(id) on delete cascade,
    profile_id uuid references profiles(id) on delete cascade,
    is_host boolean default false not null,
    is_entrant boolean default false not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    primary key (tournament_id, profile_id),
    constraint at_least_one_role check (is_host or is_entrant)
);

-- Create credits table (tracks all credit balances)
create table credits (
    id uuid default uuid_generate_v4() primary key,
    tournament_id uuid references tournaments(id) on delete cascade not null,
    profile_id uuid references profiles(id) on delete cascade not null,
    amount integer not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    updated_at timestamp with time zone default timezone('utc'::text, now()) not null,
    constraint valid_amount check (amount >= 0),
    unique(tournament_id, profile_id)
);

-- Create matches table
create table matches (
    id uuid default uuid_generate_v4() primary key,
    tournament_id uuid references tournaments(id) not null,
    challenger_id uuid references profiles(id) not null,
    opponent_id uuid references profiles(id) not null,
    wager_amount integer not null,
    status match_status default 'in_progress' not null,
    winner_id uuid references profiles(id),
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    updated_at timestamp with time zone default timezone('utc'::text, now()) not null,
    completed_at timestamp with time zone,
    constraint valid_wager check (wager_amount > 0),
    constraint different_players check (challenger_id != opponent_id)
);

-- Create challenges table
create table challenges (
    id uuid default uuid_generate_v4() primary key,
    match_id uuid references matches(id) not null,
    status challenge_status default 'pending' not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    updated_at timestamp with time zone default timezone('utc'::text, now()) not null,
    expires_at timestamp with time zone not null
);

-- Create transactions table
create table transactions (
    id uuid default uuid_generate_v4() primary key,
    tournament_id uuid references tournaments(id) not null,
    profile_id uuid references profiles(id) not null,
    amount integer not null,
    type transaction_type not null,
    match_id uuid references matches(id),
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    constraint valid_amount check (amount != 0)
);

-- Create indexes for better query performance
create index idx_tournament_users_tournament_id on tournament_users(tournament_id);
create index idx_tournament_users_profile_id on tournament_users(profile_id);
create index idx_tournament_users_is_host on tournament_users(is_host);
create index idx_credits_tournament_id on credits(tournament_id);
create index idx_credits_profile_id on credits(profile_id);
create index idx_matches_tournament_id on matches(tournament_id);
create index idx_matches_challenger_id on matches(challenger_id);
create index idx_matches_opponent_id on matches(opponent_id);
create index idx_matches_status on matches(status);
create index idx_challenges_match_id on challenges(match_id);
create index idx_transactions_tournament_id on transactions(tournament_id);
create index idx_transactions_profile_id on transactions(profile_id);

-- Set up Row Level Security (RLS)
alter table profiles enable row level security;
alter table tournaments enable row level security;
alter table tournament_users enable row level security;
alter table credits enable row level security;
alter table matches enable row level security;
alter table challenges enable row level security;
alter table transactions enable row level security;

-- Basic RLS policies
create policy "No direct profile access"
    on profiles for select
    using (false);

create policy "Users can view profiles in their tournaments"
    on public_profiles for select
    using (true);

create policy "Users can view tournaments they're participating in"
    on tournaments for select
    using (
        auth.uid() in (
            select profile_id 
            from tournament_users 
            where tournament_id = tournaments.id
        )
    );

create policy "Users can view credits in their tournaments"
    on credits for select
    using (
        auth.uid() in (
            select profile_id 
            from tournament_users 
            where tournament_id = credits.tournament_id
        )
    );

-- Add updated_at trigger function
create or replace function update_updated_at_column()
returns trigger as $$
begin
    new.updated_at = timezone('utc'::text, now());
    return new;
end;
$$ language plpgsql;

-- Create triggers for updated_at
create trigger update_profiles_updated_at
    before update on profiles
    for each row
    execute function update_updated_at_column();

create trigger update_tournaments_updated_at
    before update on tournaments
    for each row
    execute function update_updated_at_column();

create trigger update_credits_updated_at
    before update on credits
    for each row
    execute function update_updated_at_column();

create trigger update_matches_updated_at
    before update on matches
    for each row
    execute function update_updated_at_column();

create trigger update_challenges_updated_at
    before update on challenges
    for each row
    execute function update_updated_at_column();

commit;
