import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/listing.dart';
import '../domain/listing_filter.dart';

class ListingRepository {
  final SupabaseClient _client;

  ListingRepository(this._client);

  static const _select = '''
    *,
    listing_photos(url, position),
    listing_ratings(avg_rating, review_count),
    profiles!listings_host_id_fkey(full_name, avatar_url)
  ''';

  Future<List<Listing>> getListings({
    ListingFilter? filter,
    int page = 0,
    int pageSize = 10,
  }) async {
    var query = _client
        .from('listings')
        .select(_select)
        .eq('is_active', true);

    if (filter?.region != null) {
      query = query.eq('region', filter!.region!.name);
    }
    if (filter?.type != null) {
      query = query.eq('type', filter!.type!.name);
    }
    if (filter?.minPrice != null) {
      query = query.gte('price_per_night', filter!.minPrice!);
    }
    if (filter?.maxPrice != null) {
      query = query.lte('price_per_night', filter!.maxPrice!);
    }
    if (filter?.minGuests != null) {
      query = query.gte('max_guests', filter!.minGuests!);
    }

    final data = await query
        .order('created_at', ascending: false)
        .range(page * pageSize, (page + 1) * pageSize - 1);

    return (data as List).map((j) => Listing.fromJson(j)).toList();
  }

  Future<Listing> getListingById(String id) async {
    final data = await _client
        .from('listings')
        .select(_select)
        .eq('id', id)
        .single();

    return Listing.fromJson(data);
  }

  Future<List<Listing>> getListingsWithLocation() async {
    final data = await _client
        .from('listings')
        .select('id, title, price_per_night, lat, lng, region, listing_photos(url, position)')
        .eq('is_active', true)
        .not('lat', 'is', null)
        .not('lng', 'is', null);

    return (data as List).map((j) => Listing.fromJson(j)).toList();
  }
}
