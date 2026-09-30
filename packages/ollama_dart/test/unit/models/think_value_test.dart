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
      expect(ThinkValue.fromJson('max'), isA<ThinkWithLevel>());
      expect(
        (ThinkValue.fromJson('max')! as ThinkWithLevel).level,
        ThinkLevel.max,
      );
    });

    test('ThinkValue.fromJson returns null for unsupported JSON types', () {
      expect(ThinkValue.fromJson(null), isNull);
      expect(ThinkValue.fromJson(123), isNull);
    });

    test('preserves model-defined strings and const string factories', () {
      const value = ThinkValue.string('xhigh');
      expect(value, isA<ThinkWithString>());
      expect(value.toJson(), 'xhigh');
      expect(ThinkValue.fromJson('xhigh'), value);
      expect(ThinkValue.fromJson('future-level')?.toJson(), 'future-level');
      expect(ThinkValue.fromJson(''), const ThinkWithString(''));
      expect(const ThinkWithString('xhigh').hashCode, value.hashCode);
      expect(const ThinkWithString('other'), isNot(value));
      expect(value.toString(), 'ThinkWithString(xhigh)');
      expect(const ThinkWithString('xhigh').copyWith(), value);
      expect(
        const ThinkWithString('xhigh').copyWith(value: 'other'),
        const ThinkWithString('other'),
      );
    });

    test('ThinkEnabled.toJson returns boolean', () {
      expect(const ThinkEnabled(true).toJson(), isTrue);
      expect(const ThinkEnabled(false).toJson(), isFalse);
    });

    test('ThinkWithLevel.toJson returns string', () {
      expect(const ThinkWithLevel(ThinkLevel.high).toJson(), 'high');
      expect(const ThinkWithLevel(ThinkLevel.medium).toJson(), 'medium');
      expect(const ThinkWithLevel(ThinkLevel.low).toJson(), 'low');
      expect(const ThinkWithLevel(ThinkLevel.max).toJson(), 'max');
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

    for (final level in ThinkLevel.values) {
      test('${level.name} has equal string and enum representations', () {
        final named = ThinkValue.string(level.name);
        final known = ThinkValue.level(level);
        final decoded = ThinkValue.fromJson(named.toJson());
        expect(named == known, isTrue);
        expect(known == named, isTrue);
        expect(named.hashCode, known.hashCode);
        expect(decoded, isA<ThinkWithLevel>());
        expect(decoded, named);
        expect(named, decoded);
        expect(<ThinkValue>{named, known}, hasLength(1));
      });
    }

    test('boolean controls remain separate from named levels', () {
      expect(
        const ThinkEnabled(true) == const ThinkWithString('true'),
        isFalse,
      );
      expect(
        const ThinkWithString('true') == const ThinkEnabled(true),
        isFalse,
      );
      expect(
        const ThinkEnabled(true) == const ThinkWithLevel(ThinkLevel.high),
        isFalse,
      );
      expect(
        const ThinkWithLevel(ThinkLevel.high) == const ThinkEnabled(true),
        isFalse,
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
    for (final name in ['high', 'xhigh']) {
      test(
        '$name string controls preserve request equality after decoding',
        () {
          final chat = ChatRequest(
            model: 'qwen3.8',
            messages: const [],
            think: ThinkValue.string(name),
          );
          final generate = GenerateRequest(
            model: 'qwen3.8',
            think: ThinkValue.string(name),
          );
          final decodedChat = ChatRequest.fromJson(chat.toJson());
          final decodedGenerate = GenerateRequest.fromJson(generate.toJson());
          expect(decodedChat == chat, isTrue);
          expect(chat == decodedChat, isTrue);
          expect(decodedChat.hashCode, chat.hashCode);
          expect(decodedGenerate == generate, isTrue);
          expect(generate == decodedGenerate, isTrue);
          expect(decodedGenerate.hashCode, generate.hashCode);
        },
      );
    }

    test('named levels survive chat and generate round-trips', () {
      const chat = ChatRequest(
        model: 'qwen3.8',
        messages: [],
        think: ThinkValue.string('xhigh'),
      );
      const generate = GenerateRequest(
        model: 'qwen3.8',
        think: ThinkValue.string('future-level'),
      );
      expect(ChatRequest.fromJson(chat.toJson()), chat);
      expect(GenerateRequest.fromJson(generate.toJson()), generate);
    });
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

    test('ChatRequest serializes ThinkLevel.max correctly', () {
      const request = ChatRequest(
        model: 'llama3.2',
        messages: [ChatMessage.user('Hello')],
        think: ThinkWithLevel(ThinkLevel.max),
      );

      final json = request.toJson();
      expect(json['think'], 'max');
    });

    test('ChatRequest deserializes ThinkLevel.max correctly', () {
      final json = {
        'model': 'llama3.2',
        'messages': [
          {'role': 'user', 'content': 'Hello'},
        ],
        'think': 'max',
      };

      final request = ChatRequest.fromJson(json);
      expect(request.think, isA<ThinkWithLevel>());
      expect((request.think! as ThinkWithLevel).level, ThinkLevel.max);
    });

    test('GenerateRequest serializes ThinkLevel.max correctly', () {
      const request = GenerateRequest(
        model: 'llama3.2',
        prompt: 'Hello',
        think: ThinkWithLevel(ThinkLevel.max),
      );

      final json = request.toJson();
      expect(json['think'], 'max');
    });

    test('GenerateRequest deserializes ThinkLevel.max correctly', () {
      final json = {'model': 'llama3.2', 'prompt': 'Hello', 'think': 'max'};

      final request = GenerateRequest.fromJson(json);
      expect(request.think, isA<ThinkWithLevel>());
      expect((request.think! as ThinkWithLevel).level, ThinkLevel.max);
    });
  });
}
