import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('LibraryDocument', () {
    group('constructor', () {
      test('creates with required parameters', () {
        const doc = LibraryDocument(
          id: 'doc-123',
          name: 'test.pdf',
          status: LibraryDocumentStatus.completed,
        );
        expect(doc.id, 'doc-123');
        expect(doc.name, 'test.pdf');
        expect(doc.status, LibraryDocumentStatus.completed);
        expect(doc.mimeType, isNull);
        expect(doc.size, isNull);
        expect(doc.hash, isNull);
        expect(doc.createdAt, isNull);
        expect(doc.updatedAt, isNull);
        expect(doc.numberOfPages, isNull);
        expect(doc.summary, isNull);
        expect(doc.tokensProcessingTotal, isNull);
      });

      test('creates with all parameters', () {
        const doc = LibraryDocument(
          id: 'doc-456',
          name: 'report.pdf',
          status: LibraryDocumentStatus.completed,
          mimeType: 'application/pdf',
          size: 1024000,
          hash: 'abc123def456',
          createdAt: 1703980800,
          updatedAt: 1703984400,
          numberOfPages: 25,
          summary: 'A comprehensive report on AI',
          tokensProcessingTotal: 5000,
        );
        expect(doc.mimeType, 'application/pdf');
        expect(doc.size, 1024000);
        expect(doc.hash, 'abc123def456');
        expect(doc.createdAt, 1703980800);
        expect(doc.updatedAt, 1703984400);
        expect(doc.numberOfPages, 25);
        expect(doc.summary, 'A comprehensive report on AI');
        expect(doc.tokensProcessingTotal, 5000);
      });
    });

    group('toJson', () {
      test('serializes required fields', () {
        const doc = LibraryDocument(
          id: 'doc-123',
          name: 'file.txt',
          status: LibraryDocumentStatus.running,
        );
        final json = doc.toJson();
        expect(json['id'], 'doc-123');
        expect(json['name'], 'file.txt');
        expect(json['processing_status'], 'Running');
        expect(json.containsKey('mime_type'), isFalse);
        expect(json.containsKey('size'), isFalse);
      });

      test('serializes all fields', () {
        const doc = LibraryDocument(
          id: 'doc-full',
          name: 'complete.pdf',
          status: LibraryDocumentStatus.completed,
          mimeType: 'application/pdf',
          size: 2048000,
          hash: 'hashvalue123',
          createdAt: 1703980800,
          updatedAt: 1703984400,
          numberOfPages: 50,
          summary: 'Document summary',
          tokensProcessingTotal: 10000,
        );
        final json = doc.toJson();
        expect(json['id'], 'doc-full');
        expect(json['name'], 'complete.pdf');
        expect(json['processing_status'], 'Completed');
        expect(json['mime_type'], 'application/pdf');
        expect(json['size'], 2048000);
        expect(json['hash'], 'hashvalue123');
        expect(json['created_at'], 1703980800);
        expect(json['updated_at'], 1703984400);
        expect(json['number_of_pages'], 50);
        expect(json['summary'], 'Document summary');
        expect(json['tokens_processing_total'], 10000);
      });
    });

    group('fromJson', () {
      test('deserializes correctly', () {
        final json = <String, dynamic>{
          'id': 'doc-789',
          'name': 'document.pdf',
          'processing_status': 'Completed',
          'mime_type': 'application/pdf',
          'size': 512000,
          'hash': 'xyz789',
          'created_at': 1703980800,
          'updated_at': 1703984400,
          'number_of_pages': 15,
          'summary': 'A technical document',
          'tokens_processing_total': 3500,
        };
        final doc = LibraryDocument.fromJson(json);
        expect(doc.id, 'doc-789');
        expect(doc.name, 'document.pdf');
        expect(doc.status, LibraryDocumentStatus.completed);
        expect(doc.mimeType, 'application/pdf');
        expect(doc.size, 512000);
        expect(doc.hash, 'xyz789');
        expect(doc.createdAt, 1703980800);
        expect(doc.updatedAt, 1703984400);
        expect(doc.numberOfPages, 15);
        expect(doc.summary, 'A technical document');
        expect(doc.tokensProcessingTotal, 3500);
      });

      test('handles missing optional fields', () {
        final json = <String, dynamic>{
          'id': 'doc-min',
          'name': 'minimal.txt',
          'processing_status': 'Running',
        };
        final doc = LibraryDocument.fromJson(json);
        expect(doc.id, 'doc-min');
        expect(doc.name, 'minimal.txt');
        expect(doc.status, LibraryDocumentStatus.running);
        expect(doc.mimeType, isNull);
        expect(doc.size, isNull);
      });

      test('handles empty json', () {
        final json = <String, dynamic>{};
        final doc = LibraryDocument.fromJson(json);
        expect(doc.id, '');
        expect(doc.name, '');
        expect(doc.status, LibraryDocumentStatus.unknown);
      });

      test('handles unknown status', () {
        final json = <String, dynamic>{
          'id': 'doc-1',
          'name': 'test.pdf',
          'processing_status': 'SomeNewStatus',
        };
        final doc = LibraryDocument.fromJson(json);
        expect(doc.status, LibraryDocumentStatus.unknown);
      });
    });

    group('copyWith', () {
      test('copies with changes', () {
        const original = LibraryDocument(
          id: 'doc-1',
          name: 'original.pdf',
          status: LibraryDocumentStatus.running,
          size: 1000,
        );
        final copy = original.copyWith(
          status: LibraryDocumentStatus.completed,
          numberOfPages: 10,
        );
        expect(copy.id, 'doc-1');
        expect(copy.name, 'original.pdf');
        expect(copy.status, LibraryDocumentStatus.completed);
        expect(copy.size, 1000);
        expect(copy.numberOfPages, 10);
      });

      test('copies without changes', () {
        const original = LibraryDocument(
          id: 'doc-2',
          name: 'test.pdf',
          status: LibraryDocumentStatus.completed,
        );
        final copy = original.copyWith();
        expect(copy.id, 'doc-2');
        expect(copy.name, 'test.pdf');
        expect(copy.status, LibraryDocumentStatus.completed);
      });
    });

    group('convenience getters', () {
      test('isProcessing returns true when status is running', () {
        const running = LibraryDocument(
          id: '1',
          name: 'a',
          status: LibraryDocumentStatus.running,
        );
        expect(running.isProcessing, isTrue);
        expect(running.isCompleted, isFalse);

        const completed = LibraryDocument(
          id: '2',
          name: 'b',
          status: LibraryDocumentStatus.completed,
        );
        expect(completed.isProcessing, isFalse);
        expect(completed.isCompleted, isTrue);
      });
    });

    group('equality', () {
      test('equals with same id', () {
        const doc1 = LibraryDocument(
          id: 'doc-123',
          name: 'a.pdf',
          status: LibraryDocumentStatus.running,
        );
        const doc2 = LibraryDocument(
          id: 'doc-123',
          name: 'different.pdf',
          status: LibraryDocumentStatus.completed,
        );
        expect(doc1, equals(doc2));
        expect(doc1.hashCode, doc2.hashCode);
      });

      test('not equals with different id', () {
        const doc1 = LibraryDocument(
          id: 'doc-1',
          name: 'same.pdf',
          status: LibraryDocumentStatus.completed,
        );
        const doc2 = LibraryDocument(
          id: 'doc-2',
          name: 'same.pdf',
          status: LibraryDocumentStatus.completed,
        );
        expect(doc1, isNot(equals(doc2)));
      });
    });

    group('toString', () {
      test('returns descriptive string', () {
        const doc = LibraryDocument(
          id: 'doc-xyz',
          name: 'report.pdf',
          status: LibraryDocumentStatus.completed,
        );
        expect(
          doc.toString(),
          'LibraryDocument(id: doc-xyz, name: report.pdf, status: LibraryDocumentStatus.completed)',
        );
      });
    });
  });

  group('LibraryDocumentStatus', () {
    test('has correct values', () {
      expect(LibraryDocumentStatus.running.value, 'Running');
      expect(LibraryDocumentStatus.completed.value, 'Completed');
      expect(LibraryDocumentStatus.failed.value, 'Failed');
      expect(LibraryDocumentStatus.unknown.value, 'unknown');
    });

    group('fromJson', () {
      test('parses known statuses case-insensitively', () {
        expect(
          LibraryDocumentStatus.fromJson('Running'),
          LibraryDocumentStatus.running,
        );
        expect(
          LibraryDocumentStatus.fromJson('running'),
          LibraryDocumentStatus.running,
        );
        expect(
          LibraryDocumentStatus.fromJson('RUNNING'),
          LibraryDocumentStatus.running,
        );

        expect(
          LibraryDocumentStatus.fromJson('Completed'),
          LibraryDocumentStatus.completed,
        );
        expect(
          LibraryDocumentStatus.fromJson('completed'),
          LibraryDocumentStatus.completed,
        );

        expect(
          LibraryDocumentStatus.fromJson('Failed'),
          LibraryDocumentStatus.failed,
        );
        expect(
          LibraryDocumentStatus.fromJson('failed'),
          LibraryDocumentStatus.failed,
        );
      });

      test('returns unknown for unrecognized values', () {
        expect(
          LibraryDocumentStatus.fromJson('processing'),
          LibraryDocumentStatus.unknown,
        );
        expect(
          LibraryDocumentStatus.fromJson('pending'),
          LibraryDocumentStatus.unknown,
        );
        expect(
          LibraryDocumentStatus.fromJson(''),
          LibraryDocumentStatus.unknown,
        );
      });
    });
  });

  group('LibraryDocumentList', () {
    group('constructor', () {
      test('creates with required data', () {
        const list = LibraryDocumentList(data: []);
        expect(list.data, isEmpty);
        expect(list.object, 'list');
        expect(list.total, isNull);
        expect(list.hasMore, isNull);
      });

      test('creates with all parameters', () {
        const list = LibraryDocumentList(
          object: 'list',
          data: [
            LibraryDocument(
              id: 'doc-1',
              name: 'a.pdf',
              status: LibraryDocumentStatus.completed,
            ),
            LibraryDocument(
              id: 'doc-2',
              name: 'b.pdf',
              status: LibraryDocumentStatus.running,
            ),
          ],
          total: 50,
          hasMore: true,
        );
        expect(list.data, hasLength(2));
        expect(list.total, 50);
        expect(list.hasMore, isTrue);
      });
    });

    group('toJson', () {
      test('serializes correctly', () {
        const list = LibraryDocumentList(
          data: [
            LibraryDocument(
              id: 'doc-1',
              name: 'test.pdf',
              status: LibraryDocumentStatus.completed,
            ),
          ],
          total: 10,
          hasMore: false,
        );
        final json = list.toJson();
        expect(json['object'], 'list');
        expect(json['data'], hasLength(1));
        expect(json['total'], 10);
        expect(json['has_more'], false);
      });

      test('omits null fields', () {
        const list = LibraryDocumentList(data: []);
        final json = list.toJson();
        expect(json.containsKey('total'), isFalse);
        expect(json.containsKey('has_more'), isFalse);
      });
    });

    group('fromJson', () {
      test('deserializes correctly', () {
        final json = <String, dynamic>{
          'object': 'list',
          'data': [
            {
              'id': 'doc-1',
              'name': 'first.pdf',
              'processing_status': 'Completed',
            },
            {
              'id': 'doc-2',
              'name': 'second.pdf',
              'processing_status': 'Running',
            },
          ],
          'total': 100,
          'has_more': true,
        };
        final list = LibraryDocumentList.fromJson(json);
        expect(list.data, hasLength(2));
        expect(list.data[0].id, 'doc-1');
        expect(list.data[0].status, LibraryDocumentStatus.completed);
        expect(list.data[1].id, 'doc-2');
        expect(list.data[1].status, LibraryDocumentStatus.running);
        expect(list.total, 100);
        expect(list.hasMore, isTrue);
      });

      test('handles missing data', () {
        final json = <String, dynamic>{'object': 'list'};
        final list = LibraryDocumentList.fromJson(json);
        expect(list.data, isEmpty);
      });
    });

    group('convenience getters', () {
      test('isEmpty and isNotEmpty work correctly', () {
        const empty = LibraryDocumentList(data: []);
        expect(empty.isEmpty, isTrue);
        expect(empty.isNotEmpty, isFalse);

        const nonEmpty = LibraryDocumentList(
          data: [
            LibraryDocument(
              id: 'x',
              name: 'y',
              status: LibraryDocumentStatus.completed,
            ),
          ],
        );
        expect(nonEmpty.isEmpty, isFalse);
        expect(nonEmpty.isNotEmpty, isTrue);
      });

      test('length returns count', () {
        const list = LibraryDocumentList(
          data: [
            LibraryDocument(
              id: '1',
              name: 'a.pdf',
              status: LibraryDocumentStatus.completed,
            ),
            LibraryDocument(
              id: '2',
              name: 'b.pdf',
              status: LibraryDocumentStatus.completed,
            ),
          ],
        );
        expect(list.length, 2);
      });
    });

    group('equality', () {
      test('equals with same data', () {
        const list1 = LibraryDocumentList(
          data: [
            LibraryDocument(
              id: '1',
              name: 'a',
              status: LibraryDocumentStatus.completed,
            ),
          ],
        );
        const list2 = LibraryDocumentList(
          data: [
            LibraryDocument(
              id: '1', // Same id = equal document
              name: 'b',
              status: LibraryDocumentStatus.running,
            ),
          ],
        );
        expect(list1, equals(list2));
      });

      test('not equals with different data', () {
        const list1 = LibraryDocumentList(
          data: [
            LibraryDocument(
              id: '1',
              name: 'a',
              status: LibraryDocumentStatus.completed,
            ),
          ],
        );
        const list2 = LibraryDocumentList(
          data: [
            LibraryDocument(
              id: '2', // Different id = different document
              name: 'a',
              status: LibraryDocumentStatus.completed,
            ),
          ],
        );
        expect(list1, isNot(equals(list2)));
      });

      test('not equals with different length', () {
        const list1 = LibraryDocumentList(
          data: [
            LibraryDocument(
              id: '1',
              name: 'a',
              status: LibraryDocumentStatus.completed,
            ),
          ],
        );
        const list2 = LibraryDocumentList(data: []);
        expect(list1, isNot(equals(list2)));
      });
    });

    group('toString', () {
      test('returns descriptive string', () {
        const list = LibraryDocumentList(
          data: [
            LibraryDocument(
              id: '1',
              name: 'a',
              status: LibraryDocumentStatus.completed,
            ),
          ],
          total: 25,
        );
        expect(list.toString(), 'LibraryDocumentList(count: 1, total: 25)');
      });
    });
  });

  group('LibraryDocumentContent', () {
    group('constructor', () {
      test('creates with required parameters', () {
        const content = LibraryDocumentContent(text: 'Hello world');
        expect(content.text, 'Hello world');
        expect(content.signedUrls, isNull);
      });

      test('creates with all parameters', () {
        const content = LibraryDocumentContent(
          text: 'Document content here',
          signedUrls: ['https://example.com/file1.pdf'],
        );
        expect(content.text, 'Document content here');
        expect(content.signedUrls, hasLength(1));
        expect(content.signedUrls![0], 'https://example.com/file1.pdf');
      });
    });

    group('toJson', () {
      test('serializes required fields', () {
        const content = LibraryDocumentContent(text: 'Some text');
        final json = content.toJson();
        expect(json['text'], 'Some text');
        expect(json.containsKey('signed_urls'), isFalse);
      });

      test('serializes all fields', () {
        const content = LibraryDocumentContent(
          text: 'Full content',
          signedUrls: [
            'https://example.com/a.pdf',
            'https://example.com/b.pdf',
          ],
        );
        final json = content.toJson();
        expect(json['text'], 'Full content');
        expect(json['signed_urls'], hasLength(2));
      });
    });

    group('fromJson', () {
      test('deserializes correctly', () {
        final json = <String, dynamic>{
          'text': 'Extracted document text',
          'signed_urls': [
            'https://storage.example.com/doc1.pdf',
            'https://storage.example.com/doc2.pdf',
          ],
        };
        final content = LibraryDocumentContent.fromJson(json);
        expect(content.text, 'Extracted document text');
        expect(content.signedUrls, hasLength(2));
      });

      test('handles missing optional fields', () {
        final json = <String, dynamic>{'text': 'Just text'};
        final content = LibraryDocumentContent.fromJson(json);
        expect(content.text, 'Just text');
        expect(content.signedUrls, isNull);
      });

      test('handles empty json', () {
        final json = <String, dynamic>{};
        final content = LibraryDocumentContent.fromJson(json);
        expect(content.text, '');
        expect(content.signedUrls, isNull);
      });
    });

    group('equality', () {
      test('equals with same text and signedUrls', () {
        const content1 = LibraryDocumentContent(
          text: 'Same text',
          signedUrls: ['https://example.com'],
        );
        const content2 = LibraryDocumentContent(
          text: 'Same text',
          signedUrls: ['https://example.com'],
        );
        expect(content1, equals(content2));
        expect(content1.hashCode, content2.hashCode);
      });

      test('not equals with different signedUrls', () {
        const content1 = LibraryDocumentContent(text: 'Same text');
        const content2 = LibraryDocumentContent(
          text: 'Same text',
          signedUrls: ['https://example.com'],
        );
        expect(content1, isNot(equals(content2)));
      });

      test('not equals with different text', () {
        const content1 = LibraryDocumentContent(text: 'Text A');
        const content2 = LibraryDocumentContent(text: 'Text B');
        expect(content1, isNot(equals(content2)));
      });
    });

    group('toString', () {
      test('returns descriptive string', () {
        const content = LibraryDocumentContent(
          text: 'This is a long document content that should be counted.',
        );
        expect(content.toString(), 'LibraryDocumentContent(text: 55 chars)');
      });
    });
  });
}
