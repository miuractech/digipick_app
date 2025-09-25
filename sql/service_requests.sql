-- Service Requests Table
-- This table stores all service requests made by users for their devices

CREATE TABLE public.service_requests (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  ticket_no text NOT NULL, -- Format: YYYY-MM-DD-OOOO-DDDD-NNNN
  product text NOT NULL, -- Product name from devices table
  serial_no text NOT NULL, -- Serial number from devices table (device_id)
  service_type text NOT NULL CHECK (service_type IN ('demo_installation', 'repair', 'service', 'calibration')),
  service_details text NOT NULL, -- Detailed description of the service request
  organization_id uuid NOT NULL, -- Reference to company_details.id
  device_id uuid NOT NULL, -- Reference to devices.id
  user_id uuid NOT NULL, -- User ID who requested the service
  date_of_request timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  date_of_service timestamp with time zone NULL, -- Preferred service date
  uploaded_reference text NULL, -- Type of uploaded file: 'video', 'image', 'pdf', etc.
  uploaded_file_url text NULL, -- URL/path to the uploaded file
  mode_of_service text NULL, -- 'on-site', 'remote', etc.
  service_engineer text NULL, -- Service engineer ID or name
  engineer_comments text NULL, -- Comments from the service engineer
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'cancelled')),
  payment_details text NULL, -- Payment information
  created_at timestamp with time zone NULL DEFAULT timezone('utc'::text, now()),
  updated_at timestamp with time zone NULL DEFAULT timezone('utc'::text, now()),
  
  CONSTRAINT service_requests_pkey PRIMARY KEY (id),
  CONSTRAINT service_requests_ticket_no_key UNIQUE (ticket_no),
  CONSTRAINT service_requests_organization_id_fkey FOREIGN KEY (organization_id) 
    REFERENCES company_details (id) ON DELETE CASCADE,
  CONSTRAINT service_requests_device_id_fkey FOREIGN KEY (device_id) 
    REFERENCES devices (id) ON DELETE CASCADE
) TABLESPACE pg_default;

-- Indexes for better performance
CREATE INDEX IF NOT EXISTS idx_service_requests_ticket_no 
  ON public.service_requests USING btree (ticket_no) TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS idx_service_requests_organization_id 
  ON public.service_requests USING btree (organization_id) TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS idx_service_requests_device_id 
  ON public.service_requests USING btree (device_id) TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS idx_service_requests_user_id 
  ON public.service_requests USING btree (user_id) TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS idx_service_requests_status 
  ON public.service_requests USING btree (status) TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS idx_service_requests_service_type 
  ON public.service_requests USING btree (service_type) TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS idx_service_requests_date_of_request 
  ON public.service_requests USING btree (date_of_request) TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS idx_service_requests_date_of_service 
  ON public.service_requests USING btree (date_of_service) TABLESPACE pg_default;

-- Function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_service_requests_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger to automatically update the updated_at field
CREATE TRIGGER trigger_update_service_requests_updated_at 
  BEFORE UPDATE ON service_requests 
  FOR EACH ROW 
  EXECUTE FUNCTION update_service_requests_updated_at();

-- Function to generate ticket number
CREATE OR REPLACE FUNCTION generate_ticket_number(org_id uuid, dev_id uuid)
RETURNS text AS $$
DECLARE
    date_str text;
    org_code text;
    dev_code text;
    seq_number text;
    ticket_count integer;
BEGIN
    -- Format current date as YYYY-MM-DD
    date_str := to_char(now(), 'YYYY-MM-DD');
    
    -- Get organization code (first 4 chars of UUID without hyphens)
    org_code := UPPER(LEFT(REPLACE(org_id::text, '-', ''), 4));
    
    -- Get device code (first 4 chars of UUID without hyphens)
    dev_code := UPPER(LEFT(REPLACE(dev_id::text, '-', ''), 4));
    
    -- Get count of tickets for today to generate sequential number
    SELECT COUNT(*) + 1 INTO ticket_count
    FROM service_requests 
    WHERE DATE(date_of_request) = CURRENT_DATE;
    
    -- Format sequential number as 4-digit string
    seq_number := LPAD(ticket_count::text, 4, '0');
    
    -- Return formatted ticket number
    RETURN date_str || '-' || org_code || '-' || dev_code || '-' || seq_number;
END;
$$ LANGUAGE plpgsql;

-- Sample data for testing (optional)
-- INSERT INTO service_requests (
--     ticket_no, product, serial_no, service_type, service_details,
--     organization_id, device_id, user_id, date_of_service, mode_of_service, status
-- ) VALUES (
--     '2024-01-15-ABC1-DEF2-0001',
--     'Device Monitor X1',
--     'DM001X',
--     'service',
--     'Regular maintenance and calibration required',
--     (SELECT id FROM company_details LIMIT 1),
--     (SELECT id FROM devices LIMIT 1),
--     auth.uid(),
--     '2024-01-20 10:00:00+00',
--     'on-site',
--     'pending'
-- );
