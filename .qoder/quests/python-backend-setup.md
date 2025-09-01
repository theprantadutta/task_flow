# Python Backend Setup and Implementation Plan

## Overview

This document outlines the complete setup and implementation plan for the TaskFlow Python backend. The backend serves as the server-side component for handling complex operations that are not suitable for client-side processing or Firebase Cloud Functions, including scheduled tasks, notifications, analytics, and data processing.

## Repository Type Detection

Based on the codebase analysis, this is a **Full-Stack Application** with:
- Flutter frontend (mobile app)
- Python backend (server-side logic)
- Firebase integration (authentication, database, messaging)

## Architecture

The Python backend follows a modular architecture with the following components:

```
graph TD
    A[Flask Application] --> B[API Endpoints]
    A --> C[Task Scheduler]
    A --> D[Notification Service]
    A --> E[Firebase Admin SDK]
    
    B --> F[Health Check]
    B --> G[Notification APIs]
    B --> H[Analytics APIs]
    B --> I[User Activity APIs]
    
    C --> J[Scheduled Jobs]
    C --> K[Task Reminders]
    C --> L[Reports]
    C --> M[Recurring Tasks]
    
    D --> N[FCM Integration]
    D --> O[Push Notifications]
    D --> P[Bulk Notifications]
    D --> Q[Email Notifications]
    
    E --> R[Firestore Access]
    E --> S[Authentication]
    E --> T[Storage]
```

## Technology Stack & Dependencies

### Core Technologies
- **Flask**: Web framework for REST API endpoints
- **Firebase Admin SDK**: Server-side Firebase integration
- **APScheduler**: Advanced Python Scheduler for task scheduling
- **python-dotenv**: Environment variable management
- **smtplib**: For email notifications (to be implemented)

### Dependencies
| Package | Version | Purpose |
|---------|---------|---------|
| firebase-admin | 6.2.0 | Firebase server-side integration |
| flask | 2.3.2 | Web framework |
| flask-cors | 4.0.0 | Cross-Origin Resource Sharing support |
| python-dotenv | 1.0.0 | Environment variable loading |
| apscheduler | 3.10.1 | Task scheduling |

## Component Architecture

### Main Application (app.py)
The main Flask application that initializes all services and defines API endpoints.

### Notification Service (notification_service.py)
Handles all Firebase Cloud Messaging operations:
- Single user notifications
- Topic-based notifications
- Bulk notifications
- Email notifications (to be implemented)

### Task Scheduler (task_scheduler.py)
Manages scheduled tasks using APScheduler:
- Periodic task checking
- Daily/weekly scheduled jobs
- Custom cron-based scheduling
- Recurring task scheduling

### Setup Script (setup.py)
Automates virtual environment creation and dependency installation.

### Run Script (run.py)
Handles virtual environment activation and server startup.

## API Specification

### Base URL
```
http://localhost:5000/api
```

### Authentication
All protected endpoints require a JWT token in the Authorization header:
```
Authorization: Bearer <token>
```

### Health Check Endpoint

