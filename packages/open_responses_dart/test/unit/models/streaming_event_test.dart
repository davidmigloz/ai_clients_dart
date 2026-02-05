import 'package:open_responses_dart/open_responses_dart.dart';
import 'package:test/test.dart';

void main() {
  group('StreamingEvent', () {
    test('fromJson parses response.created event', () {
      final json = {
        'type': 'response.created',
        'sequence_number': 0,
        'response': {
          'id': 'resp_123',
          'object': 'response',
          'created_at': 1700000000,
          'model': 'gpt-4o',
          'status': 'in_progress',
        },
      };

      final event = StreamingEvent.fromJson(json);

      expect(event, isA<ResponseCreatedEvent>());
      expect((event as ResponseCreatedEvent).response.id, 'resp_123');
    });

    test('fromJson parses response.completed event', () {
      final json = {
        'type': 'response.completed',
        'sequence_number': 1,
        'response': {
          'id': 'resp_123',
          'object': 'response',
          'created_at': 1700000000,
          'model': 'gpt-4o',
          'status': 'completed',
          'usage': {'input_tokens': 10, 'output_tokens': 5, 'total_tokens': 15},
        },
      };

      final event = StreamingEvent.fromJson(json);

      expect(event, isA<ResponseCompletedEvent>());
      expect(
        (event as ResponseCompletedEvent).response.status,
        ResponseStatus.completed,
      );
    });

    test('fromJson parses output_text.delta event', () {
      final json = {
        'type': 'response.output_text.delta',
        'sequence_number': 2,
        'item_id': 'msg_001',
        'output_index': 0,
        'content_index': 0,
        'delta': 'Hello',
        'logprobs': <dynamic>[],
      };

      final event = StreamingEvent.fromJson(json);

      expect(event, isA<OutputTextDeltaEvent>());
      expect((event as OutputTextDeltaEvent).delta, 'Hello');
      expect(event.itemId, 'msg_001');
    });

    test('fromJson parses function_call_arguments.delta event', () {
      final json = {
        'type': 'response.function_call_arguments.delta',
        'sequence_number': 3,
        'item_id': 'call_001',
        'output_index': 0,
        'call_id': 'call_abc123',
        'delta': '{"loc',
      };

      final event = StreamingEvent.fromJson(json);

      expect(event, isA<FunctionCallArgumentsDeltaEvent>());
      expect((event as FunctionCallArgumentsDeltaEvent).delta, '{"loc');
      expect(event.callId, 'call_abc123');
    });

    test('fromJson parses error event', () {
      final json = {
        'type': 'error',
        'sequence_number': 4,
        'error': {
          'type': 'server_error',
          'code': 'server_error',
          'message': 'Something went wrong',
        },
      };

      final event = StreamingEvent.fromJson(json);

      expect(event, isA<ErrorEvent>());
      expect((event as ErrorEvent).error.code, 'server_error');
      expect(event.error.message, 'Something went wrong');
    });

    test('toJson round-trips correctly', () {
      const original = OutputTextDeltaEvent(
        sequenceNumber: 5,
        itemId: 'msg_001',
        outputIndex: 0,
        contentIndex: 0,
        delta: 'Hello',
        logprobs: [],
      );

      final json = original.toJson();
      final parsed = StreamingEvent.fromJson(json);

      expect(parsed, isA<OutputTextDeltaEvent>());
      expect((parsed as OutputTextDeltaEvent).delta, 'Hello');
    });

    test('textDelta extension returns delta for text events', () {
      const event = OutputTextDeltaEvent(
        sequenceNumber: 6,
        itemId: 'msg_001',
        outputIndex: 0,
        contentIndex: 0,
        delta: 'Hello',
        logprobs: [],
      );

      expect(event.textDelta, 'Hello');
    });

    test('textDelta extension returns null for non-text events', () {
      const event = ResponseCompletedEvent(
        sequenceNumber: 7,
        response: ResponseResource(
          id: 'resp_123',
          createdAt: 1700000000,
          model: 'gpt-4o',
          status: ResponseStatus.completed,
        ),
      );

      expect(event.textDelta, isNull);
    });

    test('isFinal returns true for terminal events', () {
      const completed = ResponseCompletedEvent(
        sequenceNumber: 8,
        response: ResponseResource(
          id: 'resp_123',
          createdAt: 1700000000,
          model: 'gpt-4o',
          status: ResponseStatus.completed,
        ),
      );
      const failed = ResponseFailedEvent(
        sequenceNumber: 9,
        response: ResponseResource(
          id: 'resp_123',
          createdAt: 1700000000,
          model: 'gpt-4o',
          status: ResponseStatus.failed,
        ),
      );

      expect(completed.isFinal, isTrue);
      expect(failed.isFinal, isTrue);
    });

    test('isFinal returns false for non-terminal events', () {
      const event = OutputTextDeltaEvent(
        sequenceNumber: 10,
        itemId: 'msg_001',
        outputIndex: 0,
        contentIndex: 0,
        delta: 'Hello',
        logprobs: [],
      );

      expect(event.isFinal, isFalse);
    });

    group('reasoning_text aliases', () {
      test('response.reasoning_text.delta parses to ReasoningDeltaEvent', () {
        final json = {
          'type': 'response.reasoning_text.delta',
          'sequence_number': 1,
          'item_id': 'rs_001',
          'output_index': 0,
          'content_index': 0,
          'delta': 'thinking...',
        };

        final event = StreamingEvent.fromJson(json);

        expect(event, isA<ReasoningDeltaEvent>());
        expect((event as ReasoningDeltaEvent).delta, 'thinking...');
        expect(event.itemId, 'rs_001');
      });

      test('response.reasoning_text.done parses to ReasoningDoneEvent', () {
        final json = {
          'type': 'response.reasoning_text.done',
          'sequence_number': 2,
          'item_id': 'rs_001',
          'output_index': 0,
          'content_index': 0,
          'text': 'full reasoning text',
        };

        final event = StreamingEvent.fromJson(json);

        expect(event, isA<ReasoningDoneEvent>());
        expect((event as ReasoningDoneEvent).text, 'full reasoning text');
      });
    });

    group('UnknownEvent', () {
      test('unknown event type returns UnknownEvent instead of throwing', () {
        final json = {
          'type': 'response.some_future_event',
          'sequence_number': 99,
          'data': 'hello',
        };

        final event = StreamingEvent.fromJson(json);

        expect(event, isA<UnknownEvent>());
      });

      test('rawType and rawJson are preserved', () {
        final json = {
          'type': 'response.new_feature.delta',
          'sequence_number': 1,
          'custom_field': 42,
        };

        final event = StreamingEvent.fromJson(json) as UnknownEvent;

        expect(event.rawType, 'response.new_feature.delta');
        expect(event.type, 'response.new_feature.delta');
        expect(event.rawJson, json);
      });

      test('toJson returns the raw JSON', () {
        final json = {
          'type': 'response.unknown_type',
          'sequence_number': 5,
          'payload': 'test',
        };

        final event = StreamingEvent.fromJson(json) as UnknownEvent;

        expect(event.toJson(), json);
      });

      test('isFinal returns false for UnknownEvent', () {
        final json = {'type': 'response.unknown', 'sequence_number': 0};

        final event = StreamingEvent.fromJson(json);

        expect(event.isFinal, isFalse);
      });

      test('textDelta returns null for UnknownEvent', () {
        final json = {'type': 'response.unknown', 'sequence_number': 0};

        final event = StreamingEvent.fromJson(json);

        expect(event.textDelta, isNull);
      });

      test('equality considers rawJson', () {
        const event1 = UnknownEvent(
          rawType: 'response.new',
          rawJson: {'type': 'response.new', 'data': 'A'},
        );
        const event2 = UnknownEvent(
          rawType: 'response.new',
          rawJson: {'type': 'response.new', 'data': 'B'},
        );
        const event3 = UnknownEvent(
          rawType: 'response.new',
          rawJson: {'type': 'response.new', 'data': 'A'},
        );

        expect(event1, isNot(equals(event2)));
        expect(event1, equals(event3));
        expect(event1.hashCode, equals(event3.hashCode));
      });

      test('equality handles nested structures in rawJson', () {
        // Two events with identical nested content but different instances
        const event1 = UnknownEvent(
          rawType: 'response.custom',
          rawJson: {
            'type': 'response.custom',
            'response': {
              'id': '123',
              'nested': {'key': 'value'},
            },
            'items': [
              1,
              2,
              {'a': 'b'},
            ],
          },
        );
        const event2 = UnknownEvent(
          rawType: 'response.custom',
          rawJson: {
            'type': 'response.custom',
            'response': {
              'id': '123',
              'nested': {'key': 'value'},
            },
            'items': [
              1,
              2,
              {'a': 'b'},
            ],
          },
        );
        const event3 = UnknownEvent(
          rawType: 'response.custom',
          rawJson: {
            'type': 'response.custom',
            'response': {
              'id': '123',
              'nested': {'key': 'different'},
            },
            'items': [
              1,
              2,
              {'a': 'b'},
            ],
          },
        );

        // Same nested content should be equal
        expect(event1, equals(event2));
        expect(event1.hashCode, equals(event2.hashCode));

        // Different nested content should not be equal
        expect(event1, isNot(equals(event3)));
      });
    });
  });
}
