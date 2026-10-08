import 'package:http/http.dart' as http;

/// Identifies the speech operation, including an application's base path.
bool isSpeechRequest(http.BaseRequest? request) =>
    request != null &&
    request.method == 'POST' &&
    request.url.path.endsWith('/audio/speech');

/// Retains caller-readable HTTP context while redacting speech diagnostics.
bool isSpeechResponse(Object? cause) =>
    cause is http.BaseResponse && isSpeechRequest(cause.request);
