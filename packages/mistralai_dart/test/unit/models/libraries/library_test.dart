import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Library', () {
    group('constructor', () {
      test('creates with required parameters', () {
        const library = Library(id: 'lib-123', name: 'Test Library');
        expect(library.id, 'lib-123');
        expect(library.name, 'Test Library');
        expect(library.description, isNull);
        expect(library.createdAt, isNull);
        expect(library.updatedAt, isNull);
        expect(library.ownerId, isNull);
        expect(library.ownerType, isNull);
        expect(library.totalSize, isNull);
        expect(library.nbDocuments, isNull);
      });

      test('creates with all parameters', () {
        const library = Library(
          id: 'lib-456',
          name: 'Knowledge Base',
          description: 'Technical documentation',
          createdAt: 1703980800,
          updatedAt: 1703984400,
          ownerId: 'user-abc',
          ownerType: 'user',
          totalSize: 1048576,
          nbDocuments: 10,
        );
        expect(library.description, 'Technical documentation');
        expect(library.createdAt, 1703980800);
        expect(library.updatedAt, 1703984400);
        expect(library.ownerId, 'user-abc');
        expect(library.ownerType, 'user');
        expect(library.totalSize, 1048576);
        expect(library.nbDocuments, 10);
      });
    });

    group('toJson', () {
      test('serializes required fields', () {
        const library = Library(id: 'lib-123', name: 'My Library');
        final json = library.toJson();
        expect(json['id'], 'lib-123');
        expect(json['name'], 'My Library');
        expect(json.containsKey('description'), isFalse);
        expect(json.containsKey('created_at'), isFalse);
      });

      test('serializes all fields', () {
        const library = Library(
          id: 'lib-456',
          name: 'Full Library',
          description: 'Complete example',
          createdAt: 1703980800,
          updatedAt: 1703984400,
          ownerId: 'org-123',
          ownerType: 'org',
          totalSize: 2097152,
          nbDocuments: 5,
        );
        final json = library.toJson();
        expect(json['id'], 'lib-456');
        expect(json['name'], 'Full Library');
        expect(json['description'], 'Complete example');
        expect(json['created_at'], 1703980800);
        expect(json['updated_at'], 1703984400);
        expect(json['owner_id'], 'org-123');
        expect(json['owner_type'], 'org');
        expect(json['total_size'], 2097152);
        expect(json['nb_documents'], 5);
      });
    });

    group('fromJson', () {
      test('deserializes correctly', () {
        final json = <String, dynamic>{
          'id': 'lib-789',
          'name': 'Docs Library',
          'description': 'API documentation',
          'created_at': 1703980800,
          'updated_at': 1703984400,
          'owner_id': 'user-xyz',
          'owner_type': 'user',
          'total_size': 512000,
          'nb_documents': 3,
        };
        final library = Library.fromJson(json);
        expect(library.id, 'lib-789');
        expect(library.name, 'Docs Library');
        expect(library.description, 'API documentation');
        expect(library.createdAt, 1703980800);
        expect(library.updatedAt, 1703984400);
        expect(library.ownerId, 'user-xyz');
        expect(library.ownerType, 'user');
        expect(library.totalSize, 512000);
        expect(library.nbDocuments, 3);
      });

      test('handles missing optional fields', () {
        final json = <String, dynamic>{
          'id': 'lib-minimal',
          'name': 'Minimal Library',
        };
        final library = Library.fromJson(json);
        expect(library.id, 'lib-minimal');
        expect(library.name, 'Minimal Library');
        expect(library.description, isNull);
        expect(library.createdAt, isNull);
      });

      test('handles empty json', () {
        final json = <String, dynamic>{};
        final library = Library.fromJson(json);
        expect(library.id, '');
        expect(library.name, '');
      });
    });

    group('copyWith', () {
      test('copies with changes', () {
        const original = Library(
          id: 'lib-1',
          name: 'Original',
          description: 'First description',
          nbDocuments: 5,
        );
        final copy = original.copyWith(
          name: 'Updated',
          description: 'New description',
        );
        expect(copy.id, 'lib-1');
        expect(copy.name, 'Updated');
        expect(copy.description, 'New description');
        expect(copy.nbDocuments, 5);
      });

      test('copies without changes', () {
        const original = Library(
          id: 'lib-2',
          name: 'Test',
          description: 'A library',
        );
        final copy = original.copyWith();
        expect(copy.id, 'lib-2');
        expect(copy.name, 'Test');
        expect(copy.description, 'A library');
      });
    });

    group('convenience getters', () {
      test('hasDocuments returns true when nbDocuments > 0', () {
        const withDocs = Library(id: 'lib-1', name: 'A', nbDocuments: 5);
        expect(withDocs.hasDocuments, isTrue);

        const withZeroDocs = Library(id: 'lib-2', name: 'B', nbDocuments: 0);
        expect(withZeroDocs.hasDocuments, isFalse);

        const withNullDocs = Library(id: 'lib-3', name: 'C');
        expect(withNullDocs.hasDocuments, isFalse);
      });

      test('isEmpty returns true when nbDocuments is null or 0', () {
        const empty1 = Library(id: 'lib-1', name: 'A');
        expect(empty1.isEmpty, isTrue);

        const empty2 = Library(id: 'lib-2', name: 'B', nbDocuments: 0);
        expect(empty2.isEmpty, isTrue);

        const notEmpty = Library(id: 'lib-3', name: 'C', nbDocuments: 1);
        expect(notEmpty.isEmpty, isFalse);
      });
    });

    group('equality', () {
      test('equals with same id', () {
        const lib1 = Library(id: 'lib-123', name: 'A');
        const lib2 = Library(id: 'lib-123', name: 'Different Name');
        expect(lib1, equals(lib2));
        expect(lib1.hashCode, lib2.hashCode);
      });

      test('not equals with different id', () {
        const lib1 = Library(id: 'lib-123', name: 'Same Name');
        const lib2 = Library(id: 'lib-456', name: 'Same Name');
        expect(lib1, isNot(equals(lib2)));
      });
    });

    group('toString', () {
      test('returns descriptive string', () {
        const library = Library(
          id: 'lib-xyz',
          name: 'My Library',
          nbDocuments: 10,
        );
        expect(
          library.toString(),
          'Library(id: lib-xyz, name: My Library, documents: 10)',
        );
      });

      test('handles null nbDocuments', () {
        const library = Library(id: 'lib-abc', name: 'Empty');
        expect(
          library.toString(),
          'Library(id: lib-abc, name: Empty, documents: 0)',
        );
      });
    });
  });

  group('LibraryList', () {
    group('constructor', () {
      test('creates with required data', () {
        const list = LibraryList(data: []);
        expect(list.data, isEmpty);
        expect(list.object, 'list');
        expect(list.total, isNull);
        expect(list.hasMore, isNull);
      });

      test('creates with all parameters', () {
        const list = LibraryList(
          object: 'list',
          data: [
            Library(id: 'lib-1', name: 'A'),
            Library(id: 'lib-2', name: 'B'),
          ],
          total: 10,
          hasMore: true,
        );
        expect(list.data, hasLength(2));
        expect(list.total, 10);
        expect(list.hasMore, isTrue);
      });
    });

    group('toJson', () {
      test('serializes correctly', () {
        const list = LibraryList(
          data: [Library(id: 'lib-1', name: 'Test')],
          total: 5,
          hasMore: false,
        );
        final json = list.toJson();
        expect(json['object'], 'list');
        expect(json['data'], hasLength(1));
        expect(json['total'], 5);
        expect(json['has_more'], false);
      });

      test('omits null fields', () {
        const list = LibraryList(data: []);
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
            {'id': 'lib-1', 'name': 'First'},
            {'id': 'lib-2', 'name': 'Second'},
          ],
          'total': 20,
          'has_more': true,
        };
        final list = LibraryList.fromJson(json);
        expect(list.data, hasLength(2));
        expect(list.data[0].id, 'lib-1');
        expect(list.data[1].id, 'lib-2');
        expect(list.total, 20);
        expect(list.hasMore, isTrue);
      });

      test('handles missing data', () {
        final json = <String, dynamic>{'object': 'list'};
        final list = LibraryList.fromJson(json);
        expect(list.data, isEmpty);
      });
    });

    group('convenience getters', () {
      test('isEmpty and isNotEmpty work correctly', () {
        const empty = LibraryList(data: []);
        expect(empty.isEmpty, isTrue);
        expect(empty.isNotEmpty, isFalse);

        const nonEmpty = LibraryList(
          data: [Library(id: 'x', name: 'y')],
        );
        expect(nonEmpty.isEmpty, isFalse);
        expect(nonEmpty.isNotEmpty, isTrue);
      });

      test('length returns count', () {
        const list = LibraryList(
          data: [
            Library(id: '1', name: 'A'),
            Library(id: '2', name: 'B'),
            Library(id: '3', name: 'C'),
          ],
        );
        expect(list.length, 3);
      });
    });

    group('equality', () {
      test('equals with same data', () {
        const list1 = LibraryList(
          data: [Library(id: '1', name: 'A')],
        );
        const list2 = LibraryList(
          data: [Library(id: '1', name: 'B')], // Same id = equal library
        );
        expect(list1, equals(list2));
      });

      test('not equals with different data', () {
        const list1 = LibraryList(
          data: [Library(id: '1', name: 'A')],
        );
        const list2 = LibraryList(
          data: [
            Library(id: '2', name: 'A'),
          ], // Different id = different library
        );
        expect(list1, isNot(equals(list2)));
      });

      test('not equals with different length', () {
        const list1 = LibraryList(
          data: [Library(id: '1', name: 'A')],
        );
        const list2 = LibraryList(data: []);
        expect(list1, isNot(equals(list2)));
      });
    });

    group('toString', () {
      test('returns descriptive string', () {
        const list = LibraryList(
          data: [Library(id: '1', name: 'A')],
          total: 10,
        );
        expect(list.toString(), 'LibraryList(count: 1, total: 10)');
      });
    });
  });
}
