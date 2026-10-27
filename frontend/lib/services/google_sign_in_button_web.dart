import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:google_sign_in_web/web_only.dart' as google_sign_in_web;

import 'google_sign_in_service.dart';

class GoogleSignInWebButton extends StatefulWidget {
  const GoogleSignInWebButton({
    super.key,
    required this.child,
    required this.onIdToken,
  });

  final Widget child;
  final Future<void> Function(String idToken) onIdToken;

  @override
  State<GoogleSignInWebButton> createState() => _GoogleSignInWebButtonState();
}

class _GoogleSignInWebButtonState extends State<GoogleSignInWebButton> {
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = GoogleSignInService.instance.onCurrentUserChanged.listen((
      account,
    ) async {
      final idToken = await GoogleSignInService.instance.idTokenFor(account);
      if (idToken != null) await widget.onIdToken(idToken);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => google_sign_in_web.renderButton();
}
