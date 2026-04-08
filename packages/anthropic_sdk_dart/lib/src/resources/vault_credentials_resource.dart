import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/managed_agents/credentials/create_credential_params.dart';
import '../models/managed_agents/credentials/credential.dart';
import '../models/managed_agents/credentials/credential_list_response.dart';
import '../models/managed_agents/credentials/update_credential_params.dart';
import 'base_resource.dart';

/// Beta header for the Managed Agents API.
const _betaHeader = 'managed-agents-2026-04-01';

/// Resource for vault credentials (Beta).
///
/// Credentials store authentication details used by agents during sessions.
class VaultCredentialsResource extends ResourceBase {
  /// The vault ID this resource is scoped to.
  final String vaultId;

  /// Creates a [VaultCredentialsResource].
  VaultCredentialsResource({
    required this.vaultId,
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Creates a new credential in the vault.
  ///
  /// The optional [abortTrigger] allows canceling the request.
  Future<Credential> create(
    CreateCredentialParams request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/vaults/$vaultId/credentials');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'anthropic-beta': _betaHeader},
    );
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return Credential.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Lists credentials in the vault.
  ///
  /// Parameters:
  /// - [limit]: Maximum number of credentials to return.
  /// - [page]: Pagination token from a previous response.
  /// - [includeArchived]: Whether to include archived credentials.
  /// - [abortTrigger]: Allows canceling the request.
  Future<ListCredentialsResponse> list({
    int? limit,
    String? page,
    bool? includeArchived,
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, dynamic>{
      'limit': ?limit?.toString(),
      'page': ?page,
      'include_archived': ?includeArchived?.toString(),
    };

    final url = requestBuilder.buildUrl(
      '/v1/vaults/$vaultId/credentials',
      queryParams: queryParams.isEmpty ? null : queryParams,
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'anthropic-beta': _betaHeader},
    );
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return ListCredentialsResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Retrieves a specific credential.
  ///
  /// Parameters:
  /// - [credentialId]: The ID of the credential to retrieve.
  /// - [abortTrigger]: Allows canceling the request.
  Future<Credential> retrieve(
    String credentialId, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/vaults/$vaultId/credentials/$credentialId',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'anthropic-beta': _betaHeader},
    );
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return Credential.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Updates a credential.
  ///
  /// Parameters:
  /// - [credentialId]: The ID of the credential to update.
  /// - [request]: The update parameters.
  /// - [abortTrigger]: Allows canceling the request.
  Future<Credential> update(
    String credentialId,
    UpdateCredentialParams request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/vaults/$vaultId/credentials/$credentialId',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'anthropic-beta': _betaHeader},
    );
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return Credential.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Deletes a credential.
  ///
  /// Parameters:
  /// - [credentialId]: The ID of the credential to delete.
  /// - [abortTrigger]: Allows canceling the request.
  Future<DeletedCredential> delete(
    String credentialId, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/vaults/$vaultId/credentials/$credentialId',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'anthropic-beta': _betaHeader},
    );
    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return DeletedCredential.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Archives a credential.
  ///
  /// Parameters:
  /// - [credentialId]: The ID of the credential to archive.
  /// - [abortTrigger]: Allows canceling the request.
  Future<Credential> archive(
    String credentialId, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/vaults/$vaultId/credentials/$credentialId/archive',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'anthropic-beta': _betaHeader},
    );
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(<String, dynamic>{});

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return Credential.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
