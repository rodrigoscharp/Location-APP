import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritesRepository {
  final SupabaseClient _client;

  FavoritesRepository(this._client);

  Stream<List<String>> watchFavoriteIds(String userId) {
    return _client
        .from('user_favorites')
        .stream(primaryKey: ['user_id', 'listing_id'])
        .eq('user_id', userId)
        .map((rows) => rows.map((r) => r['listing_id'] as String).toList());
  }

  Future<List<String>> getFavoriteIds(String userId) async {
    final data = await _client
        .from('user_favorites')
        .select('listing_id')
        .eq('user_id', userId);
    return (data as List).map((r) => r['listing_id'] as String).toList();
  }

  Future<void> addFavorite(String userId, String listingId) async {
    await _client.from('user_favorites').insert({
      'user_id': userId,
      'listing_id': listingId,
    });
  }

  Future<void> removeFavorite(String userId, String listingId) async {
    await _client
        .from('user_favorites')
        .delete()
        .eq('user_id', userId)
        .eq('listing_id', listingId);
  }

  Future<void> toggle(String userId, String listingId, bool isFavorite) async {
    if (isFavorite) {
      await removeFavorite(userId, listingId);
    } else {
      await addFavorite(userId, listingId);
    }
  }
}
