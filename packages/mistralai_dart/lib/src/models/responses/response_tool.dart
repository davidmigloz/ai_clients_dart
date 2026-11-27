import 'package:meta/meta.dart';

import '../../utils/additional_json_fields.dart';
import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// A ResponseTool variant.
///
/// [ResponseFunctionTool], [ResponseNamespaceTool], or [UnknownResponseTool].
@immutable
sealed class ResponseTool {
  const ResponseTool();

  /// Parses an API payload.
  factory ResponseTool.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'function' => ResponseFunctionTool.fromJson(json),
        'namespace' => ResponseNamespaceTool.fromJson(json),
        _ => UnknownResponseTool(json),
      };

  /// Encodes the wire object.
  Map<String, dynamic> toJson();
}

/// A future ResponseTool value.
@immutable
final class UnknownResponseTool extends ResponseTool {
  /// Creates a fallback from the original payload.
  UnknownResponseTool(Map<String, dynamic> json) : raw = Map.unmodifiable(json);

  /// The original payload.
  final Map<String, dynamic> raw;

  @override
  Map<String, dynamic> toJson() => Map.of(raw);

  @override
  bool operator ==(Object other) =>
      other is UnknownResponseTool && mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => mapDeepHashCode(raw);
}

/// A ResponseNestedTool variant.
///
/// [ResponseNestedFunctionTool], [ResponseCustomTool], or [UnknownResponseNestedTool].
@immutable
sealed class ResponseNestedTool {
  const ResponseNestedTool();

  /// Parses an API payload.
  factory ResponseNestedTool.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'function' => ResponseNestedFunctionTool.fromJson(json),
        'custom' => ResponseCustomTool.fromJson(json),
        _ => UnknownResponseNestedTool(json),
      };

  /// Encodes the wire object.
  Map<String, dynamic> toJson();
}

/// A future ResponseNestedTool value.
@immutable
final class UnknownResponseNestedTool extends ResponseNestedTool {
  /// Creates a fallback from the original payload.
  UnknownResponseNestedTool(Map<String, dynamic> json)
    : raw = Map.unmodifiable(json);

  /// The original payload.
  final Map<String, dynamic> raw;

  @override
  Map<String, dynamic> toJson() => Map.of(raw);

  @override
  bool operator ==(Object other) =>
      other is UnknownResponseNestedTool && mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => mapDeepHashCode(raw);
}

/// A ResponseCustomToolFormat variant.
///
/// [ResponseCustomTextFormat], [ResponseCustomGrammarFormat], or [UnknownResponseCustomToolFormat].
@immutable
sealed class ResponseCustomToolFormat {
  const ResponseCustomToolFormat();

  /// Parses an API payload.
  factory ResponseCustomToolFormat.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'text' => ResponseCustomTextFormat.fromJson(json),
        'grammar' => ResponseCustomGrammarFormat.fromJson(json),
        _ => UnknownResponseCustomToolFormat(json),
      };

  /// Encodes the wire object.
  Map<String, dynamic> toJson();
}

/// A future ResponseCustomToolFormat value.
@immutable
final class UnknownResponseCustomToolFormat extends ResponseCustomToolFormat {
  /// Creates a fallback from the original payload.
  UnknownResponseCustomToolFormat(Map<String, dynamic> json)
    : raw = Map.unmodifiable(json);

  /// The original payload.
  final Map<String, dynamic> raw;

  @override
  Map<String, dynamic> toJson() => Map.of(raw);

  @override
  bool operator ==(Object other) =>
      other is UnknownResponseCustomToolFormat && mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => mapDeepHashCode(raw);
}

/// A ResponseTextFormat variant.
///
/// [ResponseTextFormatPlain], [ResponseTextFormatJsonObject], [ResponseTextFormatJsonSchema], or [UnknownResponseTextFormat].
@immutable
sealed class ResponseTextFormat {
  const ResponseTextFormat();

  /// Parses an API payload.
  factory ResponseTextFormat.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'text' => ResponseTextFormatPlain.fromJson(json),
        'json_object' => ResponseTextFormatJsonObject.fromJson(json),
        'json_schema' => ResponseTextFormatJsonSchema.fromJson(json),
        _ => UnknownResponseTextFormat(json),
      };

  /// Encodes the wire object.
  Map<String, dynamic> toJson();
}

