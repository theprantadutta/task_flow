class TaskAssignment {
  final String taskId;
  final String userId;
  final String role; // assignee, collaborator, reviewer
  final String status; // invited, accepted, declined
  final DateTime assignedAt;
  final DateTime? invitedAt;

  TaskAssignment({
    required this.taskId,
    required this.userId,
    required this.role,
    required this.status,
    required this.assignedAt,
    this.invitedAt,
  });

  factory TaskAssignment.fromJson(Map<String, dynamic> json) {
    return TaskAssignment(
      taskId: json['taskId'] as String,
      userId: json['userId'] as String,
      role: json['role'] as String,
      status: json['status'] as String,
      assignedAt: DateTime.parse(json['assignedAt'] as String),
      invitedAt: json['invitedAt'] == null ? null : DateTime.parse(json['invitedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      'userId': userId,
      'role': role,
      'status': status,
      'assignedAt': assignedAt.toIso8601String(),
      'invitedAt': invitedAt?.toIso8601String(),
    };
  }

  TaskAssignment copyWith({
    String? taskId,
    String? userId,
    String? role,
    String? status,
    DateTime? assignedAt,
    DateTime? invitedAt,
  }) {
    return TaskAssignment(
      taskId: taskId ?? this.taskId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      status: status ?? this.status,
      assignedAt: assignedAt ?? this.assignedAt,
      invitedAt: invitedAt ?? this.invitedAt,
    );
  }
}