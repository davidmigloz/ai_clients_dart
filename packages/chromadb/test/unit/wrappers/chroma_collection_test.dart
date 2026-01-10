import 'package:chromadb/chromadb.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockRecordsResource extends Mock implements RecordsResource {}

class MockCollectionsResource extends Mock implements CollectionsResource {}

class MockEmbeddingFunction extends Mock implements EmbeddingFunction {}

class MockDataLoader extends Mock implements DataLoader<Loadable> {}

void main() {
  late MockRecordsResource mockRecords;
  late MockCollectionsResource mockCollections;
  late MockEmbeddingFunction mockEmbeddingFunction;
  late MockDataLoader mockDataLoader;

  const testMetadata = Collection(id: 'test-id', name: 'test-collection');

  setUp(() {
    mockRecords = MockRecordsResource();
    mockCollections = MockCollectionsResource();
    mockEmbeddingFunction = MockEmbeddingFunction();
    mockDataLoader = MockDataLoader();
  });

  group('ChromaCollection', () {
    group('add()', () {
      test('throws ArgumentError when ids is empty', () {
        final collection = ChromaCollection(
          records: mockRecords,
          collections: mockCollections,
          metadata: testMetadata,
          embeddingFunction: mockEmbeddingFunction,
        );

        expect(
          () => collection.add(ids: [], documents: ['doc']),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              'ids cannot be empty',
            ),
          ),
        );
      });

      test('throws ArgumentError when ids are not unique', () {
        final collection = ChromaCollection(
          records: mockRecords,
          collections: mockCollections,
          metadata: testMetadata,
          embeddingFunction: mockEmbeddingFunction,
        );

        expect(
          () =>
              collection.add(ids: ['id1', 'id1'], documents: ['doc1', 'doc2']),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              'ids must be unique',
            ),
          ),
        );
      });

      test('throws ArgumentError when embeddings length mismatch', () {
        final collection = ChromaCollection(
          records: mockRecords,
          collections: mockCollections,
          metadata: testMetadata,
        );

        expect(
          () => collection.add(
            ids: ['id1', 'id2'],
            embeddings: [
              [0.1, 0.2],
            ],
          ),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              'embeddings length must match ids length',
            ),
          ),
        );
      });

      test('throws ArgumentError when documents length mismatch', () {
        final collection = ChromaCollection(
          records: mockRecords,
          collections: mockCollections,
          metadata: testMetadata,
          embeddingFunction: mockEmbeddingFunction,
        );

        expect(
          () => collection.add(ids: ['id1', 'id2'], documents: ['doc1']),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              'documents length must match ids length',
            ),
          ),
        );
      });

      test('throws ArgumentError when multiple sources provided', () {
        final collection = ChromaCollection(
          records: mockRecords,
          collections: mockCollections,
          metadata: testMetadata,
          embeddingFunction: mockEmbeddingFunction,
        );

        expect(
          () => collection.add(
            ids: ['id1'],
            documents: ['doc1'],
            images: ['img1'],
          ),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('multiple embedding sources'),
            ),
          ),
        );
      });

      test('throws ArgumentError when no source and required', () {
        final collection = ChromaCollection(
          records: mockRecords,
          collections: mockCollections,
          metadata: testMetadata,
        );

        expect(
          () => collection.add(ids: ['id1']),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('Must provide'),
            ),
          ),
        );
      });

      test('throws StateError when embeddingFunction is null but needed', () {
        final collection = ChromaCollection(
          records: mockRecords,
          collections: mockCollections,
          metadata: testMetadata,
          // No embedding function
        );

        expect(
          () => collection.add(ids: ['id1'], documents: ['doc1']),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              contains('embeddingFunction is required'),
            ),
          ),
        );
      });

      test('calls embeddingFunction.generate with documents', () async {
        when(() => mockEmbeddingFunction.generate(any())).thenAnswer(
          (_) async => [
            [0.1, 0.2, 0.3],
          ],
        );
        when(
          () => mockRecords.add(
            ids: any(named: 'ids'),
            embeddings: any(named: 'embeddings'),
            documents: any(named: 'documents'),
            metadatas: any(named: 'metadatas'),
            uris: any(named: 'uris'),
          ),
        ).thenAnswer((_) async {});

        final collection = ChromaCollection(
          records: mockRecords,
          collections: mockCollections,
          metadata: testMetadata,
          embeddingFunction: mockEmbeddingFunction,
        );

        await collection.add(ids: ['id1'], documents: ['Hello world']);

        final captured =
            verify(
                  () => mockEmbeddingFunction.generate(captureAny()),
                ).captured.first
                as List<Embeddable>;

        expect(captured, hasLength(1));
        expect(captured.first, isA<EmbeddableDocument>());
        expect((captured.first as EmbeddableDocument).document, 'Hello world');
      });
    });

    group('update()', () {
      test('allows no embedding source when required=false', () async {
        when(
          () => mockRecords.update(
            ids: any(named: 'ids'),
            embeddings: any(named: 'embeddings'),
            documents: any(named: 'documents'),
            metadatas: any(named: 'metadatas'),
            uris: any(named: 'uris'),
          ),
        ).thenAnswer((_) async {});

        final collection = ChromaCollection(
          records: mockRecords,
          collections: mockCollections,
          metadata: testMetadata,
        );

        // Should not throw - update allows partial updates
        await collection.update(
          ids: ['id1'],
          metadatas: [
            {'key': 'value'},
          ],
        );

        verify(
          () => mockRecords.update(
            ids: ['id1'],
            embeddings: null,
            documents: null,
            metadatas: [
              {'key': 'value'},
            ],
            uris: null,
          ),
        ).called(1);
      });
    });

    group('query()', () {
      test('throws ArgumentError when no query source provided', () {
        final collection = ChromaCollection(
          records: mockRecords,
          collections: mockCollections,
          metadata: testMetadata,
        );

        expect(
          collection.query,
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('Must provide'),
            ),
          ),
        );
      });

      test('throws ArgumentError when multiple query sources', () {
        final collection = ChromaCollection(
          records: mockRecords,
          collections: mockCollections,
          metadata: testMetadata,
        );

        expect(
          () => collection.query(queryTexts: ['text'], queryImages: ['image']),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('multiple query sources'),
            ),
          ),
        );
      });

      test('throws StateError when embeddingFunction null', () {
        final collection = ChromaCollection(
          records: mockRecords,
          collections: mockCollections,
          metadata: testMetadata,
          // No embedding function
        );

        expect(
          () => collection.query(queryTexts: ['text']),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              contains('embeddingFunction is required'),
            ),
          ),
        );
      });
    });

    group('dataLoader integration', () {
      test('throws StateError when dataLoader null but uris provided', () {
        final collection = ChromaCollection(
          records: mockRecords,
          collections: mockCollections,
          metadata: testMetadata,
          embeddingFunction: mockEmbeddingFunction,
          // No data loader
        );

        expect(
          () => collection.add(ids: ['id1'], uris: ['file://path']),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              contains('dataLoader is required'),
            ),
          ),
        );
      });

      test('calls dataLoader for uris and generates embeddings', () async {
        when(
          () => mockDataLoader.call(any()),
        ).thenAnswer((_) async => ['loaded-image-data']);
        when(() => mockEmbeddingFunction.generate(any())).thenAnswer(
          (_) async => [
            [0.1, 0.2, 0.3],
          ],
        );
        when(
          () => mockRecords.add(
            ids: any(named: 'ids'),
            embeddings: any(named: 'embeddings'),
            documents: any(named: 'documents'),
            metadatas: any(named: 'metadatas'),
            uris: any(named: 'uris'),
          ),
        ).thenAnswer((_) async {});

        final collection = ChromaCollection(
          records: mockRecords,
          collections: mockCollections,
          metadata: testMetadata,
          embeddingFunction: mockEmbeddingFunction,
          dataLoader: mockDataLoader,
        );

        await collection.add(ids: ['id1'], uris: ['file://path']);

        verify(() => mockDataLoader.call(['file://path'])).called(1);

        final captured =
            verify(
                  () => mockEmbeddingFunction.generate(captureAny()),
                ).captured.first
                as List<Embeddable>;

        expect(captured, hasLength(1));
        expect(captured.first, isA<EmbeddableImage>());
        expect((captured.first as EmbeddableImage).image, 'loaded-image-data');
      });
    });

    group('modify()', () {
      test('calls collections.update with correct parameters', () async {
        when(
          () => mockCollections.update(
            name: any(named: 'name'),
            newName: any(named: 'newName'),
            newMetadata: any(named: 'newMetadata'),
            tenant: any(named: 'tenant'),
            database: any(named: 'database'),
          ),
        ).thenAnswer(
          (_) async => const Collection(
            id: 'test-id',
            name: 'new-name',
            metadata: {'updated': true},
          ),
        );

        final collection = ChromaCollection(
          records: mockRecords,
          collections: mockCollections,
          metadata: testMetadata,
        );

        final updated = await collection.modify(
          newName: 'new-name',
          newMetadata: {'updated': true},
        );

        expect(updated.name, 'new-name');
        expect(updated.metadata, {'updated': true});

        verify(
          () => mockCollections.update(
            name: 'test-collection',
            newName: 'new-name',
            newMetadata: {'updated': true},
          ),
        ).called(1);
      });
    });

    group('convenience methods', () {
      test('count() delegates to records', () async {
        when(() => mockRecords.count()).thenAnswer((_) async => 42);

        final collection = ChromaCollection(
          records: mockRecords,
          collections: mockCollections,
          metadata: testMetadata,
        );

        final count = await collection.count();

        expect(count, 42);
        verify(() => mockRecords.count()).called(1);
      });

      test('id and name getters work correctly', () {
        final collection = ChromaCollection(
          records: mockRecords,
          collections: mockCollections,
          metadata: testMetadata,
        );

        expect(collection.id, 'test-id');
        expect(collection.name, 'test-collection');
      });
    });
  });
}
