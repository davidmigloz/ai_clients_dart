import 'dart:async';
import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../../mocks/mock_http_client.dart';

const _threadsBeta = 'message-threads-2026-08-12';

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

  test('listener cancellation releases a stalled thread transport', () async {
    final stalled = _StalledThreadTransport();
    final streamingClient = AnthropicClient(httpClient: stalled);
    addTearDown(streamingClient.close);
    addTearDown(() => stalled.body.close().ignore());
    final thread = streamingClient.messages.createThread(_request());
    final subscription = thread.stream().listen(null);
    await stalled.listened.future.timeout(const Duration(seconds: 1));

    await subscription.cancel().timeout(const Duration(seconds: 1));

    await stalled.canceled.future.timeout(const Duration(seconds: 1));
    expect(thread.previousMessageId, isNull);
    thread.append([InputMessage.user('New turn')]);
    expect(thread.messages, hasLength(2));
  });

  test('adopts a returned container for continuation and fork', () async {
    final response = MockResponses.message(id: 'msg_with_container')
      ..['container'] = {
        'id': 'container_fixture',
        'expires_at': '2026-11-12T00:00:00Z',
      };
    transport
      ..queueJsonResponse(response)
      ..queueJsonResponse(MockResponses.message(id: 'msg_second'))
      ..queueJsonResponse(MockResponses.message(id: 'msg_fork'));
    const skills = [
      ContainerSkillParams(type: ContainerSkillType.anthropic, skillId: 'pdf'),
    ];
    final thread = client.messages.createThread(
      _request().copyWith(
        container: ContainerParam.config(const ContainerParams(skills: skills)),
      ),
    );
    await thread.send();
    await thread.send(messages: [InputMessage.user('Continue')]);
    final fork = thread.fork();
    await fork.send(messages: [InputMessage.user('Fork')]);

    final expected = {
      'id': 'container_fixture',
      'skills': [skills.single.toJson()],
    };
    expect(_body(transport.requests.first)['container'], {
      'skills': [skills.single.toJson()],
    });
    expect(_body(transport.requests[1])['container'], expected);
    expect(_body(transport.requests.last)['container'], expected);
    expect(fork.params.container?.toJson(), expected);
  });

  test('adopts a container returned at stream start before retrying', () async {
    final events = MockResponses.streamingEvents();
    (events.first['message'] as Map<String, dynamic>)['container'] = {
      'id': 'container_stream',
      'expires_at': '2026-11-12T00:00:00Z',
    };
    transport
      ..queueStreamingResponse(events)
      ..queueJsonResponse(_error('thread_not_found'), statusCode: 404)
      ..queueJsonResponse(MockResponses.message(id: 'msg_retry'));
    final thread = client.messages.createThread(
      _request(),
      replayOnThreadError: true,
    );

    await thread.stream().finalMessage();
    final reply = await thread.send(messages: [InputMessage.user('Continue')]);

    expect(reply.id, 'msg_retry');
    expect(transport.requests, hasLength(3));
    expect(_body(transport.requests[1])['container'], 'container_stream');
    expect(_body(transport.requests[2])['container'], 'container_stream');
    expect(_body(transport.requests[2])['thread'], {'type': 'create'});
  });

  test(
    'never replays malformed tool arguments from an interrupted stream',
    () async {
      final start = MockResponses.message(id: 'msg_interrupted')
        ..['content'] = <Object>[];
      transport
        ..queueStreamingResponse([
          {'type': 'message_start', 'message': start},
          {
            'type': 'content_block_start',
            'index': 0,
            'content_block': {
              'type': 'tool_use',
              'id': 'tool_fixture',
              'name': 'lookup',
              'input': <String, dynamic>{},
            },
          },
          {
            'type': 'content_block_delta',
            'index': 0,
            'delta': {'type': 'input_json_delta', 'partial_json': '{"value":'},
          },
          {'type': 'content_block_stop', 'index': 0},
        ])
        ..queueJsonResponse(MockResponses.message(id: 'msg_new'));
      final thread = client.messages.createThread(_request());

      await expectLater(thread.stream().finalMessage(), throwsStateError);
      expect(thread.previousMessageId, isNull);
      await thread.send(messages: [InputMessage.user('Try a different task')]);

      expect(_body(transport.requests.last)['messages'], [
        ..._request().messages.map((message) => message.toJson()),
        _user('Try a different task'),
      ]);
    },
  );

  test(
    'starts and continues turns with consistent routing and beta headers',
    () async {
      transport
        ..queueJsonResponse(MockResponses.message(id: 'msg_first'))
        ..queueJsonResponse(MockResponses.message(id: 'msg_second'));
      final thread = client.messages.createThread(
        _request(),
        betas: const ['thinking-binding-controls-2026-08-01', _threadsBeta],
        workspaceId: 'wrkspc_test',
        userProfileId: 'uprof_test',
      );
      expect(thread.previousMessageId, isNull);

      final first = await thread.send();
      final second = await thread.send(
        messages: [InputMessage.user('Next turn')],
      );

      expect(first.id, 'msg_first');
      expect(second.id, 'msg_second');
      expect(thread.previousMessageId, second.id);
      expect(thread.lastMessage, second);
      expect(thread.messages, hasLength(4));
      for (final request in transport.requests) {
        expect(request.url.path, '/v1/messages');
        expect(request.url.queryParameters, isEmpty);
        expect(
          request.headers['anthropic-beta'],
          'thinking-binding-controls-2026-08-01,$_threadsBeta',
        );
        expect(request.headers['anthropic-workspace-id'], 'wrkspc_test');
        expect(request.headers['anthropic-user-profile-id'], 'uprof_test');
      }
      final initial = _body(transport.requests.first);
      expect(initial['thread'], {'type': 'create'});
      expect(initial['system'], 'Be concise.');
      final continued = _body(transport.requests.last);
      expect(continued['thread'], {
        'type': 'continue',
        'previous_message_id': 'msg_first',
      });
      expect(continued['messages'], [_user('Next turn')]);
      expect(continued, isNot(contains('system')));
      expect(continued, isNot(contains('tools')));
    },
  );

  test(
    'opt-in replay is bounded and strips earlier cache breakpoints',
    () async {
      transport
        ..queueJsonResponse(MockResponses.message(id: 'msg_first'))
        ..queueJsonResponse(_error('thread_not_found'), statusCode: 404)
        ..queueJsonResponse(_error('thread_not_found'), statusCode: 404)
        ..queueJsonResponse(MockResponses.message(id: 'msg_recovered'));
      final thread = client.messages.createThread(
        _request().copyWith(
          messages: [
            InputMessage.userBlocks(const [
              TextInputBlock('Opening', cacheControl: CacheControlEphemeral()),
            ]),
          ],
        ),
        replayOnThreadError: true,
      );
      await thread.send();

      await expectLater(
        thread.send(messages: [InputMessage.user('Next turn')]),
        throwsA(
          isA<ApiException>().having(
            (error) => error.errorCode,
            'errorCode',
            'thread_not_found',
          ),
        ),
      );
      expect(transport.requests, hasLength(3));
      expect(thread.previousMessageId, isNull);
      expect(thread.messages, hasLength(2));
      final replay = _body(transport.requests[2]);
      expect(replay['thread'], {'type': 'create'});
      expect(replay['system'], 'Be concise.');
      expect(replay['messages'], [
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': 'Opening'},
          ],
        },
        thread.lastMessage!.toInputMessage().toJson(),
        _user('Next turn'),
      ]);

      final recovered = await thread.send(
        messages: [InputMessage.user('Retry')],
      );
      expect(recovered.id, 'msg_recovered');
      expect(thread.previousMessageId, 'msg_recovered');
      expect(thread.messages, hasLength(4));
    },
  );

  for (final (optIn, code) in [
    (false, 'thread_not_found'),
    (true, 'model_not_found'),
  ]) {
    test('does not replay when optIn=$optIn and code=$code', () async {
      transport
        ..queueJsonResponse(MockResponses.message(id: 'msg_first'))
        ..queueJsonResponse(_error(code), statusCode: 404);
      final thread = client.messages.createThread(
        _request(),
        replayOnThreadError: optIn,
      );
      await thread.send();

      await expectLater(
        thread.send(messages: [InputMessage.user('Next')]),
        throwsA(
          isA<ApiException>().having((error) => error.errorCode, 'code', code),
        ),
      );
      expect(transport.requests, hasLength(2));
      expect(thread.messages, hasLength(2));
    });
  }

  test('stream handshake can replay once before any output', () async {
    transport
      ..queueJsonResponse(MockResponses.message(id: 'msg_first'))
      ..queueJsonResponse(_error('thread_already_continued'), statusCode: 400)
      ..queueStreamingResponse(MockResponses.streamingEvents(text: 'Replayed'));
    final thread = client.messages.createThread(
      _request(),
      replayOnThreadError: true,
    );
    await thread.send();

    final second = await thread
        .stream(messages: [InputMessage.user('Next')])
        .finalMessage();

    expect(second.text, 'Replayed');
    expect(thread.previousMessageId, second.id);
    expect(thread.messages, hasLength(4));
    expect(transport.requests, hasLength(3));
    expect(_body(transport.requests[1])['thread'], {
      'type': 'continue',
      'previous_message_id': 'msg_first',
    });
    expect(_body(transport.requests[2])['thread'], {'type': 'create'});
    expect(_body(transport.requests[2])['messages'], hasLength(3));
  });

  test(
    'dropped stream keeps partial text and can retry the turn explicitly',
    () async {
      final start = MockResponses.message(id: 'msg_partial')
        ..['content'] = <Object>[]
        ..['stop_reason'] = null;
      transport
        ..queueJsonResponse(MockResponses.message(id: 'msg_first'))
        ..queueStreamingResponse([
          {'type': 'message_start', 'message': start},
          {
            'type': 'content_block_start',
            'index': 0,
            'content_block': {'type': 'text', 'text': ''},
          },
          {
            'type': 'content_block_delta',
            'index': 0,
            'delta': {'type': 'text_delta', 'text': 'Partial reply'},
          },
        ])
        ..queueJsonResponse(MockResponses.message(id: 'msg_retry'));
      final thread = client.messages.createThread(_request());
      await thread.send();

      await expectLater(
        thread.stream(messages: [InputMessage.user('Next')]).finalMessage(),
        throwsStateError,
      );
      expect(thread.previousMessageId, isNull);
      expect(thread.lastMessage!.id, 'msg_first');
      expect(thread.messages.last.toJson(), {
        'role': 'assistant',
        'content': [
          {'type': 'text', 'text': 'Partial reply'},
        ],
      });
      expect(transport.requests, hasLength(2));

      final retried = await thread.send();
      expect(retried.id, 'msg_retry');
      expect(thread.previousMessageId, retried.id);
      final body = _body(transport.lastRequest!);
      expect(body['thread'], {'type': 'create'});
      expect(body['messages'], [
        _user('Opening'),
        thread.messages[1].toJson(),
        _user('Next'),
      ]);
      expect(thread.messages, hasLength(4));
    },
  );

  test('refusal drops the turn and starts over with staged inputs', () async {
    transport
      ..queueJsonResponse(MockResponses.message(id: 'msg_first'))
      ..queueJsonResponse(
        MockResponses.message(id: 'msg_refused', stopReason: 'refusal'),
      )
      ..queueJsonResponse(MockResponses.message(id: 'msg_next'));
    final thread = client.messages.createThread(_request());
    await thread.send();
    thread.append([InputMessage.user('Keep staged input')]);

    final refusal = await thread.send(messages: [InputMessage.user('Refuse')]);
    expect(refusal.isRefusal, isTrue);
    expect(thread.previousMessageId, isNull);
    expect(thread.lastMessage!.id, 'msg_first');
    expect(thread.messages.last.toJson(), _user('Keep staged input'));

    final next = await thread.send(messages: [InputMessage.user('Try again')]);
    expect(next.id, 'msg_next');
    final body = _body(transport.lastRequest!);
    expect(body['thread'], {'type': 'create'});
    expect(body['messages'], [
      _user('Opening'),
      thread.messages[1].toJson(),
      _user('Keep staged input'),
      _user('Try again'),
    ]);
  });

  test(
    'a fallback reply is stored locally without a continuation cursor',
    () async {
      final fallback = MockResponses.message(
        id: 'msg_fallback',
        model: 'claude-opus-5-5',
      );
      final usage = Map<String, dynamic>.of(
        fallback['usage'] as Map<String, dynamic>,
      );
      fallback['usage'] = usage;
      usage['iterations'] = [
        {
          'type': 'fallback_message',
          'model': 'claude-opus-5-5',
          'input_tokens': 8,
          'output_tokens': 4,
          'cache_creation_input_tokens': 0,
          'cache_read_input_tokens': 0,
        },
      ];
      transport
        ..queueJsonResponse(fallback)
        ..queueJsonResponse(MockResponses.message(id: 'msg_next'));
      final thread = client.messages.createThread(
        _request().copyWith(fallbacks: const FallbacksParam.defaultMode()),
        betas: const ['server-side-fallback-2026-07-01'],
      );

      final first = await thread.send();
      expect(first.id, 'msg_fallback');
      expect(thread.previousMessageId, isNull);
      expect(thread.messages, hasLength(2));
      await thread.send(messages: [InputMessage.user('Next turn')]);
      expect(_body(transport.lastRequest!)['thread'], {'type': 'create'});
      expect(_body(transport.lastRequest!)['messages'], hasLength(3));
      expect(
        transport.lastRequest!.headers['anthropic-beta'],
        'server-side-fallback-2026-07-01,$_threadsBeta',
      );
    },
  );

  test(
    'prevents an overlapping turn and releases after stream cancellation',
    () async {
      transport.queueStreamingResponse(
        MockResponses.streamingEvents(text: 'Cancelled'),
      );
      final thread = client.messages.createThread(_request());
      final iterator = StreamIterator(thread.stream());
      expect(await iterator.moveNext(), isTrue);
      expect(iterator.current, isA<MessageStartEvent>());
      expect(thread.previousMessageId, isNull);

      await expectLater(thread.send(), throwsStateError);
      await iterator.cancel();

      expect(thread.previousMessageId, isNull);
      expect(transport.requests, hasLength(1));
      transport.queueJsonResponse(
        MockResponses.message(id: 'msg_after_cancel'),
      );
      final reply = await thread.send();
      expect(reply.id, 'msg_after_cancel');
      expect(_body(transport.lastRequest!)['thread'], {'type': 'create'});
    },
  );
}

MessageCreateRequest _request() => MessageCreateRequest(
  model: 'claude-sonnet-5-5',
  maxTokens: 256,
  messages: [InputMessage.user('Opening')],
  system: SystemPrompt.text('Be concise.'),
);

Map<String, dynamic> _body(http.BaseRequest request) =>
    jsonDecode((request as http.Request).body) as Map<String, dynamic>;

Map<String, String> _user(String text) => {'role': 'user', 'content': text};

Map<String, dynamic> _error(String code) => {
  'type': 'error',
  'error': {
    'type': 'invalid_request_error',
    'message': 'The request could not continue.',
    'details': {'error_code': code},
  },
};

final class _StalledThreadTransport extends http.BaseClient {
  _StalledThreadTransport() {
    body = StreamController(
      onListen: listened.complete,
      onCancel: canceled.complete,
    );
  }

  final listened = Completer<void>();
  final canceled = Completer<void>();
  late final StreamController<List<int>> body;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async =>
      http.StreamedResponse(body.stream, 200);
}
