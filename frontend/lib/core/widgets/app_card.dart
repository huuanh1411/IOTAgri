// lib/core/widgets/app_card.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/ui_consts.dart';

/// Generic white card with rounded corners and soft shadow.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  final Widget? child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UIConsts.cardRadius),
        boxShadow: [UIConsts.softShadow],
      ),
      child: child,
    );
    return onTap != null
        ? InkWell(onTap: onTap, borderRadius: BorderRadius.circular(UIConsts.cardRadius), child: card)
        : card;
  }
}
