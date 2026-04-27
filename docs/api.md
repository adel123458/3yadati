# 3yadati API

Base URL: `/api/v1`

All endpoints (except those marked `Public`) require `Authorization: Bearer <token>`.

## Auth

| Method | Path | Public | Body |
|---|---|---|---|
| POST | `/auth/register` | ✅ | `{ email, password, fullName, phone?, role?, isCenter?, centerName?, specialtyId? }` |
| POST | `/auth/login` | ✅ | `{ email, password }` |
| GET  | `/auth/me` |  |  |

Login / register return `{ accessToken, user }`.

## Doctors

| Method | Path | Notes |
|---|---|---|
| GET | `/doctors/specialties` | Public |
| GET | `/doctors/me` | Current doctor profile |
| PATCH | `/doctors/me` | Update profile |
| GET | `/doctors/:id` | Public profile |

## Branches

`GET / POST / PATCH / DELETE /branches[/:id]` — full CRUD scoped to the current doctor.

## Working hours & holidays

- `GET / POST / PATCH / DELETE /working-hours[/:id]`
- `GET / POST / DELETE /holidays[/:id]`

## Appointments

- `GET /appointments?from=&to=&status=&branchId=`
- `POST /appointments`
- `GET /appointments/:id`
- `PATCH /appointments/:id`
- `PATCH /appointments/:id/status` — `{ status, cancelledReason? }`
- `PATCH /appointments/:id/reschedule` — `{ startAt, endAt }`
- `DELETE /appointments/:id`
- `POST /appointments/generate-slots` — `{ from, to, branchId? }`

Statuses: `AVAILABLE / PENDING / CONFIRMED / COMPLETED / CANCELLED / NO_SHOW / CLOSED`.

## Patients

- `GET /patients?q=`
- `POST /patients`
- `GET /patients/:id`
- `PATCH /patients/:id`

## Statistics

- `GET /statistics/overview` → today counts + revenue + upcoming + patient totals.
- `GET /statistics/weekly` → array of `{ date, count }` for the last 7 days.
- `GET /statistics/status-breakdown` → `[ { status, count } ]`.

## Notifications

- `GET /notifications`
- `GET /notifications/unread-count`
- `PATCH /notifications/read-all`
- `PATCH /notifications/:id/read`

A live Swagger UI is served at `/docs`.
