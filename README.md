🚀 TaskFlow

Flutter Build & Release • License: MIT

TaskFlow is a premium, high-performance task management application built with Flutter and Firebase. It combines sleek glassmorphic design with robust functionality to help users stay productive and motivated.

✨ Features
🌈 Modern Aesthetics
Beautiful UI with vibrant gradients, glassmorphism, smooth transitions, and micro-animations.
🔐 Secure Authentication
Supports Google Sign-In and Anonymous Authentication using Firebase Auth.
☁️ Real-time Sync
Instant task synchronization using Cloud Firestore.
💡 Daily Motivation
Fetches motivational quotes from external REST APIs.
🔔 Task Alarm System
Smart reminder popup with looping alarm tones and snooze support.
🚀 CI/CD Powered
Automated Android build and release pipeline using GitHub Actions.
🛠️ Tech Stack
Technology	Usage
Flutter (Dart)	Frontend Framework
Firebase Auth	Authentication
Cloud Firestore	Database
Provider	State Management
Flutter Animate	Animations
GitHub Actions	CI/CD Pipeline
📸 Preview

TaskFlow Icon

Building a more productive tomorrow, one task at a time.

🚀 Getting Started
Prerequisites

Before starting, make sure you have:

Latest stable version of Flutter SDK
Android Studio or VS Code
Firebase Project
Git installed
Android Emulator or Physical Device
📦 Installation & Setup
1. Clone the Repository
git clone https://github.com/Nishanttxx/task_manager.git
cd task_manager
2. Install Dependencies
flutter pub get
🔥 Firebase Setup
3. Create Firebase Project
Open Firebase Console
Create a new Firebase project
Enable:
Authentication
Cloud Firestore
4. Enable Authentication Methods

Inside Firebase Console:

Enable Google Sign-In
Go to:
Authentication → Sign-in Method
Enable:
Google
Anonymous Authentication
5. Add Android App to Firebase
Register Android package name
Download google-services.json
Place it inside:
android/app/google-services.json
6. Install FlutterFire CLI
dart pub global activate flutterfire_cli

Verify installation:

flutterfire --version
7. Configure Firebase for Flutter

Run:

flutterfire configure

This generates:

lib/firebase_options.dart
▶️ Run the App
Start Emulator or Connect Device

Check connected devices:

flutter devices
Run Application
flutter run
🏗️ Build APK
Debug APK
flutter build apk --debug
Release APK
flutter build apk --release

Generated APK location:

build/app/outputs/flutter-apk/
🔑 GitHub Actions CI/CD Setup

TaskFlow includes automated Android build workflows using GitHub Actions.

Required GitHub Secrets

Go to:

GitHub Repository → Settings → Secrets and Variables → Actions

Add:

Secret Name	Description
KEYSTORE_BASE64	Base64 encoded keystore
KEYSTORE_PASSWORD	Keystore password
KEY_ALIAS	Key alias
KEY_PASSWORD	Key password
FIREBASE_API_KEY	Firebase API Key
CI/CD Features
✅ Automatic APK build on push
✅ Release workflow automation
✅ Secure encrypted secrets
✅ CodeQL vulnerability scanning
✅ Continuous integration checks
📁 Project Structure
lib/
 ├── models/
 ├── providers/
 ├── screens/
 ├── services/
 ├── widgets/
 ├── firebase_options.dart
 └── main.dart
🔔 Alarm Feature

TaskFlow includes a smart task reminder system:

Full-screen alarm popup
Custom alarm tone support
Snooze functionality
Persistent reminders
Local storage integration
🧪 Useful Commands
Clean Project
flutter clean
Get Dependencies Again
flutter pub get
Analyze Code
flutter analyze
Run Tests
flutter test
📄 License

Distributed under the MIT License.

See LICENSE for more information.
