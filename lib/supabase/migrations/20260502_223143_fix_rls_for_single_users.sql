-- Fix RLS policies to allow single users (without partners) to save data
-- This allows users to use the app even before linking with a partner

-- Conflict Sessions: Allow INSERT for authenticated users even without a couple
DROP POLICY IF EXISTS "Authenticated users can create conflict sessions" ON conflict_sessions;
CREATE POLICY "Authenticated users can create conflict sessions" ON conflict_sessions
  FOR INSERT WITH CHECK (
    auth.uid() = initiator_id
  );

-- Conflict Sessions: Allow SELECT for single users OR couples
DROP POLICY IF EXISTS "Users can view conflict sessions in their couples" ON conflict_sessions;
CREATE POLICY "Users can view conflict sessions in their couples" ON conflict_sessions
  FOR SELECT USING (
    auth.uid() = initiator_id OR 
    couple_id IN (
      SELECT id FROM couples WHERE auth.uid()::TEXT = ANY(partner_ids)
    )
  );

-- In-App Notifications: Allow INSERT for authenticated users
DROP POLICY IF EXISTS "Authenticated users can create notifications" ON in_app_notifications;
CREATE POLICY "Authenticated users can create notifications" ON in_app_notifications
  FOR INSERT WITH CHECK (
    auth.uid() = user_id
  );

-- In-App Notifications: Allow SELECT for authenticated users
DROP POLICY IF EXISTS "Users can view their own notifications" ON in_app_notifications;
CREATE POLICY "Users can view their own notifications" ON in_app_notifications
  FOR SELECT USING (
    auth.uid() = user_id
  );

-- Growth Challenges: Allow INSERT for authenticated users
DROP POLICY IF EXISTS "Authenticated users can create growth challenges" ON growth_challenges;
CREATE POLICY "Authenticated users can create growth challenges" ON growth_challenges
  FOR INSERT WITH CHECK (
    auth.uid() = set_by_user_id OR auth.uid() = assigned_to_user_id
  );

-- Growth Challenges: Allow SELECT for single users OR couples
DROP POLICY IF EXISTS "Users can view growth challenges in their couples" ON growth_challenges;
CREATE POLICY "Users can view growth challenges in their couples" ON growth_challenges
  FOR SELECT USING (
    auth.uid() = set_by_user_id OR 
    auth.uid() = assigned_to_user_id OR
    couple_id IN (
      SELECT id FROM couples WHERE auth.uid()::TEXT = ANY(partner_ids)
    )
  );

-- Appreciation Entries: Allow INSERT for authenticated users
DROP POLICY IF EXISTS "Authenticated users can create appreciation entries" ON appreciation_entries;
CREATE POLICY "Authenticated users can create appreciation entries" ON appreciation_entries
  FOR INSERT WITH CHECK (
    auth.uid() = from_user_id
  );

-- Appreciation Entries: Allow SELECT for single users OR couples
DROP POLICY IF EXISTS "Users can view appreciation entries in their couples" ON appreciation_entries;
CREATE POLICY "Users can view appreciation entries in their couples" ON appreciation_entries
  FOR SELECT USING (
    auth.uid() = from_user_id OR 
    auth.uid() = to_user_id OR
    couple_id IN (
      SELECT id FROM couples WHERE auth.uid()::TEXT = ANY(partner_ids)
    )
  );

-- Check-ins: Allow INSERT for authenticated users
DROP POLICY IF EXISTS "Authenticated users can create check-ins" ON check_ins;
CREATE POLICY "Authenticated users can create check-ins" ON check_ins
  FOR INSERT WITH CHECK (
    auth.uid() = user_id
  );

-- Check-ins: Allow SELECT for single users OR couples
DROP POLICY IF EXISTS "Users can view check-ins in their couples" ON check_ins;
CREATE POLICY "Users can view check-ins in their couples" ON check_ins
  FOR SELECT USING (
    auth.uid() = user_id OR
    couple_id IN (
      SELECT id FROM couples WHERE auth.uid()::TEXT = ANY(partner_ids)
    )
  );

-- Gratitude Entries: Allow INSERT for authenticated users
DROP POLICY IF EXISTS "Authenticated users can create gratitude entries" ON gratitude_entries;
CREATE POLICY "Authenticated users can create gratitude entries" ON gratitude_entries
  FOR INSERT WITH CHECK (
    auth.uid() = user_id
  );

-- Gratitude Entries: Allow SELECT for single users OR couples
DROP POLICY IF EXISTS "Users can view gratitude entries in their couples" ON gratitude_entries;
CREATE POLICY "Users can view gratitude entries in their couples" ON gratitude_entries
  FOR SELECT USING (
    auth.uid() = user_id OR
    couple_id IN (
      SELECT id FROM couples WHERE auth.uid()::TEXT = ANY(partner_ids)
    )
  );

-- Milestones: Allow INSERT for authenticated users
DROP POLICY IF EXISTS "Authenticated users can create milestones" ON milestones;
CREATE POLICY "Authenticated users can create milestones" ON milestones
  FOR INSERT WITH CHECK (
    auth.uid() IS NOT NULL
  );

-- Milestones: Allow SELECT for all authenticated users (couples OR single)
DROP POLICY IF EXISTS "Users can view milestones in their couples" ON milestones;
CREATE POLICY "Users can view milestones in their couples" ON milestones
  FOR SELECT USING (
    auth.uid() IS NOT NULL
  );

-- Date Ideas: Allow INSERT for authenticated users
DROP POLICY IF EXISTS "Authenticated users can create date ideas" ON date_ideas;
CREATE POLICY "Authenticated users can create date ideas" ON date_ideas
  FOR INSERT WITH CHECK (
    auth.uid() IS NOT NULL
  );

-- Date Ideas: Allow SELECT for all authenticated users (couples OR single)
DROP POLICY IF EXISTS "Users can view date ideas in their couples" ON date_ideas;
CREATE POLICY "Users can view date ideas in their couples" ON date_ideas
  FOR SELECT USING (
    auth.uid() IS NOT NULL
  );
