import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'model_capabilities.dart';

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

  /// Model capability information.
  final ModelCapabilities? capabilities;

  /// Maximum input context window size in tokens for this model.
  final int? maxInputTokens;

  /// Maximum value for the `max_tokens` parameter when using this model.
  final int? maxTokens;

  /// Creates a [ModelInfo].
  const ModelInfo({
    required this.id,
    required this.displayName,
    required this.createdAt,
    this.type = 'model',
    this.capabilities,
    this.maxInputTokens,
    this.maxTokens,
  });

  /// Creates a [ModelInfo] from JSON.
  factory ModelInfo.fromJson(Map<String, dynamic> json) {
    return ModelInfo(
      id: json['id'] as String,
      displayName: json['display_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      type: json['type'] as String? ?? 'model',
      capabilities: json['capabilities'] != null
          ? ModelCapabilities.fromJson(
              json['capabilities'] as Map<String, dynamic>,
            )
          : null,
      maxInputTokens: json['max_input_tokens'] as int?,
      maxTokens: json['max_tokens'] as int?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'display_name': displayName,
    'created_at': createdAt.toUtc().toIso8601String(),
    'type': type,
    if (capabilities != null) 'capabilities': capabilities!.toJson(),
    if (maxInputTokens != null) 'max_input_tokens': maxInputTokens,
    if (maxTokens != null) 'max_tokens': maxTokens,
  };

  /// Creates a copy with replaced values.
  ModelInfo copyWith({
    String? id,
    String? displayName,
    DateTime? createdAt,
    String? type,
    Object? capabilities = unsetCopyWithValue,
    Object? maxInputTokens = unsetCopyWithValue,
    Object? maxTokens = unsetCopyWithValue,
  }) {
    return ModelInfo(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      capabilities: capabilities == unsetCopyWithValue
          ? this.capabilities
          : capabilities as ModelCapabilities?,
      maxInputTokens: maxInputTokens == unsetCopyWithValue
          ? this.maxInputTokens
          : maxInputTokens as int?,
      maxTokens: maxTokens == unsetCopyWithValue
          ? this.maxTokens
          : maxTokens as int?,
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
          capabilities == other.capabilities &&
          maxInputTokens == other.maxInputTokens &&
          maxTokens == other.maxTokens;

  @override
  int get hashCode => Object.hash(
    id,
    displayName,
    createdAt,
    type,
    capabilities,
    maxInputTokens,
    maxTokens,
  );

  @override
  String toString() =>
      'ModelInfo(id: $id, displayName: $displayName, createdAt: $createdAt, '
      'type: $type, capabilities: $capabilities, '
      'maxInputTokens: $maxInputTokens, maxTokens: $maxTokens)';
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
