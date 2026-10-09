// lib/core/widgets/skeleton_box.dart
import 'package:flutter/material.dart';
import '../theme/theme.dart'; // UIConsts

/// A simple skeleton/loading placeholder box.
/// Use it to indicate loading content while preserving layout.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  final double? width;
  final double? height;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(borderRadius ?? UIConsts.cardRadius),
      ),
    );
  }
}
