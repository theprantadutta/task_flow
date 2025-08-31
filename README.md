# TaskFlow - Team Productivity & Project Management App

TaskFlow is a collaborative project management application built with Flutter and Firebase, designed to help teams organize and track their work through an intuitive Kanban-style interface.

## Features

- **User Authentication**: Email/password and Google Sign-In
- **User Profile Management**: Profile pictures and personal information
- **Workspace Management**: Create workspaces and invite team members
- **Project Management**: Organize work into projects
- **Task Management**: Kanban-style board with drag-and-drop functionality
- **Role-Based Access Control**: Admin/Member permissions
- **Push Notifications**: Real-time updates for task assignments
- **Analytics**: User engagement tracking

## Tech Stack

### Frontend
- **Flutter SDK** with Material Design
- **State Management**: Bloc pattern
- **Firebase Services**: Auth, Firestore, Storage, Cloud Messaging, Analytics, Performance Monitoring

### Backend
- **Python Flask** for server-side logic
- **Firebase Admin SDK** for backend Firebase operations
- **APScheduler** for job scheduling

## Project Structure

```
lib/
├── main.dart
├── core/
│   ├── constants/
│   ├── utils/
│   └── themes/
├── features/
│   ├── auth/
│   ├── profile/
│   ├── workspace/
│   ├── project/
│   └── task/
├── shared/
│   ├── models/
│   ├── widgets/
│   └── services/
└── routes/
```

## Python Backend

The `python_backend` directory contains a Flask application that handles server-side logic:

```
python_backend/
├── app.py              # Main Flask application
├── requirements.txt    # Python dependencies
├── notification_service.py  # FCM notification service
├── task_scheduler.py   # Scheduled task management
├── setup.py            # Setup script
└── run.py              # Run script
```

## Getting Started

1. **Flutter Setup**:
   ```bash
   flutter pub get
   ```

2. **Firebase Configuration**:
   - Add `google-services.json` to `android/app/`
   - Add `GoogleService-Info.plist` to `ios/Runner/`

3. **Python Backend Setup**:
   ```bash
   cd python_backend
   python setup.py
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   pip install -r requirements.txt
   python app.py
   ```

## Implementation Status

This project is currently in development. See [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md) for details on what has been implemented.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.