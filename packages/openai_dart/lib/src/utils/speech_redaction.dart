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
    isSavedAgentRequest(request) ||
    isAgentSessionRequest(request) ||
    isVaultRequest(request) ||
    isAgentEnvironmentRequest(request) ||
    isAgentFileRequest(request);

/// Identifies implemented raw session/event/history operations, including custom bases.
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
  final history =
      request.method == 'GET' &&
      ((segments.length >= 4 &&
              segments[segments.length - 4] == 'agents' &&
              segments[segments.length - 3] == 'sessions' &&
              const {'items', 'turns', 'traces'}.contains(segments.last)) ||
          (segments.length >= 5 &&
              segments[segments.length - 5] == 'agents' &&
              segments[segments.length - 4] == 'sessions' &&
              segments[segments.length - 2] == 'turns') ||
          (segments.length >= 6 &&
              segments[segments.length - 6] == 'agents' &&
              segments[segments.length - 5] == 'sessions' &&
              segments[segments.length - 3] == 'turns' &&
              segments.last == 'items'));
  return collection ||
      item ||
      events ||
      history ||
      isAgentSessionSubagentRequest(request);
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

/// Identifies all ten private Vault/credential routes, including custom bases.
bool isVaultRequest(http.BaseRequest? request) {
  if (request == null) return false;
  final s = request.url.pathSegments;
  final collection =
      s.isNotEmpty &&
      s.last == 'vaults' &&
      const {'GET', 'POST'}.contains(request.method);
  final vault =
      s.length >= 2 &&
      s[s.length - 2] == 'vaults' &&
      const {'GET', 'POST', 'DELETE'}.contains(request.method);
  final credentials =
      s.length >= 3 &&
      s[s.length - 3] == 'vaults' &&
      s.last == 'credentials' &&
      const {'GET', 'POST'}.contains(request.method);
  final credential =
      s.length >= 4 &&
      s[s.length - 4] == 'vaults' &&
      s[s.length - 2] == 'credentials' &&
      const {'GET', 'POST', 'DELETE'}.contains(request.method);
  return collection || vault || credentials || credential;
}

/// Implemented environment/template routes, including custom base paths.
bool isAgentEnvironmentRequest(http.BaseRequest? request) {
  if (request == null) return false;
  final s = request.url.pathSegments;
  if (s.length >= 2 &&
      s[s.length - 2] == 'agents' &&
      s.last == 'environments') {
    return const {'GET', 'POST'}.contains(request.method);
  }
  if (s.length >= 3 &&
      s[s.length - 3] == 'agents' &&
      s[s.length - 2] == 'environments') {
    return request.method == 'GET' ||
        (s.last == 'templates' && request.method == 'POST');
  }
  return s.length >= 4 &&
      s[s.length - 4] == 'agents' &&
      s[s.length - 3] == 'environments' &&
      s[s.length - 2] == 'templates' &&
      const {'GET', 'POST', 'DELETE'}.contains(request.method);
}

/// Six live-file/artifact routes; paths, inline contents and metadata are private.
bool isAgentFileRequest(http.BaseRequest? request) {
  if (request == null) return false;
  final s = request.url.pathSegments;
  if (s.length >= 4 && s[s.length - 4] == 'agents') {
    if (s[s.length - 3] == 'environments' && s.last == 'files') {
      return const {'GET', 'POST'}.contains(request.method);
    }
    if (s[s.length - 3] == 'sessions' && s.last == 'artifacts') {
      return request.method == 'GET';
    }
  }
  if (s.length >= 5 &&
      s[s.length - 5] == 'agents' &&
      s[s.length - 4] == 'sessions' &&
      s[s.length - 2] == 'artifacts') {
    return const {'GET', 'DELETE'}.contains(request.method);
  }
  return s.length >= 6 &&
      s[s.length - 6] == 'agents' &&
      s[s.length - 5] == 'sessions' &&
      s[s.length - 3] == 'artifacts' &&
      s.last == 'content' &&
      request.method == 'GET';
}

/// Six implemented child inspection routes, including custom bases and IDs.
bool isAgentSessionSubagentRequest(http.BaseRequest? request) {
  if (request == null) return false;
  if (request.method != 'GET') return false;
  final s = request.url.pathSegments;
  for (final tail in [4, 5, 6, 7, 8]) {
    final offset = s.length - tail;
    if (offset < 0 ||
        s[offset] != 'agents' ||
        s[offset + 1] != 'sessions' ||
        s[offset + 3] != 'subagents') {
      continue;
    }
    if (tail == 4 || tail == 5) return true;
    if (tail == 6 && const {'items', 'turns'}.contains(s.last)) return true;
    if (tail == 7 && s[offset + 5] == 'turns') return true;
    if (tail == 8 && s[offset + 5] == 'turns' && s.last == 'items') return true;
  }
  return false;
}
