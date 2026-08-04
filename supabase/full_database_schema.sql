-- ============================================================================
-- FoodTrack — Script complet de création de la base de données
-- Schema : public   |   Extensions : pgcrypto, postgis
-- ============================================================================
-- Ce script recrée TOUTES les tables, policies RLS, triggers et fonctions
-- de l'application FoodTrack, sans erreur de lint.
--
-- IMPORTANT à propos de spatial_ref_sys :
--   La table `spatial_ref_sys` est le catalogue interne de l'extension
--   PostGIS. Elle est créée AUTOMATIQUEMENT par l'extension et réside dans le
--   schéma public. Le lint "RLS Disabled in Public" la signale à tort.
--   Pour corriger ce faux positif, deux solutions (voir FIN de script) :
--     A) Déplacer spatial_ref_sys dans un schéma non exposé (recommendé)
--     B) L'activer le RLS dessus (déconseillé, réservé au propriétaire)
--
-- Attention : le script DOIT être exécuté par un rôle disposant des droits
-- propriétaire sur les objets (ex: postgres, ou le rôle de la base).
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. EXTENSIONS
-- ---------------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS postgis;

-- ---------------------------------------------------------------------------
-- 2. TABLE profiles
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email text NOT NULL,
  display_name text,
  role text NOT NULL DEFAULT 'client' CHECK (role IN ('client', 'pro')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS profiles_email_idx ON public.profiles (email);
CREATE INDEX IF NOT EXISTS profiles_role_idx ON public.profiles (role);

-- ---------------------------------------------------------------------------
-- 3. TABLE foodtrucks
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.foodtrucks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE,
  name text NOT NULL,
  description text,
  cuisine_type text,
  latitude numeric(10,8),
  longitude numeric(11,8),
  is_open boolean NOT NULL DEFAULT true,
  status text NOT NULL DEFAULT 'Ouvert',
  opening_hours jsonb DEFAULT '{}',
  image_url text,
  bio text,
  phone text,
  service_type text,
  social_instagram text,
  social_facebook text,
  social_tiktok text,
  social_x text,
  social_website text,
  average_rating numeric(3,2) NOT NULL DEFAULT 0,
  review_count integer NOT NULL DEFAULT 0,
  pro_since timestamptz,
  location geometry(Point,4326),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Un seul foodtruck par propriétaire (NULL non contraint)
CREATE UNIQUE INDEX IF NOT EXISTS foodtrucks_owner_id_unique
  ON public.foodtrucks (owner_id) WHERE owner_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_foodtrucks_location
  ON public.foodtrucks USING GIST (location);
CREATE INDEX IF NOT EXISTS idx_foodtrucks_cuisine_type
  ON public.foodtrucks (cuisine_type);
CREATE INDEX IF NOT EXISTS idx_foodtrucks_is_open
  ON public.foodtrucks (is_open);
CREATE INDEX IF NOT EXISTS idx_foodtrucks_average_rating
  ON public.foodtrucks (average_rating DESC);

-- ---------------------------------------------------------------------------
-- 4. TABLE menu_items
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.menu_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  foodtruck_id uuid NOT NULL REFERENCES public.foodtrucks(id) ON DELETE CASCADE,
  name text NOT NULL,
  description text,
  price dec(10, 2) NOT NULL,
  category text DEFAULT 'plat',
  is_available boolean NOT NULL DEFAULT true,
  image_url text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_menu_items_foodtruck_id
  ON public.menu_items (foodtruck_id);
CREATE INDEX IF NOT EXISTS idx_menu_items_category
  ON public.menu_items (category);
CREATE INDEX IF NOT EXISTS idx_menu_items_is_available
  ON public.menu_items (is_available);

-- ---------------------------------------------------------------------------
-- 5. TABLE user_reports
-- ---------------------------------------------------------------------------
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

-- ---------------------------------------------------------------------------
-- 6. TABLE feedback
-- ---------------------------------------------------------------------------
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

-- ---------------------------------------------------------------------------
-- 7. TABLE reviews
-- ---------------------------------------------------------------------------
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

-- ============================================================================
-- 8. FONCTIONS & TRIGGERS
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 8.1 handle_new_user : crée le profil à l'inscription auth
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, display_name, role, created_at, updated_at)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'role', 'client'),
    now(),
    now()
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  RAISE WARNING 'Error in handle_new_user: %', SQLERRM;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ---------------------------------------------------------------------------
-- 8.2 update_updated_at_column : met à jour updated_at
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_updated_at ON public.foodtrucks;
CREATE TRIGGER trigger_updated_at
  BEFORE UPDATE ON public.foodtrucks
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS trigger_menu_items_updated_at ON public.menu_items;
CREATE TRIGGER trigger_menu_items_updated_at
  BEFORE UPDATE ON public.menu_items
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS trigger_reviews_updated_at ON public.reviews;
CREATE TRIGGER trigger_reviews_updated_at
  BEFORE UPDATE ON public.reviews
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ---------------------------------------------------------------------------
-- 8.3 update_foodtruck_location : calcule la géométrie POSTGIS
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.update_foodtruck_location()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.latitude IS NOT NULL AND NEW.longitude IS NOT NULL THEN
    NEW.location := ST_SetSRID(
      ST_MakePoint(NEW.longitude::double precision, NEW.latitude::double precision),
      4326
    );
  ELSE
    NEW.location := NULL;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_location ON public.foodtrucks;
