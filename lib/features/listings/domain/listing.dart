enum ListingType {
  pousada('Pousada'),
  casa('Casa'),
  chale('Chalé');

  final String label;
  const ListingType(this.label);
}

enum ListingRegion {
  praia('Praia', '🏖️'),
  centro('Centro', '🏙️'),
  montanha('Montanha', '⛰️');

  final String label;
  final String emoji;
  const ListingRegion(this.label, this.emoji);
}

class Listing {
  final String id;
  final String hostId;
  final String title;
  final String? description;
  final ListingType type;
  final ListingRegion region;
  final String? address;
  final double? lat;
  final double? lng;
  final double pricePerNight;
  final int maxGuests;
  final int bedrooms;
  final int bathrooms;
  final List<String> amenities;
  final List<String> photoUrls;
  final double? avgRating;
  final int reviewCount;
  final String? hostName;
  final String? hostAvatarUrl;
  final DateTime createdAt;

  const Listing({
    required this.id,
    required this.hostId,
    required this.title,
    this.description,
    required this.type,
    required this.region,
    this.address,
    this.lat,
    this.lng,
    required this.pricePerNight,
    this.maxGuests = 2,
    this.bedrooms = 1,
    this.bathrooms = 1,
    this.amenities = const [],
    this.photoUrls = const [],
    this.avgRating,
    this.reviewCount = 0,
    this.hostName,
    this.hostAvatarUrl,
    required this.createdAt,
  });

  String get coverPhoto =>
      photoUrls.isNotEmpty ? photoUrls.first : _placeholderByRegion;

  String get _placeholderByRegion {
    switch (region) {
      case ListingRegion.praia:
        return 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800';
      case ListingRegion.montanha:
        return 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800';
      case ListingRegion.centro:
        return 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800';
    }
  }

  factory Listing.fromJson(Map<String, dynamic> json) {
    // Parse photos sorted by position
    final photosRaw = json['listing_photos'] as List<dynamic>? ?? [];
    final photoUrls = (photosRaw
          ..sort((a, b) =>
              ((a['position'] as int?) ?? 0)
                  .compareTo((b['position'] as int?) ?? 0)))
        .map((p) => p['url'] as String)
        .toList();

    // Parse ratings (may come as list or map depending on join type)
    double? avgRating;
    int reviewCount = 0;
    final ratingsRaw = json['listing_ratings'];
    if (ratingsRaw is List && ratingsRaw.isNotEmpty) {
      avgRating = (ratingsRaw.first['avg_rating'] as num?)?.toDouble();
      reviewCount = ratingsRaw.first['review_count'] as int? ?? 0;
    } else if (ratingsRaw is Map) {
      avgRating = (ratingsRaw['avg_rating'] as num?)?.toDouble();
      reviewCount = ratingsRaw['review_count'] as int? ?? 0;
    }

    // Parse host profile
    String? hostName;
    String? hostAvatarUrl;
    final hostRaw = json['profiles'];
    if (hostRaw is List && hostRaw.isNotEmpty) {
      hostName = hostRaw.first['full_name'] as String?;
      hostAvatarUrl = hostRaw.first['avatar_url'] as String?;
    } else if (hostRaw is Map) {
      hostName = hostRaw['full_name'] as String?;
      hostAvatarUrl = hostRaw['avatar_url'] as String?;
    }

    return Listing(
      id: json['id'] as String,
      hostId: json['host_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: ListingType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ListingType.pousada,
      ),
      region: ListingRegion.values.firstWhere(
        (e) => e.name == json['region'],
        orElse: () => ListingRegion.praia,
      ),
      address: json['address'] as String?,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      pricePerNight: (json['price_per_night'] as num).toDouble(),
      maxGuests: json['max_guests'] as int? ?? 2,
      bedrooms: json['bedrooms'] as int? ?? 1,
      bathrooms: json['bathrooms'] as int? ?? 1,
      amenities: List<String>.from(json['amenities'] as List? ?? []),
      photoUrls: photoUrls,
      avgRating: avgRating,
      reviewCount: reviewCount,
      hostName: hostName,
      hostAvatarUrl: hostAvatarUrl,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

// Amenity display helpers
const amenityLabels = {
  'wifi': 'Wi-Fi',
  'piscina': 'Piscina',
  'ar_condicionado': 'Ar-condicionado',
  'cafe_da_manha': 'Café da manhã',
  'estacionamento': 'Estacionamento',
  'churrasqueira': 'Churrasqueira',
  'pet_friendly': 'Pet-friendly',
  'vista_mar': 'Vista para o mar',
  'academia': 'Academia',
  'cozinha': 'Cozinha equipada',
};

const amenityIcons = {
  'wifi': '📶',
  'piscina': '🏊',
  'ar_condicionado': '❄️',
  'cafe_da_manha': '☕',
  'estacionamento': '🚗',
  'churrasqueira': '🔥',
  'pet_friendly': '🐾',
  'vista_mar': '🌊',
  'academia': '💪',
  'cozinha': '🍳',
};
