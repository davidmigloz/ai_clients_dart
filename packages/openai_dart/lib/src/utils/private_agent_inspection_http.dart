import 'package:http/http.dart' as http;

import '../errors/exceptions.dart';
import '../platform/http_utils.dart';
import 'speech_redaction.dart';

/// Guards caller callbacks for child inspection, automations and image routes.
/// Original external failures remain explicit causes; automatic diagnostics
/// never render provider, connector or response-stream values.
T privateAgentInspectionExternal<T>(
  http.BaseRequest? request,
  T Function() callback, {
  bool redactDiagnostics = false,
}) {
  if (!isAgentSessionSubagentRequest(request) &&
      !isAgentAutomationRequest(request) &&
      !isImagesRequest(request) &&
      !redactDiagnostics) {
    return callback();
  }
  try {
    return callback();
  } catch (error) {
    throw ConnectionException(
      message: redactDiagnostics
          ? 'Private request callback failed'
          : 'Agents external callback failed',
      cause: error,
      redactDiagnostics: true,
    );
  }
}

/// Guards only transport-origin failures, leaving local HTTP, timeout, parse
/// and abort exceptions to their existing policy and concrete classes.
Future<T> privateAgentInspectionTransport<T>(
  http.BaseRequest request,
  Future<T> Function() callback, {
  bool redactDiagnostics = false,
}) async {
  if (!isAgentSessionSubagentRequest(request) &&
      !isAgentAutomationRequest(request) &&
      !isImagesRequest(request) &&
      !redactDiagnostics) {
    return callback();
  }
  try {
    return await callback();
  } catch (error) {
    if (error is http.RequestAbortedException) rethrow;
    if (redactDiagnostics) {
      if (error is AbortedException || error is RequestTimeoutException) {
        rethrow;
      }
      if (error is http.ClientException || isSocketException(error)) {
        throw _PrivateHttpTransportException(error, request.url);
      }
      throw ConnectionException(
        message: 'Private request transport failed',
        url: request.url.toString(),
        cause: error,
        redactDiagnostics: true,
      );
    }
    throw ConnectionException(
      message: 'Agents transport failed',
      cause: error,
      redactDiagnostics: true,
    );
  }
}

/// Retains existing idempotent network retry classification for an explicitly
/// private transport failure. Provider callbacks use the ordinary non-retryable
/// ConnectionException above, so credential failures are not replayed.
final class _PrivateHttpTransportException extends ConnectionException
    implements http.ClientException {
  _PrivateHttpTransportException(Object error, this.uri)
    : super(
        message: 'Private request transport failed',
        url: uri.toString(),
        cause: error,
        redactDiagnostics: true,
      );

  @override
  final Uri uri;
}
