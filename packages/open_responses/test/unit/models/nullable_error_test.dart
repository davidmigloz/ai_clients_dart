import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:open_responses/open_responses.dart';
import 'package:test/test.dart';

import '../../fixtures/responses.dart';

void main() {
  test(
    'nullable provider error type and param round-trip without defaults',
    () {
      final headers = <String, dynamic>{'retry-after': '1'};
      final json = <String, dynamic>{
        'type': null,
        'code': null,
        'message': 'private',
        'param': null,
        'headers': headers,
      };
      final error = ErrorPayload.fromJson(json);
      headers.clear();
      expect(error.type, isNull);
      expect(error.param, isNull);
      expect(error.code, isNull);
      expect(error.toJson(), {
        'type': null,
        'code': null,
        'message': 'private',
        'param': null,
        'headers': {'retry-after': '1'},
      });
      expect(error.headers!.clear, throwsUnsupportedError);
      expect(error.copyWith(), error);
      expect(error.copyWith().hashCode, error.hashCode);
      expect(ErrorPayload.fromJson(error.toJson()), error);
      expect(ErrorPayload.fromJson(error.toJson()).hashCode, error.hashCode);
      expect(error.toString(), isNot(contains('private')));
      final text = error.copyWith(type: 'provider', param: 'input');
      expect(text.type, 'provider');
      expect(text.param, 'input');
      expect(text.copyWith(type: null).toJson()['type'], isNull);
      expect(
        text.copyWith(type: null, hasType: false).toJson().containsKey('type'),
        isFalse,
      );
      final absent = ErrorPayload.fromJson(const {'message': 'legacy'});
      expect(absent.type, 'error'); // Existing omitted-type read behavior.
      expect(absent.hasType, isFalse);
      for (final key in ['type', 'param', 'code']) {
        expect(
          () => ErrorPayload.fromJson({'message': 'failed', key: 12}),
          throwsFormatException,
        );
      }
      expect(
        () =>
            ErrorPayload.fromJson(const {'message': 'failed', 'headers': null}),
        throwsFormatException,
      );
    },
  );

  for (final streaming in [false, true]) {
    test('public nullable error diagnostics stream=$streaming', () async {
      final error = {
        'type': null,
        'code': 'server_error',
        'message': 'private',
        'param': null,
      };
      final fixture = basicCompletedResponse()
        ..['status'] = 'failed'
        ..['error'] = error;
      var sends = 0;
      final transport = MockClient((request) async {
        sends++;
        expect(request.method, 'POST');
        expect(request.url.path, '/v1/responses');
        if (!streaming) return http.Response(jsonEncode(fixture), 200);
        return http.Response(
          'event: error\ndata: ${jsonEncode({'type': 'error', 'sequence_number': 1, 'error': error})}\n\ndata: [DONE]\n\n',
          200,
          headers: {'content-type': 'text/event-stream'},
        );
      });
      final client = OpenResponsesClient(
        config: const OpenResponsesConfig(
          baseUrl: 'https://example.invalid/v1',
          retryPolicy: RetryPolicy(maxRetries: 0),
        ),
        httpClient: transport,
      );
      addTearDown(transport.close);
      addTearDown(client.close);
      const request = CreateResponseRequest(
        model: 'fixture-model',
        input: ResponseTextInput('Hello'),
      );
      final ErrorPayload parsed;
      if (streaming) {
        final events = await client.responses.createStream(request).toList();
        parsed = events.whereType<ErrorEvent>().single.error;
      } else {
        parsed = (await client.responses.create(request)).error!;
      }
      expect(parsed.type, isNull);
      expect(parsed.param, isNull);
      expect(parsed.toJson(), error);
      expect(sends, 1);
    });
  }
}
