import 'dart:convert';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:googleai_dart/src/client/interceptor_chain.dart';
import 'package:googleai_dart/src/client/request_builder.dart';
import 'package:googleai_dart/src/resources/interactions_resource.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockHttpClient extends Mock implements http.Client {}

http.StreamedResponse _jsonResponse(Object? body, {int status = 200}) {
  final encoded = utf8.encode(jsonEncode(body));
  return http.StreamedResponse(
    Stream.value(encoded),
    status,
    headers: {
      'content-type': 'application/json',
      'content-length': '${encoded.length}',
    },
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(
      http.Request('GET', Uri.parse('https://example.com')),
    );
  });

  late _MockHttpClient mockHttpClient;
  late InteractionsResource resource;
  late List<http.BaseRequest> capturedRequests;

  void stubJsonResponse(Object? body, {int status = 200}) {
    when(() => mockHttpClient.send(any())).thenAnswer((invocation) async {
      capturedRequests.add(
        invocation.positionalArguments.first as http.BaseRequest,
      );
      return _jsonResponse(body, status: status);
    });
  }

  setUp(() {
    mockHttpClient = _MockHttpClient();
    capturedRequests = <http.BaseRequest>[];

    const config = GoogleAIConfig(
      baseUrl: 'https://generativelanguage.googleapis.com',
      authProvider: ApiKeyProvider('test-key'),
    );
    resource = InteractionsResource(
      config: config,
      httpClient: mockHttpClient,
      interceptorChain: InterceptorChain(
        interceptors: const [],
        httpClient: mockHttpClient,
      ),
      requestBuilder: const RequestBuilder(config: config),
    );
  });

  group('InteractionsResource Api-Revision header', () {
    test('create() opts into the new schema via Api-Revision', () async {
      stubJsonResponse({
        'id': 'i_1',
        'status': 'completed',
        'steps': <dynamic>[],
      });

      await resource.create(
        model: 'gemini-3.5-flash',
        input: const InteractionInput.text('hi'),
      );

      final req = capturedRequests.single;
      expect(req.headers['Api-Revision'], '2026-05-20');
    });

    test('get() also sends the Api-Revision header', () async {
      stubJsonResponse({
        'id': 'i_1',
        'status': 'completed',
        'steps': <dynamic>[],
      });

      await resource.get('i_1');

      expect(capturedRequests.single.headers['Api-Revision'], '2026-05-20');
    });
  });

  group('InteractionsResource responseFormat wiring', () {
    test('create() serializes response_format into the body', () async {
      stubJsonResponse({
        'id': 'i_1',
        'status': 'completed',
        'steps': <dynamic>[],
      });

      await resource.create(
        model: 'gemini-3.5-flash',
        input: const InteractionInput.text('hi'),
        responseFormat: const InteractionResponseFormatConfig.single(
          InteractionTextResponseFormat(
            mimeType: InteractionTextResponseFormatMimeType.applicationJson,
            schema: {'type': 'object'},
          ),
        ),
      );

      final req = capturedRequests.single as http.Request;
      final body = jsonDecode(req.body) as Map<String, dynamic>;
      final rf = body['response_format'] as Map<String, dynamic>;
      expect(rf['type'], 'text');
      expect(rf['mime_type'], 'application/json');
      expect(rf['schema'], {'type': 'object'});
    });
  });

  group('GoogleAIClient Interactions routing', () {
    const interaction = {
      'id': 'int_1',
      'status': 'completed',
      'steps': <dynamic>[],
    };
    const sse =
        'data: {"event_type":"interaction.completed", '
        '"event_id":"after_1","interaction":{"id":"int_1", '
        '"status":"completed","steps":[]}}\n\n';
    late List<http.Request> requests;

    GoogleAIClient makeClient(GoogleAIConfig config) {
      final transport = MockClient((request) async {
        requests.add(request);
        if (request.method == 'DELETE') return http.Response('', 204);
        if (request.headers['accept'] == 'text/event-stream') {
          return http.Response(
            sse,
            200,
            headers: {'content-type': 'text/event-stream'},
          );
        }
        final body = request.url.path.endsWith(':generateContent')
            ? {'candidates': <dynamic>[]}
            : interaction;
        return http.Response(
          jsonEncode(body),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final client = GoogleAIClient(config: config, httpClient: transport);
      addTearDown(transport.close);
      addTearDown(client.close);
      return client;
    }

    setUp(() => requests = []);

    test(
      'stable Interactions can share a client with beta generateContent',
      () async {
        final client = makeClient(
          const GoogleAIConfig.googleAI(
            authProvider: ApiKeyProvider(
              'test-key',
              placement: AuthPlacement.header,
            ),
            interactionsApiVersion: ApiVersion.v1,
          ),
        );

        final response = await client.interactions.create(
          model: 'gemini-4-hydrogen',
          input: const InteractionInput.text('Say hello.'),
          previousInteractionId: 'int_0',
          store: true,
          background: false,
          serviceTier: ServiceTier.flex,
          safetySettings: const [
            InteractionSafetySetting(
              type: InteractionHarmCategory.harassment,
              threshold: InteractionHarmBlockThreshold.blockOnlyHigh,
            ),
          ],
          responseFormat: const InteractionResponseFormatConfig.single(
            InteractionTextResponseFormat(),
          ),
        );
        await client.interactions.get('int_1', includeInput: false);
        await client.interactions.cancel('int_background');
        await client.interactions.delete('int_1');
        await client.models.generateContent(
          model: 'gemini-4-hydrogen',
          request: const GenerateContentRequest(
            contents: [
              Content(parts: [TextPart('Say hello.')], role: 'user'),
            ],
          ),
        );

        expect(response.id, 'int_1');
        expect(
          requests.map((request) => '${request.method} ${request.url.path}'),
          [
            'POST /v1/interactions',
            'GET /v1/interactions/int_1',
            'POST /v1/interactions/int_background/cancel',
            'DELETE /v1/interactions/int_1',
            'POST /v1beta/models/gemini-4-hydrogen:generateContent',
          ],
        );
        for (final request in requests) {
          expect(request.headers['x-goog-api-key'], 'test-key');
          expect(request.headers['api-revision'], isNull);
        }
        expect(requests[1].url.queryParameters, {'include_input': 'false'});
        expect(jsonDecode(requests.first.body), {
          'model': 'gemini-4-hydrogen',
          'input': 'Say hello.',
          'previous_interaction_id': 'int_0',
          'store': true,
          'background': false,
          'service_tier': 'flex',
          'safety_settings': [
            {'type': 'harassment', 'threshold': 'block_only_high'},
          ],
          'response_format': {'type': 'text'},
        });
      },
    );

    test(
      'stable stateless interactions send an explicit false store flag',
      () async {
        final client = makeClient(
          const GoogleAIConfig(interactionsApiVersion: ApiVersion.v1),
        );

        await client.interactions.create(
          model: 'gemini-4-hydrogen',
          input: const InteractionInput.text('Say hello.'),
          store: false,
        );

        expect(jsonDecode(requests.single.body), {
          'model': 'gemini-4-hydrogen',
          'input': 'Say hello.',
          'store': false,
        });
      },
    );

    test(
      'default and explicit beta retain both legacy response options',
      () async {
        for (final config in [
          const GoogleAIConfig(),
          const GoogleAIConfig(
            apiVersion: ApiVersion.v1,
            interactionsApiVersion: ApiVersion.v1beta,
            defaultHeaders: {'aPi-ReViSiOn': 'test-revision'},
          ),
        ]) {
          final client = makeClient(config);
          await client.interactions.create(
            model: 'test-model',
            responseModalities: const [InteractionResponseModality.text],
            responseMimeType: 'text/plain',
          );
        }

        for (final request in requests) {
          expect(request.url.path, '/v1beta/interactions');
          expect(request.headers['api-revision'], '2026-05-20');
          expect(jsonDecode(request.body), {
            'model': 'test-model',
            'response_modalities': ['text'],
            'response_mime_type': 'text/plain',
          });
        }
      },
    );

    test(
      'a compatible gateway can still receive legacy options on v1',
      () async {
        final client = makeClient(
          const GoogleAIConfig(
            baseUrl: 'https://example.test/proxy/',
            apiVersion: ApiVersion.v1,
          ),
        );

        await client.interactions.create(
          model: 'test',
          responseMimeType: 'text/plain',
        );

        expect(requests.single.url.path, '/proxy/v1/interactions');
        expect(jsonDecode(requests.single.body), {
          'model': 'test',
          'response_mime_type': 'text/plain',
        });
      },
    );

    test('model SSE selects the stable path and supports GET replay', () async {
      final client = makeClient(
        const GoogleAIConfig(
          interactionsApiVersion: ApiVersion.v1,
          authProvider: ApiKeyProvider(
            'test-key',
            placement: AuthPlacement.header,
          ),
          defaultHeaders: {'aCcEpT': 'application/json'},
        ),
      );

      final first = await client.interactions
          .createStream(
            model: 'gemini-4-hydrogen',
            input: const InteractionInput.text('Say hello.'),
            store: true,
          )
          .single;
      final replayed = await client.interactions
          .resumeStream('int_1', lastEventId: 'cursor/1', includeInput: true)
          .single;

      expect(first.eventId, 'after_1');
      expect(replayed, isA<InteractionCompletedEvent>());
      expect(requests.first.url.path, '/v1/interactions');
      expect(requests.first.method, 'POST');
      expect(requests.first.url.queryParameters, isEmpty);
      expect(jsonDecode(requests.first.body), {
        'model': 'gemini-4-hydrogen',
        'input': 'Say hello.',
        'store': true,
        'stream': true,
      });
      expect(requests.last.url.path, '/v1/interactions/int_1');
      expect(requests.last.method, 'GET');
      expect(requests.last.url.queryParameters, {
        'stream': 'true',
        'last_event_id': 'cursor/1',
        'include_input': 'true',
      });
      for (final request in requests) {
        expect(request.headers['accept'], 'text/event-stream');
        expect(request.headers['api-revision'], isNull);
        expect(request.headers['x-goog-api-key'], 'test-key');
      }
    });

    test(
      'managed-agent unary and streaming calls share the beta body',
      () async {
        final client = makeClient(const GoogleAIConfig());
        const agent = 'antigravity-preview-09-2026';
        const input = InteractionInput.text('Summarize this message.');
        const webhook = WebhookConfig(uris: ['https://example.test/webhook']);
        await client.interactions.createWithAgent(
          agent: agent,
          input: input,
          background: true,
          store: true,
          previousInteractionId: 'int_0',
          webhookConfig: webhook,
        );
        final event = await client.interactions
            .createWithAgentStream(
              agent: agent,
              input: input,
              background: true,
              store: true,
              previousInteractionId: 'int_0',
              webhookConfig: webhook,
            )
            .single;

        expect(event, isA<InteractionCompletedEvent>());
        final unary = jsonDecode(requests.first.body) as Map<String, dynamic>;
        expect(unary, {
          'agent': agent,
          'input': 'Summarize this message.',
          'previous_interaction_id': 'int_0',
          'background': true,
          'store': true,
          'webhook_config': {
            'uris': ['https://example.test/webhook'],
          },
        });
        expect(jsonDecode(requests.last.body), {...unary, 'stream': true});
        expect(requests.last.url.path, '/v1beta/interactions');
        expect(requests.last.url.queryParameters, {'alt': 'sse'});
        expect(requests.last.headers['accept'], 'text/event-stream');
        expect(requests.last.headers['api-revision'], '2026-05-20');
      },
    );

    test(
      'clearing the override restores client-wide version inheritance',
      () async {
        const config = GoogleAIConfig(interactionsApiVersion: ApiVersion.v1);
        expect(config.copyWith().interactionsApiVersion, ApiVersion.v1);
        final client = makeClient(
          config.copyWith(interactionsApiVersion: null),
        );
        await client.interactions.get('int_1');

        expect(requests.single.url.path, '/v1beta/interactions/int_1');
        expect(requests.single.url.queryParameters, isEmpty);
      },
    );
  });
}
