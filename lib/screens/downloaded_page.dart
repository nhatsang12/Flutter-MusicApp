// lib/screens/downloaded_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io'; // Để xóa file
import '../models/song.dart';
import '../services/download_manager.dart';
import '../services/audio_manager.dart';
import '../services/theme_provider.dart';
import '../services/language_provider.dart';
import '../widgets/mini_player.dart';
import '../widgets/music_player.dart';

class DownloadedPage extends StatefulWidget {
  @override
  _DownloadedPageState createState() => _DownloadedPageState();
}

class _DownloadedPageState extends State<DownloadedPage> {
  List<Song> _downloadedSongs = [];
  final AudioManager _audioManager = AudioManager();

  @override
  void initState() {
    super.initState();
    _loadDownloadedSongs();
  }

  Future<void> _loadDownloadedSongs() async {
    final songs = await DownloadManager.getDownloadedSongs();
    setState(() {
      _downloadedSongs = songs;
    });
  }

  Future<void> _deleteSong(Song song) async {
    // 1. Xóa file vật lý
    try {
      final file = File(song.url);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print("Lỗi xóa file: $e");
    }
    // 2. Xóa khỏi danh sách lưu
    await DownloadManager.removeSong(song.id);
    _loadDownloadedSongs(); // Reload lại list
  }

  void _openFullScreenPlayer() {
    if (_audioManager.currentSong == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StreamBuilder<void>(
        stream: _audioManager.uiStream.stream,
        builder: (context, snapshot) => Container(
          height: MediaQuery.of(context).size.height * 0.95,
          child: MusicPlayer(
            currentSong: _audioManager.currentSong!,
            isPlaying: _audioManager.isPlaying,
            position: _audioManager.position,
            duration: _audioManager.duration,
            isRepeat: _audioManager.isRepeat,
            isShuffle: _audioManager.isShuffle,
            onPlayPause: _audioManager.togglePlayPause,
            onNext: _audioManager.next,
            onPrevious: _audioManager.previous,
            onRepeat: _audioManager.toggleRepeat,
            onShuffle: _audioManager.toggleShuffle,
            onSeek: (val) => _audioManager.seek(Duration(seconds: val.toInt())),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Đã tải (${_downloadedSongs.length})", style: TextStyle(color: theme.textPrimary)),
        iconTheme: IconThemeData(color: theme.textPrimary),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: theme.backgroundColors)),
        child: _downloadedSongs.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.download_done, size: 80, color: theme.textSecondary),
              SizedBox(height: 16),
              Text("Chưa có bài hát nào được tải", style: TextStyle(color: theme.textSecondary)),
            ],
          ),
        )
            : ListView.builder(
          itemCount: _downloadedSongs.length,
          itemBuilder: (context, index) {
            final song = _downloadedSongs[index];
            bool isPlaying = _audioManager.currentSong?.id == song.id;

            return Dismissible(
              key: Key(song.id),
              background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: EdgeInsets.only(right: 20), child: Icon(Icons.delete, color: Colors.white)),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) => _deleteSong(song),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.isDarkMode ? Colors.white10 : Colors.transparent),
                ),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(song.coverUrl, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_,__,___) => Icon(Icons.music_note, color: Colors.grey)),
                  ),
                  title: Text(song.title, style: TextStyle(color: isPlaying ? Colors.purpleAccent : theme.textPrimary, fontWeight: FontWeight.w600)),
                  subtitle: Text(song.artist, style: TextStyle(color: theme.textSecondary)),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () => _deleteSong(song),
                  ),
                  onTap: () {
                    // Phát nhạc từ file trong máy
                    _audioManager.play(song, _downloadedSongs);
                  },
                ),
              ),
            );
          },
        ),
      ),
      bottomSheet: StreamBuilder<void>(
        stream: _audioManager.uiStream.stream,
        builder: (context, snapshot) {
          if (_audioManager.currentSong != null) {
            return Container(
              color: theme.backgroundColors.last,
              child: MiniPlayer(
                song: _audioManager.currentSong!,
                isPlaying: _audioManager.isPlaying,
                onPlayPause: _audioManager.togglePlayPause,
                onNext: _audioManager.next,
                onTap: _openFullScreenPlayer,
              ),
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }
}