#### GET /api/health
Check the health status of the backend service.

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2023-07-15T10:30:00Z"
}
```

### Notification Endpoints

#### POST /api/send-notification
Send a notification to a specific user device.

**Request Body:**
```json
{
  "token": "device_registration_token",
  "title": "Notification Title",
  "body": "Notification Body",
  "data": {
    "key": "value"
  }
}
```

**Response:**
```json
{
  "success": true,
  "message_id": "message_id"
}
```

#### POST /api/send-topic-notification
Send a notification to all devices subscribed to a topic.

**Request Body:**
```json
{
  "topic": "task-reminders",
  "title": "Notification Title",
  "body": "Notification Body",
  "data": {
    "key": "value"
  }
}
```

**Response:**
```json
{
  "success": true,
  "message_id": "message_id"
}
```

#### POST /api/notify-task-assignment
Send a notification when a task is assigned to a user.

**Request Body:**
```json
{
  "assigneeId": "user_123",
  "taskId": "task_456",
  "taskTitle": "Complete backend implementation",
  "projectId": "project_789",
  "dueDate": "2023-12-31T23:59:59Z"
}
```

**Response:**
```json
{
  "success": true,
  "message_id": "message_id"
}
```

### Analytics Endpoints

#### POST /api/analytics/event
Record a user activity event.

**Request Body:**
```json
{
  "userId": "user_123",
  "eventType": "task_completed",
  "eventData": {
    "taskId": "task_456",
    "projectId": "project_789",
    "duration": 3600
  }
}
```

**Response:**
```json
{
  "success": true,
  "eventId": "event_abc"
}
```

#### GET /api/analytics/user-summary
Get user activity summary.

**Query Parameters:**
- userId (required): User ID
- period (optional): Time period (daily, weekly, monthly) - defaults to weekly

**Response:**
```json
{
  "userId": "user_123",
  "period": "weekly",
  "summary": {
    "tasksCompleted": 15,
    "projectsActive": 3,
    "hoursWorked": 25.5,
    "productivityScore": 8.5
  },
  "trends": {
    "completionRate": 0.85,
    "improvement": 0.12
  }
}
```

### Scheduled Task Management Endpoints

#### POST /api/scheduled-tasks
Create a new scheduled task.

**Request Body:**
```json
{
  "taskType": "daily_summary",
  "schedule": "0 9 * * *",  // Cron expression
  "parameters": {
    "userId": "user_123",
    "timezone": "America/New_York"
  },
  "description": "Send daily summary email"
}
```

**Response:**
```json
{
  "success": true,
  "taskId": "scheduled_task_123",
  "nextRun": "2023-07-16T09:00:00Z"
}
```

#### GET /api/scheduled-tasks
List all scheduled tasks.

**Response:**
```json
{
  "tasks": [
    {
      "taskId": "scheduled_task_123",
      "taskType": "daily_summary",
      "schedule": "0 9 * * *",
      "nextRun": "2023-07-16T09:00:00Z",
      "enabled": true,
      "description": "Send daily summary email"
    }
  ]
}
```

#### DELETE /api/scheduled-tasks/{taskId}
Delete a scheduled task.

**Response:**
```json
{
  "success": true,
  "message": "Task deleted successfully"
}
```

### User Management Endpoints

#### GET /api/users/{userId}/preferences
Get user notification preferences.

**Response:**
```json
{
  "userId": "user_123",
  "preferences": {
    "emailNotifications": true,
    "pushNotifications": true,
    "dailySummary": true,
    "weeklySummary": true,
    "taskAssignment": true,
    "taskDueDate": true,
    "emailFrequency": "daily"
  }
}
```

#### PUT /api/users/{userId}/preferences
Update user notification preferences.

**Request Body:**
```json
{
  "preferences": {
    "emailNotifications": true,
    "pushNotifications": false,
    "dailySummary": true,
    "weeklySummary": false,
    "taskAssignment": true,
    "taskDueDate": true,
    "emailFrequency": "weekly"
  }
}
```

**Response:**
```json
{
  "success": true,
  "message": "Preferences updated successfully"
}
```

### Error Responses

All endpoints may return the following error responses:

**400 Bad Request**
```json
{
  "error": "Invalid request data",
  "details": "Missing required field: token"
}
```

**401 Unauthorized**
```json
{
  "error": "Authentication required",
  "message": "Missing or invalid authentication token"
}
```

**403 Forbidden**
```json
{
  "error": "Access denied",
  "message": "You don't have permission to access this resource"
}
```

**429 Too Many Requests**
```json
{
  "error": "Rate limit exceeded",
  "message": "Too many requests. Please try again later."
}
```

**500 Internal Server Error**
```json
{
  "error": "Internal server error",
  "message": "An unexpected error occurred"
}
```

## Implementation Roadmap

### Week 1: Core Infrastructure
- [ ] Set up virtual environment and dependencies
- [ ] Enhance Firebase integration with better error handling
- [ ] Implement comprehensive logging framework
- [ ] Add JWT authentication middleware
- [ ] Add rate limiting middleware
- [ ] Create basic API documentation

### Week 2: Notification System
- [ ] Implement task assignment notifications
- [ ] Create notification templates for different events
- [ ] Add bulk notification capabilities
- [ ] Implement email notification system
- [ ] Add notification grouping and categorization
- [ ] Implement user preference management

### Week 3: Task Scheduling
- [ ] Implement recurring task scheduling with timezone support
- [ ] Create admin interface for managing scheduled jobs
- [ ] Add logging and monitoring for scheduled tasks
- [ ] Implement overdue task checking
- [ ] Add custom scheduled job creation via API

### Week 4: Analytics and Reporting
- [ ] Implement user activity analytics collection
- [ ] Create daily/weekly summary email functionality
- [ ] Generate productivity insights
- [ ] Build APIs for frontend analytics integration
- [ ] Implement data aggregation for dashboard metrics

### Week 5: Security and Performance
- [ ] Implement comprehensive API authentication
- [ ] Add input validation and sanitization
- [ ] Optimize database queries and implement caching
- [ ] Conduct security audit
- [ ] Add performance monitoring and metrics collection

## Testing Plan

### Unit Tests
- [ ] Test notification service functions
- [ ] Test task scheduler functionality
- [ ] Test API endpoint responses
- [ ] Test error handling scenarios
- [ ] Test authentication and authorization logic

### Integration Tests
- [ ] Test Firebase Admin SDK integration
- [ ] Test scheduled task execution
- [ ] Test notification delivery
- [ ] Test API endpoint integration with Firestore
- [ ] Test email notification delivery

### Performance Tests
- [ ] Load testing for API endpoints
- [ ] Stress testing for notification service
- [ ] Performance benchmarking for scheduled tasks
- [ ] Database query optimization testing

## Monitoring and Observability

### Logging Structure
All logs should follow a structured format:
```json
{
  "timestamp": "2023-07-15T10:30:00Z",
  "level": "INFO",
  "service": "notification_service",
  "function": "send_notification_to_user",
  "message": "Notification sent successfully",
  "userId": "user_123",
  "messageId": "message_abc"
}
```

### Metrics Collection
Key metrics to collect:
- API response times
- Error rates
- Notification delivery success rates
- Scheduled task execution times
- Database query performance
- System resource utilization

### Health Checks
Implement health checks for:
- Application status
- Database connectivity
- External service connectivity
- Scheduled task status
- System resources

## Data Models

The Python backend interacts with Firebase Firestore collections:

### Users Collection
- uid (string): Firebase user ID
- name (string): User's display name
- email (string): User's email address
- photoUrl (string): Profile picture URL
- notificationPreferences (object): User's notification preferences

### Workspaces Collection
- id (string): Workspace ID
- name (string): Workspace name
- description (string): Workspace description
- ownerId (string): Creator's user ID
- members (array): List of member user IDs
- createdAt (timestamp): Creation timestamp

### Projects Collection
- id (string): Project ID
- name (string): Project name
- description (string): Project description
- workspaceId (string): Parent workspace ID
- ownerId (string): Creator's user ID
- members (array): List of member user IDs
- createdAt (timestamp): Creation timestamp

### Tasks Collection
- id (string): Task ID
- title (string): Task title
- description (string): Task description
- projectId (string): Parent project ID
- assigneeId (string): Assigned user ID
- status (string): Task status (todo, in_progress, done)
- priority (string): Task priority (low, medium, high)
- dueDate (timestamp): Due date
- createdAt (timestamp): Creation timestamp

### User Activity Collection
- id (string): Activity ID
- userId (string): User ID
- eventType (string): Type of activity
- eventData (object): Additional event data
- timestamp (timestamp): When the activity occurred

## Business Logic Layer

### Notification System
The notification system handles:
1. User-specific notifications (task assignments, updates)
2. Topic-based notifications (broadcast messages)
3. Bulk notifications (announcements to multiple users)
4. Email notifications (daily/weekly summaries)
5. Notification templates for different events

### Task Scheduling
The task scheduler manages:
1. Periodic overdue task checks (every 30 minutes)
2. Daily task reminders
3. Weekly productivity reports
4. Custom scheduled jobs
5. Recurring task scheduling with timezone support

### Analytics and Reporting
The analytics system handles:
1. User activity tracking
2. Task completion metrics
3. Productivity insights
4. Daily/weekly summary generation
5. Custom report generation

### Firebase Integration
The backend integrates with Firebase services:
1. Firestore for data access
2. Firebase Authentication for user validation
3. Firebase Cloud Messaging for push notifications
4. Firebase Storage for file management

## Middleware & Interceptors

### CORS Middleware
Cross-Origin Resource Sharing support is enabled for all routes to allow communication between the Flutter frontend and Python backend.

### Authentication Middleware
API authentication and authorization middleware to secure endpoints.

### Rate Limiting
Rate limiting middleware to prevent API abuse.

### Error Handling
Centralized error handling for all API endpoints with proper HTTP status codes and error messages.

## Environment Configuration

### Environment Variables
The backend uses environment variables for configuration:
- FLASK_ENV: Application environment (development/production)
- FLASK_APP: Main application file
- FIREBASE_PROJECT_ID: Firebase project ID
- FIREBASE_PRIVATE_KEY: Firebase service account private key
- FIREBASE_CLIENT_EMAIL: Firebase service account email
- EMAIL_HOST: SMTP server for email notifications
- EMAIL_PORT: SMTP port
- EMAIL_USER: SMTP username
- EMAIL_PASSWORD: SMTP password

### Virtual Environment Structure
The Python backend uses a virtual environment to isolate dependencies:

```
python_backend/
├── venv/                 # Python virtual environment (git ignored)
│   ├── .gitkeep          # Empty file to keep directory in git
│   ├── Scripts/          # Windows executables
│   ├── bin/              # Unix executables
│   ├── lib/              # Library files
│   └── pyvenv.cfg        # Virtual environment config
├── .env                  # Environment variables (git ignored)
├── .env.example          # Environment variable template
├── app.py                # Main Flask application
├── notification_service.py # FCM notification service
├── task_scheduler.py     # Scheduled task management
├── extract_firebase_config.py # Firebase config extractor
├── setup.py              # Setup script
├── run.py                # Application runner
├── requirements.txt      # Dependencies
└── serviceAccountKey.json # Service account key (git ignored)
```

### Virtual Environment Setup
```bash
# Create virtual environment
python -m venv venv

