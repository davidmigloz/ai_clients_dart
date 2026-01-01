import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../metadata/metadata.dart';
import '../metadata/stop_reason.dart';

/// Legacy completion request.
///
/// This is the deprecated text completion API. Use messages API instead.
@Deprecated('Use MessageCreateRequest instead')
@immutable
class CompletionRequest {
  /// The model to use.
  final String model;

  /// The prompt to complete.
  final String prompt;

  /// Maximum number of tokens to generate.
  final int maxTokensToSample;

  /// Custom stop sequences.
  final List<String>? stopSequences;

  /// Whether to stream the response.
  final bool? stream;

  /// Temperature for randomness (0.0-1.0).
  final double? temperature;

  /// Nucleus sampling parameter.
  final double? topP;

  /// Top-K sampling parameter.
  final int? topK;

  /// Request metadata.
  final Metadata? metadata;

  /// Creates a [CompletionRequest].
  @Deprecated('Use MessageCreateRequest instead')
  const CompletionRequest({
    required this.model,
    required this.prompt,
    required this.maxTokensToSample,
    this.stopSequences,
    this.stream,
    this.temperature,
    this.topP,
    this.topK,
    this.metadata,
  });

  /// Creates a [CompletionRequest] from JSON.
  @Deprecated('Use MessageCreateRequest instead')
  factory CompletionRequest.fromJson(Map<String, dynamic> json) {
    return CompletionRequest(
      model: json['model'] as String,
      prompt: json['prompt'] as String,
      maxTokensToSample: json['max_tokens_to_sample'] as int,
      stopSequences: (json['stop_sequences'] as List?)?.cast<String>(),
      stream: json['stream'] as bool?,
      temperature: (json['temperature'] as num?)?.toDouble(),
      topP: (json['top_p'] as num?)?.toDouble(),
      topK: json['top_k'] as int?,
      metadata: json['metadata'] != null
          ? Metadata.fromJson(json['metadata'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'model': model,
    'prompt': prompt,
    'max_tokens_to_sample': maxTokensToSample,
    if (stopSequences != null) 'stop_sequences': stopSequences,
    if (stream != null) 'stream': stream,
    if (temperature != null) 'temperature': temperature,
    if (topP != null) 'top_p': topP,
    if (topK != null) 'top_k': topK,
    if (metadata != null) 'metadata': metadata!.toJson(),
  };

  /// Creates a copy with replaced values.
  CompletionRequest copyWith({
    String? model,
    String? prompt,
    int? maxTokensToSample,
    Object? stopSequences = unsetCopyWithValue,
    Object? stream = unsetCopyWithValue,
    Object? temperature = unsetCopyWithValue,
    Object? topP = unsetCopyWithValue,
    Object? topK = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
  }) {
    return CompletionRequest(
      model: model ?? this.model,
      prompt: prompt ?? this.prompt,
      maxTokensToSample: maxTokensToSample ?? this.maxTokensToSample,
      stopSequences: stopSequences == unsetCopyWithValue
          ? this.stopSequences
          : stopSequences as List<String>?,
      stream: stream == unsetCopyWithValue ? this.stream : stream as bool?,
      temperature: temperature == unsetCopyWithValue
          ? this.temperature
          : temperature as double?,
      topP: topP == unsetCopyWithValue ? this.topP : topP as double?,
      topK: topK == unsetCopyWithValue ? this.topK : topK as int?,
      metadata: metadata == unsetCopyWithValue
          ? this.metadata
          : metadata as Metadata?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompletionRequest &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          prompt == other.prompt &&
          maxTokensToSample == other.maxTokensToSample &&
          _listsEqual(stopSequences, other.stopSequences) &&
          stream == other.stream &&
          temperature == other.temperature &&
          topP == other.topP &&
          topK == other.topK &&
          metadata == other.metadata;

  @override
  int get hashCode => Object.hash(
    model,
    prompt,
    maxTokensToSample,
    stopSequences,
    stream,
    temperature,
    topP,
    topK,
    metadata,
  );

  @override
  String toString() =>
      'CompletionRequest(model: $model, prompt: [${prompt.length} chars], '
      'maxTokensToSample: $maxTokensToSample, stopSequences: $stopSequences, '
      'stream: $stream, temperature: $temperature, topP: $topP, topK: $topK, '
      'metadata: $metadata)';
}

/// Legacy completion response.
///
/// This is the deprecated text completion API response.
@Deprecated('Use Message instead')
@immutable
class CompletionResponse {
  /// Unique completion identifier.
  final String id;

  /// Object type. Always "completion".
  final String type;

  /// The generated completion text.
  final String completion;

  /// The stop reason.
  final StopReason? stopReason;

  /// The model used.
  final String model;

  /// Creates a [CompletionResponse].
  @Deprecated('Use Message instead')
  const CompletionResponse({
    required this.id,
    this.type = 'completion',
    required this.completion,
    this.stopReason,
    required this.model,
  });

  /// Creates a [CompletionResponse] from JSON.
  @Deprecated('Use Message instead')
  factory CompletionResponse.fromJson(Map<String, dynamic> json) {
    return CompletionResponse(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'completion',
      completion: json['completion'] as String,
      stopReason: json['stop_reason'] != null
          ? StopReason.fromJson(json['stop_reason'] as String)
          : null,
      model: json['model'] as String,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'completion': completion,
    if (stopReason != null) 'stop_reason': stopReason!.toJson(),
    'model': model,
  };

  /// Creates a copy with replaced values.
  CompletionResponse copyWith({
    String? id,
    String? type,
    String? completion,
    Object? stopReason = unsetCopyWithValue,
    String? model,
  }) {
    return CompletionResponse(
      id: id ?? this.id,
      type: type ?? this.type,
      completion: completion ?? this.completion,
      stopReason: stopReason == unsetCopyWithValue
          ? this.stopReason
          : stopReason as StopReason?,
      model: model ?? this.model,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompletionResponse &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          completion == other.completion &&
          stopReason == other.stopReason &&
          model == other.model;

  @override
  int get hashCode => Object.hash(id, type, completion, stopReason, model);

  @override
  String toString() =>
      'CompletionResponse(id: $id, type: $type, '
      'completion: [${completion.length} chars], '
      'stopReason: $stopReason, model: $model)';
}

bool _listsEqual<T>(List<T>? a, List<T>? b) {
  if (a == null && b == null) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
