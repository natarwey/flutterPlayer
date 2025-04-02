import 'package:flutter_application_1/database/storage/playlist.dart';
import 'package:flutter_application_1/database/storage/track.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlaylistService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<Playlist>> getPlaylists() async {
    final response = await supabase
        .from('playlists')
        .select('*')
        .order('created_at', ascending: false);
    
    return response.map((p) => Playlist.fromMap(p)).toList();
  }

  Future<List<Track>> getPlaylistTracks(int playlistId) async {
    final response = await supabase
        .from('playlist_tracks')
        .select('track:track_id(*)')
        .eq('playlist_id', playlistId);
    
    return response.map((t) => Track.fromMap(t['track'])).toList();
  }
}