import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../listings/domain/listing.dart';
import '../../../listings/presentation/widgets/rating_stars.dart';

class MapListingBottomCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const MapListingBottomCard({
    super.key,
    required this.listing,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(20)),
              child: CachedNetworkImage(
                imageUrl: listing.coverPhoto,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    Container(width: 100, color: AppColors.lightGray),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    listing.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${listing.region.emoji} ${listing.region.label} · ${listing.type.label}',
                    style: const TextStyle(
                        color: AppColors.warmGray, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  RatingStars(
                      rating: listing.avgRating,
                      reviewCount: listing.reviewCount,
                      size: 12),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: CurrencyFormatter.format(
                              listing.pricePerNight),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.charcoal,
                            fontSize: 15,
                          ),
                        ),
                        const TextSpan(
                          text: '/noite',
                          style: TextStyle(
                              color: AppColors.warmGray, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close, size: 18, color: AppColors.warmGray),
            ),
          ],
        ),
      ),
    );
  }
}
