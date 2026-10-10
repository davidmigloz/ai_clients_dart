import 'dart:convert';

import 'package:http/http.dart' as http;

import '../errors/exceptions.dart';
import '../models/agents/agent_json_helpers.dart';
import '../models/agents/agents.dart';
import '../utils/private_audio_http.dart';
import 'agent_environment_files_resource.dart';
import 'base_resource.dart';

/// Owned hosted environments; prewarming requires service beta eligibility.
/// Session, environment, provider and artifact lifetimes are independent.
/// Status values do not imply suspend/resume/reset/delete methods.
class AgentEnvironmentsResource extends ResourceBase with _EnvironmentHttp {
  AgentEnvironmentFilesResource? _files;

  /// Mutable live files on a connected hosted environment.
  AgentEnvironmentFilesResource get files {
    ensureNotClosed?.call();
    return _files ??= AgentEnvironmentFilesResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
  }

  /// Shares the client's authenticated project and borrowed transport.
  AgentEnvironmentsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
    super.streamClientFactory,
  });
  AgentEnvironmentTemplatesResource? _templates;

  /// Reusable configuration with confidential inputs and safe metadata views.
  AgentEnvironmentTemplatesResource get templates {
    ensureNotClosed?.call();
    return _templates ??= AgentEnvironmentTemplatesResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
  }

  /// Prewarms an OpenAI-hosted environment, with at most ten attached vaults.
  ///
  /// An optional key has 1–256 Unicode characters and deduplicates for 24 hours
  /// within the authenticated organization/project/creator. Retry the same JSON
  /// and key to receive current state. Mismatched JSON or incomplete creation
  /// returns HTTP 409. Retained deleted keys do not recreate environments;
  /// after retention expires the key may create a fresh environment. No local
  /// deduplication cache is maintained. Without a key, each call creates anew.
  Future<AgentEnvironment> create(
    CreateAgentEnvironmentRequest request, {
    String? idempotencyKey,
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    request.validate();
    final headers = {...?additionalHeaders};
    if (idempotencyKey != null) {
      headers.removeWhere((key, _) => key.toLowerCase() == 'idempotency-key');
      headers['Idempotency-Key'] = idempotencyKey;
    }
    return _json(
      'POST',
      '/agents/environments',
      AgentEnvironment.fromJson,
      expectedStatus: 201,
      body: request.toJson(),
      additionalHeaders: headers,
      abortTrigger: abortTrigger,
      validateIdempotencyKey: true,
    );
  }

  /// Lists one ID-paginated page. Omitted type defaults on the service.
  Future<AgentEnvironmentList> list({
    int? limit,
    AgentListOrder? order,
    String? after,
    AgentEnvironmentType? type,
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    final query = _query(limit, order, after);
    if (type != null) {
      validateAgentEnum(type.value, const [
        'openai_hosted',
      ], 'Environments type');
      query['type'] = type.value;
    }
    return _json(
      'GET',
      '/agents/environments',
      AgentEnvironmentList.fromJson,
      query: query,
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Retrieves current status and installed safe metadata, with no local cache.
  Future<AgentEnvironment> retrieve(
    String environmentId, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    return _json(
      'GET',
      '/agents/environments/${_segment(environmentId)}',
      AgentEnvironment.fromJson,
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }
}

/// Project-scoped hosted environment templates. Inline settings are applied
/// after a template, and cannot broaden its network policy. Omitted network
/// defaults belong to the API version. Returned views exclude confidential data.
class AgentEnvironmentTemplatesResource extends ResourceBase
    with _EnvironmentHttp {
  /// Shares ordinary client authentication, context and HTTP policy.
  AgentEnvironmentTemplatesResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Creates reusable configuration. Confidential inputs are never read back.
  Future<AgentEnvironmentTemplate> create(
    CreateAgentEnvironmentTemplateRequest request, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    request.validate();
    return _json(
      'POST',
      '/agents/environments/templates',
      AgentEnvironmentTemplate.fromJson,
      expectedStatus: 201,
      body: request.toJson(),
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Retrieves safe template metadata without command, variable or archive data.
  Future<AgentEnvironmentTemplate> retrieve(
    String templateId, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    final path = '/agents/environments/templates/${_segment(templateId)}';
    return _json(
      'GET',
      path,
      AgentEnvironmentTemplate.fromJson,
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Replaces supplied settings; omission retains, network null resets the policy,
  /// desktop null disables it, and name null clears the name.
  Future<AgentEnvironmentTemplate> update(
    String templateId,
    UpdateAgentEnvironmentTemplateRequest request, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    final path = '/agents/environments/templates/${_segment(templateId)}';
    request.validate();
    return _json(
      'POST',
      path,
      AgentEnvironmentTemplate.fromJson,
      body: request.toJson(),
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Deletes template configuration and its confidential inputs.
  Future<DeletedAgentEnvironmentTemplate> delete(
    String templateId, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    final path = '/agents/environments/templates/${_segment(templateId)}';
    return _json(
      'DELETE',
      path,
      DeletedAgentEnvironmentTemplate.fromJson,
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Lists one page. Keep the same order when advancing with lastId.
  Future<AgentEnvironmentTemplateList> list({
    int? limit,
    AgentListOrder? order,
    String? after,
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    return _json(
      'GET',
      '/agents/environments/templates',
      AgentEnvironmentTemplateList.fromJson,
      query: _query(limit, order, after),
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }
}

Map<String, String> _query(int? limit, AgentListOrder? order, String? after) {
  if (limit != null) {
    validateAgentInt(limit, 'Environments limit', min: 1, max: 100);
  }
  if (order != null) {
    validateAgentEnum(order.value, const ['asc', 'desc'], 'Environments order');
  }
  if (after != null) {
    validateAgentLength(after, 'Environments after', max: 1048576);
  }
  return {
    if (limit != null) 'limit': limit.toString(),
    if (order != null) 'order': order.value,
    'after': ?after,
  };
}

String _segment(String id) {
  validateAgentLength(id, 'Environment path ID', max: 1048576);
  if (id.isEmpty || id == '.' || id == '..') {
    throw const FormatException(
      'Environment path ID: expected an opaque segment',
    );
  }
  try {
    return Uri.encodeComponent(id);
  } on ArgumentError {
    throw const FormatException(
      'Environment path ID: expected an encodable segment',
    );
  }
}

mixin _EnvironmentHttp on ResourceBase {
  Future<T> _json<T>(
    String method,
    String path,
    T Function(Map<String, dynamic>) parse, {
    int expectedStatus = 200,
    Map<String, dynamic>? body,
    Map<String, String>? query,
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
    bool validateIdempotencyKey = false,
  }) async {
    final callerHeaders = Map<String, String>.unmodifiable({
      ...?additionalHeaders,
    });
    final headers = requestBuilder.buildBetaHeaders(
      betaFeature: 'agents=v1',
      additionalHeaders: callerHeaders,
    );
    // Resolve case-insensitive caller precedence before provider authentication.
    final request = http.Request(
      method,
      requestBuilder.buildUrl(path, queryParams: query),
    )..headers.addAll(headers);
    for (final entry in callerHeaders.entries) {
      if (entry.key.toLowerCase() == 'idempotency-key') {
        request.headers['idempotency-key'] = entry.value;
      }
    }
    if (request.headers['idempotency-key'] case final key?
        when validateIdempotencyKey) {
      validateAgentLength(
        key,
        'Environment create idempotencyKey',
        min: 1,
        max: 256,
      );
    }
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
    await checkPrivateAudioAbort(abortTrigger, 'Agents environments');
    final response = await sendPrivateAudioRequest(
      request,
      interceptorChain: interceptorChain,
      context: 'Agents environments',
      abortTrigger: abortTrigger,
    );
    if (response.statusCode != expectedStatus) {
      throw ParseException(
        message:
            'Unexpected Agents environment success status; expected $expectedStatus.',
        responseBody: utf8.decode(response.bodyBytes, allowMalformed: true),
      );
    }
    return parsePrivateAudioResponse(response, parse, 'Agents environments');
  }
}
