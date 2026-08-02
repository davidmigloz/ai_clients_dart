import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/interactions/environments/environments.dart';
import 'base_resource.dart';

/// Resource for the Environments API.
///
/// Provides CRUD operations on execution [Environment]s (sandboxes) that
/// agents and interactions can run in.
///
/// **Note:** the Environments API is part of the experimental Interactions
/// API.
class EnvironmentsResource extends ResourceBase {
  /// Creates an [EnvironmentsResource].
  EnvironmentsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// The Interactions API schema revision this client targets.
  ///
  /// Sent via the `Api-Revision` header on every request, mirroring the
  /// official google-genai SDK, which sends it unconditionally for the
  /// Interactions API family (interactions, agents, webhooks).
  ///
  /// See https://ai.google.dev/gemini-api/docs/interactions-breaking-changes-may-2026
  static const _apiRevision = '2026-05-20';

  /// Builds headers for an Environments API request, always opting into the
  /// [_apiRevision] schema via the `Api-Revision` header.
  Map<String, String> _buildHeaders([Map<String, String>? additionalHeaders]) {
    return requestBuilder.buildHeaders(
      // Spread additionalHeaders first so the Api-Revision opt-in always wins.
      additionalHeaders: {...?additionalHeaders, 'Api-Revision': _apiRevision},
    );
  }

  /// Lists environments.
  ///
  /// [pageSize] caps the maximum number of environments per page and
  /// [pageToken] is used for pagination.
  Future<ListEnvironmentsResponse> list({
    int? pageSize,
    String? pageToken,
  }) async {
    final queryParams = <String, String>{
      if (pageSize != null) 'page_size': pageSize.toString(),
      'page_token': ?pageToken,
    };

    final url = requestBuilder.buildUrl(
      '/{version}/environments',
      queryParams: queryParams,
    );

    final headers = _buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ListEnvironmentsResponse.fromJson(responseBody);
  }

  /// Creates a new [Environment].
  ///
  /// Returns the created environment with its server-assigned
  /// [Environment.id] populated.
  Future<Environment> create({
    required CreateEnvironmentRequest environment,
  }) async {
    final url = requestBuilder.buildUrl('/{version}/environments');

    final headers = _buildHeaders(const {'Content-Type': 'application/json'});

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(environment.toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return Environment.fromJson(responseBody);
  }

  /// Gets a specific environment by [id].
  Future<Environment> get(String id) async {
    final url = requestBuilder.buildUrl('/{version}/environments/$id');

    final headers = _buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return Environment.fromJson(responseBody);
  }

  /// Deletes an environment by [id].
  Future<void> delete(String id) async {
    final url = requestBuilder.buildUrl('/{version}/environments/$id');

    final headers = _buildHeaders();

    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);

    await interceptorChain.execute(httpRequest);
  }
}
