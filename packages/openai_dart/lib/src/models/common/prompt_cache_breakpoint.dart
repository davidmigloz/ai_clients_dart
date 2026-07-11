import 'package:meta/meta.dart';

/// Marks the exact end of a reusable prompt prefix.
///
/// The breakpoint inherits its TTL from the request's
/// `prompt_cache_options.ttl`; the boundary is not rounded to a token block.
///
/// Used both as a request parameter (attached to a content block to request
/// an explicit cache breakpoint) and echoed back unchanged when present on
/// response content.
@immutable
class PromptCacheBreakpointConfig {
  /// The breakpoint mode. Always `explicit`.
  String get mode => 'explicit';

  /// Creates a [PromptCacheBreakpointConfig].
  const PromptCacheBreakpointConfig();

  /// Creates a [PromptCacheBreakpointConfig] from JSON.
  // ignore: avoid_unused_constructor_parameters
  factory PromptCacheBreakpointConfig.fromJson(Map<String, dynamic> json) {
    return const PromptCacheBreakpointConfig();
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'mode': mode};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PromptCacheBreakpointConfig && runtimeType == other.runtimeType;

  @override
  int get hashCode => mode.hashCode;

  @override
  String toString() => 'PromptCacheBreakpointConfig()';
}
