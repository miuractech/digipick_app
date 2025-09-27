/*
 * MIGRATION: Organization Manager Auto-Assignment
 * 
 * Version: 1.0
 * Date: 2024-12-XX
 * 
 * Purpose:
 * - Enhances existing triggers to automatically assign manager roles when organizations are created
 * - Handles both existing and non-existing users via the user_tracking system
 * - Ensures organization email holders automatically become managers with full device access
 * 
 * What this migration does:
 * 1. Updates the sync_organization_user_role() function to use user_tracking for non-existing users
 * 2. Ensures proper cleanup when organization emails change or organizations are deleted
 * 3. Maintains backward compatibility with existing data
 * 
 * Requirements:
 * - user_role table must exist
 * - user_tracking table must exist (from user_tracking.sql)
 * - company_details table must exist
 * - users table must exist
 */

-- ============================================================================
-- BACKUP EXISTING FUNCTION (for rollback purposes)
-- ============================================================================

-- Store current function definition in a comment for rollback reference
/*
 * ROLLBACK INSTRUCTIONS:
 * If you need to rollback this migration, restore the original function:
 * 
 * CREATE OR REPLACE FUNCTION sync_organization_user_role()
 * RETURNS TRIGGER AS $$
 * DECLARE user_record RECORD;
 * BEGIN
 *   -- Original simpler logic here (check existing function before migration)
 * END;
 * $$ LANGUAGE plpgsql;
 */

-- ============================================================================
-- ENHANCED FUNCTION: Organization Manager Auto-Assignment
-- ============================================================================

CREATE OR REPLACE FUNCTION sync_organization_user_role()
RETURNS TRIGGER AS $$
DECLARE
  user_record RECORD;
BEGIN
  -- Handle INSERT: Add organization email as manager with full device access
  IF TG_OP = 'INSERT' AND NEW.email IS NOT NULL THEN
    -- Check if user exists with this email
    SELECT * INTO user_record FROM public.users WHERE email = NEW.email;
    
    IF FOUND THEN
      -- User exists: Insert user role as manager with "all" device access
      INSERT INTO public.user_role (user_id, organization_id, user_type, devices)
      VALUES (user_record.id, NEW.id, 'manager', '"all"'::jsonb)
      ON CONFLICT (user_id, organization_id) DO UPDATE SET
        user_type = EXCLUDED.user_type,
        devices = EXCLUDED.devices,
        updated_at = timezone('utc'::text, now());
        
      -- Log successful immediate assignment
      RAISE NOTICE 'Auto-assigned manager role to existing user: % for organization: %', NEW.email, NEW.name;
    ELSE
      -- User doesn't exist: Add to user_tracking so they become manager when they sign up
      INSERT INTO public.user_tracking (organization_id, email, user_type, devices, added_by)
      VALUES (NEW.id, NEW.email, 'manager', '"all"'::jsonb, null)
      ON CONFLICT (organization_id, email) DO UPDATE SET
        user_type = 'manager',
        devices = '"all"'::jsonb,
        updated_at = timezone('utc'::text, now());
        
      -- Log pending assignment
      RAISE NOTICE 'Tracked manager role for future user: % for organization: %', NEW.email, NEW.name;
    END IF;
  END IF;

  -- Handle UPDATE: Update user role if email changed
  IF TG_OP = 'UPDATE' THEN
    -- If email changed from one value to another
    IF OLD.email IS DISTINCT FROM NEW.email THEN
      
      -- Remove old email's manager role if it exists
      IF OLD.email IS NOT NULL THEN
        SELECT * INTO user_record FROM public.users WHERE email = OLD.email;
        IF FOUND THEN
          DELETE FROM public.user_role 
          WHERE user_id = user_record.id 
            AND organization_id = OLD.id 
            AND user_type = 'manager';
            
          RAISE NOTICE 'Removed manager role from old email: % for organization: %', OLD.email, OLD.name;
        END IF;
        
        -- Also remove from user_tracking (only system-created entries)
        DELETE FROM public.user_tracking
        WHERE organization_id = OLD.id 
          AND email = OLD.email 
          AND user_type = 'manager'
          AND added_by IS NULL; -- Only remove system-created entries
          
        RAISE NOTICE 'Removed tracking for old email: % for organization: %', OLD.email, OLD.name;
      END IF;
      
      -- Add new email's manager role with full device access
      IF NEW.email IS NOT NULL THEN
        SELECT * INTO user_record FROM public.users WHERE email = NEW.email;
        IF FOUND THEN
          -- User exists: Create user_role immediately
          INSERT INTO public.user_role (user_id, organization_id, user_type, devices)
          VALUES (user_record.id, NEW.id, 'manager', '"all"'::jsonb)
          ON CONFLICT (user_id, organization_id) DO UPDATE SET
            user_type = EXCLUDED.user_type,
            devices = EXCLUDED.devices,
            updated_at = timezone('utc'::text, now());
            
          RAISE NOTICE 'Auto-assigned manager role to new email: % for organization: %', NEW.email, NEW.name;
        ELSE
          -- User doesn't exist: Add to user_tracking for future signup
          INSERT INTO public.user_tracking (organization_id, email, user_type, devices, added_by)
          VALUES (NEW.id, NEW.email, 'manager', '"all"'::jsonb, null)
          ON CONFLICT (organization_id, email) DO UPDATE SET
            user_type = 'manager',
            devices = '"all"'::jsonb,
            updated_at = timezone('utc'::text, now());
            
          RAISE NOTICE 'Tracked manager role for new email: % for organization: %', NEW.email, NEW.name;
        END IF;
      END IF;
    END IF;
  END IF;

  -- Handle DELETE: Clean up user roles and tracking for this organization
  IF TG_OP = 'DELETE' THEN
    DELETE FROM public.user_role WHERE organization_id = OLD.id;
    DELETE FROM public.user_tracking WHERE organization_id = OLD.id;
    
    RAISE NOTICE 'Cleaned up all roles and tracking for deleted organization: %', OLD.name;
    RETURN OLD;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- ENSURE TRIGGER EXISTS (idempotent)
