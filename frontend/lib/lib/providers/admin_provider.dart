import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';

class AdminProvider with ChangeNotifier {
  Map<String, dynamic> _stats = {
    'students': 0,
    'teachers': 0,
    'halls': 0,
    'upcomingExams': 0,
  };
  List<dynamic> _recentMalpractices = [];
  bool _isLoading = false;

  Map<String, dynamic> get stats => _stats;
  List<dynamic> get recentMalpractices => _recentMalpractices;
  bool get isLoading => _isLoading;

  static final String _baseUrl = '${ApiConfig.baseUrl}/admin';

  Future<void> fetchDashboardStats(String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/stats'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        _stats = jsonDecode(response.body);
      }
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRecentMalpractices(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/malpractices'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        _recentMalpractices = jsonDecode(response.body);
        notifyListeners();
      }
    } catch (e) {
      print(e);
    }
  }
}
