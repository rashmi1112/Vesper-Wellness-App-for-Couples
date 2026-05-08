-- Row Level Security Policies for Togetherly

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE couples ENABLE ROW LEVEL SECURITY;
ALTER TABLE conflict_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE growth_challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE challenge_check_ins ENABLE ROW LEVEL SECURITY;
ALTER TABLE appreciation_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE check_ins ENABLE ROW LEVEL SECURITY;
ALTER TABLE gratitude_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE milestones ENABLE ROW LEVEL SECURITY;
ALTER TABLE date_ideas ENABLE ROW LEVEL SECURITY;
ALTER TABLE in_app_notifications ENABLE ROW LEVEL SECURITY;

-- Users table policies
DROP POLICY IF EXISTS "Users can view their own profile" ON users;
CREATE POLICY "Users can view their own profile" ON users
  FOR SELECT USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can insert their own profile" ON users;
CREATE POLICY "Users can insert their own profile" ON users
  FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Users can update their own profile" ON users;
CREATE POLICY "Users can update their own profile" ON users
  FOR UPDATE USING (auth.uid() = id) WITH CHECK (true);

DROP POLICY IF EXISTS "Users can view their partners' profiles" ON users;
CREATE POLICY "Users can view their partners' profiles" ON users
  FOR SELECT USING (
    id::TEXT = ANY(
      SELECT unnest(partner_ids) FROM couples WHERE auth.uid()::TEXT = ANY(partner_ids)
    )
  );

-- Couples table policies
DROP POLICY IF EXISTS "Users can view their couples" ON couples;
CREATE POLICY "Users can view their couples" ON couples
  FOR SELECT USING (
    auth.uid()::TEXT = ANY(partner_ids)
  );

DROP POLICY IF EXISTS "Authenticated users can create couples" ON couples;
CREATE POLICY "Authenticated users can create couples" ON couples
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS "Users can update their couples" ON couples;
CREATE POLICY "Users can update their couples" ON couples
  FOR UPDATE USING (
    auth.uid()::TEXT = ANY(partner_ids)
  );

DROP POLICY IF EXISTS "Users can delete their couples" ON couples;
CREATE POLICY "Users can delete their couples" ON couples
  FOR DELETE USING (
    auth.uid()::TEXT = ANY(partner_ids)
  );

-- Conflict Sessions policies
DROP POLICY IF EXISTS "Users can view conflict sessions in their couples" ON conflict_sessions;
CREATE POLICY "Users can view conflict sessions in their couples" ON conflict_sessions
  FOR SELECT USING (
    couple_id IN (
      SELECT id FROM couples WHERE auth.uid()::TEXT = ANY(partner_ids)
    )
  );

DROP POLICY IF EXISTS "Authenticated users can create conflict sessions" ON conflict_sessions;
CREATE POLICY "Authenticated users can create conflict sessions" ON conflict_sessions
  FOR INSERT WITH CHECK (
    auth.uid() = initiator_id
  );

DROP POLICY IF EXISTS "Users can update conflict sessions in their couples" ON conflict_sessions;
CREATE POLICY "Users can update conflict sessions in their couples" ON conflict_sessions
  FOR UPDATE USING (
    couple_id IN (
      SELECT id FROM couples WHERE auth.uid()::TEXT = ANY(partner_ids)
    )
  );

DROP POLICY IF EXISTS "Users can delete conflict sessions in their couples" ON conflict_sessions;
CREATE POLICY "Users can delete conflict sessions in their couples" ON conflict_sessions
  FOR DELETE USING (
    couple_id IN (
      SELECT id FROM couples WHERE auth.uid()::TEXT = ANY(partner_ids)
    )
  );

-- Growth Challenges policies
DROP POLICY IF EXISTS "Users can view growth challenges in their couples" ON growth_challenges;
CREATE POLICY "Users can view growth challenges in their couples" ON growth_challenges
  FOR SELECT USING (
    couple_id IN (
      SELECT id FROM couples WHERE auth.uid()::TEXT = ANY(partner_ids)
    )
  );

