import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ContentProvenanceChecksResource', () {
    test(
      'create sends a multipart POST to /content_provenance_checks',
      () async {
        final requestCompleter = Completer<http.BaseRequest>();

        final mockClient = MockClient((request) async {
          requestCompleter.complete(request);
          return http.Response(
            '{"object":"content_provenance_check","created_at":1234567890,'
            '"results":[]}',
            200,
          );
        });

        final client = OpenAIClient(
          config: const OpenAIConfig(
            authProvider: ApiKeyProvider('sk-test-key'),
          ),
          httpClient: mockClient,
        );

        await client.contentProvenanceChecks.create(
          bytes: [1, 2, 3, 4],
          filename: 'image.png',
        );

        final request = await requestCompleter.future;
        expect(request.method, equals('POST'));
        expect(request.url.path, endsWith('/content_provenance_checks'));

        client.close();
      },
    );

    test('sends exactly one file part named "file"', () async {
      final requestCompleter = Completer<http.BaseRequest>();

      final mockClient = MockClient((request) async {
        requestCompleter.complete(request);
        return http.Response(
          '{"object":"content_provenance_check","created_at":1,"results":[]}',
          200,
        );
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(authProvider: ApiKeyProvider('sk-test-key')),
        httpClient: mockClient,
      );

      await client.contentProvenanceChecks.create(
        bytes: [1, 2, 3, 4],
        filename: 'image.png',
      );

      final request = await requestCompleter.future as http.Request;
      final requestBody = request.body;

      expect(
        requestBody,
        contains('content-disposition: form-data; name="file"'),
      );
      expect(requestBody, contains('filename="image.png"'));

      client.close();
    });

    test('includes all required headers', () async {
      final requestCompleter = Completer<http.BaseRequest>();

      final mockClient = MockClient((request) async {
        requestCompleter.complete(request);
        return http.Response(
          '{"object":"content_provenance_check","created_at":1,"results":[]}',
          200,
        );
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test-key'),
          organization: 'test-org',
          project: 'test-project',
        ),
        httpClient: mockClient,
      );

      await client.contentProvenanceChecks.create(
        bytes: [1, 2, 3, 4],
        filename: 'image.png',
      );

      final request = await requestCompleter.future;

      expect(request.headers['Authorization'], equals('Bearer sk-test-key'));
      expect(request.headers['OpenAI-Organization'], equals('test-org'));
      expect(request.headers['OpenAI-Project'], equals('test-project'));
      expect(request.headers['X-Request-ID'], isNotNull);
      expect(request.headers['content-type'], contains('multipart/form-data'));

      client.close();
    });

    test('parses results with both c2pa and synthid types', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          '{"object":"content_provenance_check","created_at":1700000000,'
          '"results":['
          '{"type":"c2pa","outcome":"detected","validation_state":"trusted",'
          '"model":"gpt-image-2","issuer":"OpenAI",'
          '"generated_at":"2026-07-30T12:00:00Z"},'
          '{"type":"synthid","outcome":"not_detected","model":null,'
          '"generated_at":null}'
          ']}',
          200,
        );
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(authProvider: ApiKeyProvider('sk-test-key')),
        httpClient: mockClient,
      );

      final check = await client.contentProvenanceChecks.create(
        bytes: [1, 2, 3, 4],
        filename: 'image.png',
      );

      expect(check.object, 'content_provenance_check');
      expect(check.createdAt, 1700000000);
      expect(check.results, hasLength(2));

      final c2pa = check.results[0] as C2PAProvenanceResult;
      expect(c2pa.outcome, ProvenanceDetectionResult.detected);
      expect(c2pa.validationState, C2PAValidationState.trusted);
      expect(c2pa.model, 'gpt-image-2');
      expect(c2pa.issuer, 'OpenAI');

      final synthId = check.results[1] as SynthIDProvenanceResult;
      expect(synthId.outcome, ProvenanceDetectionResult.notDetected);
      expect(synthId.model, isNull);
      expect(synthId.generatedAt, isNull);

      client.close();
    });

    test('4xx error response goes through ErrorInterceptor', () {
      final mockClient = MockClient((request) async {
        return http.Response(
          '{"error":{"message":"Invalid file","type":"invalid_request_error",'
          ' "code":"invalid_file"}}',
          400,
        );
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(authProvider: ApiKeyProvider('sk-test-key')),
        httpClient: mockClient,
      );

      expect(
        () => client.contentProvenanceChecks.create(
          bytes: [1, 2, 3, 4],
          filename: 'image.png',
        ),
        throwsA(isA<BadRequestException>()),
      );

      client.close();
    });
  });
}