/// A future ResponseTextFormat value.
@immutable
final class UnknownResponseTextFormat extends ResponseTextFormat {
  /// Creates a fallback from the original payload.
  UnknownResponseTextFormat(Map<String, dynamic> json)
    : raw = Map.unmodifiable(json);

  /// The original payload.
  final Map<String, dynamic> raw;

  @override
  Map<String, dynamic> toJson() => Map.of(raw);

  @override
  bool operator ==(Object other) =>
      other is UnknownResponseTextFormat && mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => mapDeepHashCode(raw);
}

/// The ResponsesFunctionTool wire payload.
@immutable
class ResponseFunctionTool extends ResponseTool {
  /// Creates a [ResponseFunctionTool].
  const ResponseFunctionTool({
    this.allowedCallers,
    this.isAsync,
    this.deferLoading,
    this.description,
    required this.name,
    this.outputSchema,
    this.parameters,
    this.strict,
    this.extra,
  });

  /// The fixed type discriminator.
  String get type => 'function';

  /// The allowed_callers field.
  final List<String>? allowedCallers;

  /// The async field.
  final bool? isAsync;

  /// The defer_loading field.
  final bool? deferLoading;

  /// The description field.
  final String? description;

  /// The name field.
  final String name;

  /// The output_schema field.
  final Map<String, dynamic>? outputSchema;

  /// The parameters field.
  final Map<String, dynamic>? parameters;

  /// The strict field.
  final bool? strict;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseFunctionTool] from JSON.
  factory ResponseFunctionTool.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'function') {
      throw FormatException('ResponseFunctionTool: unexpected type $value');
    }
    if (json['name'] == null) {
      throw const FormatException('ResponseFunctionTool: missing name');
    }
    return ResponseFunctionTool(
      allowedCallers: json['allowed_callers'] == null
          ? null
          : (json['allowed_callers'] as List)
                .map((item) => item as String)
                .toList(),
      isAsync: json['async'] == null ? null : json['async'] as bool,
      deferLoading: json['defer_loading'] == null
          ? null
          : json['defer_loading'] as bool,
      description: json['description'] == null
          ? null
          : json['description'] as String,
      name: json['name'] as String,
      outputSchema: json['output_schema'] == null
          ? null
          : json['output_schema'] as Map<String, dynamic>,
      parameters: json['parameters'] == null
          ? null
          : json['parameters'] as Map<String, dynamic>,
      strict: json['strict'] == null ? null : json['strict'] as bool,
      extra: additionalJsonFields(json, const {
        'allowed_callers',
        'async',
        'defer_loading',
        'description',
        'name',
        'output_schema',
        'parameters',
        'strict',
        'type',
      }),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...?extra,
    'type': type,
    'allowed_callers': ?allowedCallers,
    'async': ?isAsync,
    'defer_loading': ?deferLoading,
    'description': ?description,
    'name': name,
    'output_schema': ?outputSchema,
    'parameters': ?parameters,
    'strict': ?strict,
  };

  /// Creates a copy with the given fields replaced.
  ResponseFunctionTool copyWith({
    Object? allowedCallers = unsetCopyWithValue,
    Object? isAsync = unsetCopyWithValue,
    Object? deferLoading = unsetCopyWithValue,
    Object? description = unsetCopyWithValue,
    String? name,
    Object? outputSchema = unsetCopyWithValue,
    Object? parameters = unsetCopyWithValue,
    Object? strict = unsetCopyWithValue,
    Object? extra = unsetCopyWithValue,
  }) => ResponseFunctionTool(
    allowedCallers: allowedCallers == unsetCopyWithValue
        ? this.allowedCallers
        : (allowedCallers as List?)?.cast<String>(),
    isAsync: isAsync == unsetCopyWithValue ? this.isAsync : isAsync as bool?,
    deferLoading: deferLoading == unsetCopyWithValue
        ? this.deferLoading
        : deferLoading as bool?,
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    name: name ?? this.name,
    outputSchema: outputSchema == unsetCopyWithValue
        ? this.outputSchema
        : (outputSchema as Map?)?.cast<String, dynamic>(),
    parameters: parameters == unsetCopyWithValue
        ? this.parameters
        : (parameters as Map?)?.cast<String, dynamic>(),
    strict: strict == unsetCopyWithValue ? this.strict : strict as bool?,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseFunctionTool &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(allowedCallers, other.allowedCallers) &&
          isAsync == other.isAsync &&
          deferLoading == other.deferLoading &&
          description == other.description &&
          name == other.name &&
          valuesDeepEqual(outputSchema, other.outputSchema) &&
          valuesDeepEqual(parameters, other.parameters) &&
          strict == other.strict &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([
    valueDeepHashCode(allowedCallers),
    isAsync,
    deferLoading,
    description,
    name,
    valueDeepHashCode(outputSchema),
    valueDeepHashCode(parameters),
    strict,
    valueDeepHashCode(extra),
  ]);

  @override
  String toString() =>
      'ResponseFunctionTool('
      'allowedCallers: ${allowedCallers?.length}, '
      'isAsync: $isAsync, '
      'deferLoading: $deferLoading, '
      'description: $description, '
      'name: $name, '
      'outputSchema: ${outputSchema?.length}, '
      'parameters: ${parameters?.length}, '
      'strict: $strict, '
      'extra: ${extra?.length})';
}

