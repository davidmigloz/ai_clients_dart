import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('OcrDocument', () {
    group('UrlDocument', () {
      test('creates from factory', () {
        const doc = OcrDocument.url('https://example.com/doc.pdf');

        expect(doc, isA<UrlDocument>());
        expect((doc as UrlDocument).url, 'https://example.com/doc.pdf');
      });

      test('serializes to JSON', () {
        const doc = UrlDocument('https://example.com/doc.pdf');

        final json = doc.toJson();

        expect(json['type'], 'document_url');
        expect(json['document_url'], 'https://example.com/doc.pdf');
      });

      test('equality works correctly', () {
        const doc1 = UrlDocument('https://example.com/doc.pdf');
        const doc2 = UrlDocument('https://example.com/doc.pdf');
        const doc3 = UrlDocument('https://other.com/doc.pdf');

        expect(doc1, equals(doc2));
        expect(doc1.hashCode, equals(doc2.hashCode));
        expect(doc1, isNot(equals(doc3)));
      });
    });

    group('Base64Document', () {
      test('creates from factory', () {
        const doc = OcrDocument.base64(
          data: 'base64data',
          mimeType: 'application/pdf',
        );

        expect(doc, isA<Base64Document>());
        expect((doc as Base64Document).data, 'base64data');
        expect(doc.mimeType, 'application/pdf');
      });

      test('serializes to JSON', () {
        const doc = Base64Document(data: 'base64data', mimeType: 'image/png');

        final json = doc.toJson();

        expect(json['type'], 'base64');
        expect(json['data'], 'base64data');
        expect(json['mime_type'], 'image/png');
      });

      test('equality works correctly', () {
        const doc1 = Base64Document(data: 'data', mimeType: 'application/pdf');
        const doc2 = Base64Document(data: 'data', mimeType: 'application/pdf');
        const doc3 = Base64Document(data: 'other', mimeType: 'application/pdf');

        expect(doc1, equals(doc2));
        expect(doc1.hashCode, equals(doc2.hashCode));
        expect(doc1, isNot(equals(doc3)));
      });
    });

    group('FileDocument', () {
      test('creates from factory', () {
        const doc = OcrDocument.file('file-123');

        expect(doc, isA<FileDocument>());
        expect((doc as FileDocument).fileId, 'file-123');
      });

      test('serializes to JSON', () {
        const doc = FileDocument('file-456');

        final json = doc.toJson();

        expect(json['type'], 'file');
        expect(json['file_id'], 'file-456');
      });

      test('equality works correctly', () {
        const doc1 = FileDocument('file-123');
        const doc2 = FileDocument('file-123');
        const doc3 = FileDocument('file-456');

        expect(doc1, equals(doc2));
        expect(doc1.hashCode, equals(doc2.hashCode));
        expect(doc1, isNot(equals(doc3)));
      });
    });

    group('fromJson', () {
      test('parses URL document with type field', () {
        final json = {
          'type': 'document_url',
          'document_url': 'https://example.com/doc.pdf',
        };

        final doc = OcrDocument.fromJson(json);

        expect(doc, isA<UrlDocument>());
        expect((doc as UrlDocument).url, 'https://example.com/doc.pdf');
      });

      test('parses base64 document with type field', () {
        final json = {
          'type': 'base64',
          'data': 'encoded-data',
          'mime_type': 'image/jpeg',
        };

        final doc = OcrDocument.fromJson(json);

        expect(doc, isA<Base64Document>());
        expect((doc as Base64Document).data, 'encoded-data');
        expect(doc.mimeType, 'image/jpeg');
      });

      test('parses file document with type field', () {
        final json = {'type': 'file', 'file_id': 'file-789'};

        final doc = OcrDocument.fromJson(json);

        expect(doc, isA<FileDocument>());
        expect((doc as FileDocument).fileId, 'file-789');
      });

      test('infers URL document from fields', () {
        final json = {'document_url': 'https://example.com/doc.pdf'};

        final doc = OcrDocument.fromJson(json);

        expect(doc, isA<UrlDocument>());
      });

      test('infers file document from fields', () {
        final json = {'file_id': 'file-abc'};

        final doc = OcrDocument.fromJson(json);

        expect(doc, isA<FileDocument>());
      });

      test('infers base64 document from fields', () {
        final json = {
          'data': 'encoded-content',
          'mime_type': 'application/pdf',
        };

        final doc = OcrDocument.fromJson(json);

        expect(doc, isA<Base64Document>());
      });

      test('throws for unknown type', () {
        final json = {'type': 'unknown'};

        expect(
          () => OcrDocument.fromJson(json),
          throwsA(isA<FormatException>()),
        );
      });
    });
  });
}
