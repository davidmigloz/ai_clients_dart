@TestOn('vm')
library;

import 'dart:io';

import 'package:ollama_dart/ollama_dart.dart';
import 'package:test/test.dart';

void main() {
  group('OllamaConfig.fromEnvironment', () {
    test(
      'creates config with default base URL when OLLAMA_HOST is not set',
      () {
        if (Platform.environment.containsKey('OLLAMA_HOST')) {
          markTestSkipped('OLLAMA_HOST is set');
          return;
        }
        // Should NOT throw - Ollama is local-first
        final config = OllamaConfig.fromEnvironment();
        expect(config, isNotNull);
      },
    );

    test('default base URL is http://localhost:11434', () {
      if (Platform.environment.containsKey('OLLAMA_HOST')) {
        markTestSkipped('OLLAMA_HOST is set');
        return;
      }
      final config = OllamaConfig.fromEnvironment();
      expect(config.baseUrl, 'http://localhost:11434');
    });

    test('reads OLLAMA_HOST when set', () {
      final host = Platform.environment['OLLAMA_HOST'];
      if (host == null || host.isEmpty) {
        markTestSkipped('OLLAMA_HOST not set');
        return;
      }
      final config = OllamaConfig.fromEnvironment();
      expect(config.baseUrl, host);
    });

    test('has no auth provider', () {
      if (Platform.environment.containsKey('OLLAMA_HOST')) {
        markTestSkipped('OLLAMA_HOST is set');
        return;
      }
      final config = OllamaConfig.fromEnvironment();
      expect(config.authProvider, isNull);
    });
  });

  group('OllamaClient.fromEnvironment', () {
    test('creates client with defaults when no env vars are set', () {
      if (Platform.environment.containsKey('OLLAMA_HOST')) {
        markTestSkipped('OLLAMA_HOST is set');
        return;
      }
      // Should NOT throw
      final client = OllamaClient.fromEnvironment();
      expect(client, isNotNull);
      client.close();
    });

    test('creates client when OLLAMA_HOST is set', () {
      final host = Platform.environment['OLLAMA_HOST'];
      if (host == null || host.isEmpty) {
        markTestSkipped('OLLAMA_HOST not set');
        return;
      }
      final client = OllamaClient.fromEnvironment();
      expect(client, isNotNull);
      client.close();
    });
  });
}
