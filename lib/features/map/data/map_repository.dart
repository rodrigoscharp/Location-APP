import 'package:supabase_flutter/supabase_flutter.dart';
import '../../listings/domain/listing.dart';

class MapRepository {
  final SupabaseClient _client;

  MapRepository(this._client);

  Future<List<Listing>> getListingsWithCoordinates() async {
    final data = await _client
        .from('listings')
        .select('''
          id, title, price_per_night, lat, lng, region, type,
          listing_photos(url, position)
        ''')
        .eq('is_active', true)
        .not('lat', 'is', null)
        .not('lng', 'is', null);

    return (data as List).map((j) {
      // Minimal listing for map pins
      final photosRaw = j['listing_photos'] as List<dynamic>? ?? [];
      final photoUrls = photosRaw.map((p) => p['url'] as String).toList();
      return Listing(
        id: j['id'] as String,
        hostId: '',
        title: j['title'] as String,
        type: ListingType.values.firstWhere(
          (e) => e.name == j['type'],
          orElse: () => ListingType.pousada,
        ),
        region: ListingRegion.values.firstWhere(
          (e) => e.name == j['region'],
          orElse: () => ListingRegion.praia,
        ),
        lat: (j['lat'] as num).toDouble(),
        lng: (j['lng'] as num).toDouble(),
        pricePerNight: (j['price_per_night'] as num).toDouble(),
        photoUrls: photoUrls,
        createdAt: DateTime.now(),
      );
    }).toList();
  }
}
