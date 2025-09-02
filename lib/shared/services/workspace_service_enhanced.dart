import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_flow/shared/models/workspace.dart';
import 'package:task_flow/shared/models/workspace_member_enhanced.dart';
import 'package:task_flow/shared/models/invitation.dart';
import 'package:task_flow/shared/services/base_service.dart';
import 'package:task_flow/shared/services/invitation_service.dart';
import 'package:task_flow/core/constants/app_constants.dart';
import 'package:task_flow/core/utils/logger.dart';

class WorkspaceServiceEnhanced extends BaseService {
  final InvitationService _invitationService;

  WorkspaceServiceEnhanced({InvitationService? invitationService})
      : _invitationService = invitationService ?? InvitationService();

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

      // Add the owner as a member with accepted status
      await addMemberToWorkspace(
        workspaceId: docRef.id,
        userId: ownerId,
        role: AppConstants.adminRole,
        status: 'accepted',
      );

      Logger.info('Workspace created: ${docRef.id}');
      
      // Log the workspace creation event
      await analyticsService.logWorkspaceCreated();
      
      return newWorkspace;
    } catch (e) {
      Logger.error('Error creating workspace: $e');
      rethrow;
    }
  }

  Future<List<Workspace>> getUserWorkspaces(String userId) async {
    try {
      // Start a performance trace
      final trace = await analyticsService.startTrace('get_user_workspaces');
      
      final snapshot = await firestore
          .collection(AppConstants.workspacesCollection)
          .where('ownerId', isEqualTo: userId)
          .get();
          
      // Stop the trace
      await trace.stop();

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

  /// Add a member to workspace with status tracking
  Future<void> addMemberToWorkspace({
    required String workspaceId,
    required String userId,
    required String role,
    required String status,
  }) async {
    try {
      final member = WorkspaceMemberEnhanced(
        workspaceId: workspaceId,
        userId: userId,
        role: role,
        joinedAt: DateTime.now(),
        status: status,
        invitedAt: status == 'invited' ? DateTime.now() : null,
      );

      await firestore
          .collection(AppConstants.workspacesCollection)
          .doc(workspaceId)
          .collection('members')
          .doc(userId)
          .set(member.toJson());

      Logger.info('Member added to workspace: $userId in $workspaceId with status $status');
    } catch (e) {
      Logger.error('Error adding member to workspace: $e');
      rethrow;
    }
  }

  /// Invite a user to a workspace
  Future<Invitation> inviteUserToWorkspace({
    required String workspaceId,
    required String inviterId,
    required String inviteeId,
    required String role,
  }) async {
    try {
      // Check if user is already a member
      final isMember = await isUserMemberOfWorkspace(
        workspaceId: workspaceId,
        userId: inviteeId,
      );

      if (isMember) {
        throw Exception('User is already a member of this workspace');
      }

      // Create invitation
      final invitation = await _invitationService.createInvitation(
        inviterId: inviterId,
        inviteeId: inviteeId,
        type: 'workspace',
        metadata: {
          'workspaceId': workspaceId,
          'role': role,
        },
      );

      // Add user as invited member
      await addMemberToWorkspace(
        workspaceId: workspaceId,
        userId: inviteeId,
        role: role,
        status: 'invited',
      );

      Logger.info('User invited to workspace: $inviteeId to $workspaceId');
      return invitation;
    } catch (e) {
      Logger.error('Error inviting user to workspace: $e');
      rethrow;
    }
  }

  /// Accept workspace invitation
  Future<void> acceptWorkspaceInvitation({
    required String workspaceId,
    required String userId,
  }) async {
    try {
      await firestore
          .collection(AppConstants.workspacesCollection)
          .doc(workspaceId)
          .collection('members')
          .doc(userId)
          .update({
        'status': 'accepted',
        'joinedAt': FieldValue.serverTimestamp(),
      });

      Logger.info('User accepted workspace invitation: $userId in $workspaceId');
    } catch (e) {
      Logger.error('Error accepting workspace invitation: $e');
      rethrow;
    }
  }

  /// Decline workspace invitation
  Future<void> declineWorkspaceInvitation({
    required String workspaceId,
    required String userId,
  }) async {
    try {
      await removeMemberFromWorkspace(
        workspaceId: workspaceId,
        userId: userId,
      );

      Logger.info('User declined workspace invitation: $userId in $workspaceId');
    } catch (e) {
      Logger.error('Error declining workspace invitation: $e');
      rethrow;
    }
  }

  Future<List<WorkspaceMemberEnhanced>> getWorkspaceMembers(String workspaceId) async {
    try {
      final snapshot = await firestore
          .collection(AppConstants.workspacesCollection)
          .doc(workspaceId)
          .collection('members')
          .get();

      return snapshot.docs
          .map((doc) => WorkspaceMemberEnhanced.fromJson({
                ...doc.data(),
                'workspaceId': workspaceId,
              }))
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

      // Check if user exists and has accepted status
      if (snapshot.exists) {
        final data = snapshot.data();
        return data?['status'] == 'accepted';
      }

      return false;
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

  /// Get pending invitations for a workspace
  Future<List<Invitation>> getWorkspaceInvitations(String workspaceId) async {
    try {
      // This would require a more complex query to get all invitations for a workspace
      // For now, we'll return an empty list
      return [];
    } catch (e) {
      Logger.error('Error getting workspace invitations: $e');
      rethrow;
    }
  }
}