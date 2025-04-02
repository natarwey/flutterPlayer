class Playlist {
  final int id;
  final String name;
  final String? coverUrl;

  Playlist({
    required this.id,
    required this.name,
    this.coverUrl,
  });

  factory Playlist.fromMap(Map<String, dynamic> map) {
    return Playlist(
      id: map['id'],
      name: map['name'],
      coverUrl: map['cover_url'],
    );
  }
}