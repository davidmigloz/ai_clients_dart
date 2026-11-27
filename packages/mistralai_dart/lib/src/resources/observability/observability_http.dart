import 'dart:convert';

import 'package:http/http.dart' as http;

import '../base_resource.dart';

/// Shared JSON transport for the Observability resources.
extension ObservabilityHttp on ResourceBase {
  /// Sends one request with the client's auth, retries, and error handling.
  Future<http.Response> sendObservability(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
  }) {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/observability/$path',
      queryParams: query,
    );
    final request = http.Request(method, url)
      ..headers.addAll(
        requestBuilder.buildHeaders(
          additionalHeaders: {
            'Accept': 'application/json',
            if (body != null) 'Content-Type': 'application/json',
          },
        ),
      );
    if (body != null) request.body = jsonEncode(body);
    return interceptorChain.execute(request);
  }

  /// Sends one request and decodes its JSON response object.
  Future<T> readObservability<T>(
    String method,
    String path,
    T Function(Map<String, dynamic>) decode, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
  }) async {
    final response = await sendObservability(
      method,
      path,
      query: query,
      body: body,
    );
    return decode(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
