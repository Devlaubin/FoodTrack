-- Migration: Create `foodtrucks` table compatible with Supabase + PostGIS

-- Required extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS postgis;

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
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Add a geometry column in a PostGIS-friendly way (AddGeometryColumn is deprecated in some setups)
ALTER TABLE public.foodtrucks
  ADD COLUMN IF NOT EXISTS location geometry(Point,4326);

-- Trigger function to update `location` from latitude/longitude
CREATE OR REPLACE FUNCTION public.update_foodtruck_location()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.latitude IS NOT NULL AND NEW.longitude IS NOT NULL THEN
    NEW.location := ST_SetSRID(ST_MakePoint(NEW.longitude::double precision, NEW.latitude::double precision), 4326);
  ELSE
    NEW.location := NULL;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_location ON public.foodtrucks;
CREATE TRIGGER trigger_update_location
  BEFORE INSERT OR UPDATE ON public.foodtrucks
  FOR EACH ROW
  EXECUTE FUNCTION public.update_foodtruck_location();

-- Indexes
CREATE INDEX IF NOT EXISTS idx_foodtrucks_location ON public.foodtrucks USING GIST (location);
CREATE INDEX IF NOT EXISTS idx_foodtrucks_cuisine_type ON public.foodtrucks (cuisine_type);
CREATE INDEX IF NOT EXISTS idx_foodtrucks_is_open ON public.foodtrucks (is_open);

-- Enable RLS
ALTER TABLE public.foodtrucks ENABLE ROW LEVEL SECURITY;

-- Policies
DROP POLICY IF EXISTS "Anyone can view foodtrucks" ON public.foodtrucks;
CREATE POLICY "Anyone can view foodtrucks"
  ON public.foodtrucks FOR SELECT
  TO anon, authenticated
  USING (true);

DROP POLICY IF EXISTS "Pro users can create foodtrucks" ON public.foodtrucks;
CREATE POLICY "Pro users can create foodtrucks"
  ON public.foodtrucks FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = owner_id);

DROP POLICY IF EXISTS "Owners can update foodtrucks" ON public.foodtrucks;
CREATE POLICY "Owners can update foodtrucks"
  ON public.foodtrucks FOR UPDATE
  TO authenticated
  USING (auth.uid() = owner_id)
  WITH CHECK (auth.uid() = owner_id);

DROP POLICY IF EXISTS "Owners can delete foodtrucks" ON public.foodtrucks;
CREATE POLICY "Owners can delete foodtrucks"
  ON public.foodtrucks FOR DELETE
  TO authenticated
  USING (auth.uid() = owner_id);

-- Trigger to auto-update updated_at
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
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();