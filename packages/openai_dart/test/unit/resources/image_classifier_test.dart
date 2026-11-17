import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logging/logging.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  test(
    'classifyImage posts one image and decodes classifier categories',
    () async {
      final client = _client((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/v1/moderations');
        expect(jsonDecode(request.body), {
          'model': 'omni-moderation-csam-latest',
          'input': [
            {
              'type': 'image_url',
              'image_url': {'url': _imageUrl},
            },
          ],
        });
        return http.Response(jsonEncode(_response), 200);
      });

      final response = await client.moderations.classifyImage(_imageUrl);

      expect(response.id, 'modr_fixture');
      expect(response.model, 'omni-moderation-csam-latest');
      expect(response.result.flagged, isTrue);
      expect(response.result.categories['likely-csam'], isTrue);
      expect(response.result.categories['likely-csam/gen-ai'], isFalse);
      expect(response.result.categoryScores['likely-csam/gen-ai'], 0.13);
      expect(response.result.categoryAppliedInputTypes['likely-csam'], [
        'image',
      ]);
      expect(response.toJson(), _response);
    },
  );

  test(
    'ordinary multimodal moderation keeps its general category shape',
    () async {
      const categoryNames = [
        'hate',
        'hate/threatening',
        'harassment',
        'harassment/threatening',
        'illicit',
        'illicit/violent',
        'self-harm',
        'self-harm/intent',
        'self-harm/instructions',
        'sexual',
        'sexual/minors',
        'violence',
        'violence/graphic',
      ];
      final client = _client((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(request.url.path, '/v1/moderations');
        expect(body['model'], 'omni-moderation-latest');
        return http.Response(
          jsonEncode({
            'id': 'modr_general_fixture',
            'model': 'omni-moderation-latest',
            'results': [
              {
                'flagged': false,
                'categories': {
                  for (final category in categoryNames) category: false,
                },
                'category_scores': {
                  for (final category in categoryNames) category: 0,
                },
                'category_applied_input_types': {
                  for (final category in categoryNames) category: ['image'],
                },
              },
            ],
          }),
          200,
        );
      });

      final response = await client.moderations.create(
        ModerationRequest(
          model: 'omni-moderation-latest',
          input: ModerationInput.multiModal([
            ModerationInputItem.imageUrl(_imageUrl),
          ]),
        ),
      );

      expect(response.first.categories.violence, isFalse);
      expect(response.first.categoryScores.violence, 0);
      expect(response.first.categoryAppliedInputTypes?.violence, ['image']);
    },
  );

  test(
    'the generic method directs classifier callers to classifyImage',
    () async {
      final client = _client((_) async => fail('Unexpected request'));
      for (final request in [
        ModerationRequest(
          model: 'omni-moderation-csam-latest',
          input: ModerationInput.multiModal([
            ModerationInputItem.imageUrl(_imageUrl),
          ]),
        ),
        const _ClassifierWireModelRequest(),
      ]) {
        await expectLater(
          client.moderations.create(request),
          throwsA(
            isA<ArgumentError>().having(
              (error) => error.message,
              'message',
              contains('moderations.classifyImage'),
            ),
          ),
        );
      }
    },
  );

  test(
    'classifier keeps request, response and error diagnostics private',
    () async {
      final previousHierarchy = hierarchicalLoggingEnabled;
      final previousLevel = Logger.root.level;
      hierarchicalLoggingEnabled = true;
      Logger.root.level = Level.ALL;
      final logs = <String>[];
      final subscription = Logger.root.onRecord.listen(
        (record) => logs.add(record.message),
      );
      addTearDown(() async {
        await subscription.cancel();
        Logger.root.level = previousLevel;
        hierarchicalLoggingEnabled = previousHierarchy;
      });

      const errorMessage = 'fixture-private-error-text';
      const customErrorMessage = 'fixture-private-interceptor-text';
      const malformedBody = '{"fixture-private-invalid-response"';
      const ordinaryText = 'fixture-ordinary-moderation-text';
      var sends = 0;
      final client = _client((request) async {
        return switch (++sends) {
          1 => http.Response(jsonEncode(_response), 200),
          2 || 4 => http.Response(
            jsonEncode({
              'error': {'message': errorMessage},
            }),
            400,
          ),
          3 => http.Response(malformedBody, 200),
          _ => fail('Unexpected request'),
        };
      }, logLevel: Level.FINEST);
      final flags = <bool>[];
      client.interceptorChain.interceptors.insert(
        0,
        _CallbackInterceptor((context, next) {
          flags.add(context.redactDiagnostics);
          if (flags.length == 5) throw StateError(customErrorMessage);
          return next(context);
        }),
      );
      final moderations = client.moderations;

      final classified = await moderations.classifyImage(_imageUrl);
      expect(classified.id, 'modr_fixture');
      await expectLater(
        moderations.classifyImage(_imageUrl),
        throwsA(
          isA<BadRequestException>()
              .having((error) => error.message, 'message', errorMessage)
              .having(
                (error) => error.toString(),
                'diagnostic',
                isNot(contains(errorMessage)),
              ),
        ),
      );
      await expectLater(
        moderations.classifyImage(_imageUrl),
        throwsA(
          isA<ParseException>()
              .having((error) => error.responseBody, 'body', malformedBody)
              .having(
                (error) => error.toString(),
                'diagnostic',
                isNot(contains(malformedBody)),
              ),
        ),
      );
      final privateLogs = logs.join('\n');
      expect(privateLogs, contains('[REDACTED private request]'));
      expect(privateLogs, contains('[REDACTED private response]'));
      for (final value in [
        _imageUrl,
        'modr_fixture',
        'likely-csam',
        errorMessage,
        malformedBody,
      ]) {
        expect(privateLogs, isNot(contains(value)));
      }

      logs.clear();
      await expectLater(
        moderations.create(
          ModerationRequest(input: ModerationInput.text(ordinaryText)),
        ),
        throwsA(isA<BadRequestException>()),
      );
      expect(logs.join('\n'), contains(ordinaryText));
      expect(logs.join('\n'), contains(errorMessage));

      logs.clear();
      await expectLater(
        moderations.classifyImage(_imageUrl),
        throwsA(
          isA<ConnectionException>()
              .having((error) => error.cause, 'cause', isA<StateError>())
              .having(
                (error) => error.toString(),
                'diagnostic',
                isNot(contains(customErrorMessage)),
              ),
        ),
      );
      expect(logs.join('\n'), isNot(contains(customErrorMessage)));
      expect(flags, [true, true, true, false, true]);
      expect(sends, 4);
    },
  );

  test(
    'closed moderation handles reject classifier requests before sending',
    () async {
      final client = _client((_) async => fail('Unexpected request'));
      final moderations = client.moderations;
      client.close();

      await expectLater(moderations.classifyImage(_imageUrl), throwsStateError);
      await expectLater(
        moderations.create(const _ClassifierWireModelRequest()),
        throwsStateError,
      );
    },
  );

  test('preserves additional categories and keeps missing keys absent', () {
    final response = ImageClassifierResponse.fromJson(const {
      'id': 'modr_fixture',
      'model': 'omni-moderation-csam-latest',
      'results': [
        {
          'flagged': false,
          'categories': {'likely-csam': false, 'future-category': true},
          'category_scores': {'likely-csam': 0, 'future-category': 1},
          'category_applied_input_types': {
            'future-category': ['image'],
          },
        },
      ],
    });
    final result = response.result;

    expect(result.categories['likely-csam/gen-ai'], isNull);
    expect(result.categoryScores['likely-csam/gen-ai'], isNull);
    expect(result.categoryAppliedInputTypes['likely-csam'], isNull);
    expect(result.categories['future-category'], isTrue);
    expect(
      result.categoryScores['future-category'],
      isA<double>().having((n) => n, 'score', 1),
    );
    expect(result.categoryAppliedInputTypes['future-category'], ['image']);
    final roundTrip = ImageClassifierResponse.fromJson(response.toJson());
    expect(roundTrip, response);
    expect(roundTrip.hashCode, response.hashCode);
  });

  test('models own their maps and applied input lists', () {
    final flags = {'category': true, 'other': false};
    final scores = {'category': 0.8, 'other': 0.1};
    final inputs = {
      'category': ['image'],
    };
    final result = ImageClassifierResult(
      flagged: true,
      categories: flags,
      categoryScores: scores,
      categoryAppliedInputTypes: inputs,
    );
    flags['category'] = false;
    scores.clear();
    inputs['category']!.clear();

    expect(result.categories['category'], isTrue);
    expect(result.categoryScores['category'], 0.8);
    expect(result.categoryAppliedInputTypes['category'], ['image']);
    expect(result.categories.clear, throwsUnsupportedError);
    expect(result.categoryScores.clear, throwsUnsupportedError);
    expect(result.categoryAppliedInputTypes.clear, throwsUnsupportedError);
    expect(
      () => result.categoryAppliedInputTypes['category']!.clear(),
      throwsUnsupportedError,
    );

    final reordered = ImageClassifierResult(
      flagged: true,
      categories: const {'other': false, 'category': true},
      categoryScores: const {'other': 0.1, 'category': 0.8},
      categoryAppliedInputTypes: const {
        'category': ['image'],
      },
    );
    expect(reordered, result);
    expect(reordered.hashCode, result.hashCode);
  });

  test('rejects missing results and invalid category maps', () {
    expect(
      () => ImageClassifierResponse.fromJson(
        Map<String, dynamic>.of(_response)..['results'] = const <Object>[],
      ),
      throwsFormatException,
    );
    expect(
      () => ImageClassifierResult.fromJson(
        Map<String, dynamic>.of(_result)..['categories'] = null,
      ),
      throwsFormatException,
    );
    expect(
      () => ImageClassifierResult.fromJson(
        Map<String, dynamic>.of(_result)
          ..['category_scores'] = const {'likely-csam': '0.13'},
      ),
      throwsFormatException,
    );
    expect(
      () => ImageClassifierResult.fromJson(
        Map<String, dynamic>.of(_result)
          ..['category_applied_input_types'] = const {
            'likely-csam': ['image', 1],
          },
      ),
      throwsFormatException,
    );
  });
}

