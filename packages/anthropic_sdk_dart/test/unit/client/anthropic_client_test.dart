@TestOn('vm')
library;

import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  group('AnthropicClient', () {
    test('can be created with default config', () {
      final client = AnthropicClient();

      expect(client.config, isNotNull);
      expect(client.config.baseUrl, 'https://api.anthropic.com');

      client.close();
    });

    test('can be created with custom config', () {
      final client = AnthropicClient(
        config: const AnthropicConfig(
          baseUrl: 'https://custom.anthropic.com',
          authProvider: ApiKeyProvider('test-key'),
        ),
      );

      expect(client.config.baseUrl, 'https://custom.anthropic.com');
      expect(client.config.authProvider, isA<ApiKeyProvider>());

      client.close();
    });

    test('can be created with custom HTTP client', () {
      final httpClient = http.Client();
      final client = AnthropicClient(httpClient: httpClient);

      expect(client, isNotNull);

      client.close();
      // httpClient is still usable because client didn't own it
    });

    test('exposes messages resource', () {
      final client = AnthropicClient();

      expect(client.messages, isNotNull);

      client.close();
    });

    test('exposes models resource', () {
      final client = AnthropicClient();

      expect(client.models, isNotNull);

      client.close();
    });

    test('exposes files resource', () {
      final client = AnthropicClient();

      expect(client.files, isNotNull);

      client.close();
    });

    test('exposes skills resource', () {
      final client = AnthropicClient();

      expect(client.skills, isNotNull);

      client.close();
    });

    test('exposes nested batches resource via messages', () {
      final client = AnthropicClient();

      expect(client.messages.batches, isNotNull);

      client.close();
    });

    test('exposes interceptorChain for advanced usage', () {
      final client = AnthropicClient();

      expect(client.interceptorChain, isNotNull);

      client.close();
    });

    test('exposes requestBuilder for advanced usage', () {
      final client = AnthropicClient();

      expect(client.requestBuilder, isNotNull);

      client.close();
    });

    test('exposes httpClient for streaming', () {
      final client = AnthropicClient();

      expect(client.httpClient, isNotNull);

      client.close();
    });

    test('close can be called multiple times safely', () {
      final client = AnthropicClient()..close();

      // Should not throw when called again
      expect(client.close, returnsNormally);
    });

    test('throws StateError when used after close', () async {
      final client = AnthropicClient()..close();
      await expectLater(
        client.messages.create(
          MessageCreateRequest(
            model: 'claude-sonnet-4-20250514',
            maxTokens: 100,
            messages: [InputMessage.user('Hi')],
          ),
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('does not close custom httpClient', () {
      final httpClient = _SpyHttpClient();
      // ignore: unused_local_variable
      final client = AnthropicClient(httpClient: httpClient)..close();
      expect(httpClient.closeCalled, isFalse);
    });

    group('fromEnvironment', () {
      test('throws StateError when ANTHROPIC_API_KEY is not set', () {
        if (Platform.environment['ANTHROPIC_API_KEY']?.isNotEmpty ?? false) {
          markTestSkipped('ANTHROPIC_API_KEY is set');
          return;
        }
        expect(AnthropicClient.fromEnvironment, throwsA(isA<StateError>()));
      });
    });
  });
}

class _SpyHttpClient extends http.BaseClient {
  bool closeCalled = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    throw UnimplementedError();
  }

  @override
  void close() {
    closeCalled = true;
  }
}
