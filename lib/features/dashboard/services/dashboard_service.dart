import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_flow/shared/models/workspace.dart';
import 'package:task_flow/shared/models/project.dart';

class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      // Get tasks completed this week
      final now = DateTime.now();
      final startOfWeek = DateTime(now.year, now.month, now.day - now.weekday + 1);
      
      final tasksSnapshot = await _firestore
          .collectionGroup('tasks')
          .where('assigneeId', isEqualTo: userId)
          .where('status', isEqualTo: 'done')
          .where('updatedAt', isGreaterThanOrEqualTo: startOfWeek)
          .get();

      // Get upcoming deadlines (within 7 days)
      final endOfNextWeek = DateTime(now.year, now.month, now.day + 7);
      
      final upcomingTasksSnapshot = await _firestore
          .collectionGroup('tasks')
          .where('assigneeId', isEqualTo: userId)
          .where('status', isNotEqualTo: 'done')
          .where('dueDate', isGreaterThanOrEqualTo: now)
          .where('dueDate', isLessThanOrEqualTo: endOfNextWeek)
          .get();

      return {
        'tasksCompletedThisWeek': tasksSnapshot.size,
        'upcomingDeadlines': upcomingTasksSnapshot.size,
      };
    } catch (e) {
      // Return default values if there's an error
      return {
        'tasksCompletedThisWeek': 0,
        'upcomingDeadlines': 0,
      };
    }
  }

  Future<List<Workspace>> getUserWorkspaces(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('workspaces')
          .where('ownerId', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Workspace.fromJson(data);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Project>> getUserProjects(String userId) async {
    try {
      final workspaces = await getUserWorkspaces(userId);
      final workspaceIds = workspaces.map((w) => w.id).toList();

      if (workspaceIds.isEmpty) return [];

      final projects = <Project>[];

      for (final workspaceId in workspaceIds) {
        final snapshot = await _firestore
            .collection('workspaces')
            .doc(workspaceId)
            .collection('projects')
            .get();

        projects.addAll(snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          data['workspaceId'] = workspaceId;
          return Project.fromJson(data);
        }).toList());
      }

      return projects;
    } catch (e) {
      return [];
    }
  }
}