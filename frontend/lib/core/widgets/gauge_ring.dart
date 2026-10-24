import '../../utils/l10n.dart';
// lib/core/widgets/gauge_ring.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Circular gauge showing a percentage/value with an icon.
class GaugeRing extends StatelessWidget {
  final String label;
  final double? value;
  final String unit;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  const GaugeRing({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Normalize value for 0‑100 percentage for the radial progress.
    final double progress = ((value ?? 0) / 100).clamp(0.0, 1.0);
    final gauge = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 72,
          height: 72,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background track
              SizedBox(
                width: 72,
                height: 72,
                child: CircularProgressIndicator(
                  value: 1,
                  strokeWidth: 8,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[300]!),
                ),
              ),
              // Animated foreground
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: progress),
                duration: const Duration(milliseconds: 800),
                builder: (context, prog, child) => SizedBox(
                  width: 72,
                  height: 72,
                  child: CircularProgressIndicator(
                    value: prog,
                    strokeWidth: 8,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),
              // Icon/value in centre
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 20, color: color),
                  const SizedBox(height: 4),
                  Text(
                    value == null ? '—' : '${value!.toStringAsFixed(0)}$unit',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 34,
          child: Center(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.fade,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.secondaryText,
              ),
            ),
          ),
        ),
      ],
    );
    if (onTap == null) return gauge;
    return Semantics(
      button: true,
      label: context.l10n.viewSensorDetails((label).toString()),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(padding: const EdgeInsets.all(6), child: gauge),
      ),
    );
  }
}
