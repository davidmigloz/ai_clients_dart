import 'package:meta/meta.dart';

import '../../utils/equality_helpers.dart';
import '../metadata/usage_info.dart';
import 'embedding_data.dart';

/// Response from an embeddings request.
@immutable
class EmbeddingResponse {
  /// Unique identifier for the embeddings request.
  final String id;

  /// The object type (always "list").
  final String object;

  /// The model used for generating embeddings.
  final String model;

  /// List of embedding results.
  final List<EmbeddingData> data;

  /// Token usage information.
  final UsageInfo? usage;

  /// Creates an [EmbeddingResponse].
  const EmbeddingResponse({
    required this.id,
    required this.object,
    required this.model,
    required this.data,
    this.usage,
  });

  /// Creates an [EmbeddingResponse] from JSON.
  factory EmbeddingResponse.fromJson(Map<String, dynamic> json) =>
      EmbeddingResponse(
        id: json['id'] as String? ?? '',
        object: json['object'] as String? ?? 'list',
        model: json['model'] as String? ?? '',
        data:
            (json['data'] as List?)
                ?.map((e) => EmbeddingData.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        usage: json['usage'] != null
            ? UsageInfo.fromJson(json['usage'] as Map<String, dynamic>)
            : null,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'model': model,
    'data': data.map((e) => e.toJson()).toList(),
    if (usage != null) 'usage': usage!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmbeddingResponse &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          object == other.object &&
          model == other.model &&
          listEquals(data, other.data) &&
          usage == other.usage;

  @override
  int get hashCode =>
      Object.hash(id, object, model, Object.hashAll(data), usage);

  @override
  String toString() =>
      'EmbeddingResponse(id: $id, model: $model, data: ${data.length} items)';
}
