import 'dart:async';

import 'package:http/http.dart' as http;

import 'provider_transport.dart';

/// Returns an OAuth access token for a cloud provider request.
typedef CloudAccessTokenProvider = FutureOr<String> Function();

/// Validates and attaches the selected cloud credential.
final class CloudRequestAuth {
  /// Selects an API key, OAuth token, or preauthenticated gateway.
  const CloudRequestAuth({
    this.apiKey,
    this.tokenProvider,
    this.skipAuth = false,
  });

  /// The provider-issued API key, when available.
  final String? apiKey;

  /// Resolves a fresh OAuth token on each request.
  final CloudAccessTokenProvider? tokenProvider;

  /// Uses caller-supplied gateway authentication.
  final bool skipAuth;

  /// Applies the configured credential to this provider request.
  Future<void> apply(ProviderRequest request) async {
    if (skipAuth) return;
    request.headers
      ..remove('x-api-key')
      ..remove('api-key');
    if (apiKey case final key?) {
      if (!_validToken(key)) throw ArgumentError('Invalid provider API key');
      request.headers
        ..remove('authorization')
        ..['x-api-key'] = key;
      return;
    }
    if (request.headers['authorization']?.isNotEmpty == true) return;
    final String token;
    try {
      token = await tokenProvider!();
      if (!_validToken(token)) throw StateError('Invalid access token');
    } catch (_) {
      throw http.ClientException(
        'Could not resolve cloud OAuth access token',
        request.uri,
      );
    }
    request.headers['authorization'] = 'Bearer $token';
  }
}

final _invalidHeaderByte = RegExp(r'[^\x21-\x7e]');

bool _validToken(String value) =>
    value.isNotEmpty && !_invalidHeaderByte.hasMatch(value);
