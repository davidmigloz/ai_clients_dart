import 'package:http/http.dart' as http;

import '../../client/config.dart';
import '../../client/interceptor_chain.dart';
import '../../client/request_builder.dart';
import 'ingestion_pipeline_configurations_resource.dart';
import 'search_indexes_resource.dart';

/// Resource for RAG (Retrieval Augmented Generation) API operations (beta).
///
/// The RAG API provides tools for configuring document ingestion pipelines and
/// managing search indexes. Key features include:
/// - **Ingestion pipeline configurations**: Register and manage how documents
///   are processed and chunked before indexing.
/// - **Search indexes**: Register and inspect the indexes used for retrieval.
///
/// Example usage:
/// ```dart
/// // List ingestion pipeline configurations
/// final configs =
///     await client.rag.ingestionPipelineConfigurations.list();
///
/// // Get the search index info
/// final indexes = await client.rag.searchIndexes.list();
/// ```
class RagResource {
  /// Configuration.
  final MistralConfig config;

  /// HTTP client.
  final http.Client httpClient;

  /// Interceptor chain.
  final InterceptorChain interceptorChain;

  /// Request builder.
  final RequestBuilder requestBuilder;

  /// Callback to check if the client has been closed.
  final void Function()? ensureNotClosed;

  /// Sub-resource for ingestion pipeline configurations.
  late final IngestionPipelineConfigurationsResource
  ingestionPipelineConfigurations;

  /// Sub-resource for search indexes.
  late final SearchIndexesResource searchIndexes;

  /// Creates a [RagResource].
  RagResource({
    required this.config,
    required this.httpClient,
    required this.interceptorChain,
    required this.requestBuilder,
    this.ensureNotClosed,
  }) {
    ingestionPipelineConfigurations = IngestionPipelineConfigurationsResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
    searchIndexes = SearchIndexesResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
  }
}
