-- ========================================
-- INSERT ADMIN USER
-- ========================================
-- This script creates an admin user in the database
-- Run this in Supabase SQL Editor
-- ========================================

-- First, add INSERT policy for the trigger if not exists
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'users' AND policyname = 'Users can insert their own profile'
  ) THEN
    CREATE POLICY "Users can insert their own profile" ON public.users
      FOR INSERT WITH CHECK (auth.uid() = id);
    RAISE NOTICE 'INSERT policy created for users table.';
  ELSE
    RAISE NOTICE 'INSERT policy already exists for users table.';
  END IF;
END $$;

-- Insert admin user
DO $$
DECLARE
  admin_id UUID;
  admin_email TEXT := 'rasheduliriyad@gmail.com';
BEGIN
  -- First, get ID from auth.users if user exists with this email
  SELECT id INTO admin_id FROM auth.users WHERE email = admin_email;

  IF admin_id IS NOT NULL THEN
    -- User exists in auth.users with this email
    -- Check if ID exists in public.users (regardless of email)
    IF EXISTS (SELECT 1 FROM public.users WHERE id = admin_id) THEN
      RAISE NOTICE 'User exists in both tables. Checking role...';
      UPDATE public.users SET role = 'admin' WHERE id = admin_id;
      RAISE NOTICE 'Role updated to admin.';
    ELSE
      RAISE NOTICE 'Linking auth user to public.users...';
      INSERT INTO public.users (id, email, full_name, role, created_at, updated_at)
      VALUES (admin_id, admin_email, 'Rashedul Riyad', 'admin', NOW(), NOW());
    END IF;
    
    RAISE NOTICE 'Email: %', admin_email;
    RAISE NOTICE 'User ID: %', admin_id;
    RETURN;
  END IF;

  -- User doesn't exist anywhere, create new
  RAISE NOTICE 'Creating new admin user...';
  admin_id := gen_random_uuid();

  INSERT INTO auth.users (
    id, instance_id, aud, role, email, encrypted_password,
    email_confirmed_at, invited_at, created_at, updated_at,
    last_sign_in_at, raw_app_meta_data, raw_user_meta_data
  ) VALUES (
    admin_id, '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', admin_email, '',
    NOW(), NOW(), NOW(), NOW(), NOW(),
    '{"provider": "email"}',
    '{"full_name": "Rashedul Riyad", "role": "admin"}'
  );

  -- Use ON CONFLICT to handle case where ID already exists
  INSERT INTO public.users (id, email, full_name, role, created_at, updated_at)
  VALUES (admin_id, admin_email, 'Rashedul Riyad', 'admin', NOW(), NOW())
  ON CONFLICT (id) DO UPDATE SET role = 'admin', updated_at = NOW();

  RAISE NOTICE '=====================================================';
  RAISE NOTICE 'ADMIN USER CREATED SUCCESSFULLY';
  RAISE NOTICE '=====================================================';
  RAISE NOTICE 'Email: %', admin_email;
  RAISE NOTICE 'User ID: %', admin_id;
  RAISE NOTICE 'Role: admin';
  RAISE NOTICE '=====================================================';
  RAISE NOTICE 'IMPORTANT: Password was not set.';
  RAISE NOTICE 'Run the UPDATE PASSWORD section below to set password.';

END $$;

-- ========================================
-- UPDATE PASSWORD FOR ADMIN USER
-- ========================================
-- After running the above script, run this to set a password
-- Replace 'YOUR_PASSWORD' with your actual password
-- ========================================

UPDATE auth.users
SET encrypted_password = crypt('YOUR_PASSWORD', gen_salt('bf'))
WHERE id = (
  SELECT id FROM auth.users WHERE email = 'rasheduliriyad@gmail.com'
);



