import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('TextOutputContent', () {
    test('round-trips through JSON', () {
      const content = TextOutputContent('hello');

      final json = content.toJson();
      expect(json, {'type': 'text', 'text': 'hello'});
      expect(OutputContent.fromJson(json), content);
    });

    test('supports equality/hashCode', () {
      const a = TextOutputContent('hi');
      const b = TextOutputContent('hi');
      const c = TextOutputContent('bye');

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });
  });

  group('InputImageOutputContent', () {
    test('round-trips through JSON with URL', () {
      const content = InputImageOutputContent(
        imageUrl: 'https://example.com/image.png',
        detail: ImageDetail.high,
      );

      final json = content.toJson();
      expect(json, {
        'type': 'input_image',
        'image_url': 'https://example.com/image.png',
        'detail': 'high',
      });
      expect(OutputContent.fromJson(json), content);
    });

    test('round-trips through JSON with file ID', () {
      const content = InputImageOutputContent(fileId: 'file_123');

      final json = content.toJson();
      expect(json, {'type': 'input_image', 'file_id': 'file_123'});
      expect(OutputContent.fromJson(json), content);
    });

    test('supports equality/hashCode', () {
      const a = InputImageOutputContent(fileId: 'file_1');
      const b = InputImageOutputContent(fileId: 'file_1');
      const c = InputImageOutputContent(fileId: 'file_2');

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });
  });

  group('ComputerScreenshotOutputContent', () {
    test('round-trips through JSON', () {
      const content = ComputerScreenshotOutputContent(
        imageUrl: 'https://example.com/screenshot.png',
        detail: ImageDetail.auto,
      );

      final json = content.toJson();
      expect(json, {
        'type': 'computer_screenshot',
        'image_url': 'https://example.com/screenshot.png',
        'detail': 'auto',
      });
      expect(OutputContent.fromJson(json), content);
    });

    test('supports equality/hashCode', () {
      const a = ComputerScreenshotOutputContent(fileId: 'file_1');
      const b = ComputerScreenshotOutputContent(fileId: 'file_1');
      const c = ComputerScreenshotOutputContent(fileId: 'file_2');

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });
  });

  group('InputFileOutputContent', () {
    test('round-trips through JSON', () {
      const content = InputFileOutputContent(
        fileUrl: 'https://example.com/doc.pdf',
        filename: 'doc.pdf',
        detail: FileInputDetail.high,
      );

      final json = content.toJson();
      expect(json, {
        'type': 'input_file',
        'file_url': 'https://example.com/doc.pdf',
        'filename': 'doc.pdf',
        'detail': 'high',
      });
      expect(OutputContent.fromJson(json), content);
    });

    test('supports equality/hashCode', () {
      const a = InputFileOutputContent(fileId: 'file_1');
      const b = InputFileOutputContent(fileId: 'file_1');
      const c = InputFileOutputContent(fileId: 'file_2');

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });
  });

  group('EncryptedOutputContent', () {
    test('round-trips through JSON', () {
      const content = EncryptedOutputContent('opaque-blob');

      final json = content.toJson();
      expect(json, {
        'type': 'encrypted_content',
        'encrypted_content': 'opaque-blob',
      });
      expect(OutputContent.fromJson(json), content);
    });

    test('supports equality/hashCode', () {
      const a = EncryptedOutputContent('blob-1');
      const b = EncryptedOutputContent('blob-1');
      const c = EncryptedOutputContent('blob-2');

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });
  });

  group('OutputContent.fromJson', () {
    test('throws FormatException for unknown type', () {
      expect(
        () => OutputContent.fromJson({'type': 'bogus'}),
        throwsFormatException,
      );
    });
  });
}
