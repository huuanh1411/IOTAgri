import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:iotagri_app/services/api_error.dart';

void main() {
  test('parses structured rate-limit responses and Retry-After', () {
    final error = ApiError.fromResponse(
      http.Response(
        '{"message":"Slow down"}',
        429,
        headers: {'retry-after': '900'},
      ),
    );
    expect(error.kind, ApiErrorKind.rateLimited);
    expect(error.message, 'Slow down');
    expect(error.retryAfter, const Duration(seconds: 900));
  });

  test('keeps a plain-text backend error', () {
    final error = ApiError.fromResponse(http.Response('Invalid device', 400));
    expect(error.kind, ApiErrorKind.validation);
    expect(error.message, 'Invalid device');
  });
}
