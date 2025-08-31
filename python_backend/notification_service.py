"""
Notification Service for TaskFlow Python Backend
"""

import firebase_admin
from firebase_admin import messaging
from typing import List, Optional

class NotificationService:
    def __init__(self):
        """Initialize the notification service"""
        if not firebase_admin._apps:
            try:
                # Initialize with default credentials
                # In production, you would use a service account key
                firebase_admin.initialize_app()
                self.initialized = True
            except Exception as e:
                print(f"Failed to initialize Firebase Admin SDK: {e}")
                self.initialized = False
        else:
            self.initialized = True
    
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
            return response
            
        except Exception as e:
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
            return response
            
        except Exception as e:
            raise Exception(f"Failed to send notification to topic: {e}")
    
    def send_bulk_notifications(self, tokens: List[str], title: str, body: str, data: Optional[dict] = None) -> List[str]:
        """
        Send notifications to multiple users
        
        Args:
            tokens: List of device registration tokens
            title: Notification title
            body: Notification body
            data: Optional data payload
            
        Returns:
            List of message IDs
        """
        if not self.initialized:
            raise Exception("Notification service not initialized")
        
        try:
            # Split tokens into batches of 500 (FCM limit)
            batch_size = 500
            responses = []
            
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
                responses.extend(response.success_count * [None])  # Simplified response handling
                
            return responses
            
        except Exception as e:
            raise Exception(f"Failed to send bulk notifications: {e}")

# Global instance
notification_service = NotificationService()