-- Migration to add user_id fields to tables and make couple_id nullable
-- This allows data to be saved per-user without requiring couple records

-- Add user_id to date_ideas table
ALTER TABLE date_ideas 
ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES users(id) ON DELETE CASCADE;

-- Add user_id to milestones table  
ALTER TABLE milestones
ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES users(id) ON DELETE CASCADE;

-- Make couple_id nullable on all tables (except couples table itself)
ALTER TABLE conflict_sessions ALTER COLUMN couple_id DROP NOT NULL;
ALTER TABLE growth_challenges ALTER COLUMN couple_id DROP NOT NULL;
ALTER TABLE appreciation_entries ALTER COLUMN couple_id DROP NOT NULL;
ALTER TABLE check_ins ALTER COLUMN couple_id DROP NOT NULL;
ALTER TABLE gratitude_entries ALTER COLUMN couple_id DROP NOT NULL;
ALTER TABLE milestones ALTER COLUMN couple_id DROP NOT NULL;
ALTER TABLE date_ideas ALTER COLUMN couple_id DROP NOT NULL;

-- Add indexes for the new user_id columns
CREATE INDEX IF NOT EXISTS idx_date_ideas_user ON date_ideas(user_id);
CREATE INDEX IF NOT EXISTS idx_milestones_user ON milestones(user_id);
CREATE INDEX IF NOT EXISTS idx_gratitude_entries_user ON gratitude_entries(user_id);
