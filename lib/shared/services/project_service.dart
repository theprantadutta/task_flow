import 'package:task_flow/shared/models/project.dart';
import 'package:task_flow/shared/services/base_service.dart';
import 'package:task_flow/core/constants/app_constants.dart';
import 'package:task_flow/core/utils/logger.dart';

class ProjectService extends BaseService {
  Future<Project> createProject({
    required String workspaceId,
    required String name,
    String? description,
    required String ownerId,
  }) async {
    try {
      final project = Project(
        id: '',
        workspaceId: workspaceId,
        name: name,
        description: description,
        ownerId: ownerId,
        createdAt: DateTime.now(),
      );

      final docRef = await firestore
          .collection(AppConstants.workspacesCollection)
          .doc(workspaceId)
          .collection(AppConstants.projectsCollection)
          .add(project.toJson());

      final newProject = Project(
        id: docRef.id,
        workspaceId: workspaceId,
        name: name,
        description: description,
        ownerId: ownerId,
        createdAt: project.createdAt,
      );

      Logger.info('Project created: ${docRef.id}');
      
      // Log the project creation event
      await analyticsService.logProjectCreated();
      
      return newProject;
    } catch (e) {
      Logger.error('Error creating project: $e');
      rethrow;
    }
  }

  Future<List<Project>> getWorkspaceProjects(String workspaceId) async {
    try {
      // Start a performance trace
      final trace = await analyticsService.startTrace('get_workspace_projects');
      
      final snapshot = await firestore
          .collection(AppConstants.workspacesCollection)
          .doc(workspaceId)
          .collection(AppConstants.projectsCollection)
          .get();
          
      // Stop the trace
      await trace.stop();

      return snapshot.docs
          .map((doc) => Project.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      Logger.error('Error getting workspace projects: $e');
      rethrow;
    }
  }

  Future<Project?> getProject(String workspaceId, String projectId) async {
    try {
      final snapshot = await firestore
          .collection(AppConstants.workspacesCollection)
          .doc(workspaceId)
          .collection(AppConstants.projectsCollection)
          .doc(projectId)
          .get();

      if (snapshot.exists) {
        return Project.fromJson({
          ...snapshot.data()!,
          'id': snapshot.id,
        });
      }

      return null;
    } catch (e) {
      Logger.error('Error getting project: $e');
      rethrow;
    }
  }

  Future<void> updateProject(Project project) async {
    try {
      await firestore
          .collection(AppConstants.workspacesCollection)
          .doc(project.workspaceId)
          .collection(AppConstants.projectsCollection)
          .doc(project.id)
          .update(project.toJson());

      Logger.info('Project updated: ${project.id}');
    } catch (e) {
      Logger.error('Error updating project: $e');
      rethrow;
    }
  }

  Future<void> deleteProject(String workspaceId, String projectId) async {
    try {
      await firestore
          .collection(AppConstants.workspacesCollection)
          .doc(workspaceId)
          .collection(AppConstants.projectsCollection)
          .doc(projectId)
          .delete();

      Logger.info('Project deleted: $projectId');
    } catch (e) {
      Logger.error('Error deleting project: $e');
      rethrow;
    }
  }
}