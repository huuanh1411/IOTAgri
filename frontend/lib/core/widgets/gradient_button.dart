// lib/core/widgets/gradient_button.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/ui_consts.dart';
import '../theme/app_text.dart';

/// Pill‑shaped button with a sage → forest gradient background.
/// If [icon] is provided it is placed to the left of the label.
class GradientButton extends StatelessWidget {
  const GradientButton({
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
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) Icon(icon, size: 20, color: Colors.white),
              if (icon != null) const SizedBox(width: 8),
              Text(label, style: AppText.button),
            ],
          );

    return InkWell(
      onTap: isLoading ? null : onPressed,
      borderRadius: BorderRadius.circular(UIConsts.buttonRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
          ),
          borderRadius: BorderRadius.circular(UIConsts.buttonRadius),
          boxShadow: [UIConsts.softShadow],
        ),
        child: Center(child: child),
      ),
    );
  }
}
