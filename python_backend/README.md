# TaskFlow Python Backend

This is the Python backend for the TaskFlow application. It handles server-side logic that would typically be done with Firebase Cloud Functions.

## Features

- Scheduled task notifications
- Complex data processing
- Firebase Admin SDK integration
- REST API endpoints

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

4. Set up Firebase Admin SDK credentials

5. Run the server:
   ```
   python app.py
   ```