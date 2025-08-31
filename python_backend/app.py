from flask import Flask, jsonify, request
from flask_cors import CORS
import firebase_admin
from firebase_admin import credentials, messaging
from apscheduler.schedulers.background import BackgroundScheduler
import os
from dotenv import load_dotenv
import json
from notification_service import notification_service
from task_scheduler import task_scheduler

# Load environment variables
load_dotenv()

# Initialize Flask app
app = Flask(__name__)
CORS(app)

# Initialize Firebase Admin SDK
# You'll need to download the service account key from Firebase Console
# and place it in the project directory
try:
    if os.path.exists("serviceAccountKey.json"):
        cred = credentials.Certificate("serviceAccountKey.json")
        firebase_admin.initialize_app(cred)
        print("Firebase Admin SDK initialized successfully")
    else:
        print("serviceAccountKey.json not found, using default credentials")
        firebase_admin.initialize_app()
except Exception as e:
    print(f"Failed to initialize Firebase Admin SDK: {e}")

# Initialize scheduler
scheduler = BackgroundScheduler()
scheduler.start()

@app.route('/')
def home():
    return jsonify({"message": "TaskFlow Python Backend is running"})

@app.route('/api/health')
def health_check():
    return jsonify({"status": "healthy"})

@app.route('/api/send-notification', methods=['POST'])
def send_notification():
    try:
        data = request.get_json()
        
        # Extract notification data
        token = data.get('token')
        title = data.get('title', 'TaskFlow Notification')
        body = data.get('body', '')
        
        if not token:
            return jsonify({"error": "Device token is required"}), 400
        
        # Send notification
        response = notification_service.send_notification_to_user(token, title, body)
        return jsonify({"success": True, "message_id": response})
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/send-topic-notification', methods=['POST'])
def send_topic_notification():
    try:
        data = request.get_json()
        
        # Extract notification data
        topic = data.get('topic')
        title = data.get('title', 'TaskFlow Notification')
        body = data.get('body', '')
        
        if not topic:
            return jsonify({"error": "Topic is required"}), 400
        
        # Send notification
        response = notification_service.send_notification_to_topic(topic, title, body)
        return jsonify({"success": True, "message_id": response})
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# Example scheduled job
def scheduled_task_reminder():
    """Send reminders for overdue tasks"""
    print("Checking for overdue tasks...")
    # This would contain logic to query Firebase for overdue tasks
    # and send notifications to users
    
    try:
        # Example notification to a topic
        response = notification_service.send_notification_to_topic(
            "task-reminders",
            "Task Reminder",
            "You have tasks that need attention"
        )
        print(f"Successfully sent scheduled notification: {response}")
    except Exception as e:
        print(f"Error sending scheduled notification: {e}")

# Schedule the task reminder to run every 30 minutes
task_scheduler.schedule_overdue_task_check(scheduled_task_reminder, 30)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)