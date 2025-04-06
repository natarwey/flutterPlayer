import 'package:flutter/material.dart';
import 'package:flutter_application_1/database/storage/track.dart';

class TrackListItem extends StatelessWidget {
  final Track track;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;
  final VoidCallback onTap;

  const TrackListItem({
    super.key,
    required this.track,
    required this.isFavorite,
    this.onToggleFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: track.imageUrl.isNotEmpty
          ? Image.network(track.imageUrl, width: 50, height: 50)
          : const Icon(Icons.music_note),
      title: Text(track.name),
      subtitle: Text(track.artistName ?? 'Unknown Artist'),
      trailing: IconButton(
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? Colors.red : Colors.white,
        ),
        onPressed: onToggleFavorite,
      ),
      onTap: onTap,
    );
  }
}