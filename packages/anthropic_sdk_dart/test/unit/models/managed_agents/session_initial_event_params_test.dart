import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('SessionInitialEventParams (create wrapper)', () {
    test('.userMessage factory wraps UserMessageEventParams and toJson '
        'delegates', () {
      const params = UserMessageEventParams(
        content: [
          {'type': 'text', 'text': 'hello'},
        ],
      );
      const wrapped = SessionInitialEventParams.userMessage(params);

      expect(wrapped, isA<SessionUserMessageEventParams>());
      expect((wrapped as SessionUserMessageEventParams).params, equals(params));
      expect(wrapped.toJson(), params.toJson());
      expect(wrapped.toJson(), {
        'type': 'user.message',
        'content': [
          {'type': 'text', 'text': 'hello'},
        ],
      });
    });

    test('.userDefineOutcome factory wraps UserDefineOutcomeEventParams', () {
      const params = UserDefineOutcomeEventParams(
        description: 'Produce a report.',
        rubric: TextRubricParams(content: 'Grade leniently.'),
        maxIterations: 5,
      );
      const wrapped = SessionInitialEventParams.userDefineOutcome(params);

      expect(wrapped, isA<SessionUserDefineOutcomeEventParams>());
      expect(wrapped.toJson(), params.toJson());
      expect(wrapped.toJson()['type'], 'user.define_outcome');
    });

    test('fromJson dispatches user.message to the right wrapper and '
        'round-trips', () {
      final json = <String, dynamic>{
        'type': 'user.message',
        'content': [
          {'type': 'text', 'text': 'hello'},
        ],
      };

      final parsed = SessionInitialEventParams.fromJson(json);
      expect(parsed, isA<SessionUserMessageEventParams>());
      expect(parsed.toJson(), json);
    });

    test('fromJson dispatches user.define_outcome to the right wrapper', () {
      final json = <String, dynamic>{
        'type': 'user.define_outcome',
        'description': 'd',
        'rubric': {'type': 'text', 'content': 'r'},
        'max_iterations': 3,
      };

      final parsed = SessionInitialEventParams.fromJson(json);
      expect(parsed, isA<SessionUserDefineOutcomeEventParams>());
      expect(parsed.toJson(), json);
    });

    test('unrecognized type → UnknownSessionInitialEventParams fallback', () {
      final json = <String, dynamic>{
        'type': 'system.message',
        'content': [
          {'type': 'text', 'text': 'sys'},
        ],
      };

      final parsed = SessionInitialEventParams.fromJson(json);
      expect(parsed, isA<UnknownSessionInitialEventParams>());
      // Round-trips the raw JSON unchanged.
      expect(parsed.toJson(), json);
    });

    test('equality and hashCode', () {
      const a = SessionInitialEventParams.userMessage(
        UserMessageEventParams(
          content: [
            {'type': 'text', 'text': 'hi'},
          ],
        ),
      );
      const b = SessionInitialEventParams.userMessage(
        UserMessageEventParams(
          content: [
            {'type': 'text', 'text': 'hi'},
          ],
        ),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('copyWith replaces the wrapped params', () {
      const wrapped = SessionInitialEventParams.userMessage(
        UserMessageEventParams(
          content: [
            {'type': 'text', 'text': 'hi'},
          ],
        ),
      );
      final updated = (wrapped as SessionUserMessageEventParams).copyWith(
        params: const UserMessageEventParams(
          content: [
            {'type': 'text', 'text': 'bye'},
          ],
        ),
      );
      expect(updated.toJson()['content'], [
        {'type': 'text', 'text': 'bye'},
      ]);
    });
  });
}
