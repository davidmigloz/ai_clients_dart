import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../../mocks/mock_http_client.dart';

const Map<String, Object> _schema = {
  'type': 'object',
  'properties': {
    'answer': {'type': 'integer'},
  },
  'required': ['answer'],
  'additionalProperties': false,
};

void main() {
  late MockHttpClient httpClient;
  late AnthropicClient client;
  late MessageCreateRequest request;

  setUp(() {
    httpClient = MockHttpClient();
    client = AnthropicClient(
      config: const AnthropicConfig(
        authProvider: ApiKeyProvider('test-key'),
        retryPolicy: RetryPolicy(maxRetries: 0),
      ),
      httpClient: httpClient,
    );
    request = MessageCreateRequest(
      model: 'claude-sonnet-5-5',
      maxTokens: 128,
      messages: [InputMessage.user('What is 2 + 2?')],
    );
  });

  tearDown(() => client.close());

  final output = StructuredOutput<int>(schema: _schema, decode: _answer);

  test(
    'parse preserves output options, routing, and each text value',
    () async {
      final input = request.copyWith(
        outputConfig: const OutputConfig(
          effort: EffortLevel.low,
          taskBudget: TokenTaskBudget(total: 24000, remaining: 22000),
        ),
      );
      httpClient.queueJsonResponse({
        ...MockResponses.message(id: 'msg_structured'),
        'content': [
          {'type': 'thinking', 'thinking': 'Calculate.', 'signature': 'signed'},
          {'type': 'text', 'text': '{"answer":4}'},
          {'type': 'text', 'text': '{"answer":7}'},
        ],
      });

      final result = await client.messages.parse(
        input,
        output: output,
        betas: ['task-budgets-2026-03-13'],
        workspaceId: 'wrk_test',
        userProfileId: 'uprof_test',
      );

      expect(result.parsedOutput, 4);
      expect(result.parsedTextBlocks, {1: 4, 2: 7});
      expect(() => result.parsedTextBlocks[3] = 42, throwsUnsupportedError);
      expect(result.message.id, 'msg_structured');
      expect(result.message.usage.inputTokens, 10);
      expect(result.message.content.first, isA<ThinkingBlock>());
      expect(input.outputConfig!.format, isNull);

      final sent = httpClient.lastRequest! as http.Request;
      expect(sent.url.path, '/v1/messages');
      expect(sent.headers['x-api-key'], 'test-key');
      expect(sent.headers['anthropic-version'], '2026-10-21');
      expect(sent.headers['anthropic-beta'], 'task-budgets-2026-03-13');
      expect(sent.headers['anthropic-workspace-id'], 'wrk_test');
      expect(sent.headers['anthropic-user-profile-id'], 'uprof_test');
      expect(jsonDecode(sent.body), {
        ...request.toJson(),
        'output_config': {
          'effort': 'low',
          'task_budget': {'type': 'tokens', 'total': 24000, 'remaining': 22000},
          'format': {'type': 'json_schema', 'schema': _schema},
        },
      });
    },
  );

  test('raw JSON null and first nonnull parsed value stay distinct', () async {
    httpClient.queueJsonResponse({
      ...MockResponses.message(),
      'content': [
        {'type': 'text', 'text': 'null'},
        {'type': 'text', 'text': '"a"'},
      ],
    });
    final result = await client.messages.parse(
      request,
      output: StructuredOutput<Object?>(
        schema: {'type': 'string'},
        decode: (value) => value,
      ),
    );
    expect(result.parsedTextBlocks, {0: null, 1: 'a'});
    expect(result.parsedOutput, 'a');
  });

  test('returns the raw refusal without decoding plain text', () async {
    httpClient.queueJsonResponse({
      ...MockResponses.message(text: 'Cannot answer.', stopReason: 'refusal'),
      'stop_details': {
        'category': 'safety',
        'fallback_credit_token': 'credit-token',
      },
    });
    final result = await client.messages.parse(request, output: output);
    expect(result.parsedOutput, isNull);
    expect(result.parsedTextBlocks, isEmpty);
    expect(result.message.stopReason, StopReason.refusal);
    expect(result.message.stopDetails!.fallbackCreditToken, 'credit-token');
    expect(result.message.text, 'Cannot answer.');
  });

  test('returns the raw max-tokens response without decoding it', () async {
    httpClient.queueJsonResponse(
      MockResponses.message(text: '{"answer":', stopReason: 'max_tokens'),
    );
    final result = await client.messages.parse(request, output: output);
    expect(result.parsedTextBlocks, isEmpty);
    expect(result.message.text, '{"answer":');
    expect(result.message.stopReason, StopReason.maxTokens);
  });

  test(
    'JSON and application-decoder failures retain raw diagnostics',
    () async {
      for (final text in ['not JSON', '{"answer":"four"}']) {
        httpClient.queueJsonResponse(MockResponses.message(text: text));
        await expectLater(
          client.messages.parse(request, output: output),
          throwsA(
            isA<StructuredOutputParseException>()
                .having((e) => e.blockIndex, 'blockIndex', 0)
                .having((e) => e.message.text, 'original text', text)
                .having((e) => e.cause, 'cause', isA<FormatException>()),
          ),
        );
      }
    },
  );

  test(
    'streamed parse observes deltas and decodes after message stop',
    () async {
      final events = MockResponses.streamingEvents(text: '{"answer":')
        ..insert(3, {
          'type': 'content_block_delta',
          'index': 0,
          'delta': {'type': 'text_delta', 'text': '4}'},
        });
      httpClient.queueStreamingResponse(events);
      final observed = <MessageStreamEvent>[];
      final result = await client.messages
          .parseStream(
            request,
            output: output,
            betas: ['example-beta'],
            workspaceId: 'wrk_test',
            userProfileId: 'uprof_test',
          )
          .finalParsedMessage(onEvent: observed.add);
      expect(result.parsedOutput, 4);
      expect(result.message.text, '{"answer":4}');
      expect(observed.whereType<ContentBlockDeltaEvent>(), hasLength(2));
      expect(observed.last, isA<MessageStopEvent>());
      final sent = httpClient.lastRequest! as http.Request;
      expect(sent.headers['anthropic-beta'], 'example-beta');
      expect(sent.headers['anthropic-workspace-id'], 'wrk_test');
      expect(sent.headers['anthropic-user-profile-id'], 'uprof_test');
      expect(jsonDecode(sent.body), {
        ...request.toJson(),
        'stream': true,
        'output_config': {
          'format': {'type': 'json_schema', 'schema': _schema},
        },
      });
    },
  );

  test('failed and incomplete streams never decode partial text', () async {
    var decoderCalls = 0;
    final countedOutput = StructuredOutput<int>(
      schema: _schema,
      decode: (json) {
        decoderCalls++;
        return _answer(json);
      },
    );
    final truncated = MockResponses.streamingEvents(text: '{"answer":4}')
      ..removeLast();
    httpClient.queueStreamingResponse(truncated);
    await expectLater(
      client.messages
          .parseStream(request, output: countedOutput)
          .finalParsedMessage(),
      throwsA(isA<StateError>()),
    );

    httpClient.queueStreamingResponse([
      ...truncated.take(3),
      {
        'type': 'error',
        'error': {'type': 'overloaded_error', 'message': 'fixture overload'},
      },
    ]);
    await expectLater(
      client.messages
          .parseStream(request, output: countedOutput)
          .finalParsedMessage(),
      throwsA(
        predicate<Object>(
          (error) => error.toString().contains('overloaded_error'),
        ),
      ),
    );
    expect(decoderCalls, 0);
  });

  for (final missingType in ['content_block_stop', 'message_delta']) {
    test('message_stop without $missingType cannot complete', () async {
      final malformed = MockResponses.streamingEvents(text: '{"answer":4}')
        ..removeWhere((event) => event['type'] == missingType);
      var decoderCalls = 0;
      final counted = StructuredOutput<int>(
        schema: _schema,
        decode: (json) {
          decoderCalls++;
          return _answer(json);
        },
      );
      httpClient.queueStreamingResponse(malformed);
      await expectLater(
        client.messages
            .parseStream(request, output: counted)
            .finalParsedMessage(),
        throwsA(isA<StateError>()),
      );
      expect(decoderCalls, 0);

      httpClient.queueStreamingResponse(malformed);
      await expectLater(
        client.messages.createStream(request).finalMessage(),
        throwsA(isA<StateError>()),
      );
    });
  }

  test(
    'mismatched block stop and explicit null terminal reason fail',
    () async {
      for (final (eventType, field, value) in [
        ('content_block_stop', 'index', 1),
        ('message_delta', 'delta', {'stop_reason': null}),
      ]) {
        final events = MockResponses.streamingEvents(text: '{"answer":4}');
        events.singleWhere((event) => event['type'] == eventType)[field] =
            value;
        httpClient.queueStreamingResponse(events);
        await expectLater(
          client.messages
              .parseStream(request, output: output)
              .finalParsedMessage(),
          throwsA(isA<StateError>()),
        );
      }
    },
  );

  test('rejects conflicting typed formats before sending', () async {
    final conflicting = request.copyWith(
      outputConfig: OutputConfig(format: output.format),
    );
    await expectLater(
      client.messages.parse(conflicting, output: output),
      throwsA(isA<ValidationException>()),
    );
    await expectLater(
      client.messages
          .parseStream(conflicting, output: output)
          .finalParsedMessage(),
      throwsA(isA<ValidationException>()),
    );
    expect(httpClient.requests, isEmpty);
  });

  test('legacy format JSON becomes canonical for create, count and batch', () {
    final legacy = {
      ...request.toJson(),
      'output_config': {'effort': 'low', 'format': null},
      'output_format': output.format.toJson(),
    };
    final canonical = {'effort': 'low', 'format': output.format.toJson()};
    final message = MessageCreateRequest.fromJson(legacy).toJson();
    final tokens = TokenCountRequest.fromJson(legacy).toJson();
    final item = BatchRequestItem.fromJson({
      'custom_id': 'fixture',
      'params': legacy,
    }).params.toJson();
    for (final json in [message, tokens, item]) {
      expect(json['output_config'], canonical);
      expect(json, isNot(contains('output_format')));
    }

    final conflicting = {...legacy, 'output_config': canonical};
    expect(
      () => MessageCreateRequest.fromJson(conflicting),
      throwsFormatException,
    );
    expect(
      () => TokenCountRequest.fromJson(conflicting),
      throwsFormatException,
    );
    expect(
      MessageCreateRequest.fromJson({
        ...conflicting,
        'output_format': null,
      }).toJson()['output_config'],
      canonical,
    );
  });
}

int _answer(Object? json) {
  if (json case {'answer': final int value}) return value;
  throw const FormatException('Expected an integer answer.');
}
