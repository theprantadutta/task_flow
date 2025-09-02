class ProjectMember {
  final String projectId;
  final String userId;
  final String role; // manager, member, viewer
  final String status; // invited, accepted, declined
  final DateTime joinedAt;
  final DateTime? invitedAt;

  ProjectMember({
    required this.projectId,
    required this.userId,
    required this.role,
    required this.status,
    required this.joinedAt,
    this.invitedAt,
  });

  factory ProjectMember.fromJson(Map<String, dynamic> json) {
    return ProjectMember(
      projectId: json['projectId'] as String,
      userId: json['userId'] as String,
      role: json['role'] as String,
      status: json['status'] as String,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      invitedAt: json['invitedAt'] == null ? null : DateTime.parse(json['invitedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'userId': userId,
      'role': role,
      'status': status,
      'joinedAt': joinedAt.toIso8601String(),
      'invitedAt': invitedAt?.toIso8601String(),
    };
  }

  ProjectMember copyWith({
    String? projectId,
    String? userId,
    String? role,
    String? status,
    DateTime? joinedAt,
    DateTime? invitedAt,
  }) {
    return ProjectMember(
      projectId: projectId ?? this.projectId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      status: status ?? this.status,
      joinedAt: joinedAt ?? this.joinedAt,
      invitedAt: invitedAt ?? this.invitedAt,
    );
  }
}