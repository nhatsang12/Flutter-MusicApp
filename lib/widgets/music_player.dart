// lib/widgets/music_player.dart
import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/theme_provider.dart'; // Import Theme để lấy màu
import 'package:provider/provider.dart';

class MusicPlayer extends StatelessWidget {
  final Song currentSong;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final bool isRepeat;
  final bool isShuffle;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onRepeat;
  final VoidCallback onShuffle;
  final Function(double) onSeek;

  const MusicPlayer({
    Key? key,
    required this.currentSong,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.isRepeat,
    required this.isShuffle,
    required this.onPlayPause,
    required this.onNext,
    required this.onPrevious,
    required this.onRepeat,
    required this.onShuffle,
    required this.onSeek,
  }) : super(key: key);

  String _formatTime(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inMinutes)}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context); // Lấy theme

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      // Nền Gradient nhẹ
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: theme.isDarkMode
              ? [Color(0xFF1a1a2e), Color(0xFF0f3460)]
              : [Colors.white, Colors.grey.shade200],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Nút kéo xuống để đóng
          Container(
            width: 40, height: 4,
            margin: EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(2)),
          ),

          // Ảnh bìa
          Container(
            height: 300,
            width: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 20, offset: Offset(0, 10))],
              image: DecorationImage(image: NetworkImage(currentSong.coverUrl), fit: BoxFit.cover),
            ),
          ),
          SizedBox(height: 30),

          // Tên bài hát
          Text(
            currentSong.title,
            style: TextStyle(color: theme.textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            currentSong.artist,
            style: TextStyle(color: theme.textSecondary, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30),

          // Thanh trượt thời gian
          Slider(
            activeColor: Colors.purpleAccent,
            inactiveColor: Colors.grey.withOpacity(0.3),
            min: 0,
            max: duration.inSeconds.toDouble(),
            value: position.inSeconds.toDouble().clamp(0, duration.inSeconds.toDouble()),
            onChanged: onSeek,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatTime(position), style: TextStyle(color: theme.textSecondary)),
                Text(_formatTime(duration), style: TextStyle(color: theme.textSecondary)),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Các nút điều khiển
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Nút Shuffle (Đổi màu khi bật)
              IconButton(
                icon: Icon(Icons.shuffle, size: 28),
                color: isShuffle ? Colors.purpleAccent : theme.iconColor,
                onPressed: onShuffle,
              ),

              // Previous
              IconButton(
                icon: Icon(Icons.skip_previous, size: 36),
                color: theme.textPrimary,
                onPressed: onPrevious,
              ),

              // Play/Pause (To nhất)
              Container(
                decoration: BoxDecoration(color: Colors.purpleAccent, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.4), blurRadius: 10, spreadRadius: 2)]),
                child: IconButton(
                  iconSize: 64,
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
                  onPressed: onPlayPause,
                ),
              ),

              // Next
              IconButton(
                icon: Icon(Icons.skip_next, size: 36),
                color: theme.textPrimary,
                onPressed: onNext,
              ),

              // Nút Repeat (Đổi màu khi bật)
              IconButton(
                icon: Icon(isRepeat ? Icons.repeat_one : Icons.repeat, size: 28),
                color: isRepeat ? Colors.purpleAccent : theme.iconColor,
                onPressed: onRepeat,
              ),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}