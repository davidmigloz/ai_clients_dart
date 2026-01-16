import 'package:open_responses_dart/open_responses_dart.dart';
import 'package:test/test.dart';

void main() {
  group('StreamingEvent', () {
    test('fromJson parses response.created event', () {
      final json = {
        'type': 'response.created',
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
        'item_id': 'msg_001',
        'output_index': 0,
        'content_index': 0,
        'delta': 'Hello',
      };

      final event = StreamingEvent.fromJson(json);

      expect(event, isA<OutputTextDeltaEvent>());
      expect((event as OutputTextDeltaEvent).delta, 'Hello');
      expect(event.itemId, 'msg_001');
    });

    test('fromJson parses function_call_arguments.delta event', () {
      final json = {
        'type': 'response.function_call_arguments.delta',
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
        'error': {'code': 'server_error', 'message': 'Something went wrong'},
      };

      final event = StreamingEvent.fromJson(json);

      expect(event, isA<ErrorEvent>());
      expect((event as ErrorEvent).error.code, 'server_error');
      expect(event.error.message, 'Something went wrong');
    });

    test('toJson round-trips correctly', () {
      const original = OutputTextDeltaEvent(
        itemId: 'msg_001',
        outputIndex: 0,
        contentIndex: 0,
        delta: 'Hello',
      );

      final json = original.toJson();
      final parsed = StreamingEvent.fromJson(json);

      expect(parsed, isA<OutputTextDeltaEvent>());
      expect((parsed as OutputTextDeltaEvent).delta, 'Hello');
    });

    test('textDelta extension returns delta for text events', () {
      const event = OutputTextDeltaEvent(
        itemId: 'msg_001',
        outputIndex: 0,
        contentIndex: 0,
        delta: 'Hello',
      );

      expect(event.textDelta, 'Hello');
    });

    test('textDelta extension returns null for non-text events', () {
      const event = ResponseCompletedEvent(
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
        response: ResponseResource(
          id: 'resp_123',
          createdAt: 1700000000,
          model: 'gpt-4o',
          status: ResponseStatus.completed,
        ),
      );
      const failed = ResponseFailedEvent(
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
        itemId: 'msg_001',
        outputIndex: 0,
        contentIndex: 0,
        delta: 'Hello',
      );

      expect(event.isFinal, isFalse);
    });
  });
}
