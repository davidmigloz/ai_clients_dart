import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/observability/dataset_record.dart';
import '../../models/observability/delete_dataset_records_in_schema.dart';
import '../../models/observability/judge_output.dart';
import '../../models/observability/post_dataset_record_judging_in_schema.dart';
import '../../models/observability/put_dataset_record_payload_in_schema.dart';
import '../../models/observability/put_dataset_record_properties_in_schema.dart';
import '../base_resource.dart';

/// Resource for dataset record operations.
///
/// Provides methods to get, delete, judge, and update individual dataset
/// records by their ID.
///
/// Example usage:
/// ```dart
/// // Get a record
/// final record = await client.observability.datasetRecords.get(
///   datasetRecordId: 'record-id',
/// );
///
/// // Update properties
/// await client.observability.datasetRecords.updateProperties(
///   datasetRecordId: 'record-id',
///   request: PutDatasetRecordPropertiesInSchema(
///     properties: {'label': 'good'},
///   ),
/// );
/// ```
class DatasetRecordsResource extends ResourceBase {
  /// Creates a [DatasetRecordsResource].
  DatasetRecordsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Gets a dataset record by ID.
  Future<DatasetRecord> get({required String datasetRecordId}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/observability/dataset-records/$datasetRecordId',
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return DatasetRecord.fromJson(responseBody);
  }

  /// Deletes a dataset record by ID.
  Future<void> delete({required String datasetRecordId}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/observability/dataset-records/$datasetRecordId',
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);

    await interceptorChain.execute(httpRequest);
  }

  /// Deletes multiple dataset records.
  Future<void> bulkDelete({
    required DeleteDatasetRecordsInSchema request,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/observability/dataset-records/bulk-delete',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    await interceptorChain.execute(httpRequest);
  }

  /// Runs a judge on a dataset record.
  Future<JudgeOutput> liveJudging({
    required String datasetRecordId,
    required PostDatasetRecordJudgingInSchema request,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/observability/dataset-records/$datasetRecordId/live-judging',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return JudgeOutput.fromJson(responseBody);
  }

  /// Updates a dataset record's conversation payload.
  Future<void> updatePayload({
    required String datasetRecordId,
    required PutDatasetRecordPayloadInSchema request,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/observability/dataset-records/$datasetRecordId/payload',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('PUT', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    await interceptorChain.execute(httpRequest);
  }

  /// Updates a dataset record's properties.
  Future<void> updateProperties({
    required String datasetRecordId,
    required PutDatasetRecordPropertiesInSchema request,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/observability/dataset-records/$datasetRecordId/properties',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('PUT', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    await interceptorChain.execute(httpRequest);
  }
}
