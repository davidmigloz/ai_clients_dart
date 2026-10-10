import 'package:http/http.dart' as http;

import '../errors/exceptions.dart';
import 'speech_redaction.dart';

/// Guards caller-provided synchronous callbacks for child inspection routes.
/// Original external failures remain explicit causes; automatic diagnostics
/// never render provider, connector or response-stream values.
T privateAgentInspectionExternal<T>(
  http.BaseRequest request,
  T Function() callback,
) {
  if (!isAgentSessionSubagentRequest(request)) return callback();
  try {
    return callback();
  } catch (error) {
    throw ConnectionException(
      message: 'Agents child inspection external callback failed',
      cause: error,
      redactDiagnostics: true,
    );
  }
}

/// Guards only transport-origin failures, leaving local HTTP, timeout, parse
/// and abort exceptions to their existing policy and concrete classes.
Future<T> privateAgentInspectionTransport<T>(
  http.BaseRequest request,
  Future<T> Function() callback,
) async {
  if (!isAgentSessionSubagentRequest(request)) return callback();
  try {
    return await callback();
  } catch (error) {
    if (error is http.RequestAbortedException) rethrow;
    throw ConnectionException(
      message: 'Agents child inspection transport failed',
      cause: error,
      redactDiagnostics: true,
    );
  }
}
