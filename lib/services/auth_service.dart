// lib/services/auth_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String _userKey = 'current_user';
  static const String _usersKey = 'registered_users';
  static User? _currentUser;

  // Load current user
  static Future<void> loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString(_userKey);

    if (userJson != null) {
      _currentUser = User.fromJson(json.decode(userJson));
    }
  }

  // Get current user
  static User? getCurrentUser() {
    return _currentUser;
  }

  // Check if logged in
  static bool isLoggedIn() {
    return _currentUser != null;
  }

  // Register new user
  static Future<bool> register(String email, String password, String name) async {
    final prefs = await SharedPreferences.getInstance();

    // Get existing users
    final String? usersJson = prefs.getString(_usersKey);
    Map<String, dynamic> users = usersJson != null ? json.decode(usersJson) : {};

    // Check if email already exists
    if (users.containsKey(email)) {
      return false; // Email already registered
    }

    // Create new user
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      name: name,
      createdAt: DateTime.now(),
    );

    // Save user with password
    users[email] = {
      'password': password,
      'user': user.toJson(),
    };

    await prefs.setString(_usersKey, json.encode(users));

    // Auto login after registration
    _currentUser = user;
    await prefs.setString(_userKey, json.encode(user.toJson()));

    return true;
  }

  // Login
  static Future<bool> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final String? usersJson = prefs.getString(_usersKey);

    if (usersJson == null) return false;

    Map<String, dynamic> users = json.decode(usersJson);

    if (!users.containsKey(email)) {
      return false; // Email not found
    }

    final userData = users[email];
    if (userData['password'] != password) {
      return false; // Wrong password
    }

    // Login successful
    _currentUser = User.fromJson(userData['user']);
    await prefs.setString(_userKey, json.encode(_currentUser!.toJson()));

    return true;
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    _currentUser = null;
  }

  // Update user profile
  static Future<void> updateProfile(String name, String? avatarUrl) async {
    if (_currentUser == null) return;

    final updatedUser = User(
      id: _currentUser!.id,
      email: _currentUser!.email,
      name: name,
      avatarUrl: avatarUrl,
      createdAt: _currentUser!.createdAt,
    );

    _currentUser = updatedUser;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(updatedUser.toJson()));

    // Update in users list
    final String? usersJson = prefs.getString(_usersKey);
    if (usersJson != null) {
      Map<String, dynamic> users = json.decode(usersJson);
      if (users.containsKey(_currentUser!.email)) {
        users[_currentUser!.email]['user'] = updatedUser.toJson();
        await prefs.setString(_usersKey, json.encode(users));
      }
    }
  }
}