import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('CreateSessionParams.initialEvents', () {
    final userMessageJson = <String, dynamic>{
      'type': 'user.message',
      'content': [
        {'type': 'text', 'text': 'hello'},
      ],
    };

    Map<String, dynamic> paramsJson({Object? initialEvents = #absent}) {
      return {
        'agent': 'agt_1',
        'environment_id': 'env_1',
        if (initialEvents != #absent) 'initial_events': initialEvents,
      };
    }

    test('fromJson parses initial_events and round-trips', () {
      final json = paramsJson(initialEvents: [userMessageJson]);
      final params = CreateSessionParams.fromJson(json);

      expect(params.initialEvents, hasLength(1));
      expect(
        params.initialEvents!.single,
        isA<SessionUserMessageEventParams>(),
      );
      expect(params.toJson(), json);
    });

    test('is null and omitted from toJson when absent', () {
      final params = CreateSessionParams.fromJson(paramsJson());
      expect(params.initialEvents, isNull);
      expect(params.toJson().containsKey('initial_events'), isFalse);
    });

    test('copyWith replaces and clears initialEvents', () {
      const params = CreateSessionParams(
        agent: AgentParamsId(id: 'agt_1'),
        environmentId: 'env_1',
        initialEvents: [
          SessionInitialEventParams.userMessage(
            UserMessageEventParams(
              content: [
                {'type': 'text', 'text': 'hi'},
              ],
            ),
          ),
        ],
      );

      final cleared = params.copyWith(initialEvents: null);
      expect(cleared.initialEvents, isNull);

      final replaced = params.copyWith(
        initialEvents: const [
          SessionInitialEventParams.userDefineOutcome(
            UserDefineOutcomeEventParams(
              description: 'd',
              rubric: TextRubricParams(content: 'r'),
            ),
          ),
        ],
      );
      expect(
        replaced.initialEvents!.single,
        isA<SessionUserDefineOutcomeEventParams>(),
      );

      // Omitted preserves the existing value.
      expect(params.copyWith().initialEvents, params.initialEvents);
    });

    test('equality and hashCode include initialEvents', () {
      const a = CreateSessionParams(
        agent: AgentParamsId(id: 'agt_1'),
        environmentId: 'env_1',
        initialEvents: [
          SessionInitialEventParams.userMessage(
            UserMessageEventParams(
              content: [
                {'type': 'text', 'text': 'hi'},
              ],
            ),
          ),
        ],
      );
      const b = CreateSessionParams(
        agent: AgentParamsId(id: 'agt_1'),
        environmentId: 'env_1',
        initialEvents: [
          SessionInitialEventParams.userMessage(
            UserMessageEventParams(
              content: [
                {'type': 'text', 'text': 'hi'},
              ],
            ),
          ),
        ],
      );
      const c = CreateSessionParams(
        agent: AgentParamsId(id: 'agt_1'),
        environmentId: 'env_1',
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });

    test('toString includes initialEvents', () {
      const params = CreateSessionParams(
        agent: AgentParamsId(id: 'agt_1'),
        environmentId: 'env_1',
        initialEvents: [
          SessionInitialEventParams.userMessage(
            UserMessageEventParams(content: []),
          ),
        ],
      );
      expect(params.toString(), contains('initialEvents:'));
    });
  });
}
