import '../embeddings/embedding_function.dart';
import '../loaders/data_loader.dart';
import '../models/collections/collection.dart';
import '../models/functions/attach_function_response.dart';
import '../models/functions/detach_function_response.dart';
import '../models/functions/get_attached_function_response.dart';
import '../models/records/delete_collection_records_response.dart';
import '../models/records/get_response.dart';
import '../models/records/include.dart';
import '../models/records/index_status_response.dart';
import '../models/records/query_response.dart';
import '../models/records/read_level.dart';
import '../models/records/search_request.dart';
import '../models/records/search_response.dart';
import '../resources/collections_resource.dart';
import '../resources/functions_resource.dart';
import '../resources/records_resource.dart';

/// High-level collection wrapper with automatic embedding generation.
///
/// This wrapper provides a more ergonomic API over [RecordsResource] with:
/// - Automatic embedding generation from documents, images, or URIs
/// - Convenient query methods that accept text instead of embeddings
/// - Validation of input parameters
///
/// Example:
/// ```dart
/// final collection = await client.getOrCreateCollection(
///   name: 'my-docs',
///   embeddingFunction: myEmbedder,
/// );
///
/// // Add documents (embeddings generated automatically)
/// await collection.add(
///   ids: ['id1', 'id2'],
///   documents: ['Hello world', 'Goodbye world'],
/// );
///
/// // Query by text (embedding generated automatically)
/// final results = await collection.query(
///   queryTexts: ['greeting'],
///   nResults: 5,
/// );
/// ```
class ChromaCollection {
  /// The underlying records resource.
  final RecordsResource _records;

  /// The underlying collections resource (for modify operations).
  final CollectionsResource _collections;

  /// The underlying functions resource (for function operations).
  final FunctionsResource? _functions;

  /// The collection metadata.
  final Collection metadata;

  /// The embedding function for auto-embedding.
  final EmbeddingFunction? embeddingFunction;

  /// The data loader for loading data from URIs.
  final DataLoader<Loadable>? dataLoader;

  /// Creates a ChromaCollection wrapper.
  ChromaCollection({
    required RecordsResource records,
    required CollectionsResource collections,
    FunctionsResource? functions,
    required this.metadata,
    this.embeddingFunction,
    this.dataLoader,
  }) : _records = records,
       _collections = collections,
       _functions = functions;

  /// The collection's unique identifier.
  String get id => metadata.id;

  /// The collection's name.
  String get name => metadata.name;

  /// Adds records to the collection.
  ///
  /// Provide ONE of: [embeddings], [documents], [images], or [uris].
  /// If [embeddings] is not provided, an [embeddingFunction] must be set.
  ///
  /// [ids] - Unique identifiers for each record (required).
  /// [embeddings] - Pre-computed embedding vectors.
  /// [documents] - Text documents to embed.
  /// [images] - Base64-encoded images to embed.
  /// [uris] - URIs to load and embed (requires [dataLoader]).
  /// [metadatas] - Metadata for each record.
  Future<void> add({
    required List<String> ids,
    List<List<double>>? embeddings,
    List<String>? documents,
    List<String>? images,
    List<String>? uris,
    List<Map<String, dynamic>>? metadatas,
  }) async {
    _validateIds(ids);
    final computedEmbeddings = await _resolveEmbeddings(
      embeddings: embeddings,
      documents: documents,
      images: images,
      uris: uris,
      count: ids.length,
    );

    await _records.add(
      ids: ids,
      embeddings: computedEmbeddings,
      documents: documents,
      metadatas: metadatas,
      uris: uris,
    );
  }

  /// Updates existing records in the collection.
  ///
  /// Only the provided fields will be updated.
  Future<void> update({
    required List<String> ids,
    List<List<double>>? embeddings,
    List<String>? documents,
    List<String>? images,
    List<String>? uris,
    List<Map<String, dynamic>>? metadatas,
  }) async {
    _validateIds(ids);
    final computedEmbeddings = await _resolveEmbeddings(
      embeddings: embeddings,
      documents: documents,
      images: images,
      uris: uris,
      count: ids.length,
      required: false,
    );

    await _records.update(
      ids: ids,
      embeddings: computedEmbeddings,
      documents: documents,
      metadatas: metadatas,
      uris: uris,
    );
  }

