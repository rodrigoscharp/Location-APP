import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacings.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/app_button.dart';
import 'booking_provider.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String bookingId;
  const PaymentScreen({super.key, required this.bookingId});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  // Mock PIX key for demo — replace with actual Edge Function call
  static const _mockPixKey =
      '00020126580014br.gov.bcb.pix013600000000-0000-0000-0000-000000000000520400005303986540510.005802BR5913Ubatuba APP6008Ubatuba62090505*****63041D2E';

  bool _copied = false;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    // Poll for payment confirmation every 5 seconds
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      ref.invalidate(bookingDetailProvider(widget.bookingId));
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingAsync = ref.watch(bookingDetailProvider(widget.bookingId));

    return bookingAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Pagamento')),
        body:
            const Center(child: CircularProgressIndicator(color: AppColors.coral)),
      ),
      error: (_, __) => Scaffold(
        appBar: AppBar(title: const Text('Pagamento')),
        body: const Center(child: Text('Erro ao carregar reserva')),
      ),
      data: (booking) {
        // Auto-navigate on confirmation
        if (booking.status.name == 'confirmed') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/confirmation/${booking.id}');
          });
        }

        final serviceFee = booking.totalPrice * 0.12;
        final total = booking.totalPrice + serviceFee;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Pagamento via PIX',
                style: TextStyle(fontWeight: FontWeight.w700)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () => context.pop(),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacings.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: AppSpacings.base),
                // Value
                Text(
                  CurrencyFormatter.formatDecimal(total),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: AppColors.charcoal,
                  ),
                ),
                Text(
                  '${booking.nights} noite${booking.nights > 1 ? 's' : ''} · taxa de serviço incluída',
                  style: const TextStyle(color: AppColors.warmGray),
                ),
                const SizedBox(height: AppSpacings.xl),

                // QR Code
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: _mockPixKey,
                    version: QrVersions.auto,
                    size: 220,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: AppColors.charcoal,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: AppColors.charcoal,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacings.lg),

                const Text(
                  'Abra o app do seu banco e escaneie o QR code ou use a chave PIX abaixo',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.warmGray, fontSize: 14),
                ),
                const SizedBox(height: AppSpacings.base),

                // Copy PIX key button
                AppButton(
                  label: _copied ? 'Copiado!' : 'Copiar chave PIX',
                  icon: _copied ? Icons.check : Icons.copy,
                  color: _copied ? AppColors.success : AppColors.teal,
                  onPressed: () async {
                    await Clipboard.setData(
                        ClipboardData(text: _mockPixKey));
                    setState(() => _copied = true);
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) setState(() => _copied = false);
                    });
                  },
                ),
                const SizedBox(height: AppSpacings.base),

                // Status indicator
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.sand,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.coral,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Aguardando pagamento...',
                        style: TextStyle(fontSize: 13, color: AppColors.warmGray),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacings.lg),
                const Text(
                  'O pagamento é processado instantaneamente via PIX.\nSua reserva será confirmada automaticamente.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.warmGray),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
