import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song.dart';
import '../services/playlist_api_service.dart';

class Playlist {
  String id;
  String name;
  List<Song> songs;

  Playlist({required this.id, required this.name, required this.songs});

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'songs': songs.map((s) => s.toJson()).toList(),
  };

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
  static const String serverUrl = "http://10.0.2.2:3000";

  // Load dữ liệu khi mở app
  static Future<void> loadPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_key);
    if (data != null) {
      List<dynamic> jsonList = json.decode(data);
      _playlists = jsonList.map((item) => Playlist.fromJson(item)).toList();
    }
  }

  static List<Playlist> get playlists => _playlists;

  static Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    String data = json.encode(_playlists.map((p) => p.toJson()).toList());
    await prefs.setString(_key, data);
  }

  // Tạo playlist mới, trả về playlist mới luôn
  static Future<Playlist> createPlaylist(String name) async {
    final newPlaylist = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      songs: [],
    );

    _playlists.add(newPlaylist);
    await _save();

    // Đồng bộ server
    try {
      final serverData = await PlaylistApiService.createPlaylist(name);
      if (serverData != null) {
        newPlaylist.id = serverData["_id"];
        await _save();
      }
    } catch (_) {}

    return newPlaylist;
  }

  static Future<void> deletePlaylist(String id) async {
    _playlists.removeWhere((p) => p.id == id);
    await _save();
  }

  static Future<void> renamePlaylist(String id, String newName) async {
    final index = _playlists.indexWhere((p) => p.id == id);
    if (index != -1) {
      _playlists[index].name = newName;
      await _save();
    }
  }

  // Thêm bài hát, xử lý duplicate, trả về true nếu thêm thành công
  static Future<bool> addSongToPlaylist(String playlistId, Song song) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index == -1) return false;

    final exists = _playlists[index].songs.any((s) => s.id == song.id);
    if (exists) return false;

    _playlists[index].songs.add(song);
    await _save();

    // Đồng bộ server nhưng không block UI
    try {
      await http.patch(
        Uri.parse('$serverUrl/playlists/$playlistId/add-song'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'songId': song.id}),
      );
    } catch (e) {
      print('Sync add song error: $e');
    }

    return true;
  }

  static Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      _playlists[index].songs.removeWhere((s) => s.id == songId);
      await _save();
    }
  }
}
