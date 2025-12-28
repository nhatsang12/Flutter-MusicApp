// lib/services/language_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  Locale _currentLocale = Locale('vi'); // Mặc định Tiếng Việt

  Locale get currentLocale => _currentLocale;

  // 1. Load ngôn ngữ đã lưu khi mở app
  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedCode = prefs.getString('language_code');
    if (savedCode != null) {
      _currentLocale = Locale(savedCode);
      notifyListeners();
    }
  }

  // 2. Đổi ngôn ngữ và Lưu lại
  Future<void> changeLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', code);
    _currentLocale = Locale(code);
    notifyListeners(); // Báo cho toàn bộ App vẽ lại
  }

  // 3. Lấy chữ theo key
  String getText(String key) {
    String langCode = _currentLocale.languageCode;
    return _localizedValues[langCode]?[key] ?? key;
  }

  // --- TỪ ĐIỂN ĐẦY ĐỦ CHO TOÀN BỘ APP ---
  static final Map<String, Map<String, String>> _localizedValues = {
    'vi': {
      // Common / General
      'app_name': 'Music Player',
      'close': 'Đóng',
      'cancel': 'Hủy',
      'confirm': 'Xác nhận',
      'save': 'Lưu',
      'create': 'Tạo',
      'delete': 'Xóa',
      'edit': 'Chỉnh sửa',
      'loading': 'Đang tải...',
      'success': 'Thành công',
      'error': 'Lỗi',
      'feature_dev': 'Tính năng đang phát triển',
      'on': 'Đang bật',
      'off': 'Đang tắt',

      // Auth (Login & Register)
      'login_title': 'Đăng nhập',
      'register_title': 'Tạo Tài Khoản',
      'register_subtitle': 'Bắt đầu hành trình âm nhạc',
      'login_subtitle': 'Âm nhạc là cuộc sống',
      'full_name': 'Họ và tên',
      'enter_name': 'Vui lòng nhập họ tên',
      'email': 'Email',
      'enter_email': 'Vui lòng nhập email',
      'email_invalid': 'Email không hợp lệ',
      'password': 'Mật khẩu',
      'enter_password': 'Vui lòng nhập mật khẩu',
      'password_min': 'Mật khẩu phải có ít nhất 6 ký tự',
      'confirm_password': 'Xác nhận mật khẩu',
      'password_mismatch': 'Mật khẩu không khớp',
      'register_btn': 'Đăng ký',
      'login_btn': 'Đăng nhập',
      'have_account': 'Đã có tài khoản? ',
      'login_now': 'Đăng nhập ngay',
      'forgot_pass': 'Quên mật khẩu?',
      'or': 'HOẶC',
      'create_new_account': 'Tạo tài khoản mới',
      'email_taken': 'Email đã được sử dụng',
      'login_failed': 'Email hoặc mật khẩu không đúng',

      // Home Page
      'search_hint': 'Nhập tên bài hát...',
      'search_empty': 'Không tìm thấy bài hát nào',
      'search_error': 'Lỗi tìm kiếm',
      'load_error': 'Lỗi tải nhạc',
      'no_result': 'Không tìm thấy kết quả nào',
      'link_broken': 'Lỗi: Link bài hát bị hỏng',

      // Library Page
      'library_title': 'Thư viện',
      'refresh': 'Làm mới',
      'tab_songs': 'Bài hát',
      'tab_playlist': 'Playlist',
      'search_library': 'Tìm kiếm bài hát, ca sĩ...',
      'stats_songs': 'Bài hát',
      'stats_artists': 'Ca sĩ',
      'stats_albums': 'Album',
      'playlist_empty': 'Chưa có playlist nào',
      'create_now': 'Tạo ngay',
      'create_playlist_title': 'Tạo Playlist mới',
      'enter_playlist_name': 'Nhập tên playlist...',

      // Playlist Detail
      'rename_playlist': 'Đổi tên Playlist',
      'shuffle_play': 'PHÁT NGẪU NHIÊN',
      'download': 'Tải xuống',
      'add_songs': 'Thêm bài',
      'downloading': 'Đang tải...',
      'playing_shuffle': '🔀 Đang phát ngẫu nhiên...',
      'created_by': 'Tạo bởi',
      'empty_list': 'Playlist trống',
      'deleted_song': 'Đã xóa',
      'premium_banner': 'Miễn phí 7 ngày nghe và tải toàn bộ kho nhạc Premium',

      // Favorites Page
      'favorites_title': 'Yêu thích',
      'delete_all': 'Xóa tất cả',
      'delete_all_confirm': 'Bạn có chắc muốn xóa tất cả bài hát yêu thích?',
      'empty_favorites': 'Chưa có bài hát yêu thích',
      'add_favorite_hint': 'Nhấn icon ♥ để thêm bài hát',
      'removed_favorite': 'Đã xóa khỏi yêu thích',
      'deleted_all_favorites': 'Đã xóa tất cả yêu thích',

      // Profile Page
      'settings': 'CÀI ĐẶT',
      'personal_info': 'Thông tin cá nhân',
      'update_profile': 'Cập nhật hồ sơ',
      'change_pass': 'Đổi mật khẩu',
      'current_pass': 'Mật khẩu hiện tại',
      'new_pass': 'Mật khẩu mới',
      're_new_pass': 'Nhập lại mật khẩu mới',
      'notifications': 'Thông báo',
      'language': 'Ngôn ngữ',
      'dark_mode': 'Giao diện tối',
      'others': 'KHÁC',
      'help': 'Trợ giúp & Hỗ trợ',
      'about': 'Về ứng dụng',
      'logout': 'Đăng xuất',
      'logout_confirm': 'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản không? Nhạc đang phát sẽ bị dừng.',
      'update_success': 'Hồ sơ đã được cập nhật thành công!',
      'pass_success': 'Đổi mật khẩu thành công! Vui lòng đăng nhập lại.',
      'pass_wrong': 'Mật khẩu cũ không đúng!',
      'pick_img_success': 'Đã cập nhật ảnh đại diện!',
      'pick_img_error': 'Lỗi chọn ảnh',
      'played': 'Đã nghe',
      'time': 'Thời gian',
      'version': 'Phiên bản 1.0.0 (Pro)',
      'about_desc': 'Ứng dụng nghe nhạc đỉnh cao với giao diện hiện đại.\nMade with ❤️ by Flutter.',

      // Action Menu (AddPlaylistSheet / BottomSheet)
      'add_to_fav': 'Thêm vào yêu thích',
      'add_to_playlist': 'Thêm vào playlist',
      'share': 'Chia sẻ',
      'share_content': 'Chia sẻ',
    },
    'en': {
      // Common / General
      'app_name': 'Music Player',
      'close': 'Close',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'save': 'Save',
      'create': 'Create',
      'delete': 'Delete',
      'edit': 'Edit',
      'loading': 'Loading...',
      'success': 'Success',
      'error': 'Error',
      'feature_dev': 'Feature under development',
      'on': 'On',
      'off': 'Off',

      // Auth
      'login_title': 'Login',
      'register_title': 'Create Account',
      'register_subtitle': 'Start your musical journey',
      'login_subtitle': 'Music is life',
      'full_name': 'Full Name',
      'enter_name': 'Please enter your name',
      'email': 'Email',
      'enter_email': 'Please enter your email',
      'email_invalid': 'Invalid email address',
      'password': 'Password',
      'enter_password': 'Please enter password',
      'password_min': 'Password must be at least 6 chars',
      'confirm_password': 'Confirm Password',
      'password_mismatch': 'Passwords do not match',
      'register_btn': 'Register',
      'login_btn': 'Login',
      'have_account': 'Already have an account? ',
      'login_now': 'Login now',
      'forgot_pass': 'Forgot password?',
      'or': 'OR',
      'create_new_account': 'Create new account',
      'email_taken': 'Email already in use',
      'login_failed': 'Incorrect email or password',

      // Home Page
      'search_hint': 'Enter song name...',
      'search_empty': 'No songs found',
      'search_error': 'Search error',
      'load_error': 'Load error',
      'no_result': 'No results found',
      'link_broken': 'Error: Broken song link',

      // Library Page
      'library_title': 'Library',
      'refresh': 'Refresh',
      'tab_songs': 'Songs',
      'tab_playlist': 'Playlist',
      'search_library': 'Search songs, artists...',
      'stats_songs': 'Songs',
      'stats_artists': 'Artists',
      'stats_albums': 'Albums',
      'playlist_empty': 'No playlists yet',
      'create_now': 'Create Now',
      'create_playlist_title': 'Create New Playlist',
      'enter_playlist_name': 'Enter playlist name...',

      // Playlist Detail
      'rename_playlist': 'Rename Playlist',
      'shuffle_play': 'SHUFFLE PLAY',
      'download': 'Download',
      'add_songs': 'Add Songs',
      'downloading': 'Downloading...',
      'playing_shuffle': '🔀 Shuffling playlist...',
      'created_by': 'Created by',
      'empty_list': 'Empty playlist',
      'deleted_song': 'Deleted',
      'premium_banner': 'Free 7 days trial for Premium',

      // Favorites Page
      'favorites_title': 'Favorites',
      'delete_all': 'Delete All',
      'delete_all_confirm': 'Are you sure you want to delete all favorites?',
      'empty_favorites': 'No favorite songs',
      'add_favorite_hint': 'Tap ♥ to add songs',
      'removed_favorite': 'Removed from favorites',
      'deleted_all_favorites': 'All favorites deleted',

      // Profile Page
      'settings': 'SETTINGS',
      'personal_info': 'Personal Info',
      'update_profile': 'Update Profile',
      'change_pass': 'Change Password',
      'current_pass': 'Current Password',
      'new_pass': 'New Password',
      're_new_pass': 'Confirm New Password',
      'notifications': 'Notifications',
      'language': 'Language',
      'dark_mode': 'Dark Mode',
      'others': 'OTHERS',
      'help': 'Help & Support',
      'about': 'About App',
      'logout': 'Logout',
      'logout_confirm': 'Are you sure you want to logout? Music will stop.',
      'update_success': 'Profile updated successfully!',
      'pass_success': 'Password changed! Please login again.',
      'pass_wrong': 'Incorrect old password!',
      'pick_img_success': 'Profile picture updated!',
      'pick_img_error': 'Image selection error',
      'played': 'Played',
      'time': 'Time',
      'version': 'Version 1.0.0 (Pro)',
      'about_desc': 'Premium music player with modern interface.\nMade with ❤️ by Flutter.',

      // Action Menu
      'add_to_fav': 'Add to Favorites',
      'add_to_playlist': 'Add to Playlist',
      'share': 'Share',
      'share_content': 'Share',
    }
  };
}