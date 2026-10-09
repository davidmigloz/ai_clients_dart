import 'dart:convert';

import 'package:http/http.dart' as http;

import '../errors/exceptions.dart';
import '../models/agents/agent_enums.dart';
import '../models/agents/agent_json_helpers.dart';
import '../models/agents/agent_session_models.dart';
import '../utils/http_error_response.dart';
import '../utils/private_audio_http.dart';
import 'agent_session_stream.dart';
import 'base_resource.dart';
import 'speech_stream_transport.dart';

/// Raw durable sessions under `client.agents.sessions`.
///
/// Creating or observing a session does not execute local callbacks. A caller
/// owns required-action handling and optional self-hosted executor connectivity.
/// Cancelling observation leaves durable work running; cancellation input and
/// session deletion are separate explicitly submitted lifecycle actions.
class AgentSessionsResource extends ResourceBase with _AgentSessionHttp {
  /// Creates a resource using the ordinary client policy and transport.
  AgentSessionsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
    super.streamClientFactory,
  });

  AgentSessionEventsResource? _events;

  /// Live event observation and manual event submission.
  AgentSessionEventsResource get events {
    ensureNotClosed?.call();
    return _events ??= AgentSessionEventsResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
      streamClientFactory: streamClientFactory,
    );
  }

  AgentSessionItemsResource? _items;
  AgentSessionTurnsResource? _turns;
  AgentSessionTracesResource? _traces;

  /// Root-agent history, including coordinator interactions with children.
  AgentSessionItemsResource get items {
    ensureNotClosed?.call();
    return _items ??= AgentSessionItemsResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
  }

  /// Root turns and their persisted items; historical actions are not replayed.
  AgentSessionTurnsResource get turns {
    ensureNotClosed?.call();
    return _turns ??= AgentSessionTurnsResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
  }

  /// Currently published OTLP traces, with root-turn ID pagination.
  AgentSessionTracesResource get traces {
    ensureNotClosed?.call();
    return _traces ??= AgentSessionTracesResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
  }

  /// Creates a session with HTTP 201 JSON.
  ///
  /// Inline configuration needs a model when `agentId` is omitted. Environment
  /// `none` requires initial input. A saved agent, vault or prewarmed environment
  /// is optional. Use [createStream] for SSE; `stream: true` is rejected here.
  Future<AgentSession> create(
    CreateAgentSessionRequest request, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    request.validate();
    if (request.stream == true) {
      throw const FormatException(
        'Use createStream for streamed session creation',
      );
    }
    return _json(
      'POST',
      '/agents/sessions',
      AgentSession.fromJson,
      expectedStatus: 201,
      body: request.toJson(),
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Creates a session with HTTP 201 SSE and explicit `stream: true`.
  ///
  /// The raw stream continues across idle and turn boundaries until HTTP EOF or
  /// local cancellation. EOF is not proof of completed work. Retrieve current
  /// state after an uncertain disconnect. Streamed hosted/none creation requires
  /// initial input; self-hosted creation can wait for an executor connection.
  Stream<AgentSessionEvent> createStream(
    CreateAgentSessionRequest request, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    final streamed = request.copyWith(stream: true)..validate();
    return _observe(
      'POST',
      '/agents/sessions',
      expectedStatus: 201,
      body: streamed.toJson(),
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Lists one page, retaining the same order/agent filter when advancing.
  Future<AgentSessionList> list({
    int? limit,
    AgentListOrder? order,
    String? after,
    String? agentId,
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    if (limit != null) {
      validateAgentInt(limit, 'Sessions list.limit', min: 1, max: 100);
    }
    if (order != null) {
      validateAgentEnum(order.value, const [
        'asc',
        'desc',
      ], 'Sessions list.order');
    }
    if (after != null) {
      validateAgentLength(after, 'Sessions list.after', max: 1048576);
    }
    if (agentId != null) {
      validateAgentLength(agentId, 'Sessions list.agentId', max: 1048576);
    }
    return _json(
      'GET',
      '/agents/sessions',
      AgentSessionList.fromJson,
      query: {
        if (limit != null) 'limit': limit.toString(),
        if (order != null) 'order': order.value,
        'after': ?after,
        'agent_id': ?agentId,
      },
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Retrieves current state without inferring completion from HTTP acceptance.
  Future<AgentSession> retrieve(
    String sessionId, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    return _json(
      'GET',
      _sessionPath(sessionId),
      AgentSession.fromJson,
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Updates metadata, subsequent-turn model settings and spending control.
  ///
  /// Omission retains state. Metadata replaces the full map; explicit null clears
  /// it. Spend-control null or a nullable `limit` removes the cap without resetting
  /// recorded spend. This cap is independent of organization usage tiers/limits.
  Future<AgentSession> update(
    String sessionId,
    UpdateAgentSessionRequest request, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    final path = _sessionPath(sessionId);
    request.validate();
    return _json(
      'POST',
      path,
      AgentSession.fromJson,
      body: request.toJson(),
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Deletes public session state; running execution must be cancelled first.
  ///
  /// Physical cleanup may continue asynchronously. This is distinct from the
  /// cancel input and does not manage external self-hosted compute cleanup.
  Future<DeletedAgentSession> delete(
    String sessionId, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    return _json(
      'DELETE',
      _sessionPath(sessionId),
      DeletedAgentSession.fromJson,
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }
}

/// Persistent live observation and raw input submission for durable sessions.
class AgentSessionEventsResource extends ResourceBase with _AgentSessionHttp {
  /// Creates an event resource sharing ordinary client authentication/context.
  AgentSessionEventsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
    super.streamClientFactory,
  });

  /// Observes HTTP 200 SSE with no replay cursor or automatic reconnection.
  ///
  /// Subscribe before submitting work to receive early events. Idle, required
  /// action and turn completion are typed events and do not close observation.
  /// Cancel/abort releases only this observer; no cancel/delete input is sent.
  Stream<AgentSessionEvent> stream(
    String sessionId, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    return _observe(
      'GET',
      '${_sessionPath(sessionId)}/events',
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Submits raw input; HTTP 202 with no JSON result confirms acceptance only.
  ///
  /// [idempotencyKey] has 1–256 Unicode characters. Reuse it for an application's
  /// retry of the same logical input. No event-retention duration is promised.
  /// Authentication form-value submissions run transport once, even if configured
  /// interceptors try to retry. After uncertain delivery, retrieve current required
  /// actions before choosing another submission. The client never saves form
  /// values to a local history or calls an approval/tool callback automatically.
  Future<void> create(
    String sessionId,
    CreateAgentSessionEventsRequest request, {
    String? idempotencyKey,
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    final path = '${_sessionPath(sessionId)}/events';
    request.validate();
    if (idempotencyKey != null) {
      validateAgentLength(
        idempotencyKey,
        'Session events idempotencyKey',
        min: 1,
        max: 256,
      );
    }
    final headers = {...?additionalHeaders};
    if (idempotencyKey != null) {
      headers.removeWhere((key, _) => key.toLowerCase() == 'idempotency-key');
      headers['Idempotency-Key'] = idempotencyKey;
    }
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == 'idempotency-key') {
        validateAgentLength(
          entry.value,
          'Session events idempotencyKey',
          min: 1,
          max: 256,
        );
      }
    }
    final containsAuthentication = request.events.any(
      (event) =>
          event is AgentSessionApprovalResultInput &&
          event.response is AgentSessionBrowserAuthenticationSubmit,
    );
    return _sendResponse(
      'POST',
      path,
      expectedStatus: 202,
      body: request.toJson(),
      additionalHeaders: headers,
      abortTrigger: abortTrigger,
      allowRetries: !containsAuthentication,
      validateIdempotencyKey: true,
    ).then<void>((_) {});
  }
}

String _sessionPath(String id) {
  validateAgentLength(id, 'Agents sessionId', max: 1048576);
  if (id.isEmpty || id == '.' || id == '..') {
    throw const FormatException('Agents sessionId: expected an opaque segment');
  }
  try {
    return '/agents/sessions/${Uri.encodeComponent(id)}';
  } on ArgumentError {
    throw const FormatException(
      'Agents sessionId: expected an encodable segment',
    );
  }
}

mixin _AgentSessionHttp on ResourceBase {
  Future<T> _json<T>(
    String method,
    String path,
    T Function(Map<String, dynamic>) parse, {
    int expectedStatus = 200,
    Map<String, dynamic>? body,
    Map<String, String>? query,
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) =>
      _sendResponse(
        method,
        path,
        expectedStatus: expectedStatus,
        body: body,
        query: query,
        additionalHeaders: additionalHeaders,
        abortTrigger: abortTrigger,
      ).then(
        (response) =>
            parsePrivateAudioResponse(response, parse, 'Agents session'),
      );

  Future<http.Response> _sendResponse(
    String method,
    String path, {
    int expectedStatus = 200,
    Map<String, dynamic>? body,
    Map<String, String>? query,
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
    bool allowRetries = true,
    bool validateIdempotencyKey = false,
  }) async {
    final callerHeaders = additionalHeaders == null
        ? null
        : Map<String, String>.unmodifiable(additionalHeaders);
    String? callerIdempotencyKey;
    if (validateIdempotencyKey && callerHeaders != null) {
      for (final entry in callerHeaders.entries) {
        if (entry.key.toLowerCase() == 'idempotency-key') {
          callerIdempotencyKey = entry.value;
        }
      }
    }
    await checkPrivateAudioAbort(abortTrigger, 'Agents sessions');
    final request =
        http.Request(method, requestBuilder.buildUrl(path, queryParams: query))
          ..headers.addAll(
            requestBuilder.buildBetaHeaders(
              betaFeature: 'agents=v1',
              additionalHeaders: callerHeaders,
            ),
          )
          ..headers['openai-beta'] = 'agents=v1'
          ..headers['accept'] = 'application/json';
    if (callerIdempotencyKey != null) {
      request.headers['idempotency-key'] = callerIdempotencyKey;
    }
    if (validateIdempotencyKey) {
      if (request.headers['idempotency-key'] case final key?) {
        validateAgentLength(
          key,
          'Session events idempotencyKey',
          min: 1,
          max: 256,
        );
      }
    }
    if (body == null) {
      request.headers.remove('content-type');
    } else {
      request
        ..headers['content-type'] = 'application/json; charset=utf-8'
        ..encoding = utf8
        ..bodyBytes = utf8.encode(jsonEncode(body));
    }
    final response = await sendPrivateAudioRequest(
      request,
      interceptorChain: interceptorChain,
      context: 'Agents session',
      abortTrigger: abortTrigger,
      allowRetries: allowRetries,
    );
    if (response.statusCode != expectedStatus) {
      throw ParseException(
        message:
            'Unexpected Agents session success status; expected $expectedStatus.',
        responseBody: utf8.decode(response.bodyBytes, allowMalformed: true),
      );
    }
    return response;
  }

  Stream<AgentSessionEvent> _observe(
    String method,
    String path, {
    int expectedStatus = 200,
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) => decodeAgentSessionEvents(
    openPrivateByteStream(
      httpClient: httpClient,
      streamClientFactory: streamClientFactory,
      requestBuilder: requestBuilder,
      method: method,
      endpoint: path,
      body: body,
      additionalHeaders: additionalHeaders,
      betaFeature: 'agents=v1',
      accept: 'text/event-stream',
      timeout: config.timeout,
      context: 'Agents session observation',
      parseError: (response) =>
          parseHttpErrorResponse(response, request: response.request!),
      validateResponse: (response) {
        if (response.statusCode != expectedStatus) {
          throw ParseException(
            message:
                'Unexpected Agents session SSE status; expected $expectedStatus.',
          );
        }
      },
      ensureNotClosed: ensureNotClosed,
      abortTrigger: abortTrigger,
      timeoutResponseBody: false,
    ),
  );
}

/// ID cursors are exclusive in the selected order. These are persisted root-agent records; each child has a separate history. They are not authority to replay old tool or approval actions.
class AgentSessionItemsResource extends ResourceBase with _AgentSessionHttp {
  /// Creates a history resource sharing ordinary client policy and ownership.
  AgentSessionItemsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Reads one available page; keep the same order/context when using lastId.
  Future<AgentSessionItemList> list(
    String sessionId, {
    int? limit,
    AgentListOrder? order,
    String? after,
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    final path = _sessionPath(sessionId);
    final query = _historyQuery(limit: limit, order: order, after: after);
    return _json(
      'GET',
      '$path/items',
      AgentSessionItemList.fromJson,
      query: query,
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }
}

/// ID cursors are exclusive in the selected order. These are persisted root-agent records; each child has a separate history. They are not authority to replay old tool or approval actions.
class AgentSessionTurnsResource extends ResourceBase with _AgentSessionHttp {
  /// Creates a history resource sharing ordinary client policy and ownership.
  AgentSessionTurnsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });
  AgentSessionTurnItemsResource? _items;

  /// Items belonging to one root-agent turn.
  AgentSessionTurnItemsResource get items {
    ensureNotClosed?.call();
    return _items ??= AgentSessionTurnItemsResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
  }

  /// Retrieves status/timestamps/usage/error; a terminal turn is distinct from session idle.
  Future<AgentSessionTurn> retrieve(
    String sessionId,
    String turnId, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    return _json(
      'GET',
      _turnPath(sessionId, turnId),
      AgentSessionTurn.fromJson,
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Reads one available page; keep the same order/context when using lastId.
  Future<AgentSessionTurnList> list(
    String sessionId, {
    int? limit,
    AgentListOrder? order,
    String? after,
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    final path = _sessionPath(sessionId);
    final query = _historyQuery(limit: limit, order: order, after: after);
    return _json(
      'GET',
      '$path/turns',
      AgentSessionTurnList.fromJson,
      query: query,
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }
}

/// ID cursors are exclusive in the selected order. These are persisted root-agent records; each child has a separate history. They are not authority to replay old tool or approval actions.
class AgentSessionTurnItemsResource extends ResourceBase
    with _AgentSessionHttp {
  /// Creates a history resource sharing ordinary client policy and ownership.
  AgentSessionTurnItemsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Reads one available page; keep the same order/context when using lastId.
  Future<AgentSessionItemList> list(
    String sessionId,
    String turnId, {
    int? limit,
    AgentListOrder? order,
    String? after,
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    final path = _turnPath(sessionId, turnId);
    final query = _historyQuery(limit: limit, order: order, after: after);
    return _json(
      'GET',
      '$path/items',
      AgentSessionItemList.fromJson,
      query: query,
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }
}

/// The service limits reads and JSON to 16 MiB. Request fewer traces if the service reports this limit. Pages skip unpublished traces and never wait for later updates; IDs are root-turn anchors. Export permission must be enabled for the organization/project.
class AgentSessionTracesResource extends ResourceBase with _AgentSessionHttp {
  /// Creates a history resource sharing ordinary client policy and ownership.
  AgentSessionTracesResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Reads one available page; keep the same order/context when using lastId.
  Future<AgentSessionTraceList> list(
    String sessionId, {
    int? limit,
    AgentListOrder? order,
    String? after,
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    final path = _sessionPath(sessionId);
    final query = _historyQuery(limit: limit, order: order, after: after);
    return _json(
      'GET',
      '$path/traces',
      AgentSessionTraceList.fromJson,
      query: query,
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }
}

String _turnPath(String sessionId, String turnId) =>
    '${_sessionPath(sessionId)}/turns/${_opaqueTurnId(turnId)}';
String _opaqueTurnId(String id) {
  validateAgentLength(id, 'Agents turnId', max: 1048576);
  if (id.isEmpty || id == '.' || id == '..') {
    throw const FormatException('Agents turnId: expected an opaque segment');
  }
  try {
    return Uri.encodeComponent(id);
  } on ArgumentError {
    throw const FormatException('Agents turnId: expected an encodable segment');
  }
}

Map<String, String> _historyQuery({
  int? limit,
  AgentListOrder? order,
  String? after,
}) {
  if (limit != null) {
    validateAgentInt(limit, 'Agents history.limit', min: 1, max: 100);
  }
  if (order != null) {
    validateAgentEnum(order.value, const [
      'asc',
      'desc',
    ], 'Agents history.order');
  }
  if (after != null) {
    validateAgentLength(after, 'Agents history.after', max: 1048576);
  }
  return {
    if (limit != null) 'limit': limit.toString(),
    if (order != null) 'order': order.value,
    'after': ?after,
  };
}
