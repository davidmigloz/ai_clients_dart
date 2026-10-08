import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  late List<String> records;
  late Level oldLevel;
  late bool oldHierarchical;
  setUp(() {
    records = [];
    oldHierarchical = hierarchicalLoggingEnabled;
    hierarchicalLoggingEnabled = true;
    oldLevel = Logger.root.level;
    Logger.root.level = Level.ALL;
    final subscription = Logger.root.onRecord.listen(
      (record) => records.add(record.message),
    );
    addTearDown(subscription.cancel);
  });
  tearDown(() {
    Logger.root.level = oldLevel;
    hierarchicalLoggingEnabled = oldHierarchical;
  });

  final routes = <(String, String)>[
    ('POST', '/live/sessions'),
    for (final action in ['accept', 'fork', 'hangup', 'refer', 'reject'])
      ('POST', '/live/sessions/SYNTHETIC_PRIVATE_ID%2Fsegment/$action'),
    ('GET', '/live/sessions/SYNTHETIC_PRIVATE_ID%2Fsegment/content'),
  ];
  for (final (method, path) in routes) {
    test(
      'Live logging redacts private wire context for $method $path',
      () async {
        final request =
            http.Request(
                method,
                Uri.parse(
                  'https://example.test/custom/v1$path?trace=SYNTHETIC_QUERY',
                ),
              )
              ..headers['X-Request-ID'] = 'SYNTHETIC_TRACE'
              ..headers['X-Custom-Private'] = 'SYNTHETIC_HEADER';
        if (method == 'POST') {
          request.body = jsonEncode({
            'future_private': 'SYNTHETIC_REQUEST',
            'transport': {
              'sdp': 'SYNTHETIC_SDP',
              'auth': {'password': 'SYNTHETIC_PASSWORD'},
            },
          });
        }
        final body = utf8.encode('SYNTHETIC_RESPONSE_AND_AUDIO');
        final response = http.Response.bytes(
          body,
          200,
          request: request,
          headers: {
            'content-type': method == 'GET' ? 'audio/wav' : 'application/json',
            'x-request-id': 'SYNTHETIC_RESPONSE_TRACE',
            'x-future-private': 'SYNTHETIC_RESPONSE_HEADER',
          },
        );
        final logger = LoggingInterceptor(
          logger: Logger('live-private'),
          logRequestBody: true,
          logResponseBody: true,
        );
        final result = await logger.intercept(
          RequestContext(request: request),
          (_) async => response,
        );
        expect(result, same(response));
        expect(result.bodyBytes, body);
        expect(result.headers['x-request-id'], 'SYNTHETIC_RESPONSE_TRACE');
        expect(records.join('\n'), isNot(contains('SYNTHETIC_')));
        expect(records.join('\n'), contains('[REDACTED]'));

        final error = ApiException(
          message: 'SYNTHETIC_ERROR',
          statusCode: 400,
          requestId: 'SYNTHETIC_ERROR_ID',
          cause: response,
        );
        expect(error.message, 'SYNTHETIC_ERROR');
        expect(error.cause, same(response));
        expect(error.toString(), isNot(contains('SYNTHETIC_')));

        records.clear();
        await expectLater(
          logger.intercept(
            RequestContext(request: request),
            (_) async =>
                throw http.ClientException('SYNTHETIC_CONNECTOR', request.url),
          ),
          throwsA(isA<http.ClientException>()),
        );
        expect(records.join('\n'), isNot(contains('SYNTHETIC_')));
      },
    );
  }

  test('unrelated paths retain normal logging', () async {
    final logger = LoggingInterceptor(logger: Logger('ordinary'));
    final request = http.Request(
      'POST',
      Uri.parse('https://example.test/live/other'),
    );
    await logger.intercept(
      RequestContext(request: request),
      (_) async => http.Response('{}', 200),
    );
    expect(records.join('\n'), contains('https://example.test/live/other'));
  });
}
