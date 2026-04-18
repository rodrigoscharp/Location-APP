import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/supabase_client_provider.dart';
import '../data/booking_repository.dart';
import '../domain/booking.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(ref.watch(supabaseClientProvider));
});

final bookingDetailProvider = FutureProvider.family<Booking, String>((ref, id) {
  return ref.watch(bookingRepositoryProvider).getBookingById(id);
});

class CheckoutState {
  final DateTime? checkIn;
  final DateTime? checkOut;
  final int guests;

  const CheckoutState({
    this.checkIn,
    this.checkOut,
    this.guests = 1,
  });

  bool get isValid => checkIn != null && checkOut != null && checkOut!.isAfter(checkIn!);

  int get nights => isValid ? checkOut!.difference(checkIn!).inDays : 0;

  CheckoutState copyWith({
    DateTime? checkIn,
    DateTime? checkOut,
    int? guests,
  }) {
    return CheckoutState(
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      guests: guests ?? this.guests,
    );
  }
}

final checkoutStateProvider = StateProvider<CheckoutState>((ref) {
  return const CheckoutState();
});