/// The ResponsesNamespaceTool wire payload.
@immutable
class ResponseNamespaceTool extends ResponseTool {
  /// Creates a [ResponseNamespaceTool].
  const ResponseNamespaceTool({
    required this.description,
    required this.name,
    required this.tools,
    this.extra,
  });

  /// The fixed type discriminator.
  String get type => 'namespace';

  /// The description field.
  final String description;

  /// The name field.
  final String name;

  /// The tools field.
  final List<ResponseNestedTool> tools;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseNamespaceTool] from JSON.
  factory ResponseNamespaceTool.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'namespace') {
      throw FormatException('ResponseNamespaceTool: unexpected type $value');
    }
    if (json['description'] == null) {
      throw const FormatException('ResponseNamespaceTool: missing description');
    }
    if (json['name'] == null) {
      throw const FormatException('ResponseNamespaceTool: missing name');
    }
    if (json['tools'] == null) {
      throw const FormatException('ResponseNamespaceTool: missing tools');
    }
    return ResponseNamespaceTool(
      description: json['description'] as String,
      name: json['name'] as String,
      tools: (json['tools'] as List)
          .map(
            (item) => ResponseNestedTool.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      extra: additionalJsonFields(json, const {
        'description',
        'name',
        'tools',
        'type',
      }),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...?extra,
    'type': type,
    'description': description,
    'name': name,
    'tools': tools.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  ResponseNamespaceTool copyWith({
    String? description,
    String? name,
    List<ResponseNestedTool>? tools,
    Object? extra = unsetCopyWithValue,
  }) => ResponseNamespaceTool(
    description: description ?? this.description,
    name: name ?? this.name,
    tools: tools ?? this.tools,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseNamespaceTool &&
          runtimeType == other.runtimeType &&
          description == other.description &&
          name == other.name &&
          valuesDeepEqual(tools, other.tools) &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([
    description,
    name,
    valueDeepHashCode(tools),
    valueDeepHashCode(extra),
  ]);

  @override
  String toString() =>
      'ResponseNamespaceTool('
      'description: $description, '
      'name: $name, '
      'tools: ${tools.length}, '
      'extra: ${extra?.length})';
}

/// The ResponsesCustomTool wire payload.
@immutable
class ResponseCustomTool extends ResponseNestedTool {
  /// Creates a [ResponseCustomTool].
  const ResponseCustomTool({
    this.allowedCallers,
    this.isAsync,
    this.deferLoading,
    this.description,
    this.format,
    required this.name,
    this.extra,
  });

  /// The fixed type discriminator.
  String get type => 'custom';

  /// The allowed_callers field.
  final List<String>? allowedCallers;

  /// The async field.
  final bool? isAsync;

  /// The defer_loading field.
  final bool? deferLoading;

  /// The description field.
  final String? description;

  /// The format field.
  final ResponseCustomToolFormat? format;

  /// The name field.
  final String name;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseCustomTool] from JSON.
  factory ResponseCustomTool.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'custom') {
      throw FormatException('ResponseCustomTool: unexpected type $value');
    }
    if (json['name'] == null) {
      throw const FormatException('ResponseCustomTool: missing name');
    }
    return ResponseCustomTool(
      allowedCallers: json['allowed_callers'] == null
          ? null
          : (json['allowed_callers'] as List)
                .map((item) => item as String)
                .toList(),
      isAsync: json['async'] == null ? null : json['async'] as bool,
      deferLoading: json['defer_loading'] == null
          ? null
          : json['defer_loading'] as bool,
      description: json['description'] == null
          ? null
          : json['description'] as String,
      format: json['format'] == null
          ? null
          : ResponseCustomToolFormat.fromJson(
              json['format'] as Map<String, dynamic>,
            ),
      name: json['name'] as String,
      extra: additionalJsonFields(json, const {
        'allowed_callers',
        'async',
        'defer_loading',
        'description',
        'format',
        'name',
        'type',
      }),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...?extra,
    'type': type,
    'allowed_callers': ?allowedCallers,
    'async': ?isAsync,
    'defer_loading': ?deferLoading,
    'description': ?description,
    if (format != null) 'format': format!.toJson(),
    'name': name,
  };

  /// Creates a copy with the given fields replaced.
  ResponseCustomTool copyWith({
    Object? allowedCallers = unsetCopyWithValue,
    Object? isAsync = unsetCopyWithValue,
    Object? deferLoading = unsetCopyWithValue,
    Object? description = unsetCopyWithValue,
    Object? format = unsetCopyWithValue,
    String? name,
    Object? extra = unsetCopyWithValue,
  }) => ResponseCustomTool(
    allowedCallers: allowedCallers == unsetCopyWithValue
        ? this.allowedCallers
        : (allowedCallers as List?)?.cast<String>(),
    isAsync: isAsync == unsetCopyWithValue ? this.isAsync : isAsync as bool?,
    deferLoading: deferLoading == unsetCopyWithValue
        ? this.deferLoading
        : deferLoading as bool?,
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    format: format == unsetCopyWithValue
        ? this.format
        : format as ResponseCustomToolFormat?,
    name: name ?? this.name,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseCustomTool &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(allowedCallers, other.allowedCallers) &&
          isAsync == other.isAsync &&
          deferLoading == other.deferLoading &&
          description == other.description &&
          format == other.format &&
          name == other.name &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([
    valueDeepHashCode(allowedCallers),
    isAsync,
    deferLoading,
    description,
    format,
    name,
    valueDeepHashCode(extra),
  ]);

  @override
  String toString() =>
      'ResponseCustomTool('
      'allowedCallers: ${allowedCallers?.length}, '
      'isAsync: $isAsync, '
      'deferLoading: $deferLoading, '
      'description: $description, '
      'format: $format, '
      'name: $name, '
      'extra: ${extra?.length})';
}

/// The ResponsesText wire payload.
@immutable
class ResponseCustomTextFormat extends ResponseCustomToolFormat {
  /// Creates a [ResponseCustomTextFormat].
  const ResponseCustomTextFormat({this.extra});

  /// The fixed type discriminator.
  String get type => 'text';

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseCustomTextFormat] from JSON.
  factory ResponseCustomTextFormat.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'text') {
      throw FormatException('ResponseCustomTextFormat: unexpected type $value');
    }
    return ResponseCustomTextFormat(
      extra: additionalJsonFields(json, const {'type'}),
    );
  }

  @override
  Map<String, dynamic> toJson() => {...?extra, 'type': type};

  /// Creates a copy with the given fields replaced.
  ResponseCustomTextFormat copyWith({Object? extra = unsetCopyWithValue}) =>
      ResponseCustomTextFormat(
        extra: extra == unsetCopyWithValue
            ? this.extra
            : (extra as Map?)?.cast<String, dynamic>(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseCustomTextFormat &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([valueDeepHashCode(extra)]);

  @override
  String toString() =>
      'ResponseCustomTextFormat('
      'extra: ${extra?.length})';
}

/// The ResponsesGrammar wire payload.
@immutable
class ResponseCustomGrammarFormat extends ResponseCustomToolFormat {
  /// Creates a [ResponseCustomGrammarFormat].
  const ResponseCustomGrammarFormat({
    required this.definition,
    required this.syntax,
    this.extra,
  });

  /// The fixed type discriminator.
  String get type => 'grammar';

  /// The definition field.
  final String definition;

  /// The syntax field.
  final String syntax;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseCustomGrammarFormat] from JSON.
  factory ResponseCustomGrammarFormat.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'grammar') {
      throw FormatException(
        'ResponseCustomGrammarFormat: unexpected type $value',
      );
    }
    if (json['definition'] == null) {
      throw const FormatException(
        'ResponseCustomGrammarFormat: missing definition',
      );
    }
    if (json['syntax'] == null) {
      throw const FormatException(
        'ResponseCustomGrammarFormat: missing syntax',
      );
    }
    return ResponseCustomGrammarFormat(
      definition: json['definition'] as String,
      syntax: json['syntax'] as String,
      extra: additionalJsonFields(json, const {'definition', 'syntax', 'type'}),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...?extra,
    'type': type,
    'definition': definition,
    'syntax': syntax,
  };

  /// Creates a copy with the given fields replaced.
  ResponseCustomGrammarFormat copyWith({
    String? definition,
    String? syntax,
    Object? extra = unsetCopyWithValue,
  }) => ResponseCustomGrammarFormat(
    definition: definition ?? this.definition,
    syntax: syntax ?? this.syntax,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseCustomGrammarFormat &&
          runtimeType == other.runtimeType &&
          definition == other.definition &&
          syntax == other.syntax &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode =>
      Object.hashAll([definition, syntax, valueDeepHashCode(extra)]);

  @override
  String toString() =>
      'ResponseCustomGrammarFormat('
      'definition: $definition, '
      'syntax: $syntax, '
      'extra: ${extra?.length})';
}

