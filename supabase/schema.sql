-- ============================================================
-- Location-APP — Ubatuba — Supabase Schema
-- Run this in Supabase SQL Editor (Dashboard > SQL Editor)
-- ============================================================

-- PROFILES (extends auth.users)
create table public.profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  full_name   text,
  avatar_url  text,
  phone       text,
  is_host     boolean default false,
  created_at  timestamptz default now()
);

-- Auto-create profile on sign up
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name, avatar_url)
  values (
    new.id,
    new.raw_user_meta_data->>'full_name',
    new.raw_user_meta_data->>'avatar_url'
  );
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- LISTINGS
create table public.listings (
  id              uuid primary key default gen_random_uuid(),
  host_id         uuid references public.profiles(id) on delete cascade,
  title           text not null,
  description     text,
  type            text check (type in ('pousada','casa','chale')) not null,
  region          text check (region in ('praia','centro','montanha')) not null,
  address         text,
  lat             double precision,
  lng             double precision,
  price_per_night numeric(10,2) not null,
  max_guests      int default 2,
  bedrooms        int default 1,
  bathrooms       int default 1,
  amenities       text[] default '{}',
  is_active       boolean default true,
  created_at      timestamptz default now()
);

-- LISTING_PHOTOS
create table public.listing_photos (
  id          uuid primary key default gen_random_uuid(),
  listing_id  uuid references public.listings(id) on delete cascade,
  url         text not null,
  position    int default 0
);

-- REVIEWS
create table public.reviews (
  id          uuid primary key default gen_random_uuid(),
  listing_id  uuid references public.listings(id) on delete cascade,
  reviewer_id uuid references public.profiles(id),
  rating      int check (rating between 1 and 5),
  comment     text,
  created_at  timestamptz default now()
);

-- LISTING RATINGS VIEW
create view public.listing_ratings as
  select
    listing_id,
    round(avg(rating)::numeric, 1) as avg_rating,
    count(*) as review_count
  from public.reviews
  group by listing_id;

-- BOOKINGS
create table public.bookings (
  id              uuid primary key default gen_random_uuid(),
  listing_id      uuid references public.listings(id),
  guest_id        uuid references public.profiles(id),
  check_in        date not null,
  check_out       date not null,
  guests_count    int default 1,
  total_price     numeric(10,2),
  status          text check (status in ('pending','confirmed','cancelled')) default 'pending',
  payment_id      text,
  created_at      timestamptz default now()
);

-- USER_FAVORITES
create table public.user_favorites (
  user_id     uuid references public.profiles(id) on delete cascade,
  listing_id  uuid references public.listings(id) on delete cascade,
  created_at  timestamptz default now(),
  primary key (user_id, listing_id)
);

-- CONVERSATIONS
create table public.conversations (
  id          uuid primary key default gen_random_uuid(),
  listing_id  uuid references public.listings(id),
  guest_id    uuid references public.profiles(id),
  host_id     uuid references public.profiles(id),
  created_at  timestamptz default now(),
  unique (listing_id, guest_id, host_id)
);

-- MESSAGES
create table public.messages (
  id              uuid primary key default gen_random_uuid(),
  conversation_id uuid references public.conversations(id) on delete cascade,
  sender_id       uuid references public.profiles(id),
  content         text not null,
  created_at      timestamptz default now()
);

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

alter table public.profiles enable row level security;
alter table public.listings enable row level security;
alter table public.listing_photos enable row level security;
alter table public.reviews enable row level security;
alter table public.bookings enable row level security;
alter table public.user_favorites enable row level security;
alter table public.conversations enable row level security;
alter table public.messages enable row level security;

-- PROFILES
create policy "Public profiles are readable by everyone"
  on public.profiles for select using (true);
create policy "Users can update own profile"
  on public.profiles for update using (auth.uid() = id);

-- LISTINGS
create policy "Active listings readable by everyone"
  on public.listings for select using (is_active = true);
create policy "Host can manage own listings"
  on public.listings for all using (auth.uid() = host_id);

-- LISTING_PHOTOS
create policy "Photos are readable by everyone"
  on public.listing_photos for select using (true);
create policy "Host can manage own listing photos"
  on public.listing_photos for all using (
    auth.uid() = (select host_id from public.listings where id = listing_id)
  );

-- REVIEWS
create policy "Reviews are readable by everyone"
  on public.reviews for select using (true);
create policy "Authenticated users can write reviews"
  on public.reviews for insert with check (auth.uid() = reviewer_id);

-- BOOKINGS
create policy "Guest can see own bookings"
  on public.bookings for select using (auth.uid() = guest_id);
create policy "Host can see bookings on their listings"
  on public.bookings for select using (
    auth.uid() = (select host_id from public.listings where id = listing_id)
  );
create policy "Authenticated users can create bookings"
  on public.bookings for insert with check (auth.uid() = guest_id);
create policy "Guest can cancel own bookings"
  on public.bookings for update using (auth.uid() = guest_id);

-- USER_FAVORITES
create policy "Users manage own favorites"
  on public.user_favorites for all using (auth.uid() = user_id);

-- CONVERSATIONS
create policy "Participants can see their conversations"
  on public.conversations for select using (
    auth.uid() = guest_id or auth.uid() = host_id
  );
create policy "Authenticated users can create conversations"
  on public.conversations for insert with check (auth.uid() = guest_id);

-- MESSAGES
create policy "Participants can see messages"
  on public.messages for select using (
    auth.uid() in (
      select guest_id from public.conversations where id = conversation_id
      union
      select host_id from public.conversations where id = conversation_id
    )
  );
create policy "Participants can send messages"
  on public.messages for insert with check (auth.uid() = sender_id);

-- ============================================================
-- STORAGE BUCKETS (run in Supabase Storage dashboard or via SQL)
-- ============================================================
-- insert into storage.buckets (id, name, public) values ('listing-photos', 'listing-photos', true);
-- insert into storage.buckets (id, name, public) values ('avatars', 'avatars', false);

-- ============================================================
-- REALTIME (enable in Supabase Dashboard > Database > Replication)
-- Enable realtime for: messages, conversations
-- ============================================================

-- ============================================================
-- SAMPLE DATA — Ubatuba listings
-- ============================================================
-- Replace 'your-host-uuid' with a real user id after creating an account

-- insert into public.listings (host_id, title, description, type, region, address, lat, lng, price_per_night, max_guests, bedrooms, bathrooms, amenities)
-- values
-- ('your-host-uuid', 'Pousada Recanto das Ondas', 'Charmosa pousada a 50m da Praia Grande com café da manhã incluso.', 'pousada', 'praia', 'R. das Ondas, 123 - Praia Grande, Ubatuba', -23.499, -45.101, 280, 4, 2, 2, ARRAY['wifi','cafe_da_manha','estacionamento','piscina']),
-- ('your-host-uuid', 'Casa Azul da Serra', 'Casa aconchegante na serra com trilhas e cachoeiras.', 'casa', 'montanha', 'Estr. da Serra, 456 - Ubatuba', -23.452, -45.082, 350, 6, 3, 2, ARRAY['wifi','churrasqueira','piscina','pet_friendly']),
-- ('your-host-uuid', 'Chalé Vista Mar', 'Chalé romântico com vista panorâmica para o mar.', 'chale', 'praia', 'Alto do Morro, 789 - Ubatuba', -23.432, -45.063, 420, 2, 1, 1, ARRAY['wifi','ar_condicionado','vista_mar']);
