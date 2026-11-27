import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/observability/create_dataset_record_request.dart';
import '../../models/observability/dataset.dart';
import '../../models/observability/dataset_export.dart';
import '../../models/observability/dataset_import_task.dart';
import '../../models/observability/dataset_import_tasks.dart';
import '../../models/observability/dataset_preview.dart';
import '../../models/observability/dataset_previews.dart';
import '../../models/observability/dataset_record.dart';
import '../../models/observability/dataset_record_batch.dart';
import '../../models/observability/dataset_records.dart';
import '../../models/observability/dataset_span_import.dart';
import '../../models/observability/patch_dataset_in_schema.dart';
import '../../models/observability/post_dataset_import_from_campaign_in_schema.dart';
import '../../models/observability/post_dataset_import_from_dataset_in_schema.dart';
import '../../models/observability/post_dataset_import_from_explorer_in_schema.dart';
import '../../models/observability/post_dataset_import_from_file_in_schema.dart';
import '../../models/observability/post_dataset_import_from_playground_in_schema.dart';
import '../../models/observability/post_dataset_in_schema.dart';
import '../base_resource.dart';
import 'observability_http.dart';

/// Resource for observability dataset operations.
///
/// Provides CRUD for datasets, record management, imports from various
/// sources, exports, and task tracking.
///
/// Example usage:
/// ```dart
/// // Create a dataset
/// final dataset = await client.observability.datasets.create(
///   request: PostDatasetInSchema(
///     name: 'Training Data',
///     description: 'Curated training conversations',
///   ),
/// );
///
/// final records = await client.observability.datasets.listRecords(
///   datasetId: dataset.id,
///   pageSize: 20,
/// );
/// ```
class DatasetsResource extends ResourceBase {
  /// Creates a [DatasetsResource].
  DatasetsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Lists datasets with optional search and pagination.
  Future<DatasetPreviews> list({int? page, int? pageSize, String? query}) =>
      readObservability(
        'GET',
        'datasets',
        DatasetPreviews.fromJson,
        query: {
          'page': ?page?.toString(),
          'page_size': ?pageSize?.toString(),
          'q': ?query,
        },
      );

  /// Creates a new empty dataset.
  Future<Dataset> create({required PostDatasetInSchema request}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/observability/datasets');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return Dataset.fromJson(responseBody);
  }

  /// Gets a dataset by ID.
  Future<DatasetPreview> get({required String datasetId}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/observability/datasets/${Uri.encodeComponent(datasetId)}',
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return DatasetPreview.fromJson(responseBody);
  }

  /// Deletes a dataset.
  Future<void> delete({required String datasetId}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/observability/datasets/${Uri.encodeComponent(datasetId)}',
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);

    await interceptorChain.execute(httpRequest);
  }

  /// Updates a dataset (partial update).
  Future<DatasetPreview> update({
    required String datasetId,
    required PatchDatasetInSchema request,
  }) => readObservability(
    'PATCH',
    'datasets/${Uri.encodeComponent(datasetId)}',
    DatasetPreview.fromJson,
    body: request.toJson(),
  );

  /// Exports a dataset to JSONL format.
  ///
  /// Returns a [DatasetExport] with a presigned URL to download the file.
  Future<DatasetExport> exportToJsonl({required String datasetId}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/observability/datasets/${Uri.encodeComponent(datasetId)}/exports/to-jsonl',
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return DatasetExport.fromJson(responseBody);
  }

  /// Imports records from a campaign.
  ///
  /// Historical API. New applications can use [importFromSpans].
  Future<DatasetImportTask> importFromCampaign({
    required String datasetId,
    required PostDatasetImportFromCampaignInSchema request,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/observability/datasets/${Uri.encodeComponent(datasetId)}/imports/from-campaign',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return DatasetImportTask.fromJson(responseBody);
  }

  /// Imports records from another dataset.
  Future<DatasetImportTask> importFromDataset({
    required String datasetId,
    required PostDatasetImportFromDatasetInSchema request,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/observability/datasets/${Uri.encodeComponent(datasetId)}/imports/from-dataset',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return DatasetImportTask.fromJson(responseBody);
  }

  /// Imports records from the event explorer.
  Future<DatasetImportTask> importFromExplorer({
    required String datasetId,
    required PostDatasetImportFromExplorerInSchema request,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/observability/datasets/${Uri.encodeComponent(datasetId)}/imports/from-explorer',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return DatasetImportTask.fromJson(responseBody);
  }

  /// Imports records from an uploaded file.
  Future<DatasetImportTask> importFromFile({
    required String datasetId,
    required PostDatasetImportFromFileInSchema request,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/observability/datasets/${Uri.encodeComponent(datasetId)}/imports/from-file',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return DatasetImportTask.fromJson(responseBody);
  }

  /// Imports records from the playground.
  ///
  /// Historical API. New applications can use [importFromSpans].
  Future<DatasetImportTask> importFromPlayground({
    required String datasetId,
    required PostDatasetImportFromPlaygroundInSchema request,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/observability/datasets/${Uri.encodeComponent(datasetId)}/imports/from-playground',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return DatasetImportTask.fromJson(responseBody);
  }

  /// Lists records in a dataset.
  Future<DatasetRecords> listRecords({
    required String datasetId,
    int? page,
    int? pageSize,
  }) => readObservability(
    'GET',
    'datasets/${Uri.encodeComponent(datasetId)}/records',
    DatasetRecords.fromJson,
    query: {'page': ?page?.toString(), 'page_size': ?pageSize?.toString()},
  );

  /// Adds a conversation to a dataset.
  Future<DatasetRecord> createRecord({
    required String datasetId,
    required CreateDatasetRecordRequest request,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/observability/datasets/${Uri.encodeComponent(datasetId)}/records',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return DatasetRecord.fromJson(responseBody);
  }

  /// Lists import tasks for a dataset.
  Future<DatasetImportTasks> listTasks({
    required String datasetId,
    int? page,
    int? pageSize,
  }) => readObservability(
    'GET',
    'datasets/${Uri.encodeComponent(datasetId)}/tasks',
    DatasetImportTasks.fromJson,
    query: {'page': ?page?.toString(), 'page_size': ?pageSize?.toString()},
  );

  /// Gets the status of a dataset import task.
  Future<DatasetImportTask> getTask({
    required String datasetId,
    required String taskId,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/observability/datasets/${Uri.encodeComponent(datasetId)}/tasks/${Uri.encodeComponent(taskId)}',
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return DatasetImportTask.fromJson(responseBody);
  }

  /// Creates a batch of dataset records.
  Future<CreateDatasetRecordsResponse> createRecords({
    required String datasetId,
    required CreateDatasetRecordsRequest request,
  }) => readObservability(
    'POST',
    'datasets/${Uri.encodeComponent(datasetId)}/records/bulk',
    CreateDatasetRecordsResponse.fromJson,
    body: request.toJson(),
  );

  /// Starts an import of telemetry spans using a versioned mapping contract.
  Future<DatasetImportTask> importFromSpans({
    required String datasetId,
    required ImportDatasetFromSpansRequest request,
  }) => readObservability(
    'POST',
    'datasets/${Uri.encodeComponent(datasetId)}/imports/from-spans',
    DatasetImportTask.fromJson,
    body: request.toJson(),
  );
}
