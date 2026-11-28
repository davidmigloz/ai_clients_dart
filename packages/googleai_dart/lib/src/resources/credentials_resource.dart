import 'dart:convert';

import 'package:http/http.dart' as http;

import '../client/config.dart';
import '../models/credentials/credentials.dart';
import '../utils/redactor.dart';
import 'base_resource.dart';

/// Manages credentials used by Gemini managed agents.
///
/// Available on the Gemini Developer API with [ApiVersion.v1beta].
class CredentialsResource extends ResourceBase {
  /// Creates the credentials resource.
  CredentialsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  static const _secretFields = {
    'value',
    'token',
    'client_secret',
    'refresh_token',
    'clientSecret',
    'refreshToken',
  };

  static const List<String> _diagnosticFields = [
    ..._secretFields,
    'authorization',
    'x-goog-api-key',
    'key',
  ];

  /// Stores a credential and returns its metadata.
  ///
  /// Omit [CredentialCreateParams.id] to use a server-generated UUID.
  Future<Credential> create({
    required CredentialCreateParams credential,
    Future<void>? abortTrigger,
  }) async => Credential.fromJson(
    _decode(
      await _send(
        'POST',
        body: credential.toJson(),
        abortTrigger: abortTrigger,
      ),
    ),
  );

  /// Lists credential metadata. Pass the returned next-page token to continue.
  Future<ListCredentialsResponse> list({
    int? pageSize,
    String? pageToken,
    Future<void>? abortTrigger,
  }) async => ListCredentialsResponse.fromJson(
    _decode(
      await _send(
        'GET',
        queryParams: {
          if (pageSize != null) 'page_size': '$pageSize',
          'page_token': ?pageToken,
        },
        abortTrigger: abortTrigger,
      ),
    ),
  );

  /// Retrieves credential metadata by ID.
  Future<Credential> get(String id, {Future<void>? abortTrigger}) async =>
      Credential.fromJson(
        _decode(await _send('GET', id: id, abortTrigger: abortTrigger)),
      );

  /// Updates a stored credential without returning its secret values.
  ///
  /// [updateMask] is a comma-separated list of wire field names to update.
  Future<Credential> update(
    String id, {
    required CredentialUpdateParams credential,
    String? updateMask,
    Future<void>? abortTrigger,
  }) async => Credential.fromJson(
    _decode(
      await _send(
        'PATCH',
        id: id,
        body: credential.toJson(),
        queryParams: {'update_mask': ?updateMask},
        abortTrigger: abortTrigger,
      ),
    ),
  );

  /// Deletes a stored credential.
  Future<void> delete(String id, {Future<void>? abortTrigger}) async {
    await _send('DELETE', id: id, abortTrigger: abortTrigger);
  }

  Future<http.Response> _send(
    String method, {
    String? id,
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    Future<void>? abortTrigger,
  }) {
    if (config.apiMode != ApiMode.googleAI ||
        config.apiVersion != ApiVersion.v1beta) {
      throw UnsupportedError(
        'The Credentials API requires the Gemini Developer API with '
        'ApiVersion.v1beta.',
      );
    }
    if (id != null && (id.isEmpty || id == '.' || id == '..')) {
      throw ArgumentError('Expected a credential ID');
    }
    final path = id == null
        ? '/{version}/credentials'
        : '/{version}/credentials/${Uri.encodeComponent(id)}';
    final request =
        http.Request(
            method,
            requestBuilder.buildUrl(path, queryParams: queryParams),
          )
          ..headers.addAll(
            requestBuilder.buildHeaders(
              additionalHeaders: body == null
                  ? null
                  : const {'Content-Type': 'application/json'},
            ),
          );
    if (body != null) request.body = jsonEncode(body);

    final secrets = {
      for (final key in _secretFields)
        if (body?[key] case final String secret when secret.isNotEmpty) secret,
    };
    return interceptorChain.execute(
      request,
      abortTrigger: abortTrigger,
      diagnosticRedactor: Redactor.forSecrets(
        redactionList: _diagnosticFields,
        secrets: secrets,
      ),
    );
  }

  Map<String, dynamic> _decode(http.Response response) {
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) return decoded;
    } on FormatException {
      // An exception thrown by the decoder can retain its input.
    }
    throw const FormatException(
      'Expected a JSON object from the Credentials API',
    );
  }
}
