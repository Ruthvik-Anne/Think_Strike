# ThinkStrike

**ThinkStrike** is a modular platform for AI-powered quiz generation, student feedback, teacher dashboards, and admin user management.

## Setup & Run

### Backend (Python/FastAPI)
1. Install requirements:
   ```
   pip install -r requirements.txt
   ```
2. Run the backend:
   ```
   uvicorn backend.main:app --reload
   ```

### Frontend (Flutter)
1. Install dependencies:
   ```
   flutter pub get
   ```
2. Run the app:
   ```
   flutter run
   ```

## Features

- Teachers: Preview and save quizzes, view student results
- Students: Take quizzes, get instant feedback
- Admin: Manage users

## Folder Structure

See `SUMMARY.md` for structure and documentation.


## TensorFlow note
The backend can optionally use TensorFlow for AI features. TensorFlow is included in `requirements.txt` but may significantly increase the Docker image size. If you don't need TF, remove it from `requirements.txt` before building the Docker image.
