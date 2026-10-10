// lib/core/widgets/status_pill.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Small colored pill badge used on cards.
class StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const StatusPill({
    Key? key,
    required this.label,
    this.color = AppColors.forestGreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
