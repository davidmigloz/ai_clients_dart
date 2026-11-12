import 'dart:convert';
import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _defaultBase = 'https://api.anthropic.com';
const _proxyBase = 'https://fixture.invalid/proxy';
const _route = '/v1/messages/count_tokens';

String? _credentialCase(String? value, String fixture) => switch (value) {
  null => null,
  _ when value == fixture => 'fixture',
  _ => 'other',
};

Future<void> main() async {
  final result = <String, Object?>{};
  try {
    result['baseUrlCase'] = switch (AnthropicConfig.fromEnvironment().baseUrl) {
      _defaultBase => 'default',
      _proxyBase => 'proxy',
      _ => 'other',
    };
  } on StateError catch (error) {
    result['configError'] = error.message;
  }
  final transport = MockClient((request) async {
    result['requestRoute'] = switch (request.url.toString()) {
      '$_defaultBase$_route' => 'default',
      '$_proxyBase$_route' => 'proxy',
      _ => 'other',
    };
    result['apiKey'] = _credentialCase(
      request.headers['x-api-key'],
      'fixture-api-key',
    );
    result['authorization'] = _credentialCase(
      request.headers['authorization'],
      'Bearer fixture-oauth-token',
    );
    result['beta'] = request.headers['anthropic-beta'];
    return http.Response('{"input_tokens":1}', 200);
  });
  try {
    final client = AnthropicClient.fromEnvironment(httpClient: transport);
    try {
      await client.messages.countTokens(
        TokenCountRequest(
          model: 'claude-sonnet-5-5',
          messages: [InputMessage.user('Local credential fixture.')],
        ),
      );
    } finally {
      client.close();
    }
  } on StateError catch (error) {
    result['clientError'] = error.message;
  } on FormatException catch (error) {
    result['clientError'] =
        error.message == 'Invalid authentication header value'
        ? error.message
        : 'Invalid fixture request';
  } finally {
    transport.close();
  }
  stdout.writeln(jsonEncode(result));
}
