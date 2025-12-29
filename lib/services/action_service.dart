// lib/services/action_service.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/song.dart';
import 'download_manager.dart'; // <--- Import mới

class ActionService {

  static Future<void> downloadSong(BuildContext context, Song song) async {
    if (song.url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: Link nhạc rỗng')));
      return;
    }

    // Kiểm tra xem bài này đã tải chưa (để tránh tải lại)
    List<Song> downloaded = await DownloadManager.getDownloadedSongs();
    if (downloaded.any((s) => s.id == song.id)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bài hát này đã được tải rồi!')));
      return;
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [CircularProgressIndicator(color: Colors.white, strokeWidth: 2), SizedBox(width: 10), Text('Đang tải "${song.title}"...')]),
        duration: Duration(seconds: 10),
      ));

      final response = await http.get(Uri.parse(song.url));

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final folderPath = '${directory.path}/songs';
        final savePath = '$folderPath/${song.id}.mp3';

        await Directory(folderPath).create(recursive: true);
        final file = File(savePath);
        await file.writeAsBytes(response.bodyBytes);

        // --- LƯU VÀO DANH SÁCH ĐÃ TẢI ---
        await DownloadManager.addSong(song, savePath);
        // -------------------------------

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('✅ Đã tải xong!'),
          backgroundColor: Colors.green,
        ));

      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tải thất bại: $e'), backgroundColor: Colors.red));
    }
  }

  static void shareSong(Song song) {
    if (song.url.isNotEmpty) {
      Share.share('Nghe bài hát ${song.title} của ${song.artist} tại: ${song.url}');
    }
  }
}