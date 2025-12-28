// lib/screens/music_home_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import '../models/song.dart';
import '../services/music_api_service.dart';
import '../services/favorites_manager.dart';
import '../services/auth_service.dart';
import '../services/playlist_manager.dart';
import '../services/action_service.dart';
import '../services/audio_manager.dart';
import '../widgets/add_playlist_sheet.dart';
import 'favorites_page.dart';
import 'library_page.dart';
import 'profile_page.dart';
import '../widgets/music_player.dart';
import '../widgets/playlist_view.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/mini_player.dart';
import 'package:provider/provider.dart';
import '../services/language_provider.dart';
import '../services/theme_provider.dart'; // <--- IMPORT THEME

class MusicHomePage extends StatefulWidget {
  @override
  _MusicHomePageState createState() => _MusicHomePageState();
}

class _MusicHomePageState extends State<MusicHomePage> {
  final AudioManager _audioManager = AudioManager();

  List<Song> _displaySongs = [];
  bool _isLoading = false;
  int _selectedNavIndex = 0;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSongsFromDeezer();
    FavoritesManager.loadFavorites();
    PlaylistManager.loadPlaylists();
  }

  Future<void> _loadSongsFromDeezer() async {
    setState(() => _isLoading = true);
    try {
      List<Song> songs = await MusicApiService.fetchFromDeezer(limit: 30);
      setState(() {
        _displaySongs = songs;
      });
    } catch (e) {
      if (mounted) {
        final lang = Provider.of<LanguageProvider>(context, listen: false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${lang.getText('load_error')}: $e')));
      }
      setState(() {
        _displaySongs = MusicApiService.getSampleSongs();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;
    final lang = Provider.of<LanguageProvider>(context, listen: false);

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();
    try {
      List<Song> results = await MusicApiService.searchSongs(query);
      setState(() {
        _displaySongs = results;
      });
      if (results.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(lang.getText('search_empty'))));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${lang.getText('search_error')}: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _loadSongsFromDeezer();
      }
    });
  }

  void _playSong(Song song, int index, {List<Song>? contextPlaylist}) {
    final playlistToPlay = contextPlaylist ?? _displaySongs;
    _audioManager.play(song, playlistToPlay);
  }

  void _openFullScreenPlayer() {
    if (_audioManager.currentSong == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StreamBuilder<void>(
            stream: _audioManager.uiStream.stream,
            builder: (context, snapshot) {
              if (_audioManager.currentSong == null) return SizedBox();

              return Container(
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
              );
            }
        );
      },
    );
  }

  void _showSongOptions(Song song) {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    // Lấy Theme để chỉnh màu BottomSheet
    final theme = Provider.of<ThemeProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.isDarkMode ? Color(0xFF1E1E2C) : Colors.white, // Nền đổi màu
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.favorite, color: Colors.redAccent),
              title: Text(lang.getText('add_to_fav'), style: TextStyle(color: theme.textPrimary)), // Chữ đổi màu
              onTap: () {
                FavoritesManager.toggleFavorite(song);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(lang.getText('success'))));
              },
            ),
            ListTile(
              leading: Icon(Icons.playlist_add, color: Colors.blueAccent),
              title: Text(lang.getText('add_to_playlist'), style: TextStyle(color: theme.textPrimary)), // Chữ đổi màu
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) => Container(height: 400, child: AddPlaylistSheet(song: song)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.download, color: Colors.greenAccent),
              title: Text(lang.getText('download'), style: TextStyle(color: theme.textPrimary)), // Chữ đổi màu
              onTap: () {
                Navigator.pop(context);
                ActionService.downloadSong(context, song);
              },
            ),
            ListTile(
              leading: Icon(Icons.share, color: Colors.purpleAccent),
              title: Text(lang.getText('share'), style: TextStyle(color: theme.textPrimary)), // Chữ đổi màu
              onTap: () {
                Navigator.pop(context);
                ActionService.shareSong(song);
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHomePage(LanguageProvider lang, ThemeProvider theme) {
    return Column(
      children: [
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : _displaySongs.isEmpty
              ? Center(child: Text(lang.getText('no_result'), style: TextStyle(color: theme.textSecondary))) // Chữ đổi màu
              : PlaylistView(
            playlist: _displaySongs,
            currentIndex: _displaySongs.indexWhere((s) => s.id == _audioManager.currentSong?.id),
            onSongTap: (song, index) => _playSong(song, index),
            onOptionTap: _showSongOptions,
          ),
        ),
      ],
    );
  }

  Widget _getCurrentPage(LanguageProvider lang, ThemeProvider theme) {
    switch (_selectedNavIndex) {
      case 0: return _buildHomePage(lang, theme);
      case 1: return LibraryPage(onSongTap: (song, index, playlist) {
        _playSong(song, index, contextPlaylist: playlist);
      });
      case 2: return FavoritesPage(onSongTap: (song, index) {
        _playSong(song, index, contextPlaylist: FavoritesManager.getFavorites());
      });
      case 3: return ProfilePage();
      default: return _buildHomePage(lang, theme);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    // Lấy Theme
    final theme = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: _selectedNavIndex == 0
          ? AppBar(
        // Màu icon trên AppBar đổi theo Theme
        iconTheme: IconThemeData(color: theme.textPrimary),
        title: _isSearching
            ? TextField(
          controller: _searchController,
          // Màu chữ nhập vào đổi theo Theme
          style: TextStyle(color: theme.textPrimary),
          autofocus: true,
          decoration: InputDecoration(
            hintText: lang.getText('search_hint'),
            // Màu chữ gợi ý đổi theo Theme
            hintStyle: TextStyle(color: theme.textSecondary),
            border: InputBorder.none,
          ),
          onSubmitted: _performSearch,
        )
            : Text(lang.getText('app_name'), style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search, color: theme.iconColor),
              onPressed: _toggleSearch
          ),
          if (!_isSearching)
            IconButton(
                icon: Icon(Icons.refresh, color: theme.iconColor),
                onPressed: _loadSongsFromDeezer
            ),

          StreamBuilder<void>(
              stream: _audioManager.uiStream.stream,
              builder: (context, snapshot) {
                if (_audioManager.currentSong != null) {
                  return IconButton(
                      icon: Icon(Icons.more_vert, color: theme.iconColor),
                      onPressed: () => _showSongOptions(_audioManager.currentSong!)
                  );
                }
                return SizedBox();
              }
          ),
        ],
      )
          : null,
      body: _getCurrentPage(lang, theme),

      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StreamBuilder<void>(
              stream: _audioManager.uiStream.stream,
              builder: (context, snapshot) {
                if (_audioManager.currentSong != null) {
                  return MiniPlayer(
                    song: _audioManager.currentSong!,
                    isPlaying: _audioManager.isPlaying,
                    onPlayPause: _audioManager.togglePlayPause,
                    onNext: _audioManager.next,
                    onTap: _openFullScreenPlayer,
                  );
                }
                return SizedBox.shrink();
              }
          ),

          CustomBottomNavBar(
            currentIndex: _selectedNavIndex,
            onTap: (index) => setState(() => _selectedNavIndex = index),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}