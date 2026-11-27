import 'dart:convert';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

const _model = 'gemini-3.8-flash';
const _prompt = 'Summarize this request.';
const _input = InteractionInput.text(_prompt);
const Map<String, Object> _interaction = {
  'object': 'interaction',
  'id': 'interaction-1',
  'status': 'in_progress',
  'service_tier': 'deferred',
  'steps': <Object>[],
};

http.Response _jsonResponse(Object? body) => http.Response(
  jsonEncode(body),
  200,
  headers: const {'content-type': 'application/json'},
);

GoogleAIClient _client(
  GoogleAIConfig config,
  Future<http.Response> Function(http.Request) handle,
) {
  final transport = MockClient(handle);
  final client = GoogleAIClient(config: config, httpClient: transport);
  addTearDown(transport.close);
  addTearDown(client.close);
  return client;
}

void main() {
  group('Vertex Interactions routing', () {
    for (final (location, host) in [
      ('global', 'aiplatform.googleapis.com'),
      ('us', 'aiplatform.us.rep.googleapis.com'),
      ('eu', 'aiplatform.eu.rep.googleapis.com'),
      ('us-central1', 'us-central1-aiplatform.googleapis.com'),
    ]) {
      test('uses the configured $location host and project-scoped path', () async {
        final requests = <http.Request>[];
        final client = _client(
          GoogleAIConfig.vertexAI(
            location: location,
            projectId: 'project',
            authProvider: const BearerTokenProvider('test-token'),
          ),
          (request) async {
            requests.add(request);
            if (request.url.path.endsWith(':generateContent')) {
              return _jsonResponse({'candidates': <Object>[]});
            }
            if (request.url.path.endsWith(':predict')) {
              return _jsonResponse({
                'predictions': [
                  {
                    'embeddings': {
                      'values': [0.5],
                    },
                  },
                ],
              });
            }
            return _jsonResponse(_interaction);
          },
        );

        await client.interactions.create(model: _model, input: _input);
        await client.models.generateContent(
          model: _model,
          request: GenerateContentRequest(contents: [Content.text('Hello.')]),
        );
        final embedding = await client.models.embedContent(
          model: 'gemini-embedding-001',
          request: EmbedContentRequest(content: Content.text('Hello.')),
        );

        expect(embedding.embedding.values, [0.5]);
        expect(requests.map((request) => request.url.host), [host, host, host]);
        expect(requests.map((request) => request.url.path), [
          '/v1/projects/project/locations/$location/interactions',
          '/v1/projects/project/locations/$location/publishers/google/models/$_model:generateContent',
          '/v1/projects/project/locations/$location/publishers/google/models/gemini-embedding-001:predict',
        ]);
        for (final request in requests) {
          expect(request.headers['authorization'], 'Bearer test-token');
        }
      });
    }

    test('keeps the documented project scope with a Cloud API key', () async {
      final client = _client(
        GoogleAIConfig.vertexAI(
          projectId: 'project',
          location: 'global',
          authProvider: const ApiKeyProvider(
            'cloud-key',
            placement: AuthPlacement.header,
          ),
        ),
        (request) async {
          expect(
            request.url.toString(),
            'https://aiplatform.googleapis.com/v1/projects/project/locations/global/interactions',
          );
          expect(request.headers['x-goog-api-key'], 'cloud-key');
          return _jsonResponse(_interaction);
        },
      );
      await client.interactions.create(model: _model, input: _input);
    });

    test('uses the pinned SDK route for projectless express mode', () async {
      final client = _client(
        const GoogleAIConfig(
          apiMode: ApiMode.vertexAI,
          baseUrl: 'https://aiplatform.googleapis.com',
          apiVersion: ApiVersion.v1,
          authProvider: ApiKeyProvider(
            'cloud-key',
            placement: AuthPlacement.header,
          ),
        ),
        (request) async {
          expect(
            request.url.toString(),
            'https://aiplatform.googleapis.com/v1/interactions',
          );
          expect(request.headers['x-goog-api-key'], 'cloud-key');
          return _jsonResponse(_interaction);
        },
      );

      await client.interactions.create(model: _model, input: _input);
      await expectLater(client.interactions.list(), throwsUnsupportedError);
    });

    test(
      'selects the Cloud beta version independently of model routes',
      () async {
        final client = _client(
          GoogleAIConfig.vertexAI(
            projectId: 'project',
            location: 'eu',
            interactionsApiVersion: ApiVersion.v1beta1,
            authProvider: const BearerTokenProvider('test-token'),
          ),
          (request) async {
            expect(
              request.url.toString(),
              'https://aiplatform.eu.rep.googleapis.com/v1beta1/projects/project/locations/eu/interactions',
            );
            expect(request.headers['authorization'], 'Bearer test-token');
            expect(request.headers['api-revision'], isNull);
            return _jsonResponse(_interaction);
          },
        );

        expect(client.config.apiVersion, ApiVersion.v1);
        await client.interactions.create(model: _model, input: _input);
      },
    );

    test(
      'lists stored interaction metadata and forwards the page token',
      () async {
        final requests = <http.Request>[];
        final client = _client(
          GoogleAIConfig.vertexAI(
            projectId: 'project',
            location: 'global',
            authProvider: const BearerTokenProvider('test-token'),
          ),
          (request) async {
            requests.add(request);
            return _jsonResponse({
              'interaction_metadatas': [
                {'id': 'interaction-${requests.length}'},
              ],
              if (requests.length == 1) 'next_page_token': 'next/+',
            });
          },
        );

        final first = await client.interactions.list(pageSize: 20);
        final second = await client.interactions.list(
          pageSize: 20,
          pageToken: first.nextPageToken,
        );

        expect(requests.first.method, 'GET');
        expect(
          requests.first.url.path,
          '/v1/projects/project/locations/global/interactions',
        );
        expect(requests.first.url.queryParameters, {'page_size': '20'});
        expect(requests.last.url.queryParameters, {
          'page_size': '20',
          'page_token': 'next/+',
        });
        expect(first.interactionMetadatas?.single.id, 'interaction-1');
        expect(second.toJson(), {
          'interaction_metadatas': [
            {'id': 'interaction-2'},
          ],
        });
      },
    );

    test(
      'rejects listing on the Gemini Developer API before sending',
      () async {
        final client = _client(
          const GoogleAIConfig(),
          (_) async => throw StateError('Unexpected HTTP request'),
        );

        await expectLater(client.interactions.list(), throwsUnsupportedError);
      },
    );
  });

  group('Deferred Vertex Interactions', () {
    test(
      'creates, polls, streams and cancels a global deferred interaction',
      () async {
        const path = '/v1/projects/project/locations/global/interactions';
        final requests = <http.Request>[];
        final client = _client(
          GoogleAIConfig.vertexAI(
            projectId: 'project',
            location: 'global',
            authProvider: const BearerTokenProvider('test-token'),
          ),
          (request) async {
            requests.add(request);
            if (request.headers['accept'] == 'text/event-stream') {
              final result = jsonEncode({
                'event_type': 'interaction.completed',
                'event_id': 'after-1',
                'interaction': {..._interaction, 'status': 'completed'},
              });
              return http.Response('data: $result\n\n', 200);
            }
            return _jsonResponse({
              ..._interaction,
              if (request.url.path == path && request.method == 'POST')
                'status': 'queued',
              if (request.url.path.endsWith('/cancel')) 'status': 'cancelled',
            });
          },
        );

        final created = await client.interactions.create(
          model: _model,
          input: _input,
          serviceTier: ServiceTier.deferred,
          background: true,
          store: true,
        );
        final polled = await client.interactions.get(created.id);
        final event = await client.interactions
            .resumeStream(created.id, lastEventId: 'before-1')
            .single;
        final cancelled = await client.interactions.cancel(
          'another-running-interaction',
        );

        expect(created.serviceTier, ServiceTier.deferred);
        expect(created.status, InteractionStatus.queued);
        expect(created.toJson()['status'], 'queued');
        expect(polled.status, InteractionStatus.inProgress);
        expect(event, isA<InteractionCompletedEvent>());
        expect(cancelled.status, InteractionStatus.cancelled);
        expect(requests.map((req) => '${req.method} ${req.url.path}'), [
          'POST $path',
          'GET $path/${created.id}',
          'GET $path/${created.id}',
          'POST $path/another-running-interaction/cancel',
        ]);
        expect(jsonDecode(requests.first.body), {
          'model': _model,
          'input': _prompt,
          'service_tier': 'deferred',
          'background': true,
          'store': true,
        });
        expect(requests[2].url.queryParameters, {
          'stream': 'true',
          'last_event_id': 'before-1',
        });
        expect(requests[2].headers['authorization'], 'Bearer test-token');
      },
    );

    test(
      'rejects streaming creation and managed-agent requests before sending',
      () async {
        final client = _client(
          GoogleAIConfig.vertexAI(
            projectId: 'project',
            location: 'global',
            authProvider: const BearerTokenProvider('test-token'),
          ),
          (_) async => throw StateError('Unexpected HTTP request'),
        );

        await expectLater(
          client.interactions
              .createStream(
                model: _model,
                input: _input,
                serviceTier: ServiceTier.deferred,
                background: true,
                store: true,
              )
              .toList(),
          throwsArgumentError,
        );
        await expectLater(
          client.interactions.createWithAgent(
            agent: 'deep-research-preview-04-2026',
            input: _input,
            serviceTier: ServiceTier.deferred,
            background: true,
            store: true,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      'rejects missing storage and unsupported location before sending',
      () async {
        for (final (location, store) in [('global', false), ('us', true)]) {
          final client = _client(
            GoogleAIConfig.vertexAI(
              projectId: 'project',
              location: location,
              authProvider: const BearerTokenProvider('test-token'),
            ),
            (_) async => throw StateError('Unexpected HTTP request'),
          );

          await expectLater(
            client.interactions.create(
              model: _model,
              input: _input,
              serviceTier: ServiceTier.deferred,
              background: true,
              store: store,
            ),
            throwsArgumentError,
          );
        }
      },
    );
  });
}
