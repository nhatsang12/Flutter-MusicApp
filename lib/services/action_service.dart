// lib/services/action_service.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // Thư viện tải file
import 'package:path_provider/path_provider.dart'; // Thư viện lấy đường dẫn máy
import 'package:permission_handler/permission_handler.dart'; // Thư viện xin quyền
import 'package:share_plus/share_plus.dart'; // Thư viện chia sẻ
import '../models/song.dart';

class ActionService {

  // 1. CHIA SẺ BÀI HÁT
  static void shareSong(Song song) {
    Share.share('Nghe bài hát cực hay: ${song.title} - ${song.artist}\nLink: ${song.url}');
  }

  // 2. TẢI XUỐNG (DOWNLOAD)
  static Future<void> downloadSong(BuildContext context, Song song) async {
    try {
      // 2.1. Xin quyền lưu trữ (Chỉ cần thiết cho Android cũ, Android mới tự xử lý nhưng cứ check cho chắc)
      if (Platform.isAndroid) {
        var status = await Permission.storage.request();
        if (status.isDenied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Vui lòng cấp quyền lưu trữ để tải nhạc!')),
          );
          return;
        }
      }

      // 2.2. Lấy đường dẫn thư mục để lưu
      Directory? dir;
      if (Platform.isAndroid) {
        // Lưu vào thư mục Download công khai hoặc thư mục nhạc của App
        dir = await getExternalStorageDirectory();
      } else {
        // iOS
        dir = await getApplicationDocumentsDirectory();
      }

      if (dir == null) return;

      // Tạo tên file an toàn (bỏ các ký tự đặc biệt)
      String safeTitle = song.title.replaceAll(RegExp(r'[^\w\s]+'), '');
      String savePath = "${dir.path}/$safeTitle.mp3";

      // 2.3. Hiển thị thông báo đang tải
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đang tải xuống: ${song.title}...')),
      );

      // 2.4. Bắt đầu tải bằng Dio
      await Dio().download(song.url, savePath);

      // 2.5. Thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Đã tải xong!')),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      print("File saved to: $savePath");

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải xuống: $e'), backgroundColor: Colors.red),
      );
    }
  }
}