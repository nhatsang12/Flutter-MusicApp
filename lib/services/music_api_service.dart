// lib/services/music_api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/song.dart';

class MusicApiService {
  // Fetch songs from Deezer API
  static Future<List<Song>> fetchFromDeezer({int limit = 30}) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.deezer.com/chart/0/tracks?limit=$limit'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tracks = data['data'] as List;

        return tracks.map((track) => Song.fromDeezer(track)).toList();
      } else {
        throw Exception('API returned status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching from Deezer: $e');
      throw Exception('Failed to load songs from Deezer');
    }
  }

  // --- HÀM MỚI QUAN TRỌNG: LẤY THÔNG TIN BÀI HÁT TỪ ID ---
  // Hàm này giúp lấy lại link nhạc mới khi link cũ trong playlist bị hết hạn
  static Future<Song?> fetchSongById(String songId) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.deezer.com/track/$songId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Kiểm tra xem API có trả về lỗi không (ví dụ ID sai hoặc bài bị xóa)
        if (data['error'] != null) {
          print("Deezer API Error: ${data['error']}");
          return null;
        }

        // Trả về đối tượng Song với link nhạc (preview) mới nhất
        return Song.fromDeezer(data);
      }
    } catch (e) {
      print('Error fetching song detail: $e');
    }
    return null;
  }
  // -------------------------------------------------------

  // Sample songs as fallback
  static List<Song> getSampleSongs() {
    return [
      Song(
        id: 'sample_1',
        title: 'Summer Vibes',
        artist: 'DJ Cool',
        url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
        coverUrl: 'https://picsum.photos/300/300?random=1',
        duration: '3:45',
      ),
      Song(
        id: 'sample_2',
        title: 'Midnight Dreams',
        artist: 'Luna Star',
        url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
        coverUrl: 'https://picsum.photos/300/300?random=2',
        duration: '4:20',
      ),
      Song(
        id: 'sample_3',
        title: 'Ocean Waves',
        artist: 'Chill Beats',
        url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
        coverUrl: 'https://picsum.photos/300/300?random=3',
        duration: '5:10',
      ),
      Song(
        id: 'sample_4',
        title: 'City Lights',
        artist: 'Urban Flow',
        url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
        coverUrl: 'https://picsum.photos/300/300?random=4',
        duration: '4:05',
      ),
      Song(
        id: 'sample_5',
        title: 'Mountain Echo',
        artist: 'Nature Sounds',
        url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
        coverUrl: 'https://picsum.photos/300/300?random=5',
        duration: '3:30',
      ),
    ];
  }

  // Search songs
  static Future<List<Song>> searchSongs(String query) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.deezer.com/search?q=$query&limit=20'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tracks = data['data'] as List;

        return tracks.map((track) => Song.fromDeezer(track)).toList();
      } else {
        throw Exception('Search failed');
      }
    } catch (e) {
      print('Error searching: $e');
      return [];
    }
  }

  // Get top tracks by genre
  static Future<List<Song>> getTopTracksByGenre(int genreId, {int limit = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.deezer.com/genre/$genreId/top?limit=$limit'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tracks = data['data'] as List;

        return tracks.map((track) => Song.fromDeezer(track)).toList();
      } else {
        throw Exception('Failed to load genre tracks');
      }
    } catch (e) {
      print('Error fetching genre tracks: $e');
      return [];
    }
  }
}