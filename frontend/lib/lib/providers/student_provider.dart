import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/student.dart';
import '../models/exam.dart';
import '../models/malpractice.dart';
import '../core/config/api_config.dart';

class StudentProvider with ChangeNotifier {
  List<Student> _students = [];
  List<SeatAllocation> _mySeats = [];
  List<MalpracticeLog> _malpracticeHistory = [];
  bool _isLoading = false;

  List<Student> get students => _students;
  List<SeatAllocation> get mySeats => _mySeats;
  List<MalpracticeLog> get malpracticeHistory => _malpracticeHistory;
  bool get isLoading => _isLoading;

  static final String _baseUrl = '${ApiConfig.baseUrl}/students';

  Future<void> fetchStudents(String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(Uri.parse(_baseUrl), headers: { 'Authorization': 'Bearer $token' });
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _students = data.map((json) => Student.fromJson(json)).toList();
      }
    } catch (e) { print(e); } finally { _isLoading = false; notifyListeners(); }
  }

  Future<void> fetchMySeats(String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(Uri.parse('$_baseUrl/seats'), headers: { 'Authorization': 'Bearer $token' });
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _mySeats = data.map((json) => SeatAllocation.fromJson(json)).toList();
      }
    } catch (e) { print(e); } finally { _isLoading = false; notifyListeners(); }
  }

  Future<void> fetchMyMalpracticeHistory(String token) async {
    _isLoading = true;
    _malpracticeHistory = [];
    notifyListeners();
    try {
      final response = await http.get(Uri.parse('$_baseUrl/malpractice'), headers: { 'Authorization': 'Bearer $token' });
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _malpracticeHistory = data.map((json) => MalpracticeLog.fromJson(json)).toList();
      }
    } catch (e) { print(e); } finally { _isLoading = false; notifyListeners(); }
  }
  
  Future<void> fetchMalpracticeHistory(int studentId, String token) async {
    _isLoading = true;
    _malpracticeHistory = [];
    notifyListeners();
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$studentId/malpractice'), headers: { 'Authorization': 'Bearer $token' });
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _malpracticeHistory = data.map((json) => MalpracticeLog.fromJson(json)).toList();
      }
    } catch (e) { print(e); } finally { _isLoading = false; notifyListeners(); }
  }

  Future<bool> deleteMalpractice(int id, String token) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/malpractice/$id'), headers: { 'Authorization': 'Bearer $token' });
      if (response.statusCode == 200) {
        _malpracticeHistory.removeWhere((m) => m.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) { print(e); }
    return false;
  }

  Future<bool> addStudent(Map<String, dynamic> studentData, String token) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer $token' },
        body: jsonEncode(studentData),
      );
      if (response.statusCode == 201) {
        _students.insert(0, Student.fromJson(jsonDecode(response.body)));
        notifyListeners();
        return true;
      }
    } catch (e) { print(e); }
    return false;
  }

  Future<bool> updateStudent(int id, Map<String, dynamic> studentData, String token) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer $token' },
        body: jsonEncode(studentData),
      );
      if (response.statusCode == 200) {
        final index = _students.indexWhere((s) => s.id == id);
        if (index != -1) {
          _students[index] = Student.fromJson(jsonDecode(response.body));
          notifyListeners();
        }
        return true;
      }
    } catch (e) { print(e); }
    return false;
  }

  Future<bool> deleteStudent(int id, String token) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/$id'), headers: { 'Authorization': 'Bearer $token' });
      if (response.statusCode == 200) {
        _students.removeWhere((s) => s.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) { print(e); }
    return false;
  }

  Future<bool> bulkUpload(List<int> fileBytes, String fileName, String token) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/bulk'));
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
        contentType: MediaType('text', 'csv'),
      ));
      var response = await request.send();
      if (response.statusCode == 201) {
        await fetchStudents(token);
        return true;
      }
    } catch (e) { print(e); }
    return false;
  }
}
