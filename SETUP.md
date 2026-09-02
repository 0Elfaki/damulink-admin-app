# DamuLink Admin — Setup

This folder contains the `lib/` source and `pubspec.yaml` for the admin/
organization dashboard. It shares the same Supabase backend as the donor
app, so no new database setup is needed — the migration that adds
role-based staff access was already applied to your project.

**Health Staff feature**: to enable donor registration for staff who
sign up donors without a smartphone, run `damulink/supabase/staff_side.sql`
(in the donor app repo, since it's the shared backend) in the Supabase
SQL editor. See that file's header comment — one block near the
bottom replaces `admin_update_user_role()`, so read the note there first.

## 1. Scaffold the project

This zip only has `lib/` and `pubspec.yaml` — no `android/`/`web`/`ios`
platform folders (those need the Flutter SDK to generate correctly, which
isn't available in the environment I built this in). Create them locally:

```bash
flutter create --platforms=android,web,ios damulink_admin
```

Then copy `lib/` and `pubspec.yaml` from this zip into that new
`damulink_admin` folder, overwriting the defaults.

## 2. Install dependencies

```bash
cd damulink_admin
flutter pub get
```

## 3. Run it

```bash
# Web
flutter run -d chrome

# Android (device/emulator connected)
flutter run
```

## 4. Who can log in

Only accounts with `role` set to `organizer`, `lab`, `admin`, or
`health_staff` in the `profiles` table can sign in here — donor accounts
are rejected with a message telling them to use the DamuLink app instead.
Promote an existing account to any of these from the Users tab (admin
only). `health_staff` accounts only see Register Donor / Donors / KPIs —
not Campaigns, Blood Requests, Lab Reports, or Users.

Your account (`Thomas Okiria`) has already been promoted to `admin` so you
can log in immediately and start promoting other staff accounts from the
Users tab.

## 5. Deploying the web version

Same process as the donor app:

```bash
flutter build web --release --no-tree-shake-icons
cd build
Compress-Archive -Path web\* -DestinationPath damulink-admin-web.zip -Force
```

Then drag that zip onto Netlify (or wherever you're hosting it) — use a
**different site** from the donor app, since this is a separate deployment
with separate access.

## What's built

- **Dashboard** — live KPIs (donors, donations, campaigns, blood requests,
  lab reports, rewards, badges, points in circulation) plus a status
  breakdown chart.
- **Campaigns** — create new campaigns, close/reopen existing ones.
- **Blood Requests** — view all requests across all users, mark
  fulfilled/cancelled.
- **Lab Reports** — search for a donor, log blood type confirmation,
  hemoglobin level, and screening notes.
- **Users** — search all accounts, change anyone's role
  (donor/organizer/lab/admin/health_staff) via a dropdown.
- **Register Donor** (`health_staff`) — register a donor who doesn't
  have a smartphone; they get an auto-generated Donor ID (`DL-000123`)
  on the spot. No login account is created for them.
- **Donors** (`health_staff`) — every donor, app-registered and
  staff-registered, in one searchable list with a green/red eligibility
  indicator (56 days since last donation, plus a manual eligible/deferred
  toggle for health reasons). Tapping a donor opens their full profile,
  donation history, and a "log donation" action for staff-registered
  donors.
- **Staff KPIs** (`health_staff`) — total donors (app + staff-registered),
  eligible vs. not eligible split, registrations today/this week/this
  month, donations logged.

## Security notes

- Role changes go through a Postgres function (`admin_update_user_role`)
  that verifies the caller is an admin server-side — not just a client-side
  check, so it can't be bypassed by editing the app.
- Non-staff (donor) accounts are actively signed out if they somehow reach
  the login screen and authenticate — they're never shown the dashboard.
- If you demote yourself away from `admin`, the app warns you first since
  you'd lose dashboard access immediately.
