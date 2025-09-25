# 📁 Service Request File Storage Setup

## Overview
The service request system uses **Supabase Storage** to handle file uploads (images, videos, documents) that users attach to their service requests.

## 🏗️ Storage Architecture

### **Storage Location**
- **Platform**: Supabase Storage (S3-compatible)
- **Bucket**: `service-files`
- **Path Structure**: `service_requests/{timestamp}_{filename}`
- **URL Storage**: File URLs are stored in the `service_requests.uploaded_file_url` database field

### **Example File Paths**
```
service_requests/1672531200000_device_photo.jpg
service_requests/1672531300000_error_screenshot.png
service_requests/1672531400000_service_manual.pdf
```

## 🔧 Setup Instructions

### **1. Database Setup**
First, run the service requests table creation:
```sql
-- Run this first
\i sql/service_requests.sql
```

### **2. Storage Bucket Setup**

**❌ IMPORTANT: Cannot use SQL for bucket creation in Supabase!**

**✅ Use Supabase Dashboard instead:**

1. **Go to Storage → Buckets** in your Supabase Dashboard
2. **Click "New bucket"**
3. **Configure the bucket:**
   - **Name:** `service-files`
   - **Public:** ✅ Yes (checked)
   - **File size limit:** `52428800` (50MB)
   - **Allowed MIME types:** `image/*`, `video/*`, `application/pdf`, `text/plain`
4. **Click "Save"**

Then run the helper functions:
```sql
-- Run this to create helper functions and views
\i sql/storage_setup_corrected.sql
```

### **3. Supabase Dashboard Configuration**
1. Go to **Storage** section in Supabase Dashboard
2. Verify the `service-files` bucket exists
3. Check bucket settings:
   - **Public**: Yes (for easy file access)
   - **File size limit**: 50MB
   - **Allowed file types**: Images, Videos, PDFs, Documents

## 📋 Supported File Types

### **Images**
- JPEG (`.jpg`, `.jpeg`)
- PNG (`.png`)
- GIF (`.gif`)
- WebP (`.webp`)

### **Videos**
- MP4 (`.mp4`)
- AVI (`.avi`)
- MOV (`.mov`)
- WMV (`.wmv`)
- FLV (`.flv`)
- WebM (`.webm`)

### **Documents**
- PDF (`.pdf`)
- Text files (`.txt`)
- Word documents (`.doc`, `.docx`)

## 🔐 Security & Permissions

### **Row Level Security (RLS)**
The storage bucket has RLS policies that:
- ✅ Allow **authenticated users** to upload files
- ✅ Allow **authenticated users** to view files
- ✅ Allow **users** to delete their own files
- ✅ Prevent **unauthorized access**

### **File Size Limits**
- **Maximum file size**: 50MB per file
- **Recommended size**: Under 10MB for optimal performance

## 💾 Database Integration

### **File Reference Storage**
When a file is uploaded, two fields are populated in the `service_requests` table:

```sql
uploaded_file_url    -- Full public URL to the file
uploaded_reference   -- File type: 'image', 'video', 'pdf', 'file'
```

### **Example Database Record**
```json
{
  "ticket_no": "2024-01-15-ABC1-DEF2-0001",
  "uploaded_file_url": "https://your-project.supabase.co/storage/v1/object/public/service-files/service_requests/1672531200000_device_photo.jpg",
  "uploaded_reference": "image"
}
```

## 🔄 File Upload Flow

1. **User selects file** in the service request form
2. **File validation** checks type and size
3. **Upload to Supabase Storage** with unique filename
4. **URL returned** and stored in database
5. **Service request created** with file reference

## 🛠️ Maintenance Features

### **File Cleanup**
The setup includes an optional cleanup function:
```sql
-- Clean up files older than 2 years
SELECT cleanup_old_service_files();
```

### **Storage Statistics**
Check storage usage:
```sql
-- Get file statistics
SELECT * FROM get_service_files_stats();
```

### **File Management View**
Query files with service request context:
```sql
-- View all files with service request details
SELECT * FROM service_request_files;
```

## 🚨 Troubleshooting

### **Upload Fails**
1. Check file size (must be under 50MB)
2. Verify file type is in allowed list
3. Ensure user is authenticated
4. Check storage bucket exists and is public

### **File Not Accessible**
1. Verify RLS policies are active
2. Check bucket is set to public
3. Ensure URL is correctly stored in database

### **Performance Issues**
1. Optimize image sizes before upload
2. Use WebP format for better compression
3. Consider implementing client-side image compression

## 📊 Monitoring

### **Storage Usage Query**
```sql
SELECT 
  COUNT(*) as total_files,
  SUM((metadata->>'size')::bigint) / 1024 / 1024 as total_size_mb
FROM storage.objects 
WHERE bucket_id = 'service-files';
```

### **Recent Uploads**
```sql
SELECT name, created_at, (metadata->>'size')::bigint as size_bytes
FROM storage.objects 
WHERE bucket_id = 'service-files'
ORDER BY created_at DESC 
LIMIT 10;
```

## 🔗 Related Files

- `sql/service_requests.sql` - Main service requests table
- `sql/storage_setup.sql` - Storage bucket and policies setup
- `lib/services/service_request_service.dart` - File upload service
- `lib/screens/service_request_screen.dart` - File upload UI

---

**Note**: Make sure to run both SQL files in order for the complete setup to work properly!
