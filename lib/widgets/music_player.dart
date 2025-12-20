
import 'package:flutter/material.dart';
import '../models/song.dart';

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

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.purple.shade800, Colors.blue.shade900],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 10))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                currentSong.coverUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[800],
                  child: Icon(Icons.music_note, size: 100, color: Colors.white54),
                ),
              ),
            ),
          ),
          SizedBox(height: 30),
          Text(currentSong.title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center, maxLines: 2),
          SizedBox(height: 8),
          Text(currentSong.artist, style: TextStyle(fontSize: 16, color: Colors.white70)),
          SizedBox(height: 30),
          Slider(
            value: position.inSeconds.toDouble(),
            max: duration.inSeconds > 0 ? duration.inSeconds.toDouble() : 1.0,
            onChanged: onSeek,
            activeColor: Colors.white,
            inactiveColor: Colors.white30,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(position), style: TextStyle(color: Colors.white70)),
                Text(_formatDuration(duration), style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(icon: Icon(Icons.shuffle), color: isShuffle ? Colors.greenAccent : Colors.white70, iconSize: 28, onPressed: onShuffle),
              IconButton(icon: Icon(Icons.skip_previous), color: Colors.white, iconSize: 40, onPressed: onPrevious),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  color: Colors.purple.shade800,
                  iconSize: 40,
                  onPressed: onPlayPause,
                ),
              ),
              IconButton(icon: Icon(Icons.skip_next), color: Colors.white, iconSize: 40, onPressed: onNext),
              IconButton(icon: Icon(Icons.repeat), color: isRepeat ? Colors.greenAccent : Colors.white70, iconSize: 28, onPressed: onRepeat),
            ],
          ),
        ],
      ),
    );
  }
}