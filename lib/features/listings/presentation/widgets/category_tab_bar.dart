import 'package:flutter/material.dart';
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
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _CategoryChip(
            label: 'Todos',
            emoji: '🌴',
            selected: selected == null,
            onTap: () => onSelected(null),
          ),
          ...ListingRegion.values.map((region) => _CategoryChip(
                label: region.label,
                emoji: region.emoji,
                selected: selected == region,
                onTap: () => onSelected(region),
              )),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.coral : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.coral : AppColors.lightGray,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.white : AppColors.charcoal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
