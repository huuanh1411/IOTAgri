// lib/core/widgets/app_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme.dart'; // AppText, UIConsts

/// A reusable button that supports a loading state.
class AppButton extends ConsumerWidget {
  const AppButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.width,
  });

  final VoidCallback onPressed;
  final Widget child;
  final bool isLoading;
  final double? width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final btn = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(width ?? double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConsts.buttonRadius),
        ),
        textStyle: AppText.button,
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : child,
    );
    return btn;
  }
}
