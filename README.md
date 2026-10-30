# Campus Fix — Campus Incident Reporting App

A Flutter app for ALU students to report campus issues (facilities, water,
electricity, furniture, sanitation, safety) and for campus staff to triage
them and update their status until they are resolved.

**Stack:** Flutter · Riverpod 3 · go_router · Firebase Auth · Cloud Firestore · Firebase Storage

## Features

| Students | Staff |
| --- | --- |
| Register/login with an ALU email; email verification is required | Everything students can do |
| Report an incident: category, title, description, location, optional photo | Campus-wide dashboard with a "needs triage" shortcut |
| Edit or withdraw a report while it is still *Submitted* | Move reports through Submitted → In Progress → Resolved / Rejected |
| Browse **My reports** or the **Campus** feed (to spot duplicates) | Add a note to every status change (shown to the reporter) |
| Search plus status and category filters | Delete spam or duplicate reports |
| Live status timeline and activity log | |

## Architecture

Feature-first folders, each split into the same four layers:

```
lib/
├── main.dart / app.dart          # bootstrap + MaterialApp.router
├── core/                         # shared, feature-agnostic code
│   ├── config/app_config.dart    # business constants (domains, limits, paths)
│   ├── theme/                    # design tokens: colours, text styles, spacing, ThemeData
│   ├── navigation/               # route names, GoRouter + auth guard, bottom-nav shell
│   ├── providers/                # Firebase SDK providers, ActionController base
│   ├── errors/                   # AppException + Firebase error translation
│   ├── utils/                    # validators, formatters, snackbar/dialog helpers
│   └── widgets/                  # reusable UI (AppCard, PrimaryButton, AsyncValueView…)
└── features/
    ├── auth/      { domain · data · application · presentation }
    ├── incidents/ { domain · data · application · presentation }
    ├── home/      presentation
    └── profile/   presentation
```

| Layer | Responsibility | Depends on |
| --- | --- | --- |
| `domain` | Plain models + enums (`Incident`, `IncidentStatus`, `IncidentFilter`) | nothing |
| `data` | Repositories: the **only** code that calls Firebase | domain |
| `application` | Riverpod providers (streams, derived state) and controllers (actions) | data, domain |
| `presentation` | Screens and widgets. They only `watch` and `read` providers | application, domain |

### State management (Riverpod)

- **`StreamProvider`s** wrap Firestore snapshots (`allIncidentsProvider`,
  `myIncidentsProvider`, `incidentByIdProvider`). A staff status change
  appears on every screen that shows that report, without manual refreshes.
- **Derived `Provider`s** compose state: `filteredIncidentsProvider` =
  scope + search + filters applied to the live stream; `dashboardStatsProvider`
  counts by status.
- **`Notifier`s** hold UI state (`IncidentFilterNotifier`) and run actions
  (`AuthController`, `IncidentActions`). They extend one `ActionController` base,
  so loading and error handling is written once. Screens show a spinner from
  `isLoading` and a snackbar via `ref.listenForErrors(...)`.
- `setState` is used only for local, ephemeral widget state, such as password
  visibility or the photo picked in the form.

### Navigation

`go_router` with a single `redirect` guard driven by the auth stream:
no session → `/login`, unverified → `/verify-email`, verified → app.
Bottom navigation uses `StatefulShellRoute.indexedStack`, so each tab keeps
its scroll position.

## Firebase data model

```
users/{uid}
  fullName, email, role: "student" | "staff", createdAt

incidents/{incidentId}
  title, description, location
  category: facilities | water | electricity | furniture | sanitation | safety | other
  status:   submitted | inProgress | resolved | rejected
  reporterId, reporterName
  photoUrl?, photoPath?          # Storage: incident_photos/{uid}/{incidentId}.jpg
  createdAt, updatedAt           # server timestamps
  history: [{ status, changedAt, changedBy, note? }]   # audit trail
```

## Access control

These rules are enforced server-side in [firestore.rules](firestore.rules) and
[storage.rules](storage.rules). Hiding buttons in the UI is not the security
boundary.

- Every read and write requires a signed-in account with a **verified**
  `@alustudent.com` / `@alueducation.com` email.
- Users can only create their own profile, and only with `role: "student"`.
  Nobody can change their own role.
- Only `staff` can change `status`. A status update may modify only
  `status`, `updatedAt` and `history`, and must append exactly one history entry.
- Reporters can edit or delete only their own report, and only while it is `submitted`.
- Photos: users can write only into their own folder, only images, under 5 MB.

## Setup

1. **Create the Firebase project** (Blaze plan is required for Storage):
   ```bash
   firebase projects:create campus-fix-<yourname>
   ```
2. In the Firebase console, enable **Authentication → Email/Password**,
   **Firestore Database** and **Storage**.
3. Connect the app (this overwrites `lib/firebase_options.dart`):
   ```bash
   dart pub global activate flutterfire_cli
   ~/.pub-cache/bin/flutterfire configure --project=campus-fix-<yourname>
   ```
4. Deploy the security rules:
   ```bash
   firebase use campus-fix-<yourname>
   firebase deploy --only firestore:rules,storage
   ```
5. Run: `flutter pub get && flutter run`

### Creating a staff account

Register normally, verify the email, then in **Firestore →
`users/{uid}`** change `role` from `student` to `staff`. The app switches to
the staff experience live, with no re-login needed.

## Testing

```bash
flutter test
```

- **Unit:** validators (ALU domain, password policy), formatters, filter
  logic, status workflow transitions, model parsing.
- **Repository:** `IncidentRepository` against `fake_cloud_firestore`
  (create, edit, status update + audit trail, per-reporter queries, delete).
- **Manual (on device):** auth flows, photo upload, and rules rejections
  (e.g. a student attempting a status update).
