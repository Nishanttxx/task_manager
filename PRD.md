Set up FlutterFire correctly in this Flutter project and implement Firebase integration for a Task Manager App.

Requirements:
- Use FlutterFire (correct official Firebase setup for Flutter)
- Use Firebase Authentication
- Use Cloud Firestore
- Use REST API integration
- Ensure users do NOT need to manually enter any API key
- Implement secure access using Firebase Authentication + Firestore Security Rules
- Prefer Anonymous Authentication for instant app usage, but structure code so Email/Password auth can also be added later
- Follow clean architecture and reusable widget practices

Project requirements:
1. Authentication
   - Anonymous sign in on app start
   - Optional email/password auth structure
   - Logout support

2. Firestore CRUD
   - Add task
   - Edit task
   - Delete task
   - Mark task completed

3. Each task must contain:
   - title
   - description
   - date
   - status

4. REST API
   - Fetch motivational quote from:
     https://api.quotable.io/random
   - Display quote + author

5. UI
   - Clean responsive UI
   - Loading indicators
   - Error handling
   - Proper navigation
   - Form validation

6. Folder structure:
lib/
├── models/
├── screens/
├── services/
├── widgets/
└── main.dart

Tasks to perform:

STEP 1 — Install dependencies
Add:
- firebase_core
- firebase_auth
- cloud_firestore
- http
- provider

STEP 2 — Initialize Firebase
Configure FlutterFire properly using:
flutterfire configure

Generate:
- firebase_options.dart

Initialize Firebase in main.dart using:
Firebase.initializeApp()

STEP 3 — Implement Anonymous Authentication
Create:
services/auth_service.dart

Requirements:
- Automatically sign in anonymously on app launch
- Return current Firebase user
- Handle errors properly

STEP 4 — Implement Firestore service
Create:
services/firestore_service.dart

Requirements:
- Add task
- Update task
- Delete task
- Toggle completed status
- Fetch user-specific tasks only

Structure:
users/{uid}/tasks/{taskId}

STEP 5 — Firestore security rules
Generate proper Firestore rules:

rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {

    match /users/{userId}/tasks/{taskId} {

      allow read, write:
      if request.auth != null
      && request.auth.uid == userId;
    }
  }
}

STEP 6 — Create task model
Create:
models/task_model.dart

Fields:
- id
- title
- description
- date
- completed

Include:
- fromMap()
- toMap()

STEP 7 — Create quote API service
Create:
services/quote_service.dart

Use:
https://api.quotable.io/random

Return:
- quote
- author

Handle:
- loading
- network errors
- invalid response

STEP 8 — Build UI screens

Create:
- login_screen.dart
- home_screen.dart
- add_task_screen.dart

Home screen requirements:
- Display motivational quote
- Display task list from Firestore
- Add/Edit/Delete tasks
- Mark task completed
- FloatingActionButton to add task

STEP 9 — Add loading and error handling
Requirements:
- CircularProgressIndicator during async calls
- Snackbar for errors
- Empty state UI for no tasks

STEP 10 — Ensure no manual API key entry
Important:
- Do NOT ask end users to enter API keys
- Use Firebase config internally
- Security must rely on Firebase Authentication + Firestore Rules
- Explain in comments that Firebase API keys are public identifiers and not secrets

STEP 11 — Provide full runnable code
Generate:
- complete Dart files
- imports
- Firebase setup code
- proper null safety
- comments explaining important parts

STEP 12 — Provide commands to run project
Include:
flutter pub get
flutterfire configure
flutter run

Also explain:
- how to enable Firebase Authentication
- how to create Firestore database
- how to test CRUD functionality
- how to test anonymous authentication

Ensure code is production-style, clean, modular, and beginner-friendly.