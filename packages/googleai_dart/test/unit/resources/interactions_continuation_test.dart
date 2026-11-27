import 'dart:async';
import 'dart:convert';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

const _model = 'gemini-4-neon';
const _input = TextInput('Explain induction.');
const _config = InteractionGenerationConfig(maxOutputTokens: 131072);

Map<String, dynamic> _interaction(String id, String status, {String? token}) =>
    {
      'id': id,
      'status': status,
      'steps': <Object>[],
      'continuation_token': ?token,
    };

http.Response _sse(List<Map<String, dynamic>> events) => http.Response(
  events.map((event) => 'data: ${jsonEncode(event)}\n\n').join(),
  200,
  headers: {'content-type': 'text/event-stream'},
);

void main() {
  test(
    'resumes stored long decode using the hop that issued the token',
    () async {
      final requests = <http.Request>[];
      final client = GoogleAIClient(
        config: const GoogleAIConfig(interactionsApiVersion: ApiVersion.v1),
        httpClient: MockClient((request) async {
          requests.add(request);
          final body = requests.length == 1
              ? _interaction('hop-1', 'requires_continuation', token: 'token-1')
              : _interaction('hop-2', 'completed');
          return http.Response(jsonEncode(body), 200);
        }),
      );
      addTearDown(client.close);

      final first = await client.interactions.create(
        model: _model,
        input: _input,
        generationConfig: _config,
        previousInteractionId: 'older-conversation',
      );
      expect(requests, hasLength(1));
      expect(first.status, InteractionStatus.requiresContinuation);
      expect(first.continuationToken, 'token-1');

      final second = await client.interactions.create(
        model: _model,
        generationConfig: _config,
        previousInteractionId: first.id,
        continuationToken: first.continuationToken,
      );
      expect(second.id, 'hop-2');
      expect(second.status, InteractionStatus.completed);
      expect(second.continuationToken, isNull);
      expect(requests, hasLength(2));
      for (final request in requests) {
        expect(request.method, 'POST');
        expect(request.url.path, '/v1/interactions');
      }
      expect(jsonDecode(requests.first.body), {
        'model': _model,
        'input': 'Explain induction.',
        'generation_config': {'max_output_tokens': 131072},
        'previous_interaction_id': 'older-conversation',
      });
      expect(jsonDecode(requests.last.body), {
        'model': _model,
        'generation_config': {'max_output_tokens': 131072},
        'previous_interaction_id': 'hop-1',
        'continuation_token': 'token-1',
      });

      expect(first.toJson()['continuation_token'], 'token-1');
      expect(first.copyWith(id: 'another-id').continuationToken, 'token-1');
      expect(
        first.copyWith(continuationToken: null).toJson(),
        isNot(contains('continuation_token')),
      );
    },
  );

  test(
    'exposes stateless checkpoints and sends the original prompt on POST',
    () async {
      const checkpointJson = {
        'event_type': 'interaction.status_update',
        'interaction_id': 'stream-hop',
        'event_id': 'replay-only-id',
        'status': 'in_progress',
        'continuation_token': 'decode-token',
        'usage': {'initial_input_tokens': 16, 'total_tokens': 32768},
      };
      final requests = <http.Request>[];
      final client = GoogleAIClient(
        config: const GoogleAIConfig(interactionsApiVersion: ApiVersion.v1),
        httpClient: MockClient((request) async {
          requests.add(request);
          return _sse([
            checkpointJson,
            {
              'event_type': 'interaction.completed',
              'interaction': _interaction(
                'stream-hop',
                'requires_continuation',
                token: 'next-token',
              ),
            },
          ]);
        }),
      );
      addTearDown(client.close);

      final events = await client.interactions
          .createStream(
            model: _model,
            input: _input,
            generationConfig: _config,
            store: false,
            continuationToken: 'caller-token',
          )
          .toList();

      final request = requests.single;
      expect(request.method, 'POST');
      expect(request.url.path, '/v1/interactions');
      expect(request.url.queryParameters, isEmpty);
      expect(request.headers['Accept'], 'text/event-stream');
      expect(jsonDecode(request.body), {
        'model': _model,
        'input': 'Explain induction.',
        'generation_config': {'max_output_tokens': 131072},
        'continuation_token': 'caller-token',
        'store': false,
        'stream': true,
      });
      expect(events, hasLength(2));
      final checkpoint = events.first as InteractionStatusUpdateEvent;
      expect(checkpoint.eventId, 'replay-only-id');
      expect(checkpoint.interactionId, 'stream-hop');
      expect(checkpoint.continuationToken, 'decode-token');
      expect(checkpoint.usage?.initialInputTokens, 16);
      expect(checkpoint.usage?.totalTokens, 32768);
      expect(checkpoint.toJson(), checkpointJson);
      final finished = events.last as InteractionCompletedEvent;
      expect(
        finished.interaction.status,
        InteractionStatus.requiresContinuation,
      );
      expect(finished.interaction.continuationToken, 'next-token');
    },
  );

  test('replays an existing SSE interaction with an event ID on GET', () async {
    final client = GoogleAIClient(
      config: const GoogleAIConfig(interactionsApiVersion: ApiVersion.v1),
      httpClient: MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/v1/interactions/hop-1');
        expect(request.url.queryParameters, {
          'stream': 'true',
          'last_event_id': 'event-for-replay',
        });
        expect(request.body, isEmpty);
        return _sse([
          {
            'event_type': 'interaction.status_update',
            'status': 'requires_continuation',
            'continuation_token': 'decode-checkpoint',
          },
        ]);
      }),
    );
    addTearDown(client.close);

    final event =
        await client.interactions
                .resumeStream('hop-1', lastEventId: 'event-for-replay')
                .single
            as InteractionStatusUpdateEvent;
    expect(event.status, InteractionStatus.requiresContinuation);
    expect(event.continuationToken, 'decode-checkpoint');
  });

  test(
    'forwards an explicit continuation token on both beta agent calls',
    () async {
      final requests = <http.Request>[];
      final client = GoogleAIClient(
        httpClient: MockClient((request) async {
          requests.add(request);
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['continuation_token'], 'manual-agent-token');
          expect(body['agent'], 'managed-agent');
          expect(request.url.path, '/v1beta/interactions');
          return body['stream'] == true
              ? _sse([
                  {
                    'event_type': 'interaction.completed',
                    'interaction': _interaction('agent-stream', 'completed'),
                  },
                ])
              : http.Response(
                  jsonEncode(_interaction('agent-unary', 'completed')),
                  200,
                );
        }),
      );
      addTearDown(client.close);

      await client.interactions.createWithAgent(
        agent: 'managed-agent',
        input: _input,
        continuationToken: 'manual-agent-token',
      );
      await client.interactions
          .createWithAgentStream(
            agent: 'managed-agent',
            input: _input,
            continuationToken: 'manual-agent-token',
          )
          .drain<void>();
      expect(requests, hasLength(2));
    },
  );

  test('aborts after a checkpoint without opening another request', () async {
    final body = StreamController<List<int>>();
    addTearDown(body.close);
    final requests = <http.BaseRequest>[];
    final client = GoogleAIClient(
      config: const GoogleAIConfig(interactionsApiVersion: ApiVersion.v1),
      httpClient: MockClient.streaming((request, _) async {
        requests.add(request);
        return http.StreamedResponse(body.stream, 200);
      }),
    );
    addTearDown(client.close);
    final abort = Completer<void>();
    final events = StreamIterator(
      client.interactions.createStream(
        model: _model,
        input: _input,
        abortTrigger: abort.future,
      ),
    );
    addTearDown(events.cancel);
    body.add(
      utf8.encode(
        _sse([
          {
            'event_type': 'interaction.status_update',
            'interaction_id': 'hop-1',
            'status': 'in_progress',
            'continuation_token': 'checkpoint',
          },
        ]).body,
      ),
    );
    expect(await events.moveNext(), isTrue);
    final checkpoint = events.current as InteractionStatusUpdateEvent;
    expect(checkpoint.continuationToken, 'checkpoint');

    final aborted = expectLater(
      events.moveNext(),
      throwsA(isA<AbortedException>()),
    );
    abort.complete();
    await aborted;
    expect(requests, hasLength(1));
  });

  test(
    'redacts echoed continuation tokens before clipping error metadata',
    () async {
      final token = 'opaque-token-${'a' * 300}';
      final client = GoogleAIClient(
        config: const GoogleAIConfig(interactionsApiVersion: ApiVersion.v1),
        httpClient: MockClient((_) async {
          return http.Response(
            jsonEncode({
              'error': {'message': 'Invalid continuation'},
              'padding': 'b' * 104,
              'continuation_token': token,
            }),
            400,
          );
        }),
      );
      addTearDown(client.close);

      await expectLater(
        client.interactions.create(model: _model, continuationToken: token),
        throwsA(
          isA<ApiException>().having(
            (error) => error.responseMetadata?.bodyExcerpt,
            'redacted excerpt',
            allOf(contains('***REDACTED***'), isNot(contains('opaque-token'))),
          ),
        ),
      );
    },
  );

  test('round trips continuation fields on public request models', () {
    const modelJson = {
      'model': _model,
      'continuation_token': 'token',
      'store': false,
    };
    const agentJson = {
      'agent': 'managed-agent',
      'input': 'Explain induction.',
      'continuation_token': 'agent-token',
      'store': false,
    };
    final model = CreateInteractionParams.fromJson(modelJson);
    final agent = CreateInteractionParams.fromJson(agentJson);
    expect(model, isA<CreateModelInteractionParams>());
    expect(agent, isA<CreateAgentInteractionParams>());
    expect(model.toJson(), modelJson);
    expect(agent.toJson(), agentJson);
  });
}
