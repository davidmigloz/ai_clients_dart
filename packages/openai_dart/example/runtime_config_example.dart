/// Demonstrates immutable resource configuration and request-local auth rotation.
/// Synthetic HTTP only: no API key, cloud call, or API cost.
library;

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  var currentToken = 'synthetic_initial';
  final requests = <http.Request>[];
  final transport = MockClient((request) async {
    requests.add(request);
    final expected = request.url.host == 'first.invalid'
        ? currentToken
        : 'synthetic_second';
    if (request.headers['authorization'] != 'Bearer $expected') {
      throw StateError('The request did not keep its own credentials.');
    }
    return http.Response(
      jsonEncode({'object': 'list', 'data': <Object?>[]}),
      200,
      headers: {'content-type': 'application/json'},
    );
  });
  final client = OpenAIClient(
    config: OpenAIConfig(
      baseUrl: 'https://first.invalid/v1',
      authProvider: _RotatingAuth(() => currentToken),
    ),
    httpClient: transport,
  );
  try {
    final retained = client.models;
    await retained.list();

    // A provider can resolve fresh credentials for retained handles without
    // putting a mutable last-resolved bearer token on the shared client.
    currentToken = 'synthetic_rotated';
    client.updateConfig(
      baseUrl: 'https://second.invalid/proxy/v1',
      authProvider: const ApiKeyProvider('synthetic_second'),
      timeout: const Duration(seconds: 30),
      organization: null,
    );
    await retained.list(); // Keeps the first route/provider configuration.
    await client.models.list(); // Newly acquired handle uses the new settings.
    if (requests.map((r) => r.url.host).join(',') !=
        'first.invalid,first.invalid,second.invalid') {
      throw StateError('Configuration snapshots were mixed.');
    }
    stdout.writeln(
      'Kept the retained handle and refreshed the next handle: '
      '${requests.length} synthetic requests, zero external API calls.',
    );
  } finally {
    client.close();
    transport.close(); // Injected transports remain caller-owned.
  }
}

class _RotatingAuth implements AuthProvider {
  _RotatingAuth(this._token);
  final String Function() _token;
  @override
  Map<String, String> getHeaders() => {'Authorization': 'Bearer ${_token()}'};
}
