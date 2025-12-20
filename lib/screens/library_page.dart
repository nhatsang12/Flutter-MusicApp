// lib/screens/library_page.dart
import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/music_api_service.dart';

class LibraryPage extends StatefulWidget {
  final Function(Song, int) onSongTap;

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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Không thể tải từ Deezer, hiển thị bài mẫu')),
              ],
            ),
            backgroundColor: Colors.orange.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thư viện'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadLibrary,
            tooltip: 'Làm mới',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(70),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterSongs,
                style: TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm bài hát, ca sĩ...',
                  hintStyle: TextStyle(color: Colors.white54),
                  prefixIcon: Icon(Icons.search, color: Colors.purple.shade300),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.white70),
                    onPressed: _clearSearch,
                  )
                      : null,
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.white10, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.purple.shade300, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.purple.shade300,
              strokeWidth: 3,
            ),
            SizedBox(height: 20),
            Text(
              'Đang tải thư viện...',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      )
          : Column(
        children: [
          // Stats Cards
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    Icons.library_music,
                    'Bài hát',
                    '${_filteredSongs.length}',
                    Colors.purple.shade400,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    Icons.person,
                    'Ca sĩ',
                    '${_getUniqueArtists()}',
                    Colors.blue.shade400,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    Icons.album,
                    'Album',
                    '${_getUniqueAlbums()}',
                    Colors.pink.shade400,
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: Colors.white12, thickness: 1),
          ),

          // Search Results Info
          if (_searchQuery.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.search, size: 16, color: Colors.white54),
                  SizedBox(width: 8),
                  Text(
                    'Tìm thấy ${_filteredSongs.length} kết quả',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ],
              ),
            ),

          // Song List
          Expanded(
            child: _filteredSongs.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _searchQuery.isEmpty ? Icons.music_off : Icons.search_off,
                    size: 80,
                    color: Colors.white24,
                  ),
                  SizedBox(height: 20),
                  Text(
                    _searchQuery.isEmpty
                        ? 'Thư viện trống'
                        : 'Không tìm thấy kết quả',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_searchQuery.isNotEmpty) ...[
                    SizedBox(height: 8),
                    Text(
                      'Thử tìm kiếm với từ khóa khác',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ],
              ),
            )
                : ListView.builder(
              itemCount: _filteredSongs.length,
              padding: EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (context, index) {
                final song = _filteredSongs[index];
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
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
                    title: Text(
                      song.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      song.artist,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          song.duration,
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.play_circle_outline,
                          color: Colors.purple.shade300,
                          size: 28,
                        ),
                      ],
                    ),
                    onTap: () => widget.onSongTap(song, index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white54,
              fontSize: 11,
            ),
          ),
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