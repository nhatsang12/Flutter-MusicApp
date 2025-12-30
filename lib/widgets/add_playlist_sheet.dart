import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/playlist_manager.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';
import '../services/language_provider.dart';

class AddPlaylistSheet extends StatefulWidget {
  final Song? song;

  AddPlaylistSheet({this.song});

  @override
  _AddPlaylistSheetState createState() => _AddPlaylistSheetState();
}

class _AddPlaylistSheetState extends State<AddPlaylistSheet> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final lang = Provider.of<LanguageProvider>(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.isDarkMode ? Color(0xFF1E1E2C) : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                lang.getText('add_to_playlist') ?? "Thêm vào Playlist",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textPrimary),
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.add, color: Colors.purpleAccent),
                title: Text(lang.getText('create_playlist') ?? "Tạo Playlist mới", style: TextStyle(color: theme.textPrimary)),
                onTap: () => _showCreateDialog(context),
              ),
              Divider(color: theme.isDarkMode ? Colors.white24 : Colors.grey),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: PlaylistManager.playlists.length,
                itemBuilder: (context, index) {
                  final playlist = PlaylistManager.playlists[index];
                  return ListTile(
                    leading: Icon(Icons.queue_music, color: Colors.white70),
                    title: Text(playlist.name, style: TextStyle(color: theme.textPrimary)),
                    subtitle: Text("${playlist.songs.length} bài hát", style: TextStyle(color: theme.textSecondary)),
                    onTap: () async {
                      if (widget.song != null) {
                        bool success = await PlaylistManager.addSongToPlaylist(playlist.id, widget.song!);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success ? "Đã thêm vào ${playlist.name}" : "Bài hát đã có trong playlist!"),
                            backgroundColor: success ? Colors.green : Colors.orange,
                          ),
                        );
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: false);
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    _nameController.clear();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.isDarkMode ? Color(0xFF2C2C3E) : Colors.white,
        title: Text(lang.getText('create_playlist') ?? "Tạo Playlist mới", style: TextStyle(color: theme.textPrimary)),
        content: TextField(
          controller: _nameController,
          style: TextStyle(color: theme.textPrimary),
          decoration: InputDecoration(
            hintText: lang.getText('playlist_name') ?? "Tên playlist",
            hintStyle: TextStyle(color: theme.textSecondary),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.textSecondary)),
          ),
          autofocus: true,
          onSubmitted: (_) => _createPlaylist(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(lang.getText('cancel') ?? "Hủy")),
          ElevatedButton(onPressed: _createPlaylist, child: Text(lang.getText('create') ?? "Tạo")),
        ],
      ),
    );
  }

  Future<void> _createPlaylist() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    try {
      final newPlaylist = await PlaylistManager.createPlaylist(name);

      if (widget.song != null) {
        await PlaylistManager.addSongToPlaylist(newPlaylist.id, widget.song!);
      }

      setState(() {});
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Playlist '${newPlaylist.name}' đã tạo${widget.song != null ? ' và thêm bài hát' : ''}")),
      );
    } catch (e) {
      print('Create playlist error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ ${e.toString()}')));
    }
  }
}
