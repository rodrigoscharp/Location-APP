import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/booking.dart';

class BookingRepository {
  final SupabaseClient _client;

  BookingRepository(this._client);

  Future<Booking> createBooking({
    required String listingId,
    required String guestId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guestsCount,
    required double totalPrice,
  }) async {
    final data = await _client.from('bookings').insert({
      'listing_id': listingId,
      'guest_id': guestId,
      'check_in': checkIn.toIso8601String().split('T').first,
      'check_out': checkOut.toIso8601String().split('T').first,
      'guests_count': guestsCount,
      'total_price': totalPrice,
      'status': 'pending',
    }).select().single();

    return Booking.fromJson(data);
  }

  Future<Booking> getBookingById(String id) async {
    final data = await _client
        .from('bookings')
        .select()
        .eq('id', id)
        .single();
    return Booking.fromJson(data);
  }

  Future<List<Booking>> getGuestBookings(String guestId) async {
    final data = await _client
        .from('bookings')
        .select()
        .eq('guest_id', guestId)
        .order('created_at', ascending: false);
    return (data as List).map((j) => Booking.fromJson(j)).toList();
  }

  /// Check if dates overlap with existing confirmed bookings
  Future<bool> isAvailable({
    required String listingId,
    required DateTime checkIn,
    required DateTime checkOut,
  }) async {
    final data = await _client
        .from('bookings')
        .select('id')
        .eq('listing_id', listingId)
        .eq('status', 'confirmed')
        .or('check_in.lt.${checkOut.toIso8601String().split('T').first},check_out.gt.${checkIn.toIso8601String().split('T').first}');

    return (data as List).isEmpty;
  }

  Future<void> cancelBooking(String bookingId) async {
    await _client
        .from('bookings')
        .update({'status': 'cancelled'})
        .eq('id', bookingId);
  }

  Future<void> updatePaymentId(String bookingId, String paymentId) async {
    await _client
        .from('bookings')
        .update({'payment_id': paymentId})
        .eq('id', bookingId);
  }
}
