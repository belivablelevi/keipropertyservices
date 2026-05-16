# Kei Services CRM — Setup Guide

## What You Have

```
kei-services/
├── index.html          ← Homepage (unchanged)
├── services.html       ← Services page (unchanged)
├── about.html          ← About page (unchanged)
├── portfolio.html      ← Portfolio / before-after (unchanged)
├── reviews.html        ← Reviews coming soon page (unchanged)
├── contact.html        ← Quote form — Formspree REMOVED → Supabase
├── styles.css          ← Shared stylesheet (unchanged)
├── dashboard.html      ← Full CRM dashboard (NEW)
└── dashboard/
    ├── schema.sql      ← Supabase database schema (run once)
    └── SETUP.md        ← This file
```

---

## Step 1 — Create Your Supabase Project (5 min)

1. Go to **supabase.com** → Sign up free
2. Click **New Project**
3. Name it: `kei-services`
4. Region: **Canada (East)** — closest to Ottawa
5. Set a database password (save it somewhere)
6. Wait ~2 minutes for it to spin up

---

## Step 2 — Run the SQL Schema (2 min)

1. In your Supabase project → **SQL Editor** (left sidebar)
2. Click **New query**
3. Open `dashboard/schema.sql` from this folder
4. Paste the entire contents into the editor
5. Click **Run** (green button)
6. You should see: `Success. No rows returned.`

This creates 4 tables: `quote_requests`, `customers`, `jobs`, `payments`

---

## Step 3 — Create the Storage Bucket (2 min)

1. Supabase → **Storage** (left sidebar)
2. Click **New bucket**
3. Name: `job-images`
4. Toggle **Public bucket**: OFF (keep private)
5. Click **Save**
6. Go to **Policies** tab → Add policy:
   - Table: `objects`
   - Operation: `INSERT`
   - Role: `anon`
   - Policy: `true` (allows anyone to upload quote photos)

---

## Step 4 — Get Your API Keys (1 min)

1. Supabase → **Settings** (gear icon) → **API**
2. Copy two values:
   - **Project URL** (looks like `https://abcdefgh.supabase.co`)
   - **anon / public key** (long string starting with `eyJ...`)

---

## Step 5 — Connect the Quote Form (2 min)

Open `contact.html` and find these two lines near the top of the `<script>` tag:

```javascript
var SUPABASE_URL  = 'YOUR_SUPABASE_URL';
var SUPABASE_ANON = 'YOUR_SUPABASE_ANON_KEY';
```

Replace with your actual values:

```javascript
var SUPABASE_URL  = 'https://abcdefgh.supabase.co';
var SUPABASE_ANON = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

Save the file. The form now submits directly to your database.

---

## Step 6 — Connect the Dashboard (2 min)

Open `dashboard.html` and find these two lines:

```javascript
var SUPABASE_URL  = '';
var SUPABASE_ANON = '';
```

Paste the same values:

```javascript
var SUPABASE_URL  = 'https://abcdefgh.supabase.co';
var SUPABASE_ANON = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

---

## Step 7 — Create Owner Accounts (3 min)

### Option A — Supabase Dashboard (quick)
1. Supabase → **Authentication** → **Users**
2. Click **Invite user**
3. Enter owner email (e.g. `keipropertyservices@gmail.com`)
4. Repeat for second owner
5. Each owner gets an email to set their password

### Option B — Keep the demo login
The dashboard works in **demo mode** with localStorage by default:
- Email: `owner@kei.com`
- Password: `kei2025`

To change demo credentials, open `dashboard.html` and find:
```javascript
var OWNERS = [
  { email: 'owner@kei.com', password: 'kei2025', name: 'Owner' },
];
```
Update the email and password to whatever you want.

To use real Supabase Auth instead, find the `doLogin()` function and
follow the comment inside it to swap in `supabase.auth.signInWithPassword()`.

---

## Step 8 — Deploy to Vercel (5 min)

1. Push this entire `kei-services/` folder to a **GitHub repo**
2. Go to **vercel.com** → Add New Project → Import from GitHub
3. Set **Root Directory** to `kei-services`
4. Framework Preset: **Other** (static HTML)
5. Click **Deploy**
6. Add your custom domain (`keiservices.ca`) in Project → Domains

---

## How the System Works

```
Customer fills contact.html form
        ↓
Supabase: quote_requests table (status = pending)
        ↓
dashboard.html shows it under Quotes tab (badge count)
        ↓
You review, call customer, update status → "quoted"
        ↓
Customer approves → status "approved"
        ↓
Click "Convert → Job" → creates a job + payment record
        ↓
Job day: advance status (scheduled → in_progress → completed)
        ↓
Payment tab: click "Mark Paid" → choose cash or e-transfer
        ↓
Revenue tracked on dashboard
```

---

## Dashboard Access

The dashboard is at: `yourdomain.com/dashboard.html`

Keep this URL to yourself. The page requires login.
There is no public link to it anywhere on the site.

---

## Offline Mode

If Supabase is not configured, the dashboard works 100% with
**localStorage**. All data persists in the browser between sessions.
This is perfect for testing before Supabase is set up.

---

## What Was Removed

- ❌ Formspree (completely gone from contact.html)
- ❌ Email-based quote handling
- ❌ Any third-party form services

## What Was Added

- ✅ quote form → Supabase direct insert
- ✅ File upload → Supabase Storage
- ✅ Full CRM dashboard (dashboard.html)
- ✅ Quote management with status tracking
- ✅ Customer records
- ✅ Job tracking (scheduled → in progress → completed)
- ✅ Payment tracking (unpaid → paid, cash or e-transfer)
- ✅ Dashboard stats (revenue, pending quotes, etc.)
- ✅ Works in demo mode (localStorage) before Supabase setup
- ✅ Mobile responsive

---

*Kei Services CRM — Built for two students building something real.*
