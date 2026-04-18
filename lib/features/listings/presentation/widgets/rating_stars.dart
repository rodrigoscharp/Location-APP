import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      return Text(
        'Novo',
        style: GoogleFonts.dmSans(
          fontSize: size - 1,
          color: AppColors.warmGray,
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, size: size + 1, color: AppColors.starYellow),
        const SizedBox(width: 3),
        Text(
          rating!.toStringAsFixed(1),
          style: GoogleFonts.dmSans(
            fontSize: size,
            fontWeight: FontWeight.w700,
            color: AppColors.charcoal,
          ),
        ),
        if (showCount && reviewCount > 0) ...[
          const SizedBox(width: 2),
          Text(
            '($reviewCount)',
            style: GoogleFonts.dmSans(
              fontSize: size - 1,
              color: AppColors.warmGray,
            ),
          ),
        ],
      ],
    );
  }
}
