import '../../copy_with_sentinel.dart';

/// Configuration for ParallelAISearch.
class ParallelAISearchConfig {
  /// Optional. The API key for ParallelAiSearch.
  final String? apiKey;

  /// Optional. Custom configs for ParallelAiSearch.
  final Map<String, dynamic>? customConfig;

  /// Creates a [ParallelAISearchConfig] instance.
  const ParallelAISearchConfig({this.apiKey, this.customConfig});

  /// Creates a [ParallelAISearchConfig] from JSON.
  factory ParallelAISearchConfig.fromJson(Map<String, dynamic> json) =>
      ParallelAISearchConfig(
        apiKey: json['api_key'] as String?,
        customConfig: json['custom_config'] as Map<String, dynamic>?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (apiKey != null) 'api_key': apiKey,
    if (customConfig != null) 'custom_config': customConfig,
  };

  /// Creates a copy with replaced values.
  ParallelAISearchConfig copyWith({
    Object? apiKey = unsetCopyWithValue,
    Object? customConfig = unsetCopyWithValue,
  }) {
    return ParallelAISearchConfig(
      apiKey: apiKey == unsetCopyWithValue ? this.apiKey : apiKey as String?,
      customConfig: customConfig == unsetCopyWithValue
          ? this.customConfig
          : customConfig as Map<String, dynamic>?,
    );
  }
}
