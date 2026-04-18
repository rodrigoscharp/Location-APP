import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
      body: bookingAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.coral),
        ),
        error: (_, __) => const Center(child: Text('Erro ao carregar reserva')),
        data: (booking) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacings.base),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: 64,
                  ),
                ),
                const SizedBox(height: AppSpacings.lg),
                const Text(
                  'Reserva confirmada!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: AppSpacings.sm),
                const Text(
                  'Sua hospedagem foi reservada com sucesso.\nBoa viagem a Ubatuba!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.warmGray, height: 1.5),
                ),
                const SizedBox(height: AppSpacings.xl),

                // Booking details card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacings.base),
                  decoration: BoxDecoration(
                    color: AppColors.sand,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _DetailRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Check-in',
                        value: DateFormat('dd/MM/yyyy').format(booking.checkIn),
                      ),
                      const SizedBox(height: 12),
                      _DetailRow(
                        icon: Icons.calendar_month_outlined,
                        label: 'Check-out',
                        value: DateFormat('dd/MM/yyyy').format(booking.checkOut),
                      ),
                      const SizedBox(height: 12),
                      _DetailRow(
                        icon: Icons.person_outline,
                        label: 'Hóspedes',
                        value: '${booking.guestsCount}',
                      ),
                      const SizedBox(height: 12),
                      _DetailRow(
                        icon: Icons.payments_outlined,
                        label: 'Total pago',
                        value: CurrencyFormatter.formatDecimal(booking.totalPrice),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacings.xl),
                AppButton(
                  label: 'Explorar mais hospedagens',
                  onPressed: () => context.go(Routes.explore),
                ),
                const SizedBox(height: AppSpacings.base),
                AppButton(
                  label: 'Minhas reservas',
                  outlined: true,
                  onPressed: () => context.go(Routes.profile),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.coral),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(color: AppColors.warmGray)),
        const Spacer(),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
