"""
Notification Service for TaskFlow Python Backend
"""

import firebase_admin
from firebase_admin import credentials, messaging
from typing import List, Optional
import os
import json
import logging

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class NotificationService:
    def __init__(self):
        """Initialize the notification service"""
        self.initialized = False
        self._initialize_firebase()
    
    def _initialize_firebase(self):
        """Initialize Firebase Admin SDK with better error handling"""
        try:
            if firebase_admin._apps:
                logger.info("Firebase Admin SDK already initialized")
                self.initialized = True
                return
            
            # Try to initialize with service account key
            service_account_path = os.path.join(os.path.dirname(__file__), 'serviceAccountKey.json')
            
            if os.path.exists(service_account_path):
                cred = credentials.Certificate(service_account_path)
                firebase_admin.initialize_app(cred)
                logger.info("Firebase Admin SDK initialized successfully with service account key")
                self.initialized = True
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
                    self.initialized = True
                else:
                    # Fallback to default credentials (for development)
                    logger.warning("Service account key not found and environment variables not set, using default credentials")
                    firebase_admin.initialize_app()
                    self.initialized = True
                    
        except Exception as e:
            logger.error(f"Failed to initialize Firebase Admin SDK: {e}")
            self.initialized = False
    
    def send_notification_to_user(self, token: str, title: str, body: str, data: Optional[dict] = None) -> str:
        """
        Send a notification to a specific user
        
        Args:
            token: Device registration token
            title: Notification title
            body: Notification body
            data: Optional data payload
            
        Returns:
            Message ID of the sent notification
        """
        if not self.initialized:
            raise Exception("Notification service not initialized")
        
        try:
            message = messaging.Message(
                notification=messaging.Notification(
                    title=title,
                    body=body,
                ),
                data=data or {},
                token=token,
            )
            
            response = messaging.send(message)
            logger.info(f"Notification sent successfully to user: {response}")
            return response
            
        except Exception as e:
            logger.error(f"Failed to send notification: {e}")
            raise Exception(f"Failed to send notification: {e}")
    
    def send_notification_to_topic(self, topic: str, title: str, body: str, data: Optional[dict] = None) -> str:
        """
        Send a notification to a topic
        
        Args:
            topic: Topic name
            title: Notification title
            body: Notification body
            data: Optional data payload
            
        Returns:
            Message ID of the sent notification
        """
        if not self.initialized:
            raise Exception("Notification service not initialized")
        
        try:
            message = messaging.Message(
                notification=messaging.Notification(
                    title=title,
                    body=body,
                ),
                data=data or {},
                topic=topic,
            )
            
            response = messaging.send(message)
            logger.info(f"Notification sent successfully to topic {topic}: {response}")
            return response
            
        except Exception as e:
            logger.error(f"Failed to send notification to topic {topic}: {e}")
            raise Exception(f"Failed to send notification to topic: {e}")
    
    def send_bulk_notifications(self, tokens: List[str], title: str, body: str, data: Optional[dict] = None) -> dict:
        """
        Send notifications to multiple users
        
        Args:
            tokens: List of device registration tokens
            title: Notification title
            body: Notification body
            data: Optional data payload
            
        Returns:
            Dictionary with success and failure counts
        """
        if not self.initialized:
            raise Exception("Notification service not initialized")
        
        try:
            # Split tokens into batches of 500 (FCM limit)
            batch_size = 500
            success_count = 0
            failure_count = 0
            
            for i in range(0, len(tokens), batch_size):
                batch_tokens = tokens[i:i + batch_size]
                
                message = messaging.MulticastMessage(
                    notification=messaging.Notification(
                        title=title,
                        body=body,
                    ),
                    data=data or {},
                    tokens=batch_tokens,
                )
                
                response = messaging.send_multicast(message)
                success_count += response.success_count
                failure_count += response.failure_count
                
            logger.info(f"Bulk notifications sent - Success: {success_count}, Failures: {failure_count}")
            return {
                "success_count": success_count,
                "failure_count": failure_count
            }
            
        except Exception as e:
            logger.error(f"Failed to send bulk notifications: {e}")
            raise Exception(f"Failed to send bulk notifications: {e}")

    def send_task_assignment_notification(self, user_token: str, task_title: str, project_name: str, due_date: str = None) -> str:
        """
        Send a task assignment notification to a user
        
        Args:
            user_token: Device registration token
            task_title: Title of the assigned task
            project_name: Name of the project the task belongs to
            due_date: Optional due date for the task
            
        Returns:
            Message ID of the sent notification
        """
        if not self.initialized:
            raise Exception("Notification service not initialized")
        
        try:
            title = "New Task Assigned"
            body = f"You have been assigned a new task: {task_title} in {project_name}"
            if due_date:
                body += f" (Due: {due_date})"
            
            data = {
                "type": "task_assignment",
                "task_title": task_title,
                "project_name": project_name
            }
            
            if due_date:
                data["due_date"] = due_date
            
            return self.send_notification_to_user(user_token, title, body, data)
            
        except Exception as e:
            logger.error(f"Failed to send task assignment notification: {e}")
            raise Exception(f"Failed to send task assignment notification: {e}")

# Global instance
notification_service = NotificationService()