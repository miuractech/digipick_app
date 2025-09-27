
/*
 * ORGANIZATION MANAGER AUTO-ASSIGNMENT FLOW EXAMPLES
 * 
 * This file demonstrates how the enhanced trigger system automatically
 * handles manager role assignment when organizations are created,
 * regardless of whether the user exists yet or not.
 */

-- ============================================================================
-- SCENARIO 1: Creating organization with existing user email
-- ============================================================================

-- Step 1: Assume user already exists
-- INSERT INTO users (id, email) VALUES ('user-123', 'john@company.com');

-- Step 2: Create organization with existing user's email
INSERT INTO company_details (id, name, email) 
VALUES ('org-456', 'Acme Corp', 'john@company.com');

-- RESULT: Trigger automatically creates:
-- user_role: (user_id: 'user-123', organization_id: 'org-456', user_type: 'manager', devices: "all")

-- ============================================================================
-- SCENARIO 2: Creating organization with non-existing user email  
-- ============================================================================

-- Step 1: Create organization with non-existing user's email
INSERT INTO company_details (id, name, email) 
VALUES ('org-789', 'Beta Inc', 'jane@betainc.com');

-- RESULT: Trigger automatically creates:
-- user_tracking: (organization_id: 'org-789', email: 'jane@betainc.com', user_type: 'manager', devices: "all", added_by: null)

-- Step 2: Later, when jane@betainc.com signs up
-- INSERT INTO users (id, email) VALUES ('user-456', 'jane@betainc.com');

-- RESULT: User registration trigger automatically creates:
-- user_role: (user_id: 'user-456', organization_id: 'org-789', user_type: 'manager', devices: "all")
-- AND updates user_tracking: (is_synced: true, user_id: 'user-456')

-- ============================================================================
-- SCENARIO 3: Changing organization email
-- ============================================================================

-- Step 1: Organization exists with old email
-- company_details: (id: 'org-456', email: 'john@company.com')

-- Step 2: Change organization email
UPDATE company_details 
SET email = 'john.doe@newcompany.com' 
WHERE id = 'org-456';

-- RESULT: Trigger automatically:
-- 1. Removes old manager role for 'john@company.com'
-- 2. Removes old user_tracking entry for 'john@company.com' (if exists)
-- 3. If 'john.doe@newcompany.com' exists: creates new manager role
-- 4. If 'john.doe@newcompany.com' doesn't exist: creates user_tracking entry

-- ============================================================================
-- SCENARIO 4: Deleting organization
-- ============================================================================

-- Step 1: Delete organization
DELETE FROM company_details WHERE id = 'org-456';

-- RESULT: Trigger automatically:
-- 1. Deletes all user_role entries for this organization
-- 2. Deletes all user_tracking entries for this organization

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Check current user roles
SELECT 
    ur.user_type,
    ur.devices,
    u.email as user_email,
    cd.name as organization_name
FROM user_role ur
JOIN users u ON ur.user_id = u.id
JOIN company_details cd ON ur.organization_id = cd.id
WHERE ur.user_type = 'manager';

-- Check pending manager assignments in user_tracking
SELECT 
    ut.email,
    ut.user_type,
    ut.devices,
    ut.is_synced,
    cd.name as organization_name
FROM user_tracking ut
JOIN company_details cd ON ut.organization_id = cd.id
WHERE ut.user_type = 'manager' AND ut.added_by IS NULL;

-- Check complete manager assignment status
WITH organization_managers AS (
    -- Existing managers (synced)
    SELECT 
        cd.id as org_id,
        cd.name as org_name,
        cd.email as org_email,
        u.email as manager_email,
        'active' as status,
        ur.created_at as assigned_at
    FROM company_details cd
    LEFT JOIN users u ON u.email = cd.email
    LEFT JOIN user_role ur ON ur.user_id = u.id AND ur.organization_id = cd.id AND ur.user_type = 'manager'
    WHERE cd.email IS NOT NULL AND u.id IS NOT NULL
    
    UNION ALL
    
    -- Pending managers (in tracking)
    SELECT 
        cd.id as org_id,
        cd.name as org_name,
        cd.email as org_email,
        ut.email as manager_email,
        'pending' as status,
        ut.created_at as assigned_at
    FROM company_details cd
    JOIN user_tracking ut ON ut.organization_id = cd.id AND ut.user_type = 'manager' AND ut.added_by IS NULL
    WHERE cd.email IS NOT NULL
)
SELECT * FROM organization_managers
ORDER BY org_name, status;
