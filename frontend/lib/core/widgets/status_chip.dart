// lib/core/widgets/status_chip.dart
import 'package:flutter/material.dart';
import '../theme/theme.dart'; // AppText, UIConsts

/// A chip that displays a status label with a colored background.
/// `color` should be appropriate for the status (e.g., warning, error).
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    this.color = Colors.green,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(UIConsts.buttonRadius),
      ),
      child: Text(
        label,
        style: AppText.caption.copyWith(color: color),
      ),
    );
  }
}
