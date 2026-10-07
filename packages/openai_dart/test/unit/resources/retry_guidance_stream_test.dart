import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  final entrypoints = <String, Stream<dynamic> Function(OpenAIClient)>{
    'chat JSON': (client) =>
        client.chat.completions.createStream(_chatRequest()),
    'image generation JSON': (client) => client.images.generateStream(
      const ImageGenerationRequest(model: 'fixture-model', prompt: 'Hello'),
    ),
    'image edit JSON': (client) => client.images.editJsonStream(
      const ImageEditJsonRequest(
        images: [ImageReference.file('file-fixture')],
        prompt: 'Hello',
      ),
    ),
    'image edit multipart': (client) => client.images.editStream(
      ImageEditRequest(
        model: 'fixture-model',
        image: Uint8List.fromList([1, 2, 3]),
        imageFilename: 'fixture.png',
        prompt: 'Hello',
      ),
    ),
  };
  for (final entry in entrypoints.entries) {
    for (final status in [429, 503]) {
      for (final rawBody in [
        'structured',
        'malformed members',
        'not JSON',
        '',
      ]) {
        test(
          '${entry.key} $status exposes pre-stream retry metadata: $rawBody',
          () async {
            final errorJson = {
              'error': {
                'message': rawBody == 'malformed members'
                    ? false
                    : 'Overloaded',
                'type': 'server_error',
                'code': 'overloaded',
                'param': rawBody == 'malformed members' ? <Object>[] : 'model',
              },
            };
            final isJson =
                rawBody == 'structured' || rawBody == 'malformed members';
            final body = isJson ? jsonEncode(errorJson) : rawBody;
            var sends = 0;
            final transport = MockClient.streaming((request, _) async {
              sends++;
              expect(request.method, 'POST');
              expect(request.headers['accept'], 'text/event-stream');
              if (entry.key == 'image edit multipart') {
                expect(request, isA<http.MultipartRequest>());
                expect(
                  (request as http.MultipartRequest).fields['stream'],
                  'true',
                );
              } else {
                expect(request, isA<http.Request>());
                expect(
                  (jsonDecode((request as http.Request).body) as Map)['stream'],
                  isTrue,
                );
              }
              return http.StreamedResponse(
                Stream.value(utf8.encode(body)),
                status,
                headers: {
                  'retry-after-ms': '1.2345',
                  'retry-after': '9',
                  'x-request-id': 'req-stream-guidance',
                },
              );
            });
            final client = _client(transport);
            addTearDown(client.close);
            final error = await _captureError(entry.value(client));
            expect(sends, 1);
            expect(
              error,
              status == 429
                  ? isA<RateLimitException>()
                  : isA<InternalServerException>(),
            );
            expect(error.statusCode, status);
            expect(error.requestId, 'req-stream-guidance');
            expect(error.body, isJson ? errorJson : null);
            expect(error.type, isJson ? 'server_error' : null);
            expect(error.code, isJson ? 'overloaded' : null);
            expect(error.param, rawBody == 'structured' ? 'model' : null);
            final delay = switch (error) {
              RateLimitException() => error.retryAfter,
              InternalServerException() => error.retryAfter,
              _ => null,
            };
            expect(delay, const Duration(microseconds: 1235));
            expect(
              error.message,
              rawBody == 'structured'
                  ? 'Overloaded'
                  : body.isEmpty
                  ? 'HTTP $status error'
                  : body,
            );
          },
        );
      }
    }
  }

  test('inline error after streamed output is exposed without replay', () async {
    var sends = 0;
    final transport = MockClient.streaming((_, _) async {
      sends++;
      return http.StreamedResponse(
        Stream.value(
          utf8.encode(
            'data: {"id":"chatcmpl-fixture","object":"chat.completion.chunk","created":0,"model":"fixture-model","choices":[{"index":0,"delta":{"content":"Hello"},"finish_reason":null,"logprobs":null}]}\n\n'
            'data: {"error":{"message":"Overloaded","type":"server_error","code":"overloaded"}}\n\n',
          ),
        ),
        200,
        headers: {'retry-after-ms': '1'},
      );
    });
    final client = _client(transport);
    addTearDown(client.close);
    final output = <ChatStreamEvent>[];
    await expectLater(
      client.chat.completions.createStream(_chatRequest()).map((event) {
        output.add(event);
        return event;
      }).toList(),
      throwsA(isA<StreamException>()),
    );
    expect(output.single.textDelta, 'Hello');
    expect(sends, 1);
  });

  test(
    'streaming transport failure does not introduce automatic retries',
    () async {
      var sends = 0;
      final client = _client(
        MockClient.streaming((_, _) {
          sends++;
          return Future<http.StreamedResponse>.error(
            http.ClientException('Connection failed'),
          );
        }),
      );
      addTearDown(client.close);
      await expectLater(
        client.chat.completions.createStream(_chatRequest()).toList(),
        throwsA(isA<http.ClientException>()),
      );
      expect(sends, 1);
    },
  );
}

OpenAIClient _client(http.Client transport) => OpenAIClient(
  config: const OpenAIConfig(
    authProvider: ApiKeyProvider('sk-fixture'),
    retryPolicy: RetryPolicy(maxRetries: 5, initialDelay: Duration.zero),
  ),
  httpClient: transport,
);

ChatCompletionCreateRequest _chatRequest() => ChatCompletionCreateRequest(
  model: 'fixture-model',
  messages: [ChatMessage.user('Hello')],
);

Future<ApiException> _captureError(Stream<dynamic> stream) async {
  try {
    await stream.drain<void>();
    fail('Expected an API error');
  } on ApiException catch (error) {
    return error;
  }
}
