import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class RatingStars extends StatelessWidget {
  final double? rating;
  final int reviewCount;
  final double size;
  final bool showCount;

  const RatingStars({
    super.key,
    this.rating,
    this.reviewCount = 0,
    this.size = 13,
    this.showCount = true,
  });

  @override
  Widget build(BuildContext context) {
    if (rating == null) {
      return const Text('Novo', style: TextStyle(fontSize: 12, color: AppColors.warmGray));
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, size: size, color: AppColors.starYellow),
        const SizedBox(width: 2),
        Text(
          rating!.toStringAsFixed(1),
          style: TextStyle(
            fontSize: size - 1,
            fontWeight: FontWeight.w600,
            color: AppColors.charcoal,
          ),
        ),
        if (showCount && reviewCount > 0) ...[
          const SizedBox(width: 2),
          Text(
            '($reviewCount)',
            style: TextStyle(fontSize: size - 1, color: AppColors.warmGray),
          ),
        ],
      ],
    );
  }
}
