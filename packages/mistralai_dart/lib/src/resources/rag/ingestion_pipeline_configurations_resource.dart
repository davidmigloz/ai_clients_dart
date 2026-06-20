import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/rag/create_ingestion_pipeline_configuration_request.dart';
import '../../models/rag/ingestion_pipeline_configuration.dart';
import '../../models/rag/update_run_info.dart';
import '../base_resource.dart';

/// Resource for RAG ingestion pipeline configuration operations (beta).
///
/// Ingestion pipeline configurations describe how documents are processed and
/// chunked before being indexed for retrieval.
///
/// Example usage:
/// ```dart
/// // List configurations
/// final configs =
///     await client.rag.ingestionPipelineConfigurations.list();
///
/// // Register a configuration
/// final config = await client.rag.ingestionPipelineConfigurations.register(
///   request: const CreateIngestionPipelineConfigurationRequest(
///     name: 'My pipeline',
///   ),
/// );
/// ```
class IngestionPipelineConfigurationsResource extends ResourceBase {
  /// Creates an [IngestionPipelineConfigurationsResource].
  IngestionPipelineConfigurationsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Lists the registered ingestion pipeline configurations.
  ///
  /// For the current workspace, lists all of the registered ingestion pipeline
  /// configurations.
  ///
  /// Maps to the official `ingestion_pipeline_configurations.list`
  /// (`GET /v1/rag/ingestion_pipeline_configurations`).
  Future<List<IngestionPipelineConfiguration>> list() async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/rag/ingestion_pipeline_configurations',
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as List<dynamic>;
    return responseBody
        .map(
          (e) => IngestionPipelineConfiguration.fromJson(
            e as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  /// Registers a new ingestion pipeline configuration.
  ///
  /// Maps to the official `ingestion_pipeline_configurations.register`
  /// (`PUT /v1/rag/ingestion_pipeline_configurations`).
  Future<IngestionPipelineConfiguration> register({
    required CreateIngestionPipelineConfigurationRequest request,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/rag/ingestion_pipeline_configurations',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('PUT', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return IngestionPipelineConfiguration.fromJson(responseBody);
  }

  /// Updates the run info of an ingestion pipeline configuration.
  ///
  /// Maps to the official `ingestion_pipeline_configurations.update_run_info`
  /// (`PUT /v1/rag/ingestion_pipeline_configurations/{id}/run_info`).
  ///
  /// [id] is the unique identifier of the configuration.
  Future<IngestionPipelineConfiguration> updateRunInfo({
    required String id,
    required UpdateRunInfo request,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/rag/ingestion_pipeline_configurations/$id/run_info',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('PUT', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return IngestionPipelineConfiguration.fromJson(responseBody);
  }
}
