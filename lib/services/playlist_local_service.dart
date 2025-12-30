import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/services/playlist_manager.dart';
// import '../models/playlist.dart';
import '../models/song.dart';

class PlaylistLocalService {
  static const String _key = 'user_playlists';

  // Lưu tất cả playlists
  static Future<void> savePlaylists(List<Playlist> playlists) async {
    final prefs = await SharedPreferences.getInstance();
    String data = json.encode(playlists.map((p) => p.toJson()).toList());
    await prefs.setString(_key, data);
  }

  // Load tất cả playlists
  static Future<List<Playlist>> loadPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_key);

    if (data != null) {
      List<dynamic> jsonList = json.decode(data);
      return jsonList.map((item) => Playlist.fromJson(item)).toList();
    }
    return [];
  }

  // Xóa tất cả dữ liệu local (khi logout)
  static Future<void> clearLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  // Lưu một playlist cụ thể
  static Future<void> savePlaylist(Playlist playlist) async {
    List<Playlist> playlists = await loadPlaylists();
    int index = playlists.indexWhere((p) => p.id == playlist.id);

    if (index != -1) {
      playlists[index] = playlist;
    } else {
      playlists.add(playlist);
    }

    await savePlaylists(playlists);
  }

  // Xóa một playlist
  static Future<void> deletePlaylist(String playlistId) async {
    List<Playlist> playlists = await loadPlaylists();
    playlists.removeWhere((p) => p.id == playlistId);
    await savePlaylists(playlists);
  }
}