/*
# Create user_reports and feedback tables

1. Purpose
- Let any authenticated user report another user (harassment, spam,
  inappropriate content, fake foodtruck, other) to the moderation team.
- Let any user submit bug reports and feature/suggestion feedback for
  the FoodTrack app itself.

2. New Tables
- `user_reports`
  - id (uuid, primary key)
  - reporter_id (uuid, references profiles, who files the report)
  - reported_user_id (uuid, nullable, references profiles, the reported account)
  - reported_user_email (text, email of the reported user, stored in case
    their account is deleted, keeps audit trail)
  - reason (text, one of: harassment, spam, inappropriate, fake_foodtruck, other)
  - description (text, optional details)
  - status (text, moderation lifecycle: pending / reviewed / resolved / dismissed)
  - created_at (timestamptz)

- `feedback`
  - id (uuid, primary key)
  - user_id (uuid, references profiles, author of the feedback)
  - type (text, 'bug' or 'suggestion')
  - category (text, e.g. 'carte', 'recherche', 'compte', 'pro', 'autre')
  - title (text, short summary)
  - description (text, full details)
  - status (text, lifecycle: new / in_progress / resolved / closed)
  - created_at (timestamptz)

3. Security (RLS)
- user_reports:
  - SELECT: reporter can only read their own reports
  - INSERT: authenticated users, with reporter_id = auth.uid()
  - UPDATE/DELETE: none (only via service role / admin)
- feedback:
  - SELECT: author can only read their own feedback
  - INSERT: authenticated users, with user_id = auth.uid()
  - UPDATE/DELETE: none (only via service role / admin)

4. Notes
- A trigger auto-updates nothing here (no updated_at needed, reports are
  append-only from the app side; moderation happens with service role).
- Indexes are created on the foreign keys and status for quick queries.
*/

-- Extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ---------------------------------------------------------------
-- Table: user_reports
-- ---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.user_reports (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  reported_user_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  reported_user_email text NOT NULL,
  reason text NOT NULL CHECK (
    reason IN ('harassment', 'spam', 'inappropriate', 'fake_foodtruck', 'other')
  ),
  description text,
  status text NOT NULL DEFAULT 'pending' CHECK (
    status IN ('pending', 'reviewed', 'resolved', 'dismissed')
  ),
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_user_reports_reporter_id
  ON public.user_reports (reporter_id);
CREATE INDEX IF NOT EXISTS idx_user_reports_status
  ON public.user_reports (status);
CREATE INDEX IF NOT EXISTS idx_user_reports_reported_user
  ON public.user_reports (reported_user_id);

ALTER TABLE public.user_reports ENABLE ROW LEVEL SECURITY;

-- Reporters can read their own reports
DROP POLICY IF EXISTS "Reporters read own reports" ON public.user_reports;
CREATE POLICY "Reporters read own reports"
  ON public.user_reports FOR SELECT
  TO authenticated
  USING (auth.uid() = reporter_id);

-- Authenticated users can file a report
DROP POLICY IF EXISTS "Reporters can create reports" ON public.user_reports;
CREATE POLICY "Reporters can create reports"
  ON public.user_reports FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = reporter_id);

-- No UPDATE / DELETE policies for regular users:
-- moderation is done server-side with the service role.

-- ---------------------------------------------------------------
-- Table: feedback
-- ---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.feedback (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  type text NOT NULL CHECK (type IN ('bug', 'suggestion')),
  category text NOT NULL DEFAULT 'autre' CHECK (
    category IN ('carte', 'recherche', 'compte', 'pro', 'performance', 'autre')
  ),
  title text NOT NULL,
  description text NOT NULL,
  status text NOT NULL DEFAULT 'new' CHECK (
    status IN ('new', 'in_progress', 'resolved', 'closed')
  ),
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_feedback_user_id
  ON public.feedback (user_id);
CREATE INDEX IF NOT EXISTS idx_feedback_type
  ON public.feedback (type);
CREATE INDEX IF NOT EXISTS idx_feedback_status
  ON public.feedback (status);

ALTER TABLE public.feedback ENABLE ROW LEVEL SECURITY;

-- Authors can read their own feedback
DROP POLICY IF EXISTS "Users read own feedback" ON public.feedback;
CREATE POLICY "Users read own feedback"
  ON public.feedback FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Authenticated users can submit feedback
DROP POLICY IF EXISTS "Users can create feedback" ON public.feedback;
CREATE POLICY "Users can create feedback"
  ON public.feedback FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- No UPDATE / DELETE policies for regular users.

