import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CachedHeroImage extends StatelessWidget {
  final String imageUrl;
  final String heroTag;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const CachedHeroImage({
    super.key,
    required this.imageUrl,
    required this.heroTag,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      height: height,
      width: double.infinity,
      fit: fit,
      placeholder: (_, __) => Container(
        height: height,
        color: AppColors.lightGray,
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.coral,
            strokeWidth: 2,
          ),
        ),
      ),
      errorWidget: (_, __, ___) => Container(
        height: height,
        color: AppColors.lightGray,
        child: const Icon(Icons.image_not_supported_outlined, color: AppColors.warmGray),
      ),
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }

    return Hero(tag: heroTag, child: image);
  }
}
