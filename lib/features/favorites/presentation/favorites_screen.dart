import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacings.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../../listings/presentation/listings_provider.dart';
import '../../listings/presentation/widgets/listing_card.dart';
import 'favorites_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favIdsAsync = ref.watch(favoriteIdsProvider);

    return Scaffold(
      backgroundColor: AppColors.paleGray,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Favoritos',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.charcoal,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.lightGray),
        ),
      ),
      body: favIdsAsync.when(
        loading: () => const LoadingShimmer(),
        error: (e, _) => const ErrorStateWidget(),
        data: (ids) {
          if (ids.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.favorite_border_rounded,
              title: 'Nenhum favorito ainda',
              subtitle: 'Toque no coração para salvar hospedagens',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            itemCount: ids.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacings.lg),
            itemBuilder: (_, i) {
              final listingAsync = ref.watch(listingDetailProvider(ids[i]));
              return listingAsync.when(
                loading: () => Container(
                  height: 265,
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                error: (_, __) => const SizedBox.shrink(),
                data: (listing) => ListingCard(
                  listing: listing,
                  animationIndex: i,
                  onTap: () => context.go('/explore/listing/${listing.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
