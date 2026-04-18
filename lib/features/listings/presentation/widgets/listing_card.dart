import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../favorites/presentation/widgets/heart_button.dart';
import '../../domain/listing.dart';
import 'rating_stars.dart';

class ListingCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback onTap;
  final int animationIndex;

  const ListingCard({
    super.key,
    required this.listing,
    required this.onTap,
    this.animationIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Imagem ──────────────────────────────────────────
          Stack(
            children: [
              // Foto principal
              Hero(
                tag: 'listing-img-${listing.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    imageUrl: listing.coverPhoto,
                    height: 265,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: 265,
                      decoration: BoxDecoration(
                        color: AppColors.lightGray,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      height: 265,
                      color: AppColors.paleGray,
                      child: const Icon(Icons.image_outlined,
                          color: AppColors.mediumGray, size: 48),
                    ),
                  ),
                ),
              ),

              // Gradiente inferior
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(20)),
                  child: Container(
                    height: 110,
                    decoration: const BoxDecoration(
                      gradient: AppColors.gradientImage,
                    ),
                  ),
                ),
              ),

              // Badge de preço — sobre a imagem
              Positioned(
                bottom: 14,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: CurrencyFormatter.format(
                              listing.pricePerNight),
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.charcoal,
                          ),
                        ),
                        TextSpan(
                          text: '/noite',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: AppColors.warmGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Botão de favorito
              Positioned(
                top: 12,
                right: 12,
                child: HeartButton(listingId: listing.id),
              ),

              // Badge de tipo
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    listing.type.label,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Info ────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.title,
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.charcoal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${listing.region.emoji} ${listing.region.label}',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: AppColors.warmGray,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              RatingStars(
                rating: listing.avgRating,
                reviewCount: listing.reviewCount,
              ),
            ],
          ),
        ],
      )
          .animate()
          .fadeIn(
            delay: Duration(milliseconds: animationIndex * 50),
            duration: const Duration(milliseconds: 400),
          )
          .slideY(begin: 0.08, end: 0),
    );
  }
}
