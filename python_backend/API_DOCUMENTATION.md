# TaskFlow Python Backend API Documentation

## Base URL
```
http://localhost:5000/api
```

## Authentication
All protected endpoints require a JWT token in the Authorization header:
```
Authorization: Bearer <token>
```

To obtain a JWT token, first authenticate with Firebase on the client side, then call the login endpoint with the Firebase token.

## API Endpoints

### Health Check

#### GET /api/health
Check the health status of the backend service.

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2023-07-15T10:30:00Z"
}
```

### Authentication

#### POST /api/login
Exchange a Firebase ID token for a JWT token.

**Request Body:**
```json
{
  "firebase_token": "firebase_id_token"
}
```

**Response:**
```json
{
  "success": true,
  "access_token": "jwt_access_token",
  "user_id": "user_123"
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
  "body": "Notification Body"
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
  "body": "Notification Body"
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
  "assigneeToken": "device_registration_token",
  "taskTitle": "Complete backend implementation",
  "projectName": "TaskFlow Backend",
  "dueDate": "2023-12-31T23:59:59Z",
  "userId": "user_123"
}
```

**Response:**
```json
{
  "success": true,
  "message_id": "message_id"
}
```

#### POST /api/send-bulk-notifications
Send notifications to multiple users.

**Request Body:**
```json
{
  "tokens": ["token1", "token2", "token3"],
  "title": "Notification Title",
  "body": "Notification Body"
}
```

**Response:**
```json
{
  "success": true,
  "result": {
    "success_count": 3,
    "failure_count": 0
  }
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

### User Preferences Endpoints

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