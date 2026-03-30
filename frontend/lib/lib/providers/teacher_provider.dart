import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/teacher.dart';
import '../models/exam.dart';
import '../models/malpractice.dart';
import '../core/config/api_config.dart';

class TeacherProvider with ChangeNotifier {
  List<Teacher> _teachers = [];
  List<dynamic> _duties = [];
  List<SeatAllocation> _hallSeats = [];
  List<MalpracticeLog> _recentMalpractice = [];
  bool _isLoading = false;

  List<Teacher> get teachers => _teachers;
  List<dynamic> get duties => _duties;
  List<SeatAllocation> get hallSeats => _hallSeats;
  List<MalpracticeLog> get recentMalpractice => _recentMalpractice;
  bool get isLoading => _isLoading;

  static final String _baseUrl = '${ApiConfig.baseUrl}/teachers';

  Future<void> fetchTeachers(String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(Uri.parse(_baseUrl), headers: { 'Authorization': 'Bearer $token' });
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _teachers = data.map((json) => Teacher.fromJson(json)).toList();
      }
    } catch (e) { print(e); } finally { _isLoading = false; notifyListeners(); }
  }

  Future<void> fetchDuties(String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(Uri.parse('$_baseUrl/duties'), headers: { 'Authorization': 'Bearer $token' });
      if (response.statusCode == 200) {
        _duties = jsonDecode(response.body);
      }
    } catch (e) { print(e); } finally { _isLoading = false; notifyListeners(); }
  }

  Future<void> fetchHallSeats(int dayId, int hallId, String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(Uri.parse('$_baseUrl/halls/$dayId/$hallId/seats'), headers: { 'Authorization': 'Bearer $token' });
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _hallSeats = data.map((json) => SeatAllocation.fromJson(json)).toList();
      }
    } catch (e) { print(e); } finally { _isLoading = false; notifyListeners(); }
  }

  Future<void> fetchRecentMalpractice(String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(Uri.parse('$_baseUrl/malpractice/recent'), headers: { 'Authorization': 'Bearer $token' });
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _recentMalpractice = data.map((json) => MalpracticeLog.fromJson(json)).toList();
      }
    } catch (e) { print(e); } finally { _isLoading = false; notifyListeners(); }
  }

  Future<bool> deleteMalpractice(int id, String token) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/malpractice/$id'), headers: { 'Authorization': 'Bearer $token' });
      if (response.statusCode == 200) {
        _recentMalpractice.removeWhere((m) => m.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) { print(e); }
    return false;
  }

  Future<bool> reportMalpractice(int studentId, int examDayId, String reason, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/report-malpractice'),
        headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer $token' },
        body: jsonEncode({
          'student_id': studentId,
          'exam_day_id': examDayId,
          'reason': reason,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> addTeacher(Map<String, dynamic> teacherData, String token) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer $token' },
        body: jsonEncode(teacherData),
      );
      if (response.statusCode == 201) {
        _teachers.insert(0, Teacher.fromJson(jsonDecode(response.body)));
        notifyListeners();
        return true;
      }
    } catch (e) { print(e); }
    return false;
  }

  Future<bool> updateTeacher(int id, Map<String, dynamic> teacherData, String token) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer $token' },
        body: jsonEncode(teacherData),
      );
      if (response.statusCode == 200) {
        final index = _teachers.indexWhere((t) => t.id == id);
        if (index != -1) {
          _teachers[index] = Teacher.fromJson(jsonDecode(response.body));
          notifyListeners();
        }
        return true;
      }
    } catch (e) { print(e); }
    return false;
  }

  Future<bool> deleteTeacher(int id, String token) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/$id'), headers: { 'Authorization': 'Bearer $token' });
      if (response.statusCode == 200) {
        _teachers.removeWhere((t) => t.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) { print(e); }
    return false;
  }
}
