import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('InteractionEvent dispatch', () {
    test('dispatches each documented event_type to its typed class', () {
      final cases = <Map<String, dynamic>, Type>{
        {
          'event_type': 'interaction.created',
          'interaction': {
            'id': 'i_1',
            'status': 'in_progress',
            'object': 'interaction',
          },
        }: InteractionCreatedEvent,
        {
          'event_type': 'interaction.completed',
          'interaction': {
            'id': 'i_1',
            'status': 'completed',
            'object': 'interaction',
          },
        }: InteractionCompletedEvent,
        {
          'event_type': 'interaction.status_update',
          'interaction_id': 'i_1',
          'status': 'in_progress',
        }: InteractionStatusUpdateEvent,
        {
          'event_type': 'step.start',
          'index': 0,
          'step': {'type': 'model_output', 'content': <dynamic>[]},
        }: StepStartEvent,
        {
          'event_type': 'step.delta',
          'index': 0,
          'delta': {'type': 'text', 'text': 'hi'},
        }: StepDeltaEvent,
        {'event_type': 'step.stop', 'index': 0}: StepStopEvent,
        {'event_type': 'error'}: ErrorEvent,
      };
      for (final entry in cases.entries) {
        final event = InteractionEvent.fromJson(entry.key);
        expect(event.runtimeType, entry.value, reason: '${entry.key}');
      }
    });

    test('unknown event_type parses as UnknownInteractionEvent', () {
      final event = InteractionEvent.fromJson({
        'event_type': 'interaction.some_future_event',
        'event_id': 'ev_1',
        'foo': 'bar',
      });
      expect(event, isA<UnknownInteractionEvent>());
      expect(event.eventType, 'interaction.some_future_event');
      expect(event.eventId, 'ev_1');
      final unknown = event as UnknownInteractionEvent;
      expect(unknown.json['foo'], 'bar');
      // toJson preserves the raw payload verbatim.
      expect(unknown.toJson()['foo'], 'bar');
      expect(unknown.toJson()['event_type'], 'interaction.some_future_event');
    });

    test('content.* events surface as UnknownInteractionEvent', () {
      // content.start/delta/stop are not members of the InteractionSseEvent
      // union (matching the official python-genai SDK); the forward-compatible
      // fallback keeps them from breaking the stream.
      for (final type in ['content.start', 'content.delta', 'content.stop']) {
        final event = InteractionEvent.fromJson({
          'event_type': type,
          'index': 0,
        });
        expect(event, isA<UnknownInteractionEvent>(), reason: type);
        expect(event.eventType, type);
      }
    });
  });

  group('StreamMetadata', () {
    test('parses total_usage and round-trips on a streamed event', () {
      final event =
          InteractionEvent.fromJson({
                'event_type': 'step.stop',
                'index': 1,
                'metadata': {
                  'total_usage': {
                    'total_tokens': 42,
                    'total_output_tokens': 10,
                  },
                },
              })
              as StepStopEvent;
      expect(event.metadata, isNotNull);
      expect(event.metadata!.totalUsage, isNotNull);
      expect(event.metadata!.totalUsage!.totalTokens, 42);
      expect(event.metadata!.totalUsage!.totalOutputTokens, 10);

      final json = event.toJson();
      expect(
        (json['metadata'] as Map)['total_usage'],
        isA<Map<String, dynamic>>(),
      );
    });

    test('metadata is absent when not provided', () {
      final event =
          InteractionEvent.fromJson({'event_type': 'step.stop', 'index': 0})
              as StepStopEvent;
      expect(event.metadata, isNull);
      expect(event.toJson().containsKey('metadata'), isFalse);
    });
  });

  group('StepStopEvent usage', () {
    test('parses usage and stepUsage and round-trips', () {
      final event =
          InteractionEvent.fromJson({
                'event_type': 'step.stop',
                'index': 2,
                'usage': {'total_tokens': 100},
                'step_usage': {'total_tokens': 10},
              })
              as StepStopEvent;

      expect(event.usage, isNotNull);
      expect(event.usage!.totalTokens, 100);
      expect(event.stepUsage, isNotNull);
      expect(event.stepUsage!.totalTokens, 10);

      final json = event.toJson();
      final restored = InteractionEvent.fromJson(json) as StepStopEvent;
      expect(restored.usage!.totalTokens, 100);
      expect(restored.stepUsage!.totalTokens, 10);
    });

    test('usage and stepUsage are absent when not provided', () {
      final event =
          InteractionEvent.fromJson({'event_type': 'step.stop', 'index': 0})
              as StepStopEvent;
      expect(event.usage, isNull);
      expect(event.stepUsage, isNull);
      expect(event.toJson().containsKey('usage'), isFalse);
      expect(event.toJson().containsKey('step_usage'), isFalse);
    });
  });

  group('InteractionStatus', () {
    test('round-trips budget_exceeded', () {
      expect(
        InteractionStatus.fromString('budget_exceeded'),
        InteractionStatus.budgetExceeded,
      );
      expect(InteractionStatus.budgetExceeded.toJson(), 'budget_exceeded');
    });
  });
}
