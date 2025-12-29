// lib/widgets/music_player.dart
import 'package:flutter/material.dart';
import '../models/song.dart';

import '../services/theme_provider.dart';

import 'package:provider/provider.dart';

class MusicPlayer extends StatefulWidget {
  final Song currentSong;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final bool isRepeat;
  final bool isShuffle;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onRepeat;
  final VoidCallback onShuffle;
  final Function(double) onSeek;

  const MusicPlayer({
    Key? key,
    required this.currentSong,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.isRepeat,
    required this.isShuffle,
    required this.onPlayPause,
    required this.onNext,
    required this.onPrevious,
    required this.onRepeat,
    required this.onShuffle,
    required this.onSeek,
  }) : super(key: key);


  @override
  _MusicPlayerState createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  String _formatTime(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inMinutes)}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  // --- HÀM TỰ ĐỘNG PHÁT HIỆN NGÔN NGỮ ĐỂ HIỆN LỜI ---
  String _getLyrics(String songTitle) {
    // Regex kiểm tra ký tự tiếng Việt có dấu
    // Nếu tên bài hát chứa các ký tự này -> Là nhạc Việt
    bool isVietnamese = RegExp(r'[àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ]').hasMatch(songTitle.toLowerCase());

    if (isVietnamese) {
      // --- LỜI MẪU TIẾNG VIỆT ---
      return """
(Lời bài hát đang được cập nhật...)

Verse 1:
Hôm qua em đến trường
Mẹ dắt tay từng bước
Hôm nay mẹ lên nương
Một mình em tới lớp...

Chorus:
Trường của em be bé
Nằm lặng giữa rừng cây
Cô giáo em tre trẻ
Dạy em hát rất hay...

(Đây là lời giả lập cho bài hát: "$songTitle")

Verse 2:
Hương rừng thơm đồi vắng
Nước suối trong thầm thì
Cọ xòe ô che nắng
Râm mát đường em đi...
""";
    } else {
      // --- LỜI MẪU TIẾNG ANH (Cho bài không dấu) ---
      return """
(Lyrics are being updated...)

Verse 1:
I'm walking down the street
Thinking 'bout the way we meet
The sun is shining bright
Everything feels so right...

Chorus:
Oh baby, you are the one
Shining like the morning sun
Don't ever let me go
Because I love you so...

(Demo lyrics for: "$songTitle")

Verse 2:
Look at the stars tonight
Everything is gonna be alright
Just take my hand and see
How happy we can be...
""";
    }

  }

  @override
  Widget build(BuildContext context) {

    final theme = Provider.of<ThemeProvider>(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: theme.isDarkMode
              ? [Color(0xFF1a1a2e), Color(0xFF0f3460)]
              : [Colors.white, Colors.grey.shade200],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Nút kéo xuống để đóng
          Container(
            width: 40, height: 4,

            margin: EdgeInsets.only(bottom: 20, top: 10),
            decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(2)),
          ),

          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              children: [
                // TRANG 1: ẢNH BÌA
                Center(
                  child: Container(
                    height: 320,
                    width: 320,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 20, offset: Offset(0, 10))],
                      color: Colors.grey[900],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        widget.currentSong.coverUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(child: Icon(Icons.music_note, size: 100, color: Colors.white24)),
                      ),
                    ),
                  ),
                ),

                // TRANG 2: LỜI BÀI HÁT (THÔNG MINH HƠN)
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: theme.isDarkMode ? Colors.black26 : Colors.white60,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        "Lyrics / Lời bài hát",
                        style: TextStyle(color: theme.textSecondary, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            // Gọi hàm getLyrics đã nâng cấp
                            _getLyrics(widget.currentSong.title),
                            style: TextStyle(
                                color: theme.textPrimary,
                                fontSize: 18,
                                height: 1.6,
                                fontWeight: FontWeight.w500
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDot(0, theme),
              SizedBox(width: 8),
              _buildDot(1, theme),
            ],
          ),
          SizedBox(height: 20),

          // Tên bài hát
          Text(
            widget.currentSong.title,
            style: TextStyle(color: theme.textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 1, overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8),
          Text(
            widget.currentSong.artist,
            style: TextStyle(color: theme.textSecondary, fontSize: 16),
            textAlign: TextAlign.center,
            maxLines: 1, overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 30),

          // Slider
          Slider(
            activeColor: Colors.purpleAccent,
            inactiveColor: Colors.grey.withOpacity(0.3),
            min: 0,
            max: widget.duration.inSeconds.toDouble(),
            value: widget.position.inSeconds.toDouble().clamp(0, widget.duration.inSeconds.toDouble()),
            onChanged: widget.onSeek,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatTime(widget.position), style: TextStyle(color: theme.textSecondary)),
                Text(_formatTime(widget.duration), style: TextStyle(color: theme.textSecondary)),
              ],
            ),
          ),
          SizedBox(height: 10),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(icon: Icon(Icons.shuffle, size: 28), color: widget.isShuffle ? Colors.purpleAccent : theme.iconColor, onPressed: widget.onShuffle),
              IconButton(icon: Icon(Icons.skip_previous, size: 36), color: theme.textPrimary, onPressed: widget.onPrevious),
              Container(
                decoration: BoxDecoration(color: Colors.purpleAccent, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.4), blurRadius: 10, spreadRadius: 2)]),
                child: IconButton(iconSize: 64, icon: Icon(widget.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white), onPressed: widget.onPlayPause),

              ),
              IconButton(icon: Icon(Icons.skip_next, size: 36), color: theme.textPrimary, onPressed: widget.onNext),
              IconButton(icon: Icon(widget.isRepeat ? Icons.repeat_one : Icons.repeat, size: 28), color: widget.isRepeat ? Colors.purpleAccent : theme.iconColor, onPressed: widget.onRepeat),
            ],
          ),

          SizedBox(height: 30),

        ],
      ),
    );
  }

  Widget _buildDot(int index, ThemeProvider theme) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.purpleAccent : theme.iconColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}