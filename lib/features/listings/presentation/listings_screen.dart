import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacings.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../../listings/domain/listing.dart';
import '../../listings/domain/listing_filter.dart';
import 'listings_provider.dart';
import 'widgets/category_tab_bar.dart';
import 'widgets/filter_bottom_sheet.dart';
import 'widgets/listing_card.dart';

class ListingsScreen extends ConsumerStatefulWidget {
  const ListingsScreen({super.key});

  @override
  ConsumerState<ListingsScreen> createState() => _ListingsScreenState();
}

class _ListingsScreenState extends ConsumerState<ListingsScreen> {
  final _scrollCtrl = ScrollController();
  ListingRegion? _region;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 300) {
      ref.read(listingsProvider.notifier).loadMore();
    }
  }

  void _setRegion(ListingRegion? region) {
    setState(() => _region = region);
    final current = ref.read(listingFilterProvider);
    ref.read(listingFilterProvider.notifier).state = ListingFilter(
      region: region,
      type: current.type,
      minPrice: current.minPrice,
      maxPrice: current.maxPrice,
      minGuests: current.minGuests,
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const FilterBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listingsAsync = ref.watch(listingsProvider);
    final filter = ref.watch(listingFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacings.base, AppSpacings.base, AppSpacings.base, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          const Icon(Icons.search, color: AppColors.warmGray, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Buscar em Ubatuba...',
                            style: TextStyle(color: AppColors.warmGray, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: _showFilters,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: filter.hasActiveFilters
                                ? AppColors.coral
                                : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(
                            Icons.tune_rounded,
                            color: filter.hasActiveFilters
                                ? AppColors.white
                                : AppColors.charcoal,
                            size: 22,
                          ),
                        ),
                      ),
                      if (filter.hasActiveFilters)
                        Positioned(
                          right: 2,
                          top: 2,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: AppColors.teal,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacings.sm),
            // Category tabs
            CategoryTabBar(
              selected: _region,
              onSelected: _setRegion,
            ),
            // Listings
            Expanded(
              child: listingsAsync.when(
                loading: () => const LoadingShimmer(),
                error: (e, _) => ErrorStateWidget(
                  onRetry: () =>
                      ref.read(listingsProvider.notifier).refresh(),
                ),
                data: (listings) {
                  if (listings.isEmpty) {
                    return const EmptyStateWidget(
                      icon: Icons.search_off_rounded,
                      title: 'Nenhuma hospedagem encontrada',
                      subtitle: 'Tente outros filtros ou categorias',
                    );
                  }
                  return RefreshIndicator(
                    color: AppColors.coral,
                    onRefresh: () =>
                        ref.read(listingsProvider.notifier).refresh(),
                    child: ListView.separated(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacings.base, AppSpacings.sm,
                          AppSpacings.base, AppSpacings.xl),
                      itemCount: listings.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacings.lg),
                      itemBuilder: (_, i) => ListingCard(
                        listing: listings[i],
                        animationIndex: i,
                        onTap: () => context.go(
                            '/explore/listing/${listings[i].id}'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
