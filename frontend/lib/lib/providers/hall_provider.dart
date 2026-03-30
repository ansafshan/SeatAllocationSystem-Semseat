import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/hall.dart';
import '../core/config/api_config.dart';

class DisabledBench {
  final int hallId;
  final int row;
  final int col;
  DisabledBench({required this.hallId, required this.row, required this.col});
}

class HallProvider with ChangeNotifier {
  List<Hall> _halls = [];
  List<DisabledBench> _disabledBenches = [];
  bool _isLoading = false;

  List<Hall> get halls => _halls;
  List<DisabledBench> get disabledBenches => _disabledBenches;
  bool get isLoading => _isLoading;

  static final String _baseUrl = '${ApiConfig.baseUrl}/halls';

  Future<void> fetchHalls(String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(Uri.parse(_baseUrl), headers: { 'Authorization': 'Bearer $token' });
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _halls = data.map((json) => Hall.fromJson(json)).toList();
      }
    } catch (e) { print(e); } finally { _isLoading = false; notifyListeners(); }
  }

  Future<void> fetchDisabledBenches(int hallId, String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(Uri.parse('$_baseUrl/disabled-benches/$hallId'), headers: { 'Authorization': 'Bearer $token' });
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _disabledBenches = data.map((b) => DisabledBench(hallId: b['hall_id'], row: b['bench_row'], col: b['bench_col'])).toList();
      }
    } catch(e) { print(e); }
    finally { _isLoading = false; notifyListeners(); }
  }
  
  Future<void> toggleDisabledBench(int hallId, int row, int col, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/disabled-benches/toggle'),
        headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer $token' },
        body: jsonEncode({
          'hall_id': hallId,
          'bench_row': row,
          'bench_col': col,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchDisabledBenches(hallId, token); // Refresh
      }
    } catch (e) { print(e); }
  }

  Future<bool> addHall(String name, int rows, int cols, String token) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer $token' },
        body: jsonEncode({ 'name': name, 'rows': rows, 'cols': cols }),
      );
      if (response.statusCode == 201) {
        _halls.add(Hall.fromJson(jsonDecode(response.body)));
        notifyListeners();
        return true;
      }
    } catch (e) { print(e); }
    return false;
  }

  Future<bool> updateHall(int id, String name, int rows, int cols, String token) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer $token' },
        body: jsonEncode({ 'name': name, 'rows': rows, 'cols': cols }),
      );
      if (response.statusCode == 200) {
        final index = _halls.indexWhere((h) => h.id == id);
        if (index != -1) {
          _halls[index] = Hall.fromJson(jsonDecode(response.body));
          notifyListeners();
        }
        return true;
      }
    } catch (e) { print(e); }
    return false;
  }

  Future<bool> deleteHall(int id, String token) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/$id'), headers: { 'Authorization': 'Bearer $token' });
      if (response.statusCode == 200) {
        _halls.removeWhere((h) => h.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) { print(e); }
    return false;
  }
}
