import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('DeltaContent content', () {
    const thinking = {
      'type': 'thinking',
      'thinking': [
        {'type': 'text', 'text': 'Let me think'},
      ],
      'closed': false,
    };

    test('parses a string', () {
      final delta = DeltaContent.fromJson(const {'content': 'Hi'});
      expect(delta.content, const MessageContent.text('Hi'));
      expect(delta.toJson(), {'content': 'Hi'});
    });

    test('parses missing content as null', () {
      final delta = DeltaContent.fromJson(const {'role': 'assistant'});
      expect(delta.content, isNull);
      expect(delta.content?.text, isNull);
    });

    test('keeps a thinking-only list and has no text', () {
      final delta = DeltaContent.fromJson(const {
        'content': [thinking],
      });
      final content = delta.content! as MessagePartsContent;
      expect(content.parts.single, isA<ThinkContentPart>());
      expect(content.text, isNull);
    });

    test('reads only the answer from a transition list', () {
      final delta = DeltaContent.fromJson(const {
        'content': [
          {'type': 'thinking', 'thinking': <Object>[], 'closed': true},
          {'type': 'text', 'text': 'Hello'},
        ],
      });
      expect(delta.content?.text, 'Hello');
    });

    test('tolerates an unknown part type', () {
      final delta = DeltaContent.fromJson(const {
        'content': [
          {'type': 'something_new'},
          {'type': 'text', 'text': 'Hi'},
        ],
      });
      expect(delta.content?.text, 'Hi');
    });

    test('round-trips list content', () {
      const json = {
        'content': [
          thinking,
          {'type': 'text', 'text': 'Hi'},
        ],
      };
      final delta = DeltaContent.fromJson(json);
      expect(delta.toJson(), json);
      expect(DeltaContent.fromJson(delta.toJson()), delta);
    });
  });
}
