class Batch {
  final int id;
  final String name;
  final int deptId;
  final String? deptName;
  final DateTime createdAt;

  Batch({
    required this.id,
    required this.name,
    required this.deptId,
    this.deptName,
    required this.createdAt,
  });

  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
      id: json['id'],
      name: json['name'],
      deptId: json['dept_id'],
      deptName: json['Department'] != null ? json['Department']['name'] : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dept_id': deptId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
