// lib/core/widgets/info_row.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/ui_consts.dart';
import '../theme/app_text.dart';

/// Row displaying an icon inside a tinted circle, a small‑caps label and a bold value.
/// Example: water level, nutrient level, temperature.
class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconBackground = AppColors.softSageRow,
  });

  final IconData icon;
  final String label; // small caps label
  final String value; // bold value
  final Color iconBackground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.softSageRow,
        borderRadius: BorderRadius.circular(UIConsts.cardRadius),
        boxShadow: [UIConsts.softShadow],
      ),
      child: Row(
        children: [
          Container(
            width: UIConsts.iconTileSize,
            height: UIConsts.iconTileSize,
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryText),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label.toUpperCase(), style: AppText.caption),
              Text(value, style: AppText.body.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
