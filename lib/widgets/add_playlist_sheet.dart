// lib/widgets/add_playlist_sheet.dart
import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/playlist_manager.dart';

class AddPlaylistSheet extends StatefulWidget {
  final Song song;
  const AddPlaylistSheet({Key? key, required this.song}) : super(key: key);

  @override
  _AddPlaylistSheetState createState() => _AddPlaylistSheetState();
}

class _AddPlaylistSheetState extends State<AddPlaylistSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Color(0xFF1E1E2C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Thêm vào Playlist", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),

          // Nút tạo mới
          ListTile(
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.add, color: Colors.purpleAccent),
            ),
            title: Text("Tạo Playlist mới", style: TextStyle(color: Colors.white)),
            onTap: () {
              _showCreateDialog(context);
            },
          ),
          Divider(color: Colors.white10),

          // Danh sách Playlist đã có
          Expanded( // Dùng Expanded nếu danh sách dài
            child: ListView.builder(
              shrinkWrap: true, // Quan trọng để nằm trong Column
              itemCount: PlaylistManager.playlists.length,
              itemBuilder: (context, index) {
                final playlist = PlaylistManager.playlists[index];
                return ListTile(
                  leading: Icon(Icons.queue_music, color: Colors.white70),
                  title: Text(playlist.name, style: TextStyle(color: Colors.white)),
                  subtitle: Text("${playlist.songs.length} bài hát", style: TextStyle(color: Colors.grey)),
                  onTap: () async {
                    bool success = await PlaylistManager.addSongToPlaylist(playlist.id, widget.song);
                    Navigator.pop(context); // Đóng Sheet

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(success ? "Đã thêm vào ${playlist.name}" : "Bài hát đã có trong playlist!"),
                      backgroundColor: success ? Colors.green : Colors.orange,
                    ));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Dialog nhập tên playlist mới
  void _showCreateDialog(BuildContext context) {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Color(0xFF2C2C3E),
        title: Text("Tạo Playlist mới", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Nhập tên playlist...",
            hintStyle: TextStyle(color: Colors.white38),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await PlaylistManager.createPlaylist(controller.text);
                setState(() {}); // Load lại danh sách ở màn hình dưới
                Navigator.pop(ctx); // Đóng dialog nhập
              }
            },
            child: Text("Tạo"),
          )
        ],
      ),
    );
  }
}