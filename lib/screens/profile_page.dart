// lib/screens/profile_page.dart
import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/auth_service.dart';
import '../services/favorites_manager.dart';
import 'login_page.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/language_provider.dart';
import '../services/theme_provider.dart'; // <--- IMPORT THEME

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _userName = '';
  String _userEmail = '';
  String? _avatarPath;
  int _favoriteCount = 0;
  int _totalListenTime = 0;
  int _songsPlayed = 0;
  bool _isNotificationEnabled = true;
  // ĐÃ XÓA biến _isDarkModeEnabled ở đây vì ta sẽ dùng từ Provider

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = AuthService.getCurrentUser();
    setState(() {
      _userName = user?.name ?? 'Music Lover';
      _userEmail = user?.email ?? 'user@example.com';
      _avatarPath = user?.avatarUrl;
      _favoriteCount = FavoritesManager.getFavorites().length;
      _totalListenTime = user?.totalListenTime ?? 0;
      _songsPlayed = user?.songsPlayed ?? 0;
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() { _avatarPath = image.path; });
        await AuthService.updateProfile(_userName, image.path);
        _showCustomSnackBar('Đã cập nhật ảnh đại diện!', isSuccess: true);
      }
    } catch (e) {
      _showCustomSnackBar('Lỗi chọn ảnh: $e', isSuccess: false);
    }
  }

  String _formatListenTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    return '${hours}h ${minutes}m';
  }

  void _showLanguageDialog() {
    final lang = Provider.of<LanguageProvider>(context, listen: false);

    _showBeautifulDialog(
      title: lang.getText('language'),
      icon: Icons.language,
      confirmText: lang.getText('close') != 'close' ? lang.getText('close') : 'Đóng',
      onConfirm: () => Navigator.pop(context),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLanguageOption('Tiếng Việt', 'vi', '🇻🇳'),
          Divider(color: Colors.white24),
          _buildLanguageOption('English', 'en', '🇺🇸'),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String name, String code, String flag) {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    bool isSelected = lang.currentLocale.languageCode == code;

    return ListTile(
      leading: Text(flag, style: TextStyle(fontSize: 24)),
      title: Text(name, style: TextStyle(color: isSelected ? Colors.purpleAccent : Colors.white, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      trailing: isSelected ? Icon(Icons.check, color: Colors.purpleAccent) : null,
      onTap: () {
        lang.changeLanguage(code);
        Navigator.pop(context);
      },
    );
  }

  Future<void> _showBeautifulDialog({required String title, required IconData icon, required Widget content, required String confirmText, required VoidCallback onConfirm}) {
    final theme = Provider.of<ThemeProvider>(context, listen: false); // Lấy theme để chỉnh màu dialog

    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) => Container(),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return Transform.scale(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack).value,
          child: Opacity(
            opacity: anim1.value,
            child: AlertDialog(
              backgroundColor: theme.cardColor, // Nền dialog đổi màu theo theme
              elevation: 20,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.white.withOpacity(0.1), width: 1)),
              titlePadding: EdgeInsets.zero,
              contentPadding: EdgeInsets.fromLTRB(24, 10, 24, 20),
              title: Container(padding: EdgeInsets.symmetric(vertical: 20), decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.vertical(top: Radius.circular(24))), child: Column(children: [Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Colors.purple.shade400, Colors.pink.shade400], begin: Alignment.topLeft, end: Alignment.bottomRight), boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.4), blurRadius: 10, spreadRadius: 2)]), child: Icon(icon, color: Colors.white, size: 32)), SizedBox(height: 12), Text(title, style: TextStyle(color: theme.textPrimary, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 0.5))])),
              content: content,
              actionsPadding: EdgeInsets.fromLTRB(20, 0, 20, 20),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), style: TextButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text('Hủy bỏ', style: TextStyle(color: theme.textSecondary, fontSize: 16))),
                SizedBox(width: 8),
                Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.purple.shade600, Colors.pink.shade600]), borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.3), blurRadius: 8, offset: Offset(0, 4))]), child: ElevatedButton(onPressed: onConfirm, style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: Text(confirmText, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)))),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernTextField({required TextEditingController controller, required String label, required IconData icon, bool isPassword = false}) {
    final theme = Provider.of<ThemeProvider>(context); // Lấy theme để chỉnh màu input
    bool _obscure = isPassword;
    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(color: theme.cardColor.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.08))),
          child: TextField(
            controller: controller,
            obscureText: _obscure,
            style: TextStyle(color: theme.textPrimary),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: theme.textSecondary),
              prefixIcon: Icon(icon, color: Colors.purple.shade200),
              suffixIcon: isPassword ? IconButton(icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: theme.textSecondary), onPressed: () { setState(() { _obscure = !_obscure; }); }) : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        );
      },
    );
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _userName);
    final emailController = TextEditingController(text: _userEmail);
    _showBeautifulDialog(title: 'Cập nhật hồ sơ', icon: Icons.edit_note_rounded, confirmText: 'Lưu thay đổi', content: Column(mainAxisSize: MainAxisSize.min, children: [SizedBox(height: 10), _buildModernTextField(controller: nameController, label: 'Tên hiển thị', icon: Icons.person_outline), _buildModernTextField(controller: emailController, label: 'Địa chỉ Email', icon: Icons.alternate_email)]), onConfirm: () { setState(() { _userName = nameController.text; _userEmail = emailController.text; }); AuthService.updateProfile(nameController.text, _avatarPath); Navigator.pop(context); _showCustomSnackBar('Hồ sơ đã được cập nhật thành công!', isSuccess: true); });
  }

  void _showChangePasswordDialog() {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    _showBeautifulDialog(title: 'Đổi mật khẩu', icon: Icons.lock_reset_rounded, confirmText: 'Xác nhận', content: Column(mainAxisSize: MainAxisSize.min, children: [SizedBox(height: 10), _buildModernTextField(controller: oldPassController, label: 'Mật khẩu hiện tại', icon: Icons.lock_outline, isPassword: true), Divider(color: Colors.white12, height: 24), _buildModernTextField(controller: newPassController, label: 'Mật khẩu mới', icon: Icons.vpn_key_outlined, isPassword: true), _buildModernTextField(controller: confirmPassController, label: 'Nhập lại mật khẩu mới', icon: Icons.check_circle_outline, isPassword: true)]), onConfirm: () async { if (newPassController.text != confirmPassController.text) { _showCustomSnackBar('Mật khẩu xác nhận không khớp!', isSuccess: false); return; } if (newPassController.text.length < 6) { _showCustomSnackBar('Mật khẩu mới quá ngắn!', isSuccess: false); return; } bool success = await AuthService.changePassword(oldPassController.text, newPassController.text); if (success) { Navigator.pop(context); _showCustomSnackBar('Đổi mật khẩu thành công! Vui lòng đăng nhập lại.', isSuccess: true); await Future.delayed(Duration(seconds: 2)); _logout(); } else { _showCustomSnackBar('Mật khẩu cũ không đúng!', isSuccess: false); } });
  }

  void _showCustomSnackBar(String message, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Row(children: [Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: Icon(isSuccess ? Icons.check : Icons.error_outline, color: Colors.white, size: 20)), SizedBox(width: 12), Expanded(child: Text(message, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)))]), backgroundColor: isSuccess ? Color(0xFF00BFA5) : Color(0xFFFF5252), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), margin: EdgeInsets.all(16), elevation: 6, duration: Duration(seconds: 3)));
  }

  Future<void> _logout() async {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    final theme = Provider.of<ThemeProvider>(context, listen: false);
    _showBeautifulDialog(title: lang.getText('logout'), icon: Icons.logout_rounded, confirmText: 'Đăng xuất ngay', content: Text(lang.getText('logout_confirm'), textAlign: TextAlign.center, style: TextStyle(color: theme.textSecondary, fontSize: 15, height: 1.5)), onConfirm: () async { Navigator.pop(context); await AuthService.logout(); Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage()), (route) => false); });
  }

  @override
  Widget build(BuildContext context) {
    // --- KẾT NỐI PROVIDER ---
    final lang = Provider.of<LanguageProvider>(context);
    final theme = Provider.of<ThemeProvider>(context); // Lấy theme
    // -----------------------

    return Scaffold(
      body: Container(
        // Đổi màu nền theo theme
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: theme.backgroundColors)),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20),
                _buildProfileHeader(lang, theme),
                SizedBox(height: 32),
                _buildStatsSection(lang, theme),
                SizedBox(height: 24),
                _buildMenuSection(lang, theme),
                SizedBox(height: 24),
                _buildLogoutButton(lang),
                SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(LanguageProvider lang, ThemeProvider theme) {
    return Column(
      children: [
        Center(child: Stack(children: [Container(padding: EdgeInsets.all(4), decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Colors.purple.shade400, Colors.pink.shade400])), child: CircleAvatar(radius: 60, backgroundColor: Color(0xFF1E1E1E), backgroundImage: _avatarPath != null ? (_avatarPath!.startsWith('http') ? NetworkImage(_avatarPath!) : FileImage(File(_avatarPath!)) as ImageProvider) : null, child: _avatarPath == null ? Text(_userName.isNotEmpty ? _userName[0].toUpperCase() : 'M', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)) : null)), Positioned(bottom: 0, right: 0, child: GestureDetector(onTap: _pickImage, child: Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))]), child: Icon(Icons.camera_alt, color: Colors.purple.shade700, size: 20))))])),
        SizedBox(height: 16),
        // Đổi màu chữ theo theme
        Text(_userName, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.textPrimary, letterSpacing: 0.5)),
        SizedBox(height: 4),
        Text(_userEmail, style: TextStyle(fontSize: 15, color: theme.textSecondary)),
        SizedBox(height: 12),
        GestureDetector(
          onTap: _showEditProfileDialog,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.purple.shade600, Colors.pink.shade600]), borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.edit, size: 16, color: Colors.white), SizedBox(width: 6), Text(lang.getText('edit'), style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))]),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(LanguageProvider lang, ThemeProvider theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(child: _buildStatCard(icon: Icons.favorite, label: lang.getText('favorites'), value: '$_favoriteCount', color: Colors.red.shade400, theme: theme)),
          SizedBox(width: 12),
          Expanded(child: _buildStatCard(icon: Icons.music_note, label: lang.getText('played'), value: '$_songsPlayed', color: Colors.blue.shade400, theme: theme)),
          SizedBox(width: 12),
          Expanded(child: _buildStatCard(icon: Icons.access_time, label: lang.getText('time'), value: _formatListenTime(_totalListenTime), color: Colors.green.shade400, theme: theme)),
        ],
      ),
    );
  }

  Widget _buildStatCard({required IconData icon, required String label, required String value, required Color color, required ThemeProvider theme}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: theme.isDarkMode ? Colors.white10 : Colors.black12)),
      child: Column(children: [Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)), SizedBox(height: 12), Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textPrimary)), SizedBox(height: 4), Text(label, style: TextStyle(fontSize: 12, color: theme.textSecondary))]),
    );
  }

  Widget _buildMenuSection(LanguageProvider lang, ThemeProvider theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(lang.getText('settings'), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.textSecondary, letterSpacing: 1.2)),
          SizedBox(height: 12),
          _buildMenuItem(icon: Icons.person_outline, title: lang.getText('personal_info'), subtitle: 'Cập nhật tên, email', onTap: _showEditProfileDialog, theme: theme),
          _buildMenuItem(icon: Icons.lock_outline, title: lang.getText('change_pass'), subtitle: 'Thay đổi mật khẩu bảo mật', onTap: _showChangePasswordDialog, theme: theme),
          _buildMenuItem(icon: Icons.notifications_none, title: lang.getText('notifications'), subtitle: 'Quản lý thông báo', theme: theme, trailing: Switch(value: _isNotificationEnabled, onChanged: (value) { setState(() => _isNotificationEnabled = value); _showCustomSnackBar(value ? 'Đã bật thông báo' : 'Đã tắt thông báo', isSuccess: true); }, activeColor: Colors.purple.shade400)),
          _buildMenuItem(icon: Icons.language, title: lang.getText('language'), subtitle: lang.currentLocale.languageCode == 'vi' ? 'Tiếng Việt' : 'English', onTap: _showLanguageDialog, theme: theme),

          // --- SỬA LOGIC NÚT GIAO DIỆN TỐI ---
          _buildMenuItem(
              icon: Icons.dark_mode,
              title: lang.getText('dark_mode'),
              subtitle: theme.isDarkMode ? lang.getText('on') : lang.getText('off'),
              theme: theme,
              trailing: Switch(
                  value: theme.isDarkMode, // Lấy giá trị từ Provider
                  onChanged: (value) {
                    // Gọi hàm toggleTheme của Provider để đổi màu toàn app
                    theme.toggleTheme(value);
                  },
                  activeColor: Colors.purple.shade400
              )
          ),
          // ----------------------------------

          SizedBox(height: 20),
          Text(lang.getText('others'), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.textSecondary, letterSpacing: 1.2)),
          SizedBox(height: 12),
          _buildMenuItem(icon: Icons.help_outline, title: lang.getText('help'), subtitle: 'FAQ, liên hệ hỗ trợ', onTap: () => _showCustomSnackBar('Đang kết nối nhân viên hỗ trợ...', isSuccess: true), theme: theme),
          _buildMenuItem(icon: Icons.info_outline, title: lang.getText('about'), subtitle: 'Phiên bản 1.0.0', onTap: _showAboutDialog, theme: theme),
        ],
      ),
    );
  }

  Widget _buildMenuItem({required IconData icon, required String title, required String subtitle, VoidCallback? onTap, Widget? trailing, required ThemeProvider theme}) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: theme.isDarkMode ? Colors.white10 : Colors.black12)),
      child: ListTile(
        leading: Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.purple.withOpacity(0.2), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: Colors.purple.shade300, size: 24)),
        title: Text(title, style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: Text(subtitle, style: TextStyle(color: theme.textSecondary, fontSize: 13)),
        trailing: trailing ?? Icon(Icons.arrow_forward_ios, color: theme.textSecondary, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutButton(LanguageProvider lang) {
    return Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: Container(width: double.infinity, height: 56, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.red.shade600, Colors.red.shade800]), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 20, offset: Offset(0, 8))]), child: ElevatedButton(onPressed: _logout, style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.logout, color: Colors.white), SizedBox(width: 12), Text(lang.getText('logout'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5))]))));
  }

  void _showAboutDialog() {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    final theme = Provider.of<ThemeProvider>(context, listen: false);
    _showBeautifulDialog(title: 'Music Player', icon: Icons.music_note_rounded, confirmText: lang.getText('close') != 'close' ? lang.getText('close') : 'Đóng', content: Column(mainAxisSize: MainAxisSize.min, children: [Text('Phiên bản 1.0.0 (Pro)', style: TextStyle(color: theme.textSecondary)), SizedBox(height: 16), Text('Ứng dụng nghe nhạc đỉnh cao với giao diện hiện đại.\nMade with ❤️ by Flutter.', style: TextStyle(color: theme.textSecondary, fontSize: 14, height: 1.5), textAlign: TextAlign.center)]), onConfirm: () => Navigator.pop(context));
  }
}