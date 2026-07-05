import 'package:googleai_dart/src/client/config.dart';
import 'package:googleai_dart/src/client/endpoint_config.dart';
import 'package:googleai_dart/src/client/request_builder.dart';
import 'package:test/test.dart';

void main() {
  group('RequestBuilder.buildUrl - URL joining', () {
    test('normalizes a trailing slash in the base URL (no double slash)', () {
      const builder = RequestBuilder(
        config: GoogleAIConfig(baseUrl: 'https://api.example.com/'),
      );

      final url = builder.buildUrl('/{version}/models/m:generateContent');

      expect(url.path, equals('/v1beta/models/m:generateContent'));
      expect(
        url.toString(),
        equals('https://api.example.com/v1beta/models/m:generateContent'),
      );
    });

    test('preserves a base URL sub-path (proxy)', () {
      const builder = RequestBuilder(
        config: GoogleAIConfig(baseUrl: 'https://proxy.example.com/gemini'),
      );

      final url = builder.buildUrl('/{version}/models/m:generateContent');

      expect(url.path, equals('/gemini/v1beta/models/m:generateContent'));
    });

    test('preserves a base URL sub-path with a trailing slash', () {
      const builder = RequestBuilder(
        config: GoogleAIConfig(baseUrl: 'https://proxy.example.com/gemini/'),
      );

      final url = builder.buildUrl('/{version}/models/m:generateContent');

      expect(url.path, equals('/gemini/v1beta/models/m:generateContent'));
    });

    test('preserves query params carried by the base URL', () {
      const builder = RequestBuilder(
        config: GoogleAIConfig(baseUrl: 'https://api.example.com?token=abc'),
      );

      final url = builder.buildUrl('/{version}/files');

      expect(url.path, equals('/v1beta/files'));
      expect(url.queryParameters['token'], equals('abc'));
    });

    test('preserves repeated query keys carried by the base URL', () {
      const builder = RequestBuilder(
        config: GoogleAIConfig(baseUrl: 'https://api.example.com?a=1&a=2'),
      );

      final url = builder.buildUrl('/{version}/files');

      expect(url.queryParametersAll['a'], equals(['1', '2']));
      expect(url.toString(), contains('a=1&a=2'));
    });

    test('merges all four query param layers with correct precedence', () {
      const builder = RequestBuilder(
        config: GoogleAIConfig(
          baseUrl: 'https://api.example.com?p=base&b=b',
          defaultQueryParams: {'p': 'default', 'd': 'd'},
        ),
      );

      final url = builder.buildUrl(
        '/{version}/files',
        endpointConfig: const EndpointConfig(
          queryParams: {'p': 'endpoint', 'e': 'e'},
        ),
        queryParams: {'p': 'request'},
      );

      expect(url.queryParameters['p'], equals('request'));
      expect(url.queryParameters['b'], equals('b'));
      expect(url.queryParameters['d'], equals('d'));
      expect(url.queryParameters['e'], equals('e'));
    });

    test('vertex mode injects project path with a trailing-slash base', () {
      const builder = RequestBuilder(
        config: GoogleAIConfig(
          baseUrl: 'https://us-central1-aiplatform.googleapis.com/',
          apiMode: ApiMode.vertexAI,
          projectId: 'P',
          location: 'L',
        ),
      );

      final url = builder.buildUrl('/{version}/models/m:generateContent');

      expect(
        url.path,
        equals(
          '/v1beta/projects/P/locations/L/publishers/google/models/m:generateContent',
        ),
      );
    });

    test('vertex mode composes with a base URL sub-path', () {
      const builder = RequestBuilder(
        config: GoogleAIConfig(
          baseUrl: 'https://proxy.example.com/vtx',
          apiMode: ApiMode.vertexAI,
          projectId: 'P',
          location: 'L',
        ),
      );

      final url = builder.buildUrl('/{version}/models/m:generateContent');

      expect(
        url.path,
        equals(
          '/vtx/v1beta/projects/P/locations/L/publishers/google/models/m:generateContent',
        ),
      );
    });

    test('preserves scheme and port for a local base URL', () {
      const builder = RequestBuilder(
        config: GoogleAIConfig(baseUrl: 'http://localhost:8080'),
      );

      final url = builder.buildUrl('/{version}/files');

      expect(url.scheme, equals('http'));
      expect(url.port, equals(8080));
      expect(url.path, equals('/v1beta/files'));
    });

    test('emits no stray ? when there are no query params', () {
      const builder = RequestBuilder(
        config: GoogleAIConfig(baseUrl: 'https://api.example.com'),
      );

      final url = builder.buildUrl('/{version}/files');

      expect(url.hasQuery, isFalse);
      expect(url.toString(), isNot(endsWith('?')));
    });
  });

  group('RequestBuilder.buildUploadUrl', () {
    test(
      'builds an upload URL without a double slash on trailing-slash base',
      () {
        const builder = RequestBuilder(
          config: GoogleAIConfig(
            baseUrl: 'https://generativelanguage.googleapis.com/',
          ),
        );

        final url = builder.buildUploadUrl('/upload/{version}/files');

        expect(url.path, equals('/upload/v1beta/files'));
        expect(
          url.toString(),
          equals(
            'https://generativelanguage.googleapis.com/upload/v1beta/files',
          ),
        );
      },
    );

    test('prefixes a base URL sub-path', () {
      const builder = RequestBuilder(
        config: GoogleAIConfig(baseUrl: 'https://proxy.example.com/gemini'),
      );

      final url = builder.buildUploadUrl('/upload/{version}/files');

      expect(url.path, equals('/gemini/upload/v1beta/files'));
    });

    test('respects the configured API version', () {
      const builder = RequestBuilder(
        config: GoogleAIConfig(apiVersion: ApiVersion.v1),
      );

      final url = builder.buildUploadUrl('/upload/{version}/files');

      expect(url.path, equals('/upload/v1/files'));
    });

    test('merges defaultQueryParams and base-URL params', () {
      const builder = RequestBuilder(
        config: GoogleAIConfig(
          baseUrl: 'https://api.example.com?token=abc',
          defaultQueryParams: {'proxy': 'p'},
        ),
      );

      final url = builder.buildUploadUrl('/upload/{version}/files');

      expect(url.queryParameters['token'], equals('abc'));
      expect(url.queryParameters['proxy'], equals('p'));
    });

    test('per-request params win over same-named defaults', () {
      const builder = RequestBuilder(
        config: GoogleAIConfig(defaultQueryParams: {'key': 'default-key'}),
      );

      final url = builder.buildUploadUrl(
        '/upload/{version}/files',
        queryParams: {'key': 'request-key'},
      );

      expect(url.queryParameters['key'], equals('request-key'));
    });

    test('does not apply Vertex path injection', () {
      const builder = RequestBuilder(
        config: GoogleAIConfig(
          apiMode: ApiMode.vertexAI,
          projectId: 'P',
          location: 'L',
        ),
      );

      final url = builder.buildUploadUrl(
        '/upload/{version}/fileSearchStores/s:uploadToFileSearchStore',
      );

      expect(
        url.path,
        equals('/upload/v1beta/fileSearchStores/s:uploadToFileSearchStore'),
      );
    });
  });
}
