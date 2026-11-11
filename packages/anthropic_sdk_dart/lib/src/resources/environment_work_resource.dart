import 'dart:convert';

import 'package:http/http.dart' as http;

import '../errors/exceptions.dart';
import '../models/managed_agents/environments/environment_work.dart';
import 'base_resource.dart';
import 'protected_resource_request.dart';

/// A rejected conditional heartbeat. Another worker may hold the lease.
class EnvironmentHeartbeatConflictException extends ApiException {
  /// Creates a heartbeat precondition failure.
  const EnvironmentHeartbeatConflictException({
    required this.currentState,
    super.responseMetadata,
  }) : super(
         statusCode: 412,
         message: 'The work heartbeat does not match the current lease',
         errorCode: 'heartbeat_precondition_failed',
       );

  /// Current lease state as returned by the server.
  final EnvironmentWorkLeaseState currentState;
}

/// Work queue operations for one self-hosted Managed Agents environment.
///
/// A scoped bearer token replaces configured API-key credentials. Poll with
/// the environment token and use the claimed item's sessions token for its
/// lifecycle operations.
class EnvironmentWorkResource extends ResourceBase {
  /// Creates an environment-scoped work resource.
  EnvironmentWorkResource({
    required this.environmentId,
    this._bearerToken,
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Environment that owns this queue.
  final String environmentId;
  final String? _bearerToken;

  /// Value of the first conditional heartbeat when no lease is recorded.
  static const noHeartbeat = 'NO_HEARTBEAT';

  /// Retrieves one work item with management credentials.
  Future<EnvironmentWorkItem> retrieve(
    String workId, {
    String? workspaceId,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) async => EnvironmentWorkItem.fromJson(
    (await _send(
          'GET',
          '/${_id(workId)}',
          allowBearer: false,
          includeWorkspace: true,
          workspaceId: workspaceId,
          betas: betas,
          abortTrigger: abortTrigger,
        ))!
        as Map<String, dynamic>,
  );

  /// Updates metadata with management credentials. Null values delete keys.
  Future<EnvironmentWorkItem> update(
    String workId, {
    required Map<String, String?> metadata,
    String? workspaceId,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) async => EnvironmentWorkItem.fromJson(
    (await _send(
          'POST',
          '/${_id(workId)}',
          allowBearer: false,
          includeWorkspace: true,
          workspaceId: workspaceId,
          body: {'metadata': metadata},
          betas: betas,
          abortTrigger: abortTrigger,
        ))!
        as Map<String, dynamic>,
  );

  /// Lists work items. Pass the returned cursor to continue pagination.
  Future<EnvironmentWorkListResponse> list({
    int? limit,
    String? page,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) async => EnvironmentWorkListResponse.fromJson(
    (await _send(
          'GET',
          '',
          query: {'limit': ?limit?.toString(), 'page': ?page},
          betas: betas,
          abortTrigger: abortTrigger,
        ))!
        as Map<String, dynamic>,
  );

  /// Acknowledges a work item.
  Future<EnvironmentWorkItem> ack(
    String workId, {
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) async => EnvironmentWorkItem.fromJson(
    (await _send(
          'POST',
          '/${_id(workId)}/ack',
          betas: betas,
          abortTrigger: abortTrigger,
        ))!
        as Map<String, dynamic>,
  );

  /// Extends a work lease. Supply [noHeartbeat] when claiming a fresh lease,
  /// then echo [EnvironmentWorkHeartbeat.lastHeartbeat] unchanged.
  Future<EnvironmentWorkHeartbeat> heartbeat(
    String workId, {
    int? desiredTtlSeconds,
    String? expectedLastHeartbeat,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) async => EnvironmentWorkHeartbeat.fromJson(
    (await _send(
          'POST',
          '/${_id(workId)}/heartbeat',
          query: {
            'desired_ttl_seconds': ?desiredTtlSeconds?.toString(),
            'expected_last_heartbeat': ?expectedLastHeartbeat,
          },
          betas: betas,
          abortTrigger: abortTrigger,
          handleError: _heartbeatError,
        ))!
        as Map<String, dynamic>,
  );

  /// Polls the queue. A null result means there is no assigned work.
  Future<EnvironmentWorkItem?> poll({
    int? blockMs,
    int? reclaimOlderThanMs,
    String? workerId,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) async {
    final data = await _send(
      'GET',
      '/poll',
      query: {
        'block_ms': ?blockMs?.toString(),
        'reclaim_older_than_ms': ?reclaimOlderThanMs?.toString(),
      },
      workerId: workerId,
      betas: betas,
      abortTrigger: abortTrigger,
    );
    return data == null
        ? null
        : EnvironmentWorkItem.fromJson(data as Map<String, dynamic>);
  }

  /// Retrieves queue statistics.
  Future<EnvironmentWorkQueueStats> stats({
    String? workspaceId,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) async => EnvironmentWorkQueueStats.fromJson(
    (await _send(
          'GET',
          '/stats',
          includeWorkspace: true,
          workspaceId: workspaceId,
          betas: betas,
          abortTrigger: abortTrigger,
        ))!
        as Map<String, dynamic>,
  );

  /// Requests graceful or forced shutdown for a work item.
  Future<EnvironmentWorkItem> stop(
    String workId, {
    bool? force,
    String? workspaceId,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) async => EnvironmentWorkItem.fromJson(
    (await _send(
          'POST',
          '/${_id(workId)}/stop',
          includeWorkspace: true,
          workspaceId: workspaceId,
          body: {'force': ?force},
          betas: betas,
          abortTrigger: abortTrigger,
        ))!
        as Map<String, dynamic>,
  );

  String _id(String value) {
    if (value.isEmpty) {
      throw ArgumentError('Environment and work IDs must be nonempty');
    }
    return Uri.encodeComponent(value);
  }

  Future<Object?> _send(
    String method,
    String suffix, {
    bool allowBearer = true,
    bool includeWorkspace = false,
    String? workspaceId,
    String? workerId,
    Map<String, String>? query,
    Map<String, dynamic>? body,
    required List<String> betas,
    required Future<void>? abortTrigger,
    AnthropicException? Function(String, ResponseMetadata)? handleError,
  }) {
    ensureNotClosed?.call();
    if (!allowBearer && _bearerToken != null) {
      throw ArgumentError(
        'Use management credentials for work retrieval and updates',
      );
    }
    final path = '/v1/environments/${_id(environmentId)}/work$suffix';
    final headers = requestBuilder.buildHeaders(
      includeWorkspace: includeWorkspace,
      additionalHeaders: {
        'anthropic-beta': {...betas, 'managed-agents-2026-04-01'}.join(','),
        'anthropic-workspace-id': ?workspaceId,
        'anthropic-worker-id': ?workerId,
      },
    );
    if (!includeWorkspace) headers.remove('anthropic-workspace-id');
    final request = http.Request(
      method,
      requestBuilder.buildUrl(path, queryParams: query),
    )..headers.addAll(headers);
    if (body != null) request.body = jsonEncode(body);
    return sendProtectedResourceRequest(
      this,
      request,
      bearerToken: _bearerToken,
      abortTrigger: abortTrigger,
      handleError: handleError,
    );
  }

  AnthropicException? _heartbeatError(String body, ResponseMetadata metadata) {
    if (metadata.statusCode != 412) return null;
    try {
      if (jsonDecode(body) case {
        'error': {
          'details': {
            'error_code': 'heartbeat_precondition_failed',
            'current_state': final Map<String, dynamic> state,
          },
        },
      }) {
        return EnvironmentHeartbeatConflictException(
          currentState: EnvironmentWorkLeaseState.fromJson(state),
          responseMetadata: metadata,
        );
      }
    } on FormatException {
      // Keep the HTTP error if the provider error body is malformed.
    } on TypeError {
      // The typed lease details are optional when the server shape differs.
    }
    return null;
  }
}
