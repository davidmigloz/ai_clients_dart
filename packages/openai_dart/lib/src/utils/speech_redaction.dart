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
    isSpeechRequest(request) ||
    isAudioFileRequest(request) ||
    isVoiceConsentRequest(request);

/// Identifies the five consent operations, including opaque encoded IDs.
bool isVoiceConsentRequest(http.BaseRequest? request) {
  if (request == null) return false;
  final segments = request.url.pathSegments;
  final collection =
      segments.length >= 2 &&
      segments[segments.length - 2] == 'audio' &&
      segments.last == 'voice_consents';
  final item =
      segments.length >= 3 &&
      segments[segments.length - 3] == 'audio' &&
      segments[segments.length - 2] == 'voice_consents';
  return (collection && const {'GET', 'POST'}.contains(request.method)) ||
      (item && const {'GET', 'POST', 'DELETE'}.contains(request.method));
}

/// Retains explicit caller HTTP data while redacting audio diagnostics.
bool isPrivateAudioResponse(Object? cause) =>
    cause is http.BaseResponse && isPrivateAudioRequest(cause.request);
