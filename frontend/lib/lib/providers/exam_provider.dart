import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/exam.dart';
import '../core/config/api_config.dart';

class ExamProvider with ChangeNotifier {
  List<Session> _sessions = [];
  List<ExamDay> _examDays = [];
  List<ExamDaySubject> _daySubjects = [];
  List<SeatAllocation> _allocations = [];
  List<HallTeacherAssignment> _hallTeachers = [];
  bool _isLoading = false;

  List<Session> get sessions => _sessions;
  List<ExamDay> get examDays => _examDays;
  List<ExamDaySubject> get daySubjects => _daySubjects;
  List<SeatAllocation> get allocations => _allocations;
  List<HallTeacherAssignment> get hallTeachers => _hallTeachers;
  bool get isLoading => _isLoading;

  static final String _baseUrl = '${ApiConfig.baseUrl}/exams';

  void _setLoading(bool loading) {
    _isLoading = loading;
    // Use microtask to avoid "setState() called during build" errors
    Future.microtask(() => notifyListeners());
  }

  Future<void> _logResponse(String method, String url, http.Response response) async {
    print('EXAM_PROV: $method $url');
    print('EXAM_PROV: Status ${response.statusCode}');
    if (response.statusCode >= 400) {
      print('EXAM_PROV: Error Body: ${response.body}');
    }
  }

