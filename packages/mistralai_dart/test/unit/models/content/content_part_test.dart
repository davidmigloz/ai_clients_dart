import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('TextContentPart', () {
    group('constructor', () {
      test('creates with text', () {
        const part = TextContentPart('Hello, world!');

        expect(part.text, 'Hello, world!');
        expect(part.type, 'text');
      });
    });

    group('fromJson', () {
      test('deserializes text', () {
        final json = {'type': 'text', 'text': 'Hello, world!'};

        final part = TextContentPart.fromJson(json);

        expect(part.text, 'Hello, world!');
        expect(part.type, 'text');
      });

      test('defaults to empty string when text is missing', () {
        final json = {'type': 'text'};

        final part = TextContentPart.fromJson(json);

        expect(part.text, '');
      });
    });

    group('toJson', () {
      test('serializes with type and text', () {
        const part = TextContentPart('Hello');

        final json = part.toJson();

        expect(json['type'], 'text');
        expect(json['text'], 'Hello');
        expect(json.length, 2);
      });
    });

    group('copyWith', () {
      test('copies with no changes', () {
        const part = TextContentPart('Hello');

        final copy = part.copyWith();

        expect(copy, equals(part));
        expect(copy.text, 'Hello');
      });

      test('copies with new text', () {
        const part = TextContentPart('Hello');

        final copy = part.copyWith(text: 'Goodbye');

        expect(copy.text, 'Goodbye');
      });
    });

    group('equality', () {
      test('equal with same text', () {
        const part1 = TextContentPart('Hello');
        const part2 = TextContentPart('Hello');

        expect(part1, equals(part2));
      });

      test('not equal with different text', () {
        const part1 = TextContentPart('Hello');
        const part2 = TextContentPart('Goodbye');

        expect(part1, isNot(equals(part2)));
      });
    });

    test('hashCode same for equal objects', () {
      const part1 = TextContentPart('Hello');
      const part2 = TextContentPart('Hello');

      expect(part1.hashCode, equals(part2.hashCode));
    });

    test('toString returns descriptive string', () {
      const part = TextContentPart('Hello, world!');

      expect(part.toString(), contains('Hello, world!'));
      expect(part.toString(), contains('TextContentPart'));
    });
  });

  group('ImageUrlContentPart', () {
    group('constructor', () {
      test('creates with url', () {
        const part = ImageUrlContentPart('https://example.com/image.png');

        expect(part.url, 'https://example.com/image.png');
        expect(part.type, 'image_url');
      });
    });

    group('fromJson', () {
      test('deserializes from nested format', () {
        final json = {
          'type': 'image_url',
          'image_url': {'url': 'https://example.com/image.png'},
        };

        final part = ImageUrlContentPart.fromJson(json);

        expect(part.url, 'https://example.com/image.png');
        expect(part.type, 'image_url');
      });

      test('deserializes from flat format', () {
        final json = {
          'type': 'image_url',
          'image_url': 'https://example.com/image.png',
        };

        final part = ImageUrlContentPart.fromJson(json);

        expect(part.url, 'https://example.com/image.png');
      });

      test('defaults to empty string when url is missing in nested format', () {
        final json = {'type': 'image_url', 'image_url': <String, dynamic>{}};

        final part = ImageUrlContentPart.fromJson(json);

        expect(part.url, '');
      });

      test('defaults to empty string when image_url is null', () {
        final json = {'type': 'image_url'};

        final part = ImageUrlContentPart.fromJson(json);

        expect(part.url, '');
      });
    });

    group('toJson', () {
      test('serializes to nested format', () {
        const part = ImageUrlContentPart('https://example.com/image.png');

        final json = part.toJson();

        expect(json['type'], 'image_url');
        expect(json['image_url'], isA<Map<String, dynamic>>());
        expect(
          (json['image_url'] as Map<String, dynamic>)['url'],
          'https://example.com/image.png',
        );
      });
    });

    group('copyWith', () {
      test('copies with no changes', () {
        const part = ImageUrlContentPart('https://example.com/image.png');

        final copy = part.copyWith();

        expect(copy, equals(part));
        expect(copy.url, 'https://example.com/image.png');
      });

      test('copies with new url', () {
        const part = ImageUrlContentPart('https://example.com/image.png');

        final copy = part.copyWith(url: 'https://example.com/other.jpg');

        expect(copy.url, 'https://example.com/other.jpg');
      });
    });

    group('equality', () {
      test('equal with same url', () {
        const part1 = ImageUrlContentPart('https://example.com/image.png');
        const part2 = ImageUrlContentPart('https://example.com/image.png');

        expect(part1, equals(part2));
      });

      test('not equal with different url', () {
        const part1 = ImageUrlContentPart('https://example.com/a.png');
        const part2 = ImageUrlContentPart('https://example.com/b.png');

        expect(part1, isNot(equals(part2)));
      });
    });

    test('hashCode same for equal objects', () {
      const part1 = ImageUrlContentPart('https://example.com/image.png');
      const part2 = ImageUrlContentPart('https://example.com/image.png');

      expect(part1.hashCode, equals(part2.hashCode));
    });

    test('toString returns descriptive string', () {
      const part = ImageUrlContentPart('https://example.com/image.png');

      expect(part.toString(), contains('https://example.com/image.png'));
      expect(part.toString(), contains('ImageUrlContentPart'));
    });
  });

  group('ContentPart.fromJson', () {
    test('dispatches to TextContentPart for type "text"', () {
      final json = {'type': 'text', 'text': 'Hello'};

      final part = ContentPart.fromJson(json);

      expect(part, isA<TextContentPart>());
      expect((part as TextContentPart).text, 'Hello');
    });

    test('dispatches to ImageUrlContentPart for type "image_url"', () {
      final json = {
        'type': 'image_url',
        'image_url': {'url': 'https://example.com/image.png'},
      };

      final part = ContentPart.fromJson(json);

      expect(part, isA<ImageUrlContentPart>());
      expect(
        (part as ImageUrlContentPart).url,
        'https://example.com/image.png',
      );
    });

    test('throws FormatException for unknown type', () {
      final json = {'type': 'audio', 'audio': 'data'};

      expect(() => ContentPart.fromJson(json), throwsA(isA<FormatException>()));
    });

    test('throws FormatException for null type', () {
      final json = {'text': 'Hello'};

      expect(() => ContentPart.fromJson(json), throwsA(isA<FormatException>()));
    });
  });

  group('ContentPart factory constructors', () {
    test('ContentPart.text creates TextContentPart', () {
      final part = ContentPart.text('Hello');

      expect(part, isA<TextContentPart>());
      expect((part as TextContentPart).text, 'Hello');
    });

    test('ContentPart.imageUrl creates ImageUrlContentPart', () {
      final part = ContentPart.imageUrl('https://example.com/image.png');

      expect(part, isA<ImageUrlContentPart>());
      expect(
        (part as ImageUrlContentPart).url,
        'https://example.com/image.png',
      );
    });
  });
}
