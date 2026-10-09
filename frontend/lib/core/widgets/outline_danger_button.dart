// lib/core/widgets/outline_danger_button.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/ui_consts.dart';
import '../theme/app_text.dart';

/// Outline button used for destructive actions (e.g., logout).
/// Has a red border and text, optional leading icon.
class OutlineDangerButton extends StatelessWidget {
  const OutlineDangerButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.dangerRed),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) Icon(icon, size: 20, color: AppColors.dangerRed),
              if (icon != null) const SizedBox(width: 8),
              Text(label, style: AppText.button.copyWith(color: AppColors.dangerRed)),
            ],
          );

    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.dangerRed,
        side: const BorderSide(color: AppColors.dangerRed),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConsts.buttonRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: child,
    );
  }
}
