import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/app_colors.dart';
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
      backgroundColor: AppColors.paleGray,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.charcoal, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Reservar',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: AppColors.charcoal,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.lightGray),
        ),
      ),
      body: listingAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.coral)),
        error: (_, __) => const Center(child: Text('Erro ao carregar')),
        data: (listing) {
          final total = listing.pricePerNight * _nights;

          return Stack(
            children: [
              SingleChildScrollView(
                padding:
                    const EdgeInsets.fromLTRB(20, 20, 20, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Listing summary card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              listing.coverPhoto,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 70,
                                height: 70,
                                color: AppColors.lightGray,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  listing.title,
                                  style: GoogleFonts.dmSans(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: AppColors.charcoal,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  listing.type.label,
                                  style: GoogleFonts.dmSans(
                                    color: AppColors.warmGray,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${CurrencyFormatter.format(listing.pricePerNight)}/noite',
                                  style: GoogleFonts.dmSans(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: AppColors.coral,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Calendar section
                    _SectionCard(
                      title: 'Selecione as datas',
                      child: TableCalendar(
                        firstDay: DateTime.now(),
                        lastDay: DateTime.now().add(const Duration(days: 365)),
                        focusedDay: _focusedDay,
                        rangeStartDay: _checkIn,
                        rangeEndDay: _checkOut,
                        rangeSelectionMode: RangeSelectionMode.enforced,
                        calendarFormat: CalendarFormat.month,
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppColors.charcoal,
                          ),
                        ),
                        calendarStyle: CalendarStyle(
                          rangeHighlightColor:
                              AppColors.coral.withValues(alpha: 0.15),
                          rangeStartDecoration: const BoxDecoration(
                            color: AppColors.coral,
                            shape: BoxShape.circle,
                          ),
                          rangeEndDecoration: const BoxDecoration(
                            color: AppColors.coral,
                            shape: BoxShape.circle,
                          ),
                          todayDecoration: BoxDecoration(
                            color: AppColors.coral.withValues(alpha: 0.25),
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: const BoxDecoration(
                            color: AppColors.coral,
                            shape: BoxShape.circle,
                          ),
                          defaultTextStyle: GoogleFonts.dmSans(),
                          weekendTextStyle:
                              GoogleFonts.dmSans(color: AppColors.charcoal),
                          outsideDaysVisible: false,
                        ),
                        onRangeSelected: (start, end, focused) {
                          setState(() {
                            _checkIn = start;
                            _checkOut = end;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Guests section
                    _SectionCard(
                      title: 'Hóspedes',
                      subtitle: 'Máximo: ${listing.maxGuests}',
                      child: GuestCounter(
                        value: _guests,
                        max: listing.maxGuests,
                        onChanged: (v) => setState(() => _guests = v),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Price breakdown
                    if (_nights > 0)
                      _SectionCard(
                        title: 'Resumo de preços',
                        child: PriceBreakdownCard(
                          pricePerNight: listing.pricePerNight,
                          nights: _nights,
                          total: total,
                        ),
                      ),
                  ],
                ),
              ),

              // Bottom reserve button
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: AppButton(
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
                              if (context.mounted) {
                                context.push(
                                    '${GoRouterState.of(context).uri}/payment/${booking.id}');
                              }
                            } catch (e) {
                              if (context.mounted) {
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: GoogleFonts.dmSans(
                    color: AppColors.warmGray,
                    fontSize: 13,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
