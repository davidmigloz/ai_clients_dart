import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'model_capabilities.dart';

/// Lifecycle stage returned by the Models API or passed to a model list filter.
///
/// The API can return new stages. [value] preserves the exact wire value.
@immutable
final class ModelLifecycle {
  /// The model is open to new adopters.
  static const active = ModelLifecycle('active');

  /// The model remains callable for organizations with existing access.
  static const deprecated = ModelLifecycle('deprecated');

  /// The model can no longer be called for inference.
  static const retired = ModelLifecycle('retired');

  /// The lifecycle stage as it appears on the wire.
  final String value;

  /// Creates a lifecycle value, including values introduced by the server.
  const ModelLifecycle(this.value);

  /// Reads a lifecycle value from JSON without normalizing unknown values.
  factory ModelLifecycle.fromJson(String json) => ModelLifecycle(json);

  /// Converts this lifecycle value to JSON.
  String toJson() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ModelLifecycle && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

/// Information about an Anthropic model.
@immutable
class ModelInfo {
  /// Unique model identifier.
  final String id;

  /// A human-readable name for the model.
  final String displayName;

  /// RFC 3339 datetime string representing when the model was released.
  final DateTime createdAt;

  /// Object type. Always "model".
  final String type;

  /// The model line, for example `opus` or `sonnet`.
  ///
  /// This is an open string. May be null when the model belongs to no line or
  /// the response predates this field.
  final String? line;

  /// The model's lifecycle stage. May be null on older responses.
  final ModelLifecycle? lifecycle;

  /// When the model was most recently deprecated. Null while active.
  final DateTime? deprecatedAt;

  /// The scheduled retirement time, if any. Use [lifecycle] to check whether
  /// retirement has occurred.
  final DateTime? retiresAt;

  /// Model capability information.
  final ModelCapabilities? capabilities;

  /// Maximum input context window size in tokens for this model.
  final int? maxInputTokens;

  /// Maximum value for the `max_tokens` parameter when using this model.
  final int? maxTokens;

  /// Model IDs this model accepts as `fallbacks[i].model` on the Messages API.
  ///
  /// An empty list means the `fallbacks` parameter is not supported for this
  /// model as primary.
  final List<String>? allowedFallbackModels;

  /// Creates a [ModelInfo].
  const ModelInfo({
    required this.id,
    required this.displayName,
    required this.createdAt,
    this.type = 'model',
    this.line,
    this.lifecycle,
    this.deprecatedAt,
    this.retiresAt,
    this.capabilities,
    this.maxInputTokens,
    this.maxTokens,
    this.allowedFallbackModels,
  });

