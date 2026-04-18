import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
  static const _mockPixKey =
      '00020126580014br.gov.bcb.pix013600000000-0000-0000-0000-000000000000520400005303986540510.005802BR5913Ubatuba APP6008Ubatuba62090505*****63041D2E';

  bool _copied = false;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
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
        appBar: _buildAppBar(context),
        body: const Center(
            child: CircularProgressIndicator(color: AppColors.coral)),
      ),
      error: (_, __) => Scaffold(
        appBar: _buildAppBar(context),
        body: const Center(child: Text('Erro ao carregar reserva')),
      ),
      data: (booking) {
        if (booking.status.name == 'confirmed') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/confirmation/${booking.id}');
          });
        }

        final serviceFee = booking.totalPrice * 0.12;
        final total = booking.totalPrice + serviceFee;

        return Scaffold(
          backgroundColor: AppColors.paleGray,
          appBar: _buildAppBar(context),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Header with amount
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.fromLTRB(24, 28, 24, 28),
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Valor a pagar',
                        style: GoogleFonts.dmSans(
                          color: AppColors.warmGray,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        CurrencyFormatter.formatDecimal(total),
                        style: GoogleFonts.dmSans(
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          color: AppColors.charcoal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${booking.nights} noite${booking.nights > 1 ? 's' : ''} · taxa de serviço incluída',
                        style: GoogleFonts.dmSans(
                          color: AppColors.warmGray,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // QR Code card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
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
                            // PIX badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF32BCAD).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'PIX',
                                style: GoogleFonts.dmSans(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  color: const Color(0xFF32BCAD),
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            QrImageView(
                              data: _mockPixKey,
                              version: QrVersions.auto,
                              size: 210,
                              eyeStyle: const QrEyeStyle(
                                eyeShape: QrEyeShape.square,
                                color: AppColors.charcoal,
                              ),
                              dataModuleStyle: const QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.square,
                                color: AppColors.charcoal,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Abra o app do seu banco e escaneie o código QR ou copie a chave PIX abaixo',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.dmSans(
                                color: AppColors.warmGray,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Copy button
                      AppButton(
                        label: _copied ? 'Chave copiada!' : 'Copiar chave PIX',
                        icon: _copied ? Icons.check_rounded : Icons.copy_rounded,
                        color: _copied ? AppColors.success : AppColors.teal,
                        onPressed: () async {
                          await Clipboard.setData(
                              const ClipboardData(text: _mockPixKey));
                          setState(() => _copied = true);
                          Future.delayed(const Duration(seconds: 2), () {
                            if (mounted) setState(() => _copied = false);
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Waiting status
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.lightGray),
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
                            const SizedBox(width: 10),
                            Text(
                              'Aguardando confirmação do pagamento...',
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                color: AppColors.warmGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacings.base),
                      Text(
                        'O pagamento via PIX é processado instantaneamente.\nSua reserva será confirmada automaticamente.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppColors.mediumGray,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacings.xxl),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new,
            color: AppColors.charcoal, size: 18),
        onPressed: () => context.pop(),
      ),
      title: Text(
        'Pagamento via PIX',
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
    );
  }
}
