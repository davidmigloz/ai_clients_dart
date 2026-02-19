import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Multipart Headers', () {
    test('file upload includes all required headers', () async {
      final requestCompleter = Completer<http.BaseRequest>();

      final mockClient = MockClient((request) async {
        requestCompleter.complete(request);
        return http.Response(
          '{"id":"file-123","object":"file","bytes":100,"created_at":1234567890,'
          '"filename":"test.txt","purpose":"fine-tune","status":"processed"}',
          200,
        );
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test-key'),
          organization: 'test-org',
          project: 'test-project',
          apiVersion: '2024-01-01',
          defaultHeaders: {'X-Custom-Header': 'custom-value'},
        ),
        httpClient: mockClient,
      );

      await client.files.upload(
        bytes: [1, 2, 3, 4],
        filename: 'test.txt',
        purpose: FilePurpose.fineTune,
      );

      final request = await requestCompleter.future;

      // Verify auth header
      expect(request.headers['Authorization'], equals('Bearer sk-test-key'));

      // Verify organization and project headers
      expect(request.headers['OpenAI-Organization'], equals('test-org'));
      expect(request.headers['OpenAI-Project'], equals('test-project'));

      // Verify API version header
      expect(request.headers['OpenAI-Version'], equals('2024-01-01'));

      // Verify X-Request-ID is present
      expect(request.headers['X-Request-ID'], isNotNull);
      expect(request.headers['X-Request-ID'], isNotEmpty);

      // Verify custom default header
      expect(request.headers['X-Custom-Header'], equals('custom-value'));

      // Verify Content-Type contains multipart boundary (set by MultipartRequest)
      expect(request.headers['content-type'], contains('multipart/form-data'));

      client.close();
    });

    test('uploads addPart includes all required headers', () async {
      final requestCompleter = Completer<http.BaseRequest>();

      final mockClient = MockClient((request) async {
        requestCompleter.complete(request);
        return http.Response(
          '{"id":"part-123","object":"upload.part","upload_id":"upload-456",'
          '"created_at":1234567890}',
          200,
        );
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test-key'),
          organization: 'test-org',
          project: 'test-project',
          apiVersion: '2024-01-01',
          defaultHeaders: {'X-Custom-Header': 'custom-value'},
        ),
        httpClient: mockClient,
      );

      await client.uploads.addPart('upload-456', data: [1, 2, 3, 4]);

      final request = await requestCompleter.future;

      // Verify auth header
      expect(request.headers['Authorization'], equals('Bearer sk-test-key'));

      // Verify organization and project headers
      expect(request.headers['OpenAI-Organization'], equals('test-org'));
      expect(request.headers['OpenAI-Project'], equals('test-project'));

      // Verify API version header
      expect(request.headers['OpenAI-Version'], equals('2024-01-01'));

      // Verify X-Request-ID is present
      expect(request.headers['X-Request-ID'], isNotNull);

      // Verify custom default header
      expect(request.headers['X-Custom-Header'], equals('custom-value'));

      client.close();
    });

    test(
      'multipart uses proper URL normalization with Azure-style base URL',
      () async {
        final requestCompleter = Completer<http.BaseRequest>();

        final mockClient = MockClient((request) async {
          requestCompleter.complete(request);
          return http.Response(
            '{"id":"file-123","object":"file","bytes":100,"created_at":1234567890,'
            '"filename":"test.txt","purpose":"fine-tune","status":"processed"}',
            200,
          );
        });

        final client = OpenAIClient(
          config: const OpenAIConfig(
            authProvider: ApiKeyProvider('sk-test-key'),
            baseUrl:
                'https://example.openai.azure.com/openai/deployments/my-deploy?api-version=2024-10-01',
          ),
          httpClient: mockClient,
        );

        await client.files.upload(
          bytes: [1, 2, 3, 4],
          filename: 'test.txt',
          purpose: FilePurpose.fineTune,
        );

        final request = await requestCompleter.future;

        // Verify URL is properly normalized
        expect(request.url.scheme, equals('https'));
        expect(request.url.host, equals('example.openai.azure.com'));
        expect(request.url.path, equals('/openai/deployments/my-deploy/files'));
        // Verify query params are preserved
        expect(
          request.url.queryParameters['api-version'],
          equals('2024-10-01'),
        );

        client.close();
      },
    );

    test('multipart error handling goes through ErrorInterceptor', () {
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
        () => client.files.upload(
          bytes: [1, 2, 3, 4],
          filename: 'test.txt',
          purpose: FilePurpose.fineTune,
        ),
        throwsA(isA<BadRequestException>()),
      );

      client.close();
    });

    test('audio transcription includes all required headers', () async {
      final requestCompleter = Completer<http.BaseRequest>();

      final mockClient = MockClient((request) async {
        requestCompleter.complete(request);
        return http.Response('{"text":"Hello world"}', 200);
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test-key'),
          organization: 'test-org',
          project: 'test-project',
          apiVersion: '2024-01-01',
        ),
        httpClient: mockClient,
      );

      await client.audio.transcriptions.create(
        TranscriptionRequest(
          file: Uint8List.fromList([1, 2, 3, 4]),
          filename: 'audio.mp3',
          model: 'whisper-1',
        ),
      );

      final request = await requestCompleter.future;

      // Verify auth header
      expect(request.headers['Authorization'], equals('Bearer sk-test-key'));

      // Verify organization and project headers
      expect(request.headers['OpenAI-Organization'], equals('test-org'));
      expect(request.headers['OpenAI-Project'], equals('test-project'));

      // Verify API version header
      expect(request.headers['OpenAI-Version'], equals('2024-01-01'));

      // Verify X-Request-ID is present
      expect(request.headers['X-Request-ID'], isNotNull);

      client.close();
    });

    test('image edit includes all required headers', () async {
      final requestCompleter = Completer<http.BaseRequest>();

      final mockClient = MockClient((request) async {
        requestCompleter.complete(request);
        return http.Response(
          '{"created":1234567890,"data":[{"url":"https://example.com/image.png"}]}',
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

      await client.images.edit(
        ImageEditRequest(
          image: Uint8List.fromList([1, 2, 3, 4]),
          imageFilename: 'image.png',
          prompt: 'Add a hat',
        ),
      );

      final request = await requestCompleter.future;

      // Verify auth header
      expect(request.headers['Authorization'], equals('Bearer sk-test-key'));

      // Verify organization and project headers
      expect(request.headers['OpenAI-Organization'], equals('test-org'));
      expect(request.headers['OpenAI-Project'], equals('test-project'));

      // Verify X-Request-ID is present
      expect(request.headers['X-Request-ID'], isNotNull);

      client.close();
    });

    test('image editJson sends application/json payload', () async {
      final requestCompleter = Completer<http.BaseRequest>();

      final mockClient = MockClient((request) async {
        requestCompleter.complete(request);
        return http.Response(
          '{"created":1234567890,"data":[{"b64_json":"abc"}]}',
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

      await client.images.editJson(
        const ImageEditJsonRequest(
          images: [ImageReference.file('file_123')],
          prompt: 'Add a hat',
        ),
      );

      final request = await requestCompleter.future as http.Request;
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      final images = body['images'] as List<dynamic>;
      final firstImage = images.first as Map<String, dynamic>;

      expect(request.method, equals('POST'));
      expect(request.url.path, endsWith('/images/edits'));
      expect(request.headers['Content-Type'], equals('application/json'));
      expect(firstImage['file_id'], equals('file_123'));
      expect(body['prompt'], equals('Add a hat'));
      expect(request.headers['Authorization'], equals('Bearer sk-test-key'));

      client.close();
    });

    test('container file create includes all required headers', () async {
      final requestCompleter = Completer<http.BaseRequest>();

      final mockClient = MockClient((request) async {
        requestCompleter.complete(request);
        return http.Response(
          '{"id":"file-123","object":"container.file","container_id":"container-456",'
          '"path":"/app/data.json","bytes":100,"created_at":1234567890}',
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

      await client.containers.files.create(
        'container-456',
        bytes: [1, 2, 3, 4],
        filename: 'data.json',
      );

      final request = await requestCompleter.future;

      // Verify auth header
      expect(request.headers['Authorization'], equals('Bearer sk-test-key'));

      // Verify organization and project headers
      expect(request.headers['OpenAI-Organization'], equals('test-org'));
      expect(request.headers['OpenAI-Project'], equals('test-project'));

      // Verify X-Request-ID is present
      expect(request.headers['X-Request-ID'], isNotNull);

      client.close();
    });
  });
}
