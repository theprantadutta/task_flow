import 'package:task_flow/shared/models/workspace.dart';
import 'package:task_flow/shared/models/workspace_member.dart';
import 'package:task_flow/shared/services/base_service.dart';
import 'package:task_flow/core/constants/app_constants.dart';
import 'package:task_flow/core/utils/logger.dart';

class WorkspaceService extends BaseService {
  Future<Workspace> createWorkspace({
    required String name,
    required String ownerId,
  }) async {
    try {
      final workspace = Workspace(
        id: '',
        name: name,
        ownerId: ownerId,
        createdAt: DateTime.now(),
      );

      final docRef = await firestore
          .collection(AppConstants.workspacesCollection)
          .add(workspace.toJson());

      final newWorkspace = Workspace(
        id: docRef.id,
        name: name,
        ownerId: ownerId,
        createdAt: workspace.createdAt,
      );

      // Add the owner as a member
      await addMemberToWorkspace(
        workspaceId: docRef.id,
        userId: ownerId,
        role: AppConstants.adminRole,
      );

      Logger.info('Workspace created: ${docRef.id}');
      return newWorkspace;
    } catch (e) {
      Logger.error('Error creating workspace: $e');
      rethrow;
    }
  }

  Future<List<Workspace>> getUserWorkspaces(String userId) async {
    try {
      final snapshot = await firestore
          .collection(AppConstants.workspacesCollection)
          .where('ownerId', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) => Workspace.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      Logger.error('Error getting user workspaces: $e');
      rethrow;
    }
  }

  Future<Workspace?> getWorkspace(String workspaceId) async {
    try {
      final snapshot = await firestore
          .collection(AppConstants.workspacesCollection)
          .doc(workspaceId)
          .get();

      if (snapshot.exists) {
        return Workspace.fromJson({
          ...snapshot.data()!,
          'id': snapshot.id,
        });
      }

      return null;
    } catch (e) {
      Logger.error('Error getting workspace: $e');
      rethrow;
    }
  }

  Future<void> updateWorkspace(Workspace workspace) async {
    try {
      await firestore
          .collection(AppConstants.workspacesCollection)
          .doc(workspace.id)
          .update(workspace.toJson());

      Logger.info('Workspace updated: ${workspace.id}');
    } catch (e) {
      Logger.error('Error updating workspace: $e');
      rethrow;
    }
  }

  Future<void> deleteWorkspace(String workspaceId) async {
    try {
      await firestore
          .collection(AppConstants.workspacesCollection)
          .doc(workspaceId)
          .delete();

      Logger.info('Workspace deleted: $workspaceId');
    } catch (e) {
      Logger.error('Error deleting workspace: $e');
      rethrow;
    }
  }

  Future<void> addMemberToWorkspace({
    required String workspaceId,
    required String userId,
    required String role,
  }) async {
    try {
      final member = WorkspaceMember(
        workspaceId: workspaceId,
        userId: userId,
        role: role,
        joinedAt: DateTime.now(),
      );

      await firestore
          .collection(AppConstants.workspacesCollection)
          .doc(workspaceId)
          .collection('members')
          .doc(userId)
          .set(member.toJson());

      Logger.info('Member added to workspace: $userId in $workspaceId');
    } catch (e) {
      Logger.error('Error adding member to workspace: $e');
      rethrow;
    }
  }

  Future<List<WorkspaceMember>> getWorkspaceMembers(String workspaceId) async {
    try {
      final snapshot = await firestore
          .collection(AppConstants.workspacesCollection)
          .doc(workspaceId)
          .collection('members')
          .get();

      return snapshot.docs
          .map((doc) => WorkspaceMember.fromJson(doc.data()))
          .toList();
    } catch (e) {
      Logger.error('Error getting workspace members: $e');
      rethrow;
    }
  }

  Future<bool> isUserMemberOfWorkspace({
    required String workspaceId,
    required String userId,
  }) async {
    try {
      final snapshot = await firestore
          .collection(AppConstants.workspacesCollection)
          .doc(workspaceId)
          .collection('members')
          .doc(userId)
          .get();

      return snapshot.exists;
    } catch (e) {
      Logger.error('Error checking workspace membership: $e');
      rethrow;
    }
  }

  Future<void> removeMemberFromWorkspace({
    required String workspaceId,
    required String userId,
  }) async {
    try {
      await firestore
          .collection(AppConstants.workspacesCollection)
          .doc(workspaceId)
          .collection('members')
          .doc(userId)
          .delete();

      Logger.info('Member removed from workspace: $userId in $workspaceId');
    } catch (e) {
      Logger.error('Error removing member from workspace: $e');
      rethrow;
    }
  }
}