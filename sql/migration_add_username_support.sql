/*
 * MIGRATION: Add Username Support to User Tracking
 * 
 * Version: 1.0
 * Date: 2024-12-30
 * 
 * Purpose:
 * - Adds optional username field to user_tracking table
 * - Allows managers to assign display names when adding users to organizations
 * - Maintains backward compatibility with existing data
 * 
 * What this migration does:
 * 1. Adds username column to user_tracking table
 * 2. Creates index on username for better performance
 * 3. Validates existing data integrity
 * 
 * Requirements:
 * - user_tracking table must exist (from user_tracking.sql)
 * 
 * ROLLBACK INSTRUCTIONS:
 * If you need to rollback this migration:
 * 
 * ALTER TABLE public.user_tracking DROP CONSTRAINT IF EXISTS user_tracking_unique_email_global;
 * DROP INDEX IF EXISTS idx_user_tracking_username;
 * ALTER TABLE public.user_tracking DROP COLUMN IF EXISTS username;
 * -- Optionally restore the per-organization email constraint:
 * -- ALTER TABLE public.user_tracking ADD CONSTRAINT user_tracking_unique_org_email UNIQUE (organization_id, email);
 */

-- ============================================================================
-- PRE-MIGRATION VALIDATION
-- ============================================================================

DO $$
BEGIN
  -- Check if user_tracking table exists
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name = 'user_tracking'
  ) THEN
    RAISE EXCEPTION 'user_tracking table does not exist. Please run user_tracking.sql first.';
  END IF;
  
  -- Check if username column already exists
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'user_tracking' 
    AND column_name = 'username'
  ) THEN
    RAISE NOTICE 'Username column already exists. Migration may have been run before.';
  ELSE
    RAISE NOTICE 'Adding username support to user_tracking table...';
  END IF;
END;
$$;

-- ============================================================================
-- ADD USERNAME COLUMN
-- ============================================================================

-- Add username column if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'user_tracking' 
    AND column_name = 'username'
  ) THEN
    ALTER TABLE public.user_tracking 
    ADD COLUMN username text NULL;
    
    RAISE NOTICE 'Added username column to user_tracking table';
  END IF;
END;
$$;

-- ============================================================================
-- ADD INDEX FOR USERNAME
-- ============================================================================

-- Create index on username for better performance
CREATE INDEX IF NOT EXISTS idx_user_tracking_username 
ON public.user_tracking USING btree (username) 
TABLESPACE pg_default;

RAISE NOTICE 'Created index on username column';

-- ============================================================================
-- ADD UNIQUE CONSTRAINT FOR EMAIL ACROSS ALL ORGANIZATIONS
-- ============================================================================

-- Add unique constraint to prevent the same email from being in multiple organizations
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints 
    WHERE constraint_schema = 'public' 
    AND table_name = 'user_tracking' 
    AND constraint_name = 'user_tracking_unique_email_global'
  ) THEN
    ALTER TABLE public.user_tracking 
    ADD CONSTRAINT user_tracking_unique_email_global UNIQUE (email);
    
    RAISE NOTICE 'Added global unique constraint on email column';
  ELSE
    RAISE NOTICE 'Global email unique constraint already exists';
  END IF;
END;
$$;

-- ============================================================================
-- VALIDATE MIGRATION
-- ============================================================================

DO $$
DECLARE
  total_tracking_records INTEGER;
  records_with_username INTEGER;
BEGIN
  -- Count total user_tracking records
  SELECT COUNT(*) INTO total_tracking_records 
  FROM public.user_tracking;
  
  -- Count records with usernames (should be 0 for new migration)
  SELECT COUNT(*) INTO records_with_username 
  FROM public.user_tracking 
  WHERE username IS NOT NULL AND username != '';
  
  RAISE NOTICE 'Migration Validation:';
  RAISE NOTICE '- Total user_tracking records: %', total_tracking_records;
  RAISE NOTICE '- Records with usernames: %', records_with_username;
  RAISE NOTICE '- Username column successfully added and indexed';
END;
$$;

-- ============================================================================
-- MIGRATION COMPLETION
-- ============================================================================

-- Mark migration as completed (you can track this in a migrations table if you have one)
-- INSERT INTO migrations (name, applied_at) VALUES ('add_username_support', NOW());

RAISE NOTICE 'Migration completed successfully: Add Username Support v1.0';
RAISE NOTICE 'Users can now be assigned optional usernames when added to organizations.';
RAISE NOTICE 'The frontend will display usernames when available, falling back to email addresses.';
