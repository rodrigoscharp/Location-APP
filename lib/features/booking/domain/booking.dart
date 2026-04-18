enum BookingStatus { pending, confirmed, cancelled }

class Booking {
  final String id;
  final String listingId;
  final String guestId;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guestsCount;
  final double totalPrice;
  final BookingStatus status;
  final String? paymentId;
  final DateTime createdAt;

  const Booking({
    required this.id,
    required this.listingId,
    required this.guestId,
    required this.checkIn,
    required this.checkOut,
    required this.guestsCount,
    required this.totalPrice,
    required this.status,
    this.paymentId,
    required this.createdAt,
  });

  int get nights => checkOut.difference(checkIn).inDays;

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      listingId: json['listing_id'] as String,
      guestId: json['guest_id'] as String,
      checkIn: DateTime.parse(json['check_in'] as String),
      checkOut: DateTime.parse(json['check_out'] as String),
      guestsCount: json['guests_count'] as int? ?? 1,
      totalPrice: (json['total_price'] as num).toDouble(),
      status: BookingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BookingStatus.pending,
      ),
      paymentId: json['payment_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