# Activate virtual environment
# Windows
venv\Scripts\activate
# macOS/Linux
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

## Implementation Plan

The implementation plan is organized around the priorities outlined in BACKEND_PLAN.md, with a focus on delivering the most critical features first.

### Phase 1: Environment Setup and Core Services (Week 1)
**Priority: High**
1. Create virtual environment structure with proper .gitignore entries
2. Set up comprehensive environment variable management with .env file
3. Enhance Firebase Admin SDK initialization with better error handling and logging
4. Add comprehensive error handling framework with structured logging
5. Implement authentication middleware for API endpoints with JWT
6. Add rate limiting middleware to prevent API abuse

Deliverables:
- Fully functional development environment
- Proper error handling and logging throughout the application
- Secure API endpoints with authentication

### Phase 2: Enhanced Notification System (Week 2)
**Priority: High**
1. Implement task assignment notifications when tasks are created/assigned in the Flutter app
2. Add notification templates for different task events:
   - Task assignment
   - Task status change
   - Upcoming due dates
   - Task completion
3. Create bulk notification capabilities for announcements to multiple users
4. Implement email notification system for daily/weekly summaries
5. Add notification grouping and categorization for better user experience
6. Implement user preference management for notification types

Deliverables:
- Complete notification system with push and email capabilities
- User-configurable notification preferences
- Notification templates for all task events

