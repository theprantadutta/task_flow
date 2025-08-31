import 'package:task_flow/shared/services/workspace_service.dart';
import 'package:task_flow/core/constants/app_constants.dart';

class RBACService {
  final WorkspaceService _workspaceService;

  RBACService({required WorkspaceService workspaceService})
      : _workspaceService = workspaceService;

  /// Check if user is admin of a workspace
  Future<bool> isUserAdmin(String workspaceId, String userId) async {
    try {
      final workspace = await _workspaceService.getWorkspace(workspaceId);
      return workspace?.ownerId == userId;
    } catch (e) {
      return false;
    }
  }

  /// Check if user is a member of a workspace
  Future<bool> isUserMember(String workspaceId, String userId) async {
    try {
      return await _workspaceService.isUserMemberOfWorkspace(
        workspaceId: workspaceId,
        userId: userId,
      );
    } catch (e) {
      return false;
    }
  }

  /// Check if user can create projects in a workspace
  Future<bool> canCreateProjects(String workspaceId, String userId) async {
    // Admins and members can create projects
    return await isUserMember(workspaceId, userId);
  }

  /// Check if user can delete a workspace
  Future<bool> canDeleteWorkspace(String workspaceId, String userId) async {
    // Only admins can delete workspaces
    return await isUserAdmin(workspaceId, userId);
  }

  /// Check if user can add members to a workspace
  Future<bool> canAddMembers(String workspaceId, String userId) async {
    // Only admins can add members
    return await isUserAdmin(workspaceId, userId);
  }

  /// Check if user can remove members from a workspace
  Future<bool> canRemoveMembers(String workspaceId, String userId) async {
    // Only admins can remove members
    return await isUserAdmin(workspaceId, userId);
  }

  /// Check if user can edit a task
  Future<bool> canEditTask(
      String workspaceId, String projectId, String taskId, String userId) async {
    // Admins can edit all tasks
    if (await isUserAdmin(workspaceId, userId)) {
      return true;
    }

    // Check if user is assigned to the task or created it
    // This would require additional services to check task details
    return true; // Simplified for now
  }

  /// Check if user can delete a task
  Future<bool> canDeleteTask(
      String workspaceId, String projectId, String taskId, String userId) async {
    // Admins can delete all tasks
    if (await isUserAdmin(workspaceId, userId)) {
      return true;
    }

    // Check if user is assigned to the task or created it
    // This would require additional services to check task details
    return true; // Simplified for now
  }

  /// Get user role in a workspace
  Future<String> getUserRole(String workspaceId, String userId) async {
    try {
      final workspace = await _workspaceService.getWorkspace(workspaceId);
      if (workspace?.ownerId == userId) {
        return AppConstants.adminRole;
      }

      final isMember = await _workspaceService.isUserMemberOfWorkspace(
        workspaceId: workspaceId,
        userId: userId,
      );

      return isMember ? AppConstants.memberRole : '';
    } catch (e) {
      return '';
    }
  }
}