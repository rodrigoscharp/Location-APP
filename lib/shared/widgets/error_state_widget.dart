import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'app_button.dart';

class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorStateWidget({
    super.key,
    this.message = 'Algo deu errado. Tente novamente.',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 64, color: AppColors.lightGray),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.warmGray, fontSize: 16),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              AppButton(label: 'Tentar novamente', onPressed: onRetry, icon: Icons.refresh),
            ],
          ],
        ),
      ),
    );
  }
}
