import 'package:googleai_dart/src/auth/auth_provider.dart';
import 'package:googleai_dart/src/client/config.dart';
import 'package:googleai_dart/src/errors/exceptions.dart';
import 'package:googleai_dart/src/live/live_client.dart';
import 'package:test/test.dart';

void main() {
  group('LiveClient.buildWebSocketUri - Google AI mode', () {
    test('builds the default wss URI', () {
      const config = GoogleAIConfig();

      final uri = LiveClient.buildWebSocketUri(config, {'key': 'k'});

      expect(uri.scheme, equals('wss'));
      expect(uri.host, equals('generativelanguage.googleapis.com'));
      expect(uri.port, equals(443));
      expect(
        uri.path,
        equals(
          '/ws/google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateContent',
        ),
      );
      expect(uri.queryParameters['key'], equals('k'));
    });

    test('a trailing slash in the base URL does not corrupt the host', () {
      const config = GoogleAIConfig(
        baseUrl: 'https://generativelanguage.googleapis.com/',
      );

      final uri = LiveClient.buildWebSocketUri(config, {});

      expect(uri.host, equals('generativelanguage.googleapis.com'));
      expect(
        uri.path,
        equals(
          '/ws/google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateContent',
        ),
      );
    });

    test('a base URL sub-path is prepended to the ws path', () {
      const config = GoogleAIConfig(
        baseUrl: 'https://proxy.example.com/gemini',
      );

      final uri = LiveClient.buildWebSocketUri(config, {});

      expect(uri.host, equals('proxy.example.com'));
      expect(
        uri.path,
        equals(
          '/gemini/ws/google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateContent',
        ),
      );
    });

    test('a scheme-less base URL is treated as https/wss', () {
      const config = GoogleAIConfig(
        baseUrl: 'generativelanguage.googleapis.com',
      );

      final uri = LiveClient.buildWebSocketUri(config, {});

      expect(uri.scheme, equals('wss'));
      expect(uri.host, equals('generativelanguage.googleapis.com'));
      expect(uri.port, equals(443));
    });

    test('an http base URL maps to ws and preserves the port', () {
      const config = GoogleAIConfig(baseUrl: 'http://localhost:8765');

      final uri = LiveClient.buildWebSocketUri(config, {});

      expect(uri.scheme, equals('ws'));
      expect(uri.host, equals('localhost'));
      expect(uri.port, equals(8765));
    });

    test('preserves query params carried by the base URL', () {
      const config = GoogleAIConfig(
        baseUrl: 'https://proxy.example.com?token=abc',
      );

      final uri = LiveClient.buildWebSocketUri(config, {});

      expect(uri.queryParameters['token'], equals('abc'));
    });

    test('defaultQueryParams override auth params (existing order)', () {
      const config = GoogleAIConfig(defaultQueryParams: {'key': 'default'});

      final uri = LiveClient.buildWebSocketUri(config, {'key': 'auth'});

      expect(uri.queryParameters['key'], equals('default'));
    });

    test('a supplied token selects the constrained v1beta endpoint', () {
      const config = GoogleAIConfig(
        apiVersion: ApiVersion.v1,
        baseUrl: 'https://proxy.example.com/tenant/?key=base&tag=a&tag=b',
        defaultQueryParams: {
          'access_token': 'default-token',
          'x-goog-api-key': 'default-key',
        },
      );
      final uri = LiveClient.buildWebSocketUri(config, {
        'access_token': 'auth_tokens/test-token',
        'key': 'provider-key',
      });
      expect(
        uri.path,
        '/tenant/ws/google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateContentConstrained',
      );
      expect(uri.queryParametersAll, {
        'tag': ['a', 'b'],
        'access_token': ['auth_tokens/test-token'],
      });
    });

    test(
      'header placement selects the constrained path without auth query',
      () {
        const config = GoogleAIConfig(
          baseUrl:
              'https://proxy.example.com/?access_token=base-token&key=base',
          defaultQueryParams: {
            'ACCESS_TOKEN': 'default-token',
            'key': 'default',
          },
        );
        final uri = LiveClient.buildWebSocketUri(
          config,
          {},
          useEphemeralHeader: true,
        );
        expect(uri.path.endsWith('.BidiGenerateContentConstrained'), isTrue);
        expect(uri.queryParameters, isEmpty);
      },
    );

    test('uses the configured API version in the path', () {
      const config = GoogleAIConfig(apiVersion: ApiVersion.v1);

      final uri = LiveClient.buildWebSocketUri(config, {});

      expect(
        uri.path,
        equals(
          '/ws/google.ai.generativelanguage.v1.GenerativeService.BidiGenerateContent',
        ),
      );
    });
  });

  group('LiveClient.buildWebSocketUri - Vertex AI mode', () {
    const locationHosts = {
      'global': 'aiplatform.googleapis.com',
      'us': 'aiplatform.us.rep.googleapis.com',
      'eu': 'aiplatform.eu.rep.googleapis.com',
    };

    for (final entry in locationHosts.entries) {
      test('${entry.key} uses its dedicated endpoint', () {
        final config = GoogleAIConfig.vertexAI(
          projectId: 'test-project',
          location: entry.key,
          authProvider: const ApiKeyProvider('test-key'),
        );

        final uri = LiveClient.buildWebSocketUri(config, {});

        expect(uri.scheme, 'wss');
        expect(uri.host, entry.value);
        expect(
          uri.path,
          '/ws/google.cloud.aiplatform.v1.LlmBidiService/BidiGenerateContent',
        );
        expect(uri.queryParameters, isEmpty);
      });
    }

    test('builds the regional Vertex beta URI', () {
      const config = GoogleAIConfig(
        apiMode: ApiMode.vertexAI,
        projectId: 'P',
        location: 'us-central1',
      );

      final uri = LiveClient.buildWebSocketUri(config, {});

      expect(uri.scheme, equals('wss'));
      expect(uri.host, equals('us-central1-aiplatform.googleapis.com'));
      expect(
        uri.path,
        equals(
          '/ws/google.cloud.aiplatform.v1beta1.LlmBidiService/BidiGenerateContent',
        ),
      );
      expect(uri.queryParameters, isEmpty);
    });

    test('maps ApiVersion.v1 to the v1 Live service', () {
      const config = GoogleAIConfig(
        apiMode: ApiMode.vertexAI,
        apiVersion: ApiVersion.v1,
        projectId: 'P',
        location: 'us-central1',
      );

      final uri = LiveClient.buildWebSocketUri(config, {});

      expect(
        uri.path,
        equals(
          '/ws/google.cloud.aiplatform.v1.LlmBidiService/BidiGenerateContent',
        ),
      );
    });

    test('preserves a custom base URI but discards URL bearer credentials', () {
      final config =
          GoogleAIConfig.vertexAI(
            projectId: 'P',
            location: 'eu',
            authProvider: const BearerTokenProvider('adc'),
          ).copyWith(
            baseUrl:
                'http://proxy.example.com:8765/tenant?access_token=bad&tag=a&tag=b',
          );
      final uri = LiveClient.buildWebSocketUri(config, {});
      expect(uri.scheme, 'ws');
      expect(uri.host, 'proxy.example.com');
      expect(uri.port, 8765);
      expect(
        uri.path,
        '/tenant/ws/google.cloud.aiplatform.v1.LlmBidiService/BidiGenerateContent',
      );
      expect(uri.queryParametersAll, {
        'tag': ['a', 'b'],
      });
    });

    test('throws LiveSessionSetupException when projectId is missing', () {
      const config = GoogleAIConfig(apiMode: ApiMode.vertexAI);

      expect(
        () => LiveClient.buildWebSocketUri(config, {}),
        throwsA(isA<LiveSessionSetupException>()),
      );
    });
  });
}
