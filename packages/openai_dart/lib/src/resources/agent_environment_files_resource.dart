import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../errors/exceptions.dart';
import '../models/agents/agent_json_helpers.dart';
import '../models/agents/agents.dart';
import '../utils/http_error_response.dart';
import '../utils/private_audio_http.dart';
import 'base_resource.dart';
import 'speech_stream_transport.dart';

/// Mutable live workspace files in a connected hosted execution environment.
/// Paths denote hosted workspace destinations, never local filesystem paths.
class AgentEnvironmentFilesResource extends ResourceBase with _AgentFileHttp {
  /// Shares ordinary authentication, project, policy and borrowed transport.
  AgentEnvironmentFilesResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Copies an existing Files API file or standard-base64 inline bytes into
  /// `/workspace`. Inline files are limited to 5 MiB decoded. The environment
  /// must be connected; no local file upload or environment creation is implied.
  Future<AgentEnvironmentFile> create(
    String environmentId,
    AgentSessionHostedEnvironmentFileConfig file, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    final path = _environmentFilesPath(environmentId);
    file.validate();
    return _json(
      'POST',
      path,
      AgentEnvironmentFile.fromJson,
      expectedStatus: 201,
      body: file.toJson(),
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Reads one live page. Advance with `page: result.next`, retaining path,
  /// limit and order. These opaque page tokens are unrelated to artifact IDs.
  Future<AgentEnvironmentFileList> list(
    String environmentId, {
    String? path,
    int? limit,
    AgentListOrder? order,
    String? page,
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    final endpoint = _environmentFilesPath(environmentId);
    _validatePage(limit, order);
    if (path != null) {
      validateAgentLength(path, 'Environment files path', max: 1048576);
    }
    if (page != null) {
      validateAgentLength(page, 'Environment files page', max: 1048576);
    }
    return _json(
      'GET',
      endpoint,
      AgentEnvironmentFileList.fromJson,
      query: {
        'path': ?path,
        if (limit != null) 'limit': limit.toString(),
        if (order != null) 'order': order.value,
        'page': ?page,
      },
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }
}

/// Immutable outputs already published by completed hosted session turns.
/// Published artifacts remain downloadable after environment expiry. Unpublished
/// outputs are not guaranteed to survive cancellation or session deletion.
class AgentSessionArtifactsResource extends ResourceBase with _AgentFileHttp {
  /// Shares client context; stream factories create operation-owned transports.
  AgentSessionArtifactsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
    super.streamClientFactory,
  });

  /// Lists one ID page. Advance using lastId with the same order and filter.
  /// Omitted/null environmentId applies no environment filter.
  Future<AgentSessionArtifactList> list(
    String sessionId, {
    int? limit,
    AgentListOrder? order,
    String? after,
    String? environmentId,
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    final path = _artifactsPath(sessionId);
    _validatePage(limit, order);
    if (after != null) {
      validateAgentLength(after, 'Session artifacts after', max: 1048576);
    }
    if (environmentId != null) {
      validateAgentLength(
        environmentId,
        'Session artifacts environmentId',
        max: 1048576,
      );
    }
    return _json(
      'GET',
      path,
      AgentSessionArtifactList.fromJson,
      query: {
        if (limit != null) 'limit': limit.toString(),
        if (order != null) 'order': order.value,
        'after': ?after,
        'environment_id': ?environmentId,
      },
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Retrieves immutable metadata, including original hosted path and turn ID.
  Future<AgentSessionArtifact> retrieve(
    String sessionId,
    String artifactId, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    return _json(
      'GET',
      _artifactPath(sessionId, artifactId),
      AgentSessionArtifact.fromJson,
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Deletes this artifact. Session deletion and stopping observation are
  /// separate operations and do not mean the same thing.
  Future<DeletedAgentSessionArtifact> delete(
    String sessionId,
    String artifactId, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    return _json(
      'DELETE',
      _artifactPath(sessionId, artifactId),
      DeletedAgentSessionArtifact.fromJson,
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Buffers exact binary contents in memory without JSON or text decoding.
  /// Select downloadStream for incremental access to large artifacts.
  Future<Uint8List> download(
    String sessionId,
    String artifactId, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) async {
    final bytes = BytesBuilder();
    await downloadStream(
      sessionId,
      artifactId,
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    ).forEach(bytes.add);
    return bytes.takeBytes();
  }

  /// Downloads exact bytes once, using the existing private download transport.
  /// No automatic replay or interceptors are applied to a byte stream. Auth and
  /// project headers use the shared request builder. Cancellation releases only
  /// this local download; it does not delete artifacts or cancel session work.
  /// An injected transport is borrowed; a distinct factory transport is owned.
  /// Headers and each active response-body read use the client timeout; pausing
  /// the subscription pauses the idle deadline. No local destination is chosen.
  Stream<Uint8List> downloadStream(
    String sessionId,
    String artifactId, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    final path = '${_artifactPath(sessionId, artifactId)}/content';
    return openPrivateByteStream(
      httpClient: httpClient,
      streamClientFactory: streamClientFactory,
      requestBuilder: requestBuilder,
      method: 'GET',
      endpoint: path,
      additionalHeaders: additionalHeaders,
      betaFeature: 'agents=v1',
      accept: 'application/octet-stream',
      timeout: config.timeout,
      context: 'Agents artifact download',
      parseError: (response) =>
          parseHttpErrorResponse(response, request: response.request!),
      validateResponse: (response) {
        if (response.statusCode != 200) {
          throw const ParseException(
            message:
                'Unexpected Agents artifact download success status; expected 200.',
          );
        }
        final media = response.headers['content-type']
            ?.split(';')
            .first
            .trim()
            .toLowerCase();
        if (media != null && media != 'application/octet-stream') {
          throw const ParseException(
            message: 'Unexpected Agents artifact download media type.',
          );
        }
      },
      ensureNotClosed: ensureNotClosed,
      abortTrigger: abortTrigger,
      sanitizeConnectorErrors: true,
    );
  }
}

void _validatePage(int? limit, AgentListOrder? order) {
  if (limit != null) {
    validateAgentInt(limit, 'Agents files limit', min: 1, max: 100);
  }
  if (order != null) {
    validateAgentEnum(order.value, const ['asc', 'desc'], 'Agents files order');
  }
}

String _segment(String id) {
  validateAgentLength(id, 'Agents files path ID', max: 1048576);
  if (id.isEmpty || id == '.' || id == '..') {
    throw const FormatException(
      'Agents files path ID: expected an opaque segment',
    );
  }
  try {
    return Uri.encodeComponent(id);
  } on ArgumentError {
    throw const FormatException(
      'Agents files path ID: expected an encodable segment',
    );
  }
}

String _environmentFilesPath(String id) =>
    '/agents/environments/${_segment(id)}/files';
String _artifactsPath(String id) =>
    '/agents/sessions/${_segment(id)}/artifacts';
String _artifactPath(String sessionId, String artifactId) =>
    '${_artifactsPath(sessionId)}/${_segment(artifactId)}';

mixin _AgentFileHttp on ResourceBase {
  Future<T> _json<T>(
    String method,
    String path,
    T Function(Map<String, dynamic>) parse, {
    int expectedStatus = 200,
    Map<String, dynamic>? body,
    Map<String, String>? query,
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) async {
    final headers = requestBuilder.buildBetaHeaders(
      betaFeature: 'agents=v1',
      additionalHeaders: additionalHeaders == null
          ? null
          : Map.of(additionalHeaders),
    );
    final request =
        http.Request(method, requestBuilder.buildUrl(path, queryParams: query))
          ..headers.addAll(headers)
          ..headers['openai-beta'] = 'agents=v1'
          ..headers['accept'] = 'application/json';
    if (body == null) {
      request.headers.remove('content-type');
    } else {
      request
        ..headers['content-type'] = 'application/json; charset=utf-8'
        ..encoding = utf8
        ..bodyBytes = utf8.encode(jsonEncode(body));
    }
    await checkPrivateAudioAbort(abortTrigger, 'Agents files');
    final response = await sendPrivateAudioRequest(
      request,
      interceptorChain: interceptorChain,
      context: 'Agents files',
      abortTrigger: abortTrigger,
    );
    if (response.statusCode != expectedStatus) {
      throw ParseException(
        message:
            'Unexpected Agents files success status; expected $expectedStatus.',
        responseBody: utf8.decode(response.bodyBytes, allowMalformed: true),
      );
    }
    return parsePrivateAudioResponse(response, parse, 'Agents files');
  }
}
