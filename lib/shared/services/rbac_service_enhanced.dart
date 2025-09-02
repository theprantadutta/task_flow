import 'package:task_flow/shared/services/workspace_service_enhanced.dart';
import 'package:task_flow/shared/services/project_member_service.dart';
import 'package:task_flow/shared/services/task_assignment_service.dart';
import 'package:task_flow/core/constants/app_constants.dart';
import 'package:task_flow/shared/models/project_member.dart';
import 'package:task_flow/shared/models/task_assignment.dart';

class RBACServiceEnhanced {
  final WorkspaceServiceEnhanced _workspaceService;
  final ProjectMemberService _projectMemberService;
  final TaskAssignmentService _taskAssignmentService;

  RBACServiceEnhanced({
    required WorkspaceServiceEnhanced workspaceService,
    required ProjectMemberService projectMemberService,
    required TaskAssignmentService taskAssignmentService,
  })  : _workspaceService = workspaceService,
        _projectMemberService = projectMemberService,
        _taskAssignmentService = taskAssignmentService;

  /// Check if user is admin of a workspace
  Future<bool> isUserAdmin(String workspaceId, String userId) async {
    try {
      final workspace = await _workspaceService.getWorkspace(workspaceId);
      return workspace?.ownerId == userId;
    } catch (e) {
      return false;
    }
  }

  /// Check if user is a member of a workspace (with accepted status)
  Future<bool> isUserMemberOfWorkspace(String workspaceId, String userId) async {
    try {
      return await _workspaceService.isUserMemberOfWorkspace(
        workspaceId: workspaceId,
        userId: userId,
      );
    } catch (e) {
      return false;
    }
  }

  /// Check if user is a member of a project (with accepted status)
  Future<bool> isUserMemberOfProject(
      String workspaceId, String projectId, String userId) async {
    try {
      return await _projectMemberService.isUserMemberOfProject(
        workspaceId: workspaceId,
        projectId: projectId,
        userId: userId,
      );
    } catch (e) {
      return false;
    }
  }

  /// Check if user is assigned to a task (with accepted status)
  Future<bool> isUserAssignedToTask(
      String workspaceId, String projectId, String taskId, String userId) async {
    try {
      return await _taskAssignmentService.isUserAssignedToTask(
        workspaceId: workspaceId,
        projectId: projectId,
        taskId: taskId,
        userId: userId,
      );
    } catch (e) {
      return false;
    }
  }

  /// Check if user can create projects in a workspace
  Future<bool> canCreateProjects(String workspaceId, String userId) async {
    // Only workspace members can create projects
    return await isUserMemberOfWorkspace(workspaceId, userId);
  }

  /// Check if user can delete a workspace
  Future<bool> canDeleteWorkspace(String workspaceId, String userId) async {
    // Only admins can delete workspaces
    return await isUserAdmin(workspaceId, userId);
  }

  /// Check if user can add members to a workspace
  Future<bool> canAddMembersToWorkspace(String workspaceId, String userId) async {
    // Only admins can add members to workspace
    return await isUserAdmin(workspaceId, userId);
  }

  /// Check if user can remove members from a workspace
  Future<bool> canRemoveMembersFromWorkspace(String workspaceId, String userId) async {
    // Only admins can remove members from workspace
    return await isUserAdmin(workspaceId, userId);
  }

  /// Check if user can invite members to a project
  Future<bool> canInviteMembersToProject(
      String workspaceId, String projectId, String userId) async {
    // Check if user is a member of the workspace first
    if (!await isUserMemberOfWorkspace(workspaceId, userId)) {
      return false;
    }

    // Check if user is project manager or workspace admin
    if (await isUserAdmin(workspaceId, userId)) {
      return true;
    }

    // Check user's role in the project
    try {
      final members = await _projectMemberService.getProjectMembers(
        workspaceId: workspaceId,
        projectId: projectId,
      );

      final userMember = members.firstWhere(
        (member) => member.userId == userId,
        orElse: () => ProjectMember(
          projectId: projectId,
          userId: userId,
          role: '',
          status: '',
          joinedAt: DateTime.now(),
        ),
      );

      return userMember.role == 'manager';
    } catch (e) {
      return false;
    }
  }

  /// Check if user can add members to a task
  Future<bool> canAssignUsersToTask(
      String workspaceId, String projectId, String taskId, String userId) async {
    // Check if user is a member of the project first
    if (!await isUserMemberOfProject(workspaceId, projectId, userId)) {
      return false;
    }

    // Check if user is project manager or workspace admin
    if (await isUserAdmin(workspaceId, userId)) {
      return true;
    }

    // Check if user is project manager
    try {
      final projectMembers = await _projectMemberService.getProjectMembers(
        workspaceId: workspaceId,
        projectId: projectId,
      );

      final userMember = projectMembers.firstWhere(
        (member) => member.userId == userId,
        orElse: () => ProjectMember(
          projectId: projectId,
          userId: userId,
          role: '',
          status: '',
          joinedAt: DateTime.now(),
        ),
      );

      return userMember.role == 'manager';
    } catch (e) {
      return false;
    }
  }

