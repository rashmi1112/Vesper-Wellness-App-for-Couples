-- Togetherly Database Schema
-- Supabase PostgreSQL schema for couple wellness tracking app

-- Users table (extends Supabase auth.users)
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone_number TEXT,
  date_of_birth TIMESTAMPTZ,
  gender_orientation TEXT,
  profile_photo_base64 TEXT,
  relationship_length TEXT,
  relationship_feeling TEXT,
  togetherly_goals TEXT[] DEFAULT '{}',
  partner_ids TEXT[] DEFAULT '{}',
  outgoing_link_requests TEXT[] DEFAULT '{}',
  incoming_link_requests TEXT[] DEFAULT '{}',
  partner_name TEXT DEFAULT '',
  anniversary_date TIMESTAMPTZ,
  growth_date_reminders_enabled BOOLEAN DEFAULT true,
  appreciation_prompts_enabled BOOLEAN DEFAULT true,
  appreciation_prompt_day TEXT DEFAULT 'Sunday',
  appreciation_prompt_time TEXT DEFAULT '18:00',
  peace_lily_notifications_enabled BOOLEAN DEFAULT true,
  pairing_notifications_enabled BOOLEAN DEFAULT true,
  weekly_digest_enabled BOOLEAN DEFAULT false,
  streak_celebration_enabled BOOLEAN DEFAULT true,
  growth_date_day_of_month INTEGER DEFAULT 1,
  appreciation_frequency TEXT DEFAULT 'Weekly',
  fight_better_enabled BOOLEAN DEFAULT true,
  grow_together_enabled BOOLEAN DEFAULT true,
  love_out_loud_enabled BOOLEAN DEFAULT true,
  password_salt TEXT,
  password_hash TEXT,
  biometric_enabled BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Couples table (supports polyamory - multiple partners)
