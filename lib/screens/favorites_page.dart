// lib/screens/favorites_page.dart
import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/favorites_manager.dart';

class FavoritesPage extends StatefulWidget {
  final Function(Song, int) onSongTap;

  const FavoritesPage({Key? key, required this.onSongTap}) : super(key: key);

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Song> _favorites = [];

  @override
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await FavoritesManager.initFavorites();
    _loadFavorites();
  }


  void _loadFavorites() {
    setState(() {
      _favorites = FavoritesManager.getFavorites();
    });
  }

  void _removeFavorite(Song song) async {
    final success = await FavoritesManager.removeFavorite(song);

    if (success) {
      _loadFavorites();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xóa "${song.title}" khỏi yêu thích'),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi xóa yêu thích'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  void _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1E1E1E),
        title: Text('Xóa tất cả?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Bạn có chắc muốn xóa tất cả bài hát yêu thích?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FavoritesManager.clearFavorites();
      _loadFavorites();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xóa tất cả yêu thích')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yêu thích (${_favorites.length})'),
        actions: [
          if (_favorites.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep),
              onPressed: _clearAll,
              tooltip: 'Xóa tất cả',
            ),
        ],
      ),
      body: _favorites.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 100, color: Colors.white24),
            SizedBox(height: 20),
            Text('Chưa có bài hát yêu thích', style: TextStyle(fontSize: 18, color: Colors.white54)),
            SizedBox(height: 10),
            Text('Nhấn icon ♥ để thêm bài hát', style: TextStyle(fontSize: 14, color: Colors.white38)),
          ],
        ),
      )
          : ListView.builder(
        itemCount: _favorites.length,
        padding: EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          final song = _favorites[index];
          return Dismissible(
            key: Key(song.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20),
              color: Colors.red,
              child: Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) => _removeFavorite(song),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Color(0xFF1E1E1E),
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
                    errorBuilder: (_, __, ___) => Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[800],
                      child: Icon(Icons.music_note, color: Colors.white54),
                    ),
                  ),
                ),
                title: Text(song.title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                subtitle: Text(song.artist, style: TextStyle(color: Colors.white70, fontSize: 13)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(song.duration, style: TextStyle(color: Colors.white54, fontSize: 12)),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.favorite, color: Colors.red),
                      onPressed: () => _removeFavorite(song),
                    ),
                  ],
                ),
                onTap: () => widget.onSongTap(song, index),
              ),
            ),
          );
        },
      ),
    );
  }
}