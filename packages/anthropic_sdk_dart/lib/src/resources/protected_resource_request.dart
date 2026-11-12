import 'dart:convert';

import 'package:http/http.dart' as http;

import '../auth/request_auth.dart';
import '../client/interceptor_chain.dart';
import '../errors/exceptions.dart';
import '../errors/response_error.dart';
import '../interceptors/auth_interceptor.dart';
import '../interceptors/interceptor.dart';
import 'base_resource.dart';

/// Sends a secret-bearing request without copying credentials or response
/// bodies into diagnostics. Uses the normal request-scoped transport pipeline.
Future<T> sendProtectedResourceRequest<T>(
  ResourceBase resource,
  http.Request request,
  T Function(Object?) decode, {
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
  final credentials = <String>{};
  final chain = InterceptorChain(
    interceptors: [
      if (bearerToken == null)
        ...resource.interceptorChain.interceptors.whereType<AuthInterceptor>(),
      _CaptureProtectedCredentials(credentials),
    ],
    httpClient: resource.httpClient,
    retryWrapper: resource.interceptorChain.retryWrapper,
    timeout: resource.interceptorChain.timeout,
    ensureNotClosed: resource.ensureNotClosed,
  );
  final watch = Stopwatch()..start();
  final response = await chain.execute(
    request,
    abortTrigger: abortTrigger,
    redirectErrorMessage: 'Unexpected redirect from the Claude API',
  );
  watch.stop();
  final status = response.statusCode;
  if (status < 200 || status >= 300) {
    credentials.addAll(responseCredentialValues(response));
    final body = decodeApiErrorResponse(response);
    final parsed = parseApiErrorBody(body, credentials: credentials);
    final metadata = createSafeResponseMetadata(
      statusCode: status,
      headers: response.headers,
      latency: watch.elapsed,
      bodyRequestId: parsed.requestId,
      credentials: credentials,
    );
    final specific = handleError?.call(
      redactApiErrorBody(body, credentials),
      metadata,
    );
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
    return decode(jsonDecode(response.body));
  } on Object catch (error, stackTrace) {
    if (error is! FormatException && error is! TypeError) rethrow;
    // Both JSON and model decoding can attach newly issued secrets.
    Error.throwWithStackTrace(
      const FormatException('Invalid JSON in protected API response'),
      stackTrace,
    );
  }
}

// Auth providers can copy the request, and injected transports need not attach
// the final request to their response. Observe the effective request here.
final class _CaptureProtectedCredentials implements Interceptor {
  const _CaptureProtectedCredentials(this._credentials);

  final Set<String> _credentials;

  @override
  Future<http.Response> intercept(
    RequestContext context,
    InterceptorNext next,
  ) {
    _credentials.addAll(requestCredentialValues(context.request.headers));
    return next(context);
  }
}
