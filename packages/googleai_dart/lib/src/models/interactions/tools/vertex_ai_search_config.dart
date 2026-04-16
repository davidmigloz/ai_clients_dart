import '../../copy_with_sentinel.dart';

/// Configuration for Vertex AI Search.
class VertexAISearchConfig {
  /// Optional. Vertex AI Search datastores.
  final List<String>? datastores;

  /// Optional. Vertex AI Search engine.
  final String? engine;

  /// Creates a [VertexAISearchConfig] instance.
  const VertexAISearchConfig({this.datastores, this.engine});

  /// Creates a [VertexAISearchConfig] from JSON.
  factory VertexAISearchConfig.fromJson(Map<String, dynamic> json) =>
      VertexAISearchConfig(
        datastores: (json['datastores'] as List<dynamic>?)?.cast<String>(),
        engine: json['engine'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (datastores != null) 'datastores': datastores,
    if (engine != null) 'engine': engine,
  };

  /// Creates a copy with replaced values.
  VertexAISearchConfig copyWith({
    Object? datastores = unsetCopyWithValue,
    Object? engine = unsetCopyWithValue,
  }) {
    return VertexAISearchConfig(
      datastores: datastores == unsetCopyWithValue
          ? this.datastores
          : datastores as List<String>?,
      engine: engine == unsetCopyWithValue ? this.engine : engine as String?,
    );
  }
}
