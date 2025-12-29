// lib/services/audio_manager.dart
import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import '../models/song.dart';
import 'auth_service.dart';

class AudioManager {
  // Singleton: Giúp truy cập AudioManager ở bất cứ đâu trong app
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;

  final AudioPlayer _audioPlayer = AudioPlayer();
  final StreamController<void> uiStream = StreamController.broadcast(); // Đường dây nóng cập nhật UI

  List<Song> playlist = []; // Danh sách bài hát đang chờ phát
  Song? currentSong;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  bool isShuffle = false;
  bool isRepeat = false;

  AudioManager._internal() {
    // Lắng nghe sự kiện từ AudioPlayer
    _audioPlayer.onPlayerComplete.listen((event) {
      if (currentSong == null) return;

      // --- FIX LỖI LOOP ---
      if (isRepeat) {
        // Nếu đang bật lặp lại, phát lại bài hiện tại
        play(currentSong!, null);
      } else {
        // Nếu không, chuyển bài tiếp theo
        next();
      }
    });

    _audioPlayer.onDurationChanged.listen((d) { duration = d; _notify(); });
    _audioPlayer.onPositionChanged.listen((p) { position = p; _notify(); });
    _audioPlayer.onPlayerStateChanged.listen((s) { isPlaying = s == PlayerState.playing; _notify(); });
  }

  void _notify() {
    if (!uiStream.isClosed) uiStream.add(null);
  }

  // Hàm phát nhạc chính (Đã cập nhật để hỗ trợ Offline)
  Future<void> play(Song song, List<Song>? newPlaylist) async {
    // 1. Cập nhật danh sách phát nếu có
    if (newPlaylist != null && newPlaylist.isNotEmpty) {
      playlist = List.from(newPlaylist);
    }

    currentSong = song;

    // Lưu thống kê
    AuthService.addListeningStats(position.inSeconds);

    try {
      await _audioPlayer.stop();

      // --- LOGIC QUAN TRỌNG: PHÂN BIỆT ONLINE / OFFLINE ---
      if (song.url.startsWith('http') || song.url.startsWith('https')) {
        // Nếu là link mạng -> Dùng UrlSource
        await _audioPlayer.play(UrlSource(song.url));
      } else {
        // Nếu là đường dẫn file trong máy -> Dùng DeviceFileSource
        await _audioPlayer.play(DeviceFileSource(song.url));
      }
      // ----------------------------------------------------

      isPlaying = true;
      _notify();
    } catch (e) {
      print("Lỗi phát nhạc: $e");
    }
  }

  Future<void> togglePlayPause() async {
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
    _notify();
  }

  void next() {
    if (playlist.isEmpty || currentSong == null) return;
    int currentIndex = playlist.indexWhere((s) => s.id == currentSong!.id);
    int nextIndex;

    if (isShuffle) {
      nextIndex = Random().nextInt(playlist.length);
    } else {
      nextIndex = (currentIndex + 1) % playlist.length;
    }
    play(playlist[nextIndex], null); // Truyền null để giữ nguyên playlist hiện tại
  }

  void previous() {
    if (playlist.isEmpty || currentSong == null) return;
    int currentIndex = playlist.indexWhere((s) => s.id == currentSong!.id);
    int prevIndex = (currentIndex - 1 + playlist.length) % playlist.length;
    play(playlist[prevIndex], null);
  }

  void seek(Duration pos) {
    _audioPlayer.seek(pos);
  }

  void toggleShuffle() { isShuffle = !isShuffle; _notify(); }
  void toggleRepeat() { isRepeat = !isRepeat; _notify(); }

  void dispose() {
    _audioPlayer.dispose();
    uiStream.close();
  }
}