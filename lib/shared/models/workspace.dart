class Workspace {
  final String id;
  final String name;
  final String ownerId;
  final DateTime createdAt;

  Workspace({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.createdAt,
  });

  factory Workspace.fromJson(Map<String, dynamic> json) {
    return Workspace(
      id: json['id'] as String,
      name: json['name'] as String,
      ownerId: json['ownerId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}