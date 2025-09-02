class Invitation {
  final String id;
  final String inviterId;
  final String inviteeId;
  final String type; // workspace, project, task
  final String status; // pending, accepted, declined
  final DateTime createdAt;
  final DateTime? expiresAt;
  final Map<String, dynamic> metadata; // Additional data like workspaceId, projectId, etc.

  Invitation({
    required this.id,
    required this.inviterId,
    required this.inviteeId,
    required this.type,
    required this.status,
    required this.createdAt,
    this.expiresAt,
    required this.metadata,
  });

  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      id: json['id'] as String,
      inviterId: json['inviterId'] as String,
      inviteeId: json['inviteeId'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] == null ? null : DateTime.parse(json['expiresAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inviterId': inviterId,
      'inviteeId': inviteeId,
      'type': type,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  Invitation copyWith({
    String? id,
    String? inviterId,
    String? inviteeId,
    String? type,
    String? status,
    DateTime? createdAt,
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
  }) {
    return Invitation(
      id: id ?? this.id,
      inviterId: inviterId ?? this.inviterId,
      inviteeId: inviteeId ?? this.inviteeId,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      metadata: metadata ?? this.metadata,
    );
  }
}