/// The ResponsesToolChoiceFunction wire payload.
@immutable
class ResponseToolChoiceFunction extends ResponseToolChoice {
  /// Creates a [ResponseToolChoiceFunction].
  const ResponseToolChoiceFunction({required this.name, this.extra});

  /// The fixed type discriminator.
  String get type => 'function';

  /// The name field.
  final String name;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseToolChoiceFunction] from JSON.
  factory ResponseToolChoiceFunction.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'function') {
      throw FormatException(
        'ResponseToolChoiceFunction: unexpected type $value',
      );
    }
    if (json['name'] == null) {
      throw const FormatException('ResponseToolChoiceFunction: missing name');
    }
    return ResponseToolChoiceFunction(
      name: json['name'] as String,
      extra: additionalJsonFields(json, const {'name', 'type'}),
    );
  }

  @override
  Map<String, dynamic> toJson() => {...?extra, 'type': type, 'name': name};

  /// Creates a copy with the given fields replaced.
  ResponseToolChoiceFunction copyWith({
    String? name,
    Object? extra = unsetCopyWithValue,
  }) => ResponseToolChoiceFunction(
    name: name ?? this.name,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseToolChoiceFunction &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([name, valueDeepHashCode(extra)]);

  @override
  String toString() =>
      'ResponseToolChoiceFunction('
      'name: $name, '
      'extra: ${extra?.length})';
}

