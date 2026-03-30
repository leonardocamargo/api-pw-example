-- ============================================
-- DONO - Supabase Database Schema
-- App de gerenciamento de pagamentos recorrentes
-- ============================================

-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- ============================================
-- PROFILES (extends Supabase auth.users)
-- ============================================
create table public.profiles (
    id uuid references auth.users on delete cascade primary key,
    name text,
    preferred_bank text,
    is_premium boolean default false,
    premium_until timestamptz,
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

-- RLS: users can only see/edit their own profile
alter table public.profiles enable row level security;

create policy "Users can view own profile"
    on public.profiles for select
    using (auth.uid() = id);

create policy "Users can update own profile"
    on public.profiles for update
    using (auth.uid() = id);

create policy "Users can insert own profile"
    on public.profiles for insert
    with check (auth.uid() = id);

-- Auto-create profile on signup
create or replace function public.handle_new_user()
returns trigger as $$
begin
    insert into public.profiles (id, name)
    values (new.id, new.raw_user_meta_data->>'full_name');
    return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
    after insert on auth.users
    for each row execute procedure public.handle_new_user();

-- ============================================
-- PROVIDERS (prestadores de serviço)
-- ============================================
create table public.providers (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references public.profiles(id) on delete cascade not null,
    name text not null,
    category text not null default 'outro',
    pix_key text not null,
    pix_key_type text not null default 'aleatoria',
    default_amount decimal(10,2) not null default 0,
    frequency text not null default 'mensal',
    due_day integer not null default 1 check (due_day >= 1 and due_day <= 31),
    notes text,
    is_active boolean default true,
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

-- Indexes
create index idx_providers_user_id on public.providers(user_id);
create index idx_providers_active on public.providers(user_id, is_active);

-- RLS
alter table public.providers enable row level security;

create policy "Users can view own providers"
    on public.providers for select
    using (auth.uid() = user_id);

create policy "Users can insert own providers"
    on public.providers for insert
    with check (auth.uid() = user_id);

create policy "Users can update own providers"
    on public.providers for update
    using (auth.uid() = user_id);

create policy "Users can delete own providers"
    on public.providers for delete
    using (auth.uid() = user_id);

-- ============================================
-- PAYMENTS (histórico de pagamentos)
-- ============================================
create table public.payments (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references public.profiles(id) on delete cascade not null,
    provider_id uuid references public.providers(id) on delete cascade not null,
    amount decimal(10,2) not null,
    due_date date not null,
    paid_at timestamptz,
    status text not null default 'pending'
        check (status in ('pending', 'paid', 'overdue', 'skipped')),
    notes text,
    receipt_url text,
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

-- Indexes
create index idx_payments_user_id on public.payments(user_id);
create index idx_payments_provider on public.payments(provider_id);
create index idx_payments_due_date on public.payments(user_id, due_date);
create index idx_payments_status on public.payments(user_id, status);
create index idx_payments_month on public.payments(user_id, due_date, status);

-- RLS
alter table public.payments enable row level security;

create policy "Users can view own payments"
    on public.payments for select
    using (auth.uid() = user_id);

create policy "Users can insert own payments"
    on public.payments for insert
    with check (auth.uid() = user_id);

create policy "Users can update own payments"
    on public.payments for update
    using (auth.uid() = user_id);

-- ============================================
-- FUNCTIONS
-- ============================================

-- Auto-update overdue payments
create or replace function public.update_overdue_payments()
returns void as $$
begin
    update public.payments
    set status = 'overdue', updated_at = now()
    where status = 'pending'
    and due_date < current_date;
end;
$$ language plpgsql security definer;

-- Generate monthly payments for all active providers
create or replace function public.generate_monthly_payments(target_month date)
returns void as $$
declare
    provider_record record;
    payment_date date;
    days_in_month integer;
begin
    days_in_month := extract(day from (date_trunc('month', target_month) + interval '1 month' - interval '1 day'));

    for provider_record in
        select p.*, pr.id as profile_id
        from public.providers p
        join public.profiles pr on pr.id = p.user_id
        where p.is_active = true
        and p.frequency = 'mensal'
    loop
        -- Calculate due date (cap at last day of month)
        payment_date := date_trunc('month', target_month)::date
            + (least(provider_record.due_day, days_in_month) - 1);

        -- Skip if payment already exists
        if not exists (
            select 1 from public.payments
            where provider_id = provider_record.id
            and due_date = payment_date
        ) then
            insert into public.payments (user_id, provider_id, amount, due_date, status)
            values (
                provider_record.user_id,
                provider_record.id,
                provider_record.default_amount,
                payment_date,
                'pending'
            );
        end if;
    end loop;
end;
$$ language plpgsql security definer;

-- Monthly summary view
create or replace view public.monthly_summary as
select
    user_id,
    date_trunc('month', due_date) as month,
    count(*) as total_payments,
    count(*) filter (where status = 'paid') as paid_count,
    count(*) filter (where status = 'pending') as pending_count,
    count(*) filter (where status = 'overdue') as overdue_count,
    coalesce(sum(amount) filter (where status = 'paid'), 0) as total_paid,
    coalesce(sum(amount) filter (where status = 'pending'), 0) as total_pending,
    coalesce(sum(amount) filter (where status = 'overdue'), 0) as total_overdue,
    coalesce(sum(amount), 0) as total_amount
from public.payments
group by user_id, date_trunc('month', due_date);

-- ============================================
-- CRON JOBS (via pg_cron or Supabase Edge Functions)
-- ============================================

-- Run daily at 6am BRT to update overdue status:
-- select cron.schedule('update-overdue', '0 9 * * *', 'select public.update_overdue_payments()');

-- Run on 1st of each month to generate payments:
-- select cron.schedule('generate-monthly', '0 6 1 * *', 'select public.generate_monthly_payments(current_date)');