### Phase 3: Advanced Task Scheduling (Week 3)
**Priority: Medium**
1. Implement recurring task scheduling with timezone support
2. Create admin interface for managing scheduled jobs via API endpoints
3. Add comprehensive logging and monitoring for scheduled tasks
4. Implement overdue task checking with automatic notifications
5. Add custom scheduled job creation via API with cron expression support

Deliverables:
- Advanced scheduling system with timezone awareness
- Admin APIs for job management
- Comprehensive monitoring and logging

### Phase 4: Analytics and Reporting (Week 4)
**Priority: Medium**
1. Implement user activity analytics collection through API endpoints
2. Create daily/weekly summary email functionality with personalized content
3. Generate productivity insights from task completion data
4. Build APIs for frontend analytics integration with dashboard metrics
5. Implement data aggregation functions for performance reports

Deliverables:
- Complete analytics system with data collection and reporting
- Personalized email summaries
- Dashboard APIs for frontend integration

### Phase 5: Security and Performance (Week 5)
**Priority: High**
1. Implement comprehensive API authentication and authorization with JWT and RBAC
2. Add input validation and sanitization for all endpoints using marshmallow
3. Optimize database queries and implement caching strategies for frequently accessed data
4. Conduct security audit of current implementation with penetration testing
5. Add performance monitoring and metrics collection with Prometheus/Grafana integration

Deliverables:
- Secure API endpoints with proper authentication
- Input validation on all endpoints
- Optimized performance with caching
- Comprehensive monitoring and alerting