DROP POLICY IF EXISTS "Authenticated users can create growth challenges" ON growth_challenges;
CREATE POLICY "Authenticated users can create growth challenges" ON growth_challenges
  FOR INSERT WITH CHECK (
    auth.uid() = set_by_user_id OR auth.uid() = assigned_to_user_id
  );

DROP POLICY IF EXISTS "Users can update growth challenges in their couples" ON growth_challenges;
CREATE POLICY "Users can update growth challenges in their couples" ON growth_challenges
  FOR UPDATE USING (
    couple_id IN (
      SELECT id FROM couples WHERE auth.uid()::TEXT = ANY(partner_ids)
    )
  );

DROP POLICY IF EXISTS "Users can delete growth challenges in their couples" ON growth_challenges;
CREATE POLICY "Users can delete growth challenges in their couples" ON growth_challenges
  FOR DELETE USING (
    couple_id IN (
      SELECT id FROM couples WHERE auth.uid()::TEXT = ANY(partner_ids)
    )
  );

-- Challenge Check-ins policies
DROP POLICY IF EXISTS "Users can view check-ins for challenges in their couples" ON challenge_check_ins;
CREATE POLICY "Users can view check-ins for challenges in their couples" ON challenge_check_ins
  FOR SELECT USING (
    challenge_id IN (
      SELECT id FROM growth_challenges WHERE couple_id IN (
        SELECT id FROM couples WHERE auth.uid()::TEXT = ANY(partner_ids)
      )
    )
  );

DROP POLICY IF EXISTS "Authenticated users can create challenge check-ins" ON challenge_check_ins;
CREATE POLICY "Authenticated users can create challenge check-ins" ON challenge_check_ins
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS "Users can update their challenge check-ins" ON challenge_check_ins;
CREATE POLICY "Users can update their challenge check-ins" ON challenge_check_ins
  FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their challenge check-ins" ON challenge_check_ins;
CREATE POLICY "Users can delete their challenge check-ins" ON challenge_check_ins
  FOR DELETE USING (auth.uid() = user_id);

-- Appreciation Entries policies
DROP POLICY IF EXISTS "Users can view appreciation entries in their couples" ON appreciation_entries;
CREATE POLICY "Users can view appreciation entries in their couples" ON appreciation_entries
  FOR SELECT USING (
    couple_id IN (
      SELECT id FROM couples WHERE auth.uid()::TEXT = ANY(partner_ids)
    )
  );

DROP POLICY IF EXISTS "Authenticated users can create appreciation entries" ON appreciation_entries;
CREATE POLICY "Authenticated users can create appreciation entries" ON appreciation_entries
  FOR INSERT WITH CHECK (
    auth.uid() = from_user_id
  );

DROP POLICY IF EXISTS "Users can update their appreciation entries" ON appreciation_entries;
CREATE POLICY "Users can update their appreciation entries" ON appreciation_entries
  FOR UPDATE USING (auth.uid() = from_user_id);

DROP POLICY IF EXISTS "Users can delete their appreciation entries" ON appreciation_entries;
CREATE POLICY "Users can delete their appreciation entries" ON appreciation_entries
  FOR DELETE USING (auth.uid() = from_user_id);

-- Check-ins policies
DROP POLICY IF EXISTS "Users can view check-ins in their couples" ON check_ins;
CREATE POLICY "Users can view check-ins in their couples" ON check_ins
  FOR SELECT USING (
    couple_id IN (
      SELECT id FROM couples WHERE auth.uid()::TEXT = ANY(partner_ids)
    )
  );

DROP POLICY IF EXISTS "Authenticated users can create check-ins" ON check_ins;
CREATE POLICY "Authenticated users can create check-ins" ON check_ins
  FOR INSERT WITH CHECK (
    auth.uid() = user_id
  );

DROP POLICY IF EXISTS "Users can update their check-ins" ON check_ins;
CREATE POLICY "Users can update their check-ins" ON check_ins
  FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their check-ins" ON check_ins;
CREATE POLICY "Users can delete their check-ins" ON check_ins
  FOR DELETE USING (auth.uid() = user_id);