CREATE TRIGGER trigger_update_location
  BEFORE INSERT OR UPDATE ON public.foodtrucks
  FOR EACH ROW EXECUTE FUNCTION public.update_foodtruck_location();

-- ---------------------------------------------------------------------------
-- 8.4 set_pro_since : ancienneté du pro depuis profiles.created_at
-- ---------------------------------------------------------------------------
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
  FOR EACH ROW EXECUTE FUNCTION public.set_pro_since();

-- ---------------------------------------------------------------------------
-- 8.5 update_foodtruck_rating : recalcule note moyenne / nb d'avis
-- ---------------------------------------------------------------------------
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
  FOR EACH ROW EXECUTE FUNCTION public.update_foodtruck_rating();

DROP TRIGGER IF EXISTS trigger_update_foodtruck_rating_update ON public.reviews;
CREATE TRIGGER trigger_update_foodtruck_rating_update
  AFTER UPDATE OF rating ON public.reviews
  FOR EACH ROW EXECUTE FUNCTION public.update_foodtruck_rating();

DROP TRIGGER IF EXISTS trigger_update_foodtruck_rating_delete ON public.reviews;
CREATE TRIGGER trigger_update_foodtruck_rating_delete
  AFTER DELETE ON public.reviews
  FOR EACH ROW EXECUTE FUNCTION public.update_foodtruck_rating();

-- ============================================================================
-- 9. ROW LEVEL SECURITY (RLS)
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 9.1 profiles
-- ---------------------------------------------------------------------------
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles FORCE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "users_read_own_profile" ON public.profiles;
CREATE POLICY "users_read_own_profile" ON public.profiles FOR SELECT
  TO authenticated USING (auth.uid() = id);

DROP POLICY IF EXISTS "users_insert_own_profile" ON public.profiles;
CREATE POLICY "users_insert_own_profile" ON public.profiles FOR INSERT
  TO authenticated WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "users_update_own_profile" ON public.profiles;
CREATE POLICY "users_update_own_profile" ON public.profiles FOR UPDATE
  TO authenticated USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "users_delete_own_profile" ON public.profiles;
CREATE POLICY "users_delete_own_profile" ON public.profiles FOR DELETE
  TO authenticated USING (auth.uid() = id);

DROP POLICY IF EXISTS "service_full_access_profiles" ON public.profiles;
CREATE POLICY "service_full_access_profiles" ON public.profiles FOR ALL
  TO service_role USING (true) WITH CHECK (true);

-- ---------------------------------------------------------------------------
-- 9.2 foodtrucks
-- ---------------------------------------------------------------------------
ALTER TABLE public.foodtrucks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.foodtrucks FORCE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view foodtrucks" ON public.foodtrucks;
CREATE POLICY "Anyone can view foodtrucks" ON public.foodtrucks FOR SELECT
  TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "Pro users can create foodtrucks" ON public.foodtrucks;
