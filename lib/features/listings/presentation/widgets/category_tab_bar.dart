import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/listing.dart';

class CategoryTabBar extends StatelessWidget {
  final ListingRegion? selected;
  final ValueChanged<ListingRegion?> onSelected;

  const CategoryTabBar({
    super.key,
    this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _Chip(
            label: 'Tudo',
            emoji: '🌴',
            selected: selected == null,
            onTap: () => onSelected(null),
          ),
          _Chip(
            label: 'Praia',
            emoji: '🏖️',
            selected: selected == ListingRegion.praia,
            onTap: () => onSelected(ListingRegion.praia),
          ),
          _Chip(
            label: 'Centro',
            emoji: '🏙️',
            selected: selected == ListingRegion.centro,
            onTap: () => onSelected(ListingRegion.centro),
          ),
          _Chip(
            label: 'Serra',
            emoji: '⛰️',
            selected: selected == ListingRegion.montanha,
            onTap: () => onSelected(ListingRegion.montanha),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.charcoal : AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? AppColors.charcoal : AppColors.lightGray,
            width: selected ? 0 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.charcoal.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.white : AppColors.darkGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
