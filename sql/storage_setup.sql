-- Storage Setup for Service Request Files
-- This file contains the SQL commands to set up Supabase Storage for service request file uploads
-- 
-- IMPORTANT: This script requires elevated privileges. Run this using one of the following methods:
-- 1. Supabase Dashboard -> SQL Editor (Recommended)
-- 2. Use service_role key instead of anon key when connecting
-- 3. Run as database owner/superuser

-- 1. Create the storage bucket for service files
INSERT INTO storage.buckets (id, name, public, allowed_mime_types, file_size_limit)
VALUES (
  'service-files',
  'service-files',
  true, -- Make bucket public for easy access
  ARRAY[
    'image/jpeg',
    'image/jpg', 
    'image/png',
    'image/gif',
    'image/webp',
    'video/mp4',
    'video/avi',
    'video/mov',
    'video/wmv',
    'video/flv',
    'video/webm',
    'application/pdf',
    'text/plain',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
  ],
  52428800 -- 50MB file size limit
);

-- 2. Set up Row Level Security (RLS) policies for the storage bucket

-- Policy 1: Allow authenticated users to upload files
CREATE POLICY "Allow authenticated uploads to service-files"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'service-files');

-- Policy 2: Allow authenticated users to view files
CREATE POLICY "Allow authenticated users to view service-files"
ON storage.objects
FOR SELECT
TO authenticated
USING (bucket_id = 'service-files');

-- Policy 3: Allow users to delete their own uploaded files
-- Note: You might want to restrict this to only allow deletion by service engineers or admins
CREATE POLICY "Allow users to delete their service-files"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'service-files' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Policy 4: Allow updates to file metadata (optional)
CREATE POLICY "Allow authenticated users to update service-files metadata"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'service-files')
WITH CHECK (bucket_id = 'service-files');

-- 3. Enable RLS on the storage.objects table (should already be enabled by default)
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- 4. Create a function to clean up old files (optional - for maintenance)
CREATE OR REPLACE FUNCTION cleanup_old_service_files()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Delete files older than 2 years from storage
  DELETE FROM storage.objects 
  WHERE bucket_id = 'service-files' 
    AND created_at < NOW() - INTERVAL '2 years';
END;
$$;

-- 5. Create a scheduled job to run cleanup (optional)
-- Note: This requires the pg_cron extension to be enabled
-- SELECT cron.schedule('cleanup-old-service-files', '0 2 * * 0', 'SELECT cleanup_old_service_files();');

-- 6. Grant necessary permissions to the service role (if needed)
-- These are typically set up automatically by Supabase, but including for completeness
GRANT SELECT, INSERT, UPDATE, DELETE ON storage.objects TO service_role;
GRANT USAGE ON SCHEMA storage TO service_role;

-- 7. Create a view for easier file management (optional)
CREATE VIEW service_request_files AS
SELECT 
  sr.id as service_request_id,
  sr.ticket_no,
  sr.uploaded_file_url,
  sr.uploaded_reference,
  so.name as file_path,
  so.metadata,
  so.created_at as uploaded_at,
  so.updated_at as file_updated_at
FROM service_requests sr
LEFT JOIN storage.objects so ON sr.uploaded_file_url LIKE '%' || so.name
WHERE so.bucket_id = 'service-files' OR so.bucket_id IS NULL;

-- 8. Create indexes for better performance on storage queries
CREATE INDEX IF NOT EXISTS idx_storage_objects_bucket_created 
ON storage.objects (bucket_id, created_at);

CREATE INDEX IF NOT EXISTS idx_storage_objects_bucket_name 
ON storage.objects (bucket_id, name);

-- 9. Create a function to get file statistics
CREATE OR REPLACE FUNCTION get_service_files_stats()
RETURNS TABLE (
  total_files bigint,
  total_size_bytes bigint,
  avg_file_size_bytes numeric,
  oldest_file timestamp with time zone,
  newest_file timestamp with time zone
)
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT 
    COUNT(*) as total_files,
    SUM((metadata->>'size')::bigint) as total_size_bytes,
    AVG((metadata->>'size')::bigint) as avg_file_size_bytes,
    MIN(created_at) as oldest_file,
    MAX(created_at) as newest_file
  FROM storage.objects 
  WHERE bucket_id = 'service-files';
$$;

-- 10. Sample query to check storage setup
-- SELECT * FROM storage.buckets WHERE id = 'service-files';
-- SELECT * FROM get_service_files_stats();
