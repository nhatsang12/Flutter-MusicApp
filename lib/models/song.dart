class Song {
  final String id;
  final String title;
  final String artist;
  final String url;
  final String coverUrl;
  final String duration;
  final String? album;
  final int? durationInSeconds;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.url,
    required this.coverUrl,
    required this.duration,
    this.album,
    this.durationInSeconds,
  });

  factory Song.fromJamendo(Map<String, dynamic> json) {
    int durationSeconds = int.tryParse(json['duration'].toString()) ?? 0;
    String duration = '${durationSeconds ~/ 60}:${(durationSeconds % 60).toString().padLeft(2, '0')}';

    return Song(
      id: json['id'].toString(),
      title: json['name'] ?? 'Unknown',
      artist: json['artist_name'] ?? 'Unknown Artist',
      url: json['audio'] ?? '',
      coverUrl: json['image'] ?? 'https://via.placeholder.com/300',
      duration: duration,
      album: json['album_name'],
      durationInSeconds: durationSeconds,
    );
  }

  factory Song.fromDeezer(Map<String, dynamic> json) {
    int durationSeconds = json['duration'] ?? 0;
    String duration = '${durationSeconds ~/ 60}:${(durationSeconds % 60).toString().padLeft(2, '0')}';

    return Song(
      id: json['id'].toString(),
      title: json['title'] ?? 'Unknown',
      artist: json['artist']?['name'] ?? 'Unknown Artist',
      url: json['preview'] ?? '',
      coverUrl: json['album']?['cover_big'] ?? 'https://via.placeholder.com/300',
      duration: duration,
      album: json['album']?['title'],
      durationInSeconds: durationSeconds,
    );
  }

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'].toString(),
      title: json['title'] ?? 'Unknown',
      artist: json['artist'] ?? 'Unknown Artist',
      url: json['url'] ?? '',
      coverUrl: json['cover'] ?? 'https://via.placeholder.com/300',
      duration: json['duration'] ?? '0:00',
      album: json['album'],
    );
  }

  // THÊM METHOD NÀY ⬇️
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'url': url,
      'cover': coverUrl,
      'duration': duration,
      'album': album,
    };
  }
}