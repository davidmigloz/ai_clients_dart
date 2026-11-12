// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

import '../../mocks/mock_http_client.dart';

const _futureReason = 'provider_future_stop';
final _request = MessageCreateRequest(
  model: 'claude-sonnet-5-5',
  maxTokens: 64,
  messages: [InputMessage.user('Say hello')],
);

void main() {
  test(
    'buffered Messages preserves an unknown stop reason through copy',
    () async {
      final json = MockResponses.message(stopReason: _futureReason);
      final transport = MockHttpClient()..queueJsonResponse(json);
      final client = AnthropicClient(httpClient: transport);
      addTearDown(client.close);
      final message = await client.messages.create(_request);
      expect(message.stopReason, StopReason.unknown);
      expect(message.stopReasonValue, _futureReason);
      expect(message.isEndTurn, isFalse);
      expect(message.toJson()['stop_reason'], _futureReason);
      expect(message.copyWith(), message);
      expect(message.copyWith().hashCode, message.hashCode);
      final known = message.copyWith(stopReasonValue: 'end_turn');
      expect(known.stopReason, StopReason.endTurn);
      expect(known.stopReasonValue, 'end_turn');
      expect(
        message.copyWith(stopReason: StopReason.endTurn).stopReasonValue,
        'end_turn',
      );
      expect(
        message.copyWith(stopReason: null).toJson(),
        isNot(contains('stop_reason')),
      );
      final cleared = message.copyWith(
        stopReason: StopReason.endTurn,
        stopReasonValue: null,
      );
      expect(cleared.stopReason, isNull);
      expect(cleared.stopReasonValue, isNull);
      expect(cleared.toJson(), isNot(contains('stop_reason')));
      final different = Message.fromJson({
        ...json,
        'stop_reason': 'future_second',
      });
      expect(different, isNot(message));
    },
  );

  test(
    'streaming delta and final message retain the same raw reason',
    () async {
      final events = MockResponses.streamingEvents();
      events[4] = {
        'type': 'message_delta',
        'delta': {'stop_reason': _futureReason},
        'usage': {'output_tokens': 9},
      };
      final transport = MockHttpClient()
        ..queueStreamingResponse(events)
        ..queueStreamingResponse(events);
      final client = AnthropicClient(httpClient: transport);
      addTearDown(client.close);
      final streamed = await client.messages.createStream(_request).toList();
      final delta = streamed.whereType<MessageDeltaEvent>().single.delta;
      expect(delta.stopReason, StopReason.unknown);
      expect(delta.copyWith().toJson()['stop_reason'], _futureReason);
      expect(delta.copyWith().hashCode, delta.hashCode);
      final result = await client.messages
          .createStream(_request)
          .finalMessage();
      expect(result.stopReasonValue, _futureReason);
      expect(result.toJson()['stop_reason'], _futureReason);
    },
  );

  test('delta preserves omitted and explicitly null stop reasons', () {
    const omitted = MessageDelta();
    const cleared = MessageDelta(hasStopReason: true);
    const known = MessageDelta(stopReason: StopReason.endTurn);
    final unfamiliar = MessageDelta.fromJson(const {
      'stop_reason': _futureReason,
    });

    expect(omitted.hasStopReason, isFalse);
    expect(const MessageDelta(stopReason: null), omitted);
    expect(omitted.toJson(), isNot(contains('stop_reason')));
    expect(MessageDelta.fromJson(const {}), omitted);
    expect(omitted.copyWith(), omitted);

    expect(cleared.hasStopReason, isTrue);
    expect(cleared.stopReason, isNull);
    expect(cleared.stopReasonValue, isNull);
    expect(cleared.toJson(), containsPair('stop_reason', null));
    expect(MessageDelta.fromJson(cleared.toJson()), cleared);
    expect(omitted.copyWith(stopReason: null), cleared);
    expect(unfamiliar.copyWith(stopReason: null), cleared);
    expect(cleared.copyWith().hashCode, cleared.hashCode);
    expect(cleared, isNot(omitted));

    expect(known.hasStopReason, isTrue);
    expect(known.toJson(), containsPair('stop_reason', 'end_turn'));
    expect(unfamiliar.copyWith(), unfamiliar);
    expect(unfamiliar.copyWith(stopReason: StopReason.endTurn), known);
  });

  test('delta copies and serializes explicit null for all stop fields', () {
    const cleared = MessageDelta(
      hasStopReason: true,
      hasStopDetails: true,
      hasStopSequence: true,
    );
    final wire = {
      'stop_reason': null,
      'stop_details': null,
      'stop_sequence': null,
    };
    expect(cleared.toJson(), wire);
    expect(MessageDelta.fromJson(wire), cleared);
    expect(
      const MessageDelta().copyWith(
        stopReason: null,
        stopDetails: null,
        stopSequence: null,
      ),
      cleared,
    );
    expect(cleared.copyWith().hashCode, cleared.hashCode);
  });

  for (final clear in [false, true]) {
    test(
      'stream stop reason honors omitted and null updates (clear=$clear)',
      () async {
        final events = MockResponses.streamingEvents();
        events.replaceRange(events.length - 2, events.length - 1, [
          {
            'type': 'message_delta',
            'delta': {'stop_reason': _futureReason},
            'usage': {'output_tokens': 8},
          },
          {
            'type': 'message_delta',
            'delta': <String, dynamic>{},
            'usage': {'output_tokens': 9},
          },
          if (clear)
            {
              'type': 'message_delta',
              'delta': {'stop_reason': null},
              'usage': {'output_tokens': 9},
            },
        ]);
        final transport = MockHttpClient()
          ..queueStreamingResponse(events)
          ..queueStreamingResponse(events);
        final client = AnthropicClient(httpClient: transport);
        addTearDown(client.close);

        final expected = clear ? null : StopReason.unknown;
        final finalMessage = await client.messages
            .createStream(_request)
            .finalMessage();
        expect(finalMessage.stopReason, expected);
        expect(finalMessage.stopReasonValue, clear ? null : _futureReason);
        expect(
          await client.messages.createStream(_request).stopReason,
          expected,
        );
      },
    );
  }

  for (final (field, initial) in [
    (
      'stop_sequence',
      {'stop_reason': 'stop_sequence', 'stop_sequence': 'fixture sequence'},
    ),
    (
      'stop_details',
      {
        'stop_reason': 'refusal',
        'stop_details': {'type': 'refusal', 'explanation': 'fixture refusal'},
      },
    ),
  ]) {
    test(
      'stream clears $field when the wire field is explicitly null',
      () async {
        final events = MockResponses.streamingEvents();
        events.replaceRange(events.length - 2, events.length - 1, [
          {
            'type': 'message_delta',
            'delta': initial,
            'usage': {'output_tokens': 8},
          },
          {
            'type': 'message_delta',
            'delta': {'stop_reason': null, field: null},
            'usage': {'output_tokens': 9},
          },
        ]);
        final transport = MockHttpClient()..queueStreamingResponse(events);
        final client = AnthropicClient(httpClient: transport);
        addTearDown(client.close);
        final message = await client.messages
            .createStream(_request)
            .finalMessage();
        expect(message.stopReason, isNull);
        expect(message.stopDetails, isNull);
        expect(message.stopSequence, isNull);
      },
    );
  }

  test(
    'batch results preserve a successful item with a future stop reason',
    () async {
      final transport = MockHttpClient()
        ..queueResponse(
          MockResponse(
            statusCode: 200,
            isStreaming: true,
            headers: const {'content-type': 'application/x-jsonl'},
            body: jsonEncode({
              'custom_id': 'item',
              'result': {
                'type': 'succeeded',
                'message': MockResponses.message(stopReason: _futureReason),
              },
            }),
          ),
        );
      final client = AnthropicClient(httpClient: transport);
      addTearDown(client.close);
      final row = await client.messages.batches.results('batch_fixture').single;
      final message = (row.result as BatchResultSucceeded).message;
      expect(message.stopReason, StopReason.unknown);
      expect(message.stopReasonValue, _futureReason);
    },
  );

  test('legacy Completion models also retain the original value', () {
    final response = CompletionResponse.fromJson(const {
      'id': 'completion_fixture',
      'completion': 'Done',
      'model': 'legacy_fixture',
      'stop_reason': _futureReason,
    });
    expect(response.stopReason, StopReason.unknown);
    expect(response.copyWith().toJson()['stop_reason'], _futureReason);
    expect(response.copyWith().hashCode, response.hashCode);
    final cleared = response.copyWith(stopReason: null);
    expect(cleared.stopReason, isNull);
    expect(cleared.stopReasonValue, isNull);
    expect(cleared.toJson(), isNot(contains('stop_reason')));
    expect(
      response.copyWith(stopReason: StopReason.stopSequence).stopReasonValue,
      'stop_sequence',
    );
  });
}
