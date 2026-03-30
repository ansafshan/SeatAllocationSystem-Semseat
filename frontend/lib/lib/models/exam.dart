import 'student.dart';
import 'subject.dart';
import 'hall.dart';
import 'department.dart';
import 'teacher.dart';

class Session {
  final int id;
  final String name;
  final String type; // series or university

  Session({required this.id, required this.name, required this.type});

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'],
      name: json['name'],
      type: json['type'],
    );
  }
}

class ExamDay {
  final int id;
  final int sessionId;
  final String date;
  final String slot; // FN or AN
  final Session? session;

  ExamDay({required this.id, required this.sessionId, required this.date, required this.slot, this.session});

  factory ExamDay.fromJson(Map<String, dynamic> json) {
    return ExamDay(
      id: json['id'],
      sessionId: json['session_id'],
      date: json['date'],
      slot: json['slot'],
      session: json['Session'] != null ? Session.fromJson(json['Session']) : null,
    );
  }
}

class ExamDaySubject {
  final int id;
  final int examDayId;
  final int subjectId;
  final Subject? subject;

  ExamDaySubject({
    required this.id,
    required this.examDayId,
    required this.subjectId,
    this.subject,
  });

  factory ExamDaySubject.fromJson(Map<String, dynamic> json) {
    return ExamDaySubject(
      id: json['id'],
      examDayId: json['exam_day_id'],
      subjectId: json['subject_id'],
      subject: json['Subject'] != null ? Subject.fromJson(json['Subject']) : null,
    );
  }
}

class SeatAllocation {
  final int id;
  final int studentId;
  final int hallId;
  final int examDayId;
  final int benchRow;
  final int benchCol;
  final String seatPosition;
  final Student? student;
  final Hall? hall;
  final ExamDay? examDay;

  SeatAllocation({
    required this.id,
    required this.studentId,
    required this.hallId,
    required this.examDayId,
    required this.benchRow,
    required this.benchCol,
    required this.seatPosition,
    this.student,
    this.hall,
    this.examDay,
  });

  factory SeatAllocation.fromJson(Map<String, dynamic> json) {
    return SeatAllocation(
      id: json['id'],
      studentId: json['student_id'],
      hallId: json['hall_id'],
      examDayId: json['exam_day_id'],
      benchRow: json['bench_row'],
      benchCol: json['bench_col'],
      seatPosition: json['seat_position'],
      student: json['Student'] != null ? Student.fromJson(json['Student']) : null,
      hall: json['Hall'] != null ? Hall.fromJson(json['Hall']) : null,
      examDay: json['ExamDay'] != null ? ExamDay.fromJson(json['ExamDay']) : null,
    );
  }
}

class HallTeacherAssignment {
  final int id;
  final int examDayId;
  final int hallId;
  final int teacherId;
  final Teacher? teacher;
  final Hall? hall;

  HallTeacherAssignment({
    required this.id,
    required this.examDayId,
    required this.hallId,
    required this.teacherId,
    this.teacher,
    this.hall,
  });

  factory HallTeacherAssignment.fromJson(Map<String, dynamic> json) {
    return HallTeacherAssignment(
      id: json['id'],
      examDayId: json['exam_day_id'],
      hallId: json['hall_id'],
      teacherId: json['teacher_id'],
      teacher: json['Teacher'] != null ? Teacher.fromJson(json['Teacher']) : null,
      hall: json['Hall'] != null ? Hall.fromJson(json['Hall']) : null,
    );
  }
}
