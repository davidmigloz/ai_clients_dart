import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

const _request = CreateResponseRequest(
  model: 'fixture-model',
  input: ResponseInput.text('fixture input'),
  background: true,
  promptCacheOptions: ResponsePromptCacheOptionsParam(
    ttl: ResponsePromptCacheTtl.hours12,
  ),
);
const _options = BackgroundOptions(
  completionWindow: BackgroundCompletionWindow.twoHours,
  continuationId: 'application-group',
);

void main() {
  test('background options round-trip and clear independently of history', () {
    final request = _request.copyWith(
      backgroundOptions: _options,
      previousResponseId: 'resp_parent',
    );
    final json = request.toJson();
    expect(json['previous_response_id'], 'resp_parent');
    expect(json['background_options'], {
      'completion_window': '2h',
      'continuation_id': 'application-group',
    });
    expect(CreateResponseRequest.fromJson(json), request);
    expect(CreateResponseRequest.fromJson(json).hashCode, request.hashCode);
    expect(
      request.copyWith(backgroundOptions: null).toJson(),
      isNot(contains('background_options')),
    );
    expect(_options.copyWith(continuationId: null).toJson(), {
      'completion_window': '2h',
    });
    expect(_options.toString(), isNot(contains('application-group')));
    for (final malformed in [
      null,
      {'completion_window': null},
      {'completion_window': '1h'},
      {'continuation_id': null},
    ]) {
      expect(
        () => CreateResponseRequest.fromJson({
          ...json,
          'background_options': malformed,
        }),
        throwsFormatException,
      );
    }
  });

  for (final beta in [false, true]) {
    test(
      'create, retrieve and cancel keep background lifecycle (beta=$beta)',
      () async {
        final calls = <(String, String)>[];
        final client = _client((request) async {
          calls.add((request.method, request.url.path));
          expect(request.url.queryParameters['beta'], beta ? 'true' : null);
          if (calls.length == 1) {
            expect(jsonDecode(request.body), {
              ..._request.toJson(),
              'background_options': _options.toJson(),
              'service_tier': 'default',
              'store': false,
            });
          }
          return http.Response(
            jsonEncode({
              ..._response,
              'background': true,
              'status': calls.length == 3 ? 'cancelled' : 'queued',
            }),
            200,
          );
        });
        addTearDown(client.close);

        final created = await client.responses.create(
          _request.copyWith(
            backgroundOptions: _options,
            serviceTier: ServiceTier.defaultTier,
            store: false,
          ),
          beta: beta,
        );
        expect(created.background, true);
        expect(created.status, ResponseStatus.queued);
        expect(created.toJson(), isNot(contains('background_options')));
        expect(
          await client.responses.retrieve(created.id, beta: beta),
          created,
        );
        expect(
          (await client.responses.cancel(created.id, beta: beta)).status,
          ResponseStatus.cancelled,
        );
        expect(calls, [
          ('POST', '/v1/responses'),
          ('GET', '/v1/responses/resp_fixture'),
          ('POST', '/v1/responses/resp_fixture/cancel'),
        ]);
      },
    );

    test(
      'SSE preserves transformations and cache accounting (beta=$beta)',
      () async {
        final client = _client((request) async {
          expect(jsonDecode(request.body), {
            ..._request.toJson(),
            'stream': true,
            'background_options': {'completion_window': 'soonest'},
          });
          return http.Response(
            'data: ${jsonEncode(_completedEvent)}\n\n',
            200,
            headers: {'content-type': 'text/event-stream'},
          );
        });
        addTearDown(client.close);
        final completed = await client.responses
            .createStream(
              _request.copyWith(
                backgroundOptions: const BackgroundOptions(
                  completionWindow: BackgroundCompletionWindow.soonest,
                ),
              ),
              beta: beta,
            )
            .where((event) => event is ResponseCompletedEvent)
            .cast<ResponseCompletedEvent>()
            .single;
        _expectMetadata(completed.response);
      },
    );
  }

  test('invalid discounted windows fail without sending HTTP', () async {
    final client = _client(
      (_) async => throw StateError('unexpected network call'),
    );
    addTearDown(client.close);
    final request = _request.copyWith(backgroundOptions: _options);
    await expectLater(
      client.responses.create(request.copyWith(background: false)),
      throwsArgumentError,
    );
    await expectLater(
      client.responses.create(request.copyWith(stream: true)),
      throwsArgumentError,
    );
    expect(() => client.responses.createStream(request), throwsArgumentError);
    expect(
      () => client.responses.createStreamWithAccumulator(request),
      throwsArgumentError,
    );
  });

  test(
    'validation checks the serialized request of existing subclasses',
    () async {
      final client = _client(
        (_) async => throw StateError('unexpected network call'),
      );
      addTearDown(client.close);
      const request = _CustomBackgroundRequest();
      await expectLater(client.responses.create(request), throwsArgumentError);
      expect(() => client.responses.createStream(request), throwsArgumentError);
      expect(
        () => const ResponsesCreateEvent(request: request).toJson(),
        throwsFormatException,
      );
    },
  );

  test('WebSocket rejects HTTP-only options and decodes response metadata', () {
    final fromHttp = _request.copyWith(
      background: null,
      backgroundOptions: _options,
    );
    expect(
      () => ResponsesCreateEvent(request: fromHttp).toJson(),
      throwsFormatException,
    );
    expect(
      () => ResponsesCreateEvent.fromJson(
        fromHttp.toJson()..['type'] = 'response.create',
      ),
      throwsFormatException,
    );
    final event =
        ResponsesServerEvent.fromJson(const {
              ..._completedEvent,
              'stream_id': 'lane',
            })
            as ResponsesStreamEvent;
    expect(event.streamId, 'lane');
    _expectMetadata((event.event as ResponseCompletedEvent).response);
  });

  test('missing and empty response reports round-trip distinctly', () {
    final older = Response.fromJson(
      Map<String, dynamic>.of(_response)..remove('input_transformations'),
    );
    expect(older.inputTransformations, isNull);
    expect(older.toJson(), isNot(contains('input_transformations')));
    final empty = Response.fromJson(
      Map<String, dynamic>.of(_response)
        ..['input_transformations'] = const <Object>[],
    );
    expect(empty.inputTransformations, isEmpty);
    expect(empty.toJson()['input_transformations'], isEmpty);
    expect(empty, isNot(older));
    expect(
      InputTokensDetails.fromJson(const {
        'cached_tokens': 2,
      }).cacheWriteTokensDetails,
      isNull,
    );
  });
}

