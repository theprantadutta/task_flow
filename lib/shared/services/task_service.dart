import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_flow/shared/models/task.dart';
import 'package:task_flow/shared/services/base_service.dart';
import 'package:task_flow/core/constants/app_constants.dart';
import 'package:task_flow/core/utils/logger.dart';

class TaskService extends BaseService {
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
      final snapshot = await firestore
          .collection(AppConstants.workspacesCollection)
          .doc(workspaceId)
          .collection(AppConstants.projectsCollection)
          .doc(projectId)
          .collection(AppConstants.tasksCollection)
          .get();

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

  Future<void> updateTask(Task task) async {
    try {
      await firestore
          .collection(AppConstants.workspacesCollection)
          .doc(task.projectId) // This is actually the workspaceId in the task model
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
}