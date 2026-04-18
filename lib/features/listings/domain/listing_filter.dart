import 'listing.dart';

class ListingFilter {
  final ListingRegion? region;
  final ListingType? type;
  final double? minPrice;
  final double? maxPrice;
  final int? minGuests;

  const ListingFilter({
    this.region,
    this.type,
    this.minPrice,
    this.maxPrice,
    this.minGuests,
  });

  ListingFilter copyWith({
    ListingRegion? region,
    ListingType? type,
    double? minPrice,
    double? maxPrice,
    int? minGuests,
    bool clearRegion = false,
  }) {
    return ListingFilter(
      region: clearRegion ? null : (region ?? this.region),
      type: type ?? this.type,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minGuests: minGuests ?? this.minGuests,
    );
  }

  bool get hasActiveFilters =>
      type != null ||
      minPrice != null ||
      maxPrice != null ||
      minGuests != null;
}
