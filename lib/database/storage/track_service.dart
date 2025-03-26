import 'package:flutter_application_1/database/storage/track.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TrackService {
  final SupabaseClient _supabase;

  TrackService() : _supabase = Supabase.instance.client;

  Future<List<Track>> getTracks() async {
    try {
      final response = await _supabase
          .from('track')
          .select('*')
          .order('created_at', ascending: false);

      return response.map((json) => Track.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load tracks: $e');
    }
  }

  Future<List<Track>> getTracksByAuthor(int authorId) async {
    final response = await _supabase
        .from('track')
        .select('*')
        .eq('author_id', authorId);
    
    return response.map((json) => Track.fromJson(json)).toList();
  }
}