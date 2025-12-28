// lib/screens/library_page.dart
import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/music_api_service.dart';
import '../services/action_service.dart';
import '../services/favorites_manager.dart';
import '../widgets/add_playlist_sheet.dart';
import '../services/playlist_manager.dart';
import 'playlist_detail_page.dart';
import 'package:provider/provider.dart';
import '../services/language_provider.dart';
import '../services/theme_provider.dart'; // <--- IMPORT THEME

class LibraryPage extends StatefulWidget {
  final Function(Song, int, List<Song>?) onSongTap;

  const LibraryPage({Key? key, required this.onSongTap}) : super(key: key);

  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  List<Song> _allSongs = [];
  List<Song> _filteredSongs = [];
  bool _isLoading = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLibrary();
    PlaylistManager.loadPlaylists().then((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadLibrary() async {
    setState(() => _isLoading = true);
    try {
      final songs = await MusicApiService.fetchFromDeezer(limit: 50);
      setState(() {
        _allSongs = songs;
        _filteredSongs = songs;
      });
    } catch (e) {
      setState(() {
        _allSongs = MusicApiService.getSampleSongs();
        _filteredSongs = _allSongs;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterSongs(String query) {
    setState(() {
      _searchQuery = query;
      _filteredSongs = _allSongs.where((song) {
        return song.title.toLowerCase().contains(query.toLowerCase()) ||
            song.artist.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _filterSongs('');
  }

  void _showSongOptions(Song song) {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    final theme = Provider.of<ThemeProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(color: theme.isDarkMode ? Color(0xFF1E1E2C) : Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(2))),
            SizedBox(height: 20),
            ListTile(leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(song.coverUrl, width: 50, height: 50, fit: BoxFit.cover)), title: Text(song.title, style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.bold)), subtitle: Text(song.artist, style: TextStyle(color: theme.textSecondary))),
            Divider(color: Colors.grey.withOpacity(0.2)),
            ListTile(leading: Icon(Icons.favorite, color: Colors.redAccent), title: Text(lang.getText('add_to_fav'), style: TextStyle(color: theme.textPrimary)), onTap: () { FavoritesManager.toggleFavorite(song); Navigator.pop(context); }),
            ListTile(leading: Icon(Icons.playlist_add, color: Colors.blueAccent), title: Text(lang.getText('add_to_playlist'), style: TextStyle(color: theme.textPrimary)), onTap: () { Navigator.pop(context); showModalBottomSheet(context: context, backgroundColor: Colors.transparent, isScrollControlled: true, builder: (ctx) => Container(height: MediaQuery.of(context).size.height * 0.5, child: AddPlaylistSheet(song: song))); }),
            ListTile(leading: Icon(Icons.download, color: Colors.greenAccent), title: Text(lang.getText('download'), style: TextStyle(color: theme.textPrimary)), onTap: () { Navigator.pop(context); ActionService.downloadSong(context, song); }),
            ListTile(leading: Icon(Icons.share, color: Colors.purpleAccent), title: Text(lang.getText('share'), style: TextStyle(color: theme.textPrimary)), onTap: () { Navigator.pop(context); ActionService.shareSong(song); }),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _createNewPlaylist() {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    final theme = Provider.of<ThemeProvider>(context, listen: false);
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text(lang.getText('create_playlist_title'), style: TextStyle(color: theme.textPrimary)),
        content: TextField(
          controller: controller,
          style: TextStyle(color: theme.textPrimary),
          decoration: InputDecoration(hintText: lang.getText('enter_playlist_name'), hintStyle: TextStyle(color: theme.textSecondary), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.textSecondary))),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(lang.getText('cancel'), style: TextStyle(color: theme.textSecondary))),
          ElevatedButton(onPressed: () async { if (controller.text.isNotEmpty) { await PlaylistManager.createPlaylist(controller.text); setState(() {}); Navigator.pop(ctx); } }, child: Text(lang.getText('create')))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    // Lấy Theme
    final theme = Provider.of<ThemeProvider>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(lang.getText('library_title'), style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.bold)),
          iconTheme: IconThemeData(color: theme.textPrimary),
          actions: [
            IconButton(icon: Icon(Icons.refresh, color: theme.iconColor), onPressed: _loadLibrary, tooltip: lang.getText('refresh')),
            IconButton(icon: Icon(Icons.add, color: theme.iconColor), onPressed: _createNewPlaylist, tooltip: lang.getText('create')),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(120),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: theme.cardShadow,
                      color: theme.isDarkMode ? Colors.white.withOpacity(0.08) : Colors.white, // Nền tìm kiếm
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterSongs,
                      style: TextStyle(color: theme.textPrimary, fontSize: 16), // Chữ nhập vào
                      decoration: InputDecoration(
                        hintText: lang.getText('search_library'),
                        hintStyle: TextStyle(color: theme.textSecondary), // Chữ gợi ý
                        prefixIcon: Icon(Icons.search, color: Colors.purple.shade300),
                        suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: Icon(Icons.clear, color: theme.textSecondary), onPressed: _clearSearch) : null,
                        filled: true,
                        fillColor: Colors.transparent,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ),
                ),
                TabBar(
                  indicatorColor: Colors.purpleAccent,
                  labelColor: Colors.purpleAccent,
                  unselectedLabelColor: theme.textSecondary, // Màu Tab chưa chọn
                  tabs: [
                    Tab(text: lang.getText('tab_songs')),
                    Tab(text: lang.getText('tab_playlist'))
                  ],
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            // TAB 1
            _isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.purple.shade300))
                : Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(child: _buildStatCard(Icons.library_music, lang.getText('stats_songs'), '${_filteredSongs.length}', Colors.purple.shade400, theme)),
                      SizedBox(width: 12),
                      Expanded(child: _buildStatCard(Icons.person, lang.getText('stats_artists'), '${_getUniqueArtists()}', Colors.blue.shade400, theme)),
                      SizedBox(width: 12),
                      Expanded(child: _buildStatCard(Icons.album, lang.getText('stats_albums'), '${_getUniqueAlbums()}', Colors.pink.shade400, theme)),
                    ],
                  ),
                ),
                Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Divider(color: theme.textSecondary.withOpacity(0.2), thickness: 1)),