## Detailed Feature Implementation

### Task Assignment Notifications
When a task is assigned to a user in the Flutter app:
1. The frontend will call the `/api/notify-task-assignment` endpoint
2. The backend will retrieve user's device token from Firestore
3. A push notification will be sent via FCM with task details
4. The notification will include action buttons for quick responses

Implementation steps:
1. Create a new endpoint `/api/notify-task-assignment` in app.py
2. Add a method in notification_service.py to handle task assignment notifications
3. Query Firestore to get user's device token using Firebase Admin SDK
4. Send notification with task details and action buttons
5. Log notification events for analytics
6. Handle errors gracefully with proper HTTP responses

### Daily/Weekly Summary Emails
1. Schedule daily jobs to collect user activity data from Firestore
2. Generate personalized summaries with:
   - Completed tasks in the period
   - Upcoming deadlines in the next 7 days
   - Overdue tasks requiring attention
   - Productivity insights and trends
3. Send emails using SMTP with responsive HTML templates
4. Allow users to customize email preferences (frequency, content)

Implementation steps:
1. Create email notification service using smtplib and email.mime modules
2. Implement scheduled jobs using APScheduler for daily/weekly summaries
3. Create responsive HTML email templates with inline CSS
4. Add user preference management in Firestore for email notifications
5. Implement email sending with proper error handling and retry logic
6. Add unsubscribe functionality

### User Activity Analytics
1. Track user events through `/api/analytics/event` endpoint
2. Store activity data in dedicated Firestore collections
3. Aggregate data for dashboard metrics using scheduled jobs
4. Generate reports on user engagement and productivity trends

Implementation steps:
1. Create analytics service for tracking user events with timestamp and metadata
2. Implement data aggregation functions using Firestore queries
3. Create dashboard metrics APIs with filtering and grouping capabilities
4. Add scheduled jobs for report generation and data summarization
5. Implement data retention policies with automated cleanup
6. Add export functionality for user data (GDPR compliance)

### Security Enhancements
1. Implement JWT-based authentication for all protected API endpoints
2. Add role-based access control for admin functions and data access
3. Implement input validation using marshmallow or similar validation library
4. Add rate limiting using Flask-Limiter or custom implementation
5. Secure sensitive endpoints with proper authorization checks

Implementation steps:
1. Add JWT authentication middleware with token validation
2. Implement role-based access control with user roles in Firestore
3. Add input validation schemas for all POST/PUT endpoints
4. Configure rate limiting with customizable thresholds
5. Secure admin endpoints with proper authorization checks
6. Add security headers and CORS configuration

### Recurring Task Scheduling
1. Implement timezone-aware scheduling using pytz library
2. Add support for complex recurrence patterns (daily, weekly, monthly, custom)
3. Create management interface for scheduled tasks via REST API
4. Add logging and monitoring for task execution with status tracking

Implementation steps:
1. Enhance task_scheduler.py with timezone support using pytz
2. Add recurrence pattern parsing and validation
3. Create API endpoints for task management (CRUD operations)
4. Implement logging and monitoring with execution status tracking
5. Add task execution history tracking in Firestore
6. Implement task failure handling and retry mechanisms

### Integration with Frontend
1. Create REST APIs for all backend functionality with consistent naming
2. Implement real-time updates using WebSocket connections where appropriate
3. Add file upload/download endpoints with proper validation
4. Create comprehensive API documentation with examples

Implementation steps:
1. Design REST API endpoints based on frontend requirements with proper HTTP methods
2. Implement WebSocket server for real-time notifications using Flask-SocketIO
3. Add file handling endpoints with validation and security checks
4. Create API documentation with Swagger/OpenAPI specification
5. Implement API versioning for future compatibility
6. Add comprehensive error responses with helpful messages

## Development Workflow

### Setting Up the Development Environment
1. Clone the repository
2. Navigate to the python_backend directory
3. Run the setup script: `python setup.py`
4. Activate the virtual environment:
   - Windows: `venv\Scripts\activate`
   - macOS/Linux: `source venv/bin/activate`
5. Install dependencies: `pip install -r requirements.txt`
6. Configure environment variables in .env file based on .env.example
7. Run the development server: `python app.py`