-- ============================================================================

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS sync_organization_user_role_trigger ON public.company_details;

-- Create the trigger
CREATE TRIGGER sync_organization_user_role_trigger
  AFTER INSERT OR UPDATE OR DELETE ON public.company_details
  FOR EACH ROW
  EXECUTE FUNCTION sync_organization_user_role();

-- ============================================================================
-- BACKFILL EXISTING DATA
-- ============================================================================

-- Process existing organizations that have emails but no manager assignments
DO $$
DECLARE
  org_record RECORD;
  user_record RECORD;
  processed_count INTEGER := 0;
  immediate_assignments INTEGER := 0;
  tracking_assignments INTEGER := 0;
BEGIN
  RAISE NOTICE 'Starting backfill of existing organization manager assignments...';
  
  -- Loop through all organizations with emails that don't have manager assignments
  FOR org_record IN 
    SELECT cd.id, cd.name, cd.email
    FROM public.company_details cd
    WHERE cd.email IS NOT NULL 
      AND cd.archived = FALSE
      AND NOT EXISTS (
        SELECT 1 FROM public.user_role ur 
        WHERE ur.organization_id = cd.id 
          AND ur.user_type = 'manager'
          AND ur.user_id IN (SELECT id FROM public.users WHERE email = cd.email)
      )
      AND NOT EXISTS (
        SELECT 1 FROM public.user_tracking ut
        WHERE ut.organization_id = cd.id
          AND ut.email = cd.email
          AND ut.user_type = 'manager'
          AND ut.added_by IS NULL
      )
  LOOP
    processed_count := processed_count + 1;
    
    -- Check if user exists with this email
    SELECT * INTO user_record FROM public.users WHERE email = org_record.email;
    
    IF FOUND THEN
      -- User exists: Create user_role entry immediately
      INSERT INTO public.user_role (user_id, organization_id, user_type, devices)
      VALUES (user_record.id, org_record.id, 'manager', '"all"'::jsonb)
      ON CONFLICT (user_id, organization_id) DO UPDATE SET
        user_type = EXCLUDED.user_type,
        devices = EXCLUDED.devices,
        updated_at = timezone('utc'::text, now());
        
      immediate_assignments := immediate_assignments + 1;
      RAISE NOTICE 'Backfilled immediate manager for: % (organization: %)', org_record.email, org_record.name;
    ELSE
      -- User doesn't exist: Add to user_tracking
      INSERT INTO public.user_tracking (organization_id, email, user_type, devices, added_by)
      VALUES (org_record.id, org_record.email, 'manager', '"all"'::jsonb, null)
      ON CONFLICT (organization_id, email) DO NOTHING;
      
      tracking_assignments := tracking_assignments + 1;
      RAISE NOTICE 'Backfilled tracking for: % (organization: %)', org_record.email, org_record.name;
    END IF;
  END LOOP;
  
  RAISE NOTICE 'Backfill completed: % organizations processed, % immediate assignments, % tracking assignments', 
               processed_count, immediate_assignments, tracking_assignments;
END;
$$;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Verify the migration was successful
DO $$
DECLARE
  total_orgs INTEGER;
  orgs_with_managers INTEGER;
  pending_managers INTEGER;
BEGIN
  -- Count total organizations with emails
  SELECT COUNT(*) INTO total_orgs 
  FROM public.company_details 
  WHERE email IS NOT NULL AND archived = FALSE;
  
  -- Count organizations with active managers
  SELECT COUNT(DISTINCT ur.organization_id) INTO orgs_with_managers
  FROM public.user_role ur
  JOIN public.company_details cd ON ur.organization_id = cd.id
  JOIN public.users u ON ur.user_id = u.id
  WHERE ur.user_type = 'manager' 
    AND u.email = cd.email
    AND cd.archived = FALSE;
  
  -- Count pending manager assignments
  SELECT COUNT(*) INTO pending_managers
  FROM public.user_tracking ut
  JOIN public.company_details cd ON ut.organization_id = cd.id
  WHERE ut.user_type = 'manager' 
    AND ut.added_by IS NULL
    AND cd.archived = FALSE
    AND ut.is_synced = FALSE;
  
  RAISE NOTICE 'Migration Verification:';
  RAISE NOTICE '- Total organizations with emails: %', total_orgs;
  RAISE NOTICE '- Organizations with active managers: %', orgs_with_managers;
  RAISE NOTICE '- Pending manager assignments: %', pending_managers;
  RAISE NOTICE '- Coverage: %% (%/%)', 
               ROUND((orgs_with_managers + pending_managers) * 100.0 / NULLIF(total_orgs, 0), 2),
               (orgs_with_managers + pending_managers), 
               total_orgs;
END;
$$;

-- ============================================================================
-- MIGRATION COMPLETION
-- ============================================================================

-- Mark migration as completed (you can track this in a migrations table if you have one)
-- INSERT INTO migrations (name, applied_at) VALUES ('organization_manager_auto_assignment', NOW());

RAISE NOTICE 'Migration completed successfully: Organization Manager Auto-Assignment v1.0';
RAISE NOTICE 'The system will now automatically assign manager roles when organizations are created or updated.';