                Expanded(
                  child: _filteredSongs.isEmpty
                      ? Center(child: Text(lang.getText('no_result'), style: TextStyle(color: theme.textSecondary)))
                      : ListView.builder(
                    itemCount: _filteredSongs.length,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    itemBuilder: (context, index) {
                      final song = _filteredSongs[index];
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.cardColor, // Nền item
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: theme.cardShadow,
                          border: Border.all(color: theme.isDarkMode ? Colors.white10 : Colors.transparent),
                        ),
                        child: ListTile(
                          leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(song.coverUrl, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_,__,___) => Icon(Icons.music_note, color: theme.textSecondary))),
                          title: Text(song.title, style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text(song.artist, style: TextStyle(color: theme.textSecondary, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(song.duration, style: TextStyle(color: theme.textSecondary, fontSize: 12)),
                              SizedBox(width: 8),
                              IconButton(icon: Icon(Icons.more_vert, color: theme.iconColor), onPressed: () => _showSongOptions(song)),
                            ],
                          ),
                          onTap: () => widget.onSongTap(song, index, _filteredSongs),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            // TAB 2
            _buildPlaylistTab(lang, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistTab(LanguageProvider lang, ThemeProvider theme) {
    final playlists = PlaylistManager.playlists;
    if (playlists.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.queue_music, size: 80, color: theme.textSecondary),
            SizedBox(height: 16),
            Text(lang.getText('playlist_empty'), style: TextStyle(color: theme.textSecondary)),
            TextButton.icon(icon: Icon(Icons.add, color: Colors.purpleAccent), label: Text(lang.getText('create_now'), style: TextStyle(color: Colors.purpleAccent)), onPressed: _createNewPlaylist)
          ],
        ),
      );
    }
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.8),
      itemCount: playlists.length,
      itemBuilder: (context, index) {
        final playlist = playlists[index];
        String? cover = playlist.songs.isNotEmpty ? playlist.songs.first.coverUrl : null;
        return GestureDetector(
          onTap: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (context) => PlaylistDetailPage(
                playlist: playlist,
                onSongTap: (song) {
                  int idx = playlist.songs.indexOf(song);
                  widget.onSongTap(song, idx, playlist.songs);
                }
            )));
            setState(() {});
          },
          child: Container(
            decoration: BoxDecoration(
              color: theme.cardColor, // Nền Playlist Card
              borderRadius: BorderRadius.circular(16),
              boxShadow: theme.cardShadow,
              border: Border.all(color: theme.isDarkMode ? Colors.white10 : Colors.transparent),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.vertical(top: Radius.circular(16)), color: Colors.black26, image: cover != null ? DecorationImage(image: NetworkImage(cover), fit: BoxFit.cover) : null), child: cover == null ? Icon(Icons.music_note, size: 50, color: Colors.white24) : null)),
                Padding(padding: EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(playlist.name, style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis), Text("${playlist.songs.length} ${lang.getText('tab_songs').toLowerCase()}", style: TextStyle(color: theme.textSecondary, fontSize: 12))])),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value, Color color, ThemeProvider theme) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor, // Nền thẻ thống kê
        borderRadius: BorderRadius.circular(12),
        boxShadow: theme.cardShadow,
        border: Border.all(color: theme.isDarkMode ? Colors.white10 : Colors.transparent),
      ),
      child: Column(
        children: [
          Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 24)),
          SizedBox(height: 8),
          Text(value, style: TextStyle(color: theme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 2),
          Text(label, style: TextStyle(color: theme.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }

  int _getUniqueArtists() => _filteredSongs.map((s) => s.artist).toSet().length;
  int _getUniqueAlbums() => _filteredSongs.where((s) => s.album != null).map((s) => s.album).toSet().length;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}