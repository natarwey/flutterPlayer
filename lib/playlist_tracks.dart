import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/database/storage/playlist_service.dart';
import 'package:flutter_application_1/database/storage/track.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/music/player.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlaylistTracksPage extends StatefulWidget {
  final int playlistId;

  const PlaylistTracksPage({super.key, required this.playlistId});

  @override
  State<PlaylistTracksPage> createState() => _PlaylistTracksPageState();
}

class _PlaylistTracksPageState extends State<PlaylistTracksPage> {
  final PlaylistService _playlistService = PlaylistService();
  List<Track> tracks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTracks();
  }

  Future<void> _loadTracks() async {
    try {
      final loadedTracks = await _playlistService.getPlaylistTracks(widget.playlistId);
      setState(() {
        tracks = loadedTracks;
      });
    } catch (e) {
      print('Error loading playlist tracks: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Треки плейлиста'),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : tracks.isEmpty
                ? const Center(child: Text('Нет треков в плейлисте'))
                : ListView.builder(
                    itemCount: tracks.length,
                    itemBuilder: (context, index) {
                      final track = tracks[index];
                      return ListTile(
                        leading: track.imageUrl.isNotEmpty
                            ? Image.network(track.imageUrl, width: 50, height: 50)
                            : const Icon(Icons.music_note),
                        title: Text(track.name),
                        subtitle: FutureBuilder(
                          future: _getAuthorName(track.authorId),
                          builder: (ctx, snapshot) {
                            return Text(snapshot.data ?? 'Unknown Artist');
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (_) => PlayerPage(
                                nameSound: track.name,
                                author: snapshot.data ?? 'Unknown Artist',
                                urlMusic: track.musicUrl,
                                urlPhoto: track.imageUrl,
                                onBack: () {},
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
      ),
    );
  }

  Future<String> _getAuthorName(int authorId) async {
    final response = await Supabase.instance.client
        .from('author')
        .select('name')
        .eq('id', authorId)
        .single();
    return response['name'] as String;
  }
}