/// The ResponsesFormatText wire payload.
@immutable
class ResponseTextFormatPlain extends ResponseTextFormat {
  /// Creates a [ResponseTextFormatPlain].
  const ResponseTextFormatPlain({this.extra});

  /// The fixed type discriminator.
  String get type => 'text';

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseTextFormatPlain] from JSON.
  factory ResponseTextFormatPlain.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'text') {
      throw FormatException('ResponseTextFormatPlain: unexpected type $value');
    }
    return ResponseTextFormatPlain(
      extra: additionalJsonFields(json, const {'type'}),
    );
  }

  @override
  Map<String, dynamic> toJson() => {...?extra, 'type': type};

  /// Creates a copy with the given fields replaced.
  ResponseTextFormatPlain copyWith({Object? extra = unsetCopyWithValue}) =>
      ResponseTextFormatPlain(
        extra: extra == unsetCopyWithValue
            ? this.extra
            : (extra as Map?)?.cast<String, dynamic>(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseTextFormatPlain &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([valueDeepHashCode(extra)]);

  @override
  String toString() =>
      'ResponseTextFormatPlain('
      'extra: ${extra?.length})';
}

/// The ResponsesFormatJSONObject wire payload.
@immutable
class ResponseTextFormatJsonObject extends ResponseTextFormat {
  /// Creates a [ResponseTextFormatJsonObject].
  const ResponseTextFormatJsonObject({this.extra});

  /// The fixed type discriminator.
  String get type => 'json_object';

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseTextFormatJsonObject] from JSON.
  factory ResponseTextFormatJsonObject.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'json_object') {
      throw FormatException(
        'ResponseTextFormatJsonObject: unexpected type $value',
      );
    }
    return ResponseTextFormatJsonObject(
      extra: additionalJsonFields(json, const {'type'}),
    );
  }

  @override
  Map<String, dynamic> toJson() => {...?extra, 'type': type};

  /// Creates a copy with the given fields replaced.
  ResponseTextFormatJsonObject copyWith({Object? extra = unsetCopyWithValue}) =>
      ResponseTextFormatJsonObject(
        extra: extra == unsetCopyWithValue
            ? this.extra
            : (extra as Map?)?.cast<String, dynamic>(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseTextFormatJsonObject &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([valueDeepHashCode(extra)]);

  @override
  String toString() =>
      'ResponseTextFormatJsonObject('
      'extra: ${extra?.length})';
}

/// The ResponsesFormatTextJSONSchemaConfig wire payload.
@immutable
class ResponseTextFormatJsonSchema extends ResponseTextFormat {
  /// Creates a [ResponseTextFormatJsonSchema].
  const ResponseTextFormatJsonSchema({
    this.description,
    required this.name,
    required this.schema,
    this.strict,
    this.extra,
  });

  /// The fixed type discriminator.
  String get type => 'json_schema';

  /// The description field.
  final String? description;

  /// The name field.
  final String name;

  /// The schema field.
  final Map<String, dynamic> schema;

  /// The strict field.
  final bool? strict;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseTextFormatJsonSchema] from JSON.
  factory ResponseTextFormatJsonSchema.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'json_schema') {
      throw FormatException(
        'ResponseTextFormatJsonSchema: unexpected type $value',
      );
    }
    if (json['name'] == null) {
      throw const FormatException('ResponseTextFormatJsonSchema: missing name');
    }
    if (json['schema'] == null) {
      throw const FormatException(
        'ResponseTextFormatJsonSchema: missing schema',
      );
    }
    return ResponseTextFormatJsonSchema(
      description: json['description'] == null
          ? null
          : json['description'] as String,
      name: json['name'] as String,
      schema: json['schema'] as Map<String, dynamic>,
      strict: json['strict'] == null ? null : json['strict'] as bool,
      extra: additionalJsonFields(json, const {
        'description',
        'name',
        'schema',
        'strict',
        'type',
      }),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...?extra,
    'type': type,
    'description': ?description,
    'name': name,
    'schema': schema,
    'strict': ?strict,
  };

  /// Creates a copy with the given fields replaced.
  ResponseTextFormatJsonSchema copyWith({
    Object? description = unsetCopyWithValue,
    String? name,
    Map<String, dynamic>? schema,
    Object? strict = unsetCopyWithValue,
    Object? extra = unsetCopyWithValue,
  }) => ResponseTextFormatJsonSchema(
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    name: name ?? this.name,
    schema: schema ?? this.schema,
    strict: strict == unsetCopyWithValue ? this.strict : strict as bool?,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseTextFormatJsonSchema &&
          runtimeType == other.runtimeType &&
          description == other.description &&
          name == other.name &&
          valuesDeepEqual(schema, other.schema) &&
          strict == other.strict &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([
    description,
    name,
    valueDeepHashCode(schema),
    strict,
    valueDeepHashCode(extra),
  ]);

  @override
  String toString() =>
      'ResponseTextFormatJsonSchema('
      'description: $description, '
      'name: $name, '
      'schema: ${schema.length}, '
      'strict: $strict, '
      'extra: ${extra?.length})';
}

