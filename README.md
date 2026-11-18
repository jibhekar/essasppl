# ESS — Employee Self Service

A Flutter starter application for employee self-service, using Riverpod for state management, Firebase Authentication and Cloud Firestore, and an authenticated REST API client.

## Included

- Firebase email/password sign-in and account creation
- Employee dashboard with Firestore-backed employee name
- Leave request form that submits to a REST API
- REST client that attaches the Firebase ID token as a Bearer token
- Home, profile, and payslip navigation placeholders

## Setup

1. Install Flutter and create/configure the Firebase project.
2. From the project root, run `flutterfire configure` (or install the native Firebase configuration files for Android/iOS and initialize Firebase with your generated `firebase_options.dart` for web).
3. Enable **Email/Password** in Firebase Authentication.
4. Create an `employees/{firebaseUid}` Firestore document, for example:

   ```json
   { "name": "Jordan Lee", "email": "jordan@example.com", "department": "People" }
   ```

5. Install dependencies and run the app:

   ```sh
   flutter pub get
   flutter run --dart-define=API_BASE_URL=https://your-api.example.com/api/v1
   ```

   The default API URL is `http://10.0.2.2:3000/api/v1` for the Android emulator. Use your machine's LAN address for a physical device. HTTPS is recommended outside local development.

## REST contract

The app currently calls:

- `POST /leave-requests` with `{ "startDate": "YYYY-MM-DD", "endDate": "YYYY-MM-DD", "reason": "..." }`

Requests include `Authorization: Bearer <Firebase ID token>` when a user is signed in. The backend must verify the Firebase token and authorize access to employee data; never trust a UID or employee ID supplied by the mobile client. Add the contract and endpoint paths needed for attendance, payslips, and announcements to `lib/core/api_client.dart` and the relevant Riverpod providers.

## Firebase security

Configure Firestore Security Rules so employees can read only their own profile and only authorized roles can update sensitive fields. Do not commit Firebase service-account credentials or production secrets. This repository does not include Firebase project configuration or a backend implementation.
