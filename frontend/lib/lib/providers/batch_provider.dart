import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/batch.dart';
import '../core/config/api_config.dart';

class BatchProvider with ChangeNotifier {
  List<Batch> _batches = [];
  bool _isLoading = false;

  List<Batch> get batches => _batches;
  bool get isLoading => _isLoading;

  static final String _baseUrl = '${ApiConfig.baseUrl}/batches';

  Future<void> fetchBatches(String token) async {
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
        _batches = data.map((json) => Batch.fromJson(json)).toList();
      }
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addBatch(String name, int deptId, String token) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'name': name, 'dept_id': deptId}),
      );

      if (response.statusCode == 201) {
        final newBatch = Batch.fromJson(jsonDecode(response.body));
        _batches.insert(0, newBatch);
        notifyListeners();
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<bool> updateBatch(int id, String name, int deptId, String token) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'name': name, 'dept_id': deptId}),
      );

      if (response.statusCode == 200) {
        final index = _batches.indexWhere((b) => b.id == id);
        if (index != -1) {
          _batches[index] = Batch.fromJson(jsonDecode(response.body));
          notifyListeners();
        }
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<bool> deleteBatch(int id, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _batches.removeWhere((b) => b.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }
}
