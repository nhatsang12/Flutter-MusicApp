// lib/services/playlist_manager.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song.dart';

class Playlist {
  String id;
  String name;
  List<Song> songs;

  Playlist({required this.id, required this.name, required this.songs});

  // Chuyển đổi sang JSON để lưu
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'songs': songs.map((s) => s.toJson()).toList(),
  };

  // Tạo từ JSON khi load lên
  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'],
      name: json['name'],
      songs: (json['songs'] as List).map((s) => Song.fromJson(s)).toList(),
    );
  }
}

class PlaylistManager {
  static List<Playlist> _playlists = [];
  static const String _key = 'user_playlists';

  // 1. Load dữ liệu khi mở app
  static Future<void> loadPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_key);
    if (data != null) {
      List<dynamic> jsonList = json.decode(data);
      _playlists = jsonList.map((item) => Playlist.fromJson(item)).toList();
    }
  }

  // Lấy danh sách playlist
  static List<Playlist> get playlists => _playlists;

  // 2. Lưu lại thay đổi
  static Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    String data = json.encode(_playlists.map((p) => p.toJson()).toList());
    await prefs.setString(_key, data);
  }

  // 3. Tạo Playlist mới
  static Future<void> createPlaylist(String name) async {
    final newPlaylist = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      songs: [],
    );
    _playlists.add(newPlaylist);
    await _save();
  }

  // 4. Xóa Playlist
  static Future<void> deletePlaylist(String id) async {
    _playlists.removeWhere((p) => p.id == id);
    await _save();
  }

  // 5. Đổi tên Playlist
  static Future<void> renamePlaylist(String id, String newName) async {
    final index = _playlists.indexWhere((p) => p.id == id);
    if (index != -1) {
      _playlists[index].name = newName;
      await _save();
    }
  }

  // 6. Thêm bài hát vào Playlist
  static Future<bool> addSongToPlaylist(String playlistId, Song song) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      // Kiểm tra xem bài hát đã có chưa
      bool exists = _playlists[index].songs.any((s) => s.id == song.id);
      if (exists) return false; // Đã tồn tại

      _playlists[index].songs.add(song);
      await _save();
      return true;
    }
    return false;
  }

  // 7. Xóa bài hát khỏi Playlist
  static Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      _playlists[index].songs.removeWhere((s) => s.id == songId);
      await _save();
    }
  }
}