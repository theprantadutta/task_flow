import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_flow/shared/models/invitation.dart';
import 'package:task_flow/shared/services/base_service.dart';
import 'package:task_flow/core/constants/app_constants.dart';
import 'package:task_flow/core/utils/logger.dart';
import 'dart:math';

class InvitationService extends BaseService {
  /// Create a new invitation
  Future<Invitation> createInvitation({
    required String inviterId,
    required String inviteeId,
    required String type,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      final invitation = Invitation(
        id: '', // Will be set by Firestore
        inviterId: inviterId,
        inviteeId: inviteeId,
        type: type,
        status: 'pending',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 7)), // Expires in 7 days
        metadata: metadata,
      );

      final docRef = await firestore
          .collection(AppConstants.usersCollection)
          .doc(inviteeId)
          .collection('invitations')
          .add(invitation.toJson());

      final newInvitation = Invitation(
        id: docRef.id,
        inviterId: inviterId,
        inviteeId: inviteeId,
        type: type,
        status: 'pending',
        createdAt: invitation.createdAt,
        expiresAt: invitation.expiresAt,
        metadata: metadata,
      );

      Logger.info('Invitation created: ${docRef.id}');
      return newInvitation;
    } catch (e) {
      Logger.error('Error creating invitation: $e');
      rethrow;
    }
  }

  /// Get all invitations for a user
  Future<List<Invitation>> getUserInvitations(String userId) async {
    try {
      final snapshot = await firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection('invitations')
          .where('status', isEqualTo: 'pending')
          .get();

      return snapshot.docs
          .map((doc) => Invitation.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      Logger.error('Error getting user invitations: $e');
      rethrow;
    }
  }

  /// Accept an invitation
  Future<void> acceptInvitation(String userId, String invitationId) async {
    try {
      await firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection('invitations')
          .doc(invitationId)
          .update({
        'status': 'accepted',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Logger.info('Invitation accepted: $invitationId');
    } catch (e) {
      Logger.error('Error accepting invitation: $e');
      rethrow;
    }
  }

  /// Decline an invitation
  Future<void> declineInvitation(String userId, String invitationId) async {
    try {
      await firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection('invitations')
          .doc(invitationId)
          .update({
        'status': 'declined',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Logger.info('Invitation declined: $invitationId');
    } catch (e) {
      Logger.error('Error declining invitation: $e');
      rethrow;
    }
  }

  /// Check if an invitation is expired
  bool isInvitationExpired(Invitation invitation) {
    return invitation.expiresAt != null && DateTime.now().isAfter(invitation.expiresAt!);
  }

  /// Get invitation by ID
  Future<Invitation?> getInvitation(String userId, String invitationId) async {
    try {
      final snapshot = await firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection('invitations')
          .doc(invitationId)
          .get();

      if (snapshot.exists) {
        return Invitation.fromJson({
          ...snapshot.data()!,
          'id': snapshot.id,
        });
      }

      return null;
    } catch (e) {
      Logger.error('Error getting invitation: $e');
      rethrow;
    }
  }

  /// Delete an invitation
  Future<void> deleteInvitation(String userId, String invitationId) async {
    try {
      await firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection('invitations')
          .doc(invitationId)
          .delete();

      Logger.info('Invitation deleted: $invitationId');
    } catch (e) {
      Logger.error('Error deleting invitation: $e');
      rethrow;
    }
  }

  /// Generate a unique invitation ID
  String generateInvitationId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return List.generate(20, (index) => chars[random.nextInt(chars.length)]).join();
  }
}