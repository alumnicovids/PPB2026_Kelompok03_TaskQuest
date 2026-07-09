-- Migration: Add assignments JSONB column to tasks table and update RLS policies
ALTER TABLE public.tasks ADD COLUMN IF NOT EXISTS assignments JSONB DEFAULT NULL;

DROP POLICY IF EXISTS "Allow users to manage own tasks" ON public.tasks;
CREATE POLICY "Allow users to manage own tasks" ON public.tasks FOR ALL USING (
    auth.uid() = user_id 
    OR (assignments IS NOT NULL AND assignments @> jsonb_build_array(jsonb_build_object('student_id', auth.uid()::text)))
    OR EXISTS (
        SELECT 1 FROM public.users 
        WHERE users.id = auth.uid() AND users.role IN ('dosen', 'superadmin')
    )
);
