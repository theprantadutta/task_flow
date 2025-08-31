# TaskFlow Python Backend

This is the Python backend for the TaskFlow application. It handles server-side logic that would typically be done with Firebase Cloud Functions.

## Features

- Scheduled task notifications
- Complex data processing
- Firebase Admin SDK integration
- REST API endpoints
- User analytics and reporting
- Task scheduling with timezone support
- Notification preferences management

## Prerequisites

- Python 3.8 or higher
- Firebase project with Admin SDK credentials
- Virtual environment (recommended)

## Setup

1. Create a virtual environment:
   ```
   python -m venv venv
   ```

2. Activate the virtual environment:
   - On Windows: `venv\Scripts\activate`
   - On macOS/Linux: `source venv/bin/activate`

3. Install dependencies:
   ```
   pip install -r requirements.txt
   ```

4. Set up Firebase Admin SDK credentials:
   - Download the service account key JSON file from Firebase Console
   - Rename it to `serviceAccountKey.json` and place it in the python_backend directory
   - Alternatively, set the following environment variables in a `.env` file:
     ```
     FIREBASE_PROJECT_ID=your-project-id
     FIREBASE_PRIVATE_KEY_ID=your-private-key-id
     FIREBASE_PRIVATE_KEY=your-private-key
     FIREBASE_CLIENT_EMAIL=your-client-email
     FIREBASE_CLIENT_ID=your-client-id
     ```

5. Set up environment variables:
   - Copy `.env.example` to `.env`
   - Update the values in `.env` with your actual credentials

6. Run the server:
   ```
   python app.py
   ```

## Alternative Setup (Using setup.py)

1. Run the setup script:
   ```
   python setup.py
   ```

2. Activate the virtual environment:
   - On Windows: `venv\Scripts\activate`
   - On macOS/Linux: `source venv/bin/activate`

3. Set up Firebase Admin SDK credentials and environment variables (as described above)

4. Run the server:
   ```
   python app.py
   ```

## Running with run.py

You can also use the run script which automatically activates the virtual environment:

```
python run.py
```

## API Documentation

See [API_DOCUMENTATION.md](API_DOCUMENTATION.md) for detailed API endpoint documentation.

## Project Structure

```
python_backend/
├── app.py                  # Main Flask application
├── notification_service.py  # FCM notification service
├── task_scheduler.py       # Scheduled task management
├── analytics_service.py    # User analytics service
├── user_preferences_service.py  # User preferences management
├── scheduled_tasks_service.py   # Scheduled tasks management
├── extract_firebase_config.py   # Firebase config extractor
├── setup.py                # Setup script
├── run.py                  # Application runner
├── requirements.txt        # Dependencies
├── .env.example            # Environment variable template
├── serviceAccountKey.json.template  # Service account key template
├── venv/                   # Virtual environment (git ignored)
├── IMPLEMENTATION_PLAN.md  # Implementation plan
└── API_DOCUMENTATION.md    # API documentation
```

## Environment Variables

The following environment variables can be set in a `.env` file:

- `FIREBASE_PROJECT_ID`: Firebase project ID
- `FIREBASE_PRIVATE_KEY_ID`: Firebase service account private key ID
- `FIREBASE_PRIVATE_KEY`: Firebase service account private key
- `FIREBASE_CLIENT_EMAIL`: Firebase service account email
- `FIREBASE_CLIENT_ID`: Firebase service account client ID
- `JWT_SECRET_KEY`: Secret key for JWT token generation
- `FLASK_ENV`: Flask environment (development/production)
- `FLASK_DEBUG`: Flask debug mode (True/False)

## Development

To run in development mode with auto-reload:
```
FLASK_ENV=development FLASK_DEBUG=1 python app.py
```

## Testing

To test the API endpoints, you can use tools like curl or Postman.

Example health check:
```
curl http://localhost:5000/api/health
```

## Deployment

For production deployment, consider using a WSGI server like Gunicorn:

```
gunicorn -w 4 -b 0.0.0.0:5000 app:app
```

## Security

- Never commit service account keys or sensitive environment variables to version control
- Use strong, random values for JWT_SECRET_KEY
- Implement proper authentication and authorization checks
- Use HTTPS in production