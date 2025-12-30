import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/song.dart';
import '../services/playlist_api_service.dart';

class Playlist {
  String id;
  String name;
  List<Song> songs;

  Playlist({
    required this.id,
    required this.name,
    required this.songs,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'songs': songs.map((s) => s.toJson()).toList(),
  };

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as String,
      name: json['name'] as String,
      songs: (json['songs'] as List<dynamic>)
          .map((e) => Song.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PlaylistManager {
  static final List<Playlist> _playlists = [];

  static const String _key = 'user_playlists';
  static const String serverUrl = 'http://10.0.2.2:3000/api/playlists';

  /// =========================
  /// LOAD LOCAL DATA
  /// =========================
  static Future<void> loadPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);

    if (data == null) return;

    final List<dynamic> jsonList = json.decode(data);
    _playlists
      ..clear()
      ..addAll(jsonList.map(
            (e) => Playlist.fromJson(e as Map<String, dynamic>),
      ));
  }

  static List<Playlist> get playlists => _playlists;

  static Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      json.encode(_playlists.map((e) => e.toJson()).toList()),
    );
  }

  /// =========================
  /// CREATE PLAYLIST
  /// =========================
  static Future<Playlist> createPlaylist(String name) async {
    // 1. Tạo playlist local
    final playlist = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // id tạm
      name: name,
      songs: [],
    );

    _playlists.add(playlist);
    await _save();

    // 2. Đồng bộ server
    try {
      final serverData = await PlaylistApiService.createPlaylist(name);
      if (serverData != null && serverData['_id'] != null) {
        // Update playlist local với server id
        playlist.id = serverData['_id'];

        // Save lại local với id chính xác
        await _save();
      }
    } catch (e) {
      print('Create playlist sync error: $e');
    }

    return playlist;
  }



  /// =========================
  /// UPDATE
  /// =========================
  static Future<void> renamePlaylist(String id, String newName) async {
    final playlist = _playlists.firstWhere(
          (p) => p.id == id,
      orElse: () => throw Exception('Playlist not found'),
    );

    playlist.name = newName;
    await _save();
  }

  static Future<void> deletePlaylist(String id) async {
    _playlists.removeWhere((p) => p.id == id);
    await _save();
  }

  /// =========================
  /// SONG HANDLING
  /// =========================
  static Future<bool> addSongToPlaylist(String playlistId, Song song) async {
    // 1. Lấy playlist chính xác (bằng server id)
    final playlist = _playlists.firstWhere(
          (p) => p.id == playlistId,
      orElse: () => throw Exception('Playlist not found'),
    );

    // 2. Duplicate check dựa trên song.id
    if (playlist.songs.any((s) => s.id == song.id)) {
      return false; // bài hát đã tồn tại
    }

    // 3. Thêm bài hát local
    playlist.songs.add(song);
    await _save();

    // 4. Đồng bộ server
    try {
      await PlaylistApiService.addSong(playlistId, song);
    } catch (e) {
      print('Add song sync error: $e');
    }

    return true;
  }


  static Future<void> removeSongFromPlaylist(
      String playlistId, String songId) async {
    final playlist = _playlists.firstWhere(
          (p) => p.id == playlistId,
      orElse: () => throw Exception('Playlist not found'),
    );

    playlist.songs.removeWhere((s) => s.id == songId);
    await _save();
  }
}
