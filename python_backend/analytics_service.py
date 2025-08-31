"""
Analytics Service for TaskFlow Python Backend
"""

import logging
from datetime import datetime, timedelta
from typing import Dict, List, Optional
import json

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class AnalyticsService:
    def __init__(self):
        """Initialize the analytics service"""
        self.events = []  # In a real implementation, this would be a database
        logger.info("Analytics service initialized")
    
    def record_user_activity(self, user_id: str, event_type: str, event_data: Dict = None) -> str:
        """
        Record a user activity event
        
        Args:
            user_id: User ID
            event_type: Type of event
            event_data: Additional event data
            
        Returns:
            Event ID
        """
        try:
            event = {
                "event_id": f"event_{len(self.events) + 1}",
                "user_id": user_id,
                "event_type": event_type,
                "event_data": event_data or {},
                "timestamp": datetime.utcnow().isoformat()
            }
            
            self.events.append(event)
            logger.info(f"Recorded user activity: {event_type} for user {user_id}")
            return event["event_id"]
            
        except Exception as e:
            logger.error(f"Failed to record user activity: {e}")
            raise Exception(f"Failed to record user activity: {e}")
    
    def get_user_summary(self, user_id: str, period: str = "weekly") -> Dict:
        """
        Get user activity summary
        
        Args:
            user_id: User ID
            period: Time period (daily, weekly, monthly)
            
        Returns:
            User summary data
        """
        try:
            # Calculate time range
            end_time = datetime.utcnow()
            if period == "daily":
                start_time = end_time - timedelta(days=1)
            elif period == "weekly":
                start_time = end_time - timedelta(weeks=1)
            elif period == "monthly":
                start_time = end_time - timedelta(days=30)
            else:
                start_time = end_time - timedelta(weeks=1)  # Default to weekly
            
            # Filter events for user and time period
            user_events = [
                event for event in self.events
                if event["user_id"] == user_id and
                datetime.fromisoformat(event["timestamp"].replace('Z', '+00:00')) >= start_time
            ]
            
            # Calculate summary statistics
            tasks_completed = len([
                event for event in user_events
                if event["event_type"] == "task_completed"
            ])
            
            projects_active = len(set([
                event["event_data"].get("project_id") for event in user_events
                if event["event_data"].get("project_id")
            ]))
            
            # Calculate hours worked (simplified)
            hours_worked = len(user_events) * 0.5  # Assume 30 minutes per activity
            
            # Calculate productivity score (simplified)
            productivity_score = min(10, tasks_completed * 2 + hours_worked * 0.2)
            
            # Calculate trends (simplified)
            completion_rate = tasks_completed / max(1, len(user_events)) if user_events else 0
            improvement = completion_rate * 0.1  # Simplified improvement calculation
            
            summary = {
                "user_id": user_id,
                "period": period,
                "summary": {
                    "tasksCompleted": tasks_completed,
                    "projectsActive": projects_active,
                    "hoursWorked": round(hours_worked, 1),
                    "productivityScore": round(productivity_score, 1)
                },
                "trends": {
                    "completionRate": round(completion_rate, 2),
                    "improvement": round(improvement, 2)
                }
            }
            
            logger.info(f"Generated user summary for {user_id} ({period})")
            return summary
            
        except Exception as e:
            logger.error(f"Failed to generate user summary: {e}")
            raise Exception(f"Failed to generate user summary: {e}")
    
    def generate_daily_summary(self, user_id: str) -> Dict:
        """
        Generate daily summary for a user
        
        Args:
            user_id: User ID
            
        Returns:
            Daily summary data
        """
        return self.get_user_summary(user_id, "daily")
    
    def generate_weekly_report(self, user_id: str) -> Dict:
        """
        Generate weekly report for a user
        
        Args:
            user_id: User ID
            
        Returns:
            Weekly report data
        """
        return self.get_user_summary(user_id, "weekly")
    
    def get_all_events(self) -> List[Dict]:
        """
        Get all recorded events (for admin purposes)
        
        Returns:
            List of all events
        """
        return self.events

# Global instance
analytics_service = AnalyticsService()