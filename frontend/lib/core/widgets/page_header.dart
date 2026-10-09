// lib/core/widgets/page_header.dart
import 'package:flutter/material.dart';
import '../theme/app_text.dart';
import '../theme/app_colors.dart';
import '../theme/ui_consts.dart';
import 'section_chip.dart';

/// Header used at the top of each page.
/// Shows an optional [sectionChip] above a serif title and a grey subtitle.
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    this.sectionLabel,
    required this.title,
    this.subtitle,
  });

  final String? sectionLabel;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sectionLabel != null) SectionChip(label: sectionLabel!),
        const SizedBox(height: 8),
        Text(title, style: AppText.heading),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!, style: AppText.subtitle.copyWith(color: AppColors.secondaryText)),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}
