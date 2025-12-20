// lib/services/favorites_manager.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song.dart';

class FavoritesManager {
  static const String _key = 'favorite_songs';
  static List<Song> _favorites = [];

  // Load favorites from storage
  static Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favoritesJson = prefs.getString(_key);

    if (favoritesJson != null) {
      final List<dynamic> decoded = json.decode(favoritesJson);
      _favorites = decoded.map((e) => Song.fromJson(e)).toList();
    }
  }

  // Save favorites to storage
  static Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> encoded =
    _favorites.map((song) => song.toJson()).toList();
    await prefs.setString(_key, json.encode(encoded));
  }

  // Get all favorites
  static List<Song> getFavorites() {
    return List.from(_favorites);
  }

  // Check if song is favorite
  static bool isFavorite(Song song) {
    return _favorites.any((s) => s.id == song.id);
  }

  // Toggle favorite status
  static Future<void> toggleFavorite(Song song) async {
    if (isFavorite(song)) {
      _favorites.removeWhere((s) => s.id == song.id);
    } else {
      _favorites.add(song);
    }
    await _saveFavorites();
  }

  // Add to favorites
  static Future<void> addFavorite(Song song) async {
    if (!isFavorite(song)) {
      _favorites.add(song);
      await _saveFavorites();
    }
  }

  // Remove from favorites
  static Future<void> removeFavorite(Song song) async {
    _favorites.removeWhere((s) => s.id == song.id);
    await _saveFavorites();
  }

  // Clear all favorites
  static Future<void> clearFavorites() async {
    _favorites.clear();
    await _saveFavorites();
  }

  // Get favorites count
  static int getFavoritesCount() {
    return _favorites.length;
  }
}