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
///         AdvisorTool(model: 'claude-opus-4-8'),
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

  /// The advisor model ID (e.g., `'claude-opus-4-8'`).
  final String model;

  /// Maximum number of advisor calls allowed in a single request.
  final int? maxUses;

  /// Bounds the advisor's total output (thinking + text) per call.
  ///
  /// When the advisor hits this cap, the returned result block carries
  /// `stop_reason='max_tokens'`. When omitted, the advisor model's default
  /// output cap applies.
  final int? maxTokens;

  /// Caching for the advisor's own prompt.
  ///
  /// When set, each advisor call writes a cache entry at the given TTL
  /// so subsequent calls in the same conversation read the stable prefix.
  final CacheControlEphemeral? caching;

  /// Cache control breakpoint for the tool definition itself.
  final CacheControlEphemeral? cacheControl;

  /// Allowed caller types.
  final List<String>? allowedCallers;

  /// Whether to defer loading until requested via tool reference.
  final bool? deferLoading;

  /// Whether strict schema validation is enabled.
  final bool? strict;

  /// Creates an [AdvisorTool].
  const AdvisorTool({
    String? type,
    required this.model,
    this.maxUses,
    this.maxTokens,
    this.caching,
    this.cacheControl,
    this.allowedCallers,
    this.deferLoading,
    this.strict,
  }) : type = type ?? 'advisor_20260301';

  /// Creates an [AdvisorTool] from JSON.
  factory AdvisorTool.fromJson(Map<String, dynamic> json) {
    return AdvisorTool(
      type: json['type'] as String? ?? 'advisor_20260301',
      model: json['model'] as String,
      maxUses: json['max_uses'] as int?,
      maxTokens: json['max_tokens'] as int?,
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
      allowedCallers: (json['allowed_callers'] as List?)?.cast<String>(),
      deferLoading: json['defer_loading'] as bool?,
      strict: json['strict'] as bool?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'name': 'advisor',
    'model': model,
    if (maxUses != null) 'max_uses': maxUses,
    if (maxTokens != null) 'max_tokens': maxTokens,
    if (caching != null) 'caching': caching!.toJson(),
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
    if (allowedCallers != null) 'allowed_callers': allowedCallers,
    if (deferLoading != null) 'defer_loading': deferLoading,
    if (strict != null) 'strict': strict,
  };

  /// Creates a copy with replaced values.
  AdvisorTool copyWith({
    String? type,
    String? model,
    Object? maxUses = unsetCopyWithValue,
    Object? maxTokens = unsetCopyWithValue,
    Object? caching = unsetCopyWithValue,
    Object? cacheControl = unsetCopyWithValue,
    Object? allowedCallers = unsetCopyWithValue,
    Object? deferLoading = unsetCopyWithValue,
    Object? strict = unsetCopyWithValue,
  }) {
    return AdvisorTool(
      type: type ?? this.type,
      model: model ?? this.model,
      maxUses: maxUses == unsetCopyWithValue ? this.maxUses : maxUses as int?,
      maxTokens: maxTokens == unsetCopyWithValue
          ? this.maxTokens
          : maxTokens as int?,
      caching: caching == unsetCopyWithValue
          ? this.caching
          : caching as CacheControlEphemeral?,
      cacheControl: cacheControl == unsetCopyWithValue
          ? this.cacheControl
          : cacheControl as CacheControlEphemeral?,
      allowedCallers: allowedCallers == unsetCopyWithValue
          ? this.allowedCallers
          : allowedCallers as List<String>?,
      deferLoading: deferLoading == unsetCopyWithValue
          ? this.deferLoading
          : deferLoading as bool?,
      strict: strict == unsetCopyWithValue ? this.strict : strict as bool?,
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
          maxTokens == other.maxTokens &&
          caching == other.caching &&
          cacheControl == other.cacheControl &&
          listsEqual(allowedCallers, other.allowedCallers) &&
          deferLoading == other.deferLoading &&
          strict == other.strict;

  @override
  int get hashCode => Object.hash(
    type,
    model,
    maxUses,
    maxTokens,
    caching,
    cacheControl,
    listHash(allowedCallers),
    deferLoading,
    strict,
  );

  @override
  String toString() =>
      'AdvisorTool(type: $type, model: $model, maxUses: $maxUses, '
      'maxTokens: $maxTokens, caching: $caching, cacheControl: $cacheControl, '
      'allowedCallers: $allowedCallers, deferLoading: $deferLoading, '
      'strict: $strict)';
}
