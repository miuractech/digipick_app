-- Storage Setup for Profile Pictures
-- Created: $(date)
-- Purpose: Create storage bucket and policies for company profile pictures

-- Create the company-assets storage bucket if it doesn't exist
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'company-assets',
  'company-assets',
  true,  -- Public bucket for easy access to profile pictures
  5242880,  -- 5MB file size limit
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']  -- Only allow image files
)
ON CONFLICT (id) DO NOTHING;

-- Create RLS policies for the company-assets bucket

-- Policy 1: Allow authenticated users to upload profile pictures for their organization
CREATE POLICY "Allow authenticated users to upload company assets" ON storage.objects
FOR INSERT TO authenticated
WITH CHECK (
  bucket_id = 'company-assets' 
  AND (storage.foldername(name))[1] = 'profile-pictures'
  AND auth.uid() IS NOT NULL
);

-- Policy 2: Allow public read access to all company assets
CREATE POLICY "Allow public read access to company assets" ON storage.objects
FOR SELECT TO public
USING (bucket_id = 'company-assets');

-- Policy 3: Allow authenticated users to update/delete their organization's profile pictures
CREATE POLICY "Allow authenticated users to manage their company profile pictures" ON storage.objects
FOR UPDATE TO authenticated
USING (
  bucket_id = 'company-assets' 
  AND (storage.foldername(name))[1] = 'profile-pictures'
  AND auth.uid() IS NOT NULL
);

-- Policy 4: Allow authenticated users to delete their organization's profile pictures
CREATE POLICY "Allow authenticated users to delete their company profile pictures" ON storage.objects
FOR DELETE TO authenticated
USING (
  bucket_id = 'company-assets' 
  AND (storage.foldername(name))[1] = 'profile-pictures'
  AND auth.uid() IS NOT NULL
);

-- Enable RLS on storage.objects if not already enabled
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;