  Future<void> fetchSessions(String token) async {
    _setLoading(true);
    final url = '$_baseUrl/sessions';
    try {
      final response = await http.get(Uri.parse(url), headers: {'Authorization': 'Bearer $token'});
      await _logResponse('GET', url, response);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _sessions = data.map((json) => Session.fromJson(json)).toList();
      }
    } catch (e) { print('EXAM_PROV_EXCEPTION: $e'); }
    finally { _setLoading(false); }
  }

  Future<void> fetchSession(int sessionId, String token) async {
    _setLoading(true);
    final url = '$_baseUrl/sessions/$sessionId';
    try {
      final response = await http.get(Uri.parse(url), headers: {'Authorization': 'Bearer $token'});
      await _logResponse('GET', url, response);
      if (response.statusCode == 200) {
        final session = Session.fromJson(jsonDecode(response.body));
        final index = _sessions.indexWhere((s) => s.id == session.id);
        if (index != -1) {
          _sessions[index] = session;
        } else {
          _sessions.add(session);
        }
      }
    } catch (e) { print('EXAM_PROV_EXCEPTION: $e'); }
    finally { _setLoading(false); }
  }

  Future<bool> createSession(String name, String type, String token) async {
    _setLoading(true);
    final url = '$_baseUrl/sessions';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'name': name, 'type': type}),
      );
      await _logResponse('POST', url, response);
      if (response.statusCode == 201) {
        await fetchSessions(token);
        return true;
      }
    } catch (e) { print('EXAM_PROV_EXCEPTION: $e'); }
    finally { _setLoading(false); }
    return false;
  }

  Future<Map<String, dynamic>> deleteSession(int sessionId, String token) async {
    _setLoading(true);
    final url = '$_baseUrl/sessions/$sessionId';
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );
      await _logResponse('DELETE', url, response);
      if (response.statusCode == 200) {
        _sessions.removeWhere((session) => session.id == sessionId);
        return {'success': true, 'message': 'Session deleted successfully.'};
      }
      return {'success': false, 'message': jsonDecode(response.body)['message'] ?? 'Failed to delete'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchExamDays(int sessionId, String token) async {
    _setLoading(true);
    final url = '$_baseUrl/sessions/$sessionId/days';
    try {
      final response = await http.get(Uri.parse(url), headers: {'Authorization': 'Bearer $token'});
      await _logResponse('GET', url, response);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _examDays = data.map((json) => ExamDay.fromJson(json)).toList();
      }
    } catch (e) { print('EXAM_PROV_EXCEPTION: $e'); }
    finally { _setLoading(false); }
  }

  Future<void> fetchExamDay(int dayId, String token) async {
    _setLoading(true);
    final url = '$_baseUrl/exam-days/$dayId';
    try {
      final response = await http.get(Uri.parse(url), headers: {'Authorization': 'Bearer $token'});
      await _logResponse('GET', url, response);
      if (response.statusCode == 200) {
        final day = ExamDay.fromJson(jsonDecode(response.body));
        final index = _examDays.indexWhere((d) => d.id == day.id);
        if (index != -1) {
          _examDays[index] = day;
        } else {
          _examDays.add(day);
        }
      }
    } catch (e) { print('EXAM_PROV_EXCEPTION: $e'); }
    finally { _setLoading(false); }
  }

  Future<bool> createExamDay(int sessionId, String date, String slot, String token) async {
    _setLoading(true);
    final url = '$_baseUrl/sessions/$sessionId/days';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'date': date, 'slot': slot}),
      );
      await _logResponse('POST', url, response);
      if (response.statusCode == 201) {
        await fetchExamDays(sessionId, token);
        return true;
      }
    } catch (e) { print('EXAM_PROV_EXCEPTION: $e'); }
    finally { _setLoading(false); }
    return false;
  }

  Future<Map<String, dynamic>> deleteExamDay(int dayId, String token) async {
    _setLoading(true);
    final url = '$_baseUrl/exam-days/$dayId';
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );
      await _logResponse('DELETE', url, response);
      if (response.statusCode == 200) {
        _examDays.removeWhere((day) => day.id == dayId);
        return {'success': true, 'message': 'Exam day deleted successfully.'};
      }
      return {'success': false, 'message': jsonDecode(response.body)['message'] ?? 'Failed to delete'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchDaySubjects(int dayId, String token) async {
    _setLoading(true);
    final url = '$_baseUrl/exam-days/$dayId/subjects';
    try {
      final response = await http.get(Uri.parse(url), headers: {'Authorization': 'Bearer $token'});
      await _logResponse('GET', url, response);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _daySubjects = data.map((json) => ExamDaySubject.fromJson(json)).toList();
      }
    } catch (e) { print('EXAM_PROV_EXCEPTION: $e'); }
    finally { _setLoading(false); }
  }

  Future<bool> addDaySubject(int dayId, int subjectId, String token) async {
    _setLoading(true);
    final url = '$_baseUrl/exam-days/$dayId/subjects';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'subject_id': subjectId}),
      );
      await _logResponse('POST', url, response);
      if (response.statusCode == 201) {
        await fetchDaySubjects(dayId, token);
        return true;
      }
    } catch (e) { print('EXAM_PROV_EXCEPTION: $e'); }
    finally { _setLoading(false); }
    return false;
  }

  Future<Map<String, dynamic>> removeDaySubject(int dayId, int subjectId, String token) async {
    _setLoading(true);
    final url = '$_baseUrl/exam-days/$dayId/subjects/$subjectId';
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );
      await _logResponse('DELETE', url, response);
      if (response.statusCode == 200) {
        _daySubjects.removeWhere((ds) => ds.subjectId == subjectId);
        return {'success': true, 'message': 'Subject removed successfully.'};
      }
      return {'success': false, 'message': jsonDecode(response.body)['message'] ?? 'Failed to remove'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> allocate(int dayId, String token) async {
    _setLoading(true);
    final url = '$_baseUrl/exam-days/$dayId/allocate';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({}),
      );
      await _logResponse('POST', url, response);
      if (response.statusCode == 200) {
        await fetchAllocations(dayId, token);
        return true;
      }
    } catch (e) { print('EXAM_PROV_EXCEPTION: $e'); }
    finally { _setLoading(false); }
    return false;
  }

  Future<void> fetchAllocations(int dayId, String token) async {
    final url = '$_baseUrl/exam-days/$dayId/allocations';
    try {
      final response = await http.get(Uri.parse(url), headers: {'Authorization': 'Bearer $token'});
      await _logResponse('GET', url, response);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        if (data.containsKey('allocations')) {
          final List<dynamic> allocData = data['allocations'];
          _allocations = allocData.map((json) => SeatAllocation.fromJson(json)).toList();
        } else {
          _allocations = [];
        }

        if (data.containsKey('teachers')) {
          final List<dynamic> teacherData = data['teachers'];
          _hallTeachers = teacherData.map((json) => HallTeacherAssignment.fromJson(json)).toList();
        } else {
          _hallTeachers = [];
        }

        Future.microtask(() => notifyListeners());
      }
    } catch (e) { print('EXAM_PROV_EXCEPTION: $e'); }
  }

  Future<Map<String, dynamic>> deleteAllocations(int dayId, String token) async {
    _setLoading(true);
    final url = '$_baseUrl/exam-days/$dayId/allocations';
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );
      await _logResponse('DELETE', url, response);
      if (response.statusCode == 200) {
        _allocations.clear();
        return {'success': true, 'message': 'Allocations cleared successfully.'};
      }
      return {'success': false, 'message': jsonDecode(response.body)['message'] ?? 'Failed to clear'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> assignTeacherManually(int dayId, int hallId, int teacherId, String token) async {
    _setLoading(true);
    final url = '$_baseUrl/exam-days/$dayId/assign-teacher';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({
          'hallId': hallId,
          'teacherId': teacherId
        }),
      );
      await _logResponse('POST', url, response);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final assignment = HallTeacherAssignment.fromJson(data['assignment']);
        
        // Remove existing assignment for this teacher if it exists (local move)
        _hallTeachers.removeWhere((a) => a.teacherId == teacherId);
        
        _hallTeachers.add(assignment);
        notifyListeners();
        return {'success': true, 'message': 'Teacher assigned/moved successfully.'};
      }
      return {'success': false, 'message': jsonDecode(response.body)['message'] ?? 'Failed to assign teacher'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> removeTeacherAssignment(int dayId, int teacherId, String token) async {
    _setLoading(true);
    final url = '$_baseUrl/exam-days/$dayId/teachers/$teacherId';
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );
      await _logResponse('DELETE', url, response);
      if (response.statusCode == 200) {
        _hallTeachers.removeWhere((a) => a.teacherId == teacherId);
        notifyListeners();
        return {'success': true, 'message': 'Teacher assignment removed.'};
      }
      return {'success': false, 'message': jsonDecode(response.body)['message'] ?? 'Failed to remove teacher'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    } finally {
      _setLoading(false);
    }
  }
}
