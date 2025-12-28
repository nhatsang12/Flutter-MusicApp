// lib/models/user.dart
class User {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final DateTime createdAt;

  // --- THÊM 2 TRƯỜNG MỚI ĐỂ LƯU THỐNG KÊ ---
  final int songsPlayed;       // Số bài hát đã nghe
  final int totalListenTime;   // Tổng thời gian nghe (giây)

  User({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    required this.createdAt,
    // Giá trị mặc định là 0 nếu tạo user mới
    this.songsPlayed = 0,
    this.totalListenTime = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      // Nếu dữ liệu cũ chưa có trường này thì lấy mặc định là 0
      songsPlayed: json['songsPlayed'] ?? 0,
      totalListenTime: json['totalListenTime'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
      // Lưu thêm 2 trường thống kê vào JSON
      'songsPlayed': songsPlayed,
      'totalListenTime': totalListenTime,
    };
  }
}