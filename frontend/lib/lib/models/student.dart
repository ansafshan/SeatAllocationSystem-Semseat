class Student {
  final int id;
  final String name;
  final String email;
  final String regNo;
  final String rollNo;
  final String dob;
  final int deptId;
  final int batchId;
  final String? deptName;
  final String? batchName;
  final DateTime createdAt;

  Student({
    required this.id,
    required this.name,
    required this.email,
    required this.regNo,
    required this.rollNo,
    required this.dob,
    required this.deptId,
    required this.batchId,
    this.deptName,
    this.batchName,
    required this.createdAt,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['User'] != null ? json['User']['name'] : '',
      email: json['User'] != null ? json['User']['email'] : '',
      regNo: json['reg_no'],
      rollNo: json['roll_no'],
      dob: json['dob'] ?? '',
      deptId: json['dept_id'],
      batchId: json['batch_id'],
      deptName: json['Department'] != null ? json['Department']['name'] : null,
      batchName: json['Batch'] != null ? json['Batch']['name'] : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
