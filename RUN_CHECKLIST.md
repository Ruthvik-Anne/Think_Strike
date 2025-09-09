# ThinkStrike — Fixes Applied & How to Run

This commit fixes frontend service imports, routing, and backend routing wiring. MongoDB connection is set via **backend/.env** using your connection string.

## What I fixed
- **frontend/lib/services/api_service.dart**: put/delete placed inside the class; URL building fixed; auth header included.
- **frontend/lib/services/auth_service.dart**: Rewrote a clean `AuthState` with `init()`, `login()`, `refreshMe()`, `logout()`.
- **frontend/lib/main.dart**: Rebuilt using `provider` + `go_router` (^5.0.5) with role-based redirects.
- **backend/main.py**: Now uses `routers.quiz` (complete) instead of the older `quizzes.py`. CORS tightened. Auto-seeds default admin on startup.
- **backend/.env**: Updated `MONGODB_URL` to your provided Atlas URI.

## How to run

### Backend
```bash
cd backend
python -m venv .venv && source .venv/bin/activate  # or .venv\Scripts\activate on Windows
pip install -r requirements.txt
# Ensure .env has your MongoDB URL (already set)
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```
Health check: `GET http://localhost:8000/health`

### Frontend (Flutter)
- Requires Flutter 3.x (Dart >=2.17).
- In **frontend**:
```bash
flutter pub get
# Web/dev run with backend at localhost:8000
flutter run -d chrome --dart-define=BACKEND_URL=http://localhost:8000
# Or Android/iOS:
flutter run --dart-define=BACKEND_URL=http://10.0.2.2:8000   # Android emulator
```
> On production, set `--dart-define=BACKEND_URL=https://your-api.example.com`

## Default Admin
Email: `admin@thinkstrike.edu`  
Password: `Admin123!`
