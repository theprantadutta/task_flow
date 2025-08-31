"""
User Preferences Service for TaskFlow Python Backend
"""

import logging
from typing import Dict, Any
import json

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class UserPreferencesService:
    def __init__(self):
        """Initialize the user preferences service"""
        # In a real implementation, this would be a database
        self.user_preferences = {}
        logger.info("User preferences service initialized")
    
    def get_user_preferences(self, user_id: str) -> Dict[str, Any]:
        """
        Get user notification preferences
        
        Args:
            user_id: User ID
            
        Returns:
            User preferences
        """
        try:
            # Return default preferences if user has none
            if user_id not in self.user_preferences:
                default_preferences = {
                    "emailNotifications": True,
                    "pushNotifications": True,
                    "dailySummary": True,
                    "weeklySummary": True,
                    "taskAssignment": True,
                    "taskDueDate": True,
                    "emailFrequency": "daily"
                }
                self.user_preferences[user_id] = default_preferences
                logger.info(f"Created default preferences for user {user_id}")
            
            logger.info(f"Retrieved preferences for user {user_id}")
            return self.user_preferences[user_id]
            
        except Exception as e:
            logger.error(f"Failed to get user preferences: {e}")
            raise Exception(f"Failed to get user preferences: {e}")
    
    def update_user_preferences(self, user_id: str, preferences: Dict[str, Any]) -> bool:
        """
        Update user notification preferences
        
        Args:
            user_id: User ID
            preferences: New preferences
            
        Returns:
            Success status
        """
        try:
            # Initialize user preferences if they don't exist
            if user_id not in self.user_preferences:
                self.user_preferences[user_id] = {}
            
            # Update preferences
            self.user_preferences[user_id].update(preferences)
            logger.info(f"Updated preferences for user {user_id}")
            return True
            
        except Exception as e:
            logger.error(f"Failed to update user preferences: {e}")
            raise Exception(f"Failed to update user preferences: {e}")
    
    def should_send_notification(self, user_id: str, notification_type: str) -> bool:
        """
        Check if a notification should be sent to a user
        
        Args:
            user_id: User ID
            notification_type: Type of notification
            
        Returns:
            Whether notification should be sent
        """
        try:
            preferences = self.get_user_preferences(user_id)
            
            # Map notification types to preference keys
            preference_map = {
                "task_assignment": "taskAssignment",
                "task_due_date": "taskDueDate",
                "daily_summary": "dailySummary",
                "weekly_summary": "weeklySummary"
            }
            
            preference_key = preference_map.get(notification_type, notification_type)
            return preferences.get(preference_key, True)
            
        except Exception as e:
            logger.error(f"Failed to check notification preference: {e}")
            # Default to sending notification if there's an error
            return True

# Global instance
user_preferences_service = UserPreferencesService()