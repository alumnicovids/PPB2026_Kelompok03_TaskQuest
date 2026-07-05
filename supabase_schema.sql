-- SQL Schema for TaskQuest Supabase Database
-- You can copy-paste and execute this script in the Supabase SQL Editor.

-- Enable UUID generation extension if not enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Table: users
-- Note: If you use Supabase Auth, you can link this table's ID to auth.users.id.
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- 2. Table: characters
CREATE TABLE IF NOT EXISTS public.characters (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES public.users(id) ON DELETE CASCADE,
    class_type VARCHAR(50) NOT NULL, -- 'knight', 'mage', 'archer'
    level INTEGER NOT NULL DEFAULT 1,
    current_xp INTEGER NOT NULL DEFAULT 0,
    xp_to_next_level INTEGER NOT NULL, -- calculated: 100 * level^1.3
    appearance_stage INTEGER NOT NULL DEFAULT 1, -- visual stage (1-5), rises every 5 levels
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

ALTER TABLE public.characters ENABLE ROW LEVEL SECURITY;

-- 3. Table: tasks
CREATE TABLE IF NOT EXISTS public.tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(50) NOT NULL, -- 'kuliah', 'organisasi', 'pribadi'
    priority VARCHAR(50) NOT NULL, -- 'low', 'medium', 'high'
    deadline TIMESTAMP WITH TIME ZONE NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'pending', -- 'pending', 'in_progress', 'completed'
    xp_reward INTEGER NOT NULL,
    proof_photo_path TEXT,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;

-- 4. Table: xp_logs
CREATE TABLE IF NOT EXISTS public.xp_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    task_id UUID REFERENCES public.tasks(id) ON DELETE SET NULL,
    xp_amount INTEGER NOT NULL,
    reason VARCHAR(100) NOT NULL, -- 'task_completed', 'streak_bonus', etc.
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

ALTER TABLE public.xp_logs ENABLE ROW LEVEL SECURITY;

-- 5. Table: character_items
CREATE TABLE IF NOT EXISTS public.character_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    character_id UUID NOT NULL REFERENCES public.characters(id) ON DELETE CASCADE,
    item_name VARCHAR(100) NOT NULL, -- 'Pedang Perunggu', 'Badge Rajin', etc.
    item_type VARCHAR(50) NOT NULL, -- 'weapon', 'badge', 'outfit'
    unlock_condition VARCHAR(255) NOT NULL,
    unlocked_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

ALTER TABLE public.character_items ENABLE ROW LEVEL SECURITY;

-- Basic Row Level Security (RLS) Policies (Allow users to read/write their own data)

-- Users Policies
CREATE POLICY "Allow public read access to users" ON public.users FOR SELECT USING (true);
CREATE POLICY "Allow users to update own data" ON public.users FOR UPDATE USING (true);
CREATE POLICY "Allow insert to users" ON public.users FOR INSERT WITH CHECK (true);

-- Characters Policies
CREATE POLICY "Allow users to view all characters (for Leaderboard)" ON public.characters FOR SELECT USING (true);
CREATE POLICY "Allow users to manage own character" ON public.characters FOR ALL USING (true);

-- Tasks Policies
CREATE POLICY "Allow users to manage own tasks" ON public.tasks FOR ALL USING (true);

-- XP Logs Policies
CREATE POLICY "Allow users to view all XP logs" ON public.xp_logs FOR SELECT USING (true);
CREATE POLICY "Allow users to insert own XP logs" ON public.xp_logs FOR INSERT WITH CHECK (true);

-- Character Items Policies
CREATE POLICY "Allow users to view character items" ON public.character_items FOR SELECT USING (true);
CREATE POLICY "Allow users to manage character items" ON public.character_items FOR ALL USING (true);
