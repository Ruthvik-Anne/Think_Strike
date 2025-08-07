#!/bin/bash

# ThinkStrike Release Script
# Created: 2025-08-07 15:35:50
# Author: Ruthvik-Anne

# Set version
VERSION="1.0.0"
RELEASE_DATE="2025-08-07"

# Create release directory
RELEASE_DIR="thinkstrike_${VERSION}"
mkdir -p $RELEASE_DIR

# Build frontend
echo "Building frontend..."
cd frontend
npm run build
cd ..

# Build backend
echo "Building backend..."
python -m pip install --upgrade build
python -m build

# Create web release
echo "Creating web release..."
mkdir -p $RELEASE_DIR/web
cp -r frontend/build/* $RELEASE_DIR/web/
cp -r backend/dist/* $RELEASE_DIR/web/

# Build Android APK
echo "Building Android APK..."
cd mobile
./gradlew assembleRelease
cd ..
cp mobile/app/build/outputs/apk/release/app-release.apk $RELEASE_DIR/thinkstrike.apk

# Create documentation
echo "Generating documentation..."
mkdir -p $RELEASE_DIR/docs
cp README.md $RELEASE_DIR/docs/
python scripts/generate_docs.py > $RELEASE_DIR/docs/api.html

# Create release notes
cat > $RELEASE_DIR/RELEASE_NOTES.md << EOL
# ThinkStrike v${VERSION}
Release Date: ${RELEASE_DATE}

## Features
- Quiz creation and management
- Offline support
- Automated reporting system
- Performance optimizations
- Mobile app support

## Installation
1. Web: Deploy contents of web/ directory
2. Mobile: Install thinkstrike.apk
3. Documentation: See docs/ directory

## Requirements
- Python 3.8+
- Node.js 14+
- Android 7.0+ (for mobile app)

## Support
For support, visit: https://github.com/Ruthvik-Anne/ThinkStrike/issues
EOL

# Create ZIP archive
zip -r thinkstrike_${VERSION}.zip $RELEASE_DIR

echo "Release v${VERSION} created successfully!"