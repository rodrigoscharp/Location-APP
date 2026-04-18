import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/supabase_client_provider.dart';
import '../../auth/presentation/auth_provider.dart';
import '../data/favorites_repository.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository(ref.watch(supabaseClientProvider));
});

final favoriteIdsProvider = StreamProvider<List<String>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(favoritesRepositoryProvider).watchFavoriteIds(user.id);
});

final isFavoriteProvider = Provider.family<bool, String>((ref, listingId) {
  final favs = ref.watch(favoriteIdsProvider).valueOrNull ?? [];
  return favs.contains(listingId);
});

class FavoritesNotifier extends StateNotifier<bool> {
  final FavoritesRepository _repo;
  final String userId;

  FavoritesNotifier(this._repo, this.userId) : super(false);

  Future<void> toggle(String listingId, bool currentlyFavorite) async {
    await _repo.toggle(userId, listingId, currentlyFavorite);
  }
}

final favoritesNotifierProvider =
    StateNotifierProvider<FavoritesNotifier, bool>((ref) {
  final user = ref.watch(currentUserProvider);
  final repo = ref.watch(favoritesRepositoryProvider);
  return FavoritesNotifier(repo, user?.id ?? '');
});
