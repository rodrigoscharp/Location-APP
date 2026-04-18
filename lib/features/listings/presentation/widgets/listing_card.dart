import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
          // Image with Hero + heart button
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Hero(
                  tag: 'listing-img-${listing.id}',
                  child: CachedNetworkImage(
                    imageUrl: listing.coverPhoto,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: 220,
                      color: AppColors.lightGray,
                    ),
                    errorWidget: (_, __, ___) => Container(
                      height: 220,
                      color: AppColors.lightGray,
                      child: const Icon(Icons.image_not_supported_outlined,
                          color: AppColors.warmGray, size: 40),
                    ),
                  ),
                ),
              ),
              // Region badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${listing.region.emoji} ${listing.region.label}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoal,
                    ),
                  ),
                ),
              ),
              // Heart button
              Positioned(
                top: 10,
                right: 10,
                child: HeartButton(listingId: listing.id),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Info row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.charcoal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      listing.type.label,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.warmGray,
                      ),
                    ),
                  ],
                ),
              ),
              RatingStars(
                rating: listing.avgRating,
                reviewCount: listing.reviewCount,
              ),
            ],
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: CurrencyFormatter.format(listing.pricePerNight),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
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
        ],
      )
          .animate()
          .fadeIn(delay: (animationIndex * 60).ms, duration: 350.ms)
          .slideY(begin: 0.15, end: 0),
    );
  }
}
