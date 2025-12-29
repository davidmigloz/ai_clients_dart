import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Response from embedding generation.
@immutable
class EmbedResponse {
  /// Model that produced the embeddings.
  final String? model;

  /// Array of vector embeddings.
  final List<List<double>>? embeddings;

  /// Total time spent generating in nanoseconds.
  final int? totalDuration;

  /// Load time in nanoseconds.
  final int? loadDuration;

  /// Number of input tokens processed to generate embeddings.
  final int? promptEvalCount;

  /// Creates an [EmbedResponse].
  const EmbedResponse({
    this.model,
    this.embeddings,
    this.totalDuration,
    this.loadDuration,
    this.promptEvalCount,
  });

  /// Creates an [EmbedResponse] from JSON.
  factory EmbedResponse.fromJson(Map<String, dynamic> json) => EmbedResponse(
    model: json['model'] as String?,
    embeddings: (json['embeddings'] as List?)
        ?.map((e) => (e as List).map((v) => (v as num).toDouble()).toList())
        .toList(),
    totalDuration: json['total_duration'] as int?,
    loadDuration: json['load_duration'] as int?,
    promptEvalCount: json['prompt_eval_count'] as int?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (model != null) 'model': model,
    if (embeddings != null) 'embeddings': embeddings,
    if (totalDuration != null) 'total_duration': totalDuration,
    if (loadDuration != null) 'load_duration': loadDuration,
    if (promptEvalCount != null) 'prompt_eval_count': promptEvalCount,
  };

  /// Creates a copy with replaced values.
  EmbedResponse copyWith({
    Object? model = unsetCopyWithValue,
    Object? embeddings = unsetCopyWithValue,
    Object? totalDuration = unsetCopyWithValue,
    Object? loadDuration = unsetCopyWithValue,
    Object? promptEvalCount = unsetCopyWithValue,
  }) {
    return EmbedResponse(
      model: model == unsetCopyWithValue ? this.model : model as String?,
      embeddings: embeddings == unsetCopyWithValue
          ? this.embeddings
          : embeddings as List<List<double>>?,
      totalDuration: totalDuration == unsetCopyWithValue
          ? this.totalDuration
          : totalDuration as int?,
      loadDuration: loadDuration == unsetCopyWithValue
          ? this.loadDuration
          : loadDuration as int?,
      promptEvalCount: promptEvalCount == unsetCopyWithValue
          ? this.promptEvalCount
          : promptEvalCount as int?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmbedResponse &&
          runtimeType == other.runtimeType &&
          model == other.model;

  @override
  int get hashCode => model.hashCode;

  @override
  String toString() =>
      'EmbedResponse(model: $model, '
      'embeddings: ${embeddings?.length ?? 0} vectors)';
}
