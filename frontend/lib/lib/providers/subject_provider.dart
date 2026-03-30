import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/subject.dart';
import '../core/config/api_config.dart';

class SubjectProvider with ChangeNotifier {
  List<Subject> _subjects = [];
  bool _isLoading = false;

  List<Subject> get subjects => _subjects;
  bool get isLoading => _isLoading;

  static final String _baseUrl = '${ApiConfig.baseUrl}/subjects';

  Future<void> fetchSubjects(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: { 'Authorization': 'Bearer $token' },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _subjects = data.map((json) => Subject.fromJson(json)).toList();
      }
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addSubject(String name, String code, int deptId, int batchId, String token) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'code': code,
          'dept_id': deptId,
          'batch_id': batchId,
        }),
      );

      if (response.statusCode == 201) {
        final newSub = Subject.fromJson(jsonDecode(response.body));
        _subjects.insert(0, newSub);
        notifyListeners();
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<bool> updateSubject(int id, String name, String code, int deptId, int batchId, String token) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'code': code,
          'dept_id': deptId,
          'batch_id': batchId,
        }),
      );

      if (response.statusCode == 200) {
        final index = _subjects.indexWhere((s) => s.id == id);
        if (index != -1) {
          _subjects[index] = Subject.fromJson(jsonDecode(response.body));
          notifyListeners();
        }
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<bool> deleteSubject(int id, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: { 'Authorization': 'Bearer $token' },
      );

      if (response.statusCode == 200) {
        _subjects.removeWhere((s) => s.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }
}
