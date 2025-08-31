from flask import Flask, jsonify, request
from flask_cors import CORS
from flask_jwt_extended import JWTManager, jwt_required, create_access_token, get_jwt_identity
import firebase_admin
from firebase_admin import credentials, messaging, auth
from apscheduler.schedulers.background import BackgroundScheduler
import os
from dotenv import load_dotenv
import json
import logging
from functools import wraps
import datetime
from notification_service import notification_service
from task_scheduler import task_scheduler
from analytics_service import analytics_service
from user_preferences_service import user_preferences_service
from scheduled_tasks_service import scheduled_tasks_service

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Load environment variables
load_dotenv()

# Initialize Flask app
app = Flask(__name__)
CORS(app)

# JWT Configuration
app.config['JWT_SECRET_KEY'] = os.getenv('JWT_SECRET_KEY', 'taskflow-secret-key')
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = 3600  # 1 hour
jwt = JWTManager(app)

# Rate limiting variables
request_counts = {}
time_window = 60  # 1 minute
max_requests = 100  # Max requests per time window

def rate_limit(limit=100, window=60):
    """
    Rate limiting decorator
    """
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            client_ip = request.remote_addr
            current_time = datetime.datetime.now().timestamp()
            
            # Initialize client data if not exists
            if client_ip not in request_counts:
                request_counts[client_ip] = []
            
            # Remove old requests outside the time window
            request_counts[client_ip] = [
                req_time for req_time in request_counts[client_ip]
                if current_time - req_time < window
            ]
            
            # Check if limit exceeded
            if len(request_counts[client_ip]) >= limit:
                logger.warning(f"Rate limit exceeded for IP: {client_ip}")
                return jsonify({"error": "Rate limit exceeded"}), 429
            
            # Add current request
            request_counts[client_ip].append(current_time)
            
            return f(*args, **kwargs)
        return decorated_function
    return decorator

def firebase_auth_required(f):
    """
    Firebase authentication decorator
    """
    @wraps(f)
    def decorated_function(*args, **kwargs):
        try:
            auth_header = request.headers.get('Authorization')
            if not auth_header or not auth_header.startswith('Bearer '):
                return jsonify({"error": "Missing or invalid authorization header"}), 401
            
            token = auth_header.split('Bearer ')[1]
            decoded_token = auth.verify_id_token(token)
            request.user = decoded_token
            return f(*args, **kwargs)
        except auth.InvalidIdTokenError:
            return jsonify({"error": "Invalid Firebase ID token"}), 401
        except Exception as e:
            logger.error(f"Authentication error: {e}")
            return jsonify({"error": "Authentication failed"}), 401
    return decorated_function

# Initialize Firebase Admin SDK
# You'll need to download the service account key from Firebase Console
# and place it in the project directory
try:
    if os.path.exists("serviceAccountKey.json"):
        cred = credentials.Certificate("serviceAccountKey.json")
        firebase_admin.initialize_app(cred)
        logger.info("Firebase Admin SDK initialized successfully")
    else:
        # Try to initialize with environment variables
        project_id = os.getenv('FIREBASE_PROJECT_ID')
        private_key = os.getenv('FIREBASE_PRIVATE_KEY')
        client_email = os.getenv('FIREBASE_CLIENT_EMAIL')
        
        if project_id and private_key and client_email:
            service_account_info = {
                "type": "service_account",
                "project_id": project_id,
                "private_key": private_key.replace('\\n', '\n'),
                "client_email": client_email,
                "client_id": os.getenv('FIREBASE_CLIENT_ID', ''),
                "auth_uri": os.getenv('FIREBASE_AUTH_URI', 'https://accounts.google.com/o/oauth2/auth'),
                "token_uri": os.getenv('FIREBASE_TOKEN_URI', 'https://oauth2.googleapis.com/token'),
                "auth_provider_x509_cert_url": os.getenv('FIREBASE_AUTH_PROVIDER_X509_CERT_URL', 'https://www.googleapis.com/oauth2/v1/certs'),
                "client_x509_cert_url": os.getenv('FIREBASE_CLIENT_X509_CERT_URL', '')
            }
            cred = credentials.Certificate(service_account_info)
            firebase_admin.initialize_app(cred)
            logger.info("Firebase Admin SDK initialized successfully with environment variables")
        else:
            logger.warning("serviceAccountKey.json not found and environment variables not set, using default credentials")
            firebase_admin.initialize_app()
