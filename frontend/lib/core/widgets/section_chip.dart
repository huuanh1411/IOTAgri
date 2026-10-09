// lib/core/widgets/section_chip.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/ui_consts.dart';

/// Small mint‑colored pill used as a section label (e.g., "CHỌN GIỐNG").
class SectionChip extends StatelessWidget {
  const SectionChip({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.mintChip,
        borderRadius: BorderRadius.circular(UIConsts.chipRadius),
        boxShadow: [UIConsts.softShadow],
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }
}
