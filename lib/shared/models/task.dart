class Task {
  final String id;
  final String projectId;
  final String title;
  final String? description;
  final String status;
  final String? assigneeId;
  final String reporterId;
  final DateTime? dueDate;
  final String priority;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.projectId,
    required this.title,
    this.description,
    required this.status,
    this.assigneeId,
    required this.reporterId,
    this.dueDate,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: json['status'] as String,
      assigneeId: json['assigneeId'] as String?,
      reporterId: json['reporterId'] as String,
      dueDate: json['dueDate'] == null ? null : DateTime.parse(json['dueDate'] as String),
      priority: json['priority'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      'description': description,
      'status': status,
      'assigneeId': assigneeId,
      'reporterId': reporterId,
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}