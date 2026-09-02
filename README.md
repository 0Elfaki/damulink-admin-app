# 🩸 DamuLink Admin

**The command center behind every drop.**

DamuLink Admin is the organization dashboard for the DamuLink blood donation platform. Organizers run campaigns, lab staff log results, admins manage the whole operation, and health staff register donors who show up without a smartphone in hand. All from one dashboard, all backed by the same live Supabase data as the donor app.

## Who It's For

DamuLink Admin isn't one app, it's four, gated by role:

| Role | What they see |
|---|---|
| **Admin** | Everything: dashboard, campaigns, blood requests, lab reports, users |
| **Organizer** | Campaigns, blood requests, lab reports, users |
| **Lab** | Campaigns, blood requests, lab reports, users |
| **Health Staff** | Register Donor, Donors, KPIs, a focused workspace, nothing else |

Donor accounts are rejected at login and pointed to the DamuLink app instead. This dashboard is for the people running the blood supply, not donating to it.

## Features

- **Live dashboard**, donors, donations, campaigns, blood requests, lab reports, rewards, badges, and points in circulation, updated in real time
- **Campaign management**, launch new campaigns, close or reopen existing ones, track participation against a goal
- **Blood request triage**, see every open request across the platform and mark it fulfilled or cancelled
- **Lab reports**, search for a donor and log blood type confirmation, hemoglobin level, and screening notes
- **User management**, search accounts and change anyone's role from a dropdown, changes are verified server side, not just in the UI
- **Health Staff and donor registration**, register a donor who doesn't have a smartphone on the spot. They get an auto-generated donor ID and are instantly part of the system, no login account required
- **Unified donor list**, every donor, app-registered and staff-registered alike, in one searchable list with a green or red eligibility indicator based on days since last donation and health status
- **Donation logging**, staff can log each return visit for a walk-in donor, building a full donation history over time
- **Staff KPIs**, total donors, eligible versus not-eligible split, registrations today, this week, and this month, and donations logged

## Tech Stack

- **Flutter** (Dart), builds for Android, iOS, and web
- **Supabase**, Postgres, auth, row level security, and Postgres functions for anything that needs to run with elevated trust
- **fl_chart** for the dashboard's charts and KPI visualizations

## Getting Started

This repo ships `lib/` and `pubspec.yaml` only, no platform folders. Scaffold them first:

```bash
flutter create --platforms=android,web,ios damulink_admin
```

Then copy `lib/` and `pubspec.yaml` from this repo into the new project, overwriting the defaults. Full setup, including database configuration and the Health Staff migration, is in [`SETUP.md`](SETUP.md).

```bash
flutter pub get
flutter run -d chrome   # or just `flutter run` for Android
```

## The Bigger Picture

This dashboard shares its Supabase backend with the donor-facing app: [**DamuLink**](https://github.com/0Elfaki/damulink). Every donor, donation, and campaign here is the same data donors see on their phones.

## Security

Role changes and staff-only data (like KPI aggregates and other donors' donation history) are enforced by Postgres functions and row level security policies, not by hiding buttons in the UI. A donor account that reaches the login screen is signed out before it ever sees the dashboard.
