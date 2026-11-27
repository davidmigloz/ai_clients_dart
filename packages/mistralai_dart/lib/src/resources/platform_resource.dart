import 'dart:convert';

import 'package:http/http.dart' as http;

import '../errors/exceptions.dart';
import 'base_resource.dart';

/// Shared transport for JSON identity and platform endpoints.
mixin PlatformResource on ResourceBase {
  /// Sends JSON through the client's authentication, retries and errors.
  Future<T> requestPlatform<T>(
    String method,
    String path,
    T Function(Object?) decode, {
    Map<String, String>? query,
    Map<String, dynamic>? body,
    bool authInApiKeyHeader = false,
    bool redactErrorBody = false,
  }) async {
    ensureNotClosed?.call();
    final request = http.Request(
      method,
      requestBuilder.buildUrl(path, queryParams: query),
    )..headers.addAll(requestBuilder.buildHeaders());
    // Platform dashboard keys are custom headers. HTTP redirect handling
    // may forward them across hosts, and webhook redirects can expose bodies.
    final sensitiveRequest =
        authInApiKeyHeader ||
        request.headers.containsKey('x-api-key') ||
        redactErrorBody;
    request.followRedirects = !sensitiveRequest;
    request.headers.putIfAbsent('Accept', () => 'application/json');
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }

    final response = await interceptorChain.execute(
      request,
      authInApiKeyHeader: authInApiKeyHeader,
      redactErrorBody: redactErrorBody,
    );
    if (sensitiveRequest &&
        response.statusCode >= 300 &&
        response.statusCode < 400) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Unexpected redirect from the Mistral platform API.',
      );
    }
    try {
      return decode(response.body.isEmpty ? null : jsonDecode(response.body));
    } on FormatException {
      if (redactErrorBody) {
        throw const FormatException('Invalid platform response.');
      }
      rethrow;
    }
  }
}
