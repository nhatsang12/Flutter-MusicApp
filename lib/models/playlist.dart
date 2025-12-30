import 'song.dart';

class Playlist {
  String id;
  String name;
  List<Song> songs;
  String? userId; // Thêm userId để phân biệt user
  DateTime? lastModified;
  bool isSynced; // Đánh dấu đã sync với server chưa

  Playlist({
    required this.id,
    required this.name,
    required this.songs,
    this.userId,
    this.lastModified,
    this.isSynced = false,
  });

  // Chuyển đổi sang JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'songs': songs.map((s) => s.toJson()).toList(),
    'userId': userId,
    'lastModified': lastModified?.toIso8601String(),
    'isSynced': isSynced,
  };

  // Tạo từ JSON
  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] ?? json['_id'] ?? '', // Hỗ trợ cả MongoDB _id
      name: json['name'] ?? '',
      songs: (json['songs'] as List?)?.map((s) => Song.fromJson(s)).toList() ?? [],
      userId: json['userId'],
      lastModified: json['lastModified'] != null
          ? DateTime.parse(json['lastModified'])
          : null,
      isSynced: json['isSynced'] ?? false,
    );
  }

  // Copy với các thuộc tính mới
  Playlist copyWith({
    String? id,
    String? name,
    List<Song>? songs,
    String? userId,
    DateTime? lastModified,
    bool? isSynced,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      songs: songs ?? this.songs,
      userId: userId ?? this.userId,
      lastModified: lastModified ?? this.lastModified,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}