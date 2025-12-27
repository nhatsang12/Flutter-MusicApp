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
    _audioPlayer.onPlayerComplete.listen((event) => next());
    _audioPlayer.onDurationChanged.listen((d) { duration = d; _notify(); });
    _audioPlayer.onPositionChanged.listen((p) { position = p; _notify(); });
    _audioPlayer.onPlayerStateChanged.listen((s) { isPlaying = s == PlayerState.playing; _notify(); });
  }

  void _notify() {
    if (!uiStream.isClosed) uiStream.add(null);
  }

  // Hàm phát nhạc chính
  Future<void> play(Song song, List<Song> newPlaylist) async {
    playlist = newPlaylist;
    currentSong = song;

    // Lưu thống kê
    AuthService.addListeningStats(position.inSeconds);

    await _audioPlayer.stop();
    await _audioPlayer.play(UrlSource(song.url));
    isPlaying = true;
    _notify();
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
    play(playlist[nextIndex], playlist);
  }

  void previous() {
    if (playlist.isEmpty || currentSong == null) return;
    int currentIndex = playlist.indexWhere((s) => s.id == currentSong!.id);
    int prevIndex = (currentIndex - 1 + playlist.length) % playlist.length;
    play(playlist[prevIndex], playlist);
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