// lib/services/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('is_dark_mode') ?? true;
    notifyListeners();
  }

  Future<void> toggleTheme(bool isOn) async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = isOn;
    await prefs.setBool('is_dark_mode', isOn);
    notifyListeners();
  }

  // --- BỘ MÀU SẮC CHUẨN (LIGHT/DARK) ---

  // 1. Màu nền (Background Gradient)
  List<Color> get backgroundColors => _isDarkMode
      ? [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)] // Dark: Xanh đen huyền bí
      : [Color(0xFFF0F2F5), Color(0xFFE1E5EA), Color(0xFFD7DEE4)]; // Light: Xám khói sang trọng (không bị chói)

  // 2. Màu chữ chính (Tiêu đề)
  Color get textPrimary => _isDarkMode ? Colors.white : Color(0xFF1A1A1A); // Dark: Trắng | Light: Đen gần như tuyệt đối

  // 3. Màu chữ phụ (Subtitle)
  Color get textSecondary => _isDarkMode ? Colors.white60 : Color(0xFF666666); // Dark: Xám nhạt | Light: Xám đậm

  // 4. Màu nền các thẻ (Card/Item)
  Color get cardColor => _isDarkMode
      ? Colors.white.withOpacity(0.08) // Dark: Trong suốt nhẹ
      : Colors.white; // Light: Trắng nổi bật (để tạo bóng)

  // 5. Màu Icon
  Color get iconColor => _isDarkMode ? Colors.white70 : Color(0xFF444444);

  // 6. Shadow (Đổ bóng cho Light Mode đẹp hơn)
  List<BoxShadow> get cardShadow => _isDarkMode
      ? [] // Dark mode không cần bóng
      : [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))]; // Light mode có bóng nhẹ
}