class _CustomBackgroundRequest extends CreateResponseRequest {
  const _CustomBackgroundRequest()
    : super(
        model: 'fixture-model',
        input: const ResponseInput.text('fixture input'),
      );

  @override
  Map<String, dynamic> toJson() => Map.unmodifiable({
    ...super.toJson(),
    'background_options': {'completion_window': '8h'},
  });
}

OpenAIClient _client(Future<http.Response> Function(http.Request) send) {
  final transport = MockClient(send);
  addTearDown(transport.close);
  return OpenAIClient(
    config: const OpenAIConfig(authProvider: ApiKeyProvider('fixture')),
    httpClient: transport,
  );
}

void _expectMetadata(Response response) {
  expect(response.promptCacheOptions!.ttl, ResponsePromptCacheTtl.hours12);
  expect(response.inputTransformations!.map((item) => item.reason), [
    InputRemovalReason.modelMismatch,
    const InputRemovalReason('provider_reason'),
  ]);
  final details = response.usage!.inputTokensDetails!;
  expect(details.cacheWriteTokens, 8);
  expect(
    details.cacheWriteTokensDetails,
    const CacheWriteTokensDetails(ttl30mTokens: 5, ttl12hTokens: 3),
  );
  expect(details.copyWith(cacheWriteTokensDetails: null).toJson(), {
    'cached_tokens': 0,
    'cache_write_tokens': 8,
  });
  expect(
    response.copyWith(inputTransformations: null).toJson(),
    isNot(contains('input_transformations')),
  );
  final roundTrip = Response.fromJson(response.toJson());
  expect(roundTrip, response);
  expect(roundTrip.hashCode, response.hashCode);
}

const Map<String, dynamic> _completedEvent = {
  'type': 'response.completed',
  'sequence_number': 1,
  'response': _response,
};

const Map<String, dynamic> _response = {
  'id': 'resp_fixture',
  'object': 'response',
  'created_at': 1,
  'status': 'completed',
  'output': <Object>[],
  'prompt_cache_options': {'mode': 'implicit', 'ttl': '12h'},
  'input_transformations': [
    {
      'type': 'reasoning',
      'action': 'removed',
      'id': 'rs_old',
      'reason': 'model_mismatch',
    },
    {
      'type': 'reasoning',
      'action': 'removed',
      'id': 'rs_new',
      'reason': 'provider_reason',
    },
  ],
  'usage': {
    'input_tokens': 10,
    'output_tokens': 2,
    'total_tokens': 12,
    'input_tokens_details': {
      'cached_tokens': 0,
      'cache_write_tokens': 8,
      'cache_write_tokens_details': {'ttl_30m_tokens': 5, 'ttl_12h_tokens': 3},
    },
  },
};
