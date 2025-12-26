import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/song.dart';
import 'auth_service.dart';

class FavoritesService {
  static const String baseUrl =
      "http://10.0.2.2:3000/api/favorites";

  static Future<List<Song>> fetchFavorites() async {
    final user = AuthService.getCurrentUser();
    if (user == null) return [];

    final res = await http.get(
      Uri.parse("$baseUrl/${user.id}"),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return (data['favorites'] as List)
          .map((e) => Song.fromJson(e))
          .toList();
    }
    return [];
  }

  static Future<void> addFavorite(Song song) async {
    final user = AuthService.getCurrentUser();
    if (user == null) return;

    await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": user.id,
        "song": song.toJson(),
      }),
    );
  }

  static Future<void> removeFavorite(String songId) async {
    final user = AuthService.getCurrentUser();
    if (user == null) return;

    await http.delete(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": user.id,
        "songId": songId,
      }),
    );
  }
}
