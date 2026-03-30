class Hall {
  final int id;
  final String name;
  final int rows;
  final int cols;
  final DateTime createdAt;

  Hall({
    required this.id,
    required this.name,
    required this.rows,
    required this.cols,
    required this.createdAt,
  });

  int get capacity => rows * cols * 3;

  factory Hall.fromJson(Map<String, dynamic> json) {
    return Hall(
      id: json['id'],
      name: json['name'],
      rows: json['rows'],
      cols: json['cols'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
