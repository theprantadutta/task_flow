import 'package:task_flow/shared/models/task.dart';
import 'package:task_flow/shared/services/base_service.dart';
import 'package:task_flow/core/constants/app_constants.dart';
import 'package:task_flow/core/utils/logger.dart';

class PersonalTaskService extends BaseService {
  /// Get all tasks assigned to a specific user across all projects
  Future<List<Task>> getUserTasks(String userId) async {
    try {
      final trace = await analyticsService.startTrace('get_user_tasks');
      
      // Get all workspaces the user belongs to
      final workspaceDocs = await firestore
          .collection(AppConstants.workspacesCollection)
          .where('members', arrayContains: userId)
          .get();
      
      final allTasks = <Task>[];
      
      // For each workspace, get all projects
      for (final workspaceDoc in workspaceDocs.docs) {
        final projectDocs = await firestore
            .collection(AppConstants.workspacesCollection)
            .doc(workspaceDoc.id)
            .collection(AppConstants.projectsCollection)
            .get();
        
        // For each project, get all tasks assigned to the user
        for (final projectDoc in projectDocs.docs) {
          final taskDocs = await firestore
              .collection(AppConstants.workspacesCollection)
              .doc(workspaceDoc.id)
              .collection(AppConstants.projectsCollection)
              .doc(projectDoc.id)
              .collection(AppConstants.tasksCollection)
              .where('assigneeId', isEqualTo: userId)
              .get();
          
          for (final taskDoc in taskDocs.docs) {
            allTasks.add(Task.fromJson({
              ...taskDoc.data(),
              'id': taskDoc.id,
            }));
          }
        }
      }
      
      await trace.stop();
      Logger.info('Retrieved ${allTasks.length} tasks for user $userId');
      
      return allTasks;
    } catch (e) {
      Logger.error('Error getting user tasks: $e');
      rethrow;
    }
  }

  /// Get task statistics for the user
  Future<Map<String, int>> getUserTaskStats(String userId) async {
    try {
      final tasks = await getUserTasks(userId);
      
      int todayTasks = 0;
      int overdueTasks = 0;
      int upcomingTasks = 0;
      
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));
      
      for (final task in tasks) {
        if (task.dueDate != null) {
          final dueDate = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
          
          if (dueDate.isBefore(today)) {
            overdueTasks++;
          } else if (dueDate.isAtSameMomentAs(today)) {
            todayTasks++;
          } else if (dueDate.isBefore(tomorrow.add(const Duration(days: 7)))) {
            upcomingTasks++;
          }
        }
      }
      
      return {
        'today': todayTasks,
        'overdue': overdueTasks,
        'upcoming': upcomingTasks,
      };
    } catch (e) {
      Logger.error('Error getting user task stats: $e');
      return {'today': 0, 'overdue': 0, 'upcoming': 0};
    }
  }

  /// Filter tasks based on status, priority, and search term
  List<Task> filterTasks(
    List<Task> tasks, {
    String status = 'all',
    String priority = 'all',
    String searchTerm = '',
  }) {
    return tasks.where((task) {
      // Status filter
      if (status != 'all' && task.status != status) {
        return false;
      }
      
      // Priority filter
      if (priority != 'all' && task.priority != priority) {
        return false;
      }
      
      // Search filter
      if (searchTerm.isNotEmpty) {
        final searchLower = searchTerm.toLowerCase();
        final titleMatch = task.title.toLowerCase().contains(searchLower);
        final descriptionMatch = task.description != null && 
            task.description!.toLowerCase().contains(searchLower);
        
        if (!titleMatch && !descriptionMatch) {
          return false;
        }
      }
      
      return true;
    }).toList();
  }
}