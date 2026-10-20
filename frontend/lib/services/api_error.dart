import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

enum ApiErrorKind {
  network,
  timeout,
  authentication,
  authorization,
  validation,
  notFound,
  rateLimited,
  server,
  malformed,
  unknown,
}

class ApiError implements Exception {
  const ApiError({
    required this.kind,
    required this.message,
    this.httpStatus,
    this.retryAfter,
  });

  final ApiErrorKind kind;
  final int? httpStatus;
  final String message;
  final Duration? retryAfter;

  bool get outcomeMayBeUnknown =>
      kind == ApiErrorKind.network || kind == ApiErrorKind.timeout;

  factory ApiError.fromResponse(http.Response response) {
    String? serverMessage;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        serverMessage =
            decoded['error'] as String? ??
            decoded['message'] as String? ??
            decoded['detail'] as String?;
      }
    } on FormatException {
      final body = response.body.trim();
      if (body.isNotEmpty) serverMessage = body;
    }

    final retrySeconds = int.tryParse(response.headers['retry-after'] ?? '');
    final kind = switch (response.statusCode) {
      401 => ApiErrorKind.authentication,
      403 => ApiErrorKind.authorization,
      404 => ApiErrorKind.notFound,
      429 => ApiErrorKind.rateLimited,
      >= 400 && < 500 => ApiErrorKind.validation,
      >= 500 => ApiErrorKind.server,
      _ => ApiErrorKind.unknown,
    };
    return ApiError(
      kind: kind,
      httpStatus: response.statusCode,
      message: serverMessage ?? 'Request failed (${response.statusCode}).',
      retryAfter: retrySeconds == null ? null : Duration(seconds: retrySeconds),
    );
  }

  factory ApiError.from(Object error) {
    if (error is ApiError) return error;
    if (error is TimeoutException) {
      return const ApiError(
        kind: ApiErrorKind.timeout,
        message: 'Request timed out.',
      );
    }
    if (error is http.ClientException) {
      return const ApiError(
        kind: ApiErrorKind.network,
        message: 'Network connection failed.',
      );
    }
    if (error is FormatException || error is TypeError) {
      return const ApiError(
        kind: ApiErrorKind.malformed,
        message: 'The server returned an invalid response.',
      );
    }
    return ApiError(kind: ApiErrorKind.unknown, message: error.toString());
  }

  @override
  String toString() => message;
}
