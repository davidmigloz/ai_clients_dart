import 'package:meta/meta.dart';

/// Provider routing preferences for OpenRouter.
///
/// **OpenRouter only.** Not part of the official OpenAI API.
///
/// This allows controlling which providers are used and how requests
/// are routed when using OpenRouter.
///
/// ## Example
///
/// ```dart
/// final request = ChatCompletionCreateRequest(
///   model: 'openai/gpt-4o',
///   messages: [...],
///   provider: OpenRouterProviderPreferences(
///     order: ['OpenAI', 'Azure'],
///     allowFallbacks: true,
///   ),
/// );
/// ```
@immutable
class OpenRouterProviderPreferences {
  /// Creates [OpenRouterProviderPreferences].
  const OpenRouterProviderPreferences({
    this.order,
    this.allowFallbacks,
    this.requireParameters,
    this.dataCollection,
    this.zdr,
    this.ignore,
    this.quantizations,
    this.sort,
  });

  /// Creates [OpenRouterProviderPreferences] from JSON.
  factory OpenRouterProviderPreferences.fromJson(Map<String, dynamic> json) {
    return OpenRouterProviderPreferences(
      order: (json['order'] as List<dynamic>?)?.cast<String>(),
      allowFallbacks: json['allow_fallbacks'] as bool?,
      requireParameters: json['require_parameters'] as bool?,
      dataCollection: json['data_collection'] as String?,
      zdr: json['zdr'] as bool?,
      ignore: (json['ignore'] as List<dynamic>?)?.cast<String>(),
      quantizations: (json['quantizations'] as List<dynamic>?)?.cast<String>(),
      sort: json['sort'] as String?,
    );
  }

  /// Provider routing order preference.
  ///
  /// List of provider names in order of preference. OpenRouter will try
  /// providers in this order, falling back to others if unavailable.
  final List<String>? order;

  /// Whether to allow fallback to other providers.
  ///
  /// Defaults to `true`. If `false`, only providers in [order] will be used.
  final bool? allowFallbacks;

  /// Whether to require that providers support all request parameters.
  ///
  /// Defaults to `false`. If `true`, providers that don't support all
  /// parameters in the request will be skipped.
  final bool? requireParameters;

  /// Data collection preference.
  ///
  /// Can be `"allow"` or `"deny"`. Controls whether providers can use
  /// your data for training purposes.
  final String? dataCollection;

  /// Zero Data Retention preference.
  ///
  /// If `true`, only providers that don't retain any data will be used.
  final bool? zdr;

  /// Providers to exclude from consideration.
  ///
  /// List of provider names that should never be used for this request.
  final List<String>? ignore;

  /// Acceptable quantization levels.
  ///
  /// Valid values: `int4`, `int8`, `fp8`, `fp16`, `bf16`, `unknown`.
  /// Only providers offering these quantization levels will be used.
  final List<String>? quantizations;

  /// How to sort/prioritize available providers.
  ///
  /// Valid values: `"price"`, `"throughput"`, `"latency"`.
  final String? sort;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (order != null) 'order': order,
    if (allowFallbacks != null) 'allow_fallbacks': allowFallbacks,
    if (requireParameters != null) 'require_parameters': requireParameters,
    if (dataCollection != null) 'data_collection': dataCollection,
    if (zdr != null) 'zdr': zdr,
    if (ignore != null) 'ignore': ignore,
    if (quantizations != null) 'quantizations': quantizations,
    if (sort != null) 'sort': sort,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OpenRouterProviderPreferences &&
          runtimeType == other.runtimeType &&
          _listEquals(order, other.order) &&
          allowFallbacks == other.allowFallbacks &&
          requireParameters == other.requireParameters &&
          dataCollection == other.dataCollection &&
          zdr == other.zdr &&
          _listEquals(ignore, other.ignore) &&
          _listEquals(quantizations, other.quantizations) &&
          sort == other.sort;

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    order != null ? Object.hashAll(order!) : null,
    allowFallbacks,
    requireParameters,
    dataCollection,
    zdr,
    ignore != null ? Object.hashAll(ignore!) : null,
    quantizations != null ? Object.hashAll(quantizations!) : null,
    sort,
  );

  @override
  String toString() => 'OpenRouterProviderPreferences(order: $order)';
}

/// Usage configuration for OpenRouter.
///
/// **OpenRouter only.** Not part of the official OpenAI API.
///
/// Controls whether detailed token usage information is included in responses.
@immutable
class OpenRouterUsageConfig {
  /// Creates an [OpenRouterUsageConfig].
  const OpenRouterUsageConfig({this.include});

  /// Creates an [OpenRouterUsageConfig] from JSON.
  factory OpenRouterUsageConfig.fromJson(Map<String, dynamic> json) {
    return OpenRouterUsageConfig(include: json['include'] as bool?);
  }

  /// Whether to include detailed token usage information.
  final bool? include;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {if (include != null) 'include': include};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OpenRouterUsageConfig &&
          runtimeType == other.runtimeType &&
          include == other.include;

  @override
  int get hashCode => include.hashCode;

  @override
  String toString() => 'OpenRouterUsageConfig(include: $include)';
}

/// Reasoning configuration for OpenRouter.
///
/// **OpenRouter only.** Not part of the official OpenAI API.
///
/// Controls reasoning behavior for models that support it (e.g., DeepSeek R1).
/// This is different from OpenAI's [ReasoningEffort] which is a simple enum.
@immutable
class OpenRouterReasoning {
  /// Creates an [OpenRouterReasoning].
  const OpenRouterReasoning({
    this.effort,
    this.maxTokens,
    this.exclude,
    this.enabled,
  });

  /// Creates an [OpenRouterReasoning] from JSON.
  factory OpenRouterReasoning.fromJson(Map<String, dynamic> json) {
    return OpenRouterReasoning(
      effort: json['effort'] as String?,
      maxTokens: json['max_tokens'] as int?,
      exclude: json['exclude'] as bool?,
      enabled: json['enabled'] as bool?,
    );
  }

  /// Reasoning effort level.
  ///
  /// Valid values: `"high"`, `"medium"`, `"low"`.
  final String? effort;

  /// Maximum tokens for reasoning.
  ///
  /// Valid range: 1024-32000.
  final int? maxTokens;

  /// Whether to exclude reasoning from the output.
  ///
  /// If `true`, reasoning tokens will not be included in the response content.
  final bool? exclude;

  /// Whether reasoning is enabled.
  final bool? enabled;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (effort != null) 'effort': effort,
    if (maxTokens != null) 'max_tokens': maxTokens,
    if (exclude != null) 'exclude': exclude,
    if (enabled != null) 'enabled': enabled,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OpenRouterReasoning &&
          runtimeType == other.runtimeType &&
          effort == other.effort &&
          maxTokens == other.maxTokens &&
          exclude == other.exclude &&
          enabled == other.enabled;

  @override
  int get hashCode => Object.hash(effort, maxTokens, exclude, enabled);

  @override
  String toString() => 'OpenRouterReasoning(effort: $effort)';
}
