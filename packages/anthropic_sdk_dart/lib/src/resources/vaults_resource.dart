import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/managed_agents/vaults/create_vault_params.dart';
import '../models/managed_agents/vaults/update_vault_params.dart';
import '../models/managed_agents/vaults/vault.dart';
import '../models/managed_agents/vaults/vault_list_response.dart';
import 'base_resource.dart';
import 'vault_credentials_resource.dart';

/// Beta header for the Managed Agents API.
const _betaHeader = 'managed-agents-2026-04-01';

/// Resource for the Vaults API (Beta).
///
/// Vaults store credentials for use by agents during sessions.
/// This is a beta feature and requires the `anthropic-beta` header.
class VaultsResource extends ResourceBase {
  /// Creates a [VaultsResource].
  VaultsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Returns a [VaultCredentialsResource] scoped to the given [vaultId].
  VaultCredentialsResource credentials(String vaultId) {
    return VaultCredentialsResource(
      vaultId: vaultId,
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
  }

  /// Creates a new vault.
  ///
  /// The optional [abortTrigger] allows canceling the request.
  Future<Vault> create(
    CreateVaultParams request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/vaults');
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

    return Vault.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Lists vaults.
  ///
  /// Parameters:
  /// - [limit]: Maximum number of vaults to return.
  /// - [page]: Pagination token from a previous response.
  /// - [includeArchived]: Whether to include archived vaults.
  /// - [abortTrigger]: Allows canceling the request.
  Future<ListVaultsResponse> list({
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
      '/v1/vaults',
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

    return ListVaultsResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Retrieves a specific vault.
  ///
  /// Parameters:
  /// - [vaultId]: The ID of the vault to retrieve.
  /// - [abortTrigger]: Allows canceling the request.
  Future<Vault> retrieve(String vaultId, {Future<void>? abortTrigger}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/vaults/$vaultId');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'anthropic-beta': _betaHeader},
    );
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return Vault.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Updates a vault.
  ///
  /// Parameters:
  /// - [vaultId]: The ID of the vault to update.
  /// - [request]: The update parameters.
  /// - [abortTrigger]: Allows canceling the request.
  Future<Vault> update(
    String vaultId,
    UpdateVaultParams request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/vaults/$vaultId');
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

    return Vault.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Deletes a vault.
  ///
  /// Parameters:
  /// - [vaultId]: The ID of the vault to delete.
  /// - [abortTrigger]: Allows canceling the request.
  Future<DeletedVault> delete(
    String vaultId, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/vaults/$vaultId');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'anthropic-beta': _betaHeader},
    );
    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return DeletedVault.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Archives a vault.
  ///
  /// Parameters:
  /// - [vaultId]: The ID of the vault to archive.
  /// - [abortTrigger]: Allows canceling the request.
  Future<Vault> archive(String vaultId, {Future<void>? abortTrigger}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/vaults/$vaultId/archive');
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

    return Vault.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
