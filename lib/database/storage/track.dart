class Track {
  final int id;
  final String name;
  final String imageUrl;
  final String musicUrl;
  final int genreId;
  final int authorId;
  final DateTime createdAt;

  Track({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.musicUrl,
    required this.genreId,
    required this.authorId,
    required this.createdAt,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'] as int,
      name: json['name'] as String,
      imageUrl: json['image'] as String,
      musicUrl: json['url_music'] as String,
      genreId: json['genre_id'] as int,
      authorId: json['author_id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}