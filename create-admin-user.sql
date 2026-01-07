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
  auth_user_exists BOOLEAN;
  public_user_exists BOOLEAN;
BEGIN
  -- Check if user exists in both tables
  SELECT EXISTS(SELECT 1 FROM auth.users WHERE email = admin_email) INTO auth_user_exists;
  SELECT EXISTS(SELECT 1 FROM auth.users WHERE email = admin_email) INTO admin_id;
  SELECT EXISTS(SELECT 1 FROM public.users WHERE email = admin_email) INTO public_user_exists;

  IF public_user_exists THEN
    RAISE NOTICE 'Admin user already exists in public.users. Checking role...';
    
    -- Get the user's current role
    DECLARE current_role TEXT;
    BEGIN
      SELECT role INTO current_role FROM public.users WHERE email = admin_email;
      
      IF current_role = 'admin' THEN
        RAISE NOTICE 'User already has admin role.';
      ELSE
        UPDATE public.users SET role = 'admin' WHERE email = admin_email;
        RAISE NOTICE 'Role updated to admin.';
      END IF;
    END;
    
    SELECT id INTO admin_id FROM public.users WHERE email = admin_email;
    RAISE NOTICE 'Email: %', admin_email;
    RAISE NOTICE 'User ID: %', admin_id;
    RETURN;
  END IF;

  -- User doesn't exist in public.users, proceed with creation
  IF auth_user_exists THEN
    RAISE NOTICE 'User exists in auth.users but not in public.users. Linking...';
    SELECT id INTO admin_id FROM auth.users WHERE email = admin_email;
  ELSE
    RAISE NOTICE 'Creating new admin user...';
    admin_id := gen_random_uuid();

    -- Insert into auth.users
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
  END IF;

  -- Insert into public.users
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



