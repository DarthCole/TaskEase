# Rempo - Smart To-Do and Reminder App
Rempo is an offline-first Flutter mobile application for personal task tracking and deadline reminders.  
It is designed for single-user productivity with local storage, local notifications, haptic feedback, and search/filter capabilities.
## 1) Project Overview
### Problem Context
Many users need a reliable reminder application that:
- works without internet,
- stores data privately on-device,
- and still sends reminder alerts at the right time.
Rempo addresses this with a lightweight Android-focused app for creating, managing, and tracking tasks.
### Product Vision
Rempo helps users:
- create tasks with due date/time and priority,
- receive local alerts with optional sound and haptics,
- search and filter quickly across pending and completed tasks,
- keep all data offline by default.
## 2) Core Features
- **offline task storage** using Hive local database.
- **task CRUD** for create, edit, update, and delete operations.
- **status management** for pending/completed tasks.
- **priority management** with low, medium, and high priorities.
- **reminder notifications** with exact local scheduling.
- **haptics support** for key actions (add/complete).
- **sound toggle** in settings for notification audio control.
- **search and filters** for keyword, status, and priority.
- **splash boot flow** that initializes storage and reminders.
## 3) Non-Functional Goals
- **offline reliability**: app functions without network access.
- **performance**: responsive list/search operations on-device.
- **usability**: material 3 interface with clear task hierarchy.
- **privacy**: no cloud dependency and no account requirement.
- **battery awareness**: reminders are scheduled at task times.
## 4) Technical Architecture
Rempo follows a layered Flutter architecture:
- **presentation layer**: screens and widgets in `lib/screens`.
- **state management layer**: provider logic in `lib/providers/task_provider.dart`.
- **service layer**:
  - `storage_service.dart` for Hive persistence
  - `notification_service.dart` for local scheduling and permission requests
- **data layer**: local Hive boxes for tasks and app settings.
### Data Flow
User action -> UI screen -> TaskProvider -> StorageService/NotificationService -> Hive/Notification manager
## 5) Project Structure
```text
lib/
  main.dart
  models/
    app_settings.dart
    task.dart
  providers/
    task_provider.dart
  screens/
    home_screen.dart
    settings_screen.dart
    splash_screen.dart
    task_form_screen.dart
  services/
    notification_service.dart
    storage_service.dart
```
## 6) Data Model
### Task Entity
- `id` (String UUID)
- `title` (String)
- `note` (String)
- `dueAt` (DateTime)
- `priority` (enum: low/medium/high)
- `isCompleted` (bool)
- `isNotified` (bool)
- `createdAt` (DateTime)
### App Settings Entity
- `soundEnabled` (bool)
- `hapticsEnabled` (bool)
## 7) Android Permissions
Defined in `android/app/src/main/AndroidManifest.xml`:
- `POST_NOTIFICATIONS`
- `VIBRATE`
- `WAKE_LOCK`
- `RECEIVE_BOOT_COMPLETED`
- `SCHEDULE_EXACT_ALARM`
No camera, microphone, or location permissions are used.
## 8) Build and Run
### Prerequisites
- Flutter SDK 3.x
- Android SDK configured
- Android device with USB debugging enabled
### Install dependencies
```bash
flutter pub get
```
### Run in debug
```bash
flutter run
```
### Build release APK
```bash
flutter build apk --release
```
Output file:
- `build/app/outputs/flutter-apk/app-release.apk`
## 9) Downloadable APK in Repository
This repository includes a release APK copy at:
- `releases/rempo-release.apk`
This makes it easy to download the app artifact directly from GitHub without rebuilding locally.
## 10) Testing Checklist
- create a task with due time 2 minutes ahead.
- verify reminder appears at due time.
- toggle sound off and confirm silent alert behavior.
- mark task complete and confirm list update.
- use search and status/priority filters.
- restart app and verify data persistence.
## 11) Limitations
- exact reminders may vary slightly on heavily restricted Android power modes.
- current implementation is Android-first.
- cloud sync is intentionally excluded for privacy and offline focus.
## 12) Course Deliverables Mapping
