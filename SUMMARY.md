# Project Summary

**ThinkStrike** is a modular AI-powered quiz platform with three roles:

- **Teacher:** Generates quizzes, previews them, saves to database, views student results.
- **Student:** Takes quizzes, receives feedback based on answers.
- **Admin:** Lists and manages users.

## Tech Stack

- **Backend:** FastAPI, SQLAlchemy, SQLite
- **Frontend:** Flutter

## Main Components

- `backend/`: FastAPI app, routers, models, AI quiz generator.
- `frontend/`: Flutter app with role-based screens and API service.
- `.github/`: CI workflow for automated checks.
- `README.md`, `SUMMARY.md`: Docs and setup.

## Usage

Each role has dedicated UI and API endpoints.