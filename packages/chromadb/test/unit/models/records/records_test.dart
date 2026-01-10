import 'package:chromadb/chromadb.dart';
import 'package:test/test.dart';

void main() {
  group('Include', () {
    test('toApiList converts includes correctly', () {
      final includes = [
        Include.documents,
        Include.metadatas,
        Include.distances,
      ];

      final result = Include.toApiList(includes);

      expect(result, ['documents', 'metadatas', 'distances']);
    });

    test('fromValue returns correct Include for valid values', () {
      expect(Include.fromValue('documents'), Include.documents);
      expect(Include.fromValue('embeddings'), Include.embeddings);
      expect(Include.fromValue('metadatas'), Include.metadatas);
      expect(Include.fromValue('distances'), Include.distances);
      expect(Include.fromValue('uris'), Include.uris);
      expect(Include.fromValue('data'), Include.data);
    });

    test('fromValue returns null for invalid values', () {
      expect(Include.fromValue('invalid'), isNull);
      expect(Include.fromValue(''), isNull);
      expect(Include.fromValue('DOCUMENTS'), isNull); // case-sensitive
    });

    test('fromApiList parses list correctly', () {
      final values = ['documents', 'embeddings', 'metadatas'];

      final result = Include.fromApiList(values);

      expect(result, [
        Include.documents,
        Include.embeddings,
        Include.metadatas,
      ]);
    });

    test('fromApiList skips unrecognized values', () {
      final values = ['documents', 'invalid', 'embeddings', 'unknown'];

      final result = Include.fromApiList(values);

      expect(result, [Include.documents, Include.embeddings]);
    });

    test('fromApiList handles empty list', () {
      final result = Include.fromApiList([]);

      expect(result, isEmpty);
    });

    test('defaultGet contains documents and metadatas', () {
      expect(Include.defaultGet, contains(Include.documents));
      expect(Include.defaultGet, contains(Include.metadatas));
    });

    test('defaultQuery contains documents, metadatas, and distances', () {
      expect(Include.defaultQuery, contains(Include.documents));
      expect(Include.defaultQuery, contains(Include.metadatas));
      expect(Include.defaultQuery, contains(Include.distances));
    });
  });

  group('GetResponse', () {
    test('fromJson creates response with all fields', () {
      final json = {
        'ids': ['id1', 'id2'],
        'embeddings': [
          [0.1, 0.2],
          [0.3, 0.4],
        ],
        'documents': ['doc1', 'doc2'],
        'metadatas': [
          {'key': 'value1'},
          {'key': 'value2'},
        ],
        'uris': ['uri1', 'uri2'],
      };

      final response = GetResponse.fromJson(json);

      expect(response.ids, ['id1', 'id2']);
      expect(response.embeddings, [
        [0.1, 0.2],
        [0.3, 0.4],
      ]);
      expect(response.documents, ['doc1', 'doc2']);
      expect(response.metadatas, [
        {'key': 'value1'},
        {'key': 'value2'},
      ]);
      expect(response.uris, ['uri1', 'uri2']);
    });

    test('fromJson handles minimal response', () {
      final json = {
        'ids': ['id1'],
      };

      final response = GetResponse.fromJson(json);

      expect(response.ids, ['id1']);
      expect(response.embeddings, isNull);
      expect(response.documents, isNull);
      expect(response.metadatas, isNull);
      expect(response.uris, isNull);
    });

    test('fromJson handles null values in lists', () {
      final json = {
        'ids': ['id1', 'id2'],
        'documents': ['doc1', null],
        'metadatas': [
          {'key': 'value'},
          null,
        ],
      };

      final response = GetResponse.fromJson(json);

      expect(response.documents, ['doc1', null]);
      expect(response.metadatas, [
        {'key': 'value'},
        null,
      ]);
    });

    test('fromJson handles null embeddings inner elements', () {
      final json = {
        'ids': ['id1', 'id2'],
        'embeddings': [
          [0.1, 0.2],
          null, // null inner element
        ],
      };

      final response = GetResponse.fromJson(json);

      expect(response.ids, ['id1', 'id2']);
      // null inner elements become empty lists due to null-safe handling
      expect(response.embeddings, [
        [0.1, 0.2],
        <double>[], // null coalesced to empty list
      ]);
    });

    test('fromJson parses include field', () {
      final json = {
        'ids': ['id1'],
        'include': ['documents', 'embeddings', 'metadatas'],
      };

      final response = GetResponse.fromJson(json);

      expect(response.include, [
        Include.documents,
        Include.embeddings,
        Include.metadatas,
      ]);
    });

    test('fromJson handles missing include field', () {
      final json = {
        'ids': ['id1'],
      };

      final response = GetResponse.fromJson(json);

      expect(response.include, isNull);
    });

    test('toJson converts response correctly', () {
      const response = GetResponse(ids: ['id1'], documents: ['doc1']);

      final json = response.toJson();

      expect(json['ids'], ['id1']);
      expect(json['documents'], ['doc1']);
      expect(json.containsKey('embeddings'), isFalse);
    });

    test('length returns correct count', () {
      const response = GetResponse(ids: ['id1', 'id2', 'id3']);

      expect(response.length, 3);
    });

    test('isEmpty and isNotEmpty work correctly', () {
      const empty = GetResponse(ids: []);
      const notEmpty = GetResponse(ids: ['id1']);

      expect(empty.isEmpty, isTrue);
      expect(empty.isNotEmpty, isFalse);
      expect(notEmpty.isEmpty, isFalse);
      expect(notEmpty.isNotEmpty, isTrue);
    });

    test('copyWith preserves values when not specified', () {
      const original = GetResponse(
        ids: ['id1', 'id2'],
        embeddings: [
          [0.1, 0.2],
          [0.3, 0.4],
        ],
        documents: ['doc1', 'doc2'],
        metadatas: [
          {'key': 'value1'},
          {'key': 'value2'},
        ],
        uris: ['uri1', 'uri2'],
      );

      final copy = original.copyWith();

      expect(copy.ids, ['id1', 'id2']);
      expect(copy.embeddings, [
        [0.1, 0.2],
        [0.3, 0.4],
      ]);
      expect(copy.documents, ['doc1', 'doc2']);
      expect(copy.metadatas, [
        {'key': 'value1'},
        {'key': 'value2'},
      ]);
      expect(copy.uris, ['uri1', 'uri2']);
    });

    test('copyWith can set fields to null', () {
      const original = GetResponse(
        ids: ['id1'],
        embeddings: [
          [0.1],
        ],
        documents: ['doc1'],
        metadatas: [
          {'key': 'value'},
        ],
        uris: ['uri1'],
      );

      final copy = original.copyWith(
        embeddings: null,
        documents: null,
        metadatas: null,
        uris: null,
      );

      expect(copy.ids, ['id1']);
      expect(copy.embeddings, isNull);
      expect(copy.documents, isNull);
      expect(copy.metadatas, isNull);
      expect(copy.uris, isNull);
    });

    test('equality works correctly', () {
      const response1 = GetResponse(ids: ['id1'], documents: ['doc1']);
      const response2 = GetResponse(ids: ['id1'], documents: ['doc1']);
      const response3 = GetResponse(ids: ['id2'], documents: ['doc1']);

      expect(response1, equals(response2));
      expect(response1, isNot(equals(response3)));
    });

    test('hashCode is consistent with equality', () {
      const response1 = GetResponse(ids: ['id1'], documents: ['doc1']);
      const response2 = GetResponse(ids: ['id1'], documents: ['doc1']);

      expect(response1.hashCode, equals(response2.hashCode));
    });
  });

  group('QueryResponse', () {
    test('fromJson creates response with all fields', () {
      final json = {
        'ids': [
          ['id1', 'id2'],
          ['id3'],
        ],
        'embeddings': [
          [
            [0.1, 0.2],
            [0.3, 0.4],
          ],
          [
            [0.5, 0.6],
          ],
        ],
        'documents': [
          ['doc1', 'doc2'],
          ['doc3'],
        ],
        'metadatas': [
          [
            {'key': 'value1'},
            {'key': 'value2'},
          ],
          [
            {'key': 'value3'},
          ],
        ],
        'distances': [
          [0.1, 0.2],
          [0.3],
        ],
      };

      final response = QueryResponse.fromJson(json);

      expect(response.ids, [
        ['id1', 'id2'],
        ['id3'],
      ]);
      expect(response.queryCount, 2);
      expect(response.distances, [
        [0.1, 0.2],
        [0.3],
      ]);
    });

    test('fromJson handles minimal response', () {
      final json = {
        'ids': [
          ['id1'],
        ],
      };

      final response = QueryResponse.fromJson(json);

      expect(response.ids, [
        ['id1'],
      ]);
      expect(response.embeddings, isNull);
      expect(response.distances, isNull);
    });

    test('fromJson handles null inner elements in ids', () {
      final json = {
        'ids': [
          ['id1', 'id2'],
          null, // null inner list
        ],
      };

      final response = QueryResponse.fromJson(json);

      expect(response.ids, [
        ['id1', 'id2'],
        <String>[], // null coalesced to empty list
      ]);
    });

    test('fromJson handles null inner elements in embeddings', () {
      final json = {
        'ids': [
          ['id1'],
        ],
        'embeddings': [
          [
            [0.1, 0.2],
            null, // null embedding
          ],
          null, // null query result
        ],
      };

      final response = QueryResponse.fromJson(json);

      expect(response.embeddings, [
        [
          [0.1, 0.2],
          <double>[], // null coalesced to empty list
        ],
        <List<double>>[], // null query result coalesced to empty list
      ]);
    });

    test('fromJson handles null inner elements in documents', () {
      final json = {
        'ids': [
          ['id1'],
        ],
        'documents': [
          ['doc1', null], // contains null doc
          null, // null inner list
        ],
      };

      final response = QueryResponse.fromJson(json);

      expect(response.documents, [
        ['doc1', null],
        <String?>[], // null coalesced to empty list
      ]);
    });

    test('fromJson handles null inner elements in distances', () {
      final json = {
        'ids': [
          ['id1'],
        ],
        'distances': [
          [0.1, 0.2],
          null, // null inner list
        ],
      };

      final response = QueryResponse.fromJson(json);

      expect(response.distances, [
        [0.1, 0.2],
        <double>[], // null coalesced to empty list
      ]);
    });

    test('fromJson parses include field', () {
      final json = {
        'ids': [
          ['id1'],
        ],
        'include': ['documents', 'distances', 'metadatas'],
      };

      final response = QueryResponse.fromJson(json);

      expect(response.include, [
        Include.documents,
        Include.distances,
        Include.metadatas,
      ]);
    });

    test('fromJson handles missing include field', () {
      final json = {
        'ids': [
          ['id1'],
        ],
      };

      final response = QueryResponse.fromJson(json);

      expect(response.include, isNull);
    });

    test('toJson converts response correctly', () {
      const response = QueryResponse(
        ids: [
          ['id1', 'id2'],
        ],
        distances: [
          [0.1, 0.2],
        ],
      );

      final json = response.toJson();

      expect(json['ids'], [
        ['id1', 'id2'],
      ]);
      expect(json['distances'], [
        [0.1, 0.2],
      ]);
      expect(json.containsKey('embeddings'), isFalse);
    });

    test('queryCount returns correct count', () {
      const response = QueryResponse(
        ids: [
          ['id1'],
          ['id2'],
          ['id3'],
        ],
      );

      expect(response.queryCount, 3);
    });

    test('copyWith preserves values when not specified', () {
      const original = QueryResponse(
        ids: [
          ['id1', 'id2'],
        ],
        embeddings: [
          [
            [0.1, 0.2],
            [0.3, 0.4],
          ],
        ],
        documents: [
          ['doc1', 'doc2'],
        ],
        metadatas: [
          [
            {'key': 'value1'},
            {'key': 'value2'},
          ],
        ],
        distances: [
          [0.1, 0.2],
        ],
        uris: [
          ['uri1', 'uri2'],
        ],
        data: [
          ['data1', 'data2'],
        ],
      );

      final copy = original.copyWith();

      expect(copy.ids, [
        ['id1', 'id2'],
      ]);
      expect(copy.embeddings, [
        [
          [0.1, 0.2],
          [0.3, 0.4],
        ],
      ]);
      expect(copy.documents, [
        ['doc1', 'doc2'],
      ]);
      expect(copy.distances, [
        [0.1, 0.2],
      ]);
    });

    test('copyWith can set fields to null', () {
      const original = QueryResponse(
        ids: [
          ['id1'],
        ],
        embeddings: [
          [
            [0.1],
          ],
        ],
        documents: [
          ['doc1'],
        ],
        distances: [
          [0.1],
        ],
      );

      final copy = original.copyWith(
        embeddings: null,
        documents: null,
        distances: null,
      );

      expect(copy.ids, [
        ['id1'],
      ]);
      expect(copy.embeddings, isNull);
      expect(copy.documents, isNull);
      expect(copy.distances, isNull);
    });

    test('equality works correctly', () {
      const response1 = QueryResponse(
        ids: [
          ['id1'],
        ],
        distances: [
          [0.1],
        ],
      );
      const response2 = QueryResponse(
        ids: [
          ['id1'],
        ],
        distances: [
          [0.1],
        ],
      );
      const response3 = QueryResponse(
        ids: [
          ['id2'],
        ],
        distances: [
          [0.1],
        ],
      );

      expect(response1, equals(response2));
      expect(response1, isNot(equals(response3)));
    });

    test('hashCode is consistent with equality', () {
      const response1 = QueryResponse(
        ids: [
          ['id1'],
        ],
        distances: [
          [0.1],
        ],
      );
      const response2 = QueryResponse(
        ids: [
          ['id1'],
        ],
        distances: [
          [0.1],
        ],
      );

      expect(response1.hashCode, equals(response2.hashCode));
    });
  });
}
