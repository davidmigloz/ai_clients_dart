import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('EncryptedContent', () {
    test('round-trips through JSON', () {
      const content = EncryptedContent('opaque-blob');

      final json = content.toJson();
      expect(json, {
        'type': 'encrypted_content',
        'encrypted_content': 'opaque-blob',
      });
      expect(InputContent.fromJson(json), content);
    });

    test('dispatches via InputContent.fromJson', () {
      final content = InputContent.fromJson({
        'type': 'encrypted_content',
        'encrypted_content': 'blob',
      });
      expect(content, isA<EncryptedContent>());
    });

    test('supports equality/hashCode', () {
      const a = EncryptedContent('blob-1');
      const b = EncryptedContent('blob-1');
      const c = EncryptedContent('blob-2');

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });
  });
}
