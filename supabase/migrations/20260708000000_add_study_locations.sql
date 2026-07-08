-- Migration: 20260708000000_add_study_locations.sql
-- Add study_locations table to Supabase schema

CREATE TABLE IF NOT EXISTS public.study_locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    latitude REAL NOT NULL,
    longitude REAL NOT NULL,
    is_favorite BOOLEAN NOT NULL DEFAULT false
);

ALTER TABLE public.study_locations ENABLE ROW LEVEL SECURITY;

-- Study Locations Policies
CREATE POLICY "Allow users to manage own study locations" ON public.study_locations FOR ALL USING (true);
