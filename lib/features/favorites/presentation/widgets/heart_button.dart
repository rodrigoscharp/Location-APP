import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/auth_provider.dart';
import '../favorites_provider.dart';

class HeartButton extends ConsumerWidget {
  final String listingId;
  final double size;
  final bool showBackground;

  const HeartButton({
    super.key,
    required this.listingId,
    this.size = 22,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(isFavoriteProvider(listingId));
    final isAuth = ref.watch(isAuthenticatedProvider);

    return GestureDetector(
      onTap: () async {
        if (!isAuth) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Entre para salvar favoritos')),
          );
          return;
        }
        await ref
            .read(favoritesNotifierProvider.notifier)
            .toggle(listingId, isFav);
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: animation,
          child: child,
        ),
        child: showBackground
            ? Container(
                key: ValueKey(isFav),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  size: size,
                  color: isFav ? AppColors.coral : AppColors.charcoal,
                ),
              )
            : Icon(
                key: ValueKey(isFav),
                isFav ? Icons.favorite : Icons.favorite_border,
                size: size,
                color: isFav ? AppColors.coral : AppColors.warmGray,
              ),
      ),
    );
  }
}
