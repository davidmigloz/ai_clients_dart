import 'package:meta/meta.dart';

/// Request to create a batch job.
@immutable
class CreateBatchJobRequest {
  /// The ID of the input file containing batch requests.
  ///
  /// The file must be in JSONL format where each line is a valid request object.
  final String inputFileId;

  /// The API endpoint to process requests against.
  ///
  /// Common endpoints:
  /// - `/v1/chat/completions` - Chat completion requests
  /// - `/v1/embeddings` - Embedding requests
  /// - `/v1/moderations` - Moderation requests
  final String endpoint;

  /// The model to use for processing all requests.
  final String model;

  /// Optional metadata for the batch job.
  final Map<String, dynamic>? metadata;

  /// Timeout in seconds for completing the batch job.
  ///
  /// If not completed within this time, the job will be marked as timed out.
  final int? timeoutHours;

  /// Creates a [CreateBatchJobRequest].
  const CreateBatchJobRequest({
    required this.inputFileId,
    required this.endpoint,
    required this.model,
    this.metadata,
    this.timeoutHours,
  });

  /// Creates a [CreateBatchJobRequest] from JSON.
  factory CreateBatchJobRequest.fromJson(Map<String, dynamic> json) =>
      CreateBatchJobRequest(
        inputFileId:
            json['input_files'] as String? ??
            json['input_file_id'] as String? ??
            '',
        endpoint: json['endpoint'] as String? ?? '',
        model: json['model'] as String? ?? '',
        metadata: json['metadata'] as Map<String, dynamic>?,
        timeoutHours: json['timeout_hours'] as int?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'input_files': inputFileId,
    'endpoint': endpoint,
    'model': model,
    if (metadata != null) 'metadata': metadata,
    if (timeoutHours != null) 'timeout_hours': timeoutHours,
  };

  /// Creates a copy with the specified fields replaced.
  CreateBatchJobRequest copyWith({
    String? inputFileId,
    String? endpoint,
    String? model,
    Map<String, dynamic>? metadata,
    int? timeoutHours,
  }) => CreateBatchJobRequest(
    inputFileId: inputFileId ?? this.inputFileId,
    endpoint: endpoint ?? this.endpoint,
    model: model ?? this.model,
    metadata: metadata ?? this.metadata,
    timeoutHours: timeoutHours ?? this.timeoutHours,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateBatchJobRequest &&
          runtimeType == other.runtimeType &&
          inputFileId == other.inputFileId &&
          endpoint == other.endpoint &&
          model == other.model;

  @override
  int get hashCode => Object.hash(inputFileId, endpoint, model);

  @override
  String toString() =>
      'CreateBatchJobRequest(inputFileId: $inputFileId, endpoint: $endpoint, model: $model)';
}
