-- ========================================
-- INSERT ADMIN USER
-- ========================================
-- This script creates an admin user in the database
-- Run this in Supabase SQL Editor
-- ========================================

-- Insert admin user
DO $$
DECLARE
  admin_id UUID;
  admin_email TEXT := 'rasheduliriyad@gmail.com';
BEGIN
  -- First, check if ID already exists in public.users
  SELECT id INTO admin_id FROM auth.users WHERE email = admin_email;

  IF admin_id IS NOT NULL THEN
    -- User exists in auth.users with this email, check if in public.users
    IF EXISTS (SELECT 1 FROM public.users WHERE id = admin_id) THEN
      RAISE NOTICE 'User exists in both tables. Updating role to admin...';
      UPDATE public.users SET role = 'admin' WHERE id = admin_id;
      RAISE NOTICE 'Role updated.';
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

  INSERT INTO public.users (id, email, full_name, role, created_at, updated_at)
  VALUES (admin_id, admin_email, 'Rashedul Riyad', 'admin', NOW(), NOW());

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



