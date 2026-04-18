import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacings.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../router/routes.dart';
import '../../../shared/widgets/app_button.dart';
import 'booking_provider.dart';

class BookingConfirmationScreen extends ConsumerWidget {
  final String bookingId;
  const BookingConfirmationScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsync = ref.watch(bookingDetailProvider(bookingId));

    return Scaffold(
      backgroundColor: AppColors.paleGray,
      body: bookingAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.coral)),
        error: (_, __) =>
            const Center(child: Text('Erro ao carregar reserva')),
        data: (booking) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(),

                // Success illustration
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: 68,
                  ),
                ),
                const SizedBox(height: AppSpacings.lg),
                Text(
                  'Reserva confirmada!',
                  style: GoogleFonts.dmSans(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sua hospedagem foi reservada com sucesso.\nBoa viagem a Ubatuba!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    color: AppColors.warmGray,
                    height: 1.5,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: AppSpacings.xl),

                // Booking details card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _DetailRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Check-in',
                        value:
                            DateFormat('dd/MM/yyyy').format(booking.checkIn),
                      ),
                      const _Divider(),
                      _DetailRow(
                        icon: Icons.calendar_month_outlined,
                        label: 'Check-out',
                        value:
                            DateFormat('dd/MM/yyyy').format(booking.checkOut),
                      ),
                      const _Divider(),
                      _DetailRow(
                        icon: Icons.person_outline,
                        label: 'Hóspedes',
                        value: '${booking.guestsCount}',
                      ),
                      const _Divider(),
                      _DetailRow(
                        icon: Icons.payments_outlined,
                        label: 'Total pago',
                        value: CurrencyFormatter.formatDecimal(booking.totalPrice),
                        valueColor: AppColors.coral,
                        bold: true,
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                AppButton(
                  label: 'Explorar mais hospedagens',
                  onPressed: () => context.go(Routes.explore),
                ),
                const SizedBox(height: AppSpacings.sm),
                AppButton(
                  label: 'Minhas reservas',
                  outlined: true,
                  onPressed: () => context.go(Routes.profile),
                ),
                const SizedBox(height: AppSpacings.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Divider(height: 1, color: AppColors.lightGray),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.coral.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 17, color: AppColors.coral),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.dmSans(color: AppColors.warmGray, fontSize: 14),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            fontSize: 14,
            color: valueColor ?? AppColors.charcoal,
          ),
        ),
      ],
    );
  }
}
