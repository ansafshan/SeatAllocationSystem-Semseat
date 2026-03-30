import 'exam.dart';
import 'student.dart';

class MalpracticeLog {
  final int id;
  final int studentId;
  final int examDayId;
  final String reason;
  final String createdAt;
  final ExamDay? examDay;
  final Student? student;

  MalpracticeLog({
    required this.id,
    required this.studentId,
    required this.examDayId,
    required this.reason,
    required this.createdAt,
    this.examDay,
    this.student,
  });

  factory MalpracticeLog.fromJson(Map<String, dynamic> json) {
    return MalpracticeLog(
      id: json['id'],
      studentId: json['student_id'],
      examDayId: json['exam_day_id'],
      reason: json['reason'],
      createdAt: json['created_at'],
      examDay: json['ExamDay'] != null ? ExamDay.fromJson(json['ExamDay']) : null,
      student: json['Student'] != null ? Student.fromJson(json['Student']) : null,
    );
  }
}
