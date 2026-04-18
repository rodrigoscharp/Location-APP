import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class GuestCounter extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const GuestCounter({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CounterButton(
          icon: Icons.remove,
          onPressed: value > min ? () => onChanged(value - 1) : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '$value',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.charcoal,
            ),
          ),
        ),
        _CounterButton(
          icon: Icons.add,
          onPressed: value < max ? () => onChanged(value + 1) : null,
        ),
      ],
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _CounterButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: onPressed != null ? AppColors.charcoal : AppColors.lightGray,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: onPressed != null ? AppColors.charcoal : AppColors.lightGray,
        ),
      ),
    );
  }
}
