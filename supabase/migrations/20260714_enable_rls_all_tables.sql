/*
# Activer le ROW LEVEL SECURITY sur toutes les tables applicatives FoodTrack

1. Purpose
- Corrige le lint Supabase "RLS Disabled in Public" en activant
  ROW LEVEL SECURITY sur les tables applicatives du schéma public.
- Recrée (idempotent) toutes les policies de sécurité métier.
- Ajoute les policies `service_role` nécessaires pour les triggers
  (SECURITY DEFINER), la modération et les scripts.

2. Tables couvertes
- profiles
- foodtrucks
- menu_items
- user_reports
- feedback
- reviews (si présente, issue de la migration 20260713)

3. Tables volontairement IGNORÉES
- `spatial_ref_sys` : table interne du catalogue PostGIS. Ce n'est PAS une
  table applicative. Le lint "RLS Disabled" la signale à tort (faux positif
  connu pour les tables de catalogue PostGIS). De plus, le rôle qui exécute
  les migrations n'est généralement pas propriétaire de cette table, et
  l'activer n'aurait aucun sens fonctionnel. → NE PAS y toucher.

4. Méthode d'application
- Option A (recommandée) : Dashboard Supabase → SQL Editor → coller → Run
- Option B (CLI) : `supabase db push`

5. Note
- Le script est idempotent : il peut être exécuté plusieurs fois sans erreur.
*/

-- ==========================================================================
-- 1. PROFILES
-- ==========================================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles FORCE ROW LEVEL SECURITY;

-- Un utilisateur ne lit que son propre profil
DROP POLICY IF EXISTS "users_read_own_profile" ON public.profiles;
CREATE POLICY "users_read_own_profile" ON public.profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

-- Un utilisateur peut créer son propre profil (fallback si le trigger échoue)
DROP POLICY IF EXISTS "users_insert_own_profile" ON public.profiles;
CREATE POLICY "users_insert_own_profile" ON public.profiles FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- Un utilisateur peut modifier son propre profil
DROP POLICY IF EXISTS "users_update_own_profile" ON public.profiles;
CREATE POLICY "users_update_own_profile" ON public.profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Un utilisateur peut supprimer son propre profil
DROP POLICY IF EXISTS "users_delete_own_profile" ON public.profiles;
CREATE POLICY "users_delete_own_profile" ON public.profiles FOR DELETE
  TO authenticated
  USING (auth.uid() = id);

-- Le trigger handle_new_user() (SECURITY DEFINER) insère les profils à la
-- création d'un compte auth.users. La policy service_role garantit que les
-- opérations de maintenance / scripts fonctionnent.
DROP POLICY IF EXISTS "service_full_access_profiles" ON public.profiles;
CREATE POLICY "service_full_access_profiles" ON public.profiles
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- ==========================================================================
-- 2. FOODTRUCKS
-- ==========================================================================
ALTER TABLE public.foodtrucks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.foodtrucks FORCE ROW LEVEL SECURITY;

-- Tout le monde (anon + authenticated) peut consulter les foodtrucks
DROP POLICY IF EXISTS "Anyone can view foodtrucks" ON public.foodtrucks;
CREATE POLICY "Anyone can view foodtrucks"
  ON public.foodtrucks FOR SELECT
  TO anon, authenticated
  USING (true);

-- Seuls les profils "pro" peuvent créer leur foodtruck (1 seul par pro,
-- garanti par l'index unique foodtrucks_owner_id_unique)
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

-- Le propriétaire peut modifier son foodtruck
DROP POLICY IF EXISTS "Owners can update foodtrucks" ON public.foodtrucks;
CREATE POLICY "Owners can update foodtrucks"
  ON public.foodtrucks FOR UPDATE
  TO authenticated
  USING (auth.uid() = owner_id)
  WITH CHECK (auth.uid() = owner_id);

-- Le propriétaire peut supprimer son foodtruck
DROP POLICY IF EXISTS "Owners can delete foodtrucks" ON public.foodtrucks;
CREATE POLICY "Owners can delete foodtrucks"
  ON public.foodtrucks FOR DELETE
  TO authenticated
  USING (auth.uid() = owner_id);

-- service_role : accès complet (modération, scripts, seed)
DROP POLICY IF EXISTS "service_full_access_foodtrucks" ON public.foodtrucks;
CREATE POLICY "service_full_access_foodtrucks" ON public.foodtrucks
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- ==========================================================================
-- 3. MENU_ITEMS
-- ==========================================================================
ALTER TABLE public.menu_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.menu_items FORCE ROW LEVEL SECURITY;

-- Tout le monde peut consulter les menus
DROP POLICY IF EXISTS "Anyone can view menu items" ON public.menu_items;
CREATE POLICY "Anyone can view menu items"
  ON public.menu_items FOR SELECT
  TO anon, authenticated
  USING (true);

-- Seul le propriétaire du foodtruck peut insérer un menu item
DROP POLICY IF EXISTS "Owners can insert menu items" ON public.menu_items;
CREATE POLICY "Owners can insert menu items"
  ON public.menu_items FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.foodtrucks
      WHERE foodtrucks.id = menu_items.foodtruck_id
      AND foodtrucks.owner_id = auth.uid()
    )
  );

