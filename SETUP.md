# DamuLink Admin — Setup

This folder contains the `lib/` source and `pubspec.yaml` for the admin/
organization dashboard. It shares the same Supabase backend as the donor
app, so no new database setup is needed — the migration that adds
role-based staff access was already applied to your project.

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

Only accounts with `role` set to `organizer`, `lab`, or `admin` in the
`profiles` table can sign in here — donor accounts are rejected with a
message telling them to use the DamuLink app instead.

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
  (donor/organizer/lab/admin) via a dropdown.

## Security notes

- Role changes go through a Postgres function (`admin_update_user_role`)
  that verifies the caller is an admin server-side — not just a client-side
  check, so it can't be bypassed by editing the app.
- Non-staff (donor) accounts are actively signed out if they somehow reach
  the login screen and authenticate — they're never shown the dashboard.
- If you demote yourself away from `admin`, the app warns you first since
  you'd lose dashboard access immediately.
