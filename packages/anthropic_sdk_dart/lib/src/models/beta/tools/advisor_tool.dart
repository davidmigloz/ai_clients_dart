part of '../../tools/built_in_tools.dart';

/// Advisor tool for pairing an executor model with a stronger advisor (Beta).
///
/// The advisor tool lets a faster, lower-cost executor model consult a
/// higher-intelligence advisor model mid-generation for strategic guidance.
/// The advisor reads the full conversation, produces a plan or course
/// correction, and the executor continues with the task.
///
/// Requires the `advisor-tool-2026-03-01` beta header.
///
/// ```dart
/// final response = await client.messages.create(
///   MessageCreateRequest(
///     model: 'claude-sonnet-4-6',
///     maxTokens: 4096,
///     tools: [
///       ToolDefinition.builtIn(
///         AdvisorTool(model: 'claude-opus-4-6'),
///       ),
///     ],
///     messages: [InputMessage.user('Plan a Go worker pool.')],
///   ),
///   betas: ['advisor-tool-2026-03-01'],
/// );
/// ```
@immutable
class AdvisorTool extends BuiltInTool {
  /// The tool type version.
  final String type;

  /// The advisor model ID (e.g., `'claude-opus-4-6'`).
  final String model;

  /// Maximum number of advisor calls allowed in a single request.
  final int? maxUses;

  /// Caching for the advisor's own prompt.
  ///
  /// When set, each advisor call writes a cache entry at the given TTL
  /// so subsequent calls in the same conversation read the stable prefix.
  final CacheControlEphemeral? caching;

  /// Cache control breakpoint for the tool definition itself.
  final CacheControlEphemeral? cacheControl;

  /// Creates an [AdvisorTool].
  const AdvisorTool({
    String? type,
    required this.model,
    this.maxUses,
    this.caching,
    this.cacheControl,
  }) : type = type ?? 'advisor_20260301';

  /// Creates an [AdvisorTool] from JSON.
  factory AdvisorTool.fromJson(Map<String, dynamic> json) {
    return AdvisorTool(
      type: json['type'] as String? ?? 'advisor_20260301',
      model: json['model'] as String,
      maxUses: json['max_uses'] as int?,
      caching: json['caching'] != null
          ? CacheControlEphemeral.fromJson(
              json['caching'] as Map<String, dynamic>,
            )
          : null,
      cacheControl: json['cache_control'] != null
          ? CacheControlEphemeral.fromJson(
              json['cache_control'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'name': 'advisor',
    'model': model,
    if (maxUses != null) 'max_uses': maxUses,
    if (caching != null) 'caching': caching!.toJson(),
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
  };

  /// Creates a copy with replaced values.
  AdvisorTool copyWith({
    String? type,
    String? model,
    Object? maxUses = unsetCopyWithValue,
    Object? caching = unsetCopyWithValue,
    Object? cacheControl = unsetCopyWithValue,
  }) {
    return AdvisorTool(
      type: type ?? this.type,
      model: model ?? this.model,
      maxUses: maxUses == unsetCopyWithValue ? this.maxUses : maxUses as int?,
      caching: caching == unsetCopyWithValue
          ? this.caching
          : caching as CacheControlEphemeral?,
      cacheControl: cacheControl == unsetCopyWithValue
          ? this.cacheControl
          : cacheControl as CacheControlEphemeral?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdvisorTool &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          model == other.model &&
          maxUses == other.maxUses &&
          caching == other.caching &&
          cacheControl == other.cacheControl;

  @override
  int get hashCode => Object.hash(type, model, maxUses, caching, cacheControl);

  @override
  String toString() =>
      'AdvisorTool(type: $type, model: $model, maxUses: $maxUses, '
      'caching: $caching, cacheControl: $cacheControl)';
}
