import 'package:flutter/widgets.dart';

class GoogleSignInWebButton extends StatelessWidget {
  const GoogleSignInWebButton({
    super.key,
    required this.child,
    required this.onIdToken,
  });

  final Widget child;
  final Future<void> Function(String idToken) onIdToken;

  @override
  Widget build(BuildContext context) => child;
}
