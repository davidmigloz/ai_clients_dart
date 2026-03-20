import '../copy_with_sentinel.dart';
import '../metadata/retrieval_config.dart';
import 'function_calling_config.dart';

/// The Tool configuration containing parameters for specifying Tool use
/// in the request.
class ToolConfig {
  /// Function calling config.
  final FunctionCallingConfig? functionCallingConfig;

  /// Whether to include server-side tool invocations in the response.
  final bool? includeServerSideToolInvocations;

  /// Retrieval config for tools like Google Search or FileSearch.
  final RetrievalConfig? retrievalConfig;

  /// Creates a [ToolConfig].
  const ToolConfig({
    this.functionCallingConfig,
    this.includeServerSideToolInvocations,
    this.retrievalConfig,
  });

  /// Creates a [ToolConfig] from JSON.
  factory ToolConfig.fromJson(Map<String, dynamic> json) => ToolConfig(
    functionCallingConfig: json['functionCallingConfig'] != null
        ? FunctionCallingConfig.fromJson(
            json['functionCallingConfig'] as Map<String, dynamic>,
          )
        : null,
    includeServerSideToolInvocations:
        json['includeServerSideToolInvocations'] as bool?,
    retrievalConfig: json['retrievalConfig'] != null
        ? RetrievalConfig.fromJson(
            json['retrievalConfig'] as Map<String, dynamic>,
          )
        : null,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (functionCallingConfig != null)
      'functionCallingConfig': functionCallingConfig!.toJson(),
    if (includeServerSideToolInvocations != null)
      'includeServerSideToolInvocations': includeServerSideToolInvocations,
    if (retrievalConfig != null) 'retrievalConfig': retrievalConfig!.toJson(),
  };

  /// Creates a copy with replaced values.
  ToolConfig copyWith({
    Object? functionCallingConfig = unsetCopyWithValue,
    Object? includeServerSideToolInvocations = unsetCopyWithValue,
    Object? retrievalConfig = unsetCopyWithValue,
  }) {
    return ToolConfig(
      functionCallingConfig: functionCallingConfig == unsetCopyWithValue
          ? this.functionCallingConfig
          : functionCallingConfig as FunctionCallingConfig?,
      includeServerSideToolInvocations:
          includeServerSideToolInvocations == unsetCopyWithValue
          ? this.includeServerSideToolInvocations
          : includeServerSideToolInvocations as bool?,
      retrievalConfig: retrievalConfig == unsetCopyWithValue
          ? this.retrievalConfig
          : retrievalConfig as RetrievalConfig?,
    );
  }
}
