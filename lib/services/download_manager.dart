// lib/services/download_manager.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song.dart';

class DownloadManager {
  static const String _key = 'downloaded_songs';

  // Lấy danh sách bài hát đã tải
  static Future<List<Song>> getDownloadedSongs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_key);
    if (data == null) return [];

    final List<dynamic> jsonList = json.decode(data);
    return jsonList.map((json) => Song.fromJson(json)).toList();
  }

  // Lưu bài hát vào danh sách đã tải
  static Future<void> addSong(Song song, String localPath) async {
    final prefs = await SharedPreferences.getInstance();
    List<Song> songs = await getDownloadedSongs();

    // Kiểm tra xem đã tồn tại chưa
    if (!songs.any((s) => s.id == song.id)) {
      // Tạo một bản sao của bài hát nhưng thay URL mạng bằng đường dẫn trong máy
      Song localSong = Song(
        id: song.id,
        title: song.title,
        artist: song.artist,
        album: song.album,
        coverUrl: song.coverUrl, // Vẫn dùng link ảnh mạng (hoặc bạn có thể tải ảnh về nếu muốn)
        url: localPath, // <--- QUAN TRỌNG: Lưu đường dẫn file trong máy
        duration: song.duration,
      );

      songs.add(localSong);
      await prefs.setString(_key, json.encode(songs.map((s) => s.toJson()).toList()));
    }
  }

  // Xóa bài hát khỏi danh sách
  static Future<void> removeSong(String songId) async {
    final prefs = await SharedPreferences.getInstance();
    List<Song> songs = await getDownloadedSongs();

    songs.removeWhere((s) => s.id == songId);

    await prefs.setString(_key, json.encode(songs.map((s) => s.toJson()).toList()));
  }
}