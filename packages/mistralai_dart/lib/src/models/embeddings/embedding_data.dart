import 'package:meta/meta.dart';

import '../../utils/equality_helpers.dart';

/// A single embedding result.
@immutable
class EmbeddingData {
  /// The object type (always "embedding").
  final String object;

  /// The index of this embedding in the list of results.
  final int index;

  /// The embedding vector.
  ///
  /// A list of floating point numbers representing the embedding.
  final List<double> embedding;

  /// Creates an [EmbeddingData].
  const EmbeddingData({
    required this.object,
    required this.index,
    required this.embedding,
  });

  /// Creates an [EmbeddingData] from JSON.
  factory EmbeddingData.fromJson(Map<String, dynamic> json) => EmbeddingData(
    object: json['object'] as String? ?? 'embedding',
    index: json['index'] as int? ?? 0,
    embedding:
        (json['embedding'] as List?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        [],
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'object': object,
    'index': index,
    'embedding': embedding,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmbeddingData &&
          runtimeType == other.runtimeType &&
          object == other.object &&
          index == other.index &&
          listEquals(embedding, other.embedding);

  @override
  int get hashCode => Object.hash(object, index, embedding);

  @override
  String toString() =>
      'EmbeddingData(index: $index, embedding: [${embedding.length} dims])';
}
