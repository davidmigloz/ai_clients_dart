import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('OcrRequest', () {
    group('constructor', () {
      test('creates request with required fields', () {
        const request = OcrRequest(
          document: UrlDocument('https://example.com/doc.pdf'),
        );

        expect(request.model, 'mistral-ocr-latest');
        expect(request.document, isA<UrlDocument>());
        expect(request.id, isNull);
        expect(request.pages, isNull);
        expect(request.includeImageBase64, isNull);
      });

      test('creates request with all fields', () {
        const request = OcrRequest(
          model: 'custom-ocr-model',
          document: FileDocument('file-123'),
          id: 'req-001',
          pages: [0, 1, 2],
          includeImageBase64: true,
          imageLimit: 10,
          imageMinSize: 100,
        );

        expect(request.model, 'custom-ocr-model');
        expect(request.document, isA<FileDocument>());
        expect(request.id, 'req-001');
        expect(request.pages, [0, 1, 2]);
        expect(request.includeImageBase64, isTrue);
        expect(request.imageLimit, 10);
        expect(request.imageMinSize, 100);
      });
    });

    group('factory constructors', () {
      test('fromUrl creates URL document', () {
        final request = OcrRequest.fromUrl(url: 'https://example.com/doc.pdf');

        expect(request.document, isA<UrlDocument>());
        expect(
          (request.document as UrlDocument).url,
          'https://example.com/doc.pdf',
        );
      });

      test('fromFile creates file document', () {
        final request = OcrRequest.fromFile(
          fileId: 'file-456',
          pages: const [0],
        );

        expect(request.document, isA<FileDocument>());
        expect((request.document as FileDocument).fileId, 'file-456');
        expect(request.pages, [0]);
      });

      test('fromBase64 creates base64 document', () {
        final request = OcrRequest.fromBase64(
          data: 'base64data',
          mimeType: 'application/pdf',
        );

        expect(request.document, isA<Base64Document>());
        expect((request.document as Base64Document).data, 'base64data');
        expect(
          (request.document as Base64Document).mimeType,
          'application/pdf',
        );
      });
    });

    group('toJson', () {
      test('serializes minimal request', () {
        const request = OcrRequest(
          document: UrlDocument('https://example.com/doc.pdf'),
        );

        final json = request.toJson();

        expect(json['model'], 'mistral-ocr-latest');
        expect(json['document'], isA<Map<String, dynamic>>());
        final document = json['document'] as Map<String, dynamic>;
        expect(document['document_url'], 'https://example.com/doc.pdf');
        expect(json.containsKey('id'), isFalse);
        expect(json.containsKey('pages'), isFalse);
      });

      test('serializes full request', () {
        const request = OcrRequest(
          model: 'custom-model',
          document: FileDocument('file-123'),
          id: 'req-001',
          pages: [1, 2, 3],
          includeImageBase64: true,
          imageLimit: 5,
          imageMinSize: 50,
        );

        final json = request.toJson();

        expect(json['model'], 'custom-model');
        final document = json['document'] as Map<String, dynamic>;
        expect(document['file_id'], 'file-123');
        expect(json['id'], 'req-001');
        expect(json['pages'], [1, 2, 3]);
        expect(json['include_image_base64'], true);
        expect(json['image_limit'], 5);
        expect(json['image_min_size'], 50);
      });
    });

    group('fromJson', () {
      test('parses request', () {
        final json = {
          'model': 'mistral-ocr-latest',
          'document': {
            'type': 'document_url',
            'document_url': 'https://example.com/doc.pdf',
          },
          'id': 'req-123',
          'pages': [0, 1],
          'include_image_base64': true,
        };

        final request = OcrRequest.fromJson(json);

        expect(request.model, 'mistral-ocr-latest');
        expect(request.document, isA<UrlDocument>());
        expect(request.id, 'req-123');
        expect(request.pages, [0, 1]);
        expect(request.includeImageBase64, isTrue);
      });
    });

    group('copyWith', () {
      test('copies with new values', () {
        const original = OcrRequest(
          document: UrlDocument('https://example.com/doc.pdf'),
        );

        final copy = original.copyWith(model: 'new-model', pages: [1, 2]);

        expect(copy.model, 'new-model');
        expect(copy.document, equals(original.document));
        expect(copy.pages, [1, 2]);
      });

      test('preserves values when not specified', () {
        const original = OcrRequest(
          model: 'custom-model',
          document: FileDocument('file-123'),
          id: 'req-001',
          pages: [0],
          includeImageBase64: true,
        );

        final copy = original.copyWith();

        expect(copy.model, 'custom-model');
        expect(copy.id, 'req-001');
        expect(copy.pages, [0]);
        expect(copy.includeImageBase64, isTrue);
      });
    });

    group('equality', () {
      test('requests with same model and document are equal', () {
        const request1 = OcrRequest(
          document: UrlDocument('https://example.com/doc.pdf'),
        );
        const request2 = OcrRequest(
          document: UrlDocument('https://example.com/doc.pdf'),
          pages: [0, 1], // Different but not part of equality
        );

        expect(request1, equals(request2));
        expect(request1.hashCode, equals(request2.hashCode));
      });

      test('requests with different documents are not equal', () {
        const request1 = OcrRequest(
          document: UrlDocument('https://example.com/doc1.pdf'),
        );
        const request2 = OcrRequest(
          document: UrlDocument('https://example.com/doc2.pdf'),
        );

        expect(request1, isNot(equals(request2)));
      });
    });
  });
}