-- Seul le propriétaire du foodtruck peut modifier un menu item
DROP POLICY IF EXISTS "Owners can update menu items" ON public.menu_items;
CREATE POLICY "Owners can update menu items"
  ON public.menu_items FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.foodtrucks
      WHERE foodtrucks.id = menu_items.foodtruck_id
      AND foodtrucks.owner_id = auth.uid()
    )
  );

-- Seul le propriétaire du foodtruck peut supprimer un menu item
DROP POLICY IF EXISTS "Owners can delete menu items" ON public.menu_items;
CREATE POLICY "Owners can delete menu items"
  ON public.menu_items FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.foodtrucks
      WHERE foodtrucks.id = menu_items.foodtruck_id
      AND foodtrucks.owner_id = auth.uid()
    )
  );

-- service_role : accès complet
DROP POLICY IF EXISTS "service_full_access_menu_items" ON public.menu_items;
CREATE POLICY "service_full_access_menu_items" ON public.menu_items
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- ==========================================================================
-- 4. USER_REPORTS (signalements)
-- ==========================================================================
ALTER TABLE public.user_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_reports FORCE ROW LEVEL SECURITY;

-- L'auteur du signalement peut lire ses propres signalements
DROP POLICY IF EXISTS "Reporters read own reports" ON public.user_reports;
CREATE POLICY "Reporters read own reports"
  ON public.user_reports FOR SELECT
  TO authenticated
  USING (auth.uid() = reporter_id);

-- Un utilisateur authentifié peut déposer un signalement
DROP POLICY IF EXISTS "Reporters can create reports" ON public.user_reports;
CREATE POLICY "Reporters can create reports"
  ON public.user_reports FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = reporter_id);

-- Pas d'UPDATE/DELETE pour les utilisateurs : la modération se fait
-- uniquement via service_role (équipe FoodTrack).
DROP POLICY IF EXISTS "service_full_access_user_reports" ON public.user_reports;
CREATE POLICY "service_full_access_user_reports" ON public.user_reports
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- ==========================================================================
-- 5. FEEDBACK (retours bug / suggestions)
-- ==========================================================================
ALTER TABLE public.feedback ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.feedback FORCE ROW LEVEL SECURITY;

-- L'auteur peut lire ses propres retours
DROP POLICY IF EXISTS "Users read own feedback" ON public.feedback;
CREATE POLICY "Users read own feedback"
  ON public.feedback FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Un utilisateur authentifié peut soumettre un retour
DROP POLICY IF EXISTS "Users can create feedback" ON public.feedback;
CREATE POLICY "Users can create feedback"
  ON public.feedback FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Pas d'UPDATE/DELETE pour les utilisateurs : la gestion des retours se fait
-- via service_role (équipe FoodTrack).
DROP POLICY IF EXISTS "service_full_access_feedback" ON public.feedback;
CREATE POLICY "service_full_access_feedback" ON public.feedback
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- ==========================================================================
-- 6. REVIEWS (notes & avis) — si la table existe (migration 20260713)
-- ==========================================================================
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews FORCE ROW LEVEL SECURITY;

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

-- service_role : accès complet (recalcul des notes, modération)
DROP POLICY IF EXISTS "service_full_access_reviews" ON public.reviews;
CREATE POLICY "service_full_access_reviews"
  ON public.reviews FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- ==========================================================================
-- 7. VÉRIFICATION
-- ==========================================================================
-- Affiche l'état RLS de chaque table applicative pour confirmer que tout est
-- activé (rowsecurity = on). spatial_ref_sys reste volontairement sans RLS :
-- c'est le catalogue interne de PostGIS (faux positif du lint).
SELECT
  schemaname,
  tablename,
  rowsecurity,
  forcerowsecurity AS force_rls
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN (
    'profiles', 'foodtrucks', 'menu_items',
    'user_reports', 'feedback', 'reviews'
  )
ORDER BY tablename;

