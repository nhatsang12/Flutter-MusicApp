// lib/widgets/playlist_view.dart
import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/favorites_manager.dart';

class PlaylistView extends StatefulWidget {
  final List<Song> playlist;
  final int currentIndex;
  final Function(Song, int) onSongTap;

  const PlaylistView({
    Key? key,
    required this.playlist,
    required this.currentIndex,
    required this.onSongTap,
  }) : super(key: key);

  @override
  _PlaylistViewState createState() => _PlaylistViewState();
}

class _PlaylistViewState extends State<PlaylistView> {
  @override
  Widget build(BuildContext context) {
    if (widget.playlist.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_off, size: 80, color: Colors.white24),
            SizedBox(height: 16),
            Text(
              'Không có bài hát nào',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: widget.playlist.length,
      padding: EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final song = widget.playlist[index];
        final isCurrentSong = widget.currentIndex == index;
        final isFavorite = FavoritesManager.isFavorite(song);

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isCurrentSong
                ? Colors.purple.withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                song.coverUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey[800],
                  child: Icon(Icons.music_note, size: 30, color: Colors.white54),
                ),
              ),
            ),
            title: Text(
              song.title,
              style: TextStyle(
                fontWeight: isCurrentSong ? FontWeight.bold : FontWeight.normal,
                color: isCurrentSong ? Colors.purple.shade300 : Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              song.artist,
              style: TextStyle(
                color: isCurrentSong ? Colors.purple.shade200 : Colors.white70,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nút thêm vào thư viện
                IconButton(
                  icon: Icon(
                    Icons.library_add,
                    color: Colors.blue.shade300,
                    size: 22,
                  ),
                  onPressed: () {
                    _showAddToLibraryOptions(context, song);
                  },
                  tooltip: 'Thêm vào thư viện',
                ),
                // Nút yêu thích (tim)
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.white54,
                    size: 22,
                  ),
                  onPressed: () async {
                    await FavoritesManager.toggleFavorite(song);
                    setState(() {});

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          FavoritesManager.isFavorite(song)
                              ? '❤️ Đã thêm "${song.title}" vào yêu thích'
                              : '💔 Đã xóa "${song.title}" khỏi yêu thích',
                        ),
                        duration: Duration(seconds: 2),
                        backgroundColor: FavoritesManager.isFavorite(song)
                            ? Colors.green
                            : Colors.orange,
                      ),
                    );
                  },
                  tooltip: 'Yêu thích',
                ),
                // Thời gian và icon đang phát
                if (isCurrentSong)
                  Icon(Icons.equalizer, color: Colors.purple.shade300, size: 20),
                SizedBox(width: 4),
                Text(
                  song.duration,
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
            onTap: () => widget.onSongTap(song, index),
          ),
        );
      },
    );
  }

  void _showAddToLibraryOptions(BuildContext context, Song song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    song.coverUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(Icons.music_note),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        song.artist,
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.favorite, color: Colors.red),
              title: Text('Thêm vào yêu thích', style: TextStyle(color: Colors.white)),
              onTap: () async {
                await FavoritesManager.addFavorite(song);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('❤️ Đã thêm vào yêu thích')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.playlist_add, color: Colors.blue.shade300),
              title: Text('Thêm vào playlist', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('🎵 Tính năng playlist đang phát triển')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.download, color: Colors.green.shade300),
              title: Text('Tải xuống', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('⬇️ Tính năng tải xuống đang phát triển')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.share, color: Colors.purple.shade300),
              title: Text('Chia sẻ', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('📤 Tính năng chia sẻ đang phát triển')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}