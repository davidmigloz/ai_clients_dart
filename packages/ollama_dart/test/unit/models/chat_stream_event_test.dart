import 'package:ollama_dart/ollama_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ChatStreamEvent', () {
    test('fromJson/toJson round-trip with message and stats', () {
      final json = {
        'model': 'llama3.2',
        'created_at': '2026-01-01T00:00:00Z',
        'message': {'role': 'assistant', 'content': 'Hi'},
        'done': true,
        'done_reason': 'stop',
        'total_duration': 1000,
        'eval_count': 5,
      };

      final event = ChatStreamEvent.fromJson(json);
      expect(event.message?.content, 'Hi');
      expect(event.message?.role, MessageRole.assistant);
      expect(event.totalDuration, 1000);

      final roundTrip = event.toJson();
      expect(roundTrip['total_duration'], 1000);
      expect(roundTrip['done_reason'], 'stop');
    });

    test('equality compares all fields, not just model/createdAt/done', () {
      const a = ChatStreamEvent(
        model: 'llama3.2',
        done: true,
        totalDuration: 1000,
      );
      const b = ChatStreamEvent(
        model: 'llama3.2',
        done: true,
        totalDuration: 2000,
      );

      // Previously these compared equal (totalDuration was ignored).
      expect(a, isNot(equals(b)));
      expect(a.hashCode, isNot(equals(b.hashCode)));
    });
  });
}
