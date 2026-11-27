import 'dart:convert';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

void main() {
  const model = 'gemini-4-neon';
  const continuationToken = 'c29tZS1vcGFxdWUtdG9rZW4=';
  const request = GenerateContentRequest(
    contents: [
      Content(role: 'user', parts: [TextPart('Explain induction.')]),
    ],
    generationConfig: GenerationConfig(
      maxOutputTokens: 131072,
      thinkingConfig: ThinkingConfig(thinkingLevel: ThinkingLevel.xhigh),
    ),
  );

  test('continues a Developer API request with the original inputs', () async {
    final previousLogLevel = Logger.root.level;
    Logger.root.level = Level.FINE;
    addTearDown(() => Logger.root.level = previousLogLevel);
    final logs = <String>[];
    final subscription = Logger.root.onRecord.listen((log) {
      logs.add(log.message);
    });
    addTearDown(subscription.cancel);

    final requests = <http.Request>[];
    final client = GoogleAIClient(
      config: const GoogleAIConfig.googleAI(
        authProvider: ApiKeyProvider('test-key'),
      ),
      httpClient: MockClient((request) async {
        requests.add(request);
        expect(request.method, 'POST');
        expect(request.url.path, '/v1beta/models/$model:generateContent');
        expect(request.url.queryParameters['key'], 'test-key');

        final initialRequest = requests.length == 1;
        return http.Response(
          jsonEncode({
            'candidates': [
              {
                'finishReason': initialRequest ? 'CONTINUATION' : 'STOP',
                if (initialRequest) 'continuationToken': continuationToken,
              },
            ],
          }),
          200,
        );
      }),
    );
    addTearDown(client.close);

    final initial = await client.models.generateContent(
      model: model,
      request: request,
    );
    expect(requests, hasLength(1));
    expect(logs, contains(contains('"continuationToken": "***REDACTED***"')));
    expect(logs, everyElement(isNot(contains(continuationToken))));
    final candidate = initial.candidates!.single;
    expect(candidate.finishReason, FinishReason.continuation);
    expect(candidate.continuationToken, continuationToken);

    final next = await client.models.generateContent(
      model: model,
      request: request.copyWith(continuationToken: candidate.continuationToken),
    );
    expect(next.candidates!.single.finishReason, FinishReason.stop);
    expect(next.candidates!.single.continuationToken, isNull);
    expect(requests, hasLength(2));

    final initialBody = jsonDecode(requests.first.body) as Map<String, dynamic>;
    expect(initialBody, {
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': 'Explain induction.'},
          ],
        },
      ],
      'generationConfig': {
        'maxOutputTokens': 131072,
        'thinkingConfig': {'thinkingLevel': 'XHIGH'},
      },
    });
    expect(jsonDecode(requests.last.body), {
      ...initialBody,
      'continuationToken': continuationToken,
    });
  });

  test('streams continuation tokens through the Vertex beta route', () async {
    final requests = <http.Request>[];
    final client = GoogleAIClient(
      config: GoogleAIConfig.vertexAI(
        apiVersion: ApiVersion.v1beta1,
        projectId: 'test-project',
        location: 'eu',
        authProvider: const BearerTokenProvider('test-token'),
      ),
      httpClient: MockClient((request) async {
        requests.add(request);
        return http.Response(
          'data: {"candidates":[{"content":{"parts":[{"text":"Step 2"}]}}]}\n\n'
          'data: {"candidates":[{"finishReason":"CONTINUATION",'
          ' "continuationToken":"bmV4dC10b2tlbg=="}]}\n\n'
          'data: {"usageMetadata":{"totalTokenCount":65536}}\n\n',
          200,
          headers: {'content-type': 'text/event-stream'},
        );
      }),
    );
    addTearDown(client.close);

    final chunks = await client.models
        .streamGenerateContent(
          model: model,
          request: request.copyWith(continuationToken: continuationToken),
        )
        .toList();

    final wireRequest = requests.single;
    expect(wireRequest.method, 'POST');
    expect(wireRequest.url.host, 'aiplatform.eu.rep.googleapis.com');
    expect(
      wireRequest.url.path,
      '/v1beta1/projects/test-project/locations/eu/publishers/google/'
      'models/$model:streamGenerateContent',
    );
    expect(wireRequest.url.queryParameters, {'alt': 'sse'});
    expect(wireRequest.headers['Authorization'], 'Bearer test-token');
    expect(jsonDecode(wireRequest.body), {
      ...request.toJson(),
      'continuationToken': continuationToken,
    });

    expect(chunks, hasLength(3));
    expect(chunks.first.text, 'Step 2');
    expect(chunks.first.candidates!.single.continuationToken, isNull);
    final checkpoint = chunks[1].candidates!.single;
    expect(checkpoint.finishReason, FinishReason.continuation);
    expect(checkpoint.continuationToken, 'bmV4dC10b2tlbg==');
    expect(chunks.last.usageMetadata?.totalTokenCount, 65536);
  });

  for (final field in ['continuationToken', 'continuation_token']) {
    test(
      'redacts a long $field in HTTP diagnostics and logged exceptions',
      () async {
        final logs = <LogRecord>[];
        final subscription = Logger.root.onRecord.listen(logs.add);
        addTearDown(subscription.cancel);

        final token = 'checkpoint-${List.filled(240, 'x').join()}';
        final error = {
          'message': 'Continuation rejected',
          'details': [
            {
              'reason': 'INVALID_TOKEN',
              'context': [
                {field: token, 'retryable': false},
                '$field: "$token"; request is recoverable',
                null,
              ],
            },
          ],
        };
        final client = GoogleAIClient(
          httpClient: MockClient(
            (_) async => http.Response(
              '{"$field" : "$token","error":${jsonEncode(error)}}',
              400,
            ),
          ),
        );
        addTearDown(client.close);

        final expectedException = isA<ApiException>()
            .having((error) => error.statusCode, 'status', 400)
            .having(
              (error) => error.message,
              'message',
              'Continuation rejected',
            )
            .having((error) => error.details, 'details', [
              {
                'reason': 'INVALID_TOKEN',
                'context': [
                  {field: '***REDACTED***', 'retryable': false},
                  '$field: ***REDACTED***; request is recoverable',
                  null,
                ],
              },
            ])
            .having(
              (error) => error.responseMetadata?.bodyExcerpt,
              'excerpt',
              allOf(
                contains('"$field": "***REDACTED***"'),
                isNot(contains(token.substring(0, 32))),
              ),
            );
        await expectLater(
          client.models.generateContent(model: model, request: request),
          throwsA(expectedException),
        );
        final logged = logs.singleWhere((log) => log.error is ApiException);
        expect(logged.error, expectedException);
        expect(logged.message, isNot(contains(token.substring(0, 32))));
      },
    );
  }

  test('redacts an echoed continuation token in stream diagnostics', () async {
    final logs = <String>[];
    final subscription = Logger.root.onRecord.listen((log) {
      logs.add(log.message);
    });
    addTearDown(subscription.cancel);

    const message = 'Rejected continuationToken=$continuationToken';
    const escapedToken = 'before"after';
    final details = [
      {
        'Continuation_Token': continuationToken,
        'context': [
          'Nested ${jsonEncode({'continuationToken': escapedToken})} trace',
          'ordinary value',
        ],
      },
    ];
    final error = jsonEncode({
      'error': {
        'message': message,
        'status': 'INVALID_ARGUMENT',
        'details': details,
      },
    });
    final responses = [
      http.Response(error, 400),
      http.Response('event: error\ndata: $error\n\n', 200),
    ].iterator;
    final client = GoogleAIClient(
      httpClient: MockClient((_) async {
        expect(responses.moveNext(), isTrue);
        return responses.current;
      }),
    );
    addTearDown(client.close);

    Stream<GenerateContentResponse> openStream() =>
        client.models.streamGenerateContent(model: model, request: request);

    const safeMessage = 'Rejected continuationToken=***REDACTED***';
    const safeDetails = [
      {
        'Continuation_Token': '***REDACTED***',
        'context': [
          'Nested {"continuationToken": "***REDACTED***"} trace',
          'ordinary value',
        ],
      },
    ];
    await expectLater(
      openStream().drain<void>(),
      throwsA(
        isA<ApiException>()
            .having((e) => e.message, 'message', safeMessage)
            .having((e) => e.details, 'details', safeDetails),
      ),
    );
    await expectLater(
      openStream().drain<void>(),
      throwsA(
        isA<StreamException>()
            .having((e) => e.message, 'message', safeMessage)
            .having((e) => jsonDecode(e.partialData!), 'partial data', {
              'error': {
                'message': safeMessage,
                'status': 'INVALID_ARGUMENT',
                'details': safeDetails,
              },
            }),
      ),
    );
    expect(logs, contains('Inline stream error: $safeMessage'));
    expect(logs, everyElement(isNot(contains(continuationToken))));
  });

  test('round-trips and clears candidate continuation tokens', () {
    const json = {
      'finishReason': 'CONTINUATION',
      'continuationToken': continuationToken,
    };
    final candidate = Candidate.fromJson(json);

    expect(candidate.toJson(), json);
    expect(candidate.copyWith(index: 1).continuationToken, continuationToken);
    final cleared = candidate.copyWith(continuationToken: null);
    expect(cleared.continuationToken, isNull);
    expect(cleared.toJson(), {'finishReason': 'CONTINUATION'});
  });
}