### Code Structure Guidelines
1. Follow the existing modular structure with separate services for distinct functionality
2. Create new services for new features with clear separation of concerns
3. Use dependency injection where appropriate for better testability
4. Implement proper error handling in all functions with try/except blocks
5. Add structured logging for debugging and monitoring with appropriate log levels
6. Write unit tests for all new functionality with pytest or unittest

### Testing Strategy
1. Unit tests for individual functions and services using pytest
2. Integration tests for API endpoints with test client
3. End-to-end tests for critical user flows with mocked external services
4. Performance tests for high-load scenarios with locust or similar tools
5. Security tests for authentication and authorization with OWASP ZAP

### Deployment Process
1. Ensure all tests pass locally and in CI environment
2. Update version numbers in setup.py and any other relevant files
3. Create a deployment package with necessary dependencies
4. Deploy to staging environment for testing with production-like data
5. Deploy to production after validation and approval
6. Monitor application performance and errors with logging and monitoring tools

## Success Metrics

### Technical Metrics
- API response times (< 200ms for 95% of requests)
- Uptime (99.9% target)
- Error rates (< 0.1%)
- Database query performance (< 100ms for 95% of queries)

### Business Metrics
- User engagement with notification features (target: 70% open rate)
- Task completion rates through notifications (target: 20% increase)
- User retention improvements (target: 15% increase in 30-day retention)
- Reduction in support tickets related to backend issues (target: 50% reduction)

### Operational Metrics
- Deployment frequency (target: weekly deployments)
- Mean time to recovery (MTTR) (target: < 30 minutes)
- Change failure rate (target: < 5%)
- System resource utilization (target: < 70% CPU, < 80% memory)

## Risk Assessment and Mitigation

### Technical Risks
- Firebase service limits and quotas (1,000,000 reads/day, 20,000 writes/day)
- Scalability challenges with increased user base (> 10,000 concurrent users)
- Data consistency issues with real-time updates across multiple clients
- Security vulnerabilities in API endpoints with sensitive data

### Mitigation Strategies
- Regular load testing and performance optimization with tools like Apache Bench
- Implementation of caching strategies (Redis) and database optimization (indexes)
- Comprehensive security audits and penetration testing with OWASP ZAP
- Monitoring and alerting for system health with Prometheus and Grafana

### Operational Risks
- Dependency on third-party services (Firebase, email providers like SendGrid)
- Data loss due to system failures or human error
- Performance degradation with increased load during peak usage
- Security breaches from external attacks or insider threats

### Mitigation Strategies
- Implement backup and disaster recovery procedures with daily backups
- Set up monitoring and alerting for all critical systems with PagerDuty or similar
- Regular security audits and updates with automated vulnerability scanning
- Performance testing under various load conditions with stress testing tools

## Environment Setup Instructions

### Creating the Virtual Environment

To set up the Python backend development environment:

1. Navigate to the `python_backend` directory:
   ```bash
   cd python_backend
   ```

2. Create a virtual environment:
   ```bash
   python -m venv venv
   ```

3. Activate the virtual environment:
   - On Windows:
     ```bash
     venv\Scripts\activate
     ```
   - On macOS/Linux:
     ```bash
     source venv/bin/activate
     ```

4. Install the required dependencies:
   ```bash
   pip install -r requirements.txt
   ```

5. Create a `.env` file based on the `.env.example` template:
   ```bash
   cp .env.example .env
   ```

6. Configure the environment variables in the `.env` file with your Firebase credentials and other settings.

### Directory Structure

The Python backend follows this directory structure:

```
python_backend/
├── app.py                  # Main Flask application
├── notification_service.py # FCM notification service
├── task_scheduler.py       # Scheduled task management
├── extract_firebase_config.py # Firebase config extractor
├── setup.py                # Setup script
├── run.py                  # Application runner
├── requirements.txt        # Dependencies
├── .env.example            # Environment variable template
├── .env                    # Environment variables (git ignored)
├── serviceAccountKey.json  # Service account key (git ignored)
├── README.md               # Backend documentation
└── venv/                   # Python virtual environment (git ignored)
    ├── Scripts/            # Windows executables
    ├── bin/                # Unix executables
    ├── lib/                # Library files
    └── pyvenv.cfg          # Virtual environment config
```

### Environment Variables

The following environment variables should be configured in the `.env` file:

