import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/song.dart';
import '../services/auth_service.dart';

class PlaylistApiService {
  // Android emulator: 10.0.2.2 trỏ tới localhost trên máy
  static const String baseUrl = "http://10.0.2.2:3000/api/playlists";

  // 1. Tạo playlist trên server
  static Future<Map<String, dynamic>?> createPlaylist(String name) async {
    final userId = AuthService.currentUserId;
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/create"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId,
          "name": name,
        }),
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        print('Create playlist failed: ${res.statusCode} ${res.body}');
        return null;
      }
    } catch (e) {
      print('Create playlist error: $e');
      return null;
    }
  }

  // 2. Lấy tất cả playlist của user từ server
  static Future<List<dynamic>> getUserPlaylists() async {
    final userId = AuthService.currentUserId;
    try {
      final res = await http.get(Uri.parse("$baseUrl/user/$userId"));

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        print('Get playlists failed: ${res.statusCode}');
        return [];
      }
    } catch (e) {
      print('Get playlists error: $e');
      return [];
    }
  }

  // 3. Thêm bài hát vào playlist
  static Future<bool> addSong(String playlistId, Song song) async {
    try {
      final res = await http.patch(
        Uri.parse("$baseUrl/$playlistId/add-song"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "songId": song.id,
          "title": song.title,
          "artist": song.artist,
          "url": song.url,
          "coverUrl": song.coverUrl,
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['success'] == true;
      } else {
        print('Add-song failed: ${res.statusCode} ${res.body}');
        return false;
      }
    } catch (e) {
      print('Add-song error: $e');
      return false;
    }
  }

  // 4. Xóa bài hát khỏi playlist
  static Future<bool> removeSong(String playlistId, String songId) async {
    try {
      final res = await http.patch(
        Uri.parse("$baseUrl/$playlistId/remove-song"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "songId": songId,
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['success'] == true;
      } else {
        print('Remove-song failed: ${res.statusCode} ${res.body}');
        return false;
      }
    } catch (e) {
      print('Remove-song error: $e');
      return false;
    }
  }
}
