/*
# Enforce Pro ownership constraints on foodtrucks

1. Purpose
- The app assumes each Pro account owns at most one foodtruck
  (queried via `.eq('owner_id', ownerId).maybeSingle()`), but the
  original schema had no unique constraint enforcing that.
- The original INSERT policy only checked `auth.uid() = owner_id`,
  letting any authenticated user (not just Pro accounts) create a
  foodtruck, since the profile role was never verified.

2. Changes
- Add a unique constraint on `foodtrucks.owner_id` (nulls allowed,
  so trucks without an owner are unaffected) to guarantee "one
  foodtruck per Pro account".
- Replace the INSERT policy so it also requires the inserting
  user's profile role to be 'pro'.
*/

-- One foodtruck per owner (NULL owner_id rows are not constrained).
CREATE UNIQUE INDEX IF NOT EXISTS foodtrucks_owner_id_unique
  ON public.foodtrucks (owner_id)
  WHERE owner_id IS NOT NULL;

-- Require the profile role to be 'pro' to create a foodtruck.
DROP POLICY IF EXISTS "Pro users can create foodtrucks" ON public.foodtrucks;
CREATE POLICY "Pro users can create foodtrucks"
  ON public.foodtrucks FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() = owner_id
    AND EXISTS (
      SELECT 1 FROM public.profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'pro'
    )
  );
