import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song.dart';
import 'favorites_service.dart';

class FavoritesManager {
  static const String _key = 'favorite_songs';
  static List<Song> _favorites = [];


  static Future<void> initFavorites() async {
    await loadFromLocal();   // hiển thị nhanh
    await loadFromServer();  // sync chính xác
  }

  // ==========================
  // Load favorites từ local + server
  // ==========================
  static Future<void> loadFromServer() async {
    try {
      final songs = await FavoritesService.fetchFavorites();
      _favorites = songs;
      await _saveToLocal();
    } catch (e) {
      print("Error loading favorites from server: $e");
    }
  }

  static Future<void> loadFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favoritesJson = prefs.getString(_key);

    if (favoritesJson != null) {
      final List<dynamic> decoded = json.decode(favoritesJson);
      _favorites = decoded.map((e) => Song.fromJson(e)).toList();
    }
  }

  // ==========================
  // Save favorites vào local
  // ==========================
  static Future<void> _saveToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> encoded =
    _favorites.map((song) => song.toJson()).toList();
    await prefs.setString(_key, json.encode(encoded));
  }

  // ==========================
  // Get / check favorites
  // ==========================
  static List<Song> getFavorites() => List.from(_favorites);

  static bool isFavorite(Song song) {
    return _favorites.any((s) => s.id == song.id);
  }

  static int getFavoritesCount() => _favorites.length;

  // ==========================
  // Add / Remove / Toggle favorite (server + local)
  // ==========================
  static Future<void> addFavorite(Song song) async {
    if (isFavorite(song)) return;

    try {
      _favorites.add(song);           // update local
      await _saveToLocal();
      await FavoritesService.addFavorite(song); // update server
    } catch (e) {
      print("Error adding favorite: $e");
    }
  }

  static Future<bool> removeFavorite(Song song) async {
    if (!isFavorite(song)) return false;

    final backup = List<Song>.from(_favorites);

    try {
      _favorites.removeWhere((s) => s.id == song.id);
      await _saveToLocal();
      await FavoritesService.removeFavorite(song.id);
      return true;
    } catch (e) {
      // rollback nếu server lỗi
      _favorites = backup;
      await _saveToLocal();
      print("Error removing favorite: $e");
      return false;
    }
  }

  static Future<void> toggleFavorite(Song song) async {
    if (isFavorite(song)) {
      await removeFavorite(song);
    } else {
      await addFavorite(song);
    }
  }

  // ==========================
  // Clear all favorites
  // ==========================
  static Future<void> clearFavorites() async {
    _favorites.clear();
    await _saveToLocal();
    // Server clear: có thể thêm API nếu cần
  }
}
