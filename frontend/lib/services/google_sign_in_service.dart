import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'google_sign_in_configuration.dart';

class GoogleSignInService {
  GoogleSignInService({
    GoogleSignIn? googleSignIn,
    GoogleSignInConfiguration configuration =
        GoogleSignInConfiguration.fromEnvironment,
  }) : _googleSignIn =
           googleSignIn ??
           GoogleSignIn(
             scopes: const ['email'],
             clientId: kIsWeb ? configuration.clientId : null,
             serverClientId: kIsWeb ? null : configuration.serverClientId,
           );

  static final GoogleSignInService instance = GoogleSignInService();

  final GoogleSignIn _googleSignIn;

  Stream<GoogleSignInAccount?> get onCurrentUserChanged =>
      _googleSignIn.onCurrentUserChanged;

  Future<String?> signInForIdToken() async {
    if (kIsWeb) return null;
    final account = await _googleSignIn.signIn();
    return idTokenFor(account);
  }

  Future<String?> idTokenFor(GoogleSignInAccount? account) async {
    if (account == null) return null;
    return (await account.authentication).idToken;
  }
}
