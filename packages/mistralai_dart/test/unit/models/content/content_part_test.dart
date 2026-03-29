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

  group('DocumentUrlContentPart', () {
    test('creates with required fields', () {
      const part = DocumentUrlContentPart(
        documentUrl: 'https://example.com/doc.pdf',
      );
      expect(part.type, 'document_url');
      expect(part.documentUrl, 'https://example.com/doc.pdf');
      expect(part.documentName, isNull);
    });

    test('creates with all fields', () {
      const part = DocumentUrlContentPart(
        documentUrl: 'https://example.com/doc.pdf',
        documentName: 'My Document',
      );
      expect(part.documentUrl, 'https://example.com/doc.pdf');
      expect(part.documentName, 'My Document');
    });

    test('serializes to JSON', () {
      const part = DocumentUrlContentPart(
        documentUrl: 'https://example.com/doc.pdf',
        documentName: 'My Doc',
      );
      final json = part.toJson();
      expect(json['type'], 'document_url');
      expect(json['document_url'], 'https://example.com/doc.pdf');
      expect(json['document_name'], 'My Doc');
    });

    test('omits null documentName in JSON', () {
      const part = DocumentUrlContentPart(
        documentUrl: 'https://example.com/doc.pdf',
      );
      final json = part.toJson();
      expect(json.containsKey('document_name'), isFalse);
    });

    test('deserializes from JSON', () {
      final part = ContentPart.fromJson(const {
        'type': 'document_url',
        'document_url': 'https://example.com/doc.pdf',
        'document_name': 'My Doc',
      });
      expect(part, isA<DocumentUrlContentPart>());
      final docPart = part as DocumentUrlContentPart;
      expect(docPart.documentUrl, 'https://example.com/doc.pdf');
      expect(docPart.documentName, 'My Doc');
    });

    test('equality works correctly', () {
      const part1 = DocumentUrlContentPart(
        documentUrl: 'https://example.com/doc.pdf',
      );
      const part2 = DocumentUrlContentPart(
        documentUrl: 'https://example.com/doc.pdf',
      );
      const part3 = DocumentUrlContentPart(
        documentUrl: 'https://example.com/other.pdf',
      );

      expect(part1, equals(part2));
      expect(part1.hashCode, equals(part2.hashCode));
      expect(part1, isNot(equals(part3)));
    });

    test('round-trip serialization', () {
      const original = DocumentUrlContentPart(
        documentUrl: 'https://example.com/doc.pdf',
        documentName: 'My Doc',
      );
      final json = original.toJson();
      final restored = ContentPart.fromJson(json) as DocumentUrlContentPart;
      expect(restored, equals(original));
    });
  });

  group('ReferenceContentPart', () {
    test('creates with reference IDs', () {
      const part = ReferenceContentPart(referenceIds: [1, 2, 3]);
      expect(part.type, 'reference');
      expect(part.referenceIds, [1, 2, 3]);
    });

    test('serializes to JSON', () {
      const part = ReferenceContentPart(referenceIds: [1, 2]);
      final json = part.toJson();
      expect(json['type'], 'reference');
      expect(json['reference_ids'], [1, 2]);
    });

    test('deserializes from JSON', () {
      final part = ContentPart.fromJson(const {
        'type': 'reference',
        'reference_ids': [1, 2, 3],
      });
      expect(part, isA<ReferenceContentPart>());
      expect((part as ReferenceContentPart).referenceIds, [1, 2, 3]);
    });

    test('equality works correctly', () {
      const part1 = ReferenceContentPart(referenceIds: [1, 2]);
      const part2 = ReferenceContentPart(referenceIds: [1, 2]);
      const part3 = ReferenceContentPart(referenceIds: [3, 4]);

      expect(part1, equals(part2));
      expect(part1.hashCode, equals(part2.hashCode));
      expect(part1, isNot(equals(part3)));
    });

    test('round-trip serialization', () {
      const original = ReferenceContentPart(referenceIds: [1, 2, 3]);
      final json = original.toJson();
      final restored = ContentPart.fromJson(json) as ReferenceContentPart;
      expect(restored, equals(original));
    });
  });

  group('FileContentPart', () {
    test('creates with file ID', () {
      const part = FileContentPart(fileId: 'file-123');
      expect(part.type, 'file');
      expect(part.fileId, 'file-123');
    });

    test('serializes to JSON', () {
      const part = FileContentPart(fileId: 'file-123');
      final json = part.toJson();
      expect(json['type'], 'file');
      expect(json['file_id'], 'file-123');
    });

    test('deserializes from JSON', () {
      final part = ContentPart.fromJson(const {
        'type': 'file',
        'file_id': 'file-123',
      });
      expect(part, isA<FileContentPart>());
      expect((part as FileContentPart).fileId, 'file-123');
    });

    test('equality works correctly', () {
      const part1 = FileContentPart(fileId: 'file-a');
      const part2 = FileContentPart(fileId: 'file-a');
      const part3 = FileContentPart(fileId: 'file-b');

      expect(part1, equals(part2));
      expect(part1.hashCode, equals(part2.hashCode));
      expect(part1, isNot(equals(part3)));
    });

    test('round-trip serialization', () {
      const original = FileContentPart(fileId: 'file-123');
      final json = original.toJson();
      final restored = ContentPart.fromJson(json) as FileContentPart;
      expect(restored, equals(original));
    });
  });

  group('AudioContentPart', () {
    test('creates with input audio', () {
      const part = AudioContentPart(inputAudio: 'base64audio');
      expect(part.type, 'input_audio');
      expect(part.inputAudio, 'base64audio');
    });

    test('serializes to JSON', () {
      const part = AudioContentPart(inputAudio: 'base64audio');
      final json = part.toJson();
      expect(json['type'], 'input_audio');
      expect(json['input_audio'], 'base64audio');
    });

    test('deserializes from JSON', () {
      final part = ContentPart.fromJson(const {
        'type': 'input_audio',
        'input_audio': 'base64audio',
      });
      expect(part, isA<AudioContentPart>());
      expect((part as AudioContentPart).inputAudio, 'base64audio');
    });

    test('equality works correctly', () {
      const part1 = AudioContentPart(inputAudio: 'audio-a');
      const part2 = AudioContentPart(inputAudio: 'audio-a');
      const part3 = AudioContentPart(inputAudio: 'audio-b');

      expect(part1, equals(part2));
      expect(part1.hashCode, equals(part2.hashCode));
      expect(part1, isNot(equals(part3)));
    });

    test('round-trip serialization', () {
      const original = AudioContentPart(inputAudio: 'base64audio');
      final json = original.toJson();
      final restored = ContentPart.fromJson(json) as AudioContentPart;
      expect(restored, equals(original));
    });
  });

  group('ThinkContentPart', () {
    test('creates with thinking content', () {
      const part = ThinkContentPart(
        thinking: [TextContentPart('reasoning')],
        closed: true,
      );
      expect(part.type, 'thinking');
      expect(part.thinking, hasLength(1));
      expect(part.closed, true);
    });

    test('serializes to JSON', () {
      const part = ThinkContentPart(
        thinking: [TextContentPart('reasoning')],
        closed: true,
      );
      final json = part.toJson();
      expect(json['type'], 'thinking');
      expect(json['thinking'], isList);
      expect((json['thinking'] as List).length, 1);
      expect(json['closed'], true);
    });

    test('deserializes from JSON', () {
      final part = ContentPart.fromJson(const {
        'type': 'thinking',
        'thinking': [
          {'type': 'text', 'text': 'reasoning'},
        ],
        'closed': true,
      });
      expect(part, isA<ThinkContentPart>());
      final thinkPart = part as ThinkContentPart;
      expect(thinkPart.thinking, hasLength(1));
      expect((thinkPart.thinking.first as TextContentPart).text, 'reasoning');
      expect(thinkPart.closed, true);
    });

    test('equality works correctly', () {
      const part1 = ThinkContentPart(
        thinking: [TextContentPart('a')],
        closed: true,
      );
      const part2 = ThinkContentPart(
        thinking: [TextContentPart('a')],
        closed: true,
      );
      const part3 = ThinkContentPart(
        thinking: [TextContentPart('b')],
        closed: true,
      );

      expect(part1, equals(part2));
      expect(part1.hashCode, equals(part2.hashCode));
      expect(part1, isNot(equals(part3)));
    });

    test('round-trip serialization', () {
      const original = ThinkContentPart(
        thinking: [TextContentPart('deep thought')],
        closed: false,
      );
      final json = original.toJson();
      final restored = ContentPart.fromJson(json) as ThinkContentPart;
      expect(restored, equals(original));
    });
  });

  group('ToolFileContentPart', () {
    test('creates with required fields', () {
      const part = ToolFileContentPart(tool: 'code_interpreter', fileId: 'f-1');
      expect(part.type, 'tool_file');
      expect(part.tool, 'code_interpreter');
      expect(part.fileId, 'f-1');
      expect(part.fileName, isNull);
      expect(part.fileType, isNull);
    });

    test('creates with all fields', () {
      const part = ToolFileContentPart(
        tool: 'code_interpreter',
        fileId: 'f-1',
        fileName: 'output.png',
        fileType: 'image/png',
      );
      expect(part.fileName, 'output.png');
      expect(part.fileType, 'image/png');
    });

    test('serializes to JSON', () {
      const part = ToolFileContentPart(
        tool: 'code_interpreter',
        fileId: 'f-1',
        fileName: 'output.png',
        fileType: 'image/png',
      );
      final json = part.toJson();
      expect(json['type'], 'tool_file');
      expect(json['tool'], 'code_interpreter');
      expect(json['file_id'], 'f-1');
      expect(json['file_name'], 'output.png');
      expect(json['file_type'], 'image/png');
    });

    test('omits null optional fields in JSON', () {
      const part = ToolFileContentPart(tool: 'code_interpreter', fileId: 'f-1');
      final json = part.toJson();
      expect(json.containsKey('file_name'), isFalse);
      expect(json.containsKey('file_type'), isFalse);
    });

    test('deserializes from JSON', () {
      final part = ContentPart.fromJson(const {
        'type': 'tool_file',
        'tool': 'code_interpreter',
        'file_id': 'f-1',
        'file_name': 'output.png',
      });
      expect(part, isA<ToolFileContentPart>());
      final toolFile = part as ToolFileContentPart;
      expect(toolFile.tool, 'code_interpreter');
      expect(toolFile.fileId, 'f-1');
      expect(toolFile.fileName, 'output.png');
      expect(toolFile.fileType, isNull);
    });

    test('copyWith preserves values when no arguments', () {
      const part = ToolFileContentPart(
        tool: 'code_interpreter',
        fileId: 'f-1',
        fileName: 'output.png',
      );
      final copy = part.copyWith();
      expect(copy, equals(part));
    });

    test('copyWith replaces values', () {
      const part = ToolFileContentPart(
        tool: 'code_interpreter',
        fileId: 'f-1',
        fileName: 'output.png',
      );
      final copy = part.copyWith(fileId: 'f-2', fileName: null);
      expect(copy.fileId, 'f-2');
      expect(copy.fileName, isNull);
    });

    test('equality works correctly', () {
      const part1 = ToolFileContentPart(tool: 'ci', fileId: 'f-1');
      const part2 = ToolFileContentPart(tool: 'ci', fileId: 'f-1');
      const part3 = ToolFileContentPart(tool: 'ci', fileId: 'f-2');

      expect(part1, equals(part2));
      expect(part1.hashCode, equals(part2.hashCode));
      expect(part1, isNot(equals(part3)));
    });

    test('round-trip serialization', () {
      const original = ToolFileContentPart(
        tool: 'code_interpreter',
        fileId: 'f-1',
        fileName: 'output.png',
        fileType: 'image/png',
      );
      final json = original.toJson();
      final restored = ContentPart.fromJson(json) as ToolFileContentPart;
      expect(restored, equals(original));
    });
  });

  group('ToolReferenceContentPart', () {
    test('creates with required fields', () {
      const part = ToolReferenceContentPart(
        tool: 'web_search',
        title: 'Example',
      );
      expect(part.type, 'tool_reference');
      expect(part.tool, 'web_search');
      expect(part.title, 'Example');
      expect(part.url, isNull);
      expect(part.description, isNull);
      expect(part.favicon, isNull);
    });

    test('creates with all fields', () {
      const part = ToolReferenceContentPart(
        tool: 'web_search',
        title: 'Example',
        url: 'https://example.com',
        description: 'A description',
        favicon: 'https://example.com/favicon.ico',
      );
      expect(part.url, 'https://example.com');
      expect(part.description, 'A description');
      expect(part.favicon, 'https://example.com/favicon.ico');
    });

    test('serializes to JSON', () {
      const part = ToolReferenceContentPart(
        tool: 'web_search',
        title: 'Example',
        url: 'https://example.com',
        description: 'A description',
        favicon: 'https://example.com/favicon.ico',
      );
      final json = part.toJson();
      expect(json['type'], 'tool_reference');
      expect(json['tool'], 'web_search');
      expect(json['title'], 'Example');
      expect(json['url'], 'https://example.com');
      expect(json['description'], 'A description');
      expect(json['favicon'], 'https://example.com/favicon.ico');
    });

    test('omits null optional fields in JSON', () {
      const part = ToolReferenceContentPart(
        tool: 'web_search',
        title: 'Example',
      );
      final json = part.toJson();
      expect(json.containsKey('url'), isFalse);
      expect(json.containsKey('description'), isFalse);
      expect(json.containsKey('favicon'), isFalse);
    });

    test('deserializes from JSON', () {
      final part = ContentPart.fromJson(const {
        'type': 'tool_reference',
        'tool': 'web_search',
        'title': 'Example',
        'url': 'https://example.com',
      });
      expect(part, isA<ToolReferenceContentPart>());
      final toolRef = part as ToolReferenceContentPart;
      expect(toolRef.tool, 'web_search');
      expect(toolRef.title, 'Example');
      expect(toolRef.url, 'https://example.com');
      expect(toolRef.description, isNull);
    });

    test('copyWith preserves values when no arguments', () {
      const part = ToolReferenceContentPart(
        tool: 'web_search',
        title: 'Example',
        url: 'https://example.com',
      );
      final copy = part.copyWith();
      expect(copy, equals(part));
    });

    test('copyWith replaces values and clears nullable fields', () {
      const part = ToolReferenceContentPart(
        tool: 'web_search',
        title: 'Example',
        url: 'https://example.com',
        description: 'desc',
      );
      final copy = part.copyWith(title: 'New', url: null, description: null);
      expect(copy.title, 'New');
      expect(copy.url, isNull);
      expect(copy.description, isNull);
    });

    test('equality works correctly', () {
      const part1 = ToolReferenceContentPart(tool: 'web_search', title: 'A');
      const part2 = ToolReferenceContentPart(tool: 'web_search', title: 'A');
      const part3 = ToolReferenceContentPart(tool: 'web_search', title: 'B');

      expect(part1, equals(part2));
      expect(part1.hashCode, equals(part2.hashCode));
      expect(part1, isNot(equals(part3)));
    });

    test('round-trip serialization', () {
      const original = ToolReferenceContentPart(
        tool: 'web_search',
        title: 'Example',
        url: 'https://example.com',
        description: 'A description',
        favicon: 'https://example.com/favicon.ico',
      );
      final json = original.toJson();
      final restored = ContentPart.fromJson(json) as ToolReferenceContentPart;
      expect(restored, equals(original));
    });
  });

  group('UnknownContentPart', () {
    test('wraps unknown type', () {
      final part = ContentPart.fromJson(const {
        'type': 'future_type',
        'data': 'some-data',
      });
      expect(part, isA<UnknownContentPart>());
      expect(part.type, 'future_type');
      expect((part as UnknownContentPart).raw['data'], 'some-data');
    });

    test('round-trips raw JSON', () {
      const json = {'type': 'future_type', 'data': 'some-data'};
      final part = ContentPart.fromJson(json);
      expect(part.toJson(), json);
    });

    test('handles null type', () {
      final part = ContentPart.fromJson(const {'text': 'Hello'});
      expect(part, isA<UnknownContentPart>());
      expect(part.type, 'unknown');
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

    test('returns UnknownContentPart for unknown type', () {
      final json = {'type': 'audio', 'audio': 'data'};

      final part = ContentPart.fromJson(json);

      expect(part, isA<UnknownContentPart>());
    });

    test('returns UnknownContentPart for null type', () {
      final json = {'text': 'Hello'};

      final part = ContentPart.fromJson(json);

      expect(part, isA<UnknownContentPart>());
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
