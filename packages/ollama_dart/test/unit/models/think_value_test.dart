import 'package:ollama_dart/ollama_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ThinkValue', () {
    test('ThinkValue.fromJson parses boolean values', () {
      expect(ThinkValue.fromJson(true), isA<ThinkEnabled>());
      expect((ThinkValue.fromJson(true)! as ThinkEnabled).value, isTrue);
      expect(ThinkValue.fromJson(false), isA<ThinkEnabled>());
      expect((ThinkValue.fromJson(false)! as ThinkEnabled).value, isFalse);
    });

    test('ThinkValue.fromJson parses string levels', () {
      expect(ThinkValue.fromJson('high'), isA<ThinkWithLevel>());
      expect(
        (ThinkValue.fromJson('high')! as ThinkWithLevel).level,
        ThinkLevel.high,
      );
      expect(ThinkValue.fromJson('medium'), isA<ThinkWithLevel>());
      expect(
        (ThinkValue.fromJson('medium')! as ThinkWithLevel).level,
        ThinkLevel.medium,
      );
      expect(ThinkValue.fromJson('low'), isA<ThinkWithLevel>());
      expect(
        (ThinkValue.fromJson('low')! as ThinkWithLevel).level,
        ThinkLevel.low,
      );
    });

    test('ThinkValue.fromJson returns null for unknown values', () {
      expect(ThinkValue.fromJson(null), isNull);
      expect(ThinkValue.fromJson('unknown'), isNull);
      expect(ThinkValue.fromJson(123), isNull);
    });

    test('ThinkEnabled.toJson returns boolean', () {
      expect(const ThinkEnabled(true).toJson(), isTrue);
      expect(const ThinkEnabled(false).toJson(), isFalse);
    });

    test('ThinkWithLevel.toJson returns string', () {
      expect(const ThinkWithLevel(ThinkLevel.high).toJson(), 'high');
      expect(const ThinkWithLevel(ThinkLevel.medium).toJson(), 'medium');
      expect(const ThinkWithLevel(ThinkLevel.low).toJson(), 'low');
    });

    test('ThinkValue equality works correctly', () {
      expect(const ThinkEnabled(true), equals(const ThinkEnabled(true)));
      expect(
        const ThinkEnabled(true),
        isNot(equals(const ThinkEnabled(false))),
      );
      expect(
        const ThinkWithLevel(ThinkLevel.high),
        equals(const ThinkWithLevel(ThinkLevel.high)),
      );
      expect(
        const ThinkWithLevel(ThinkLevel.high),
        isNot(equals(const ThinkWithLevel(ThinkLevel.low))),
      );
    });

    test('ThinkValue hashCode is consistent', () {
      expect(
        const ThinkEnabled(true).hashCode,
        equals(const ThinkEnabled(true).hashCode),
      );
      expect(
        const ThinkWithLevel(ThinkLevel.high).hashCode,
        equals(const ThinkWithLevel(ThinkLevel.high).hashCode),
      );
    });

    test('ThinkValue toString returns readable string', () {
      expect(const ThinkEnabled(true).toString(), 'ThinkEnabled(true)');
      expect(const ThinkEnabled(false).toString(), 'ThinkEnabled(false)');
      expect(
        const ThinkWithLevel(ThinkLevel.high).toString(),
        'ThinkWithLevel(ThinkLevel.high)',
      );
    });
  });

  group('ThinkValue in requests', () {
    test('ChatRequest serializes ThinkValue correctly', () {
      const request = ChatRequest(
        model: 'llama3.2',
        messages: [ChatMessage.user('Hello')],
        think: ThinkEnabled(true),
      );

      final json = request.toJson();
      expect(json['think'], true);
    });

    test('ChatRequest serializes ThinkLevel correctly', () {
      const request = ChatRequest(
        model: 'llama3.2',
        messages: [ChatMessage.user('Hello')],
        think: ThinkWithLevel(ThinkLevel.high),
      );

      final json = request.toJson();
      expect(json['think'], 'high');
    });

    test('ChatRequest deserializes ThinkValue correctly', () {
      final json = {
        'model': 'llama3.2',
        'messages': [
          {'role': 'user', 'content': 'Hello'},
        ],
        'think': true,
      };

      final request = ChatRequest.fromJson(json);
      expect(request.think, isA<ThinkEnabled>());
      expect((request.think! as ThinkEnabled).value, isTrue);
    });

    test('ChatRequest deserializes ThinkLevel correctly', () {
      final json = {
        'model': 'llama3.2',
        'messages': [
          {'role': 'user', 'content': 'Hello'},
        ],
        'think': 'medium',
      };

      final request = ChatRequest.fromJson(json);
      expect(request.think, isA<ThinkWithLevel>());
      expect((request.think! as ThinkWithLevel).level, ThinkLevel.medium);
    });

    test('GenerateRequest serializes ThinkValue correctly', () {
      const request = GenerateRequest(
        model: 'llama3.2',
        prompt: 'Hello',
        think: ThinkEnabled(true),
      );

      final json = request.toJson();
      expect(json['think'], true);
    });

    test('GenerateRequest deserializes ThinkValue correctly', () {
      final json = {'model': 'llama3.2', 'prompt': 'Hello', 'think': 'low'};

      final request = GenerateRequest.fromJson(json);
      expect(request.think, isA<ThinkWithLevel>());
      expect((request.think! as ThinkWithLevel).level, ThinkLevel.low);
    });
  });
}