  /// Upserts records (insert or update).
  Future<void> upsert({
    required List<String> ids,
    List<List<double>>? embeddings,
    List<String>? documents,
    List<String>? images,
    List<String>? uris,
    List<Map<String, dynamic>>? metadatas,
  }) async {
    _validateIds(ids);
    final computedEmbeddings = await _resolveEmbeddings(
      embeddings: embeddings,
      documents: documents,
      images: images,
      uris: uris,
      count: ids.length,
    );

    await _records.upsert(
      ids: ids,
      embeddings: computedEmbeddings,
      documents: documents,
      metadatas: metadatas,
      uris: uris,
    );
  }

  /// Gets records from the collection.
  Future<GetResponse> get({
    List<String>? ids,
    Map<String, dynamic>? where,
    Map<String, dynamic>? whereDocument,
    int? limit,
    int? offset,
    List<Include> include = const [Include.documents, Include.metadatas],
  }) {
    return _records.getRecords(
      ids: ids,
      where: where,
      whereDocument: whereDocument,
      limit: limit,
      offset: offset,
      include: include,
    );
  }

  /// Queries records by similarity.
  ///
  /// Provide ONE of: [queryEmbeddings], [queryTexts], [queryImages], or [queryUris].
  Future<QueryResponse> query({
    List<List<double>>? queryEmbeddings,
    List<String>? queryTexts,
    List<String>? queryImages,
    List<String>? queryUris,
    int nResults = 10,
    Map<String, dynamic>? where,
    Map<String, dynamic>? whereDocument,
    List<Include> include = const [
      Include.documents,
      Include.metadatas,
      Include.distances,
    ],
  }) async {
    final embeddings = await _resolveQueryEmbeddings(
      queryEmbeddings: queryEmbeddings,
      queryTexts: queryTexts,
      queryImages: queryImages,
      queryUris: queryUris,
    );

    return _records.query(
      queryEmbeddings: embeddings,
      nResults: nResults,
      where: where,
      whereDocument: whereDocument,
      include: include,
    );
  }

  /// Performs hybrid search with multiple criteria.
  ///
  /// This is an advanced search method supporting:
  /// - Filtering by IDs or metadata conditions
  /// - Grouping results by metadata keys
  /// - Pagination with limit/offset
  /// - Custom ranking configurations
  /// - Field selection for results
  ///
  /// [searches] - List of search payloads with filter/group/limit/rank/select.
  /// [readLevel] - Read level for consistency vs performance tradeoffs.
  Future<SearchResponse> search({
    required List<SearchPayload> searches,
    ReadLevel? readLevel,
  }) {
    return _records.search(searches: searches, readLevel: readLevel);
  }

  /// Deletes records from the collection.
  ///
  /// [limit] - Maximum number of records to delete.
  ///
  /// Returns a [DeleteCollectionRecordsResponse] with the count of deleted
  /// records.
  Future<DeleteCollectionRecordsResponse> delete({
    List<String>? ids,
    Map<String, dynamic>? where,
    Map<String, dynamic>? whereDocument,
    int? limit,
  }) {
    return _records.deleteRecords(
      ids: ids,
      where: where,
      whereDocument: whereDocument,
      limit: limit,
    );
  }

  /// Counts records in the collection.
  ///
  /// [readLevel] - Read level for consistency vs performance tradeoffs.
  Future<int> count({ReadLevel? readLevel}) =>
      _records.count(readLevel: readLevel);

  /// Gets the indexing status of the collection.
  Future<IndexStatusResponse> indexingStatus() => _records.indexingStatus();

  /// Peeks at the first N records.
  Future<GetResponse> peek({int limit = 10, List<Include>? include}) {
    return _records.getRecords(
      limit: limit,
      include: include ?? Include.defaultGet,
    );
  }

  /// Updates this collection's name or metadata.
  ///
  /// [newName] - New name for the collection.
  /// [newMetadata] - New metadata for the collection.
  ///
  /// Returns the updated collection information.
  ///
  /// Note: This updates the remote collection but does NOT update
  /// the local [metadata] field. Get a fresh collection reference
  /// to see the updated values.
  Future<Collection> modify({
    String? newName,
    Map<String, dynamic>? newMetadata,
  }) {
    return _collections.update(
      name: name,
      newName: newName,
      newMetadata: newMetadata,
    );
  }

  // ===========================================================================
  // Functions
  // ===========================================================================

  /// Attaches a function to this collection.
  ///
  /// [name] - The name for this function instance (required).
  /// [functionId] - The ID of the function to attach (required).
  /// [outputCollection] - The name of the collection for output (required).
  /// [params] - Optional parameters for the function.
  ///
  /// Returns information about the attached function and whether it was
  /// newly created.
  Future<AttachFunctionResponse> attachFunction({
    required String name,
    required String functionId,
    required String outputCollection,
    Map<String, dynamic>? params,
  }) {
    if (_functions == null) {
      throw StateError('Functions resource not available');
    }
    return _functions.attach(
      name: name,
      functionId: functionId,
      outputCollection: outputCollection,
      params: params,
    );
  }

