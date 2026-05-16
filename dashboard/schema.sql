-- ══════════════════════════════════════════════════════════════
-- KEI SERVICES CRM — SUPABASE SQL SCHEMA
-- Paste this entire file into Supabase → SQL Editor → Run
-- ══════════════════════════════════════════════════════════════

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ── TABLE: quote_requests ─────────────────────────────────────
-- Public users submit here. Owners read/update via dashboard.
CREATE TABLE IF NOT EXISTS quote_requests (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name         TEXT NOT NULL,
  phone        TEXT NOT NULL,
  email        TEXT,
  address      TEXT NOT NULL,
  service_type TEXT NOT NULL,
  message      TEXT,
  images       TEXT[],           -- Array of Supabase Storage URLs
  status       TEXT NOT NULL DEFAULT 'pending'
               CHECK (status IN ('pending','quoted','approved','completed','rejected')),
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── TABLE: customers ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS customers (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name       TEXT NOT NULL,
  phone      TEXT NOT NULL,
  email      TEXT,
  address    TEXT,
  notes      TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── TABLE: jobs ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS jobs (
  id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  customer_id    UUID REFERENCES customers(id) ON DELETE SET NULL,
  quote_id       UUID REFERENCES quote_requests(id) ON DELETE SET NULL,
  customer_name  TEXT NOT NULL,    -- Denormalized for easy display
  service_type   TEXT NOT NULL,
  scheduled_date DATE,
  status         TEXT NOT NULL DEFAULT 'scheduled'
                 CHECK (status IN ('scheduled','in_progress','completed')),
  price          NUMERIC(10,2) DEFAULT 0,
  notes          TEXT,
  images         TEXT[],
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── TABLE: payments ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS payments (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  job_id        UUID REFERENCES jobs(id) ON DELETE CASCADE,
  customer_name TEXT NOT NULL,
  service_type  TEXT NOT NULL,
  amount        NUMERIC(10,2) NOT NULL DEFAULT 0,
  status        TEXT NOT NULL DEFAULT 'unpaid'
                CHECK (status IN ('paid','unpaid')),
  method        TEXT CHECK (method IN ('cash','e-transfer') OR method IS NULL),
  paid_at       TIMESTAMPTZ,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── ROW LEVEL SECURITY ────────────────────────────────────────

-- quote_requests: public can INSERT, authenticated can do everything
ALTER TABLE quote_requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "public_can_insert_quotes" ON quote_requests
  FOR INSERT TO anon WITH CHECK (true);

CREATE POLICY "owners_can_manage_quotes" ON quote_requests
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- All other tables: authenticated only
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
CREATE POLICY "owners_manage_customers" ON customers
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "owners_manage_jobs" ON jobs
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "owners_manage_payments" ON payments
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- ── STORAGE BUCKET ────────────────────────────────────────────
-- Run this in Supabase dashboard → Storage → New bucket:
--   Name: job-images
--   Public: false (private, signed URLs for viewing)
--   Max file size: 10MB
--   Allowed MIME types: image/jpeg, image/png, image/webp
--
-- Then add these storage policies in Storage → Policies:
--   1. Allow anon to INSERT into job-images (for quote form uploads)
--   2. Allow authenticated to SELECT/INSERT/DELETE (for dashboard)

-- ── USEFUL VIEWS (optional) ───────────────────────────────────

-- Revenue summary by service type
CREATE OR REPLACE VIEW revenue_by_service AS
SELECT
  service_type,
  COUNT(*) as job_count,
  SUM(CASE WHEN status='paid' THEN amount ELSE 0 END) as collected,
  SUM(CASE WHEN status='unpaid' THEN amount ELSE 0 END) as outstanding,
  SUM(amount) as total
FROM payments
GROUP BY service_type
ORDER BY total DESC;

-- Pending quotes dashboard view
CREATE OR REPLACE VIEW pending_quotes AS
SELECT * FROM quote_requests
WHERE status = 'pending'
ORDER BY created_at DESC;

-- ── AUTH USERS ────────────────────────────────────────────────
-- Create your 2 owner accounts in:
-- Supabase Dashboard → Authentication → Users → Invite user
-- Enter each owner email. They will receive a magic link to set password.
-- No code changes needed — Supabase handles auth automatically.

-- ══════════════════════════════════════════════════════════════
-- DONE. After running this, go to SETUP.md for next steps.
-- ══════════════════════════════════════════════════════════════
