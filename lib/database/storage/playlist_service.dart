import 'package:flutter_application_1/database/storage/playlist.dart';
import 'package:flutter_application_1/database/storage/track.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlaylistService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<Playlist>> getPlaylists() async {
    final response = await supabase
        .from('list')
        .select('*')
        .order('created_at', ascending: false);
    
    return response.map<Playlist>((p) => Playlist.fromMap(p)).toList();
  }

  Future<List<Track>> getPlaylistTracks(int playlistId) async {
    final response = await supabase
        .from('play_list')
        .select('track:track_id(*)')
        .eq('list_id', playlistId);
    
    return response.map<Track>((t) => Track.fromMap(t['track'])).toList();
  }
}