# BillBuddy

BillBuddy is a bill payment, recharge, and autopay application.

## Project Structure

```text
BillBuddy/
├── frontend/    # Flutter application
├── backend/     # Node.js backend
├── README.md
└── .gitignore
```

## Features

* Biller directory
* Saved billers
* Bill fetching
* Bill payments
* Mobile recharge
* Autopay
* Payment reminders
* Payment receipts
* Payment history

## Tech Stack

### Frontend

* Flutter
* Riverpod
* go_router
* Dio

### Backend

* Node.js
* TypeScript
* PostgreSQL

## Development

### Frontend

```bash
cd frontend
flutter pub get
flutter run
```

### Backend

```bash
cd backend
npm install
npm run dev
```

## Branching

Features are developed using feature branches.

```text
feature/auth
feature/billers
feature/my-billers
feature/bills
feature/payments
feature/recharge
feature/autopay
```

Each feature branch contains the required frontend and backend work for that feature.

## Security

BillBuddy is designed with security as a core requirement. Authentication, authorization, secure token storage, server-side validation, payment idempotency, and other security controls are implemented as part of the relevant features.

## Testing

Tests are maintained alongside the frontend and backend features.

## Status

Under active development.
