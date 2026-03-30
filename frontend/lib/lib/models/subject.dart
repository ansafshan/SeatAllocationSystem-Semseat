class Subject {
  final int id;
  final String name;
  final String code;
  final int deptId;
  final int batchId;
  final String? deptName;
  final String? batchName;
  final DateTime createdAt;

  Subject({
    required this.id,
    required this.name,
    required this.code,
    required this.deptId,
    required this.batchId,
    this.deptName,
    this.batchName,
    required this.createdAt,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      deptId: json['dept_id'],
      batchId: json['batch_id'],
      deptName: json['Department'] != null ? json['Department']['name'] : null,
      batchName: json['Batch'] != null ? json['Batch']['name'] : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'dept_id': deptId,
      'batch_id': batchId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
