import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/config/api_config.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _role;
  String? _name;
  bool _isLoading = false;

  String? get token => _token;
  String? get role => _role;
  String? get name => _name;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  String get _baseUrl => ApiConfig.baseUrl;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _token = data['token'];
        _role = data['role'];
        _name = data['name'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('role', _role!);
        await prefs.setString('name', _name!);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token')) return;

    _token = prefs.getString('token');
    _role = prefs.getString('role');
    _name = prefs.getString('name');
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _role = null;
    _name = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
