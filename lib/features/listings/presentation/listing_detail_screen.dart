import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
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
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.coral)),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: ErrorStateWidget(
          onRetry: () => ref.invalidate(listingDetailProvider(listingId)),
        ),
      ),
      data: (listing) => _DetailView(listing: listing),
    );
  }
}

class _DetailView extends StatefulWidget {
  final Listing listing;
  const _DetailView({required this.listing});

  @override
  State<_DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends State<_DetailView> {
  final _pageCtrl = PageController();
  int _photoIndex = 0;

  Listing get l => widget.listing;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        slivers: [
          // ── Galeria de fotos ─────────────────────────────
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.charcoal,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.12),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.arrow_back_ios_new,
                      size: 15, color: AppColors.charcoal),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.12),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Center(
                    child: HeartButton(
                      listingId: l.id,
                      size: 18,
                      showBackground: false,
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Fotos
                  l.photoUrls.length > 1
                      ? PageView.builder(
                          controller: _pageCtrl,
                          itemCount: l.photoUrls.length,
                          onPageChanged: (i) =>
                              setState(() => _photoIndex = i),
                          itemBuilder: (_, i) => Hero(
                            tag: i == 0 ? 'listing-img-${l.id}' : 'photo-$i',
                            child: CachedNetworkImage(
                              imageUrl: l.photoUrls[i],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              placeholder: (_, __) =>
                                  Container(color: AppColors.lightGray),
                              errorWidget: (_, __, ___) =>
                                  Container(color: AppColors.lightGray),
                            ),
                          ),
                        )
                      : Hero(
                          tag: 'listing-img-${l.id}',
                          child: CachedNetworkImage(
                            imageUrl: l.coverPhoto,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),

                  // Indicadores de foto
                  if (l.photoUrls.length > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          l.photoUrls.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: i == _photoIndex ? 20 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: i == _photoIndex
                                  ? AppColors.white
                                  : AppColors.white.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Counter de fotos
                  if (l.photoUrls.length > 1)
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_photoIndex + 1}/${l.photoUrls.length}',
                          style: GoogleFonts.dmSans(
                            color: AppColors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Conteúdo ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tags de tipo e região
                  Row(
                    children: [
                      _Tag(label: l.type.label, dark: true),
                      const SizedBox(width: 8),
                      _Tag(label: '${l.region.emoji} ${l.region.label}'),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Título
                  Text(
                    l.title,
                    style: GoogleFonts.dmSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.charcoal,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Rating + address
                  Row(
                    children: [
                      RatingStars(
                        rating: l.avgRating,
                        reviewCount: l.reviewCount,
                        size: 14,
                      ),
                      if (l.address != null) ...[
                        const SizedBox(width: 10),
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: AppColors.warmGray),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            l.address!,
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: AppColors.warmGray,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),

                  // Capacidade
                  Row(
                    children: [
                      _InfoItem(
                        icon: Icons.person_outline_rounded,
                        label: '${l.maxGuests} hóspedes',
                      ),
                      const SizedBox(width: 20),
                      _InfoItem(
                        icon: Icons.bed_outlined,
                        label: '${l.bedrooms} quarto${l.bedrooms > 1 ? 's' : ''}',
                      ),
                      const SizedBox(width: 20),
                      _InfoItem(
                        icon: Icons.bathroom_outlined,
                        label: '${l.bathrooms} banheiro${l.bathrooms > 1 ? 's' : ''}',
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(),

                  // Descrição
                  if (l.description != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Sobre este lugar',
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.charcoal,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l.description!,
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        color: AppColors.darkGray,
                        height: 1.65,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                  ],

                  // Comodidades
                  if (l.amenities.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'O que esse lugar oferece',
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 3.5,
                      children: l.amenities.map((a) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.lightGray),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text(amenityIcons[a] ?? '✓',
                                  style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  amenityLabels[a] ?? a,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.darkGray,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                  ],

                  // Host card
                  const SizedBox(height: 20),
                  Text(
                    'Anfitrião',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.lightGray),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.paleGray,
                          backgroundImage: l.hostAvatarUrl != null
                              ? CachedNetworkImageProvider(l.hostAvatarUrl!)
                              : null,
                          child: l.hostAvatarUrl == null
                              ? Text(
                                  (l.hostName ?? 'A')[0].toUpperCase(),
                                  style: GoogleFonts.dmSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.coral,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l.hostName ?? 'Anfitrião',
                                style: GoogleFonts.dmSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                'Anfitrião verificado ✓',
                                style: GoogleFonts.dmSans(
                                  color: AppColors.teal,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                          ),
                          child: Text(
                            'Mensagem',
                            style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 100 + bottomPad),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Bottom bar de reserva ─────────────────────────────
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(
              top: BorderSide(color: AppColors.lightGray.withValues(alpha: 0.8))),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(20, 14, 20, bottomPad + 14),
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
                        text: CurrencyFormatter.format(l.pricePerNight),
                        style: GoogleFonts.dmSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.charcoal,
                        ),
                      ),
                      TextSpan(
                        text: ' /noite',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: AppColors.warmGray,
                        ),
                      ),
                    ],
                  ),
                ),
                if (l.avgRating != null)
                  RatingStars(
                    rating: l.avgRating,
                    reviewCount: l.reviewCount,
                    size: 12,
                  ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => context
                  .push('${GoRouterState.of(context).uri}/checkout'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 16),
              ),
              child: Text(
                'Reservar',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final bool dark;

  const _Tag({required this.label, this.dark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: dark ? AppColors.charcoal : AppColors.paleGray,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: dark ? AppColors.white : AppColors.darkGray,
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.warmGray),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: AppColors.warmGray,
          ),
        ),
      ],
    );
  }
}