CREATE POLICY "Pro users can create foodtrucks" ON public.foodtrucks FOR INSERT
  TO authenticated WITH CHECK (
    auth.uid() = owner_id
    AND EXISTS (
      SELECT 1 FROM public.profiles
      WHERE profiles.id = auth.uid() AND profiles.role = 'pro'
    )
  );

DROP POLICY IF EXISTS "Owners can update foodtrucks" ON public.foodtrucks;
CREATE POLICY "Owners can update foodtrucks" ON public.foodtrucks FOR UPDATE
  TO authenticated USING (auth.uid() = owner_id) WITH CHECK (auth.uid() = owner_id);

DROP POLICY IF EXISTS "Owners can delete foodtrucks" ON public.foodtrucks;
CREATE POLICY "Owners can delete foodtrucks" ON public.foodtrucks FOR DELETE
  TO authenticated USING (auth.uid() = owner_id);

DROP POLICY IF EXISTS "service_full_access_foodtrucks" ON public.foodtrucks;
CREATE POLICY "service_full_access_foodtrucks" ON public.foodtrucks FOR ALL
  TO service_role USING (true) WITH CHECK (true);

-- ---------------------------------------------------------------------------
-- 9.3 menu_items
-- ---------------------------------------------------------------------------
ALTER TABLE public.menu_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.menu_items FORCE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view menu items" ON public.menu_items;
CREATE POLICY "Anyone can view menu items" ON public.menu_items FOR SELECT
  TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "Owners can insert menu items" ON public.menu_items;
CREATE POLICY "Owners can insert menu items" ON public.menu_items FOR INSERT
  TO authenticated WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.foodtrucks
      WHERE foodtrucks.id = menu_items.foodtruck_id
      AND foodtrucks.owner_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Owners can update menu items" ON public.menu_items;
