import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Response from embedding generation.
@immutable
class EmbedResponse {
  /// Model that produced the embeddings.
  final String? model;

  /// Array of vector embeddings.
  final List<List<double>>? embeddings;

  /// Convenience getter for the first embedding.
  ///
  /// Returns the first embedding in the [embeddings] list, or `null` if
  /// the list is empty or null. Useful when generating a single embedding.
  List<double>? get embedding => embeddings?.firstOrNull;

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
          model == other.model &&
          _nestedListsEqual(embeddings, other.embeddings) &&
          totalDuration == other.totalDuration &&
          loadDuration == other.loadDuration &&
          promptEvalCount == other.promptEvalCount;

  @override
  int get hashCode => Object.hash(
    model,
    embeddings == null
        ? null.hashCode
        : Object.hashAll(embeddings!.map(listHash)),
    totalDuration,
    loadDuration,
    promptEvalCount,
  );

  @override
  String toString() =>
      'EmbedResponse('
      'model: $model, '
      'embeddings: ${embeddings?.length ?? 0} vectors, '
      'totalDuration: $totalDuration, '
      'loadDuration: $loadDuration, '
      'promptEvalCount: $promptEvalCount)';
}

/// Compares two nested lists for equality.
bool _nestedListsEqual(List<List<double>>? a, List<List<double>>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (!listsEqual(a[i], b[i])) return false;
  }
  return true;
}
