import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// The MCPTool wire payload.
@immutable
class McpConnectorTool {
  /// Creates a [McpConnectorTool].
  const McpConnectorTool({
    this.meta,
    this.annotations,
    this.description,
    this.execution,
    this.icons,
    required this.inputSchema,
    required this.name,
    this.outputSchema,
    this.title,
    this.extra = const {},
  });

  /// The _meta field.
  final Map<String, dynamic>? meta;

  /// The annotations field.
  final McpToolAnnotations? annotations;

  /// The description field.
  final String? description;

  /// The execution field.
  final McpToolExecution? execution;

  /// The icons field.
  final List<McpToolIcon>? icons;

  /// The inputSchema field.
  final Map<String, dynamic> inputSchema;

  /// The name field.
  final String name;

  /// The outputSchema field.
  final Map<String, dynamic>? outputSchema;

  /// The title field.
  final String? title;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [McpConnectorTool] from JSON.
  factory McpConnectorTool.fromJson(Map<String, dynamic> json) {
    if (json['inputSchema'] == null) {
      throw const FormatException('McpConnectorTool: missing inputSchema');
    }
    if (json['name'] == null) {
      throw const FormatException('McpConnectorTool: missing name');
    }
    return McpConnectorTool(
      meta: json['_meta'] == null
          ? null
          : json['_meta'] as Map<String, dynamic>,
      annotations: json['annotations'] == null
          ? null
          : McpToolAnnotations.fromJson(
              json['annotations'] as Map<String, dynamic>,
            ),
      description: json['description'] == null
          ? null
          : json['description'] as String,
      execution: json['execution'] == null
          ? null
          : McpToolExecution.fromJson(
              json['execution'] as Map<String, dynamic>,
            ),
      icons: json['icons'] == null
          ? null
          : (json['icons'] as List<Object?>)
                .map(
                  (item) => McpToolIcon.fromJson(item! as Map<String, dynamic>),
                )
                .toList(),
      inputSchema: json['inputSchema'] as Map<String, dynamic>,
      name: json['name'] as String,
      outputSchema: json['outputSchema'] == null
          ? null
          : json['outputSchema'] as Map<String, dynamic>,
      title: json['title'] == null ? null : json['title'] as String,
      extra: {
        for (final entry in json.entries)
          if (!const {
            '_meta',
            'annotations',
            'description',
            'execution',
            'icons',
            'inputSchema',
            'name',
            'outputSchema',
            'title',
          }.contains(entry.key))
            entry.key: entry.value,
      },
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    ...?extra,
    '_meta': ?meta,
    if (annotations != null) 'annotations': annotations!.toJson(),
    'description': ?description,
    if (execution != null) 'execution': execution!.toJson(),
    if (icons != null) 'icons': icons!.map((item) => item.toJson()).toList(),
    'inputSchema': inputSchema,
    'name': name,
    'outputSchema': ?outputSchema,
    'title': ?title,
  };

  /// Creates a copy with the given fields replaced.
  McpConnectorTool copyWith({
    Object? meta = unsetCopyWithValue,
    Object? annotations = unsetCopyWithValue,
    Object? description = unsetCopyWithValue,
    Object? execution = unsetCopyWithValue,
    Object? icons = unsetCopyWithValue,
    Map<String, dynamic>? inputSchema,
    String? name,
    Object? outputSchema = unsetCopyWithValue,
    Object? title = unsetCopyWithValue,
    Object? extra = unsetCopyWithValue,
  }) => McpConnectorTool(
    meta: meta == unsetCopyWithValue
        ? this.meta
        : (meta as Map?)?.cast<String, dynamic>(),
    annotations: annotations == unsetCopyWithValue
        ? this.annotations
        : annotations as McpToolAnnotations?,
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    execution: execution == unsetCopyWithValue
        ? this.execution
        : execution as McpToolExecution?,
    icons: icons == unsetCopyWithValue
        ? this.icons
        : (icons as List<Object?>?)?.cast<McpToolIcon>(),
    inputSchema: inputSchema ?? this.inputSchema,
    name: name ?? this.name,
    outputSchema: outputSchema == unsetCopyWithValue
        ? this.outputSchema
        : (outputSchema as Map?)?.cast<String, dynamic>(),
    title: title == unsetCopyWithValue ? this.title : title as String?,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is McpConnectorTool &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(meta, other.meta) &&
          annotations == other.annotations &&
          description == other.description &&
          execution == other.execution &&
          valuesDeepEqual(icons, other.icons) &&
          valuesDeepEqual(inputSchema, other.inputSchema) &&
          name == other.name &&
          valuesDeepEqual(outputSchema, other.outputSchema) &&
          title == other.title &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([
    valueDeepHashCode(meta),
    annotations,
    description,
    execution,
    valueDeepHashCode(icons),
    valueDeepHashCode(inputSchema),
    name,
    valueDeepHashCode(outputSchema),
    title,
    valueDeepHashCode(extra),
  ]);

  @override
  String toString() =>
      'McpConnectorTool('
      'meta: ${meta?.length}, '
      'annotations: $annotations, '
      'description: $description, '
      'execution: $execution, '
      'icons: ${icons?.length}, '
      'inputSchema: ${inputSchema.length}, '
      'name: $name, '
      'outputSchema: ${outputSchema?.length}, '
      'title: $title, '
      'extra: ${extra?.length})';
}

/// Additional properties describing a Tool to clients. NOTE: all properties in ToolAnnotations are **hints**. They are not guaranteed to provide a faithful description of tool behavior (including descriptive properties like `title`). Clients should never make tool use decisions based on ToolAnnotations received from untrusted servers.
@immutable
class McpToolAnnotations {
  /// Creates a [McpToolAnnotations].
  const McpToolAnnotations({
    this.destructiveHint,
    this.idempotentHint,
    this.openWorldHint,
    this.readOnlyHint,
    this.title,
  });

  /// The destructiveHint field.
  final bool? destructiveHint;

  /// The idempotentHint field.
  final bool? idempotentHint;

  /// The openWorldHint field.
  final bool? openWorldHint;

  /// The readOnlyHint field.
  final bool? readOnlyHint;

  /// The title field.
  final String? title;

  /// Parses a [McpToolAnnotations] from JSON.
  factory McpToolAnnotations.fromJson(Map<String, dynamic> json) {
    return McpToolAnnotations(
      destructiveHint: json['destructiveHint'] == null
          ? null
          : json['destructiveHint'] as bool,
      idempotentHint: json['idempotentHint'] == null
          ? null
          : json['idempotentHint'] as bool,
      openWorldHint: json['openWorldHint'] == null
          ? null
          : json['openWorldHint'] as bool,
      readOnlyHint: json['readOnlyHint'] == null
          ? null
          : json['readOnlyHint'] as bool,
      title: json['title'] == null ? null : json['title'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'destructiveHint': ?destructiveHint,
    'idempotentHint': ?idempotentHint,
    'openWorldHint': ?openWorldHint,
    'readOnlyHint': ?readOnlyHint,
    'title': ?title,
  };

  /// Creates a copy with the given fields replaced.
  McpToolAnnotations copyWith({
    Object? destructiveHint = unsetCopyWithValue,
    Object? idempotentHint = unsetCopyWithValue,
    Object? openWorldHint = unsetCopyWithValue,
    Object? readOnlyHint = unsetCopyWithValue,
    Object? title = unsetCopyWithValue,
  }) => McpToolAnnotations(
    destructiveHint: destructiveHint == unsetCopyWithValue
        ? this.destructiveHint
        : destructiveHint as bool?,
    idempotentHint: idempotentHint == unsetCopyWithValue
        ? this.idempotentHint
        : idempotentHint as bool?,
    openWorldHint: openWorldHint == unsetCopyWithValue
        ? this.openWorldHint
        : openWorldHint as bool?,
    readOnlyHint: readOnlyHint == unsetCopyWithValue
        ? this.readOnlyHint
        : readOnlyHint as bool?,
    title: title == unsetCopyWithValue ? this.title : title as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is McpToolAnnotations &&
          runtimeType == other.runtimeType &&
          destructiveHint == other.destructiveHint &&
          idempotentHint == other.idempotentHint &&
          openWorldHint == other.openWorldHint &&
          readOnlyHint == other.readOnlyHint &&
          title == other.title;

  @override
  int get hashCode => Object.hashAll([
    destructiveHint,
    idempotentHint,
    openWorldHint,
    readOnlyHint,
    title,
  ]);

  @override
  String toString() =>
      'McpToolAnnotations('
      'destructiveHint: $destructiveHint, '
      'idempotentHint: $idempotentHint, '
      'openWorldHint: $openWorldHint, '
      'readOnlyHint: $readOnlyHint, '
      'title: $title)';
}

/// Execution-related properties for a tool (2025-11-25 only).
@immutable
class McpToolExecution {
  /// Creates a [McpToolExecution].
  const McpToolExecution({this.taskSupport});

  /// The taskSupport field.
  final String? taskSupport;

  /// Parses a [McpToolExecution] from JSON.
  factory McpToolExecution.fromJson(Map<String, dynamic> json) {
    return McpToolExecution(
      taskSupport: json['taskSupport'] == null
          ? null
          : json['taskSupport'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'taskSupport': ?taskSupport};

  /// Creates a copy with the given fields replaced.
  McpToolExecution copyWith({Object? taskSupport = unsetCopyWithValue}) =>
      McpToolExecution(
        taskSupport: taskSupport == unsetCopyWithValue
            ? this.taskSupport
            : taskSupport as String?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is McpToolExecution &&
          runtimeType == other.runtimeType &&
          taskSupport == other.taskSupport;

  @override
  int get hashCode => Object.hashAll([taskSupport]);

  @override
  String toString() =>
      'McpToolExecution('
      'taskSupport: $taskSupport)';
}

/// An optionally-sized icon for display in a user interface (2025-11-25+).
@immutable
class McpToolIcon {
  /// Creates a [McpToolIcon].
  const McpToolIcon({this.mimeType, this.sizes, required this.src, this.theme});

  /// The mimeType field.
  final String? mimeType;

  /// The sizes field.
  final List<String>? sizes;

  /// The src field.
  final String src;

  /// The theme field.
  final String? theme;

  /// Parses a [McpToolIcon] from JSON.
  factory McpToolIcon.fromJson(Map<String, dynamic> json) {
    if (json['src'] == null) {
      throw const FormatException('McpToolIcon: missing src');
    }
    return McpToolIcon(
      mimeType: json['mimeType'] == null ? null : json['mimeType'] as String,
      sizes: json['sizes'] == null
          ? null
          : (json['sizes'] as List<Object?>)
                .map((item) => item! as String)
                .toList(),
      src: json['src'] as String,
      theme: json['theme'] == null ? null : json['theme'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'mimeType': ?mimeType,
    'sizes': ?sizes,
    'src': src,
    'theme': ?theme,
  };

  /// Creates a copy with the given fields replaced.
  McpToolIcon copyWith({
    Object? mimeType = unsetCopyWithValue,
    Object? sizes = unsetCopyWithValue,
    String? src,
    Object? theme = unsetCopyWithValue,
  }) => McpToolIcon(
    mimeType: mimeType == unsetCopyWithValue
        ? this.mimeType
        : mimeType as String?,
    sizes: sizes == unsetCopyWithValue
        ? this.sizes
        : (sizes as List<Object?>?)?.cast<String>(),
    src: src ?? this.src,
    theme: theme == unsetCopyWithValue ? this.theme : theme as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is McpToolIcon &&
          runtimeType == other.runtimeType &&
          mimeType == other.mimeType &&
          valuesDeepEqual(sizes, other.sizes) &&
          src == other.src &&
          theme == other.theme;

  @override
  int get hashCode =>
      Object.hashAll([mimeType, valueDeepHashCode(sizes), src, theme]);

  @override
  String toString() =>
      'McpToolIcon('
      'mimeType: $mimeType, '
      'sizes: ${sizes?.length}, '
      'src: $src, '
      'theme: $theme)';
}
