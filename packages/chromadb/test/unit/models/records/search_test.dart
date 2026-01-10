import 'package:chromadb/chromadb.dart';
import 'package:test/test.dart';

void main() {
  group('SearchFilter', () {
    test('fromJson creates filter with all fields', () {
      final json = {
        'query_ids': ['id1', 'id2'],
        'where_clause': {'type': 'test'},
      };

      final filter = SearchFilter.fromJson(json);

      expect(filter.queryIds, ['id1', 'id2']);
      expect(filter.whereClause, {'type': 'test'});
    });

    test('fromJson handles null fields', () {
      final json = <String, dynamic>{};

      final filter = SearchFilter.fromJson(json);

      expect(filter.queryIds, isNull);
      expect(filter.whereClause, isNull);
    });

    test('toJson converts filter correctly', () {
      const filter = SearchFilter(
        queryIds: ['id1'],
        whereClause: {'key': 'value'},
      );

      final json = filter.toJson();

      expect(json['query_ids'], ['id1']);
      expect(json['where_clause'], {'key': 'value'});
    });

    test('toJson omits null fields', () {
      const filter = SearchFilter();

      final json = filter.toJson();

      expect(json.containsKey('query_ids'), isFalse);
      expect(json.containsKey('where_clause'), isFalse);
    });

    test('copyWith preserves values when not specified', () {
      const original = SearchFilter(
        queryIds: ['id1'],
        whereClause: {'key': 'value'},
      );

      final copy = original.copyWith();

      expect(copy.queryIds, ['id1']);
      expect(copy.whereClause, {'key': 'value'});
    });

    test('copyWith can set fields to null', () {
      const original = SearchFilter(
        queryIds: ['id1'],
        whereClause: {'key': 'value'},
      );

      final copy = original.copyWith(queryIds: null, whereClause: null);

      expect(copy.queryIds, isNull);
      expect(copy.whereClause, isNull);
    });

    test('equality works correctly', () {
      const filter1 = SearchFilter(queryIds: ['id1']);
      const filter2 = SearchFilter(queryIds: ['id1']);
      const filter3 = SearchFilter(queryIds: ['id2']);

      expect(filter1, equals(filter2));
      expect(filter1, isNot(equals(filter3)));
    });
  });

  group('SearchGroupBy', () {
    test('fromJson creates groupBy with all fields', () {
      final json = {
        'aggregate': {'count': 'field1'},
        'keys': ['key1', 'key2'],
      };

      final groupBy = SearchGroupBy.fromJson(json);

      expect(groupBy.aggregate, {'count': 'field1'});
      expect(groupBy.keys, ['key1', 'key2']);
    });

    test('toJson converts groupBy correctly', () {
      const groupBy = SearchGroupBy(
        aggregate: {'sum': 'price'},
        keys: ['category'],
      );

      final json = groupBy.toJson();

      expect(json['aggregate'], {'sum': 'price'});
      expect(json['keys'], ['category']);
    });

    test('copyWith can set fields to null', () {
      const original = SearchGroupBy(aggregate: {'count': '*'}, keys: ['type']);

      final copy = original.copyWith(aggregate: null, keys: null);

      expect(copy.aggregate, isNull);
      expect(copy.keys, isNull);
    });
  });

  group('SearchLimit', () {
    test('fromJson creates limit with all fields', () {
      final json = {'limit': 10, 'offset': 5};

      final limit = SearchLimit.fromJson(json);

      expect(limit.limit, 10);
      expect(limit.offset, 5);
    });

    test('toJson converts limit correctly', () {
      const limit = SearchLimit(limit: 20, offset: 10);

      final json = limit.toJson();

      expect(json['limit'], 20);
      expect(json['offset'], 10);
    });

    test('copyWith can set fields to null', () {
      const original = SearchLimit(limit: 10, offset: 5);

      final copy = original.copyWith(limit: null, offset: null);

      expect(copy.limit, isNull);
      expect(copy.offset, isNull);
    });

    test('equality works correctly', () {
      const limit1 = SearchLimit(limit: 10, offset: 0);
      const limit2 = SearchLimit(limit: 10, offset: 0);
      const limit3 = SearchLimit(limit: 20, offset: 0);

      expect(limit1, equals(limit2));
      expect(limit1, isNot(equals(limit3)));
    });
  });

  group('SearchSelect', () {
    test('fromJson creates select with keys', () {
      final json = {
        'keys': ['Document', 'Metadata', 'Score'],
      };

      final select = SearchSelect.fromJson(json);

      expect(select.keys, ['Document', 'Metadata', 'Score']);
    });

    test('toJson converts select correctly', () {
      const select = SearchSelect(keys: ['Embedding']);

      final json = select.toJson();

      expect(json['keys'], ['Embedding']);
    });

    test('copyWith can set keys to null', () {
      const original = SearchSelect(keys: ['Document']);

      final copy = original.copyWith(keys: null);

      expect(copy.keys, isNull);
    });
  });

  group('SearchPayload', () {
    test('fromJson creates payload with all fields', () {
      final json = {
        'filter': {
          'query_ids': ['id1'],
        },
        'group_by': {
          'keys': ['category'],
        },
        'limit': {'limit': 10},
        'rank': {'method': 'bm25'},
        'select': {
          'keys': ['Document'],
        },
      };

      final payload = SearchPayload.fromJson(json);

      expect(payload.filter?.queryIds, ['id1']);
      expect(payload.groupBy?.keys, ['category']);
      expect(payload.limit?.limit, 10);
      expect(payload.rank, {'method': 'bm25'});
      expect(payload.select?.keys, ['Document']);
    });

    test('fromJson handles null fields', () {
      final json = <String, dynamic>{};

      final payload = SearchPayload.fromJson(json);

      expect(payload.filter, isNull);
      expect(payload.groupBy, isNull);
      expect(payload.limit, isNull);
      expect(payload.rank, isNull);
      expect(payload.select, isNull);
    });

    test('toJson converts payload correctly', () {
      const payload = SearchPayload(
        filter: SearchFilter(queryIds: ['id1']),
        limit: SearchLimit(limit: 5),
      );

      final json = payload.toJson();

      expect(json['filter'], {
        'query_ids': ['id1'],
      });
      expect(json['limit'], {'limit': 5});
      expect(json.containsKey('group_by'), isFalse);
      expect(json.containsKey('rank'), isFalse);
      expect(json.containsKey('select'), isFalse);
    });

    test('copyWith can set all fields to null', () {
      const original = SearchPayload(
        filter: SearchFilter(queryIds: ['id1']),
        groupBy: SearchGroupBy(keys: ['key']),
        limit: SearchLimit(limit: 10),
        rank: {'method': 'rrf'},
        select: SearchSelect(keys: ['Document']),
      );

      final copy = original.copyWith(
        filter: null,
        groupBy: null,
        limit: null,
        rank: null,
        select: null,
      );

      expect(copy.filter, isNull);
      expect(copy.groupBy, isNull);
      expect(copy.limit, isNull);
      expect(copy.rank, isNull);
      expect(copy.select, isNull);
    });

    test('equality works correctly', () {
      const payload1 = SearchPayload(limit: SearchLimit(limit: 10));
      const payload2 = SearchPayload(limit: SearchLimit(limit: 10));
      const payload3 = SearchPayload(limit: SearchLimit(limit: 20));

      expect(payload1, equals(payload2));
      expect(payload1, isNot(equals(payload3)));
    });
  });

  group('SearchResponse', () {
    test('fromJson creates response with all fields', () {
      final json = {
        'ids': [
          ['id1', 'id2'],
          ['id3'],
        ],
        'documents': [
          ['doc1', 'doc2'],
          ['doc3'],
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
        'metadatas': [
          [
            {'key': 'value1'},
            {'key': 'value2'},
          ],
          [
            {'key': 'value3'},
          ],
        ],
        'scores': [
          [0.9, 0.8],
          [0.7],
        ],
        'included': [
          ['Document', 'Metadata'],
          ['Document'],
        ],
        'uris': [
          ['uri1', 'uri2'],
          ['uri3'],
        ],
      };

      final response = SearchResponse.fromJson(json);

      expect(response.ids, [
        ['id1', 'id2'],
        ['id3'],
      ]);
      expect(response.searchCount, 2);
      expect(response.documents, [
        ['doc1', 'doc2'],
        ['doc3'],
      ]);
      expect(response.scores, [
        [0.9, 0.8],
        [0.7],
      ]);
    });

    test('fromJson handles minimal response', () {
      final json = {
        'ids': [
          ['id1'],
        ],
      };

      final response = SearchResponse.fromJson(json);

      expect(response.ids, [
        ['id1'],
      ]);
      expect(response.documents, isNull);
      expect(response.embeddings, isNull);
      expect(response.metadatas, isNull);
      expect(response.scores, isNull);
      expect(response.included, isNull);
      expect(response.uris, isNull);
    });

    test('fromJson handles null inner elements in ids', () {
      final json = {
        'ids': [
          ['id1', 'id2'],
          null, // null inner list - server could return this
        ],
      };

      final response = SearchResponse.fromJson(json);

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
          null, // null search result
        ],
      };

      final response = SearchResponse.fromJson(json);

      expect(response.embeddings, [
        [
          [0.1, 0.2],
          <double>[], // null coalesced to empty list
        ],
        <List<double>>[], // null search result coalesced to empty list
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

      final response = SearchResponse.fromJson(json);

      expect(response.documents, [
        ['doc1', null],
        <String?>[], // null coalesced to empty list
      ]);
    });

    test('fromJson handles null inner elements in scores', () {
      final json = {
        'ids': [
          ['id1'],
        ],
        'scores': [
          [0.9, 0.8],
          null, // null inner list
        ],
      };

      final response = SearchResponse.fromJson(json);

      expect(response.scores, [
        [0.9, 0.8],
        <double>[], // null coalesced to empty list
      ]);
    });

    test('fromJson handles null inner elements in metadatas', () {
      final json = {
        'ids': [
          ['id1'],
        ],
        'metadatas': [
          [
            {'key': 'value'},
            null,
          ],
          null, // null inner list
        ],
      };

      final response = SearchResponse.fromJson(json);

      expect(response.metadatas, [
        [
          {'key': 'value'},
          null,
        ],
        <Map<String, dynamic>?>[], // null coalesced to empty list
      ]);
    });

    test('toJson converts response correctly', () {
      const response = SearchResponse(
        ids: [
          ['id1', 'id2'],
        ],
        scores: [
          [0.95, 0.85],
        ],
      );

      final json = response.toJson();

      expect(json['ids'], [
        ['id1', 'id2'],
      ]);
      expect(json['scores'], [
        [0.95, 0.85],
      ]);
      expect(json.containsKey('documents'), isFalse);
      expect(json.containsKey('embeddings'), isFalse);
    });

    test('searchCount returns correct count', () {
      const response = SearchResponse(
        ids: [
          ['id1'],
          ['id2'],
          ['id3'],
        ],
      );

      expect(response.searchCount, 3);
    });

    test('equality works correctly', () {
      const response1 = SearchResponse(
        ids: [
          ['id1'],
        ],
        scores: [
          [0.9],
        ],
      );
      const response2 = SearchResponse(
        ids: [
          ['id1'],
        ],
        scores: [
          [0.9],
        ],
      );
      const response3 = SearchResponse(
        ids: [
          ['id2'],
        ],
        scores: [
          [0.9],
        ],
      );

      expect(response1, equals(response2));
      expect(response1, isNot(equals(response3)));
    });

    test('copyWith preserves values when not specified', () {
      const original = SearchResponse(
        ids: [
          ['id1', 'id2'],
        ],
        documents: [
          ['doc1', 'doc2'],
        ],
        embeddings: [
          [
            [0.1, 0.2],
            [0.3, 0.4],
          ],
        ],
        metadatas: [
          [
            {'key': 'value1'},
            {'key': 'value2'},
          ],
        ],
        scores: [
          [0.9, 0.8],
        ],
        included: [
          ['Document', 'Metadata'],
        ],
        uris: [
          ['uri1', 'uri2'],
        ],
      );

      final copy = original.copyWith();

      expect(copy.ids, [
        ['id1', 'id2'],
      ]);
      expect(copy.documents, [
        ['doc1', 'doc2'],
      ]);
      expect(copy.scores, [
        [0.9, 0.8],
      ]);
    });

    test('copyWith can set fields to null', () {
      const original = SearchResponse(
        ids: [
          ['id1'],
        ],
        documents: [
          ['doc1'],
        ],
        scores: [
          [0.9],
        ],
      );

      final copy = original.copyWith(documents: null, scores: null);

      expect(copy.ids, [
        ['id1'],
      ]);
      expect(copy.documents, isNull);
      expect(copy.scores, isNull);
    });

    test('hashCode is consistent with equality', () {
      const response1 = SearchResponse(
        ids: [
          ['id1'],
        ],
        scores: [
          [0.9],
        ],
      );
      const response2 = SearchResponse(
        ids: [
          ['id1'],
        ],
        scores: [
          [0.9],
        ],
      );

      expect(response1.hashCode, equals(response2.hashCode));
    });
  });
}
