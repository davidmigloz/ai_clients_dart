import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/audio_agents/audio_agent.dart';
import '../../models/audio_agents/audio_session.dart';
import '../base_resource.dart';

/// Versioned audio agent configurations and their recorded sessions.
final class AudioAgentsResource extends _AudioAgentResource {
  /// Creates the audio agents resource.
  AudioAgentsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  static const _collection = '/v1/audio/agents';

  String _agent(String id) => '$_collection/${Uri.encodeComponent(id)}';

  /// Saves an audio agent configuration.
  Future<AudioAgent> create({required CreateAudioAgentRequest request}) =>
      _json('POST', _collection, AudioAgent.fromJson, body: request.toJson());

  /// Lists saved agents, optionally matching a name substring.
  Future<AudioAgentListPage> list({
    int? pageSize,
    String? pageToken,
    String? search,
  }) => _json(
    'GET',
    _collection,
    AudioAgentListPage.fromJson,
    query: {
      'page_size': ?pageSize?.toString(),
      'page_token': ?pageToken,
      'search': ?search,
    },
  );

  /// Gets the latest version or a specific [version] of an agent.
  Future<AudioAgent> get({required String agentId, int? version}) => _json(
    'GET',
    _agent(agentId),
    AudioAgent.fromJson,
    query: {'version': ?version?.toString()},
  );

  /// Creates a new version of a saved audio agent.
  Future<AudioAgent> update({
    required String agentId,
    required UpdateAudioAgentRequest request,
  }) => _json(
    'PUT',
    _agent(agentId),
    AudioAgent.fromJson,
    body: request.toJson(),
  );

  /// Deletes a saved agent.
  Future<void> delete({required String agentId}) async {
    await _send('DELETE', _agent(agentId));
  }

  /// Lists versions of an agent.
  Future<AudioAgentListPage> listVersions({
    required String agentId,
    int? pageSize,
    String? pageToken,
  }) => _json(
    'GET',
    '${_agent(agentId)}/versions',
    AudioAgentListPage.fromJson,
    query: {'page_size': ?pageSize?.toString(), 'page_token': ?pageToken},
  );

  /// Lists sessions that used this agent.
  Future<AudioAgentSessionListPage> listSessions({
    required String agentId,
    int? pageSize,
    String? pageToken,
  }) => _json(
    'GET',
    '${_agent(agentId)}/sessions',
    AudioAgentSessionListPage.fromJson,
    query: {'page_size': ?pageSize?.toString(), 'page_token': ?pageToken},
  );
}

/// Creates, inspects, updates, and closes audio agent sessions.
///
/// A backend should use this resource with the workspace API key. A media
/// client joins with [AudioSessionCredentials] from its authenticated backend.
final class AudioSessionsResource extends _AudioAgentResource {
  /// Creates the audio sessions resource.
  AudioSessionsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  static const _collection = '/v1/audio/sessions';

  String _session(String id) => '$_collection/${Uri.encodeComponent(id)}';

  /// Opens a session and returns short-lived LiveKit participant credentials.
  Future<AudioSessionCredentials> create({
    required CreateAudioSessionRequest request,
  }) => _json(
    'POST',
    _collection,
    AudioSessionCredentials.fromJson,
    body: request.toJson(),
  );

  /// Reads the session status, participant count, and any available transcript.
  Future<AudioSession> get({required String sessionId}) =>
      _json('GET', _session(sessionId), AudioSession.fromJson);

  /// Applies configuration updates to an active session through REST.
  Future<AudioSessionUpdate> update({
    required String sessionId,
    required UpdateAudioSessionRequest request,
  }) => _json(
    'PATCH',
    _session(sessionId),
    AudioSessionUpdate.fromJson,
    body: request.toJson(),
  );

  /// Stops an audio session server-side.
  Future<void> close({required String sessionId}) async {
    await _send('DELETE', _session(sessionId));
  }
}

abstract class _AudioAgentResource extends ResourceBase {
  _AudioAgentResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  Future<T> _json<T>(
    String method,
    String path,
    T Function(Map<String, dynamic>) decode, {
    Map<String, String>? query,
    Map<String, dynamic>? body,
  }) async {
    final response = await _send(method, path, query: query, body: body);
    return decode(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<http.Response> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, dynamic>? body,
  }) {
    ensureNotClosed?.call();
    final request =
        http.Request(method, requestBuilder.buildUrl(path, queryParams: query))
          ..headers.addAll(
            requestBuilder.buildHeaders(
              additionalHeaders: {
                'Accept': 'application/json',
                if (body != null) 'Content-Type': 'application/json',
              },
            ),
          );
    if (body != null) request.body = jsonEncode(body);
    return interceptorChain.execute(request);
  }
}
