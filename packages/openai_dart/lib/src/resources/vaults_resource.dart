import 'dart:convert';
import 'package:http/http.dart' as http;
import '../errors/exceptions.dart';
import '../models/agents/agent_enums.dart';
import '../models/agents/agent_json_helpers.dart';
import '../models/vaults/vault_models.dart';
import '../utils/private_audio_http.dart';
import 'base_resource.dart';

/// Project-scoped Vault management, available through `client.vaults`.
/// Creating a vault does not execute a model or tool. Deletion is not provider
/// revocation and does not cancel running work. All requests force Agents beta.
class VaultsResource extends ResourceBase with _VaultHttp {
  /// Creates a resource sharing the client's transport and authentication.
  VaultsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });
  VaultCredentialsResource? _credentials;

  /// Write-only credential creation/rotation and safe returned inspection.
  VaultCredentialsResource get credentials {
    ensureNotClosed?.call();
    return _credentials ??= VaultCredentialsResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
  }

  /// Creates configuration without starting a session or exposing stored secrets.
  Future<Vault> create(
    CreateVaultRequest request, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    request.validate();
    return _send(
      'POST',
      requestBuilder.buildUrl('/vaults'),
      Vault.fromJson,
      expectedStatus: 201,
      body: request.toJson(),
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Lists a page with ID cursors, AND metadata filters and eventual consistency.
  Future<VaultList> list({
    int? limit,
    AgentListOrder? order,
    String? after,
    Map<String, String>? metadata,
    VaultStatusFilter? status,
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    return _send(
      'GET',
      _listUrl(
        '/vaults',
        limit: limit,
        order: order,
        after: after,
        metadata: metadata,
        status: status,
      ),
      VaultList.fromJson,
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Retrieves safe stored metadata using opaque encoded IDs.
  Future<Vault> retrieve(
    String vaultId, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    return _send(
      'GET',
      requestBuilder.buildUrl(_vaultPath(vaultId)),
      Vault.fromJson,
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Replaces supplied metadata; omission retains and an empty map clears.
  Future<Vault> update(
    String vaultId,
    UpdateVaultRequest request, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    request.validate();
    return _send(
      'POST',
      requestBuilder.buildUrl(_vaultPath(vaultId)),
      Vault.fromJson,
      body: request.toJson(),
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Deletes the stored record; does not revoke provider credentials or cancel work.
  Future<DeletedVault> delete(
    String vaultId, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    return _send(
      'DELETE',
      requestBuilder.buildUrl(_vaultPath(vaultId)),
      DeletedVault.fromJson,
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }
}

/// Stored secrets are write-only. Returned auth contains safe metadata only.
/// Rotation preserves authentication method/destination and affects new sessions
/// or environments. OAuth consent and provider revocation belong to the caller.
class VaultCredentialsResource extends ResourceBase with _VaultHttp {
  /// Creates a resource sharing the client's transport and authentication.
  VaultCredentialsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Creates configuration without starting a session or exposing stored secrets.
  Future<VaultCredential> create(
    String vaultId,
    CreateVaultCredentialRequest request, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    request.validate();
    return _send(
      'POST',
      requestBuilder.buildUrl('${_vaultPath(vaultId)}/credentials'),
      VaultCredential.fromJson,
      expectedStatus: 201,
      body: request.toJson(),
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Lists a page with ID cursors, AND metadata filters and eventual consistency.
  Future<VaultCredentialList> list(
    String vaultId, {
    int? limit,
    AgentListOrder? order,
    String? after,
    Map<String, String>? metadata,
    VaultStatusFilter? status,
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    return _send(
      'GET',
      _listUrl(
        '${_vaultPath(vaultId)}/credentials',
        limit: limit,
        order: order,
        after: after,
        metadata: metadata,
        status: status,
      ),
      VaultCredentialList.fromJson,
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Retrieves safe stored metadata using opaque encoded IDs.
  Future<VaultCredential> retrieve(
    String vaultId,
    String credentialId, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    return _send(
      'GET',
      requestBuilder.buildUrl(
        '${_vaultPath(vaultId)}/credentials/${_vaultSegment(credentialId)}',
      ),
      VaultCredential.fromJson,
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Rotates supplied secrets/metadata without changing method or destination.
  Future<VaultCredential> rotate(
    String vaultId,
    String credentialId,
    RotateVaultCredentialRequest request, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    request.validate();
    return _send(
      'POST',
      requestBuilder.buildUrl(
        '${_vaultPath(vaultId)}/credentials/${_vaultSegment(credentialId)}',
      ),
      VaultCredential.fromJson,
      body: request.toJson(),
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Deletes the stored record; does not revoke provider credentials or cancel work.
  Future<DeletedVaultCredential> delete(
    String vaultId,
    String credentialId, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    return _send(
      'DELETE',
      requestBuilder.buildUrl(
        '${_vaultPath(vaultId)}/credentials/${_vaultSegment(credentialId)}',
      ),
      DeletedVaultCredential.fromJson,
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }
}

mixin _VaultHttp on ResourceBase {
  Future<T> _send<T>(
    String method,
    Uri url,
    T Function(Map<String, dynamic>) parse, {
    int expectedStatus = 200,
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) async {
    // Detach caller options before cancellation detection suspends dispatch.
    final callerHeaders = additionalHeaders == null
        ? null
        : Map<String, String>.unmodifiable(additionalHeaders);
    await checkPrivateAudioAbort(abortTrigger, 'Vaults');
    final request = http.Request(method, url)
      ..headers.addAll(
        requestBuilder.buildBetaHeaders(
          betaFeature: 'agents=v1',
          additionalHeaders: callerHeaders,
        ),
      );
    // Apply required values to http's case-insensitive map after caller merges.
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
    final response = await sendPrivateAudioRequest(
      request,
      interceptorChain: interceptorChain,
      context: 'Vaults',
      abortTrigger: abortTrigger,
    );
    if (response.statusCode != expectedStatus) {
      throw ParseException(
        message: 'Unexpected Vaults success status; expected $expectedStatus.',
        responseBody: utf8.decode(response.bodyBytes, allowMalformed: true),
      );
    }
    return parsePrivateAudioResponse(response, parse, 'Vaults');
  }

  Uri _listUrl(
    String path, {
    int? limit,
    AgentListOrder? order,
    String? after,
    Map<String, String>? metadata,
    VaultStatusFilter? status,
  }) {
    if (limit != null) {
      validateAgentInt(limit, 'Vault list.limit', min: 1, max: 100);
    }
    if (order != null) {
      validateAgentEnum(order.value, const ['asc', 'desc'], 'Vault list.order');
    }
    if (after != null) {
      validateAgentLength(after, 'Vault list.after', max: 1048576);
    }
    if (metadata != null) {
      validateAgentCount(metadata.length, 'Vault list.metadata', max: 16);
      for (final entry in metadata.entries) {
        validateAgentLength(
          entry.key,
          'Vault list.metadata key',
          min: 1,
          max: 64,
        );
        validateAgentLength(entry.value, 'Vault list.metadata value', max: 512);
      }
    }
    status?.validate();
    final url = requestBuilder.buildUrlWithQueryAll(
      path,
      queryParameters: {
        if (limit != null) 'limit': limit.toString(),
        if (order != null) 'order': order.value,
        'after': ?after,
        if (metadata != null)
          for (final entry in metadata.entries)
            'metadata[${entry.key}]': entry.value,
        if (status is VaultSingleStatus) 'status': status.status.value,
      },
      queryParametersAll: {
        if (status is VaultMultipleStatuses)
          'status[]': status.statuses.map((v) => v.value).toList(),
      },
    );
    // A selected shape replaces any conflicting inherited status shape. An
    // empty status array supplies no pairs, leaving both statuses as defaults.
    if (status == null) return url;
    final query = Map<String, List<String>>.of(url.queryParametersAll);
    if (status is VaultSingleStatus) query.remove('status[]');
    if (status is VaultMultipleStatuses) {
      query.remove('status');
      if (status.statuses.isEmpty) query.remove('status[]');
    }
    return url.replace(queryParameters: query);
  }
}

String _vaultPath(String id) => '/vaults/${_vaultSegment(id)}';
String _vaultSegment(String id) {
  validateAgentLength(id, 'Vault resource ID', max: 1048576);
  if (id.isEmpty || id == '.' || id == '..') {
    throw const FormatException(
      'Vault resource ID: expected an opaque segment',
    );
  }
  try {
    return Uri.encodeComponent(id);
  } on ArgumentError {
    throw const FormatException(
      'Vault resource ID: expected an encodable segment',
    );
  }
}
