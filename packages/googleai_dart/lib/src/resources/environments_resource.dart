import 'dart:async' show Completer, Timer, unawaited;
import 'dart:convert';
import 'dart:math' show min;
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../client/config.dart';
import '../client/interceptor_chain.dart';
import '../errors/exceptions.dart';
import '../interceptors/auth_interceptor.dart';
import '../interceptors/interceptor.dart';
import '../models/interactions/environments/environments.dart';
import '../utils/redactor.dart';
import '../utils/request_id.dart';
import 'base_resource.dart';

part 'environment_files_resource.dart';

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

  /// Files and directories in an environment's workspace snapshot.
  late final files = EnvironmentFilesResource._(this);

  /// The Interactions API schema revision this client targets.
  ///
  /// Sent via the `Api-Revision` header on every request, mirroring the
  /// official google-genai SDK, which sends it unconditionally for the
  /// Interactions API family (interactions, agents, webhooks).
  ///
  /// See https://ai.google.dev/gemini-api/docs/interactions-breaking-changes-may-2026
  static const _apiRevision = '2026-05-20';

  static const _environmentDiagnostics = Redactor(
    redactionList: [
      'environment_key',
      'environmentKey',
      'authorization',
      'x-goog-api-key',
      'key',
    ],
  );

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
  /// [mode] filters by compute lifecycle mode on the Gemini Developer API
  /// with [ApiVersion.v1beta].
  /// [pageSize] caps the maximum number of environments per page and
  /// [pageToken] is used for pagination.
  Future<ListEnvironmentsResponse> list({
    EnvironmentMode? mode,
    int? pageSize,
    String? pageToken,
  }) async {
    if (mode != null) _ensureDeveloperBeta();
    final queryParams = <String, String>{
      if (mode != null) 'mode': mode.value,
      if (pageSize != null) 'page_size': pageSize.toString(),
      'page_token': ?pageToken,
    };

    final url = requestBuilder.buildUrl(
      '/{version}/environments',
      queryParams: queryParams,
    );

    final headers = _buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(
      httpRequest,
      diagnosticRedactor: _environmentDiagnostics,
    );
    return _decodeEnvironmentResponse(
      response,
      ListEnvironmentsResponse.fromJson,
    );
  }

  /// Creates a new [Environment].
  ///
  /// Returns the server-assigned [Environment.id]. Self-hosted creation also
  /// returns a one-time [Environment.environmentKey].
  /// The new configuration options require the Gemini Developer API
  /// with [ApiVersion.v1beta].
  Future<Environment> create({
    required CreateEnvironmentRequest environment,
  }) async {
    if (environment.mode != null ||
        environment.env != null ||
        environment.customConfig != null ||
        environment.fromEnvironment != null ||
        environment.systemInstruction != null) {
      _ensureDeveloperBeta();
    }
    final url = requestBuilder.buildUrl('/{version}/environments');

    final headers = _buildHeaders(const {'Content-Type': 'application/json'});

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(environment.toJson());

    final response = await interceptorChain.execute(
      httpRequest,
      diagnosticRedactor: _environmentDiagnostics,
      skipResponseBodyDiagnostics: true,
    );
    return _decodeEnvironmentResponse(response, Environment.fromJson);
  }

  /// Gets a specific environment by [id].
  Future<Environment> get(String id) async {
    final url = requestBuilder.buildUrl('/{version}/environments/$id');

    final headers = _buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(
      httpRequest,
      diagnosticRedactor: _environmentDiagnostics,
    );
    return _decodeEnvironmentResponse(response, Environment.fromMetadataJson);
  }

  T _decodeEnvironmentResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) parse,
  ) {
    try {
      return parse(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      );
    } on FormatException {
      // Malformed provider data can contain the one-time environment key.
    } on TypeError {
      // Preserve a source-free diagnostic for malformed field types.
    }
    throw const FormatException('Invalid Environments API response.');
  }

  /// Deletes an environment by [id].
  Future<void> delete(String id) async {
    final url = requestBuilder.buildUrl('/{version}/environments/$id');

    final headers = _buildHeaders();

    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);

    await interceptorChain.execute(httpRequest);
  }

  void _ensureDeveloperBeta() {
    if (config.apiMode != ApiMode.googleAI ||
        config.apiVersion != ApiVersion.v1beta) {
      throw UnsupportedError(
        'Environments require the Gemini Developer API with '
        'ApiVersion.v1beta.',
      );
    }
  }
}
