# GitHub Actions Setup Guide

This guide explains how to configure GitHub Actions for the ThinkStrike project with Python 3.11.

## Required Secrets

Add these secrets to your GitHub repository (Settings > Secrets and variables > Actions):

### MongoDB Atlas
- `MONGODB_URL`: Your MongoDB Atlas connection string
- `DATABASE_NAME`: Database name (default: thinkstrike)

### Deployment Platforms (Optional)

#### Heroku
- `HEROKU_API_KEY`: Your Heroku API key
- `HEROKU_APP_NAME`: Your Heroku app name
- `HEROKU_EMAIL`: Your Heroku email

#### Railway
- `RAILWAY_TOKEN`: Your Railway API token

#### Netlify
- `NETLIFY_AUTH_TOKEN`: Your Netlify auth token
- `NETLIFY_SITE_ID`: Your Netlify site ID

#### Vercel
- `VERCEL_TOKEN`: Your Vercel token
- `VERCEL_ORG_ID`: Your Vercel organization ID
- `VERCEL_PROJECT_ID`: Your Vercel project ID

#### Slack Notifications (Optional)
- `SLACK_WEBHOOK`: Slack webhook URL for deployment notifications

## Workflows

### 1. Backend CI/CD (`.github/workflows/backend-ci.yml`)
- **Triggers**: Push/PR to main/develop branches affecting backend
- **Python Version**: 3.11
- **Features**:
  - Code linting with flake8
  - Type checking with mypy
  - Unit testing with pytest
  - Security scanning with bandit and safety
  - Coverage reporting
  - Docker image building

### 2. Frontend CI/CD (`.github/workflows/frontend-ci.yml`)
- **Triggers**: Push/PR to main/develop branches affecting frontend
- **Flutter Version**: 3.16.0
- **Features**:
  - Code analysis
  - Unit testing with coverage
  - Web app building
  - Android APK building
  - iOS app building

### 3. Deployment (`.github/workflows/deploy.yml`)
- **Triggers**: Push to main branch or manual dispatch
- **Features**:
  - Backend deployment to Heroku/Railway
  - Frontend deployment to Netlify/Vercel
  - Slack notifications
  - Deployment summaries

## Environment Protection

The deployment workflow uses GitHub environments for additional security:
- `production`: Protected environment requiring approval
- Configure branch protection rules
- Set up required reviewers

## Local Development

### Python 3.11 Setup
```bash
# Using pyenv
pyenv install 3.11.0
pyenv local 3.11.0

# Install dependencies
pip install -r requirements.txt
```

### Docker Development
```bash
# Build and run with Docker Compose
docker-compose up --build

# Run backend only
docker build -t thinkstrike-backend .
docker run -p 8000:8000 thinkstrike-backend
```

## Testing

### Backend Tests
```bash
cd backend
pytest -v --cov=. --cov-report=html
```

### Frontend Tests
```bash
cd frontend
flutter test --coverage
```

## Monitoring

- **Health Check**: `GET /health` endpoint
- **Coverage Reports**: Available in Actions artifacts
- **Security Reports**: Bandit and Safety scan results
- **Deployment Status**: Slack notifications and GitHub summaries

## Troubleshooting

### Common Issues

1. **MongoDB Connection Fails**
   - Verify `MONGODB_URL` secret is correct
   - Check IP whitelist in MongoDB Atlas
   - Ensure database user has proper permissions

2. **Python Version Mismatch**
   - All workflows use Python 3.11
   - Update local environment to match

3. **Flutter Build Fails**
   - Check Flutter version compatibility
   - Verify pubspec.yaml dependencies

4. **Deployment Fails**
   - Check platform-specific secrets
   - Verify environment variables
   - Review platform logs

### Debug Mode

Enable debug logging by adding to workflow:
```yaml
env:
  DEBUG: true
  LOG_LEVEL: debug
```
