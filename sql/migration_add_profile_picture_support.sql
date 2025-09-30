-- Migration: Add profile picture support to company_details table
-- Created: $(date)
-- Purpose: Add profile_picture_url column to store company profile pictures

-- Add profile_picture_url column to company_details table
ALTER TABLE public.company_details 
ADD COLUMN IF NOT EXISTS profile_picture_url text NULL;

-- Add index for profile_picture_url column for better query performance
CREATE INDEX IF NOT EXISTS idx_company_details_profile_picture_url 
ON public.company_details USING btree (profile_picture_url) 
TABLESPACE pg_default;

-- Add comment to explain the column
COMMENT ON COLUMN public.company_details.profile_picture_url IS 'URL of the company profile picture stored in Supabase storage';

-- Update the updated_at trigger to ensure profile picture changes are tracked
-- (The trigger should already exist from the original table creation)
