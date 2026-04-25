# 3yadati — Architecture

## Monorepo layout

```
apps/
├── doctor/    Flutter app for doctors and medical centers
├── patient/   Flutter app for patients (placeholder)
└── backend/   NestJS + Prisma + PostgreSQL API
```

## Doctor app (Flutter)

- **State**: `flutter_riverpod` providers (`overviewProvider`, `appointmentsProvider`, ...).
- **Routing**: `go_router` with a shell route for the bottom navigation.
- **HTTP**: `Dio` + token interceptor + secure storage for the JWT.
- **Theme**: Material 3 + `google_fonts` (Tajawal) + custom palette in `core/theme/app_colors.dart`.
- **Locale**: Arabic by default with full RTL via a top-level `Directionality(TextDirection.rtl)`.
- **Demo mode**: every repository falls back to `MockData` if the API is unreachable, so the UI remains usable without a backend.

## Backend (NestJS)

- **Modules**: `Auth`, `Doctors`, `Branches`, `WorkingHours`, `Appointments`, `Patients`, `Statistics`, `Notifications`.
- **Auth**: JWT (Passport) with Argon2-hashed passwords. Global `JwtAuthGuard` + opt-in `@Public()` decorator.
- **RBAC**: `RolesGuard` honoring `@Roles(...)` metadata for `DOCTOR / ASSISTANT / CENTER_MANAGER / PATIENT / ADMIN`.
- **Prisma**: a single shared schema covering both apps (doctor and patient).
- **Slot generation**: `SlotsService.generate({ doctorId, from, to, branchId })` reads `WorkingHour`, skips holidays and existing slots, and inserts `AVAILABLE` rows.
- **Statistics**: aggregated counts and revenue based on `consultationPrice * COMPLETED appointments`.

## Shared database

The PostgreSQL schema is shared between both apps. The `User` table carries a `role`, and the `Doctor` / `Patient` tables are 1-1 extensions. A `DoctorPatient` join table tracks which patients belong to each doctor (with a private note per relation).

## Future work

- Push notifications (FCM / APNs) — schema (`PushToken`, `Notification`) is already in place.
- WebSocket gateway for live updates between the doctor and patient apps.
- Google Maps integration for picking branch locations.
- Full English localization (`generate: true` + ARB files).
