// lib/core/widgets/gauge_ring.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/ui_consts.dart';
import '../theme/app_text.dart';

/// A circular gauge that shows a progress value (0-1) with an optional icon
/// and a caption below. Used for water, nutrient or temperature levels.
class GaugeRing extends StatelessWidget {
  const GaugeRing({
    super.key,
    required this.value, // 0.0 – 1.0
    required this.label,
    this.icon,
    this.gaugeColor = AppColors.forest,
    this.backgroundColor = const Color(0xFFE0E0E0),
  });

  final double value;
  final String label;
  final IconData? icon;
  final Color gaugeColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final size = UIConsts.gaugeSize;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // background circle
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: backgroundColor,
                ),
              ),
              // progress arc
              CircularProgressIndicator(
                value: value,
                strokeWidth: 12,
                backgroundColor: backgroundColor,
                valueColor: AlwaysStoppedAnimation<Color>(gaugeColor),
              ),
              // optional center icon
              if (icon != null)
                Icon(icon, size: size * 0.25, color: gaugeColor),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: AppText.caption),
        const SizedBox(height: 4),
        Text('${(value * 100).toInt()}%', style: AppText.body.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
