import '../../copy_with_sentinel.dart';

/// Configuration for ExaAISearch.
class ExaAISearchConfig {
  /// Required. The API key for ExaAiSearch.
  final String apiKey;

  /// Optional. This field can be used to pass any parameter from the Exa.ai
  /// Search API.
  final Map<String, dynamic>? customConfig;

  /// Creates an [ExaAISearchConfig] instance.
  const ExaAISearchConfig({required this.apiKey, this.customConfig});

  /// Creates an [ExaAISearchConfig] from JSON.
  factory ExaAISearchConfig.fromJson(Map<String, dynamic> json) =>
      ExaAISearchConfig(
        apiKey: json['api_key'] as String,
        customConfig: json['custom_config'] as Map<String, dynamic>?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'api_key': apiKey,
    if (customConfig != null) 'custom_config': customConfig,
  };

  /// Creates a copy with replaced values.
  ExaAISearchConfig copyWith({
    Object? apiKey = unsetCopyWithValue,
    Object? customConfig = unsetCopyWithValue,
  }) {
    return ExaAISearchConfig(
      apiKey: apiKey == unsetCopyWithValue ? this.apiKey : apiKey! as String,
      customConfig: customConfig == unsetCopyWithValue
          ? this.customConfig
          : customConfig as Map<String, dynamic>?,
    );
  }
}
