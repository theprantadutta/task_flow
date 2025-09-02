import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_flow/shared/models/task_assignment.dart';
import 'package:task_flow/shared/models/invitation.dart';
import 'package:task_flow/shared/services/base_service.dart';
import 'package:task_flow/shared/services/invitation_service.dart';
import 'package:task_flow/shared/services/project_member_service.dart';
import 'package:task_flow/core/constants/app_constants.dart';
import 'package:task_flow/core/utils/logger.dart';

class TaskAssignmentService extends BaseService {
  final InvitationService _invitationService;
  final ProjectMemberService _projectMemberService;

  TaskAssignmentService({
    InvitationService? invitationService,
    ProjectMemberService? projectMemberService,
  })  : _invitationService = invitationService ?? InvitationService(),
        _projectMemberService = projectMemberService ?? ProjectMemberService();

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
      final assignment = TaskAssignment(
        taskId: taskId,
        userId: userId,
        role: role,
        status: status,
        assignedAt: DateTime.now(),
        invitedAt: status == 'invited' ? DateTime.now() : null,
      );

      await firestore
          .collection(AppConstants.workspacesCollection)
          .doc(workspaceId)
          .collection(AppConstants.projectsCollection)
          .doc(projectId)
          .collection(AppConstants.tasksCollection)
          .doc(taskId)
          .collection('assignments')
          .doc(userId)
          .set(assignment.toJson());

      Logger.info('User assigned to task: $userId in $taskId with status $status');
    } catch (e) {
      Logger.error('Error assigning user to task: $e');
      rethrow;
    }
  }

  /// Invite a user to a task
  Future<Invitation> inviteUserToTask({
    required String workspaceId,
    required String projectId,
    required String taskId,
    required String inviterId,
    required String inviteeId,
    required String role,
  }) async {
    try {
      // Check if user is a member of the project
      final isProjectMember = await _projectMemberService.isUserMemberOfProject(
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

      // Create invitation
      final invitation = await _invitationService.createInvitation(
        inviterId: inviterId,
        inviteeId: inviteeId,
        type: 'task',
        metadata: {
          'workspaceId': workspaceId,
          'projectId': projectId,
          'taskId': taskId,
          'role': role,
        },
      );

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
      return invitation;
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
        'assignedAt': FieldValue.serverTimestamp(),
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
  Future<List<TaskAssignment>> getTaskAssignments({
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
          .map((doc) => TaskAssignment.fromJson(doc.data()))
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

  /// Update user role in task
  Future<void> updateUserRole({
    required String workspaceId,
    required String projectId,
    required String taskId,
    required String userId,
    required String newRole,
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
        'role': newRole,
      });

      Logger.info('User role updated: $userId in $taskId to $newRole');
    } catch (e) {
      Logger.error('Error updating user role: $e');
      rethrow;
    }
  }

  /// Get pending invitations for a task
  Future<List<Invitation>> getTaskInvitations({
    required String workspaceId,
    required String projectId,
    required String taskId,
  }) async {
    try {
      // This would require a more complex query to get all invitations for a task
      // For now, we'll return an empty list
      return [];
    } catch (e) {
      Logger.error('Error getting task invitations: $e');
      rethrow;
    }
  }
}