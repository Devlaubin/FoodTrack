/*
# Ajouter : profils Pro enrichis + Notes & Avis

1. Purpose
- Enrichir le profil des foodtrucks gérés par les comptes Pro :
  - bio (description complète)
  - téléphone de contact
  - type de service (sur place, à emporter, livraison, etc.)
  - réseaux sociaux (Instagram, Facebook, TikTok, X, site web)
  - ancienneté "Membre FoodTrack depuis ..." (pro_since)
  - note moyenne (average_rating) et nombre d'avis (review_count)
- Permettre aux clients de noter un foodtruck (1 à 5 étoiles) et de laisser
  un commentaire, via une table `reviews`.
- Maintenir automatiquement la note moyenne et le compteur d'avis.

2. New Columns (foodtrucks)
- bio (text)
- phone (text)
- service_type (text)
- social_instagram, social_facebook, social_tiktok, social_x, social_website (text)
- average_rating (numeric, default 0)
- review_count (integer, default 0)
- pro_since (timestamptz, copié depuis profiles.created_at à la création)

3. New Table
- `reviews`
  - id (uuid, primary key)
  - foodtruck_id (uuid, references foodtrucks)
  - user_id (uuid, references profiles)
  - author_name (text)
  - rating (integer, CHECK 1..5)
  - comment (text)
  - created_at (timestamptz)
  - UNIQUE (foodtruck_id, user_id) -> un seul avis par utilisateur par truck

4. Security (RLS)
- reviews:
  - SELECT: tout le monde peut lire les avis
  - INSERT: authentifié, user_id = auth.uid()
  - UPDATE: authentifié, user_id = auth.uid()
  - DELETE: authentifié, user_id = auth.uid()
- Triggers de mise à jour de average_rating / review_count (SECURITY DEFINER)

5. Notes
- Le trigger `set_pro_since` copie `profiles.created_at` à la création du
  foodtruck, ce qui donne l'ancienneté du pro sur l'application.
*/

-- ==========================================================================
-- 1. Colonnes supplémentaires sur foodtrucks
-- ==========================================================================
ALTER TABLE public.foodtrucks
  ADD COLUMN IF NOT EXISTS bio text,
  ADD COLUMN IF NOT EXISTS phone text,
  ADD COLUMN IF NOT EXISTS service_type text,
  ADD COLUMN IF NOT EXISTS social_instagram text,
  ADD COLUMN IF NOT EXISTS social_facebook text,
  ADD COLUMN IF NOT EXISTS social_tiktok text,
  ADD COLUMN IF NOT EXISTS social_x text,
  ADD COLUMN IF NOT EXISTS social_website text,
  ADD COLUMN IF NOT EXISTS average_rating numeric(3,2) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS review_count integer NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS pro_since timestamptz;

-- Index pour accélérer le tri par note
CREATE INDEX IF NOT EXISTS idx_foodtrucks_average_rating
  ON public.foodtrucks (average_rating DESC);

-- ==========================================================================
-- 2. Trigger : pro_since = date d'inscription du profil (ancienneté)
-- ==========================================================================
CREATE OR REPLACE FUNCTION public.set_pro_since()
RETURNS TRIGGER AS $$
DECLARE
  profile_created timestamptz;
BEGIN
  SELECT created_at INTO profile_created
  FROM public.profiles
  WHERE profiles.id = NEW.owner_id;

  NEW.pro_since := COALESCE(profile_created, now());
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_set_pro_since ON public.foodtrucks;
CREATE TRIGGER trigger_set_pro_since
  BEFORE INSERT ON public.foodtrucks
  FOR EACH ROW
  EXECUTE FUNCTION public.set_pro_since();

-- ==========================================================================
-- 3. Table reviews
-- ==========================================================================
CREATE TABLE IF NOT EXISTS public.reviews (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  foodtruck_id uuid NOT NULL REFERENCES public.foodtrucks(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  author_name text NOT NULL,
  rating integer NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment text NOT NULL DEFAULT '',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT reviews_foodtruck_user_unique UNIQUE (foodtruck_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_reviews_foodtruck_id
  ON public.reviews (foodtruck_id);
CREATE INDEX IF NOT EXISTS idx_reviews_user_id
  ON public.reviews (user_id);

-- ==========================================================================
-- 4. RLS reviews
-- ==========================================================================
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

-- Tout le monde peut lire les avis (anon + authenticated)
DROP POLICY IF EXISTS "Anyone can view reviews" ON public.reviews;
CREATE POLICY "Anyone can view reviews"
  ON public.reviews FOR SELECT
  TO anon, authenticated
  USING (true);

-- Un utilisateur authentifié peut créer son propre avis
DROP POLICY IF EXISTS "Users can create reviews" ON public.reviews;
CREATE POLICY "Users can create reviews"
  ON public.reviews FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Un utilisateur peut modifier son propre avis
DROP POLICY IF EXISTS "Users can update own reviews" ON public.reviews;
CREATE POLICY "Users can update own reviews"
  ON public.reviews FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Un utilisateur peut supprimer son propre avis
DROP POLICY IF EXISTS "Users can delete own reviews" ON public.reviews;
CREATE POLICY "Users can delete own reviews"
  ON public.reviews FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- service_role : accès complet
DROP POLICY IF EXISTS "service_full_access_reviews" ON public.reviews;
CREATE POLICY "service_full_access_reviews"
  ON public.reviews FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- ==========================================================================
-- 5. Trigger : mettre à jour average_rating / review_count
-- ==========================================================================
CREATE OR REPLACE FUNCTION public.update_foodtruck_rating()
RETURNS TRIGGER AS $$
DECLARE
  avg_rating numeric;
  cnt integer;
BEGIN
  SELECT AVG(rating)::numeric(3,2), COUNT(*)
    INTO avg_rating, cnt
  FROM public.reviews
  WHERE reviews.foodtruck_id = COALESCE(NEW.foodtruck_id, OLD.foodtruck_id);

  UPDATE public.foodtrucks
  SET average_rating = COALESCE(avg_rating, 0),
      review_count = cnt
  WHERE id = COALESCE(NEW.foodtruck_id, OLD.foodtruck_id);

  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_update_foodtruck_rating_insert ON public.reviews;
CREATE TRIGGER trigger_update_foodtruck_rating_insert
  AFTER INSERT ON public.reviews
  FOR EACH ROW
  EXECUTE FUNCTION public.update_foodtruck_rating();

DROP TRIGGER IF EXISTS trigger_update_foodtruck_rating_update ON public.reviews;
CREATE TRIGGER trigger_update_foodtruck_rating_update
  AFTER UPDATE OF rating ON public.reviews
  FOR EACH ROW
  EXECUTE FUNCTION public.update_foodtruck_rating();

DROP TRIGGER IF EXISTS trigger_update_foodtruck_rating_delete ON public.reviews;
CREATE TRIGGER trigger_update_foodtruck_rating_delete
  AFTER DELETE ON public.reviews
  FOR EACH ROW
  EXECUTE FUNCTION public.update_foodtruck_rating();

-- Trigger updated_at sur reviews
DROP TRIGGER IF EXISTS trigger_reviews_updated_at ON public.reviews;
CREATE TRIGGER trigger_reviews_updated_at
  BEFORE UPDATE ON public.reviews
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- ==========================================================================
-- 6. Vérification
-- ==========================================================================
SELECT
  schemaname,
  tablename,
  rowsecurity,
  forcerowsecurity AS force_rls
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('profiles', 'foodtrucks', 'menu_items', 'reviews', 'user_reports', 'feedback')
ORDER BY tablename;

