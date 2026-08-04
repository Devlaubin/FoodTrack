/*
# Activer / Garantir la sécurité RLS sur toutes les tables FoodTrack

1. Purpose
- Garantit que ROW LEVEL SECURITY est activé sur toutes les tables publiques.
- Recrée toutes les policies de sécurité de façon idempotente (sûr à relancer).
- Ajoute les policies `service_role` nécessaires pour la modération et les triggers.
- Termine par une requête de vérification de l'état RLS.

2. Méthode d'application
- Option A (recommandée) : Dashboard Supabase → SQL Editor → coller → Run
- Option B (CLI) : définir SUPABASE_DB_PASSWORD puis `supabase db push`

3. Note
- Le script est idempotent : il peut être exécuté plusieurs fois sans erreur.
*/

-- ==========================================================================
-- 1. PROFILES
-- ==========================================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.profiles FORCE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "users_read_own_profile" ON public.profiles;
CREATE POLICY "users_read_own_profile" ON public.profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

DROP POLICY IF EXISTS "users_insert_own_profile" ON public.profiles;
CREATE POLICY "users_insert_own_profile" ON public.profiles FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "users_update_own_profile" ON public.profiles;
CREATE POLICY "users_update_own_profile" ON public.profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Le trigger handle_new_user() (SECURITY DEFINER) insère les profils :
-- policy explicite pour service_role en complément.
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

-- Tout le monde (anon + authenticated) peut voir les foodtrucks
DROP POLICY IF EXISTS "Anyone can view foodtrucks" ON public.foodtrucks;
CREATE POLICY "Anyone can view foodtrucks"
  ON public.foodtrucks FOR SELECT
  TO anon, authenticated
  USING (true);

-- Seuls les profils "pro" peuvent créer leur foodtruck
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

-- Tout le monde peut voir les menus
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
-- uniquement via service_role.
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
-- 6. VÉRIFICATION
-- ==========================================================================
-- Affiche l'état RLS de chaque table applicative pour confirmer que tout est
-- activé.
--
-- NOTE sur spatial_ref_sys (table interne PostGIS) :
-- Le lint Supabase "RLS Disabled in Public" signale cette table car elle vit
-- dans le schéma public. Ce n'est PAS une table applicative : c'est le
-- catalogue des systèmes de coordonnées géré par l'extension PostGIS.
-- On ne doit PAS y appliquer ALTER TABLE ... ENABLE ROW LEVEL SECURITY depuis
-- l'éditeur SQL, car le rôle n'est pas propriétaire de cette table
-- (erreur : "must be owner of table spatial_ref_sys"). Cet avertissement lint
-- est un faux positif connu pour les tables de catalogue PostGIS.
SELECT
  schemaname,
  tablename,
  rowsecurity,
  forcerowsecurity AS force_rls
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('profiles', 'foodtrucks', 'menu_items', 'user_reports', 'feedback')
ORDER BY tablename;

