// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';


class AuthService {
  static const String _userKey = 'current_user';
  static const String _usersKey = 'users';
  static User? _currentUser;

  // lib/services/auth_service.dart

  static String? get currentUserId => _currentUser?.id;


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


  // Thêm vào lib/services/auth_service.dart

  // Hàm cập nhật thống kê nghe nhạc
  static Future<void> addListeningStats(int seconds) async {
    if (_currentUser == null) return;

    // 1. Tạo user mới với thông số đã cộng thêm
    final updatedUser = User(
      id: _currentUser!.id,
      email: _currentUser!.email,
      name: _currentUser!.name,
      avatarUrl: _currentUser!.avatarUrl,
      createdAt: _currentUser!.createdAt,
      songsPlayed: _currentUser!.songsPlayed + 1, // Cộng thêm 1 bài
      totalListenTime: _currentUser!.totalListenTime + seconds, // Cộng thêm thời gian
    );

    // 2. Cập nhật vào biến cục bộ
    _currentUser = updatedUser;

    // 3. Lưu vào SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    // Lưu user hiện tại
    await prefs.setString(_userKey, json.encode(updatedUser.toJson()));

    // Lưu vào danh sách tổng (để không bị mất khi logout)
    final String? usersJson = prefs.getString(_usersKey);
    if (usersJson != null) {
      Map<String, dynamic> users = json.decode(usersJson);
      if (users.containsKey(updatedUser.email)) {
        users[updatedUser.email]['user'] = updatedUser.toJson();
        await prefs.setString(_usersKey, json.encode(users));
      }
    }
  }

  // --- MỚI THÊM: ĐỔI MẬT KHẨU ---
  static Future<bool> changePassword(String currentPassword, String newPassword) async {
    // 1. Kiểm tra user có đăng nhập không
    if (_currentUser == null) return false;

    final prefs = await SharedPreferences.getInstance();
    final String? usersJson = prefs.getString(_usersKey);

    // 2. Lấy danh sách user từ bộ nhớ
    if (usersJson == null) return false;
    Map<String, dynamic> users = json.decode(usersJson);
    final email = _currentUser!.email;

    // 3. Kiểm tra user có tồn tại trong dữ liệu gốc không
    if (!users.containsKey(email)) return false;

    // 4. Kiểm tra mật khẩu cũ
    if (users[email]['password'] != currentPassword) {
      return false; // Mật khẩu cũ sai
    }

    // 5. Cập nhật mật khẩu mới
    users[email]['password'] = newPassword;

    // 6. Lưu lại vào SharedPreferences
    await prefs.setString(_usersKey, json.encode(users));

    return true; // Thành công
  }
}

