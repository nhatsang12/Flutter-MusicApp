// lib/widgets/mini_player.dart
import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/favorites_manager.dart';

class MiniPlayer extends StatefulWidget {
  final Song song;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onTap;

  const MiniPlayer({
    Key? key,
    required this.song,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onNext,
    required this.onTap,
  }) : super(key: key);

  @override
  _MiniPlayerState createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  @override
  Widget build(BuildContext context) {
    bool isFav = FavoritesManager.isFavorite(widget.song);

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 64,
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 4))],
        ),
        child: Row(
          children: [
            // --- SỬA PHẦN ẢNH BÌA ---
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.song.coverUrl,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  // Thêm đoạn này để bắt lỗi ảnh
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 48,
                      height: 48,
                      color: Colors.grey[800],
                      child: Icon(Icons.music_note, color: Colors.white54),
                    );
                  },
                ),
              ),
            ),
            // ------------------------

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.song.title,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.song.artist,
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.redAccent : Colors.white),
              onPressed: () async {
                await FavoritesManager.toggleFavorite(widget.song);
                setState(() {});
              },
            ),
            IconButton(
              icon: Icon(widget.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
              onPressed: widget.onPlayPause,
            ),
            IconButton(
              icon: Icon(Icons.skip_next, color: Colors.white),
              onPressed: widget.onNext,
            ),
          ],
        ),
      ),
    );
  }
}