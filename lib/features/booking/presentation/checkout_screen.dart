import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacings.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/app_button.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../listings/presentation/listings_provider.dart';
import 'booking_provider.dart';
import 'widgets/guest_counter.dart';
import 'widgets/price_breakdown_card.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final String listingId;
  const CheckoutScreen({super.key, required this.listingId});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  DateTime? _checkIn;
  DateTime? _checkOut;
  int _guests = 1;
  bool _loading = false;

  DateTime get _focusedDay => _checkIn ?? DateTime.now();

  int get _nights =>
      (_checkIn != null && _checkOut != null)
          ? _checkOut!.difference(_checkIn!).inDays
          : 0;

  @override
  Widget build(BuildContext context) {
    final listingAsync = ref.watch(listingDetailProvider(widget.listingId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservar', style: TextStyle(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      body: listingAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.coral)),
        error: (_, __) => const Center(child: Text('Erro ao carregar')),
        data: (listing) {
          final total = listing.pricePerNight * _nights;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacings.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Listing header
                Container(
                  padding: const EdgeInsets.all(AppSpacings.base),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.lightGray),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          listing.coverPhoto,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 64,
                            height: 64,
                            color: AppColors.lightGray,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(listing.title,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                            Text(listing.type.label,
                                style: const TextStyle(
                                    color: AppColors.warmGray, fontSize: 12)),
                            Text(
                              CurrencyFormatter.format(listing.pricePerNight) +
                                  '/noite',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacings.lg),

                // Calendar
                const Text('Selecione as datas',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSpacings.sm),
                TableCalendar(
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: _focusedDay,
                  rangeStartDay: _checkIn,
                  rangeEndDay: _checkOut,
                  rangeSelectionMode: RangeSelectionMode.enforced,
                  calendarFormat: CalendarFormat.month,
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  calendarStyle: CalendarStyle(
                    rangeHighlightColor: AppColors.coral.withOpacity(0.2),
                    rangeStartDecoration: const BoxDecoration(
                      color: AppColors.coral,
                      shape: BoxShape.circle,
                    ),
                    rangeEndDecoration: const BoxDecoration(
                      color: AppColors.coral,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: AppColors.coral.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: AppColors.coral,
                      shape: BoxShape.circle,
                    ),
                  ),
                  onRangeSelected: (start, end, focused) {
                    setState(() {
                      _checkIn = start;
                      _checkOut = end;
                    });
                  },
                ),
                const Divider(height: AppSpacings.xl),

                // Guests
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Hóspedes',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                        Text('Máximo: ${listing.maxGuests}',
                            style: const TextStyle(
                                color: AppColors.warmGray, fontSize: 13)),
                      ],
                    ),
                    GuestCounter(
                      value: _guests,
                      max: listing.maxGuests,
                      onChanged: (v) => setState(() => _guests = v),
                    ),
                  ],
                ),
                const Divider(height: AppSpacings.xl),

                // Price breakdown
                if (_nights > 0) ...[
                  const Text('Resumo de preços',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppSpacings.sm),
                  PriceBreakdownCard(
                    pricePerNight: listing.pricePerNight,
                    nights: _nights,
                    total: total,
                  ),
                  const SizedBox(height: AppSpacings.lg),
                ],

                // Reserve button
                AppButton(
                  label: _nights > 0
                      ? 'Ir para pagamento · ${CurrencyFormatter.format(total)}'
                      : 'Selecione as datas',
                  loading: _loading,
                  onPressed: (_checkIn != null && _checkOut != null && !_loading)
                      ? () async {
                          final user = ref.read(currentUserProvider);
                          if (user == null) {
                            context.go('/login');
                            return;
                          }
                          setState(() => _loading = true);
                          try {
                            final booking = await ref
                                .read(bookingRepositoryProvider)
                                .createBooking(
                                  listingId: widget.listingId,
                                  guestId: user.id,
                                  checkIn: _checkIn!,
                                  checkOut: _checkOut!,
                                  guestsCount: _guests,
                                  totalPrice: total,
                                );
                            if (mounted) {
                              context.push(
                                  '${GoRouterState.of(context).uri}/payment/${booking.id}');
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erro: $e')),
                              );
                            }
                          } finally {
                            if (mounted) setState(() => _loading = false);
                          }
                        }
                      : null,
                ),
                const SizedBox(height: AppSpacings.base),
              ],
            ),
          );
        },
      ),
    );
  }
}