| Variable | Description | Required |
|----------|-------------|----------|
| FIREBASE_PROJECT_ID | Firebase project ID | Yes |
| FIREBASE_PRIVATE_KEY | Firebase service account private key | Yes |
| FIREBASE_CLIENT_EMAIL | Firebase service account email | Yes |
| FLASK_ENV | Application environment (development/production) | Yes |
| FLASK_APP | Main application file | Yes |
| EMAIL_HOST | SMTP server for email notifications | No |
| EMAIL_PORT | SMTP port | No |
| EMAIL_USER | SMTP username | No |
| EMAIL_PASSWORD | SMTP password | No |

### Running the Application

To run the application in development mode:

1. Ensure the virtual environment is activated
2. Run the Flask development server:
   ```bash
   python app.py
   ```

The application will be available at `http://localhost:5000`.

### Testing the Application

To run tests (once implemented):

1. Ensure the virtual environment is activated
2. Run the test suite:
   ```bash
   python -m pytest tests/
   ```

## Git Configuration

To ensure proper version control:

1. Add the following to `.gitignore` to exclude sensitive files:
   ```
   # Python virtual environment
   venv/
   
   # Environment variables
   .env
   
   # Firebase service account key
   serviceAccountKey.json
   
   # Python cache
   __pycache__/
   *.pyc
   ```

2. Commit the directory structure with placeholder files where necessary.

## Deployment Considerations

### Production Deployment

For production deployment:

1. Use a production WSGI server like Gunicorn instead of the Flask development server:
   ```bash
   gunicorn --bind 0.0.0.0:5000 app:app
   ```

2. Set environment variables in the production environment rather than using `.env` files.

3. Use a reverse proxy like Nginx for SSL termination and static file serving.

4. Deploy to a cloud platform like Google Cloud Run for seamless Firebase integration.

### Containerization

To containerize the application:

1. Create a `Dockerfile`:
   ```dockerfile
   FROM python:3.9-slim
   
   WORKDIR /app
   
   COPY requirements.txt .
   RUN pip install -r requirements.txt
   
   COPY . .
   
   EXPOSE 5000
   
   CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
   ```

2. Create a `.dockerignore` file:
   ```
   venv/
   .env
   serviceAccountKey.json
   __pycache__/
   *.pyc
   ```

3. Build and run the Docker container:
   ```bash
   docker build -t taskflow-backend .
   docker run -p 5000:5000 taskflow-backend
   ```

## Dependencies Management

### Current Dependencies

The Python backend currently uses the following dependencies:

| Package | Version | Purpose |
|---------|---------|---------|
| firebase-admin | 6.2.0 | Firebase server-side integration |
| flask | 2.3.2 | Web framework |
| flask-cors | 4.0.0 | Cross-Origin Resource Sharing support |
| python-dotenv | 1.0.0 | Environment variable loading |
| apscheduler | 3.10.1 | Task scheduling |

### Additional Dependencies to Install

For the full implementation plan, the following additional dependencies will be needed:

| Package | Purpose |
|---------|---------|
| flask-jwt-extended | JWT authentication for API endpoints |
| marshmallow | Input validation and serialization |
| flask-limiter | Rate limiting for API endpoints |
| gunicorn | Production WSGI server |
| pytest | Testing framework |
| requests | HTTP client for external API calls |
| pytz | Timezone support for scheduled tasks |
| redis | Caching layer for performance optimization |

To install these additional dependencies:

```bash
pip install flask-jwt-extended marshmallow flask-limiter gunicorn pytest requests pytz redis
```

Or add them to the `requirements.txt` file:

```txt
firebase-admin==6.2.0
flask==2.3.2
flask-cors==4.0.0
python-dotenv==1.0.0
apscheduler==3.10.1
flask-jwt-extended==4.5.0
marshmallow==3.19.0
flask-limiter==3.5.0
gunicorn==21.2.0
pytest==7.4.0
requests==2.31.0
pytz==2023.3
redis==4.6.0
```

### Updating Dependencies

To update dependencies to their latest versions:

1. Update `requirements.txt` with the latest versions:
   ```bash
   pip install --upgrade firebase-admin flask flask-cors python-dotenv apscheduler flask-jwt-extended marshmallow flask-limiter gunicorn pytest requests pytz redis
   pip freeze > requirements.txt
   ```

2. Test the application thoroughly after updating dependencies.

3. Commit the updated `requirements.txt` file.

