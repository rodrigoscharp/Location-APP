import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacings.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../../auth/presentation/auth_provider.dart';
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
      builder: (_) => const FilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listingsAsync = ref.watch(listingsProvider);
    final filter = ref.watch(listingFilterProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          // ── Header com gradiente ─────────────────────────────
          _Header(user: user, onFilterTap: _showFilters, hasFilter: filter.hasActiveFilters),

          // ── Category chips ───────────────────────────────────
          const SizedBox(height: 4),
          CategoryTabBar(selected: _region, onSelected: _setRegion),
          const SizedBox(height: 4),

          // ── Divisor ──────────────────────────────────────────
          const Divider(height: 1),

          // ── Listings ─────────────────────────────────────────
          Expanded(
            child: listingsAsync.when(
              loading: () => const LoadingShimmer(),
              error: (e, _) => ErrorStateWidget(
                onRetry: () => ref.read(listingsProvider.notifier).refresh(),
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
                  displacement: 20,
                  onRefresh: () =>
                      ref.read(listingsProvider.notifier).refresh(),
                  child: ListView.separated(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                    itemCount: listings.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacings.xl),
                    itemBuilder: (_, i) => ListingCard(
                      listing: listings[i],
                      animationIndex: i,
                      onTap: () =>
                          context.go('/explore/listing/${listings[i].id}'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final dynamic user;
  final VoidCallback onFilterTap;
  final bool hasFilter;

  const _Header({
    required this.user,
    required this.onFilterTap,
    required this.hasFilter,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF5A5F), Color(0xFFFF385C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, top + 18, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bem-vindo a',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: AppColors.white.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ubatuba 🌊',
                      style: GoogleFonts.dmSans(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              // Avatar
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withValues(alpha: 0.2),
                  border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.4), width: 1.5),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.white,
                  size: 22,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Search bar elevado
          GestureDetector(
            onTap: () {},
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 18),
                  const Icon(Icons.search_rounded,
                      color: AppColors.coral, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Para onde você vai?',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        color: AppColors.warmGray,
                      ),
                    ),
                  ),
                  // Filter button
                  GestureDetector(
                    onTap: onFilterTap,
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: hasFilter
                            ? AppColors.coral
                            : AppColors.paleGray,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        size: 18,
                        color: hasFilter
                            ? AppColors.white
                            : AppColors.darkGray,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
