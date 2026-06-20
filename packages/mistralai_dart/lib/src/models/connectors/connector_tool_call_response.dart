import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// MCP-specific result metadata for a tool call (isError, structuredContent,
/// _meta).
///
/// This schema has `additionalProperties: true`, so any extra fields beyond
/// the defined ones are captured in [additionalProperties].
@immutable
class ConnectorToolResultMetadata {
  /// Whether the tool call resulted in an error.
  final bool isError;

  /// Structured content returned by the tool, if any.
  final Map<String, dynamic>? structuredContent;

  /// Additional MCP metadata, mapped from the `_meta` field.
  final Map<String, dynamic>? meta;

  /// Additional properties not captured by the defined fields.
  final Map<String, dynamic>? additionalProperties;

  /// Creates a [ConnectorToolResultMetadata].
  const ConnectorToolResultMetadata({
    this.isError = false,
    this.structuredContent,
    this.meta,
    this.additionalProperties,
  });

  /// Creates a [ConnectorToolResultMetadata] from JSON.
  factory ConnectorToolResultMetadata.fromJson(Map<String, dynamic> json) {
    final extra = Map<String, dynamic>.from(json)
      ..remove('isError')
      ..remove('structuredContent')
      ..remove('_meta');
    return ConnectorToolResultMetadata(
      isError: json['isError'] as bool? ?? false,
      structuredContent: json['structuredContent'] as Map<String, dynamic>?,
      meta: json['_meta'] as Map<String, dynamic>?,
      additionalProperties: extra.isNotEmpty ? extra : null,
    );
  }

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {
    'isError': isError,
    if (structuredContent != null) 'structuredContent': structuredContent,
    if (meta != null) '_meta': meta,
    ...?additionalProperties,
  };

  /// Creates a copy with the given fields replaced.
  ///
  /// Pass `null` for nullable fields to clear them explicitly; omit to keep.
  ConnectorToolResultMetadata copyWith({
    bool? isError,
    Object? structuredContent = unsetCopyWithValue,
    Object? meta = unsetCopyWithValue,
    Object? additionalProperties = unsetCopyWithValue,
  }) => ConnectorToolResultMetadata(
    isError: isError ?? this.isError,
    structuredContent: structuredContent == unsetCopyWithValue
        ? this.structuredContent
        : structuredContent as Map<String, dynamic>?,
    meta: meta == unsetCopyWithValue
        ? this.meta
        : meta as Map<String, dynamic>?,
    additionalProperties: additionalProperties == unsetCopyWithValue
        ? this.additionalProperties
        : additionalProperties as Map<String, dynamic>?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectorToolResultMetadata &&
          runtimeType == other.runtimeType &&
          isError == other.isError &&
          mapsDeepEqual(structuredContent, other.structuredContent) &&
          mapsDeepEqual(meta, other.meta) &&
          mapsDeepEqual(additionalProperties, other.additionalProperties);

  @override
  int get hashCode => Object.hash(
    isError,
    mapDeepHashCode(structuredContent),
    mapDeepHashCode(meta),
    mapDeepHashCode(additionalProperties),
  );

  @override
  String toString() =>
      'ConnectorToolResultMetadata('
      'isError: $isError, '
      'structuredContent: ${structuredContent?.length ?? 'null'} entries, '
      'meta: ${meta?.length ?? 'null'} entries, '
      'additionalProperties: ${additionalProperties?.length ?? 'null'} entries)';
}

/// Metadata wrapper for MCP tool call responses.
///
/// This schema has `additionalProperties: true`, so any extra fields beyond
/// the defined ones are captured in [additionalProperties].
@immutable
class ConnectorToolCallMetadata {
  /// MCP-specific result metadata, nested under `mcp_meta`.
  final ConnectorToolResultMetadata? mcpMeta;

  /// Additional properties not captured by the defined fields.
  final Map<String, dynamic>? additionalProperties;

  /// Creates a [ConnectorToolCallMetadata].
  const ConnectorToolCallMetadata({this.mcpMeta, this.additionalProperties});

