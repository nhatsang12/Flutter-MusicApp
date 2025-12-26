// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String _userKey = 'current_user';
  static User? _currentUser;

  // Server base URL
  static const String baseUrl = "http://10.0.2.2:3000/api/auth";
  // Nếu chạy iOS Simulator hoặc Web, đổi localhost tương ứng

  // Load current user from SharedPreferences
  static Future<void> loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString(_userKey);
    if (userJson != null) {
      _currentUser = User.fromJson(jsonDecode(userJson));
    }
  }

  static User? getCurrentUser() => _currentUser;

  static bool isLoggedIn() => _currentUser != null;

  // ----------------- REGISTER -----------------
  static Future<bool> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // Lưu user local
          _currentUser = User(id: DateTime.now().millisecondsSinceEpoch.toString(), name: name, email: email, createdAt: DateTime.now());
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));
          return true;
        }
        return false;
      }
      return false;
    } catch (e) {
      print("Register error: $e");
      return false;
    }
  }

  // ----------------- LOGIN -----------------
  static Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['user'] != null) {
          _currentUser = User.fromJson(data['user']);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));
          print("Response login: ${response.body}");
          return true;

        }
        return false;
      }
      return false;
    } catch (e) {
      print("Login error: $e");
      return false;
    }
  }

  // ----------------- LOGOUT -----------------
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    _currentUser = null;
  }

  // ----------------- UPDATE PROFILE -----------------
  static Future<void> updateProfile(String name, {String? avatarUrl}) async {
    if (_currentUser == null) return;

    _currentUser = User(
      id: _currentUser!.id,
      email: _currentUser!.email,
      name: name,
      avatarUrl: avatarUrl,
      createdAt: _currentUser!.createdAt,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));
  }
}