  /// Check if user can edit a task
  Future<bool> canEditTask(
      String workspaceId, String projectId, String taskId, String userId) async {
    // Admins can edit all tasks
    if (await isUserAdmin(workspaceId, userId)) {
      return true;
    }

    // Check if user is assigned to the task
    if (await isUserAssignedToTask(workspaceId, projectId, taskId, userId)) {
      // Get user's role in the task
      try {
        final assignments = await _taskAssignmentService.getTaskAssignments(
          workspaceId: workspaceId,
          projectId: projectId,
          taskId: taskId,
        );

        final userAssignment = assignments.firstWhere(
          (assignment) => assignment.userId == userId,
          orElse: () => TaskAssignment(
            taskId: taskId,
            userId: userId,
            role: '',
            status: '',
            assignedAt: DateTime.now(),
          ),
        );

        // Assignee and collaborator can edit task
        return userAssignment.role == 'assignee' || userAssignment.role == 'collaborator';
      } catch (e) {
        return false;
      }
    }

    // Check if user is a member of the project
    return await isUserMemberOfProject(workspaceId, projectId, userId);
  }

  /// Check if user can delete a task
  Future<bool> canDeleteTask(
      String workspaceId, String projectId, String taskId, String userId) async {
    // Admins can delete all tasks
    if (await isUserAdmin(workspaceId, userId)) {
      return true;
    }

    // Check if user is project manager
    try {
      final projectMembers = await _projectMemberService.getProjectMembers(
        workspaceId: workspaceId,
        projectId: projectId,
      );

      final userMember = projectMembers.firstWhere(
        (member) => member.userId == userId,
        orElse: () => ProjectMember(
          projectId: projectId,
          userId: userId,
          role: '',
          status: '',
          joinedAt: DateTime.now(),
        ),
      );

      return userMember.role == 'manager';
    } catch (e) {
      return false;
    }
  }

  /// Get user role in a workspace
  Future<String> getUserWorkspaceRole(String workspaceId, String userId) async {
    try {
      final workspace = await _workspaceService.getWorkspace(workspaceId);
      if (workspace?.ownerId == userId) {
        return AppConstants.adminRole;
      }

      final isMember = await isUserMemberOfWorkspace(workspaceId, userId);
      return isMember ? AppConstants.memberRole : '';
    } catch (e) {
      return '';
    }
  }

  /// Get user role in a project
  Future<String> getUserProjectRole(
      String workspaceId, String projectId, String userId) async {
    try {
      // Check if user is workspace admin
      if (await isUserAdmin(workspaceId, userId)) {
        return 'admin';
      }

      final members = await _projectMemberService.getProjectMembers(
        workspaceId: workspaceId,
        projectId: projectId,
      );

      final userMember = members.firstWhere(
        (member) => member.userId == userId,
        orElse: () => ProjectMember(
          projectId: projectId,
          userId: userId,
          role: '',
          status: '',
          joinedAt: DateTime.now(),
        ),
      );

      return userMember.role;
    } catch (e) {
      return '';
    }
  }

  /// Get user role in a task
  Future<String> getUserTaskRole(
      String workspaceId, String projectId, String taskId, String userId) async {
    try {
      // Check if user is workspace admin
      if (await isUserAdmin(workspaceId, userId)) {
        return 'admin';
      }

      // Check if user is project manager
      final projectRole = await getUserProjectRole(workspaceId, projectId, userId);
      if (projectRole == 'manager') {
        return 'manager';
      }

      final assignments = await _taskAssignmentService.getTaskAssignments(
        workspaceId: workspaceId,
        projectId: projectId,
        taskId: taskId,
      );

      final userAssignment = assignments.firstWhere(
        (assignment) => assignment.userId == userId,
        orElse: () => TaskAssignment(
          taskId: taskId,
          userId: userId,
          role: '',
          status: '',
          assignedAt: DateTime.now(),
        ),
      );

      return userAssignment.role;
    } catch (e) {
      return '';
    }
  }

  /// Enforce hierarchical access - user must be member of parent entity
  /// to access child entity
  Future<bool> enforceHierarchicalAccess({
    required String workspaceId,
    String? projectId,
    String? taskId,
    required String userId,
  }) async {
    try {
      // Check workspace access first
      if (!await isUserMemberOfWorkspace(workspaceId, userId)) {
        return false;
      }

      // If project is specified, check project access
      if (projectId != null) {
        if (!await isUserMemberOfProject(workspaceId, projectId, userId)) {
          return false;
        }

        // If task is specified, check task access
        if (taskId != null) {
          if (!await isUserAssignedToTask(workspaceId, projectId, taskId, userId)) {
            return false;
          }
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}