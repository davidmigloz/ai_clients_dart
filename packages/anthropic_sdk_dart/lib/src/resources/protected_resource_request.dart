import 'dart:convert';

import 'package:http/http.dart' as http;

import '../client/interceptor_chain.dart';
import '../errors/exceptions.dart';
import '../errors/response_error.dart';
import '../interceptors/auth_interceptor.dart';
import 'base_resource.dart';

/// Sends a secret-bearing request without copying credentials or response
/// bodies into diagnostics. Uses the normal request-scoped transport pipeline.
Future<Object?> sendProtectedResourceRequest(
  ResourceBase resource,
  http.Request request, {
  String? bearerToken,
  Future<void>? abortTrigger,
  AnthropicException? Function(String, ResponseMetadata)? handleError,
}) async {
  request.followRedirects = false;
  if (bearerToken != null) {
    if (bearerToken.trim().isEmpty || bearerToken.contains(RegExp(r'[\r\n]'))) {
      throw ArgumentError('Bearer token is empty or contains a line break');
    }
    request.headers
      ..remove('x-api-key')
      ..['authorization'] = 'Bearer $bearerToken';
  }
  final chain = InterceptorChain(
    interceptors: [
      if (bearerToken == null)
        ...resource.interceptorChain.interceptors.whereType<AuthInterceptor>(),
    ],
    httpClient: resource.httpClient,
    retryWrapper: resource.interceptorChain.retryWrapper,
    ensureNotClosed: resource.ensureNotClosed,
  );
  final watch = Stopwatch()..start();
  final response = await chain.execute(request, abortTrigger: abortTrigger);
  watch.stop();
  final status = response.statusCode;
  if (status < 200 || status >= 300) {
    final body = decodeApiErrorResponse(response);
    final parsed = parseApiErrorBody(body);
    final metadata = createSafeResponseMetadata(
      statusCode: status,
      headers: response.headers,
      latency: watch.elapsed,
      bodyRequestId: parsed.requestId,
    );
    final specific = handleError?.call(body, metadata);
    if (specific != null) throw specific;
    final message = 'HTTP $status from the Claude API';
    throw switch (status) {
      401 => AuthenticationException(
        message: message,
        errorCode: parsed.errorCode,
        responseMetadata: metadata,
      ),
      429 => RateLimitException(
        statusCode: status,
        message: message,
        errorCode: parsed.errorCode,
        responseMetadata: metadata,
        retryAfter: retryAfterTime(metadata.headers),
      ),
      _ => ApiException(
        statusCode: status,
        message: message,
        errorCode: parsed.errorCode,
        responseMetadata: metadata,
      ),
    };
  }
  try {
    return jsonDecode(response.body);
  } on FormatException {
    // A decoder may attach the entire response body to the exception.
    throw const FormatException('Invalid JSON in protected API response');
  }
}
