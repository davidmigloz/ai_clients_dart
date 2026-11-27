import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'batch_request.dart';

/// Request to create a batch job.
@immutable
class CreateBatchJobRequest {
  /// The list of input file IDs containing batch requests.
  ///
  /// Each file must be in JSONL format where each line is a valid request
  /// object. Typically either [inputFiles] or [requests] is provided.
  final List<String>? inputFiles;

  /// The API endpoint to process requests against.
  ///
  /// Common endpoints:
  /// - `/v1/chat/completions` - Chat completion requests
  /// - `/v1/embeddings` - Embedding requests
  /// - `/v1/moderations` - Moderation requests
  final String endpoint;

  /// The model to use for processing all requests.
  final String? model;

  /// Agent ID for an agents completion batch.
  final String? agentId;

  /// Optional metadata for the batch job.
  final Map<String, dynamic>? metadata;

  /// Timeout in hours for completing the batch job.
  ///
  /// If not completed within this time, the job will be marked as timed out.
  /// Must be between 1 and 168.
  final int? timeoutHours;

  /// Inline batch requests.
  ///
  /// Alternative to using [inputFiles] for providing requests directly.
  final List<BatchRequest>? requests;

  /// Creates a [CreateBatchJobRequest].
  const CreateBatchJobRequest({
    this.inputFiles,
    required this.endpoint,
    this.model,
    this.agentId,
    this.metadata,
    this.timeoutHours,
    this.requests,
  });

  /// Creates a [CreateBatchJobRequest] from JSON.
  factory CreateBatchJobRequest.fromJson(Map<String, dynamic> json) =>
      CreateBatchJobRequest(
        inputFiles: (json['input_files'] as List?)?.cast<String>(),
        endpoint: json['endpoint'] as String? ?? '',
        model: json['model'] as String?,
        agentId: json['agent_id'] as String?,
        metadata: json['metadata'] as Map<String, dynamic>?,
        timeoutHours: json['timeout_hours'] as int?,
        requests: (json['requests'] as List?)
            ?.map((e) => BatchRequest.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (inputFiles != null) 'input_files': inputFiles,
    'endpoint': endpoint,
    if (model != null) 'model': model,
    if (agentId != null) 'agent_id': agentId,
    if (metadata != null) 'metadata': metadata,
    if (timeoutHours != null) 'timeout_hours': timeoutHours,
    if (requests != null) 'requests': requests!.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with the specified fields replaced.
  CreateBatchJobRequest copyWith({
    Object? inputFiles = unsetCopyWithValue,
    String? endpoint,
    Object? model = unsetCopyWithValue,
    Object? agentId = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
    Object? timeoutHours = unsetCopyWithValue,
    Object? requests = unsetCopyWithValue,
  }) => CreateBatchJobRequest(
    inputFiles: identical(inputFiles, unsetCopyWithValue)
        ? this.inputFiles
        : inputFiles as List<String>?,
    endpoint: endpoint ?? this.endpoint,
    model: identical(model, unsetCopyWithValue) ? this.model : model as String?,
    agentId: identical(agentId, unsetCopyWithValue)
        ? this.agentId
        : agentId as String?,
    metadata: identical(metadata, unsetCopyWithValue)
        ? this.metadata
        : metadata as Map<String, dynamic>?,
    timeoutHours: identical(timeoutHours, unsetCopyWithValue)
        ? this.timeoutHours
        : timeoutHours as int?,
    requests: identical(requests, unsetCopyWithValue)
        ? this.requests
        : requests as List<BatchRequest>?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateBatchJobRequest &&
          runtimeType == other.runtimeType &&
          listsEqual(inputFiles, other.inputFiles) &&
          endpoint == other.endpoint &&
          model == other.model &&
          agentId == other.agentId &&
          mapsDeepEqual(metadata, other.metadata) &&
          timeoutHours == other.timeoutHours &&
          listsEqual(requests, other.requests);

  @override
  int get hashCode => Object.hash(
    listHash(inputFiles),
    endpoint,
    model,
    agentId,
    mapDeepHashCode(metadata),
    timeoutHours,
    listHash(requests),
  );

  @override
  String toString() =>
      'CreateBatchJobRequest(inputFiles: $inputFiles, endpoint: $endpoint, model: $model, '
      'agentId: $agentId, timeoutHours: $timeoutHours, '
      'metadata: ${metadata?.length}, requests: ${requests?.length})';
}
