import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

import '../../mocks/mock_http_client.dart';

const _key = 'fixture-secret';
const _escaped = r'fixture\u002dsecret';
const _malformed = r'{"type":"error","error":{"message":"fixture\u002dsecret"}';
final _request = MessageCreateRequest(
  model: 'fixture',
  maxTokens: 10,
  messages: [InputMessage.user('Fixture')],
);

void main() {
  test(
    'direct Files malformed escaped error must not retain encoded credential',
    () async {
      final client = _client(_malformed, status: 503);
      addTearDown(client.close);
      await expectLater(
        client.files.download(fileId: 'file_fixture'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            isNot(contains(_escaped)),
          ),
        ),
      );
    },
  );

  test('buffered errors omit malformed excerpts with escaped keys', () async {
    final client = _client(_malformed, status: 503);
    addTearDown(client.close);
    await expectLater(
      client.messages.create(_request),
      throwsA(
        isA<ApiException>()
            .having((e) => e.message, 'message', isNot(contains(_escaped)))
            .having((e) => e.responseMetadata?.bodyExcerpt, 'excerpt', isEmpty),
      ),
    );
  });

  test(
    'SSE HTTP failure must not retain encoded credential in malformed body',
    () async {
      final client = _client(_malformed, status: 503);
      addTearDown(client.close);
      await expectLater(
        client.messages.createStream(_request).drain<void>(),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            isNot(contains(_escaped)),
          ),
        ),
      );
    },
  );

  test('malformed in-band error must not retain an escaped key', () async {
    final client = _client('event: error\ndata: $_malformed\n\n');
    addTearDown(client.close);
    final event =
        (await client.messages.createStream(_request).single) as ErrorEvent;
    expect(event.message, isNot(contains(_escaped)));
  });

  test(
    'malformed unlabeled SSE error must not retain a raw key in the decoder exception',
    () async {
      final client = _client(
        'data: {"type":"error","error":{"message":"$_key"}\n\n',
      );
      addTearDown(client.close);
      await expectLater(
        client.messages.createStream(_request).drain<void>(),
        throwsA(
          isA<FormatException>()
              .having((e) => e.source, 'source', isNull)
              .having((e) => e.offset, 'offset', isNotNull)
              .having(
                (e) => e.toString(),
                'formatted error',
                isNot(contains(_key)),
              ),
        ),
      );
    },
  );

  test('JSONL item error must not retain the request credential', () async {
    final line = jsonEncode({
      'custom_id': 'result-id',
      'result': {
        'type': 'errored',
        'error': {
          'type': 'error',
          'request_id': 'echo-$_key',
          'error': {
            'type': 'invalid_request_error',
            'message': 'rejected $_key',
            'details': {'error_code': 'real_code', 'echo': _key},
          },
        },
      },
    });
    final client = _client('$line\n');
    addTearDown(client.close);
    final result = await client.batches.results('msgbatch_fixture').single;
    final error = (result.result as BatchResultErrored).error;
    expect(jsonEncode(result.toJson()), isNot(contains(_key)));
    expect(result.customId, 'result-id');
    expect(error.message, 'rejected [REDACTED]');
    expect(error.details, containsPair('echo', '[REDACTED]'));
    expect(error.requestId, isNull);
    expect(error.errorCode, 'real_code');
  });

  test(
    'malformed JSONL failure must not expose raw credential via FormatException',
    () async {
      final client = _client(
        '{"custom_id":"fixture","result":{"type":"errored","error":"$_key"}\n',
      );
      addTearDown(client.close);
      await expectLater(
        client.batches.results('msgbatch_fixture').drain<void>(),
        throwsA(
          isA<FormatException>()
              .having((e) => e.source, 'source', isNull)
              .having((e) => e.offset, 'offset', isNotNull)
              .having(
                (e) => e.toString(),
                'formatted error',
                isNot(contains(_key)),
              ),
        ),
      );
    },
  );

  test('clean malformed JSONL keeps the original decoder context', () async {
    const line = '{"custom_id":';
    final client = _client('$line\n');
    addTearDown(client.close);
    await expectLater(
      client.batches.results('msgbatch_fixture').drain<void>(),
      throwsA(
        isA<FormatException>()
            .having((e) => e.source, 'source', line)
            .having((e) => e.offset, 'offset', line.length),
      ),
    );
  });

  test('successful JSONL message content is passed through', () async {
    final line = jsonEncode({
      'custom_id': 'result-id',
      'result': {
        'type': 'succeeded',
        'message': MockResponses.message(text: _key),
      },
    });
    final client = _client('$line\n');
    addTearDown(client.close);
    final result = await client.batches.results('msgbatch_fixture').single;
    expect(result.result, isA<BatchResultSucceeded>());
    expect(jsonEncode(result.toJson()), contains(_key));
  });

  for (final thread in [false, true]) {
    test('Managed Agents ${thread ? 'thread' : 'session'} transport errors '
        'redact credentials without changing domain events', () async {
      final normal = jsonEncode({
        'type': 'agent.message',
        'id': 'event_fixture',
        'processed_at': '2026-04-01T00:00:01Z',
        'content': [
          {'type': 'text', 'text': _key},
        ],
      });
      final error = jsonEncode({
        'type': 'error',
        'request_id': 'req_fixture',
        'error': {
          'type': 'invalid_request_error',
          'message': 'rejected $_key',
          'details': {
            'error_code': 'real_code',
            'nested': [_key, 'safe'],
          },
        },
      });
      final client = _client('data: $normal\n\nevent: error\ndata: $error\n\n');
      addTearDown(client.close);
      final session = client.sessions;
      final events =
          await (thread
                  ? session
                        .threads('sesn_fixture')
                        .events('sthr_fixture')
                        .stream()
                  : session.events('sesn_fixture').stream())
              .toList();

      expect(events, hasLength(2));
      expect(events.first, isA<AgentMessageEvent>());
      expect(jsonEncode(events.first.toJson()), contains(_key));
      final fallback = events.last as UnknownSessionEvent;
      expect(fallback.rawJson, {
        '_event': 'error',
        'type': 'error',
        'request_id': 'req_fixture',
        'error': {
          'type': 'invalid_request_error',
          'message': 'rejected [REDACTED]',
          'details': {
            'error_code': 'real_code',
            'nested': ['[REDACTED]', 'safe'],
          },
        },
      });
    });
  }

  test(
    'valid escaped error fields still redact credentials and keep actual IDs',
    () async {
      final client = _client(
        r'{"request_id":"req_safe","error":{"message":"escaped fixture\u002dsecret","details":{"error_code":"safe"}}}',
        status: 503,
      );
      addTearDown(client.close);
      await expectLater(
        client.files.download(fileId: 'file_fixture'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.message, 'message', 'escaped [REDACTED]')
              .having((e) => e.requestId, 'request ID', 'req_safe'),
        ),
      );
    },
  );
}

AnthropicClient _client(String body, {int status = 200}) => AnthropicClient(
  config: const AnthropicConfig(
    authProvider: ApiKeyProvider(_key),
    retryPolicy: RetryPolicy(maxRetries: 0),
  ),
  httpClient: MockClient((request) async {
    expect(request.headers['x-api-key'], _key);
    return http.Response(
      body,
      status,
      headers: {'content-type': 'application/json'},
    );
  }),
);
