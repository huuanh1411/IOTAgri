// lib/core/widgets/status_pill.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/ui_consts.dart';
import '../theme/app_text.dart';

/// Small pill that shows a status indicator (dot) and a label.
/// Example: "● Đã đồng bộ" – the dot colour conveys the status.
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    this.dotColor = Colors.green,
  });

  final String label;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: dotColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(UIConsts.chipRadius),
        boxShadow: [UIConsts.softShadow],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: AppText.caption.copyWith(color: dotColor)),
        ],
      ),
    );
  }
}