CREATE TABLE IF NOT EXISTS couples (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  partner_ids TEXT[] NOT NULL,
  anniversary_date TIMESTAMPTZ,
  growth_date_day INTEGER DEFAULT 1,
  appreciation_frequency TEXT DEFAULT 'Weekly',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Conflict Sessions (Fight Better feature)
CREATE TABLE IF NOT EXISTS conflict_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  couple_id UUID REFERENCES couples(id) ON DELETE CASCADE,
  initiator_id UUID REFERENCES users(id) ON DELETE CASCADE,
  started_at TIMESTAMPTZ DEFAULT NOW(),
  ended_at TIMESTAMPTZ,
  breathing_skipped BOOLEAN DEFAULT false,
  emotions TEXT[] DEFAULT '{}',
  emotion_free_text TEXT DEFAULT '',
  trigger_text TEXT DEFAULT '',
  connected_to_past_pattern BOOLEAN DEFAULT false,
  past_pattern_text TEXT DEFAULT '',
  needs TEXT[] DEFAULT '{}',
  readiness TEXT DEFAULT 'notYet',
  partner_response TEXT DEFAULT 'none',
  conversation_notes TEXT DEFAULT '',
  resolution_rating INTEGER CHECK (resolution_rating >= 1 AND resolution_rating <= 5),
  resolution_notes TEXT DEFAULT '',
  ai_summary_enabled BOOLEAN DEFAULT false,
  ai_summary_text TEXT DEFAULT '',
  follow_up_in_days INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Growth Challenges (Grow Together feature)
CREATE TABLE IF NOT EXISTS growth_challenges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  couple_id UUID REFERENCES couples(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  why TEXT NOT NULL,
  how_to_help TEXT NOT NULL,
  complexity TEXT DEFAULT 'medium',
  set_by_user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  set_by_user_name TEXT NOT NULL,
  assigned_to_user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  assigned_to_user_name TEXT NOT NULL,
  start_date TIMESTAMPTZ DEFAULT NOW(),
  target_date TIMESTAMPTZ DEFAULT NOW() + INTERVAL '30 days',
  status TEXT DEFAULT 'notStarted',
  check_in_notes TEXT[] DEFAULT '{}',
  photo_urls TEXT[] DEFAULT '{}',
  progress_percent INTEGER DEFAULT 0 CHECK (progress_percent >= 0 AND progress_percent <= 100),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Challenge Check-ins (subcollection of growth_challenges)
CREATE TABLE IF NOT EXISTS challenge_check_ins (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  challenge_id UUID REFERENCES growth_challenges(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  note TEXT NOT NULL,
  progress_percent INTEGER DEFAULT 0 CHECK (progress_percent >= 0 AND progress_percent <= 100),
  photo_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Appreciation Entries (Love Out Loud feature)
CREATE TABLE IF NOT EXISTS appreciation_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  couple_id UUID REFERENCES couples(id) ON DELETE CASCADE,
  from_user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  from_user_name TEXT NOT NULL,
  to_user_id UUID REFERENCES users(id),
  to_user_name TEXT,
  appreciation_text TEXT NOT NULL,
  win_text TEXT NOT NULL,
  gratitudes TEXT[] DEFAULT '{}',
  selected_badge TEXT DEFAULT 'star',
  week_of TIMESTAMPTZ NOT NULL,
  sent_at TIMESTAMPTZ DEFAULT NOW(),
  viewed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Check-ins (Daily wellness tracking)
CREATE TABLE IF NOT EXISTS check_ins (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  couple_id UUID REFERENCES couples(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  date TIMESTAMPTZ NOT NULL,
  mood TEXT NOT NULL,
  connection_score INTEGER NOT NULL CHECK (connection_score >= 1 AND connection_score <= 10),
  note TEXT,
  is_partner BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Gratitude Entries
CREATE TABLE IF NOT EXISTS gratitude_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  couple_id UUID REFERENCES couples(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  category TEXT NOT NULL,
  date TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Milestones
CREATE TABLE IF NOT EXISTS milestones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  couple_id UUID REFERENCES couples(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  date TIMESTAMPTZ NOT NULL,
  type TEXT NOT NULL,
  image_asset TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Date Ideas
CREATE TABLE IF NOT EXISTS date_ideas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  couple_id UUID REFERENCES couples(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  category TEXT NOT NULL,
  image_asset TEXT,
  estimated_cost INTEGER DEFAULT 2 CHECK (estimated_cost >= 1 AND estimated_cost <= 4),
  estimated_time INTEGER DEFAULT 120,
  is_completed BOOLEAN DEFAULT false,
  completed_date TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- In-App Notifications
CREATE TABLE IF NOT EXISTS in_app_notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  type TEXT NOT NULL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  payload JSONB DEFAULT '{}',
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for common queries
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_conflict_sessions_couple ON conflict_sessions(couple_id);
CREATE INDEX IF NOT EXISTS idx_conflict_sessions_initiator ON conflict_sessions(initiator_id);
CREATE INDEX IF NOT EXISTS idx_growth_challenges_couple ON growth_challenges(couple_id);
CREATE INDEX IF NOT EXISTS idx_growth_challenges_assigned ON growth_challenges(assigned_to_user_id);
CREATE INDEX IF NOT EXISTS idx_challenge_check_ins_challenge ON challenge_check_ins(challenge_id);
CREATE INDEX IF NOT EXISTS idx_appreciation_entries_couple ON appreciation_entries(couple_id);
CREATE INDEX IF NOT EXISTS idx_appreciation_entries_from ON appreciation_entries(from_user_id);
CREATE INDEX IF NOT EXISTS idx_appreciation_entries_to ON appreciation_entries(to_user_id);
CREATE INDEX IF NOT EXISTS idx_check_ins_couple ON check_ins(couple_id);
CREATE INDEX IF NOT EXISTS idx_check_ins_user ON check_ins(user_id);
CREATE INDEX IF NOT EXISTS idx_check_ins_date ON check_ins(date);
CREATE INDEX IF NOT EXISTS idx_gratitude_entries_couple ON gratitude_entries(couple_id);
CREATE INDEX IF NOT EXISTS idx_milestones_couple ON milestones(couple_id);
CREATE INDEX IF NOT EXISTS idx_date_ideas_couple ON date_ideas(couple_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user ON in_app_notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON in_app_notifications(user_id, is_read);
