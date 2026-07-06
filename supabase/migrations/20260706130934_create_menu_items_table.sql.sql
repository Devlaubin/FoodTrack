/*
# Create menu_items table

1. New Tables
- `menu_items`
  - id (uuid, primary key)
  - foodtruck_id (uuid, references foodtrucks, cascade delete)
  - name (text, not null)
  - description (text)
  - price (decimal, not null)
  - category (text, e.g., "entree", "plat", "dessert", "boisson")
  - is_available (boolean, default true)
  - image_url (text, optional)
  - created_at (timestamp)
  - updated_at (timestamp)

2. Security
- Enable RLS on `menu_items`.
- SELECT: Anyone can view menu items.
- INSERT/UPDATE/DELETE: Only the owner of the foodtruck can modify menu items.

3. Notes
- Items are linked to foodtrucks via foreign key.
- Cascade delete: if a foodtruck is deleted, its menu items are also deleted.
- Category allows grouping items in the UI.
*/

CREATE TABLE IF NOT EXISTS menu_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  foodtruck_id uuid NOT NULL REFERENCES foodtrucks(id) ON DELETE CASCADE,
  name text NOT NULL,
  description text,
  price dec(10, 2) NOT NULL,
  category text DEFAULT 'plat',
  is_available boolean NOT NULL DEFAULT true,
  image_url text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_menu_items_foodtruck_id ON menu_items (foodtruck_id);
CREATE INDEX IF NOT EXISTS idx_menu_items_category ON menu_items (category);
CREATE INDEX IF NOT EXISTS idx_menu_items_is_available ON menu_items (is_available);

-- Enable RLS
ALTER TABLE menu_items ENABLE ROW LEVEL SECURITY;

-- Anyone can view menu items
DROP POLICY IF EXISTS "Anyone can view menu items" ON menu_items;
CREATE POLICY "Anyone can view menu items"
  ON menu_items FOR SELECT
  TO anon, authenticated
  USING (true);

-- Only owner of the foodtruck can insert menu items
DROP POLICY IF EXISTS "Owners can insert menu items" ON menu_items;
CREATE POLICY "Owners can insert menu items"
  ON menu_items FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM foodtrucks
      WHERE foodtrucks.id = menu_items.foodtruck_id
      AND foodtrucks.owner_id = auth.uid()
    )
  );

-- Only owner of the foodtruck can update menu items
DROP POLICY IF EXISTS "Owners can update menu items" ON menu_items;
CREATE POLICY "Owners can update menu items"
  ON menu_items FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM foodtrucks
      WHERE foodtrucks.id = menu_items.foodtruck_id
      AND foodtrucks.owner_id = auth.uid()
    )
  );

-- Only owner of the foodtruck can delete menu items
DROP POLICY IF EXISTS "Owners can delete menu items" ON menu_items;
CREATE POLICY "Owners can delete menu items"
  ON menu_items FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM foodtrucks
      WHERE foodtrucks.id = menu_items.foodtruck_id
      AND foodtrucks.owner_id = auth.uid()
    )
  );

-- Trigger to auto-update updated_at
DROP TRIGGER IF EXISTS trigger_menu_items_updated_at ON menu_items;
CREATE TRIGGER trigger_menu_items_updated_at
  BEFORE UPDATE ON menu_items
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();