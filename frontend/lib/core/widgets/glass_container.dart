// lib/core/widgets/glass_container.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Variants for the GlassContainer widget.
enum GlassVariant { large, light, hero }

/// A reusable glass‑morphism container.
///
/// The widget applies a rounded clip, an optional backdrop blur, and a
/// translucent background (gradient or solid colour) according to the
/// selected [variant].
class GlassContainer extends StatelessWidget {
  final Widget child;
  final GlassVariant variant;

  const GlassContainer({
    super.key,
    required this.child,
    this.variant = GlassVariant.large,
  });

  @override
  Widget build(BuildContext context) {
    // Common radius values
    double radius;
    // Background decoration
    BoxDecoration decoration;
    // Optional blur sigma
    double blurSigma = 0;
    // Shadow list
    List<BoxShadow> shadows = [];

    switch (variant) {
      case GlassVariant.large:
        radius = 28;
        blurSigma = 18;
        decoration = BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.30),
              Colors.white.withValues(alpha: 0.08),
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.46),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(radius),
        );
        shadows = [
          BoxShadow(
            color: AppColors.forestGreen.withValues(alpha: 0.20),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ];
        break;
      case GlassVariant.light:
        radius = 24;
        // No blur for performance‑critical lists.
        decoration = BoxDecoration(
          color: Colors.white.withValues(alpha: 0.42),
          borderRadius: BorderRadius.circular(radius),
        );
        break;
      case GlassVariant.hero:
        radius = 28;
        decoration = BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.sage, AppColors.forestGreen],
          ),
          borderRadius: BorderRadius.circular(radius),
        );
        shadows = [
          const BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ];
        break;
    }

    Widget content = Container(
      decoration: decoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: child,
      ),
    );

    if (blurSigma > 0) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: content,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        boxShadow: shadows,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: content,
    );
  }
}
