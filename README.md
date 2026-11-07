# Campus Incident Reporter

A Flutter mobile app that lets ALU students report campus issues (water, electricity, facilities, safety, sanitation) and lets authorized staff review reports and update their status.

**Demo video:** [PASTE LINK] | **Report:** [see submission]

## Features

- Email/password sign-up restricted to ALU email addresses, with email verification
- Student and staff roles with server-enforced access control
- Submit reports with category, title, description, location, urgency, optional photo, and an anonymous option
- Browse, search, and filter reports (status, category, mine/all)
- Report details with a status timeline and staff notes
- Staff-only status updates with notes

## Tech stack

Flutter, Provider (state management), Firebase Authentication, Cloud Firestore, Cloudinary (photo hosting).

## Architecture

`screens -> providers -> services -> Firebase`. Screens never call Firebase directly.

```
lib/
  core/        theme, constants, validators, helpers, filtering
  models/      AppUser, Incident, StatusUpdate
  services/    AuthService, IncidentService, StorageService
  providers/   AuthProvider, IncidentProvider
  screens/     auth, home, incident, profile, shell
  widgets/     reusable components
```

## Firestore data model

- `users/{uid}`: name, email, role (`student` | `staff`), createdAt
- `incidents/{id}`: title, description, category, location, urgency, status, isAnonymous, reporterId, reporterName (omitted when anonymous), imageUrl, createdAt, updatedAt, history[] (status, note, by, at)

Security rules are in [`firestore.rules`](firestore.rules).

## Run it

1. Install Flutter and an Android emulator or device.
2. `git clone` this repo and run `flutter pub get`.
3. Create your own Firebase project, enable Email/Password auth and Firestore, then run `flutterfire configure` to generate `lib/firebase_options.dart`.
4. Publish `firestore.rules` in the Firebase Console.
5. Edit `lib/core/cloud_config.dart` with your Cloudinary cloud name and an unsigned upload preset.
6. `flutter run`

## Staff accounts

Everyone registers as a student. To create a staff account, register and verify it, then change `role` to `staff` in the `users` document in the Firebase Console.

## Tests

`flutter test` runs unit tests (validators, models, filtering) and a widget test.

## Limitations

- Staff roles are assigned manually in the Console
- Cloudinary uses an unsigned preset (fine for coursework, not for production)
- No push notifications