CREATE POLICY "Owners can update menu items" ON public.menu_items FOR UPDATE
  TO authenticated USING (
    EXISTS (
      SELECT 1 FROM public.foodtrucks
      WHERE foodtrucks.id = menu_items.foodtruck_id
      AND foodtrucks.owner_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Owners can delete menu items" ON public.menu_items;
CREATE POLICY "Owners can delete menu items" ON public.menu_items FOR DELETE
  TO authenticated USING (
    EXISTS (
      SELECT 1 FROM public.foodtrucks
      WHERE foodtrucks.id = menu_items.foodtruck_id
      AND foodtrucks.owner_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "service_full_access_menu_items" ON public.menu_items;
CREATE POLICY "service_full_access_menu_items" ON public.menu_items FOR ALL
  TO service_role USING (true) WITH CHECK (true);

-- ---------------------------------------------------------------------------
-- 9.4 user_reports
-- ---------------------------------------------------------------------------
ALTER TABLE public.user_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_reports FORCE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Reporters read own reports" ON public.user_reports;
CREATE POLICY "Reporters read own reports" ON public.user_reports FOR SELECT
  TO authenticated USING (auth.uid() = reporter_id);

DROP POLICY IF EXISTS "Reporters can create reports" ON public.user_reports;
CREATE POLICY "Reporters can create reports" ON public.user_reports FOR INSERT
  TO authenticated WITH CHECK (auth.uid() = reporter_id);

DROP POLICY IF EXISTS "service_full_access_user_reports" ON public.user_reports;
CREATE POLICY "service_full_access_user_reports" ON public.user_reports FOR ALL
  TO service_role USING (true) WITH CHECK (true);

-- ---------------------------------------------------------------------------
-- 9.5 feedback
-- ---------------------------------------------------------------------------
ALTER TABLE public.feedback ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.feedback FORCE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users read own feedback" ON public.feedback;
CREATE POLICY "Users read own feedback" ON public.feedback FOR SELECT
  TO authenticated USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can create feedback" ON public.feedback;
CREATE POLICY "Users can create feedback" ON public.feedback FOR INSERT
  TO authenticated WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "service_full_access_feedback" ON public.feedback;
CREATE POLICY "service_full_access_feedback" ON public.feedback FOR ALL
  TO service_role USING (true) WITH CHECK (true);

-- ---------------------------------------------------------------------------
-- 9.6 reviews
-- ---------------------------------------------------------------------------
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews FORCE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view reviews" ON public.reviews;
CREATE POLICY "Anyone can view reviews" ON public.reviews FOR SELECT
  TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "Users can create reviews" ON public.reviews;
CREATE POLICY "Users can create reviews" ON public.reviews FOR INSERT
  TO authenticated WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own reviews" ON public.reviews;
CREATE POLICY "Users can update own reviews" ON public.reviews FOR UPDATE
  TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own reviews" ON public.reviews;
CREATE POLICY "Users can delete own reviews" ON public.reviews FOR DELETE
  TO authenticated USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "service_full_access_reviews" ON public.reviews;
CREATE POLICY "service_full_access_reviews" ON public.reviews FOR ALL
  TO service_role USING (true) WITH CHECK (true);

-- ============================================================================
-- 10. CORRECTION DU LINT "RLS Disabled" sur spatial_ref_sys
-- ============================================================================
-- La table spatial_ref_sys est le catalogue interne de PostGIS. C'est un
-- faux positif du lint. Pour le corriger proprement, on déplace la table
-- dans un schéma interne NON exposé à PostgREST (recommandé par Supabase).
--
-- Attention : cette étape exige les droits de propriétaire sur la table
-- spatial_ref_sys (réservé au rôle superuser / propriétaire de la base).
-- Si le rôle actuel ne peut pas la déplacer, exécutez ce bloc en tant que
-- postgres, ou passez à la solution B (section 10B).
-- ---------------------------------------------------------------------------

-- 10A. Déplacer spatial_ref_sys hors du schéma public (RECOMMANDÉ)
-- ============================================================================
-- Créer un schéma interne non exposé, puis déplacer la table système.
-- PostGIS sait déjà gérer spatial_ref_sys dans un schéma interne.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_tables
    WHERE schemaname = 'public' AND tablename = 'spatial_ref_sys'
  ) THEN
    CREATE SCHEMA IF NOT EXISTS postgis_catalog;
    EXECUTE 'ALTER TABLE public.spatial_ref_sys SET SCHEMA postgis_catalog';
  END IF;
END $$;

-- ============================================================================
-- 10B. SOLUTION ALTERNATIVE : activer le RLS sur spatial_ref_sys
-- ============================================================================
-- À utiliser SEULEMENT si vous ne pouvez pas déplacer la table (pas les
-- droits propriétaire). Décommentez ce bloc à la place de 10A.
--
-- WARNING : pour activer le RLS il faut être propriétaire de la table.
-- En tant que postgres/superuser, vous pouvez exécuter :
--
--   ALTER TABLE public.spatial_ref_sys ENABLE ROW LEVEL SECURITY;
--   ALTER TABLE public.spatial_ref_sys FORCE ROW LEVEL SECURITY;
--
--   -- Autoriser la lecture (PostGIS a besoin de lire cette table)
--   DROP POLICY IF EXISTS "spatial_ref_sys_read" ON public.spatial_ref_sys;
--   CREATE POLICY "spatial_ref_sys_read" ON public.spatial_ref_sys FOR SELECT
--     TO anon, authenticated USING (true);
--
--   DROP POLICY IF EXISTS "spatial_ref_sys_service" ON public.spatial_ref_sys;
--   CREATE POLICY "spatial_ref_sys_service" ON public.spatial_ref_sys FOR ALL
--     TO service_role USING (true) WITH CHECK (true);
--
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 11. VÉRIFICATION
-- ---------------------------------------------------------------------------
-- Affiche l'état RLS de toutes les tables du schéma public. Après exécution
-- de la section 10A, spatial_ref_sys n'apparaît plus dans public.
SELECT
  schemaname,
  tablename,
  rowsecurity,
  forcerowsecurity AS force_rls
FROM pg_tables
WHERE schemaname IN ('public', 'postgis_catalog')
ORDER BY schemaname, tablename;
