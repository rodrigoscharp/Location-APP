import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacings.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../favorites/presentation/widgets/heart_button.dart';
import '../../listings/domain/listing.dart';
import 'listings_provider.dart';
import 'widgets/rating_stars.dart';

class ListingDetailScreen extends ConsumerWidget {
  final String listingId;

  const ListingDetailScreen({super.key, required this.listingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingAsync = ref.watch(listingDetailProvider(listingId));

    return listingAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator(color: AppColors.coral)),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: ErrorStateWidget(onRetry: () => ref.invalidate(listingDetailProvider(listingId))),
      ),
      data: (listing) => _ListingDetailView(listing: listing),
    );
  }
}

class _ListingDetailView extends StatefulWidget {
  final Listing listing;
  const _ListingDetailView({required this.listing});

  @override
  State<_ListingDetailView> createState() => _ListingDetailViewState();
}

class _ListingDetailViewState extends State<_ListingDetailView> {
  final _pageCtrl = PageController();
  int _photoIndex = 0;

  Listing get listing => widget.listing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Photo gallery app bar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.charcoal,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new, size: 16),
              ),
              onPressed: () => context.pop(),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: HeartButton(
                  listingId: listing.id,
                  showBackground: true,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Photo PageView
                  if (listing.photoUrls.isNotEmpty)
                    PageView.builder(
                      controller: _pageCtrl,
                      itemCount: listing.photoUrls.length,
                      onPageChanged: (i) => setState(() => _photoIndex = i),
                      itemBuilder: (_, i) => Hero(
                        tag: i == 0 ? 'listing-img-${listing.id}' : 'photo-$i',
                        child: CachedNetworkImage(
                          imageUrl: listing.photoUrls[i],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (_, __) =>
                              Container(color: AppColors.lightGray),
                          errorWidget: (_, __, ___) =>
                              Container(color: AppColors.lightGray),
                        ),
                      ),
                    )
                  else
                    Hero(
                      tag: 'listing-img-${listing.id}',
                      child: CachedNetworkImage(
                        imageUrl: listing.coverPhoto,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  // Photo indicator dots
                  if (listing.photoUrls.length > 1)
                    Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          listing.photoUrls.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: i == _photoIndex ? 20 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: i == _photoIndex
                                  ? AppColors.white
                                  : AppColors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacings.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + region
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          listing.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.charcoal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.sand,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${listing.region.emoji} ${listing.region.label}',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(listing.type.label),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  RatingStars(
                    rating: listing.avgRating,
                    reviewCount: listing.reviewCount,
                    size: 16,
                  ),
                  const Divider(height: 32),

                  // Details row
                  Row(
                    children: [
                      _InfoChip(
                          icon: Icons.person_outline,
                          label: '${listing.maxGuests} hóspedes'),
                      const SizedBox(width: 12),
                      _InfoChip(
                          icon: Icons.bed_outlined,
                          label: '${listing.bedrooms} quarto${listing.bedrooms > 1 ? 's' : ''}'),
                      const SizedBox(width: 12),
                      _InfoChip(
                          icon: Icons.bathroom_outlined,
                          label: '${listing.bathrooms} banheiro${listing.bathrooms > 1 ? 's' : ''}'),
                    ],
                  ),
                  const Divider(height: 32),

                  // Description
                  if (listing.description != null) ...[
                    const Text(
                      'Sobre a hospedagem',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      listing.description!,
                      style: const TextStyle(
                          color: AppColors.warmGray,
                          height: 1.6,
                          fontSize: 15),
                    ),
                    const Divider(height: 32),
                  ],

                  // Amenities
                  if (listing.amenities.isNotEmpty) ...[
                    const Text(
                      'O que esse lugar oferece',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: listing.amenities.map((a) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.lightGray),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(amenityIcons[a] ?? '✓',
                                  style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(
                                amenityLabels[a] ?? a,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const Divider(height: 32),
                  ],

                  // Host card
                  const Text(
                    'Anfitrião',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.lightGray,
                        backgroundImage: listing.hostAvatarUrl != null
                            ? CachedNetworkImageProvider(listing.hostAvatarUrl!)
                            : null,
                        child: listing.hostAvatarUrl == null
                            ? const Icon(Icons.person_outline,
                                color: AppColors.warmGray)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            listing.hostName ?? 'Anfitrião',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                          const Text(
                            'Anfitrião verificado',
                            style: TextStyle(
                                color: AppColors.warmGray, fontSize: 13),
                          ),
                        ],
                      ),
                      const Spacer(),
                      OutlinedButton(
                        onPressed: () {
                          // Navigate to chat with host
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Abrindo chat com anfitrião...')),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                        child: const Text('Mensagem'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 100), // space for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),

      // Sticky bottom bar
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          AppSpacings.base,
          AppSpacings.sm,
          AppSpacings.base,
          MediaQuery.of(context).padding.bottom + AppSpacings.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: CurrencyFormatter.format(listing.pricePerNight),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.charcoal,
                        ),
                      ),
                      const TextSpan(
                        text: ' /noite',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.warmGray,
                        ),
                      ),
                    ],
                  ),
                ),
                if (listing.avgRating != null)
                  RatingStars(
                      rating: listing.avgRating,
                      reviewCount: listing.reviewCount,
                      size: 13),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () =>
                  context.push('${GoRouterState.of(context).uri}/checkout'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 28),
              ),
              child: const Text('Reservar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.warmGray),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: AppColors.warmGray, fontSize: 13)),
      ],
    );
  }
}
