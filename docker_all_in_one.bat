\
    @echo off
    REM ThinkStrike - Build & Run All Services
    REM Prereqs: Docker installed & running

    SETLOCAL ENABLEDELAYEDEXPANSION

    REM ===== Backend Build =====
    echo.
    echo [1/3] Building backend image...
    cd backend
    docker build -t thinkstrike-backend . || goto :error

    echo.
    echo [2/3] Starting backend container...
    docker rm -f thinkstrike-api >NUL 2>&1
    docker run -d --name thinkstrike-api -p 8000:8000 ^
      -e MONGODB_URL="mongodb+srv://thinkstrike:Te31PRnZRCfPODrg@cluster1.nxtxrwu.mongodb.net/?retryWrites=true&w=majority&appName=cluster1" ^
      -e DATABASE_NAME="thinkstrike" ^
      -e SECRET_KEY="REPLACE_WITH_STRONG_SECRET" ^
      thinkstrike-backend || goto :error
    cd ..

    echo.
    echo [3/3] Done. Backend running at http://localhost:8000 (Swagger at /docs)
    echo Use Flutter to run Android or Web frontend:
    echo   cd frontend && flutter pub get && flutter run -d android
    echo   cd frontend && flutter pub get && flutter run -d chrome
    echo.
    echo Press any key to exit...
    pause >NUL
    exit /b 0

    :error
    echo.
    echo Build or run failed. Please check the error above.
    pause
    exit /b 1
