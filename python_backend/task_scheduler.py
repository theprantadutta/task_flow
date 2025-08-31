"""
Task Scheduler Service for TaskFlow Python Backend
"""

from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.cron import CronTrigger
import atexit
from datetime import datetime
from typing import Callable, Optional

class TaskScheduler:
    def __init__(self):
        """Initialize the task scheduler"""
        self.scheduler = BackgroundScheduler()
        self.scheduler.start()
        
        # Shut down the scheduler when exiting the app
        atexit.register(lambda: self.scheduler.shutdown())
    
    def schedule_daily_task_reminders(self, func: Callable, hour: int = 9, minute: int = 0):
        """
        Schedule daily task reminders
        
        Args:
            func: Function to call
            hour: Hour to run (24-hour format)
            minute: Minute to run
        """
        trigger = CronTrigger(hour=hour, minute=minute)
        self.scheduler.add_job(func, trigger, id='daily_task_reminders')
    
    def schedule_weekly_report(self, func: Callable, day_of_week: str = 'mon', hour: int = 9, minute: int = 0):
        """
        Schedule weekly reports
        
        Args:
            func: Function to call
            day_of_week: Day of week (mon, tue, wed, thu, fri, sat, sun)
            hour: Hour to run (24-hour format)
            minute: Minute to run
        """
        trigger = CronTrigger(day_of_week=day_of_week, hour=hour, minute=minute)
        self.scheduler.add_job(func, trigger, id='weekly_report')
    
    def schedule_overdue_task_check(self, func: Callable, interval_minutes: int = 30):
        """
        Schedule periodic overdue task checks
        
        Args:
            func: Function to call
            interval_minutes: Interval in minutes
        """
        self.scheduler.add_job(
            func, 
            'interval', 
            minutes=interval_minutes, 
            id='overdue_task_check'
        )
    
    def schedule_custom_task(self, func: Callable, cron_expression: str, job_id: str):
        """
        Schedule a custom task with a cron expression
        
        Args:
            func: Function to call
            cron_expression: Cron expression
            job_id: Unique job identifier
        """
        trigger = CronTrigger.from_crontab(cron_expression)
        self.scheduler.add_job(func, trigger, id=job_id)
    
    def remove_job(self, job_id: str):
        """
        Remove a scheduled job
        
        Args:
            job_id: Job identifier
        """
        try:
            self.scheduler.remove_job(job_id)
        except Exception as e:
            print(f"Failed to remove job {job_id}: {e}")
    
    def get_jobs(self):
        """
        Get all scheduled jobs
        
        Returns:
            List of jobs
        """
        return self.scheduler.get_jobs()

# Global instance
task_scheduler = TaskScheduler()