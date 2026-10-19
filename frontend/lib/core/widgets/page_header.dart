// lib/core/widgets/page_header.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'section_chip.dart';

/// Header used at the top of each screen.
class PageHeader extends StatelessWidget {
  const PageHeader({
    required this.title,
    this.subtitle,
    this.eyebrow,
    this.leadingContent,
    this.trailingAction,
    this.bottomContent,
    this.section,
    this.chip,
    super.key,
  });

  /// Optional text label for the section; if `chip` is provided, this is ignored.
  final String? section;

  /// Optional widget to display as a leading chip (e.g., SectionChip).
  final Widget? chip;

  final String title;
  final String? subtitle;
  final String? eyebrow;
  final Widget? leadingContent;
  final Widget? trailingAction;
  final Widget? bottomContent;

  @override
  Widget build(BuildContext context) {
    final contextualContent = leadingContent ??
        (eyebrow == null
            ? null
            : Text(
                eyebrow!,
                style: AppText.body(context, fontSize: 14).copyWith(
                  color: AppColors.mutedSage,
                  height: 1.3,
                ),
              ));
    final legacyChip = chip ??
        (section == null ? null : SectionChip(label: section!));

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 420;
        final text = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (legacyChip != null) ...[
              legacyChip,
              const SizedBox(height: 8),
            ] else if (contextualContent != null) ...[
              contextualContent,
              const SizedBox(height: 4),
            ],
            Text(
              title,
              style: AppText.heading(context, fontSize: 32).copyWith(
                color: AppColors.primaryText,
                height: 1.15,
                shadows: const [],
              ),
            ),
            if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(
                subtitle!,
                style: AppText.body(context, fontSize: 15).copyWith(
                  color: AppColors.mutedSage,
                  height: 1.4,
                ),
              ),
            ],
          ],
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (compact && trailingAction != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: text),
                  const SizedBox(width: 12),
                  trailingAction!,
                ],
              ),
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: text),
                  if (trailingAction != null) ...[
                    const SizedBox(width: 20),
                    trailingAction!,
                  ],
                ],
              ),
            if (bottomContent != null) ...[
              const SizedBox(height: 20),
              bottomContent!,
            ],
          ],
        );
      },
    );
  }
}
