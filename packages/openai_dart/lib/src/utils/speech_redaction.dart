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

/// Identifies private operations whose text or binary bodies require redaction.
bool isPrivateAudioRequest(http.BaseRequest? request) =>
    isSpeechRequest(request) ||
    isAudioFileRequest(request) ||
    isVoiceConsentRequest(request) ||
    isCustomVoiceRequest(request) ||
    isLiveRequest(request) ||
    isAgentsApiRequest(request);

/// Identifies implemented Agents routes containing private configuration/input.
bool isAgentsApiRequest(http.BaseRequest? request) =>
    isSavedAgentRequest(request) || isAgentSessionRequest(request);

/// Identifies the seven raw session/event operations, including custom bases.
bool isAgentSessionRequest(http.BaseRequest? request) {
  if (request == null) return false;
  final segments = request.url.pathSegments;
  final collection =
      segments.length >= 2 &&
      segments[segments.length - 2] == 'agents' &&
      segments.last == 'sessions' &&
      const {'GET', 'POST'}.contains(request.method);
  final item =
      segments.length >= 3 &&
      segments[segments.length - 3] == 'agents' &&
      segments[segments.length - 2] == 'sessions' &&
      const {'GET', 'POST', 'DELETE'}.contains(request.method);
  final events =
      segments.length >= 4 &&
      segments[segments.length - 4] == 'agents' &&
      segments[segments.length - 3] == 'sessions' &&
      segments.last == 'events' &&
      const {'GET', 'POST'}.contains(request.method);
  return collection || item || events;
}

/// Identifies the five saved-agent operations, including custom base paths.
///
/// Saved instructions, metadata, MCP headers and setup commands are private.
/// Other Agents routes remain separately scoped to their implementation tickets.
bool isSavedAgentRequest(http.BaseRequest? request) {
  if (request == null) return false;
  final segments = request.url.pathSegments;
  final collection =
      segments.isNotEmpty &&
      segments.last == 'agents' &&
      const {'GET', 'POST'}.contains(request.method);
  final item =
      segments.length >= 2 &&
      segments[segments.length - 2] == 'agents' &&
      const {'GET', 'POST', 'DELETE'}.contains(request.method);
  return collection || item;
}

/// Identifies the seven Live HTTP operations, including custom base paths.
bool isLiveRequest(http.BaseRequest? request) {
  if (request == null) return false;
  final segments = request.url.pathSegments;
  if (segments.length >= 2 &&
      segments[segments.length - 2] == 'live' &&
      segments.last == 'sessions') {
    return request.method == 'POST';
  }
  if (segments.length < 4 ||
      segments[segments.length - 4] != 'live' ||
      segments[segments.length - 3] != 'sessions') {
    return false;
  }
  return segments.last == 'content'
      ? request.method == 'GET'
      : request.method == 'POST' &&
            const {
              'accept',
              'fork',
              'hangup',
              'refer',
              'reject',
            }.contains(segments.last);
}

/// Identifies the single custom voice creation operation.
bool isCustomVoiceRequest(http.BaseRequest? request) =>
    request != null &&
    request.method == 'POST' &&
    request.url.path.endsWith('/audio/voices');

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
