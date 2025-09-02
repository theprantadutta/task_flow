import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_flow/shared/models/project_member.dart';
import 'package:task_flow/shared/models/invitation.dart';
import 'package:task_flow/shared/services/base_service.dart';
import 'package:task_flow/shared/services/invitation_service.dart';
import 'package:task_flow/shared/services/workspace_service_enhanced.dart';
import 'package:task_flow/core/constants/app_constants.dart';
import 'package:task_flow/core/utils/logger.dart';

class ProjectMemberService extends BaseService {
  final InvitationService _invitationService;
  final WorkspaceServiceEnhanced _workspaceService;

  ProjectMemberService({
    InvitationService? invitationService,
    WorkspaceServiceEnhanced? workspaceService,
  })  : _invitationService = invitationService ?? InvitationService(),
        _workspaceService = workspaceService ?? WorkspaceServiceEnhanced();

  /// Add a member to a project
  Future<void> addMemberToProject({
    required String workspaceId,
    required String projectId,
    required String userId,
    required String role,
    required String status,
  }) async {
    try {
      final member = ProjectMember(
        projectId: projectId,
        userId: userId,
        role: role,
        status: status,
        joinedAt: DateTime.now(),
        invitedAt: status == 'invited' ? DateTime.now() : null,
      );

      await firestore
          .collection(AppConstants.workspacesCollection)
          .doc(workspaceId)
          .collection(AppConstants.projectsCollection)
          .doc(projectId)
          .collection('members')
          .doc(userId)
          .set(member.toJson());

      Logger.info('Member added to project: $userId in $projectId with status $status');
    } catch (e) {
      Logger.error('Error adding member to project: $e');
      rethrow;
    }
  }

  /// Invite a user to a project
  Future<Invitation> inviteUserToProject({
    required String workspaceId,
    required String projectId,
    required String inviterId,
    required String inviteeId,
    required String role,
  }) async {
    try {
      // Check if user is a member of the workspace
      final isWorkspaceMember = await _workspaceService.isUserMemberOfWorkspace(
        workspaceId: workspaceId,
        userId: inviteeId,
      );

      if (!isWorkspaceMember) {
        throw Exception('User must be a member of the workspace to be invited to a project');
      }

      // Check if user is already a member of the project
      final isProjectMember = await isUserMemberOfProject(
        workspaceId: workspaceId,
        projectId: projectId,
        userId: inviteeId,
      );

      if (isProjectMember) {
        throw Exception('User is already a member of this project');
      }

      // Create invitation
      final invitation = await _invitationService.createInvitation(
        inviterId: inviterId,
        inviteeId: inviteeId,
        type: 'project',
        metadata: {
          'workspaceId': workspaceId,
          'projectId': projectId,
          'role': role,
        },
      );

      // Add user as invited member
      await addMemberToProject(
        workspaceId: workspaceId,
        projectId: projectId,
        userId: inviteeId,
        role: role,
        status: 'invited',
      );

      Logger.info('User invited to project: $inviteeId to $projectId');
      return invitation;
    } catch (e) {
      Logger.error('Error inviting user to project: $e');
      rethrow;
    }
  }

  /// Accept project invitation
  Future<void> acceptProjectInvitation({
    required String workspaceId,
    required String projectId,
    required String userId,
  }) async {
    try {
      await firestore
          .collection(AppConstants.workspacesCollection)
          .doc(workspaceId)
          .collection(AppConstants.projectsCollection)
          .doc(projectId)
          .collection('members')
          .doc(userId)
          .update({
        'status': 'accepted',
        'joinedAt': FieldValue.serverTimestamp(),
      });

      Logger.info('User accepted project invitation: $userId in $projectId');
    } catch (e) {
      Logger.error('Error accepting project invitation: $e');
      rethrow;
    }
  }

  /// Decline project invitation
  Future<void> declineProjectInvitation({
    required String workspaceId,
    required String projectId,
    required String userId,
  }) async {
    try {
      await removeMemberFromProject(
        workspaceId: workspaceId,
        projectId: projectId,
        userId: userId,
      );

      Logger.info('User declined project invitation: $userId in $projectId');
    } catch (e) {
      Logger.error('Error declining project invitation: $e');
      rethrow;
    }
  }

  /// Check if user is a member of a project
  Future<bool> isUserMemberOfProject({
    required String workspaceId,
    required String projectId,
    required String userId,
  }) async {
    try {
      final snapshot = await firestore
          .collection(AppConstants.workspacesCollection)
          .doc(workspaceId)
          .collection(AppConstants.projectsCollection)
          .doc(projectId)
          .collection('members')
          .doc(userId)
          .get();

      // Check if user exists and has accepted status
      if (snapshot.exists) {
        final data = snapshot.data();
        return data?['status'] == 'accepted';
      }

      return false;
    } catch (e) {
      Logger.error('Error checking project membership: $e');
      rethrow;
    }
  }

  /// Get project members
  Future<List<ProjectMember>> getProjectMembers({
    required String workspaceId,
    required String projectId,
  }) async {
    try {
      final snapshot = await firestore
          .collection(AppConstants.workspacesCollection)
          .doc(workspaceId)
          .collection(AppConstants.projectsCollection)
          .doc(projectId)
          .collection('members')
          .get();

      return snapshot.docs
          .map((doc) => ProjectMember.fromJson(doc.data()))
          .toList();
    } catch (e) {
      Logger.error('Error getting project members: $e');
      rethrow;
    }
  }

  /// Remove member from project
  Future<void> removeMemberFromProject({
    required String workspaceId,
    required String projectId,
    required String userId,
  }) async {
    try {
      await firestore
          .collection(AppConstants.workspacesCollection)
          .doc(workspaceId)
          .collection(AppConstants.projectsCollection)
          .doc(projectId)
          .collection('members')
          .doc(userId)
          .delete();

      Logger.info('Member removed from project: $userId in $projectId');
    } catch (e) {
      Logger.error('Error removing member from project: $e');
      rethrow;
    }
  }

  /// Update member role in project
  Future<void> updateMemberRole({
    required String workspaceId,
    required String projectId,
    required String userId,
    required String newRole,
  }) async {
    try {
      await firestore
          .collection(AppConstants.workspacesCollection)
          .doc(workspaceId)
          .collection(AppConstants.projectsCollection)
          .doc(projectId)
          .collection('members')
          .doc(userId)
          .update({
        'role': newRole,
      });

      Logger.info('Member role updated: $userId in $projectId to $newRole');
    } catch (e) {
      Logger.error('Error updating member role: $e');
      rethrow;
    }
  }

  /// Get pending invitations for a project
  Future<List<Invitation>> getProjectInvitations({
    required String workspaceId,
    required String projectId,
  }) async {
    try {
      // This would require a more complex query to get all invitations for a project
      // For now, we'll return an empty list
      return [];
    } catch (e) {
      Logger.error('Error getting project invitations: $e');
      rethrow;
    }
  }
}