-- Gratitude Entries policies
DROP POLICY IF EXISTS "Users can view gratitude entries in their couples" ON gratitude_entries;
CREATE POLICY "Users can view gratitude entries in their couples" ON gratitude_entries
  FOR SELECT USING (
    couple_id IN (
      SELECT id FROM couples WHERE auth.uid()::TEXT = ANY(partner_ids)
    )
  );

DROP POLICY IF EXISTS "Authenticated users can create gratitude entries" ON gratitude_entries;
CREATE POLICY "Authenticated users can create gratitude entries" ON gratitude_entries
  FOR INSERT WITH CHECK (
    auth.uid() = user_id
  );

DROP POLICY IF EXISTS "Users can update their gratitude entries" ON gratitude_entries;
CREATE POLICY "Users can update their gratitude entries" ON gratitude_entries
  FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their gratitude entries" ON gratitude_entries;
CREATE POLICY "Users can delete their gratitude entries" ON gratitude_entries
  FOR DELETE USING (auth.uid() = user_id);

-- Milestones policies
DROP POLICY IF EXISTS "Users can view milestones in their couples" ON milestones;
CREATE POLICY "Users can view milestones in their couples" ON milestones
  FOR SELECT USING (
    couple_id IN (
      SELECT id FROM couples WHERE auth.uid()::TEXT = ANY(partner_ids)
    )
  );

DROP POLICY IF EXISTS "Authenticated users can create milestones" ON milestones;
CREATE POLICY "Authenticated users can create milestones" ON milestones
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS "Users can update milestones in their couples" ON milestones;
CREATE POLICY "Users can update milestones in their couples" ON milestones
  FOR UPDATE USING (
    couple_id IN (
      SELECT id FROM couples WHERE auth.uid()::TEXT = ANY(partner_ids)
    )
  );

DROP POLICY IF EXISTS "Users can delete milestones in their couples" ON milestones;
CREATE POLICY "Users can delete milestones in their couples" ON milestones
  FOR DELETE USING (
    couple_id IN (
      SELECT id FROM couples WHERE auth.uid()::TEXT = ANY(partner_ids)
    )
  );

-- Date Ideas policies
DROP POLICY IF EXISTS "Users can view date ideas in their couples" ON date_ideas;
CREATE POLICY "Users can view date ideas in their couples" ON date_ideas
  FOR SELECT USING (
    couple_id IN (
      SELECT id FROM couples WHERE auth.uid()::TEXT = ANY(partner_ids)
    )
  );

DROP POLICY IF EXISTS "Authenticated users can create date ideas" ON date_ideas;
CREATE POLICY "Authenticated users can create date ideas" ON date_ideas
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS "Users can update date ideas in their couples" ON date_ideas;
CREATE POLICY "Users can update date ideas in their couples" ON date_ideas
  FOR UPDATE USING (
    couple_id IN (
      SELECT id FROM couples WHERE auth.uid()::TEXT = ANY(partner_ids)
    )
  );

DROP POLICY IF EXISTS "Users can delete date ideas in their couples" ON date_ideas;
CREATE POLICY "Users can delete date ideas in their couples" ON date_ideas
  FOR DELETE USING (
    couple_id IN (
      SELECT id FROM couples WHERE auth.uid()::TEXT = ANY(partner_ids)
    )
  );

-- In-App Notifications policies
DROP POLICY IF EXISTS "Users can view their own notifications" ON in_app_notifications;
CREATE POLICY "Users can view their own notifications" ON in_app_notifications
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Authenticated users can create notifications" ON in_app_notifications;
CREATE POLICY "Authenticated users can create notifications" ON in_app_notifications
  FOR INSERT WITH CHECK (
    auth.uid() = user_id
  );

DROP POLICY IF EXISTS "Users can update their own notifications" ON in_app_notifications;
CREATE POLICY "Users can update their own notifications" ON in_app_notifications
  FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own notifications" ON in_app_notifications;
CREATE POLICY "Users can delete their own notifications" ON in_app_notifications
  FOR DELETE USING (auth.uid() = user_id);
