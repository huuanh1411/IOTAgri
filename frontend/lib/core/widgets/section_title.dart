// lib/core/widgets/section_title.dart
import 'package:flutter/material.dart';
import '../theme/theme.dart'; // AppText

/// A reusable title widget for sections, using the default heading style.
class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
  });

  final String title;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        title,
        style: AppText.heading,
      ),
    );
  }
}
