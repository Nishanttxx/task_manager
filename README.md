<div align="center">

<br/>

```
╔╦╗┌─┐┌─┐┬┌─╔═╗┬  ┌─┐┬ ┬
 ║ ├─┤└─┐├┴┐╠╣ │  │ ││││
 ╩ ┴ ┴└─┘┴ ┴╚  ┴─┘└─┘└┴┘
```

# TaskFlow

**A premium Flutter task manager — beautifully designed, intelligently built.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?style=flat-square&logo=firebase&logoColor=black)](https://firebase.google.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-22c55e?style=flat-square)](LICENSE)
[![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-181717?style=flat-square&logo=github-actions&logoColor=white)](https://github.com/Nishanttxx/task_manager/actions)
[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?style=flat-square&logo=android&logoColor=white)](https://play.google.com/store)

<br/>

> *Building a more productive tomorrow, one task at a time.*

<br/>

</div>

---

## ✦ What is TaskFlow?

TaskFlow is a high-performance, production-ready task management application crafted with **Flutter** and powered by **Firebase**. It fuses a sleek glassmorphic UI — vibrant gradients, micro-animations, fluid transitions — with serious backend reliability: real-time sync, secure authentication, smart alarms, and a fully automated CI/CD pipeline.

Whether you're managing a single to-do list or coordinating complex daily workflows, TaskFlow keeps you focused, motivated, and on time.

---

## ✨ Features

| | Feature | Description |
|---|---|---|
| 🌈 | **Modern UI** | Glassmorphic design with vibrant gradients, smooth transitions & micro-animations |
| 🔐 | **Secure Auth** | Google Sign-In + Anonymous Authentication via Firebase Auth |
| ☁️ | **Real-time Sync** | Instant task sync across devices with Cloud Firestore |
| 💡 | **Daily Motivation** | Fetches fresh motivational quotes from external REST APIs |
| 🔔 | **Smart Alarms** | Full-screen reminder popup, looping alarm tones, snooze support |
| 🚀 | **CI/CD Pipeline** | Automated build & release on every push via GitHub Actions |

---

## 🛠️ Tech Stack

```
┌─────────────────────────────────────────────────────────┐
│  Frontend      Flutter (Dart)     UI Framework           │
│  Auth          Firebase Auth      Google + Anonymous      │
│  Database      Cloud Firestore    Real-time sync         │
│  State         Provider           Reactive state mgmt    │
│  Animations    Flutter Animate    Fluid micro-animations  │
│  CI/CD         GitHub Actions     Automated pipelines    │
└─────────────────────────────────────────────────────────┘
```

---

## 📁 Project Structure

```
lib/
├── models/              # Data models (Task, User, etc.)
├── providers/           # Provider state management
├── screens/             # App screens & pages
├── services/            # Firebase, API & alarm services
├── widgets/             # Reusable UI components
├── firebase_options.dart
└── main.dart
```

---

## 🚀 Getting Started

### Prerequisites

Before diving in, make sure you have the following installed:

- ✅ **Flutter SDK** (latest stable)
- ✅ **Android Studio** or **VS Code**
- ✅ **Firebase Project** (with Firestore + Auth enabled)
- ✅ **Git**
- ✅ **Android Emulator** or physical device

---

## 📦 Installation & Setup

### 1 · Clone the Repository

```bash
git clone https://github.com/Nishanttxx/task_manager.git
cd task_manager
```

### 2 · Install Dependencies

```bash
flutter pub get
```

---

## 🔥 Firebase Setup

### 3 · Create a Firebase Project

1. Open the [Firebase Console](https://console.firebase.google.com)
2. Create a new project
3. Enable the following services:
   - **Authentication**
   - **Cloud Firestore**

### 4 · Enable Authentication Methods

Inside Firebase Console → **Authentication** → **Sign-in Method**, enable:

- ✅ Google Sign-In
- ✅ Anonymous Authentication

### 5 · Add Your Android App

1. Register your Android package name in Firebase
2. Download `google-services.json`
3. Place it at:

```
android/app/google-services.json
```

### 6 · Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

Verify the installation:

```bash
flutterfire --version
```

### 7 · Configure Firebase for Flutter

```bash
flutterfire configure
```

This auto-generates:

```
lib/firebase_options.dart
```

---

## ▶️ Run the App

Check connected devices:

```bash
flutter devices
```

Launch the app:

```bash
flutter run
```

---

## 🏗️ Build APK

| Build Type | Command |
|---|---|
| Debug APK | `flutter build apk --debug` |
| Release APK | `flutter build apk --release` |

Output location:

```
build/app/outputs/flutter-apk/
```

---

## 🔔 Alarm Feature

TaskFlow's smart alarm system keeps you on top of every task:

```
┌────────────────────────────────────────┐
│  🔔  TASK REMINDER                     │
│                                        │
│  Complete daily standup report         │
│  ─────────────────────────────         │
│  ⏰ Due: Today at 09:00 AM             │
│                                        │
│  [ Snooze 5 min ]   [ Dismiss ]        │
└────────────────────────────────────────┘
```

- Full-screen alarm popup
- Custom looping alarm tones
- Snooze functionality
- Persistent reminders
- Local storage integration

---

## 🔑 GitHub Actions CI/CD

TaskFlow ships with a fully automated Android build and release pipeline.

### Required GitHub Secrets

Go to: **Repository → Settings → Secrets and Variables → Actions**

| Secret | Description |
|---|---|
| `KEYSTORE_BASE64` | Base64-encoded keystore file |
| `KEYSTORE_PASSWORD` | Keystore password |
| `KEY_ALIAS` | Key alias |
| `KEY_PASSWORD` | Key password |
| `FIREBASE_API_KEY` | Firebase API key |

### What the Pipeline Does

```
Push to main
     │
     ▼
┌─────────────┐    ┌──────────────┐    ┌───────────────┐
│  CodeQL Scan│───▶│  Flutter Build│───▶│ Release Upload│
│  (Security) │    │  (APK/AAB)   │    │ (Artifacts)   │
└─────────────┘    └──────────────┘    └───────────────┘
```

- ✅ Automatic APK build on every push
- ✅ Secure encrypted secrets
- ✅ CodeQL vulnerability scanning
- ✅ Continuous integration checks
- ✅ Release workflow automation

---

## 🧪 Useful Commands

```bash
# Clean the project
flutter clean

# Reinstall dependencies
flutter pub get

# Analyze code quality
flutter analyze

# Run tests
flutter test
```

---

## 📄 License

Distributed under the **MIT License**.  
See [`LICENSE`](LICENSE) for full details.

---

<div align="center">

Made with ❤️ using Flutter & Firebase

**[⭐ Star this repo](https://github.com/Nishanttxx/task_manager)** · **[🐛 Report a bug](https://github.com/Nishanttxx/task_manager/issues)** · **[💡 Request a feature](https://github.com/Nishanttxx/task_manager/issues)**

</div>
