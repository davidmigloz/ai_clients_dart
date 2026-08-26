import 'dart:async';
import 'dart:convert';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:googleai_dart/src/client/interceptor_chain.dart';
import 'package:googleai_dart/src/client/request_builder.dart';
import 'package:googleai_dart/src/resources/models_resource.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockHttpClient extends Mock implements http.Client {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      http.Request('POST', Uri.parse('https://example.com')),
    );
  });

  test('Vertex embeddings map EmbedContentConfig to predict fields', () async {
    final mockHttpClient = _MockHttpClient();
    late http.Request capturedRequest;
    when(() => mockHttpClient.send(any())).thenAnswer((invocation) async {
      capturedRequest = invocation.positionalArguments.single as http.Request;
      final body = utf8.encode(
        jsonEncode({
          'predictions': [
            {
              'embeddings': {
                'values': [0.1, 0.2],
              },
            },
          ],
        }),
      );
      return http.StreamedResponse(
        Stream.value(body),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final config = GoogleAIConfig.vertexAI(
      projectId: 'test-project',
      authProvider: const ApiKeyProvider('test-key'),
    );
    final resource = ModelsResource(
      config: config,
      httpClient: mockHttpClient,
      interceptorChain: InterceptorChain(
        interceptors: const [],
        httpClient: mockHttpClient,
      ),
      requestBuilder: RequestBuilder(config: config),
    );

    final response = await resource.embedContent(
      model: 'text-embedding-005',
      request: const EmbedContentRequest(
        content: Content(parts: [TextPart('document')]),
        embedContentConfig: EmbedContentConfig(
          taskType: TaskType.retrievalDocument,
          title: 'Document title',
          outputDimensionality: 64,
          autoTruncate: true,
          documentOcr: true,
          audioTrackExtraction: false,
        ),
      ),
    );

    expect(response.embedding.values, [0.1, 0.2]);
    expect(jsonDecode(capturedRequest.body), {
      'instances': [
        {
          'content': 'document',
          'task_type': 'RETRIEVAL_DOCUMENT',
          'title': 'Document title',
        },
      ],
      'parameters': {
        'outputDimensionality': 64,
        'autoTruncate': true,
        'documentOcr': true,
        'audioTrackExtraction': false,
      },
    });
  });
}
