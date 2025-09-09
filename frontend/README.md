# ThinkStrike Frontend

Flutter frontend for the ThinkStrike AI-powered quiz platform.

## Features

- Student Portal: Take quizzes and track progress
- Teacher Portal: Create quizzes and manage question banks
- Admin Portal: User management and analytics
- Glassmorphism UI design
- Cross-platform support (Web, Android, iOS)

## Getting Started

### Prerequisites

- Flutter SDK (>=3.16.0)
- Dart SDK (>=3.0.0)

### Installation

1. Install dependencies:
```bash
flutter pub get
```

2. Run the app:
```bash
# Web
flutter run -d chrome

# Android
flutter run -d android

# iOS
flutter run -d ios
```

### Building

```bash
# Web build
flutter build web

# Android APK
flutter build apk

# iOS
flutter build ios
```

## Project Structure

```
lib/
├── main.dart              # App entry point
├── theme.dart             # Glassmorphism theme
├── screens/               # UI screens
│   ├── admin_screen.dart
│   ├── student_screen.dart
│   └── teacher_screen.dart
└── services/              # API services
    └── api_service.dart
```

## API Integration

The frontend connects to the FastAPI backend running on `http://localhost:8000`.

### Available Endpoints

- `GET /admin/users` - Get user list
- `POST /teacher/teacher/quiz/preview` - Preview quiz
- `POST /teacher/teacher/quiz/generate` - Generate quiz
- `POST /student/student/quiz/submit/{quiz_id}` - Submit quiz

## Development

### Code Style

The project uses Flutter's recommended linting rules. Run:

```bash
flutter analyze
```

### Testing

```bash
flutter test
```

## Deployment

The app can be deployed to:
- Web: Netlify, Vercel
- Mobile: Google Play Store, Apple App Store
- Desktop: Windows, macOS, Linux
