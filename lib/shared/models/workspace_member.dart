class WorkspaceMember {
  final String workspaceId;
  final String userId;
  final String role;
  final DateTime joinedAt;

  WorkspaceMember({
    required this.workspaceId,
    required this.userId,
    required this.role,
    required this.joinedAt,
  });

  factory WorkspaceMember.fromJson(Map<String, dynamic> json) {
    return WorkspaceMember(
      workspaceId: json['workspaceId'] as String,
      userId: json['userId'] as String,
      role: json['role'] as String,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workspaceId': workspaceId,
      'userId': userId,
      'role': role,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }
}