  /// Creates a [ModelInfo] from JSON.
  factory ModelInfo.fromJson(Map<String, dynamic> json) {
    final lifecycle = json['lifecycle'] as String?;
    final deprecatedAt = json['deprecated_at'] as String?;
    final retiresAt = json['retires_at'] as String?;
    return ModelInfo(
      id: json['id'] as String,
      displayName: json['display_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      type: json['type'] as String? ?? 'model',
      line: json['line'] as String?,
      lifecycle: lifecycle == null ? null : ModelLifecycle.fromJson(lifecycle),
      deprecatedAt: deprecatedAt == null ? null : DateTime.parse(deprecatedAt),
      retiresAt: retiresAt == null ? null : DateTime.parse(retiresAt),
      capabilities: json['capabilities'] != null
          ? ModelCapabilities.fromJson(
              json['capabilities'] as Map<String, dynamic>,
            )
          : null,
      maxInputTokens: json['max_input_tokens'] as int?,
      maxTokens: json['max_tokens'] as int?,
      allowedFallbackModels: (json['allowed_fallback_models'] as List?)
          ?.cast<String>(),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'display_name': displayName,
    'created_at': createdAt.toUtc().toIso8601String(),
    'type': type,
    // Current model responses require these nullable fields. Older responses
    // can omit the lifecycle metadata and keep their original shape.
    if (lifecycle != null || line != null) 'line': line,
    if (lifecycle != null) 'lifecycle': lifecycle!.toJson(),
    if (lifecycle != null || deprecatedAt != null)
      'deprecated_at': deprecatedAt?.toUtc().toIso8601String(),
    if (lifecycle != null || retiresAt != null)
      'retires_at': retiresAt?.toUtc().toIso8601String(),
    if (lifecycle != null || capabilities != null)
      'capabilities': capabilities?.toJson(),
    if (lifecycle != null || maxInputTokens != null)
      'max_input_tokens': maxInputTokens,
    if (lifecycle != null || maxTokens != null) 'max_tokens': maxTokens,
    if (allowedFallbackModels != null)
      'allowed_fallback_models': allowedFallbackModels,
  };

  /// Creates a copy with replaced values.
  ModelInfo copyWith({
    String? id,
    String? displayName,
    DateTime? createdAt,
    String? type,
    Object? line = unsetCopyWithValue,
    Object? lifecycle = unsetCopyWithValue,
    Object? deprecatedAt = unsetCopyWithValue,
    Object? retiresAt = unsetCopyWithValue,
    Object? capabilities = unsetCopyWithValue,
    Object? maxInputTokens = unsetCopyWithValue,
    Object? maxTokens = unsetCopyWithValue,
    Object? allowedFallbackModels = unsetCopyWithValue,
  }) {
    return ModelInfo(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      line: line == unsetCopyWithValue ? this.line : line as String?,
      lifecycle: lifecycle == unsetCopyWithValue
          ? this.lifecycle
          : lifecycle as ModelLifecycle?,
      deprecatedAt: deprecatedAt == unsetCopyWithValue
          ? this.deprecatedAt
          : deprecatedAt as DateTime?,
      retiresAt: retiresAt == unsetCopyWithValue
          ? this.retiresAt
          : retiresAt as DateTime?,
      capabilities: capabilities == unsetCopyWithValue
          ? this.capabilities
          : capabilities as ModelCapabilities?,
      maxInputTokens: maxInputTokens == unsetCopyWithValue
          ? this.maxInputTokens
          : maxInputTokens as int?,
      maxTokens: maxTokens == unsetCopyWithValue
          ? this.maxTokens
          : maxTokens as int?,
      allowedFallbackModels: allowedFallbackModels == unsetCopyWithValue
          ? this.allowedFallbackModels
          : copyWithList<String>(allowedFallbackModels),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelInfo &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          displayName == other.displayName &&
          createdAt == other.createdAt &&
          type == other.type &&
          line == other.line &&
          lifecycle == other.lifecycle &&
          deprecatedAt == other.deprecatedAt &&
          retiresAt == other.retiresAt &&
          capabilities == other.capabilities &&
          maxInputTokens == other.maxInputTokens &&
          maxTokens == other.maxTokens &&
          listsEqual(allowedFallbackModels, other.allowedFallbackModels);

  @override
  int get hashCode => Object.hash(
    id,
    displayName,
    createdAt,
    type,
    line,
    lifecycle,
    deprecatedAt,
    retiresAt,
    capabilities,
    maxInputTokens,
    maxTokens,
    listHash(allowedFallbackModels),
  );

  @override
  String toString() =>
      'ModelInfo(id: $id, displayName: $displayName, createdAt: $createdAt, '
      'type: $type, line: $line, lifecycle: $lifecycle, '
      'deprecatedAt: $deprecatedAt, retiresAt: $retiresAt, '
      'capabilities: $capabilities, '
      'maxInputTokens: $maxInputTokens, maxTokens: $maxTokens, '
      'allowedFallbackModels: $allowedFallbackModels)';
}

/// Response for listing models.
@immutable
class ModelListResponse {
  /// List of models.
  final List<ModelInfo> data;

  /// Whether there are more results.
  final bool hasMore;

  /// ID of the first model in the list.
  final String? firstId;

  /// ID of the last model in the list.
  final String? lastId;

  /// Creates a [ModelListResponse].
  const ModelListResponse({
    required this.data,
    required this.hasMore,
    this.firstId,
    this.lastId,
  });

  /// Creates a [ModelListResponse] from JSON.
  factory ModelListResponse.fromJson(Map<String, dynamic> json) {
    return ModelListResponse(
      data: (json['data'] as List)
          .map((e) => ModelInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasMore: json['has_more'] as bool,
      firstId: json['first_id'] as String?,
      lastId: json['last_id'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'data': data.map((e) => e.toJson()).toList(),
    'has_more': hasMore,
    if (firstId != null) 'first_id': firstId,
    if (lastId != null) 'last_id': lastId,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelListResponse &&
          runtimeType == other.runtimeType &&
          listsEqual(data, other.data) &&
          hasMore == other.hasMore &&
          firstId == other.firstId &&
          lastId == other.lastId;

  @override
  int get hashCode => Object.hash(listHash(data), hasMore, firstId, lastId);

  @override
  String toString() =>
      'ModelListResponse(data: $data, hasMore: $hasMore, firstId: $firstId, lastId: $lastId)';
}
