import 'dart:convert';

import 'package:http/http.dart' as http;

import '../errors/exceptions.dart';
import '../models/agents/agent_json_helpers.dart';
import '../models/agents/agents.dart';
import '../utils/private_audio_http.dart';
import 'base_resource.dart';

/// Saved Agent schedules, scoped to the authenticated project.
///
/// Creating, updating, pausing or resuming a schedule never invokes it locally.
/// Use [invocations] to request or inspect delivery explicitly. Delivery
/// completion and schedule completion do not imply completed Agent work.
class AgentAutomationsResource extends ResourceBase with _AgentAutomationHttp {
  /// Creates a resource sharing the client's ordinary HTTP policy.
  AgentAutomationsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
    super.streamClientFactory,
  });

  AgentAutomationInvocationsResource? _invocations;

  /// Explicit manual delivery and persisted delivery history.
  AgentAutomationInvocationsResource get invocations {
    ensureNotClosed?.call();
    return _invocations ??= AgentAutomationInvocationsResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
  }

  /// Saves an active schedule without invoking it immediately.
  Future<AgentAutomation> create(
    CreateAgentAutomationRequest request, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    request.validate();
    return _json(
      'POST',
      '/agents/automations',
      AgentAutomation.fromJson,
      expectedStatus: 201,
      body: request.toJson(),
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Retrieves a saved schedule without waiting for a delivery or session.
  Future<AgentAutomation> retrieve(
    String automationId, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    return _json(
      'GET',
      _automationPath(automationId),
      AgentAutomation.fromJson,
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Updates supplied fields; target and metadata replace the complete field.
  ///
  /// Timing fields must match the stored schedule type. The service validates
  /// target type/creator restrictions and whether a once invocation is pending.
  Future<AgentAutomation> update(
    String automationId,
    UpdateAgentAutomationRequest request, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    final path = _automationPath(automationId);
    request.validate();
    return _json(
      'POST',
      path,
      AgentAutomation.fromJson,
      body: request.toJson(),
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Lists one page, optionally matching existing-session targets.
  ///
  /// Pass the returned `lastId` as [after] with the same order, limit and
  /// [sessionId]. Empty pages preserve nullable cursors. If a cursor is absent
  /// or does not advance, stop or inspect that response instead of looping.
  Future<AgentAutomationList> list({
    int? limit,
    AgentListOrder? order,
    String? after,
    String? sessionId,
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    return _json(
      'GET',
      '/agents/automations',
      AgentAutomationList.fromJson,
      query: _automationQuery(
        limit: limit,
        order: order,
        after: after,
        sessionId: sessionId,
      ),
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Prevents future invocations without deleting the target session.
  Future<DeletedAgentAutomation> delete(
    String automationId, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    return _json(
      'DELETE',
      _automationPath(automationId),
      DeletedAgentAutomation.fromJson,
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Pauses future scheduled delivery without stopping an active session.
  Future<AgentAutomation> pause(
    String automationId, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    return _json(
      'POST',
      '${_automationPath(automationId)}/pause',
      AgentAutomation.fromJson,
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Resumes scheduled delivery without creating a manual invocation.
  ///
  /// Once schedules without a pending invocation require a future `run_at`.
  /// The service validates this condition against the stored schedule.
  Future<AgentAutomation> resume(
    String automationId, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    return _json(
      'POST',
      '${_automationPath(automationId)}/resume',
      AgentAutomation.fromJson,
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }
}

/// Explicit invocation submission and delivery records for an automation.
class AgentAutomationInvocationsResource extends ResourceBase
    with _AgentAutomationHttp {
  /// Creates a child resource sharing the client's transport and policy.
  AgentAutomationInvocationsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Queues one manual delivery without changing the saved schedule.
  ///
  /// The returned delivery record is acceptance, not proof of completed Agent
  /// work. This operation has no request body and creates no local timer.
  Future<AgentAutomationInvocation> create(
    String automationId, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    return _json(
      'POST',
      '${_automationPath(automationId)}/invocations',
      AgentAutomationInvocation.fromJson,
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Retrieves one delivery record without polling the target session.
  Future<AgentAutomationInvocation> retrieve(
    String automationId,
    String invocationId, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    return _json(
      'GET',
      '${_automationPath(automationId)}/invocations/'
          '${_automationSegment(invocationId, 'invocationId')}',
      AgentAutomationInvocation.fromJson,
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Lists one page of delivery history, retaining nullable/nonadvancing cursors.
  ///
  /// Advance with the returned `lastId`, keeping the same order and limit. Stop
  /// or inspect a page whose cursor is absent or unchanged; no page is fetched
  /// automatically and no historical delivery is replayed.
  Future<AgentAutomationInvocationList> list(
    String automationId, {
    int? limit,
    AgentListOrder? order,
    String? after,
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    return _json(
      'GET',
      '${_automationPath(automationId)}/invocations',
      AgentAutomationInvocationList.fromJson,
      query: _automationQuery(limit: limit, order: order, after: after),
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }
}

String _automationPath(String id) =>
    '/agents/automations/${_automationSegment(id, 'automationId')}';

String _automationSegment(String value, String field) {
  final context = 'Agent automations $field';
  validateAgentLength(value, context, max: 1048576);
  if (value.isEmpty || value == '.' || value == '..') {
    throw FormatException('$context: expected an opaque segment');
  }
  try {
    final encoded = Uri.encodeComponent(value);
    if (Uri.decodeComponent(encoded) != value) {
      throw FormatException('$context: expected valid Unicode');
    }
    return encoded;
  } on ArgumentError {
    throw FormatException('$context: expected an encodable segment');
  }
}

void _automationQueryText(String value, String field) {
  final context = 'Agent automations list.$field';
  validateAgentLength(value, context, max: 1048576);
  if (Uri.decodeQueryComponent(Uri.encodeQueryComponent(value)) != value) {
    throw FormatException('$context: expected valid Unicode');
  }
}

Map<String, String> _automationQuery({
  int? limit,
  AgentListOrder? order,
  String? after,
  String? sessionId,
}) {
  if (limit != null) {
    validateAgentInt(limit, 'Agent automations list.limit', min: 1, max: 100);
  }
  if (order != null) {
    validateAgentEnum(order.value, const [
      'asc',
      'desc',
    ], 'Agent automations list.order');
  }
  if (after != null) _automationQueryText(after, 'after');
  if (sessionId != null) _automationQueryText(sessionId, 'sessionId');
  return {
    'limit': ?limit?.toString(),
    'order': ?order?.value,
    'after': ?after,
    'session_id': ?sessionId,
  };
}

mixin _AgentAutomationHttp on ResourceBase {
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
    final headers = additionalHeaders == null
        ? null
        : Map<String, String>.unmodifiable(additionalHeaders);
    await checkPrivateAudioAbort(abortTrigger, 'Agent automations');
    ensureNotClosed?.call();
    final http.Request request;
    try {
      request =
          http.Request(
              method,
              requestBuilder.buildUrl(path, queryParams: query),
            )
            ..headers.addAll(
              requestBuilder.buildBetaHeaders(
                betaFeature: 'agents=v1',
                additionalHeaders: headers,
              ),
            );
      request.headers['openai-beta'] = 'agents=v1';
      request.headers['accept'] = 'application/json';
      if (body == null) {
        request.headers.remove('content-type');
      } else {
        request
          ..headers['content-type'] = 'application/json; charset=utf-8'
          ..encoding = utf8
          ..bodyBytes = utf8.encode(jsonEncode(body));
      }
    } catch (error) {
      throw ConnectionException(
        message: 'Agent automations request setup failed.',
        cause: error,
        redactDiagnostics: true,
      );
    }
    final response = await sendPrivateAudioRequest(
      request,
      interceptorChain: interceptorChain,
      context: 'Agent automations',
      abortTrigger: abortTrigger,
    );
    if (response.statusCode != expectedStatus) {
      throw ParseException(
        message:
            'Unexpected Agent automations success status; expected $expectedStatus.',
        responseBody: utf8.decode(response.bodyBytes, allowMalformed: true),
      );
    }
    return parsePrivateAudioResponse(response, parse, 'Agent automations');
  }
}