  /// Creates a [ConnectorToolCallMetadata] from JSON.
  factory ConnectorToolCallMetadata.fromJson(Map<String, dynamic> json) {
    final extra = Map<String, dynamic>.from(json)..remove('mcp_meta');
    return ConnectorToolCallMetadata(
      mcpMeta: json['mcp_meta'] != null
          ? ConnectorToolResultMetadata.fromJson(
              json['mcp_meta'] as Map<String, dynamic>,
            )
          : null,
      additionalProperties: extra.isNotEmpty ? extra : null,
    );
  }

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {
    if (mcpMeta != null) 'mcp_meta': mcpMeta!.toJson(),
    ...?additionalProperties,
  };

  /// Creates a copy with the given fields replaced.
  ///
  /// Pass `null` for nullable fields to clear them explicitly; omit to keep.
  ConnectorToolCallMetadata copyWith({
    Object? mcpMeta = unsetCopyWithValue,
    Object? additionalProperties = unsetCopyWithValue,
  }) => ConnectorToolCallMetadata(
    mcpMeta: mcpMeta == unsetCopyWithValue
        ? this.mcpMeta
        : mcpMeta as ConnectorToolResultMetadata?,
    additionalProperties: additionalProperties == unsetCopyWithValue
        ? this.additionalProperties
        : additionalProperties as Map<String, dynamic>?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectorToolCallMetadata &&
          runtimeType == other.runtimeType &&
          mcpMeta == other.mcpMeta &&
          mapsDeepEqual(additionalProperties, other.additionalProperties);

  @override
  int get hashCode =>
      Object.hash(mcpMeta, mapDeepHashCode(additionalProperties));

  @override
  String toString() => 'ConnectorToolCallMetadata(mcpMeta: $mcpMeta)';
}

/// Response from calling an MCP tool on a connector.
///
/// The [content] entries are an open union of MCP content blocks (text,
/// image, audio, resource, resource_link) and are therefore exposed as
/// freeform maps.
///
/// This schema has `additionalProperties: true`, so any extra fields beyond
/// the defined ones are captured in [additionalProperties].
@immutable
class ConnectorToolCallResponse {
  /// The content blocks returned by the tool.
  final List<Map<String, dynamic>> content;

  /// Optional metadata about the tool call.
  final ConnectorToolCallMetadata? metadata;

  /// Additional properties not captured by the defined fields.
  final Map<String, dynamic>? additionalProperties;

  /// Creates a [ConnectorToolCallResponse].
  const ConnectorToolCallResponse({
    required this.content,
    this.metadata,
    this.additionalProperties,
  });

  /// Creates a [ConnectorToolCallResponse] from JSON.
  factory ConnectorToolCallResponse.fromJson(Map<String, dynamic> json) {
    final extra = Map<String, dynamic>.from(json)
      ..remove('content')
      ..remove('metadata');
    return ConnectorToolCallResponse(
      content:
          (json['content'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
      metadata: json['metadata'] != null
          ? ConnectorToolCallMetadata.fromJson(
              json['metadata'] as Map<String, dynamic>,
            )
          : null,
      additionalProperties: extra.isNotEmpty ? extra : null,
    );
  }

  /// Converts this response to JSON.
  Map<String, dynamic> toJson() => {
    'content': content,
    if (metadata != null) 'metadata': metadata!.toJson(),
    ...?additionalProperties,
  };

  /// Creates a copy with the given fields replaced.
  ///
  /// Pass `null` for nullable fields to clear them explicitly; omit to keep.
  ConnectorToolCallResponse copyWith({
    List<Map<String, dynamic>>? content,
    Object? metadata = unsetCopyWithValue,
    Object? additionalProperties = unsetCopyWithValue,
  }) => ConnectorToolCallResponse(
    content: content ?? this.content,
    metadata: metadata == unsetCopyWithValue
        ? this.metadata
        : metadata as ConnectorToolCallMetadata?,
    additionalProperties: additionalProperties == unsetCopyWithValue
        ? this.additionalProperties
        : additionalProperties as Map<String, dynamic>?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectorToolCallResponse &&
          runtimeType == other.runtimeType &&
          listOfMapsDeepEqual(content, other.content) &&
          metadata == other.metadata &&
          mapsDeepEqual(additionalProperties, other.additionalProperties);

  @override
  int get hashCode => Object.hash(
    listOfMapsHashCode(content),
    metadata,
    mapDeepHashCode(additionalProperties),
  );

  @override
  String toString() =>
      'ConnectorToolCallResponse(content: ${content.length}, '
      'metadata: $metadata)';
}
