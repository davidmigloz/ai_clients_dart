@TestOn('vm')
library;

import 'dart:async';
import 'dart:convert';

import 'package:chromadb/chromadb.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockHttpClient extends Mock implements http.Client {}

class FakeBaseRequest extends Fake implements http.BaseRequest {}

const Map<String, dynamic> _collectionJson = {
  'id': 'coll-uuid-123',
  'name': 'test-collection',
  'metadata': {'key': 'value'},
  'tenant': 'default_tenant',
  'database': 'default_database',
  'log_position': 0,
  'version': 1,
  'configuration_json': <String, dynamic>{},
};

void main() {
  setUpAll(() {
    registerFallbackValue(FakeBaseRequest());
  });

  group('CollectionsResource', () {
    late MockHttpClient mockHttpClient;

    setUp(() {
      mockHttpClient = MockHttpClient();
    });

    tearDown(() {
      reset(mockHttpClient);
    });

    group('getById', () {
      test('fetches a collection by UUID', () async {
        http.Request? capturedRequest;
        when(() => mockHttpClient.send(any())).thenAnswer((invocation) async {
          capturedRequest = invocation.positionalArguments[0] as http.Request;
          return http.StreamedResponse(
            Stream.value(utf8.encode(jsonEncode(_collectionJson))),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final client = ChromaClient(httpClient: mockHttpClient);
        addTearDown(client.close);

        final collection = await client.collections.getById(
          collectionId: 'coll-uuid-123',
        );

        expect(capturedRequest, isNotNull);
        expect(capturedRequest!.method, 'GET');
        expect(
          capturedRequest!.url.path,
          '/api/v2/tenants/default_tenant/databases/default_database'
          '/collections/by-id/coll-uuid-123',
        );
        expect(collection.id, 'coll-uuid-123');
        expect(collection.name, 'test-collection');
      });

      test('uses custom tenant and database', () async {
        http.Request? capturedRequest;
        when(() => mockHttpClient.send(any())).thenAnswer((invocation) async {
          capturedRequest = invocation.positionalArguments[0] as http.Request;
          return http.StreamedResponse(
            Stream.value(utf8.encode(jsonEncode(_collectionJson))),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final client = ChromaClient(httpClient: mockHttpClient);
        addTearDown(client.close);

        await client.collections.getById(
          collectionId: 'coll-uuid-123',
          tenant: 'my-tenant',
          database: 'my-db',
        );

        expect(
          capturedRequest!.url.path,
          '/api/v2/tenants/my-tenant/databases/my-db'
          '/collections/by-id/coll-uuid-123',
        );
      });

      test('throws NotFoundException for non-existent UUID', () async {
        when(() => mockHttpClient.send(any())).thenAnswer((_) async {
          return http.StreamedResponse(
            Stream.value(
              utf8.encode(jsonEncode({'error': 'Collection not found'})),
            ),
            404,
            headers: {'content-type': 'application/json'},
          );
        });

        final client = ChromaClient(httpClient: mockHttpClient);
        addTearDown(client.close);

        await expectLater(
          client.collections.getById(collectionId: 'non-existent'),
          throwsA(isA<NotFoundException>()),
        );
      });
    });
  });

  group('ChromaClient', () {
    late MockHttpClient mockHttpClient;

    setUp(() {
      mockHttpClient = MockHttpClient();
    });

    tearDown(() {
      reset(mockHttpClient);
    });

    group('getCollectionById', () {
      test(
        'returns ChromaCollection wrapping the fetched collection',
        () async {
          when(() => mockHttpClient.send(any())).thenAnswer((invocation) async {
            return http.StreamedResponse(
              Stream.value(utf8.encode(jsonEncode(_collectionJson))),
              200,
              headers: {'content-type': 'application/json'},
            );
          });

          final client = ChromaClient(httpClient: mockHttpClient);
          addTearDown(client.close);

          final chromaCollection = await client.getCollectionById(
            collectionId: 'coll-uuid-123',
          );

          expect(chromaCollection.id, 'coll-uuid-123');
          expect(chromaCollection.name, 'test-collection');
        },
      );

      test('throws NotFoundException for non-existent UUID', () async {
        when(() => mockHttpClient.send(any())).thenAnswer((_) async {
          return http.StreamedResponse(
            Stream.value(
              utf8.encode(jsonEncode({'error': 'Collection not found'})),
            ),
            404,
            headers: {'content-type': 'application/json'},
          );
        });

        final client = ChromaClient(httpClient: mockHttpClient);
        addTearDown(client.close);

        await expectLater(
          client.getCollectionById(collectionId: 'non-existent'),
          throwsA(isA<NotFoundException>()),
        );
      });
    });
  });
}
