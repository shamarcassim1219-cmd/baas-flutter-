import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

/// The "GO[BAAS]" wordmark used throughout onboarding - a single
/// widget so the logo's exact look (and its entrance animation)
/// only ever needs to change in one place.
class BrandLogo extends StatelessWidget {
  final double fontSize;
  final bool animate;

  const BrandLogo({super.key, this.fontSize = 28, this.animate = true});

  @override
  Widget build(BuildContext context) {
    final logo = RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
          letterSpacing: -0.5,
        ),
        children: [
          const TextSpan(text: 'GO'),
          TextSpan(
            text: 'BAAS',
            style: TextStyle(color: AppColors.accent),
          ),
        ],
      ),
    );

    if (!animate) return logo;

    return logo
        .animate()
        .fadeIn(duration: AppMotion.slow)
        .scale(
          begin: const Offset(0.85, 0.85),
          end: const Offset(1, 1),
          duration: AppMotion.slow,
          curve: AppMotion.bouncy,
        );
  }
}
