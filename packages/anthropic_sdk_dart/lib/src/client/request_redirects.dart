import 'dart:async';

import 'package:http/http.dart' as http;

import '../errors/exceptions.dart';
import '../errors/response_error.dart';

/// Sends a request without forwarding an API key to a different origin.
///
/// Standard Authorization is handled by the underlying client. Dart IO and
/// browser Fetch can both forward x-api-key across origins, so requests using
/// it require an explicit redirect check. BrowserClient rejects redirects when
/// automatic following is disabled and does not expose their locations.
Future<http.StreamedResponse> sendApiRequest(
  http.Client client,
  http.BaseRequest request,
) {
  if (!request.followRedirects ||
      request.headers['x-api-key']?.isNotEmpty != true) {
    return client.send(request);
  }
  return _sendApiKeyRequest(client, request);
}

Future<http.StreamedResponse> _sendApiKeyRequest(
  http.Client client,
  http.BaseRequest request,
) async {
  var current = request..followRedirects = false;
  final origin = request.url;
  final watch = Stopwatch()..start();
  final abort = request is http.Abortable ? request.abortTrigger : null;
  var aborted = false;
  final subscription = abort?.asStream().listen(
    (_) => aborted = true,
    onError: (Object _, StackTrace _) {},
  );
  try {
    for (var redirects = 0; ; redirects++) {
      final response = await client.send(current);
      final method = _redirectMethod(current.method, response.statusCode);
      if (method == null) return response;
      response.stream
          .listen(null, onError: (Object _, StackTrace _) {})
          .cancel()
          .ignore();

      if (abort != null) {
        // A deadline or caller abort can complete alongside this response.
        await Future<void>.delayed(Duration.zero);
        if (aborted) throw http.RequestAbortedException(current.url);
      }
      final target = _redirectTarget(current.url, response.headers);
      final error = switch (target) {
        null => 'HTTP redirect has no valid location',
        _ when !_sameOrigin(origin, target) =>
          'Refusing to forward an API key to a different origin',
        _ when redirects >= request.maxRedirects =>
          'HTTP redirect limit reached',
        _ => null,
      };
      if (error != null) {
        throw ApiException(
          statusCode: response.statusCode,
          message: error,
          responseMetadata: createSafeResponseMetadata(
            statusCode: response.statusCode,
            headers: response.headers,
            latency: watch.elapsed,
          ),
        );
      }
      current = http.AbortableRequest(method, target!, abortTrigger: abort)
        ..followRedirects = false
        ..persistentConnection = current.persistentConnection
        ..headers.addAll(current.headers)
        ..headers.remove('content-length')
        ..headers.remove('transfer-encoding');
    }
  } finally {
    unawaited(subscription?.cancel());
  }
}

// Keep the native client's automatic redirect methods. These hops carry no body.
String? _redirectMethod(String method, int status) =>
    switch ((method, status)) {
      ('GET' || 'HEAD', 301 || 302 || 303 || 307 || 308) => method,
      ('POST', 303) => 'GET',
      _ => null,
    };

Uri? _redirectTarget(Uri current, Map<String, String> headers) {
  for (final MapEntry(key: name, value: location) in headers.entries) {
    if (name.toLowerCase() != 'location' || location.trim().isEmpty) continue;
    final target = Uri.tryParse(location.trim());
    return target == null ? null : current.resolveUri(target);
  }
  return null;
}

bool _sameOrigin(Uri origin, Uri target) =>
    target.userInfo.isEmpty &&
    origin.scheme == target.scheme &&
    origin.host == target.host &&
    origin.port == target.port;
