import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_flow/shared/models/task.dart';
import 'package:task_flow/shared/services/base_service.dart';
import 'package:task_flow/shared/services/project_service.dart';
import 'package:task_flow/core/constants/app_constants.dart';
import 'package:task_flow/core/utils/logger.dart';

class TaskService extends BaseService {
  final ProjectService _projectService;

  TaskService({ProjectService? projectService})
      : _projectService = projectService ?? ProjectService();

  Future<Task> createTask({
    required String workspaceId,
    required String projectId,
    required String title,
    String? description,
    required String status,
    String? assigneeId,
    required String reporterId,
    DateTime? dueDate,
    String priority = 'medium',
  }) async {
    try {
      // Check if user is a member of the project
      final isProjectMember = await _projectService.isUserMemberOfProject(
        workspaceId: workspaceId,
        projectId: projectId,
        userId: reporterId,
      );

      if (!isProjectMember) {
        throw Exception('User must be a member of the project to create a task');
      }

      final task = Task(
        id: '',
        projectId: projectId,
        title: title,
        description: description,
        status: status,
        assigneeId: assigneeId,
        reporterId: reporterId,
        dueDate: dueDate,
        priority: priority,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final docRef = await firestore
          .collection(AppConstants.workspacesCollection)
          .doc(workspaceId)
          .collection(AppConstants.projectsCollection)
          .doc(projectId)
          .collection(AppConstants.tasksCollection)
          .add(task.toJson());

      final newTask = Task(
        id: docRef.id,
        projectId: projectId,
        title: title,
        description: description,
        status: status,
        assigneeId: assigneeId,
        reporterId: reporterId,
        dueDate: dueDate,
        priority: priority,
        createdAt: task.createdAt,
        updatedAt: task.updatedAt,
      );

      Logger.info('Task created: ${docRef.id}');
      
      // Log the task creation event
      await analyticsService.logTaskCreated();
      
      return newTask;
    } catch (e) {
      Logger.error('Error creating task: $e');
      rethrow;
    }
  }

  Stream<List<Task>> getProjectTasksStream(String workspaceId, String projectId) {
    try {
      return firestore
          .collection(AppConstants.workspacesCollection)
          .doc(workspaceId)
          .collection(AppConstants.projectsCollection)
          .doc(projectId)
          .collection(AppConstants.tasksCollection)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Task.fromJson({
                    ...doc.data(),
                    'id': doc.id,
                  }))
              .toList());
    } catch (e) {
      Logger.error('Error getting project tasks stream: $e');
      rethrow;
    }
  }

  Future<List<Task>> getProjectTasks(String workspaceId, String projectId) async {
    try {
      // Start a performance trace
      final trace = await analyticsService.startTrace('get_project_tasks');
      
      final snapshot = await firestore
          .collection(AppConstants.workspacesCollection)
          .doc(workspaceId)
          .collection(AppConstants.projectsCollection)
          .doc(projectId)
          .collection(AppConstants.tasksCollection)
          .get();
          
      // Stop the trace
      await trace.stop();

      return snapshot.docs
          .map((doc) => Task.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      Logger.error('Error getting project tasks: $e');
      rethrow;
    }
  }

  Future<Task?> getTask(
      String workspaceId, String projectId, String taskId) async {
    try {
      final snapshot = await firestore
          .collection(AppConstants.workspacesCollection)
          .doc(workspaceId)
          .collection(AppConstants.projectsCollection)
          .doc(projectId)
          .collection(AppConstants.tasksCollection)
          .doc(taskId)
          .get();

      if (snapshot.exists) {
        return Task.fromJson({
          ...snapshot.data()!,
          'id': snapshot.id,
        });
      }

      return null;
    } catch (e) {
      Logger.error('Error getting task: $e');
      rethrow;
    }
  }

  Future<void> updateTask(Task task, String workspaceId) async {
    try {
      await firestore
          .collection(AppConstants.workspacesCollection)
          .doc(workspaceId)
          .collection(AppConstants.projectsCollection)
          .doc(task.projectId)
          .collection(AppConstants.tasksCollection)
          .doc(task.id)
          .update({
        ...task.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Logger.info('Task updated: ${task.id}');
    } catch (e) {
      Logger.error('Error updating task: $e');
      rethrow;
    }
  }

  Future<void> updateTaskStatus(
      String workspaceId, String projectId, String taskId, String status) async {
    try {
      await firestore
          .collection(AppConstants.workspacesCollection)
          .doc(workspaceId)
          .collection(AppConstants.projectsCollection)
          .doc(projectId)
          .collection(AppConstants.tasksCollection)
          .doc(taskId)
          .update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Logger.info('Task status updated: $taskId to $status');
    } catch (e) {
      Logger.error('Error updating task status: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(String workspaceId, String projectId, String taskId) async {
    try {
      await firestore
          .collection(AppConstants.workspacesCollection)
          .doc(workspaceId)
          .collection(AppConstants.projectsCollection)
          .doc(projectId)
          .collection(AppConstants.tasksCollection)
          .doc(taskId)
          .delete();

      Logger.info('Task deleted: $taskId');
    } catch (e) {
      Logger.error('Error deleting task: $e');
      rethrow;
    }
  }

  /// Assign a user to a task
  Future<void> assignUserToTask({
    required String workspaceId,
    required String projectId,
    required String taskId,
    required String userId,
    required String role,
    required String status,
  }) async {
    try {
      // Check if user is a member of the project first
      final isProjectMember = await _projectService.isUserMemberOfProject(
        workspaceId: workspaceId,
        projectId: projectId,
        userId: userId,
      );

      if (!isProjectMember) {
        throw Exception('User must be a member of the project to be assigned to a task');
      }

      final assignmentData = {
        'taskId': taskId,
        'userId': userId,
        'role': role,
        'status': status,
        'assignedAt': DateTime.now().toIso8601String(),
        'invitedAt': status == 'invited' ? DateTime.now().toIso8601String() : null,
      };

      await firestore
          .collection(AppConstants.workspacesCollection)
          .doc(workspaceId)
          .collection(AppConstants.projectsCollection)
          .doc(projectId)
          .collection(AppConstants.tasksCollection)
          .doc(taskId)
          .collection('assignments')
          .doc(userId)
          .set(assignmentData);

      Logger.info('User assigned to task: $userId in $taskId with status $status');
    } catch (e) {
      Logger.error('Error assigning user to task: $e');
      rethrow;
    }
  }

  /// Invite a user to a task
  Future<void> inviteUserToTask({
    required String workspaceId,
    required String projectId,
    required String taskId,
    required String inviterId,
    required String inviteeId,
    required String role,
  }) async {
    try {
      // Check if user is a member of the project
      final isProjectMember = await _projectService.isUserMemberOfProject(
        workspaceId: workspaceId,
        projectId: projectId,
        userId: inviteeId,
      );

      if (!isProjectMember) {
        throw Exception('User must be a member of the project to be invited to a task');
      }

      // Check if user is already assigned to the task
      final isTaskAssigned = await isUserAssignedToTask(
        workspaceId: workspaceId,
        projectId: projectId,
        taskId: taskId,
        userId: inviteeId,
      );

      if (isTaskAssigned) {
        throw Exception('User is already assigned to this task');
      }

      // Add user as invited assignment
      await assignUserToTask(
        workspaceId: workspaceId,
        projectId: projectId,
        taskId: taskId,
        userId: inviteeId,
        role: role,
        status: 'invited',
      );

      Logger.info('User invited to task: $inviteeId to $taskId');
    } catch (e) {
      Logger.error('Error inviting user to task: $e');
      rethrow;
    }
  }

  /// Accept task assignment invitation
  Future<void> acceptTaskAssignment({
    required String workspaceId,
    required String projectId,
    required String taskId,
    required String userId,
  }) async {
    try {
      await firestore
          .collection(AppConstants.workspacesCollection)
          .doc(workspaceId)
          .collection(AppConstants.projectsCollection)
          .doc(projectId)
          .collection(AppConstants.tasksCollection)
          .doc(taskId)
          .collection('assignments')
          .doc(userId)
          .update({
        'status': 'accepted',
        'assignedAt': DateTime.now().toIso8601String(),
      });

      Logger.info('User accepted task assignment: $userId in $taskId');
    } catch (e) {
      Logger.error('Error accepting task assignment: $e');
      rethrow;
    }
  }

  /// Decline task assignment invitation
  Future<void> declineTaskAssignment({
    required String workspaceId,
    required String projectId,
    required String taskId,
    required String userId,
  }) async {
    try {
      await removeUserFromTask(
        workspaceId: workspaceId,
        projectId: projectId,
        taskId: taskId,
        userId: userId,
      );

      Logger.info('User declined task assignment: $userId in $taskId');
    } catch (e) {
      Logger.error('Error declining task assignment: $e');
      rethrow;
    }
  }

  /// Check if user is assigned to a task
  Future<bool> isUserAssignedToTask({
    required String workspaceId,
    required String projectId,
    required String taskId,
    required String userId,
  }) async {
    try {
      final snapshot = await firestore
          .collection(AppConstants.workspacesCollection)
          .doc(workspaceId)
          .collection(AppConstants.projectsCollection)
          .doc(projectId)
          .collection(AppConstants.tasksCollection)
          .doc(taskId)
          .collection('assignments')
          .doc(userId)
          .get();

      // Check if user exists and has accepted status
      if (snapshot.exists) {
        final data = snapshot.data();
        return data?['status'] == 'accepted';
      }

      return false;
    } catch (e) {
      Logger.error('Error checking task assignment: $e');
      rethrow;
    }
  }

  /// Get task assignments
  Future<List<Map<String, dynamic>>> getTaskAssignments({
    required String workspaceId,
    required String projectId,
    required String taskId,
  }) async {
    try {
      final snapshot = await firestore
          .collection(AppConstants.workspacesCollection)
          .doc(workspaceId)
          .collection(AppConstants.projectsCollection)
          .doc(projectId)
          .collection(AppConstants.tasksCollection)
          .doc(taskId)
          .collection('assignments')
          .get();

      return snapshot.docs
          .map((doc) => doc.data())
          .toList();
    } catch (e) {
      Logger.error('Error getting task assignments: $e');
      rethrow;
    }
  }

  /// Remove user from task
  Future<void> removeUserFromTask({
    required String workspaceId,
    required String projectId,
    required String taskId,
    required String userId,
  }) async {
    try {
      await firestore
          .collection(AppConstants.workspacesCollection)
          .doc(workspaceId)
          .collection(AppConstants.projectsCollection)
          .doc(projectId)
          .collection(AppConstants.tasksCollection)
          .doc(taskId)
          .collection('assignments')
          .doc(userId)
          .delete();

      Logger.info('User removed from task: $userId in $taskId');
    } catch (e) {
      Logger.error('Error removing user from task: $e');
      rethrow;
    }
  }
}