OpenAIClient _client(
  Future<http.Response> Function(http.Request) handle, {
  Level? logLevel,
}) {
  final transport = MockClient(handle);
  final client = OpenAIClient(
    config: OpenAIConfig(
      baseUrl: 'https://fixture.invalid/v1',
      authProvider: const ApiKeyProvider('local-fixture'),
      logLevel: logLevel,
    ),
    httpClient: transport,
  );
  addTearDown(transport.close);
  addTearDown(client.close);
  return client;
}

final class _ClassifierWireModelRequest extends ModerationRequest {
  const _ClassifierWireModelRequest()
    : super(input: const ModerationInputText('fixture'));

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'model': 'omni-moderation-csam-latest',
  };
}

final class _CallbackInterceptor implements Interceptor {
  const _CallbackInterceptor(this.callback);

  final Future<http.Response> Function(RequestContext, InterceptorNext)
  callback;

  @override
  Future<http.Response> intercept(
    RequestContext context,
    InterceptorNext next,
  ) => callback(context, next);
}

const _imageUrl = 'https://fixture.invalid/synthetic-image.png';
const _result = <String, Object>{
  'flagged': true,
  'categories': {'likely-csam': true, 'likely-csam/gen-ai': false},
  'category_scores': {'likely-csam': 0.92, 'likely-csam/gen-ai': 0.13},
  'category_applied_input_types': {
    'likely-csam': ['image'],
    'likely-csam/gen-ai': ['image'],
  },
};
const _response = <String, Object>{
  'id': 'modr_fixture',
  'model': 'omni-moderation-csam-latest',
  'results': [_result],
};
