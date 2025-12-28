// lib/widgets/playlist_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song.dart';
import '../services/favorites_manager.dart';
import '../services/action_service.dart';
import '../widgets/add_playlist_sheet.dart';
// --- IMPORT MỚI ĐỂ ĐỒNG BỘ GIAO DIỆN & NGÔN NGỮ ---
import '../services/theme_provider.dart';
import '../services/language_provider.dart';
// --------------------------------------------------

class PlaylistView extends StatefulWidget {
  final List<Song> playlist;
  final int currentIndex;
  final Function(Song, int) onSongTap;
  final Function(Song)? onOptionTap; // Hàm callback từ bên ngoài (Trang chủ)

  const PlaylistView({
    Key? key,
    required this.playlist,
    required this.currentIndex,
    required this.onSongTap,
    this.onOptionTap,
  }) : super(key: key);

  @override
  _PlaylistViewState createState() => _PlaylistViewState();
}

class _PlaylistViewState extends State<PlaylistView> {
  @override
  Widget build(BuildContext context) {
    // Lấy Theme và Ngôn ngữ
    final theme = Provider.of<ThemeProvider>(context);
    final lang = Provider.of<LanguageProvider>(context);

    if (widget.playlist.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_off, size: 80, color: theme.textSecondary),
            SizedBox(height: 16),
            Text(
              lang.getText('no_result'), // "Không tìm thấy kết quả"
              style: TextStyle(color: theme.textSecondary, fontSize: 16),
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
            // Màu nền thay đổi theo Theme (Sáng/Tối)
            color: isCurrentSong
                ? Colors.purple.withOpacity(0.2)
                : theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: theme.cardShadow, // Đổ bóng nếu là Light Mode
            border: Border.all(color: theme.isDarkMode ? Colors.white10 : Colors.transparent),
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
                // Màu chữ: Tím nếu đang hát, Đen/Trắng tùy theme
                color: isCurrentSong ? Colors.purpleAccent : theme.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              song.artist,
              style: TextStyle(
                color: isCurrentSong ? Colors.purple.withOpacity(0.7) : theme.textSecondary,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nút mở Menu chức năng (3 CHẤM)
                IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: theme.iconColor, // Màu icon theo theme
                    size: 22,
                  ),
                  onPressed: () {
                    // Ưu tiên dùng hàm từ bên ngoài truyền vào (nếu có)
                    // Nếu không thì dùng hàm nội bộ
                    if (widget.onOptionTap != null) {
                      widget.onOptionTap!(song);
                    } else {
                      _showAddToLibraryOptions(context, song, lang);
                    }
                  },
                  tooltip: lang.getText('edit'),
                ),

                // Nút yêu thích
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : theme.iconColor,
                    size: 22,
                  ),
                  onPressed: () async {
                    await FavoritesManager.toggleFavorite(song);
                    setState(() {});

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          FavoritesManager.isFavorite(song)
                              ? '❤️ ${lang.getText('success')}'
                              : '💔 ${lang.getText('removed_favorite')}',
                        ),
                        duration: Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        backgroundColor: FavoritesManager.isFavorite(song)
                            ? Colors.green
                            : Colors.orange,
                      ),
                    );
                  },
                  tooltip: lang.getText('favorites'),
                ),

                // Icon đang phát
                if (isCurrentSong)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(Icons.equalizer, color: Colors.purpleAccent, size: 20),
                  ),
              ],
            ),
            onTap: () => widget.onSongTap(song, index),
          ),
        );
      },
    );
  }

  // --- HÀM HIỂN THỊ MENU CHỨC NĂNG (NỘI BỘ) ---
  void _showAddToLibraryOptions(BuildContext context, Song song, LanguageProvider lang) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Color(0xFF1E1E2C), // Giữ màu tối cho BottomSheet cho đẹp
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(song.coverUrl, width: 50, height: 50, fit: BoxFit.cover),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(song.title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(song.artist, style: TextStyle(color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Divider(color: Colors.white10),

            ListTile(
              leading: Icon(Icons.playlist_add, color: Colors.blue.shade300),
              title: Text(lang.getText('add_to_playlist'), style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: AddPlaylistSheet(song: song),
                  ),
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.download, color: Colors.green.shade300),
              title: Text(lang.getText('download'), style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ActionService.downloadSong(context, song);
              },
            ),

            ListTile(
              leading: Icon(Icons.share, color: Colors.purple.shade300),
              title: Text(lang.getText('share'), style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ActionService.shareSong(song);
              },
            ),
          ],
        ),
      ),
    );
  }
}