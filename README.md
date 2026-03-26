# Taskify — Task Manager App

A clean, feature-rich Flutter task management app backed by Firebase. Doer helps you stay organized with prioritized tasks, recurring schedules, task dependencies, and a weekly progress overview.

---

## Features

- **Authentication** — Secure sign-up and login via Firebase Auth
- **Task Management** — Create, edit, and delete tasks with titles and descriptions
- **Priority Levels** — Assign Low, Medium, or High priority to each task
- **Due Dates** — Set due dates with a visual date picker
- **Recurring Tasks** — Mark tasks as Daily or Weekly recurring
- **Task Dependencies** — Set a prerequisite task that must be completed first
- **Search & Filter** — Live search by title, filter by priority or completion status
- **Drag-to-Reorder** — Manually reorder tasks with long-press drag handles
- **Weekly Progress Chart** — Animated bar chart showing planned vs. completed tasks for the week
- **Today / Upcoming Sections** — Tasks grouped by whether they are due today or in the future
- **Real-time Sync** — All data synced live via Cloud Firestore

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State Management | Riverpod (`flutter_riverpod`) |
| Backend / Database | Firebase (Auth + Cloud Firestore) |
| Fonts | Google Fonts — Poppins |
| Min Android SDK | API 23 (Android 6.0) |

---

## Project Structure

```
lib/
├── main.dart                  # App entry point, theme setup
├── repo/
│   ├── task.dart              # Task model, Priority & RecurringType enums
│   └── taskService.dart       # Firestore CRUD operations
├── provider/
│   └── taskProvider.dart      # Riverpod providers (stream, filters, search)
├── screen/
│   ├── splashScreen.dart      # Splash / auth gate
│   ├── loginScreen.dart       # Login screen
│   ├── signupScreen.dart      # Sign-up screen
│   ├── homescreen.dart        # Main task list with search & filter
│   ├── addTaskScreen.dart     # Add / Edit task form
│   ├── taskDetail.dart        # Task detail view
│   └── editTask.dart          # Standalone edit screen
└── widgets/
    ├── taskCard.dart          # Individual task card widget
    └── weeklyProgressCard.dart # Animated weekly bar chart
```

---

## Prerequisites

Before running the app, ensure you have the following installed:

1. **Flutter SDK** — version `3.x` or higher
   Install guide: https://docs.flutter.dev/get-started/install

2. **Dart SDK** — bundled with Flutter (`^3.8.1` required)

3. **Android Studio** or **VS Code** with the Flutter/Dart plugins

4. **A Firebase project** — see Firebase setup below

5. **A connected device or emulator** (Android API 23+ / iOS 12+)

---

## Firebase Setup

Doer uses Firebase Authentication and Cloud Firestore. You must connect it to your own Firebase project.

### Step 1 — Create a Firebase project

1. Go to https://console.firebase.google.com
2. Click **Add project** and follow the prompts

### Step 2 — Enable Authentication

1. In the Firebase console, go to **Build → Authentication**
2. Click **Get started**
3. Under **Sign-in method**, enable **Email/Password**

### Step 3 — Enable Cloud Firestore

1. Go to **Build → Firestore Database**
2. Click **Create database**
3. Choose **Start in test mode** (for development) or configure security rules
4. Select a region and click **Enable**

### Step 4 — Add the Android app to Firebase

1. In the Firebase console, click **Project settings → Add app → Android**
2. Enter the package name: `com.example.task`
3. Download the `google-services.json` file
4. Place it at: `android/app/google-services.json`

### Step 5 — (Optional) Add iOS app

1. Click **Add app → iOS**
2. Enter the bundle ID (found in `ios/Runner.xcodeproj`)
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/GoogleService-Info.plist`

---

## Running the App

### 1. Clone the repository

```bash
git clone https://github.com/your-username/Doer.git
cd Doer
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Verify Flutter setup

```bash
flutter doctor
```

Resolve any issues shown before proceeding.

### 4. Run on a connected device or emulator

```bash
# List available devices
flutter devices

# Run on a specific device
flutter run -d <device-id>

# Or simply run on the first available device
flutter run
```

### 5. Run in release mode (Android)

```bash
flutter run --release
```

### 6. Build an APK

```bash
flutter build apk --release
```

The output APK will be at `build/app/outputs/flutter-apk/app-release.apk`.

---

## Common Issues

| Issue | Fix |
|---|---|
| `google-services.json` not found | Download it from Firebase console and place it at `android/app/google-services.json` |
| Firebase initialization error | Ensure `google-services.json` matches the package name `com.example.task` |
| Gradle build failure | Run `flutter clean && flutter pub get`, then retry |
| Emulator not detected | Start an Android emulator from Android Studio's Device Manager |
| Dart SDK version mismatch | Run `flutter upgrade` to get a compatible SDK version |

---

## Development Notes

- The app uses **Riverpod** for all state management. Providers are defined in `lib/provider/taskProvider.dart`.
- Firestore collection path is scoped per authenticated user (e.g., `users/{uid}/tasks`).
- Task sorting prioritizes a custom `sortOrder` field (set via drag-to-reorder) with due date as a fallback.
- The Weekly Progress Chart currently uses static sample data as a visual placeholder.

---

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [Firebase for Flutter](https://firebase.google.com/docs/flutter/setup)
- [Cloud Firestore Docs](https://firebase.google.com/docs/firestore)
