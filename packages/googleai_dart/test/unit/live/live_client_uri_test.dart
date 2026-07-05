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
    test('builds the vertex wss URI with project/location params', () {
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
          '/ws/google.cloud.aiplatform.v1beta1.PredictionService.BidiGenerateContent',
        ),
      );
      expect(uri.queryParameters['project'], equals('P'));
      expect(uri.queryParameters['location'], equals('us-central1'));
    });

    test('maps ApiVersion.v1 to the v1 prediction service', () {
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
          '/ws/google.cloud.aiplatform.v1.PredictionService.BidiGenerateContent',
        ),
      );
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