except Exception as e:
    logger.error(f"Failed to initialize Firebase Admin SDK: {e}")

# Initialize scheduler
scheduler = BackgroundScheduler()
scheduler.start()

@app.route('/')
def home():
    return jsonify({"message": "TaskFlow Python Backend is running"})

@app.route('/api/health')
@rate_limit()
def health_check():
    return jsonify({"status": "healthy", "timestamp": datetime.datetime.utcnow().isoformat()})

@app.route('/api/login', methods=['POST'])
@rate_limit()
def login():
    try:
        data = request.get_json()
        firebase_token = data.get('firebase_token')
        
        if not firebase_token:
            return jsonify({"error": "Firebase token is required"}), 400
        
        # Verify Firebase token
        decoded_token = auth.verify_id_token(firebase_token)
        user_id = decoded_token['uid']
        
        # Create access token
        access_token = create_access_token(identity=user_id)
        
        return jsonify({
            "success": True,
            "access_token": access_token,
            "user_id": user_id
        })
        
    except auth.InvalidIdTokenError:
        return jsonify({"error": "Invalid Firebase token"}), 401
    except Exception as e:
        logger.error(f"Login error: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/api/send-notification', methods=['POST'])
@jwt_required()
@rate_limit()
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
        logger.error(f"Send notification error: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/api/send-topic-notification', methods=['POST'])
@jwt_required()
@rate_limit()
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
        logger.error(f"Send topic notification error: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/api/notify-task-assignment', methods=['POST'])
@jwt_required()
@rate_limit()
def notify_task_assignment():
    try:
        data = request.get_json()
        
        # Extract task assignment data
        assignee_token = data.get('assigneeToken')
        task_title = data.get('taskTitle')
        project_name = data.get('projectName')
        due_date = data.get('dueDate')
        
        if not assignee_token or not task_title or not project_name:
            return jsonify({"error": "assigneeToken, taskTitle, and projectName are required"}), 400
        
        # Check user preferences
        # In a real implementation, you would get the user ID from the token
        # For now, we'll assume it's in the request
        user_id = data.get('userId', 'default_user')
        if not user_preferences_service.should_send_notification(user_id, "task_assignment"):
            return jsonify({"success": True, "message": "Notification suppressed by user preferences"})
        
        # Send task assignment notification
        response = notification_service.send_task_assignment_notification(
            assignee_token, task_title, project_name, due_date
        )
        return jsonify({"success": True, "message_id": response})
        
    except Exception as e:
        logger.error(f"Notify task assignment error: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/api/send-bulk-notifications', methods=['POST'])
@jwt_required()
@rate_limit()
def send_bulk_notifications():
    try:
        data = request.get_json()
        
        # Extract bulk notification data
        tokens = data.get('tokens', [])
        title = data.get('title', 'TaskFlow Notification')
        body = data.get('body', '')
        
        if not tokens:
            return jsonify({"error": "Tokens are required"}), 400
        
        # Send bulk notifications
        response = notification_service.send_bulk_notifications(tokens, title, body)
        return jsonify({"success": True, "result": response})
        
    except Exception as e:
        logger.error(f"Send bulk notifications error: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/api/analytics/event', methods=['POST'])
@jwt_required()
@rate_limit()
def record_analytics_event():
    try:
        data = request.get_json()
        user_id = data.get('userId')
        event_type = data.get('eventType')
        event_data = data.get('eventData', {})
        
        if not user_id or not event_type:
            return jsonify({"error": "userId and eventType are required"}), 400
        
        # Record the event
        event_id = analytics_service.record_user_activity(user_id, event_type, event_data)
        return jsonify({"success": True, "eventId": event_id})
        
    except Exception as e:
        logger.error(f"Record analytics event error: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/api/analytics/user-summary', methods=['GET'])
@jwt_required()
@rate_limit()
def get_user_summary():
    try:
        user_id = request.args.get('userId')
        period = request.args.get('period', 'weekly')
        
        if not user_id:
            return jsonify({"error": "userId is required"}), 400
        
        # Get user summary
        summary = analytics_service.get_user_summary(user_id, period)
        return jsonify(summary)
        
    except Exception as e:
        logger.error(f"Get user summary error: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/api/users/<user_id>/preferences', methods=['GET'])
@jwt_required()
@rate_limit()
def get_user_preferences(user_id):
    try:
        # Get user preferences
        preferences = user_preferences_service.get_user_preferences(user_id)
        return jsonify({"userId": user_id, "preferences": preferences})
        
    except Exception as e:
        logger.error(f"Get user preferences error: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/api/users/<user_id>/preferences', methods=['PUT'])
@jwt_required()
@rate_limit()
def update_user_preferences(user_id):
    try:
        data = request.get_json()
        preferences = data.get('preferences', {})
        
        # Update user preferences
        success = user_preferences_service.update_user_preferences(user_id, preferences)
        
        if success:
            return jsonify({"success": True, "message": "Preferences updated successfully"})
        else:
            return jsonify({"success": False, "message": "Failed to update preferences"}), 500
        
    except Exception as e:
        logger.error(f"Update user preferences error: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/api/scheduled-tasks', methods=['POST'])
@jwt_required()
@rate_limit()
def create_scheduled_task():
    try:
        data = request.get_json()
        
        # Create scheduled task
        result = scheduled_tasks_service.create_scheduled_task(data)
        return jsonify(result)
        
    except Exception as e:
        logger.error(f"Create scheduled task error: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/api/scheduled-tasks', methods=['GET'])
@jwt_required()
@rate_limit()
def get_scheduled_tasks():
    try:
        # Get all scheduled tasks
        tasks = scheduled_tasks_service.get_scheduled_tasks()
        return jsonify({"tasks": tasks})
        
    except Exception as e:
        logger.error(f"Get scheduled tasks error: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/api/scheduled-tasks/<task_id>', methods=['DELETE'])
@jwt_required()
@rate_limit()
def delete_scheduled_task(task_id):
    try:
        # Delete scheduled task
        success = scheduled_tasks_service.delete_scheduled_task(task_id)
        
        if success:
            return jsonify({"success": True, "message": "Task deleted successfully"})
        else:
            return jsonify({"success": False, "message": "Failed to delete task"}), 500
        
    except Exception as e:
        logger.error(f"Delete scheduled task error: {e}")
        return jsonify({"error": str(e)}), 500

# Example scheduled job
def scheduled_task_reminder():
    """Send reminders for overdue tasks"""
    logger.info("Checking for overdue tasks...")
    # This would contain logic to query Firebase for overdue tasks
    # and send notifications to users
    
    try:
        # Example notification to a topic
        response = notification_service.send_notification_to_topic(
            "task-reminders",
            "Task Reminder",
            "You have tasks that need attention"
        )
        logger.info(f"Successfully sent scheduled notification: {response}")
    except Exception as e:
        logger.error(f"Error sending scheduled notification: {e}")

# Schedule the task reminder to run every 30 minutes
task_scheduler.schedule_overdue_task_check(scheduled_task_reminder, 30)

# Error handlers
@app.errorhandler(404)
def not_found(error):
    return jsonify({"error": "Not found"}), 404

@app.errorhandler(500)
def internal_error(error):
    logger.error(f"Internal server error: {error}")
    return jsonify({"error": "Internal server error"}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)