import 'package:http/http.dart' as http;

/// Identifies the speech operation, including an application's base path.
bool isSpeechRequest(http.BaseRequest? request) =>
    request != null &&
    request.method == 'POST' &&
    request.url.path.endsWith('/audio/speech');

/// Retains caller-readable HTTP context while redacting speech diagnostics.
bool isSpeechResponse(Object? cause) =>
    cause is http.BaseResponse && isSpeechRequest(cause.request);

/// Identifies the file-audio operations, including a custom application base path.
bool isAudioFileRequest(http.BaseRequest? request) =>
    request != null &&
    request.method == 'POST' &&
    (request.url.path.endsWith('/audio/transcriptions') ||
        request.url.path.endsWith('/audio/translations'));

/// Identifies audio operations whose text or binary bodies require redaction.
bool isPrivateAudioRequest(http.BaseRequest? request) =>
    isSpeechRequest(request) || isAudioFileRequest(request);

/// Retains explicit caller HTTP data while redacting audio diagnostics.
bool isPrivateAudioResponse(Object? cause) =>
    cause is http.BaseResponse && isPrivateAudioRequest(cause.request);
