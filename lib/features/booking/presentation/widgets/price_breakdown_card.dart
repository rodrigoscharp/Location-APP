import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

class PriceBreakdownCard extends StatelessWidget {
  final double pricePerNight;
  final int nights;
  final double total;

  const PriceBreakdownCard({
    super.key,
    required this.pricePerNight,
    required this.nights,
    required this.total,
  });

  double get serviceFee => total * 0.12;
  double get subtotal => pricePerNight * nights;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lightGray),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _Row(
            label:
                '${CurrencyFormatter.format(pricePerNight)} × $nights noite${nights > 1 ? 's' : ''}',
            value: CurrencyFormatter.format(subtotal),
          ),
          const SizedBox(height: 8),
          _Row(
            label: 'Taxa de serviço',
            value: CurrencyFormatter.format(serviceFee),
          ),
          const Divider(height: 24),
          _Row(
            label: 'Total',
            value: CurrencyFormatter.format(total + serviceFee),
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _Row({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: bold ? 16 : 14,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      color: AppColors.charcoal,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}
