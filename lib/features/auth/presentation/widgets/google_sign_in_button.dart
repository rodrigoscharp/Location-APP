import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GoogleSignInButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.lightGray),
            ),
            child: const Center(
              child: Text(
                'G',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4285F4),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Continuar com Google',
            style: TextStyle(
              color: AppColors.charcoal,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
