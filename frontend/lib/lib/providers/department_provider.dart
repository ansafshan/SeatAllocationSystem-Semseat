import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/department.dart';
import 'auth_provider.dart';
import '../core/config/api_config.dart';

class DepartmentProvider with ChangeNotifier {
  List<Department> _departments = [];
  bool _isLoading = false;

  List<Department> get departments => _departments;
  bool get isLoading => _isLoading;

  static final String _baseUrl = '${ApiConfig.baseUrl}/departments';

  Future<void> fetchDepartments(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _departments = data.map((json) => Department.fromJson(json)).toList();
      }
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addDepartment(String name, String token) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'name': name}),
      );

      if (response.statusCode == 201) {
        final newDept = Department.fromJson(jsonDecode(response.body));
        _departments.insert(0, newDept);
        notifyListeners();
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<bool> updateDepartment(int id, String name, String token) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'name': name}),
      );

      if (response.statusCode == 200) {
        final index = _departments.indexWhere((dept) => dept.id == id);
        if (index != -1) {
          _departments[index] = Department.fromJson(jsonDecode(response.body));
          notifyListeners();
        }
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<bool> deleteDepartment(int id, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _departments.removeWhere((dept) => dept.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }
}