/// The ResponsesTextConfig wire payload.
@immutable
class ResponseTextConfig {
  /// Creates a [ResponseTextConfig].
  const ResponseTextConfig({this.format, this.verbosity, this.extra});

  /// The format field.
  final ResponseTextFormat? format;

  /// The verbosity field.
  final String? verbosity;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseTextConfig] from JSON.
  factory ResponseTextConfig.fromJson(Map<String, dynamic> json) {
    return ResponseTextConfig(
      format: json['format'] == null
          ? null
          : ResponseTextFormat.fromJson(json['format'] as Map<String, dynamic>),
      verbosity: json['verbosity'] == null ? null : json['verbosity'] as String,
      extra: additionalJsonFields(json, const {'format', 'verbosity'}),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    ...?extra,
    if (format != null) 'format': format!.toJson(),
    'verbosity': ?verbosity,
  };

  /// Creates a copy with the given fields replaced.
  ResponseTextConfig copyWith({
    Object? format = unsetCopyWithValue,
    Object? verbosity = unsetCopyWithValue,
    Object? extra = unsetCopyWithValue,
  }) => ResponseTextConfig(
    format: format == unsetCopyWithValue
        ? this.format
        : format as ResponseTextFormat?,
    verbosity: verbosity == unsetCopyWithValue
        ? this.verbosity
        : verbosity as String?,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseTextConfig &&
          runtimeType == other.runtimeType &&
          format == other.format &&
          verbosity == other.verbosity &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode =>
      Object.hashAll([format, verbosity, valueDeepHashCode(extra)]);

  @override
  String toString() =>
      'ResponseTextConfig('
      'format: $format, '
      'verbosity: $verbosity, '
      'extra: ${extra?.length})';
}

/// The ResponsesSupportedReasoning wire payload.
@immutable
class ResponseReasoning {
  /// Creates a [ResponseReasoning].
  const ResponseReasoning({this.effort});

  /// The effort field.
  final ResponseReasoningEffort? effort;

  /// Parses a [ResponseReasoning] from JSON.
  factory ResponseReasoning.fromJson(Map<String, dynamic> json) {
    return ResponseReasoning(
      effort: json['effort'] == null
          ? null
          : ResponseReasoningEffort.fromJson(json['effort'] as String),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    if (effort != null) 'effort': effort!.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  ResponseReasoning copyWith({Object? effort = unsetCopyWithValue}) =>
      ResponseReasoning(
        effort: effort == unsetCopyWithValue
            ? this.effort
            : effort as ResponseReasoningEffort?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseReasoning &&
          runtimeType == other.runtimeType &&
          effort == other.effort;

  @override
  int get hashCode => Object.hashAll([effort]);

  @override
  String toString() =>
      'ResponseReasoning('
      'effort: $effort)';
}

/// Values for ResponseReasoningEffort.
enum ResponseReasoningEffort {
  /// Represents none.
  none('none'),

  /// Represents minimal.
  minimal('minimal'),

  /// Represents low.
  low('low'),

  /// Represents medium.
  medium('medium'),

  /// Represents high.
  high('high'),

  /// Represents xhigh.
  xhigh('xhigh'),

  /// Represents max.
  max('max'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const ResponseReasoningEffort(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static ResponseReasoningEffort fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// Controls which client-executed tool the model can call.
///
/// Use [ResponseToolChoiceMode] for a general policy or
/// [ResponseToolChoiceFunction] to force a named function.
@immutable
sealed class ResponseToolChoice {
  const ResponseToolChoice();

  /// Lets the model decide whether to use a tool.
  static const auto = ResponseToolChoiceMode('auto');

  /// Disables tool calls.
  static const none = ResponseToolChoiceMode('none');

  /// Requires the model to call a tool.
  static const required = ResponseToolChoiceMode('required');

  /// Decodes a policy string or a named function.
  factory ResponseToolChoice.fromJson(Object json) => switch (json) {
    final String mode => ResponseToolChoiceMode(mode),
    final Map<String, dynamic> fn => ResponseToolChoiceFunction.fromJson(fn),
    _ => throw const FormatException(
      'Expected Responses tool policy or function',
    ),
  };

  /// Serializes the tool choice.
  Object toJson();
}

/// String-valued tool policy.
@immutable
final class ResponseToolChoiceMode extends ResponseToolChoice {
  /// Creates a policy, preserving unfamiliar values from the server.
  const ResponseToolChoiceMode(this.value);

  /// The wire policy.
  final String value;

  @override
  String toJson() => value;

  @override
  bool operator ==(Object other) =>
      other is ResponseToolChoiceMode && value == other.value;

  @override
  int get hashCode => value.hashCode;
}

/// A function inside a Responses namespace.
@immutable
class ResponseNestedFunctionTool extends ResponseNestedTool {
  /// Creates a [ResponseNestedFunctionTool].
  const ResponseNestedFunctionTool({
    this.allowedCallers,
    this.isAsync,
    this.deferLoading,
    this.description,
    required this.name,
    this.outputSchema,
    this.parameters,
    this.strict,
    this.extra,
  });

  /// The fixed type discriminator.
  String get type => 'function';

  /// The allowed_callers field.
  final List<String>? allowedCallers;

  /// The async field.
  final bool? isAsync;

  /// The defer_loading field.
  final bool? deferLoading;

  /// The description field.
  final String? description;

  /// The name field.
  final String name;

  /// The output_schema field.
  final Map<String, dynamic>? outputSchema;

  /// The parameters field.
  final Object? parameters;

  /// The strict field.
  final bool? strict;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseNestedFunctionTool] from JSON.
  factory ResponseNestedFunctionTool.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'function') {
      throw FormatException(
        'ResponseNestedFunctionTool: unexpected type $value',
      );
    }
    if (json['name'] == null) {
      throw const FormatException('ResponseNestedFunctionTool: missing name');
    }
    return ResponseNestedFunctionTool(
      allowedCallers: json['allowed_callers'] == null
          ? null
          : (json['allowed_callers'] as List)
                .map((item) => item as String)
                .toList(),
      isAsync: json['async'] == null ? null : json['async'] as bool,
      deferLoading: json['defer_loading'] == null
          ? null
          : json['defer_loading'] as bool,
      description: json['description'] == null
          ? null
          : json['description'] as String,
      name: json['name'] as String,
      outputSchema: json['output_schema'] == null
          ? null
          : json['output_schema'] as Map<String, dynamic>,
      parameters: json['parameters'],
      strict: json['strict'] == null ? null : json['strict'] as bool,
      extra: additionalJsonFields(json, const {
        'allowed_callers',
        'async',
        'defer_loading',
        'description',
        'name',
        'output_schema',
        'parameters',
        'strict',
        'type',
      }),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...?extra,
    'type': type,
    'allowed_callers': ?allowedCallers,
    'async': ?isAsync,
    'defer_loading': ?deferLoading,
    'description': ?description,
    'name': name,
    'output_schema': ?outputSchema,
    'parameters': ?parameters,
    'strict': ?strict,
  };

  /// Creates a copy with the given fields replaced.
  ResponseNestedFunctionTool copyWith({
    Object? allowedCallers = unsetCopyWithValue,
    Object? isAsync = unsetCopyWithValue,
    Object? deferLoading = unsetCopyWithValue,
    Object? description = unsetCopyWithValue,
    String? name,
    Object? outputSchema = unsetCopyWithValue,
    Object? parameters = unsetCopyWithValue,
    Object? strict = unsetCopyWithValue,
    Object? extra = unsetCopyWithValue,
  }) => ResponseNestedFunctionTool(
    allowedCallers: allowedCallers == unsetCopyWithValue
        ? this.allowedCallers
        : (allowedCallers as List?)?.cast<String>(),
    isAsync: isAsync == unsetCopyWithValue ? this.isAsync : isAsync as bool?,
    deferLoading: deferLoading == unsetCopyWithValue
        ? this.deferLoading
        : deferLoading as bool?,
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    name: name ?? this.name,
    outputSchema: outputSchema == unsetCopyWithValue
        ? this.outputSchema
        : (outputSchema as Map?)?.cast<String, dynamic>(),
    parameters: parameters == unsetCopyWithValue ? this.parameters : parameters,
    strict: strict == unsetCopyWithValue ? this.strict : strict as bool?,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseNestedFunctionTool &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(allowedCallers, other.allowedCallers) &&
          isAsync == other.isAsync &&
          deferLoading == other.deferLoading &&
          description == other.description &&
          name == other.name &&
          valuesDeepEqual(outputSchema, other.outputSchema) &&
          valuesDeepEqual(parameters, other.parameters) &&
          strict == other.strict &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([
    valueDeepHashCode(allowedCallers),
    isAsync,
    deferLoading,
    description,
    name,
    valueDeepHashCode(outputSchema),
    valueDeepHashCode(parameters),
    strict,
    valueDeepHashCode(extra),
  ]);

  @override
  String toString() =>
      'ResponseNestedFunctionTool('
      'allowedCallers: ${allowedCallers?.length}, '
      'isAsync: $isAsync, '
      'deferLoading: $deferLoading, '
      'description: $description, '
      'name: $name, '
      'outputSchema: ${outputSchema?.length}, '
      'parameters: $parameters, '
      'strict: $strict, '
      'extra: ${extra?.length})';
}
