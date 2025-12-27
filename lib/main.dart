// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/language_provider.dart';
import 'services/auth_service.dart';
import 'services/theme_provider.dart'; // Import ThemeProvider
import 'screens/music_home_page.dart';
import 'screens/register_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.loadCurrentUser();

  final languageProvider = LanguageProvider();
  await languageProvider.loadLanguage();

  // Load Theme
  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => languageProvider),
        ChangeNotifierProvider(create: (_) => themeProvider), // Thêm Theme vào đây
      ],
      child: MusicPlayerApp(),
    ),
  );
}

class MusicPlayerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Dùng Consumer để App tự vẽ lại khi Theme thay đổi
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Music Player',
          debugShowCheckedModeBanner: false,

          // CẤU HÌNH THEME ĐỘNG
          theme: ThemeData(
            primarySwatch: Colors.purple,
            // Độ sáng (Sáng/Tối) dựa vào Provider
            brightness: themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
            // Màu nền Scaffold
            scaffoldBackgroundColor: themeProvider.isDarkMode ? Color(0xFF121212) : Color(0xFFF5F5F5),

            appBarTheme: AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              // Màu icon và chữ trên AppBar cũng đổi theo
              iconTheme: IconThemeData(color: themeProvider.isDarkMode ? Colors.white : Colors.black),
              titleTextStyle: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold
              ),
            ),
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),

          home: AuthService.isLoggedIn() ? MusicHomePage() : RegisterPage(),
        );
      },
    );
  }
}