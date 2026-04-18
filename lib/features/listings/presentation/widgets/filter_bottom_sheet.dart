import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacings.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../domain/listing.dart';
import '../../domain/listing_filter.dart';
import '../listings_provider.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late ListingFilter _filter;
  late RangeValues _priceRange;

  @override
  void initState() {
    super.initState();
    _filter = ref.read(listingFilterProvider);
    _priceRange = RangeValues(
      _filter.minPrice ?? 100,
      _filter.maxPrice ?? 2000,
    );
  }

  void _apply() {
    ref.read(listingFilterProvider.notifier).state = ListingFilter(
      region: _filter.region,
      type: _filter.type,
      minPrice: _priceRange.start > 100 ? _priceRange.start : null,
      maxPrice: _priceRange.end < 2000 ? _priceRange.end : null,
      minGuests: _filter.minGuests,
    );
    Navigator.pop(context);
  }

  void _clear() {
    ref.read(listingFilterProvider.notifier).state = const ListingFilter();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacings.base),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacings.base),
          Row(
            children: [
              const Text('Filtros', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const Spacer(),
              TextButton(
                onPressed: _clear,
                child: const Text('Limpar', style: TextStyle(color: AppColors.coral)),
              ),
            ],
          ),
          const Divider(),
          // Type filter
          const Text('Tipo de hospedagem', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacings.sm),
          Wrap(
            spacing: 8,
            children: ListingType.values.map((type) {
              final selected = _filter.type == type;
              return FilterChip(
                label: Text(type.label),
                selected: selected,
                onSelected: (v) => setState(() {
                  _filter = ListingFilter(
                    region: _filter.region,
                    type: v ? type : null,
                    minGuests: _filter.minGuests,
                  );
                }),
                selectedColor: AppColors.coral.withOpacity(0.15),
                checkmarkColor: AppColors.coral,
                labelStyle: TextStyle(
                  color: selected ? AppColors.coral : AppColors.charcoal,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacings.base),
          // Price range
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Faixa de preço', style: TextStyle(fontWeight: FontWeight.w600)),
              Text(
                'R\$ ${_priceRange.start.round()} – R\$ ${_priceRange.end.round()}',
                style: const TextStyle(color: AppColors.warmGray, fontSize: 13),
              ),
            ],
          ),
          RangeSlider(
            values: _priceRange,
            min: 100,
            max: 2000,
            divisions: 38,
            activeColor: AppColors.coral,
            inactiveColor: AppColors.lightGray,
            onChanged: (v) => setState(() => _priceRange = v),
          ),
          const SizedBox(height: AppSpacings.base),
          AppButton(label: 'Aplicar filtros', onPressed: _apply),
          const SizedBox(height: AppSpacings.sm),
        ],
      ),
    );
  }
}
