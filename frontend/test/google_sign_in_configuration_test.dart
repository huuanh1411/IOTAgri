import 'package:flutter_test/flutter_test.dart';
import 'package:iotagri_app/services/google_sign_in_configuration.dart';

void main() {
  test('web configuration uses web client ID as Google client ID', () {
    const config = GoogleSignInConfiguration(
      webClientId: 'web-client.apps.googleusercontent.com',
      androidServerClientId: 'android-server.apps.googleusercontent.com',
    );

    expect(config.webClientId, 'web-client.apps.googleusercontent.com');
    expect(config.clientId, 'web-client.apps.googleusercontent.com');
    expect(config.serverClientId, 'android-server.apps.googleusercontent.com');
  });
}
