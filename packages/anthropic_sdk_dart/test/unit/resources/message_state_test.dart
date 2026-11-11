import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../../mocks/mock_http_client.dart';

const _threads = 'message-threads-2026-08-12';
const _compact = 'compact-2026-09-04';
const _inlineTools = 'inline-tools-2026-09-15';
const _thinkingBinding = 'thinking-binding-controls-2026-08-01';

void main() {
  late MockHttpClient transport;
  late AnthropicClient client;

  setUp(() {
    transport = MockHttpClient();
    client = AnthropicClient(
      config: const AnthropicConfig(
        authProvider: ApiKeyProvider('test-key'),
        retryPolicy: RetryPolicy(maxRetries: 0),
      ),
      httpClient: transport,
    );
    addTearDown(client.close);
  });

  test('creates and continues a thread over the same Messages path', () async {
    const betas = [_threads, _thinkingBinding];
    transport
      ..queueJsonResponse(MockResponses.message(id: 'msg_first'))
      ..queueStreamingResponse(MockResponses.streamingEvents(text: 'Next'));

    final first = await client.messages.create(
      _request().copyWith(
        thread: const MessageThreadParam.create(),
        system: SystemPrompt.text('Use a concise style.'),
      ),
      betas: betas,
    );
    final second = await client.messages
        .createStream(
          _request().copyWith(
            messages: [InputMessage.user('Continue')],
            thread: MessageThreadParam.continueFrom(first.id),
          ),
          betas: betas,
        )
        .finalMessage();

    expect(second.text, 'Next');
    expect(second.stopReason, StopReason.endTurn);
    for (final request in transport.requests) {
      expect(request.method, 'POST');
      expect(request.url.path, '/v1/messages');
      expect(request.url.queryParameters, isEmpty);
      expect(request.headers['anthropic-beta'], betas.join(','));
    }
    final firstBody = _body(transport.requests.first);
    expect(firstBody['thread'], {'type': 'create'});
    expect(firstBody['system'], 'Use a concise style.');
    final secondBody = _body(transport.requests.last);
    expect(secondBody['thread'], {
      'type': 'continue',
      'previous_message_id': 'msg_first',
    });
    expect(secondBody['messages'], [
      {'role': 'user', 'content': 'Continue'},
    ]);
    expect(secondBody, isNot(contains('system')));
    expect(secondBody, isNot(contains('tools')));
    expect(secondBody['stream'], isTrue);
  });

  test('manual continuation does not replay an API error', () async {
    transport.queueJsonResponse({
      'type': 'error',
      'error': {
        'type': 'not_found_error',
        'message': 'Thread expired',
        'details': {'error_code': 'thread_not_found'},
      },
      'request_id': 'req_thread',
    }, statusCode: 404);

    await expectLater(
      client.messages.create(
        _request().copyWith(
          thread: const MessageThreadParam.continueFrom('msg_expired'),
        ),
        betas: const [_threads],
      ),
      throwsA(
        isA<ApiException>().having((error) => error.statusCode, 'status', 404),
      ),
    );
    expect(transport.requests, hasLength(1));
  });

  for (final streaming in [false, true]) {
    test(
      'replays signed compaction after a ${streaming ? 'streamed' : 'buffered'} reply',
      () async {
        const betas = [_compact, _inlineTools, 'task-budgets-2026-03-13'];
        final response = MockResponses.message(id: 'msg_compaction')
          ..['content'] = [_signedBlock]
          ..['stop_reason'] = 'compaction';
        if (streaming) {
          final start = {
            ...response,
            'content': <Object>[],
            'stop_reason': null,
          };
          transport.queueStreamingResponse([
            {'type': 'message_start', 'message': start},
            {
              'type': 'content_block_start',
              'index': 0,
              'content_block': _signedBlock,
            },
            {'type': 'content_block_stop', 'index': 0},
            _stopDelta('compaction'),
            {'type': 'message_stop'},
          ]);
        } else {
          transport.queueJsonResponse(response);
        }
        transport.queueJsonResponse(MockResponses.message(text: 'Replayed'));
        final request = _request().copyWith(
          compaction: const CompactionConfig.summarize(
            instructions: "Preserve the user's goal.",
          ),
        );

        final summary = streaming
            ? await client.messages
                  .createStream(request, betas: betas)
                  .finalMessage()
            : await client.messages.create(request, betas: betas);
        expect(summary.stopReason, StopReason.compaction);
        final block = summary.content.single as CompactionBlock;
        expect(block.signature, _signedBlock['signature']);
        expect(block.toolChanges, _signedBlock['tool_changes']);
        expect(block.encryptedContent, _signedBlock['encrypted_content']);
        final reply = await client.messages.create(
          request.copyWith(
            compaction: null,
            messages: [summary.toInputMessage(), InputMessage.user('Continue')],
          ),
          betas: betas,
        );
        expect(reply.text, 'Replayed');
        final first = _body(transport.requests.first);
        expect(first['compaction'], {
          'type': 'summarize',
          'instructions': "Preserve the user's goal.",
        });
        final replay = _body(transport.requests.last);
        expect(replay, isNot(contains('compaction')));
        expect(replay['messages'], [
          {
            'role': 'assistant',
            'content': [_signedBlock],
          },
          {'role': 'user', 'content': 'Continue'},
        ]);
        expect(transport.requests, hasLength(2));
        for (final sent in transport.requests) {
          expect(sent.headers['anthropic-beta'], betas.join(','));
        }
      },
    );
  }

  test('sends compaction in a beta token counting request', () async {
    transport.queueJsonResponse(MockResponses.tokenCount(inputTokens: 15));
    final request = TokenCountRequest.fromMessageCreateRequest(
      _request().copyWith(compaction: const CompactionConfig.summarize()),
    );

    final count = await client.messages.countTokens(
      request,
      betas: const [_compact],
    );

    expect(count.inputTokens, 15);
    final sent = transport.lastRequest!;
    expect(sent.url.path, '/v1/messages/count_tokens');
    expect(sent.headers['anthropic-beta'], _compact);
    expect(_body(sent)['compaction'], {'type': 'summarize'});
    expect(_body(sent), isNot(contains('thread')));
  });

  test(
    'carries GA diagnostics into the final message and sends fast mode',
    () async {
      final start = MockResponses.message(model: 'claude-opus-5-5')
        ..['content'] = <Object>[]
        ..['stop_reason'] = null
        ..['diagnostics'] = {'cache_miss_reason': null};
      transport.queueStreamingResponse([
        {'type': 'message_start', 'message': start},
        _stopDelta('end_turn', usage: {'output_tokens': 4, 'speed': 'fast'}),
        {'type': 'message_stop'},
      ]);

      final result = await client.messages
          .createStream(
            _request().copyWith(
              model: 'claude-opus-5-5',
              diagnostics: const DiagnosticsParam(
                previousMessageId: 'msg_prior',
              ),
              speed: Speed.fast,
            ),
          )
          .finalMessage();

      expect(result.diagnostics, isNotNull);
      expect(result.diagnostics!.cacheMissReason, isNull);
      expect(result.usage.speed, Speed.fast);
      final sent = transport.lastRequest!;
      expect(sent.headers['anthropic-beta'], isNull);
      final body = _body(sent);
      expect(body['diagnostics'], {'previous_message_id': 'msg_prior'});
      expect(body['speed'], 'fast');
    },
  );

  test(
    'parses thinking mismatch reports from streamed message deltas',
    () async {
      final start = MockResponses.message()
        ..['content'] = <Object>[]
        ..['stop_reason'] = null;
      final delta = _stopDelta('end_turn')
        ..['input_transformations'] = [
          {
            'type': 'thinking_mismatch_allowed',
            'path': 'messages.1.content.0',
            'reason': 'prefix_binding_mismatch',
          },
        ];
      transport.queueStreamingResponse([
        {'type': 'message_start', 'message': start},
        delta,
        {'type': 'message_stop'},
      ]);

      final result = await client.messages
          .createStream(_request(), betas: const [_thinkingBinding])
          .finalMessage();

      final entry =
          result.inputTransformations!.single
              as ThinkingMismatchAllowedInputTransformation;
      expect(entry.path, 'messages.1.content.0');
      expect(entry.reason, InputTransformationReason.prefixBindingMismatch);
      expect(
        transport.lastRequest!.headers['anthropic-beta'],
        _thinkingBinding,
      );
    },
  );

  test(
    'partial and error streams cannot yield a final conversation message',
    () async {
      final start = {
        'type': 'message_start',
        'message': MockResponses.message()
          ..['content'] = <Object>[]
          ..['stop_reason'] = null,
      };
      transport
        ..queueStreamingResponse([start])
        ..queueStreamingResponse([
          start,
          {
            'type': 'error',
            'error': {'type': 'overloaded_error', 'message': 'Try again'},
          },
          {'type': 'message_stop'},
        ]);

      await expectLater(
        client.messages.createStream(_request()).finalMessage(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('message_stop'),
          ),
        ),
      );
      await expectLater(
        client.messages.createStream(_request()).finalMessage(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('overloaded_error'),
          ),
        ),
      );
      expect(transport.requests, hasLength(2));
    },
  );
}

MessageCreateRequest _request() => MessageCreateRequest(
  model: 'claude-sonnet-5-5',
  maxTokens: 256,
  messages: [InputMessage.user('Summarize my notes.')],
);

Map<String, dynamic> _body(http.BaseRequest request) =>
    jsonDecode((request as http.Request).body) as Map<String, dynamic>;

Map<String, dynamic> _stopDelta(
  String reason, {
  Map<String, dynamic> usage = const {'output_tokens': 4},
}) => {
  'type': 'message_delta',
  'delta': {'stop_reason': reason, 'stop_sequence': null},
  'usage': usage,
};

const Map<String, dynamic> _signedBlock = {
  'type': 'compaction',
  'content': 'The user is preparing a project summary.',
  'signature': 'opaque-signed-summary',
  'encrypted_content': 'opaque-encrypted-context',
  'tool_changes': [
    {
      'type': 'tool_addition',
      'tool': {
        'type': 'tool_definition',
        'definition': {
          'name': 'lookup',
          'input_schema': {
            'type': 'object',
            'properties': {
              'key': {'type': 'string'},
            },
          },
        },
      },
    },
  ],
};
