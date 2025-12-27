// lib/screens/playlist_detail_page.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/playlist_manager.dart';
import '../services/action_service.dart';
import '../services/favorites_manager.dart';
import '../services/audio_manager.dart';
import '../widgets/mini_player.dart';
import '../widgets/music_player.dart';
// --- IMPORT ĐA NGÔN NGỮ ---
import 'package:provider/provider.dart';
import '../services/language_provider.dart';
// --------------------------

class PlaylistDetailPage extends StatefulWidget {
  final Playlist playlist;
  final Function(Song) onSongTap;

  const PlaylistDetailPage({Key? key, required this.playlist, required this.onSongTap}) : super(key: key);

  @override
  _PlaylistDetailPageState createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  final AudioManager _audioManager = AudioManager();

  void _playShuffle() {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    if (widget.playlist.songs.isEmpty) return;
    int randomIndex = Random().nextInt(widget.playlist.songs.length);
    _audioManager.play(widget.playlist.songs[randomIndex], widget.playlist.songs);
    _audioManager.isShuffle = true;
    _audioManager.toggleShuffle();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(lang.getText('playing_shuffle'))));
  }

  void _downloadAll() {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(lang.getText('downloading'))));
  }

  void _showRenameDialog() {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    TextEditingController controller = TextEditingController(text: widget.playlist.name);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Color(0xFF2C2C3E),
        title: Text(lang.getText('rename_playlist'), style: TextStyle(color: Colors.white)),
        content: TextField(controller: controller, style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(lang.getText('cancel'))),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await PlaylistManager.renamePlaylist(widget.playlist.id, controller.text);
                setState(() {});
                Navigator.pop(ctx);
              }
            },
            child: Text(lang.getText('save')),
          )
        ],
      ),
    );
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
    // --- LẤY NGÔN NGỮ ---
    final lang = Provider.of<LanguageProvider>(context);
    // -------------------

    String coverUrl = widget.playlist.songs.isNotEmpty
        ? widget.playlist.songs.first.coverUrl
        : "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?q=80&w=1000&auto=format&fit=crop";

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Colors.red.shade900.withOpacity(0.8), Color(0xFF121212)], stops: [0.0, 0.6],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeaderInfo(coverUrl, lang), // Truyền lang vào header
                      SizedBox(height: 24),
                      _buildActionButtons(lang), // Truyền lang vào nút bấm
                      SizedBox(height: 24),
                      _buildPremiumBanner(lang), // Truyền lang vào banner
                      SizedBox(height: 16),
                      _buildSongList(lang), // Truyền lang vào danh sách
                      SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      bottomSheet: StreamBuilder<void>(
        stream: _audioManager.uiStream.stream,
        builder: (context, snapshot) {
          if (_audioManager.currentSong != null) {
            return Container(
              color: Color(0xFF121212),
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

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context)),
          IconButton(icon: Icon(Icons.more_horiz, color: Colors.white), onPressed: _showRenameDialog),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo(String coverUrl, LanguageProvider lang) {
    return Column(
      children: [
        Container(height: 200, width: 200, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 20, offset: Offset(0, 10))], image: DecorationImage(image: NetworkImage(coverUrl), fit: BoxFit.cover))),
        SizedBox(height: 16),
        Text(widget.playlist.name, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        SizedBox(height: 8),
        Text("${lang.getText('created_by')} Music Lover", style: TextStyle(color: Colors.white70, fontSize: 14)), // "Tạo bởi..."
        SizedBox(height: 4),
        Text("${widget.playlist.songs.length} ${lang.getText('stats_songs').toLowerCase()}", style: TextStyle(color: Colors.white54, fontSize: 12)), // "n bài hát"
      ],
    );
  }

  Widget _buildActionButtons(LanguageProvider lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSmallActionButton(Icons.arrow_circle_down, lang.getText('download'), _downloadAll),
          ElevatedButton(
            onPressed: _playShuffle,
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF8B5CF6), foregroundColor: Colors.white, padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 8),
            child: Text(lang.getText('shuffle_play'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          ),
          _buildSmallActionButton(Icons.add_circle_outline, lang.getText('add_songs'), () { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(lang.getText('feature_dev')))); }),
        ],
      ),
    );
  }

  Widget _buildSmallActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: Column(children: [Icon(icon, color: Colors.white70, size: 28), SizedBox(height: 4), Text(label, style: TextStyle(color: Colors.white70, fontSize: 10))]));
  }

  Widget _buildPremiumBanner(LanguageProvider lang) {
    return Container(margin: EdgeInsets.symmetric(horizontal: 16), padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration(color: Colors.brown.withOpacity(0.3), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.withOpacity(0.3))), child: Row(children: [Icon(Icons.diamond_outlined, color: Colors.orange), SizedBox(width: 12), Expanded(child: Text(lang.getText('premium_banner'), style: TextStyle(color: Colors.white, fontSize: 13))), Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 14)]));
  }

  Widget _buildSongList(LanguageProvider lang) {
    if (widget.playlist.songs.isEmpty) return Padding(padding: const EdgeInsets.only(top: 40), child: Text(lang.getText('empty_list'), style: TextStyle(color: Colors.white38)));

    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: widget.playlist.songs.length,
      itemBuilder: (context, index) {
        final song = widget.playlist.songs[index];
        bool isFav = FavoritesManager.isFavorite(song);
        bool isPlayingThis = _audioManager.currentSong?.id == song.id;

        return Dismissible(
          key: Key(song.id),
          direction: DismissDirection.endToStart,
          background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: EdgeInsets.only(right: 20), child: Icon(Icons.delete, color: Colors.white)),
          onDismissed: (direction) async {
            await PlaylistManager.removeSongFromPlaylist(widget.playlist.id, song.id);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${lang.getText('deleted_song')} ${song.title}")));
          },
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.network(song.coverUrl, width: 50, height: 50, fit: BoxFit.cover)),
            title: Text(song.title, style: TextStyle(color: isPlayingThis ? Colors.purpleAccent : Colors.white, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(song.artist, style: TextStyle(color: Colors.white60, fontSize: 12), maxLines: 1),

            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.redAccent : Colors.white30, size: 20),
                  onPressed: () async {
                    await FavoritesManager.toggleFavorite(song);
                    setState(() {});
                  },
                ),
                SizedBox(width: 8),
                Icon(Icons.more_horiz, color: Colors.white30),
              ],
            ),

            onTap: () {
              _audioManager.play(song, widget.playlist.songs);
            },
          ),
        );
      },
    );
  }
}