### Dependency Security

To check for security vulnerabilities in dependencies:

1. Install and run `safety`:
   ```bash
   pip install safety
   safety check
   ```

2. Review and address any reported vulnerabilities.

3. Consider using `pip-audit` as an alternative:
   ```bash
   pip install pip-audit
   pip-audit
   ```

## Development Tools

### Code Quality Tools

To maintain code quality, install the following development tools:

```bash
pip install black flake8 mypy
```

| Tool | Purpose |
|------|---------|
| black | Code formatting |
| flake8 | Code linting |
| mypy | Type checking |

### Pre-commit Hooks

To set up pre-commit hooks for code quality:

1. Install pre-commit:
   ```bash
   pip install pre-commit
   ```

2. Create a `.pre-commit-config.yaml` file:
   ```yaml
   repos:
     - repo: https://github.com/psf/black
       rev: 23.3.0
       hooks:
         - id: black
     - repo: https://github.com/pycqa/flake8
       rev: 6.0.0
       hooks:
         - id: flake8
   ```

3. Install the pre-commit hooks:
   ```bash
   pre-commit install
   ```

## Database Integration

### Firebase Firestore Integration

The Python backend integrates with Firebase Firestore for data storage:

1. Initialize Firestore in your service:
   ```python
   import firebase_admin
   from firebase_admin import credentials, firestore
   
   # Initialize Firebase Admin SDK
   cred = credentials.Certificate("serviceAccountKey.json")
   firebase_admin.initialize_app(cred)
   
   # Get Firestore client
   db = firestore.client()
   ```

2. Perform CRUD operations:
   ```python
   # Create a document
   doc_ref = db.collection('users').document('user_id')
   doc_ref.set({
       'name': 'John Doe',
       'email': 'john@example.com'
   })
   
   # Read a document
   doc = doc_ref.get()
   if doc.exists:
       print(f'Document data: {doc.to_dict()}')
   
   # Update a document
   doc_ref.update({
       'last_login': firestore.SERVER_TIMESTAMP
   })
   
   # Delete a document
   doc_ref.delete()
   ```

### Data Modeling

When working with Firestore data, follow these modeling guidelines:

1. Use meaningful collection names (plural form)
2. Use consistent field naming (camelCase)
3. Include timestamps for creation and updates
4. Use references for relationships instead of embedding large objects
5. Denormalize data when necessary for query performance

Example data model for tasks:
```python
task_data = {
    'id': 'task_123',
    'title': 'Complete backend implementation',
    'description': 'Implement all backend features according to the plan',
    'projectId': 'project_456',
    'assigneeId': 'user_789',
    'status': 'in_progress',
    'priority': 'high',
    'dueDate': datetime.datetime(2023, 12, 31, 23, 59, 59),
    'createdAt': firestore.SERVER_TIMESTAMP,
    'updatedAt': firestore.SERVER_TIMESTAMP
}
```

## Summary

This design document provides a comprehensive plan for implementing the TaskFlow Python backend based on the requirements outlined in BACKEND_PLAN.md. The implementation focuses on five key areas:

1. **Environment Setup and Core Services** - Establishing a robust development environment with proper error handling, logging, authentication, and rate limiting.

2. **Enhanced Notification System** - Implementing a complete notification system with push notifications, email summaries, and user preference management.

3. **Advanced Task Scheduling** - Creating a sophisticated task scheduler with timezone support, recurrence patterns, and administrative interfaces.

4. **Analytics and Reporting** - Building a comprehensive analytics system with user activity tracking, productivity insights, and automated reporting.

5. **Security and Performance** - Ensuring the backend is secure, performant, and scalable with proper authentication, input validation, caching, and monitoring.

The implementation plan is organized in 5-week phases, each focusing on specific priorities with clear deliverables and success metrics. The design follows best practices for Python backend development, including modular architecture, comprehensive testing, and proper documentation.

## Next Steps

To begin implementation:

1. Set up the development environment following the instructions in the "Environment Setup Instructions" section
2. Begin with Phase 1 implementation focusing on core infrastructure
3. Follow the weekly roadmap for systematic feature development
4. Implement comprehensive testing as each feature is completed
5. Deploy to production following the deployment guidelines

The design is flexible enough to accommodate future enhancements such as microservices architecture, machine learning integration, and real-time collaboration features as outlined in the long-term vision.
