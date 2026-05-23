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
  });
}