  /// Gets details of an attached function by name.
  ///
  /// [name] - The name of the attached function (required).
  ///
  /// Returns full details of the attached function.
  Future<GetAttachedFunctionResponse> getFunction({required String name}) {
    if (_functions == null) {
      throw StateError('Functions resource not available');
    }
    return _functions.getFunction(name: name);
  }

  /// Detaches a function from this collection.
  ///
  /// [name] - The name of the attached function to detach (required).
  /// [deleteOutput] - Whether to delete the output collection.
  ///
  /// Returns whether the detach operation was successful.
  Future<DetachFunctionResponse> detachFunction({
    required String name,
    bool? deleteOutput,
  }) {
    if (_functions == null) {
      throw StateError('Functions resource not available');
    }
    return _functions.detach(name: name, deleteOutput: deleteOutput);
  }

  // ===========================================================================
  // Private Helpers
  // ===========================================================================

  void _validateIds(List<String> ids) {
    if (ids.isEmpty) {
      throw ArgumentError('ids cannot be empty');
    }
    final uniqueIds = ids.toSet();
    if (uniqueIds.length != ids.length) {
      throw ArgumentError('ids must be unique');
    }
  }

  Future<List<List<double>>?> _resolveEmbeddings({
    List<List<double>>? embeddings,
    List<String>? documents,
    List<String>? images,
    List<String>? uris,
    required int count,
    bool required = true,
  }) async {
    if (embeddings != null) {
      if (embeddings.length != count) {
        throw ArgumentError('embeddings length must match ids length');
      }
      return embeddings;
    }

    // Count how many input sources are provided
    final sources = [documents, images, uris].where((s) => s != null).length;

    if (sources == 0) {
      if (required) {
        throw ArgumentError(
          'Must provide embeddings, documents, images, or uris',
        );
      }
      return null;
    }

    if (sources > 1) {
      throw ArgumentError(
        'Cannot provide multiple embedding sources (documents, images, uris)',
      );
    }

    if (embeddingFunction == null) {
      throw StateError(
        'embeddingFunction is required when not providing embeddings',
      );
    }

    // Generate embeddings from the provided source
    List<Embeddable> inputs;

    if (documents != null) {
      if (documents.length != count) {
        throw ArgumentError('documents length must match ids length');
      }
      inputs = documents.map(Embeddable.document).toList();
    } else if (images != null) {
      if (images.length != count) {
        throw ArgumentError('images length must match ids length');
      }
      inputs = images.map(Embeddable.image).toList();
    } else if (uris != null) {
      if (uris.length != count) {
        throw ArgumentError('uris length must match ids length');
      }
      if (dataLoader == null) {
        throw StateError('dataLoader is required when using uris');
      }
      final loadedData = await dataLoader!.call(uris);
      inputs = loadedData.map(Embeddable.image).toList();
    } else {
      return null;
    }

    return embeddingFunction!.generate(inputs);
  }

  Future<List<List<double>>> _resolveQueryEmbeddings({
    List<List<double>>? queryEmbeddings,
    List<String>? queryTexts,
    List<String>? queryImages,
    List<String>? queryUris,
  }) async {
    if (queryEmbeddings != null) {
      return queryEmbeddings;
    }

    final sources = [
      queryTexts,
      queryImages,
      queryUris,
    ].where((s) => s != null).length;

    if (sources == 0) {
      throw ArgumentError(
        'Must provide queryEmbeddings, queryTexts, queryImages, or queryUris',
      );
    }

    if (sources > 1) {
      throw ArgumentError('Cannot provide multiple query sources');
    }

    if (embeddingFunction == null) {
      throw StateError(
        'embeddingFunction is required when not providing queryEmbeddings',
      );
    }

    List<Embeddable> inputs;

    if (queryTexts != null) {
      inputs = queryTexts.map(Embeddable.document).toList();
    } else if (queryImages != null) {
      inputs = queryImages.map(Embeddable.image).toList();
    } else if (queryUris != null) {
      if (dataLoader == null) {
        throw StateError('dataLoader is required when using queryUris');
      }
      final loadedData = await dataLoader!.call(queryUris);
      inputs = loadedData.map(Embeddable.image).toList();
    } else {
      throw StateError('Unexpected state: no query input provided');
    }

    return embeddingFunction!.generate(inputs);
  }
}
