"""
Task Scheduler Service for TaskFlow Python Backend
"""

from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.cron import CronTrigger
from apscheduler.triggers.interval import IntervalTrigger
import atexit
from datetime import datetime
import pytz
from typing import Callable, Optional
import logging

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class TaskScheduler:
    def __init__(self):
        """Initialize the task scheduler"""
        self.scheduler = BackgroundScheduler()
        self.scheduler.start()
        
        # Shut down the scheduler when exiting the app
        atexit.register(lambda: self.scheduler.shutdown())
        logger.info("Task scheduler initialized")
    
    def schedule_daily_task_reminders(self, func: Callable, hour: int = 9, minute: int = 0, timezone: str = 'UTC'):
        """
        Schedule daily task reminders
        
        Args:
            func: Function to call
            hour: Hour to run (24-hour format)
            minute: Minute to run
            timezone: Timezone for scheduling (default: UTC)
        """
        try:
            tz = pytz.timezone(timezone)
            trigger = CronTrigger(hour=hour, minute=minute, timezone=tz)
            job = self.scheduler.add_job(func, trigger, id='daily_task_reminders')
            logger.info(f"Daily task reminders scheduled for {hour}:{minute} in timezone {timezone}")
            return job
        except Exception as e:
            logger.error(f"Failed to schedule daily task reminders: {e}")
            raise
    
    def schedule_weekly_report(self, func: Callable, day_of_week: str = 'mon', hour: int = 9, minute: int = 0, timezone: str = 'UTC'):
        """
        Schedule weekly reports
        
        Args:
            func: Function to call
            day_of_week: Day of week (mon, tue, wed, thu, fri, sat, sun)
            hour: Hour to run (24-hour format)
            minute: Minute to run
            timezone: Timezone for scheduling (default: UTC)
        """
        try:
            tz = pytz.timezone(timezone)
            trigger = CronTrigger(day_of_week=day_of_week, hour=hour, minute=minute, timezone=tz)
            job = self.scheduler.add_job(func, trigger, id='weekly_report')
            logger.info(f"Weekly report scheduled for {day_of_week} at {hour}:{minute} in timezone {timezone}")
            return job
        except Exception as e:
            logger.error(f"Failed to schedule weekly report: {e}")
            raise
    
    def schedule_overdue_task_check(self, func: Callable, interval_minutes: int = 30):
        """
        Schedule periodic overdue task checks
        
        Args:
            func: Function to call
            interval_minutes: Interval in minutes
        """
        try:
            trigger = IntervalTrigger(minutes=interval_minutes)
            job = self.scheduler.add_job(func, trigger, id='overdue_task_check')
            logger.info(f"Overdue task check scheduled every {interval_minutes} minutes")
            return job
        except Exception as e:
            logger.error(f"Failed to schedule overdue task check: {e}")
            raise
    
    def schedule_custom_task(self, func: Callable, cron_expression: str, job_id: str, timezone: str = 'UTC'):
        """
        Schedule a custom task with a cron expression
        
        Args:
            func: Function to call
            cron_expression: Cron expression
            job_id: Unique job identifier
            timezone: Timezone for scheduling (default: UTC)
        """
        try:
            tz = pytz.timezone(timezone)
            trigger = CronTrigger.from_crontab(cron_expression, timezone=tz)
            job = self.scheduler.add_job(func, trigger, id=job_id)
            logger.info(f"Custom task {job_id} scheduled with cron expression {cron_expression} in timezone {timezone}")
            return job
        except Exception as e:
            logger.error(f"Failed to schedule custom task {job_id}: {e}")
            raise
    
    def schedule_recurring_task(self, func: Callable, task_id: str, cron_expression: str, timezone: str = 'UTC'):
        """
        Schedule a recurring task with a cron expression
        
        Args:
            func: Function to call
            task_id: Unique task identifier
            cron_expression: Cron expression
            timezone: Timezone for scheduling (default: UTC)
        """
        try:
            tz = pytz.timezone(timezone)
            trigger = CronTrigger.from_crontab(cron_expression, timezone=tz)
            job = self.scheduler.add_job(func, trigger, id=task_id, name=f"Recurring task: {task_id}")
            logger.info(f"Recurring task {task_id} scheduled with cron expression {cron_expression} in timezone {timezone}")
            return job
        except Exception as e:
            logger.error(f"Failed to schedule recurring task {task_id}: {e}")
            raise
    
    def remove_job(self, job_id: str):
        """
        Remove a scheduled job
        
        Args:
            job_id: Job identifier
        """
        try:
            self.scheduler.remove_job(job_id)
            logger.info(f"Job {job_id} removed successfully")
        except Exception as e:
            logger.error(f"Failed to remove job {job_id}: {e}")
            raise
    
    def get_jobs(self):
        """
        Get all scheduled jobs
        
        Returns:
            List of jobs
        """
        try:
            jobs = self.scheduler.get_jobs()
            logger.info(f"Retrieved {len(jobs)} scheduled jobs")
            return jobs
        except Exception as e:
            logger.error(f"Failed to retrieve scheduled jobs: {e}")
            raise
    
    def pause_job(self, job_id: str):
        """
        Pause a scheduled job
        
        Args:
            job_id: Job identifier
        """
        try:
            self.scheduler.pause_job(job_id)
            logger.info(f"Job {job_id} paused successfully")
        except Exception as e:
            logger.error(f"Failed to pause job {job_id}: {e}")
            raise
    
    def resume_job(self, job_id: str):
        """
        Resume a paused job
        
        Args:
            job_id: Job identifier
        """
        try:
            self.scheduler.resume_job(job_id)
            logger.info(f"Job {job_id} resumed successfully")
        except Exception as e:
            logger.error(f"Failed to resume job {job_id}: {e}")
            raise

# Global instance
task_scheduler = TaskScheduler()