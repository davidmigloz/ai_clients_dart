import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../client/interceptor_chain.dart';
import '../errors/exceptions.dart';
import '../platform/http_utils.dart';
import 'http_error_response.dart';

/// Sends a private audio request through the shared HTTP policy.
///
/// Original caller context remains readable; automatic diagnostics redact it.
/// Retry eligibility is determined by the existing interceptor chain.
Future<http.Response> sendPrivateAudioRequest(
  http.BaseRequest request, {
  required InterceptorChain interceptorChain,
  required String context,
  Future<void>? abortTrigger,
}) async {
  try {
    final response = await interceptorChain.execute(
      request,
      abortTrigger: abortTrigger,
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw parseHttpErrorResponse(response, request: request);
    }
    return response;
  } on AbortedException catch (error) {
    throw AbortedException(
      message: error.message,
      stage: error.stage,
      correlationId: error.correlationId,
      timestamp: error.timestamp,
      cause: error.cause ?? error,
      redactDiagnostics: true,
    );
  } on http.ClientException catch (error) {
    throw ConnectionException(
      message: error.message,
      url: error.uri?.toString() ?? request.url.toString(),
      cause: error,
      redactDiagnostics: true,
    );
  } catch (error) {
    if (isSocketException(error)) {
      throw ConnectionException(
        message: '$context connection failed',
        url: request.url.toString(),
        cause: error,
        redactDiagnostics: true,
      );
    }
    rethrow;
  }
}

/// Parses a UTF-8 JSON audio response with value-safe automatic diagnostics.
T parsePrivateAudioResponse<T>(
  http.Response response,
  T Function(Map<String, dynamic>) parse,
  String context,
) {
  final responseBody = utf8.decode(response.bodyBytes, allowMalformed: true);
  final Map<String, dynamic> json;
  try {
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected a JSON object.');
    }
    json = decoded;
  } on FormatException {
    throw ParseException(
      message: 'Invalid $context response: expected a UTF-8 JSON object.',
      responseBody: responseBody,
      cause: const FormatException('Expected a UTF-8 JSON object.'),
    );
  }

  try {
    return parse(json);
  } on FormatException catch (error) {
    // Model parsers provide field context without including received values.
    // Strip any source attached to a FormatException before retaining it.
    throw ParseException(
      message: 'Invalid $context response: ${error.message}',
      responseBody: responseBody,
      cause: FormatException(error.message),
    );
  } on TypeError {
    throw ParseException(
      message: 'Invalid $context response: a known field has an invalid type.',
      responseBody: responseBody,
      cause: const FormatException('A known field has an invalid type.'),
    );
  } on ArgumentError {
    throw ParseException(
      message: 'Invalid $context response: a known field is invalid.',
      responseBody: responseBody,
      cause: const FormatException('A known field is invalid.'),
    );
  }
}

/// Detects cancellation before authentication or dispatch.
Future<void> checkPrivateAudioAbort(
  Future<void>? abortTrigger,
  String context,
) async {
  if (abortTrigger == null) return;
  var aborted = false;
  unawaited(
    abortTrigger.then<void>(
      (_) => aborted = true,
      onError: (Object _, StackTrace _) => aborted = true,
    ),
  );
  await Future<void>.value();
  if (aborted) {
    throw AbortedException(
      message: '$context request aborted before dispatch',
      stage: AbortionStage.beforeRequest,
    );
  }
}
