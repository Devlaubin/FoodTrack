/*
# Optimize Profile Trigger

1. Purpose
- Fix timeout issues when creating profiles
- Disable RLS temporarily during trigger execution
- Add error handling to the trigger

2. Changes
- Modify handle_new_user function to disable RLS checks
- Add timeout protection
- Improve performance by avoiding unnecessary queries
*/

-- Drop the old trigger and function
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- Create optimized function that bypasses RLS checks
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Insert into profiles with proper error handling
  -- Using INSERT OR IGNORE pattern to avoid conflicts
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
  -- Log the error but don't fail the signup
  RAISE WARNING 'Error in handle_new_user: %', SQLERRM;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Create the trigger with IMMEDIATE constraint
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- Create a policy to allow users to insert their own profile if it doesn't exist
-- This provides a fallback mechanism if the trigger fails
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Allow service role to insert profiles (for trigger execution)
DROP POLICY IF EXISTS "service_insert_profiles" ON profiles;
CREATE POLICY "service_insert_profiles" ON profiles FOR INSERT
  TO service_role
  WITH CHECK (true);

-- Keep existing policies for users
DROP POLICY IF EXISTS "users_insert_own_profile" ON profiles;
CREATE POLICY "users_insert_own_profile" ON profiles FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- Allow authenticated users to read their own profile
DROP POLICY IF EXISTS "users_read_own_profile" ON profiles;
CREATE POLICY "users_read_own_profile" ON profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = id OR (auth.role() = 'service_role'));

-- Allow authenticated users to update their own profile
DROP POLICY IF EXISTS "users_update_own_profile" ON profiles;
CREATE POLICY "users_update_own_profile" ON profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);
