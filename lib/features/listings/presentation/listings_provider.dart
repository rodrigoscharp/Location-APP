import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/supabase_client_provider.dart';
import '../data/listing_repository.dart';
import '../domain/listing.dart';
import '../domain/listing_filter.dart';

final listingRepositoryProvider = Provider<ListingRepository>((ref) {
  return ListingRepository(ref.watch(supabaseClientProvider));
});

final listingFilterProvider = StateProvider<ListingFilter>((ref) {
  return const ListingFilter();
});

class ListingsNotifier extends StateNotifier<AsyncValue<List<Listing>>> {
  final ListingRepository _repo;
  final ListingFilter _filter;

  int _page = 0;
  bool _hasMore = true;
  static const _pageSize = 10;

  ListingsNotifier(this._repo, this._filter)
      : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    _page = 0;
    _hasMore = true;
    try {
      final listings =
          await _repo.getListings(filter: _filter, page: 0, pageSize: _pageSize);
      _hasMore = listings.length == _pageSize;
      state = AsyncValue.data(listings);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => _load();

  Future<void> loadMore() async {
    if (!_hasMore) return;
    final current = state.valueOrNull ?? [];
    _page++;
    try {
      final more = await _repo.getListings(
          filter: _filter, page: _page, pageSize: _pageSize);
      _hasMore = more.length == _pageSize;
      state = AsyncValue.data([...current, ...more]);
    } catch (_) {
      _page--;
    }
  }
}

final listingsProvider =
    StateNotifierProvider<ListingsNotifier, AsyncValue<List<Listing>>>((ref) {
  final filter = ref.watch(listingFilterProvider);
  final repo = ref.watch(listingRepositoryProvider);
  return ListingsNotifier(repo, filter);
});

final listingDetailProvider =
    FutureProvider.family<Listing, String>((ref, id) {
  return ref.watch(listingRepositoryProvider).getListingById(id);
});
