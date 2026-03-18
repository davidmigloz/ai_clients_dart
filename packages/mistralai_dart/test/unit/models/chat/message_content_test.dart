import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('MessageContent', () {
    group('MessageTextContent', () {
      test('creates text content', () {
        const content = MessageContent.text('Hello!');
        expect(content, isA<MessageTextContent>());
        expect((content as MessageTextContent).text, 'Hello!');
      });

      test('serializes to JSON as string', () {
        const content = MessageContent.text('Hello!');
        expect(content.toJson(), 'Hello!');
      });

      test('deserializes from string', () {
        final content = MessageContent.fromJson('Hello!');
        expect(content, isA<MessageTextContent>());
        expect((content as MessageTextContent).text, 'Hello!');
      });

      test('equality works correctly', () {
        const a = MessageContent.text('Hello!');
        const b = MessageContent.text('Hello!');
        const c = MessageContent.text('Bye!');

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
        expect(a, isNot(equals(c)));
      });

      test('toString returns readable string', () {
        const content = MessageContent.text('Hello!');
        expect(content.toString(), 'MessageTextContent(Hello!)');
      });
    });

    group('MessagePartsContent', () {
      test('creates parts content', () {
        final content = MessageContent.parts([
          ContentPart.text('What is this?'),
          ContentPart.imageUrl('https://example.com/image.jpg'),
        ]);
        expect(content, isA<MessagePartsContent>());
        expect((content as MessagePartsContent).parts, hasLength(2));
      });

      test('serializes to JSON as list', () {
        final content = MessageContent.parts([
          ContentPart.text('Describe this.'),
          ContentPart.imageUrl('https://example.com/img.png'),
        ]);
        final json = content.toJson();
        expect(json, isList);
        final list = json as List;
        expect(list, hasLength(2));
        expect((list[0] as Map)['type'], 'text');
        expect((list[0] as Map)['text'], 'Describe this.');
        expect((list[1] as Map)['type'], 'image_url');
      });

      test('deserializes from list', () {
        final content = MessageContent.fromJson(const [
          {'type': 'text', 'text': 'Hello'},
          {
            'type': 'image_url',
            'image_url': {'url': 'https://example.com/img.png'},
          },
        ]);
        expect(content, isA<MessagePartsContent>());
        final parts = (content as MessagePartsContent).parts;
        expect(parts, hasLength(2));
        expect(parts[0], isA<TextContentPart>());
        expect(parts[1], isA<ImageUrlContentPart>());
      });

      test('equality works correctly', () {
        final a = MessageContent.parts([
          ContentPart.text('Hello'),
          ContentPart.imageUrl('https://example.com/img.png'),
        ]);
        final b = MessageContent.parts([
          ContentPart.text('Hello'),
          ContentPart.imageUrl('https://example.com/img.png'),
        ]);
        final c = MessageContent.parts([ContentPart.text('Different')]);

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
        expect(a, isNot(equals(c)));
      });

      test('equality fails for different length lists', () {
        final a = MessageContent.parts([ContentPart.text('Hello')]);
        final b = MessageContent.parts([
          ContentPart.text('Hello'),
          ContentPart.imageUrl('https://example.com/img.png'),
        ]);

        expect(a, isNot(equals(b)));
      });

      test('toString returns readable string', () {
        final content = MessageContent.parts([
          ContentPart.text('Hello'),
          ContentPart.imageUrl('https://example.com/img.png'),
        ]);
        expect(content.toString(), 'MessagePartsContent(2 parts)');
      });
    });

    group('fromJson', () {
      test('throws FormatException for invalid type', () {
        expect(
          () => MessageContent.fromJson(42),
          throwsA(isA<FormatException>()),
        );
      });

      test('handles empty string', () {
        final content = MessageContent.fromJson('');
        expect(content, isA<MessageTextContent>());
        expect((content as MessageTextContent).text, '');
      });

      test('handles empty list', () {
        final content = MessageContent.fromJson(const <dynamic>[]);
        expect(content, isA<MessagePartsContent>());
        expect((content as MessagePartsContent).parts, isEmpty);
      });
    });

    group('cross-type equality', () {
      test('text and parts are not equal', () {
        const text = MessageContent.text('Hello');
        final parts = MessageContent.parts([ContentPart.text('Hello')]);
        expect(text, isNot(equals(parts)));
      });
    });
  });
}
