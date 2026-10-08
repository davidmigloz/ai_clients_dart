import 'dart:convert';

import 'package:http/http.dart' as http;

import '../client/retry_after.dart';
import '../errors/exceptions.dart';
import 'webhooks/signing_secret_redaction.dart';

/// Preserves the shared HTTP error contract for an unsuccessful response.
///
/// Status selection belongs to the caller. Original bytes, advertised charset,
/// headers and request context remain available through the exception cause.
ApiException parseHttpErrorResponse(
  http.Response response, {
  required http.BaseRequest request,
}) {
  final secretBearingResponse = revealsWebhookSigningSecret(request);
  final statusCode = response.statusCode;
  final requestId = response.headers['x-request-id'];
  final retryAfter = parseRetryAfter(response.headers);
  // A malformed body cannot replace the original HTTP status/error class.
  // Exact bytes remain available in the caller-readable response cause.
  final responseText = _errorResponseText(response);

  final diagnosticBody = redactWebhookSigningSecretBody(
    responseText,
    secretBearingResponse: secretBearingResponse,
  );

  // Try to parse the error body
  String message;
  String? type;
  String? code;
  String? param;
  Map<String, dynamic>? body;

  try {
    final json = jsonDecode(responseText) as Map<String, dynamic>;
    body = json;

    if (json['error'] case final Map<String, dynamic> error) {
      message = error['message'] == null
          ? 'Unknown error'
          : _errorString(error['message']) ?? diagnosticBody;
      type = _errorString(error['type']);
      code = _errorString(error['code']);
      param = _errorString(error['param']);
    } else {
      message = _errorString(json['message']) ?? diagnosticBody;
    }
  } catch (_) {
    // Keep unrelated raw-body behavior; omit malformed secret-bearing bodies.
    message = diagnosticBody.isNotEmpty
        ? diagnosticBody
        : 'HTTP $statusCode error';
  }

  return createApiException(
    statusCode: statusCode,
    message: redactWebhookSecretErrorValue(message, body)!,
    type: type,
    code: code,
    param: param,
    requestId: requestId,
    body: body,
    retryAfter: retryAfter,
    // Retain original bytes and headers for explicit caller inspection.
    // Exception diagnostics never render this response body automatically.
    cause: response.request != null
        ? response
        : http.Response.bytes(
            response.bodyBytes,
            response.statusCode,
            request: request,
            headers: response.headers,
            isRedirect: response.isRedirect,
            persistentConnection: response.persistentConnection,
            reasonPhrase: response.reasonPhrase,
          ),
  );
}

String _errorResponseText(http.Response response) {
  try {
    return response.body;
  } on FormatException {
    return utf8.decode(response.bodyBytes, allowMalformed: true);
  }
}

String? _errorString(Object? value) => value is String ? value : null;
