import 'package:task_flow/shared/models/workspace_member.dart';

class WorkspaceMemberEnhanced extends WorkspaceMember {
  final String status; // invited, accepted, declined
  final DateTime? invitedAt;

  WorkspaceMemberEnhanced({
    required super.workspaceId,
    required super.userId,
    required super.role,
    required super.joinedAt,
    required this.status,
    this.invitedAt,
  });

  factory WorkspaceMemberEnhanced.fromJson(Map<String, dynamic> json) {
    return WorkspaceMemberEnhanced(
      workspaceId: json['workspaceId'] as String,
      userId: json['userId'] as String,
      role: json['role'] as String,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      status: json['status'] as String,
      invitedAt: json['invitedAt'] == null ? null : DateTime.parse(json['invitedAt'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'workspaceId': workspaceId,
      'userId': userId,
      'role': role,
      'joinedAt': joinedAt.toIso8601String(),
      'status': status,
      'invitedAt': invitedAt?.toIso8601String(),
    };
  }

  WorkspaceMemberEnhanced copyWith({
    String? workspaceId,
    String? userId,
    String? role,
    DateTime? joinedAt,
    String? status,
    DateTime? invitedAt,
  }) {
    return WorkspaceMemberEnhanced(
      workspaceId: workspaceId ?? this.workspaceId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      status: status ?? this.status,
      invitedAt: invitedAt ?? this.invitedAt,
    );
  }
}