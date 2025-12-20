// lib/screens/music_home_page.dart
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/song.dart';
import '../services/music_api_service.dart';
import '../services/favorites_manager.dart';
import 'favorites_page.dart';
import 'library_page.dart';
import 'profile_page.dart';
import '../widgets/music_player.dart';
import '../widgets/playlist_view.dart';
import '../widgets/bottom_nav_bar.dart';

class MusicHomePage extends StatefulWidget {
  @override
  _MusicHomePageState createState() => _MusicHomePageState();
}

class _MusicHomePageState extends State<MusicHomePage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Song> _playlist = [];
  Song? _currentSong;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  int _currentIndex = -1;
  bool _isLoading = false;
  bool _isRepeat = false;
  bool _isShuffle = false;
  int _selectedNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
    _loadSongsFromDeezer();
    FavoritesManager.loadFavorites();
  }

  void _setupAudioPlayer() {
    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
    });

    _audioPlayer.onPositionChanged.listen((position) {
      setState(() => _position = position);
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() => _isPlaying = state == PlayerState.playing);
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      _onSongComplete();
    });
  }

  Future<void> _loadSongsFromDeezer() async {
    setState(() => _isLoading = true);

    try {
      List<Song> songs = await MusicApiService.fetchFromDeezer(limit: 30);
      setState(() {
        _playlist = songs;
      });

      if (songs.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Đã tải ${songs.length} bài hát từ Deezer')),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Lỗi tải nhạc: $e')),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: Duration(seconds: 3),
          ),
        );
      }
      // Fallback to sample songs if API fails
      setState(() {
        _playlist = MusicApiService.getSampleSongs();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _playSong(Song song, int index) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(song.url));
      setState(() {
        _currentSong = song;
        _currentIndex = index;
        _isPlaying = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể phát bài hát: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
  }

  void _playNext() {
    if (_playlist.isEmpty) return;
    int nextIndex;
    if (_isShuffle) {
      nextIndex = DateTime.now().millisecond % _playlist.length;
    } else {
      nextIndex = (_currentIndex + 1) % _playlist.length;
    }
    _playSong(_playlist[nextIndex], nextIndex);
  }

  void _playPrevious() {
    if (_playlist.isEmpty) return;
    int prevIndex = (_currentIndex - 1 + _playlist.length) % _playlist.length;
    _playSong(_playlist[prevIndex], prevIndex);
  }

  void _onSongComplete() {
    if (_isRepeat) {
      _audioPlayer.seek(Duration.zero);
      _audioPlayer.resume();
    } else {
      _playNext();
    }
  }

  void _seek(double value) {
    final position = Duration(seconds: value.toInt());
    _audioPlayer.seek(position);
  }

  // BUILD HOME PAGE CONTENT
  Widget _buildHomePage() {
    return Column(
      children: [
        if (_currentSong != null)
          MusicPlayer(
            currentSong: _currentSong!,
            isPlaying: _isPlaying,
            position: _position,
            duration: _duration,
            isRepeat: _isRepeat,
            isShuffle: _isShuffle,
            onPlayPause: _togglePlayPause,
            onNext: _playNext,
            onPrevious: _playPrevious,
            onRepeat: () => setState(() => _isRepeat = !_isRepeat),
            onShuffle: () => setState(() => _isShuffle = !_isShuffle),
            onSeek: _seek,
          ),
        Expanded(
          child: _isLoading
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Colors.purple.shade300,
                  strokeWidth: 3,
                ),
                SizedBox(height: 20),
                Text(
                  'Đang tải nhạc từ Deezer...',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          )
              : PlaylistView(
            playlist: _playlist,
            currentIndex: _currentIndex,
            onSongTap: _playSong,
          ),
        ),
      ],
    );
  }

  // GET CURRENT PAGE BASED ON INDEX
  Widget _getCurrentPage() {
    switch (_selectedNavIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return LibraryPage(onSongTap: _playSong);
      case 2:
        return FavoritesPage(onSongTap: _playSong);
      case 3:
        return ProfilePage();
      default:
        return _buildHomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedNavIndex == 0
          ? AppBar(
        title: Row(
          children: [
            Icon(Icons.music_note, color: Colors.purple.shade300),
            SizedBox(width: 8),
            Text('Music Player'),
          ],
        ),
        actions: [
          // Search button
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🔍 Tính năng tìm kiếm đang phát triển'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            tooltip: 'Tìm kiếm',
          ),
          // Refresh button
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadSongsFromDeezer,
            tooltip: 'Làm mới danh sách',
          ),
        ],
      )
          : null,
      body: _getCurrentPage(),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedNavIndex,
        onTap: (index) {
          setState(() => _selectedNavIndex = index);
        },
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}