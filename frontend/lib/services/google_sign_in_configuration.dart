class GoogleSignInConfiguration {
  static const fromEnvironment = GoogleSignInConfiguration(
    webClientId: String.fromEnvironment('GOOGLE_WEB_CLIENT_ID'),
    androidServerClientId: String.fromEnvironment(
      'GOOGLE_ANDROID_SERVER_CLIENT_ID',
    ),
  );

  const GoogleSignInConfiguration({
    required this.webClientId,
    required this.androidServerClientId,
  });

  final String webClientId;
  final String androidServerClientId;

  String? get clientId => webClientId.isEmpty ? null : webClientId;
  String? get serverClientId =>
      androidServerClientId.isEmpty ? null : androidServerClientId;
}
