class Teacher {
  final int id;
  final String name;
  final String email;
  final String staffId;
  final int deptId;
  final int? subjectId;
  final String? deptName;
  final String? subjectName;
  final String? subjectCode;
  final DateTime createdAt;

  Teacher({
    required this.id,
    required this.name,
    required this.email,
    required this.staffId,
    required this.deptId,
    this.subjectId,
    this.deptName,
    this.subjectName,
    this.subjectCode,
    required this.createdAt,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'],
      name: json['User'] != null ? json['User']['name'] : '',
      email: json['User'] != null ? json['User']['email'] : '',
      staffId: json['staff_id'] ?? '',
      deptId: json['dept_id'],
      subjectId: json['subject_id'],
      deptName: json['Department'] != null ? json['Department']['name'] : null,
      subjectName: json['Subject'] != null ? json['Subject']['name'] : null,
      subjectCode: json['Subject'] != null ? json['Subject']['code'] : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
