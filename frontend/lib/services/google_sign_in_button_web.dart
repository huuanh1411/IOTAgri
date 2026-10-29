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
  late final Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    final googleSignIn = GoogleSignInService.instance;
    _subscription = googleSignIn.onCurrentUserChanged.listen((account) async {
      final idToken = await googleSignIn.idTokenFor(account);
      if (idToken != null) await widget.onIdToken(idToken);
    });
    _initialization = googleSignIn.initialize();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
    future: _initialization,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return ErrorWidget.withDetails(
          message: 'Google Sign-In initialization failed: ${snapshot.error}',
        );
      }
      if (snapshot.connectionState != ConnectionState.done) {
        return const SizedBox(height: 40);
      }
      return google_sign_in_web.renderButton();
    },
  );
}
