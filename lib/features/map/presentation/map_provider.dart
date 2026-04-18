import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/supabase_client_provider.dart';
import '../../listings/domain/listing.dart';
import '../data/map_repository.dart';

final mapRepositoryProvider = Provider<MapRepository>((ref) {
  return MapRepository(ref.watch(supabaseClientProvider));
});

final mapListingsProvider = FutureProvider<List<Listing>>((ref) {
  return ref.watch(mapRepositoryProvider).getListingsWithCoordinates();
});

final selectedMapListingProvider = StateProvider<Listing?>((ref) => null);
