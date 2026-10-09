import '../common/copy_with_sentinel.dart';
import 'agent_enums.dart';
import 'agent_json_helpers.dart';

/// Explicit configuration for creating and coordinating subagents.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentMultiAgentConfig extends AgentJsonModel {
  /// Creates a validated [AgentMultiAgentConfig].
  AgentMultiAgentConfig({required this.enabled, this.maxConcurrentSubagents}) {
    validate();
  }

  /// Whether subagent tools are enabled.
  final bool enabled;

  /// Maximum number of subagents that may run concurrently. Defaults to 6.
  final int? maxConcurrentSubagents;

  /// Parses [AgentMultiAgentConfig] with contextual, payload-free errors.
  factory AgentMultiAgentConfig.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'enabled',
      'max_concurrent_subagents',
    ], 'AgentMultiAgentConfig');
    return AgentMultiAgentConfig(
      enabled: requiredAgentValue(
        json,
        'enabled',
        'AgentMultiAgentConfig.enabled',
        requireAgentBool,
        nullable: false,
      )!,
      maxConcurrentSubagents: optionalAgentValue(
        json,
        'max_concurrent_subagents',
        'AgentMultiAgentConfig.maxConcurrentSubagents',
        requireAgentInt,
        nullable: false,
      ),
    );
  }
  @override
  void validate() {
    if (maxConcurrentSubagents != null) {
      validateAgentInt(
        maxConcurrentSubagents!,
        'AgentMultiAgentConfig.maxConcurrentSubagents',
        min: 1,
        max: 4294967295,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'max_concurrent_subagents': ?maxConcurrentSubagents,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentMultiAgentConfig copyWith({
    bool? enabled,
    Object? maxConcurrentSubagents = unsetCopyWithValue,
  }) => AgentMultiAgentConfig(
    enabled: enabled ?? this.enabled,
    maxConcurrentSubagents: copyAgentValue<int>(
      maxConcurrentSubagents,
      this.maxConcurrentSubagents,
      'AgentMultiAgentConfig.maxConcurrentSubagents',
    ),
  );
}

/// The resolved configuration for creating and coordinating subagents.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentMultiAgent extends AgentJsonModel {
  /// Creates a validated [AgentMultiAgent].
  AgentMultiAgent({
    required this.enabled,
    required this.maxConcurrentSubagents,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'enabled',
         'max_concurrent_subagents',
       ], 'AgentMultiAgent') {
    validate();
  }

  /// Whether subagent tools are enabled. Defaults to false.
  final bool enabled;

  /// Maximum number of subagents that may run concurrently, or null when disabled. Defaults to 6 when enabled.
  final int? maxConcurrentSubagents;

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentMultiAgent] with contextual, payload-free errors.
  factory AgentMultiAgent.fromJson(Map<String, dynamic> json) {
    return AgentMultiAgent(
      enabled: requiredAgentValue(
        json,
        'enabled',
        'AgentMultiAgent.enabled',
        requireAgentBool,
        nullable: false,
      )!,
      maxConcurrentSubagents: requiredAgentValue(
        json,
        'max_concurrent_subagents',
        'AgentMultiAgent.maxConcurrentSubagents',
        requireAgentInt,
        nullable: true,
      ),
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'enabled',
            'max_concurrent_subagents',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    if (maxConcurrentSubagents != null) {
      validateAgentInt(
        maxConcurrentSubagents!,
        'AgentMultiAgent.maxConcurrentSubagents',
        min: 1,
        max: 4294967295,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'enabled': enabled,
    'max_concurrent_subagents': maxConcurrentSubagents,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentMultiAgent copyWith({
    bool? enabled,
    Object? maxConcurrentSubagents = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentMultiAgent(
    enabled: enabled ?? this.enabled,
    maxConcurrentSubagents: copyAgentValue<int>(
      maxConcurrentSubagents,
      this.maxConcurrentSubagents,
      'AgentMultiAgent.maxConcurrentSubagents',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Reasoning configuration for the agent.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentReasoningConfig extends AgentJsonModel {
  /// Creates a validated [AgentReasoningConfig].
  AgentReasoningConfig({
    AgentReasoningEffortParam? effort,
    bool clearEffort = false,
    AgentReasoningSummaryParam? summary,
    bool clearSummary = false,
  }) : clearEffort = clearEffort,
       effort = clearEffort ? null : effort,
       clearSummary = clearSummary,
       summary = clearSummary ? null : summary {
    validate();
  }

  /// The amount of reasoning effort the model should use. Omission lets the model select it.
  final AgentReasoningEffortParam? effort;

  /// Sends `effort: null`, rather than omitting it.
  final bool clearEffort;

  /// Controls whether the response includes a reasoning summary.
  final AgentReasoningSummaryParam? summary;

  /// Sends `summary: null`, rather than omitting it.
  final bool clearSummary;

  /// Parses [AgentReasoningConfig] with contextual, payload-free errors.
  factory AgentReasoningConfig.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'effort',
      'summary',
    ], 'AgentReasoningConfig');
    return AgentReasoningConfig(
      effort: optionalAgentValue(
        json,
        'effort',
        'AgentReasoningConfig.effort',
        (value, context) => AgentReasoningEffortParam.fromJson(value),
        nullable: true,
      ),
      clearEffort: json.containsKey('effort') && json['effort'] == null,
      summary: optionalAgentValue(
        json,
        'summary',
        'AgentReasoningConfig.summary',
        (value, context) => AgentReasoningSummaryParam.fromJson(value),
        nullable: true,
      ),
      clearSummary: json.containsKey('summary') && json['summary'] == null,
    );
  }
  @override
  void validate() {
    if (effort != null) {
      validateAgentEnum(effort!.value, [
        'none',
        'minimal',
        'low',
        'medium',
        'high',
        'xhigh',
        'max',
      ], 'AgentReasoningConfig.effort');
    }
    if (summary != null) {
      validateAgentEnum(summary!.value, [
        'concise',
        'detailed',
        'auto',
      ], 'AgentReasoningConfig.summary');
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    if (clearEffort)
      'effort': null
    else if (effort != null)
      'effort': effort!.toJson(),
    if (clearSummary)
      'summary': null
    else if (summary != null)
      'summary': summary!.toJson(),
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentReasoningConfig copyWith({
    Object? effort = unsetCopyWithValue,
    bool? clearEffort,
    Object? summary = unsetCopyWithValue,
    bool? clearSummary,
  }) => AgentReasoningConfig(
    effort: copyAgentValue<AgentReasoningEffortParam>(
      effort,
      this.effort,
      'AgentReasoningConfig.effort',
    ),
    clearEffort:
        clearEffort ??
        (identical(effort, unsetCopyWithValue)
            ? this.clearEffort
            : effort == null),
    summary: copyAgentValue<AgentReasoningSummaryParam>(
      summary,
      this.summary,
      'AgentReasoningConfig.summary',
    ),
    clearSummary:
        clearSummary ??
        (identical(summary, unsetCopyWithValue)
            ? this.clearSummary
            : summary == null),
  );
}

/// The reasoning configuration used by an agent.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentReasoning extends AgentJsonModel {
  /// Creates a validated [AgentReasoning].
  AgentReasoning({
    required this.effort,
    required this.summary,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'effort',
         'summary',
       ], 'AgentReasoning') {
    validate();
  }

  /// The requested reasoning effort, or `null` when the model selects its own default.
  final AgentReasoningEffortResource? effort;

  /// The requested reasoning summary format, or `null` when summaries are disabled.
  final AgentReasoningSummaryResource? summary;

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentReasoning] with contextual, payload-free errors.
  factory AgentReasoning.fromJson(Map<String, dynamic> json) {
    return AgentReasoning(
      effort: requiredAgentValue(
        json,
        'effort',
        'AgentReasoning.effort',
        (value, context) => AgentReasoningEffortResource.fromJson(value),
        nullable: true,
      ),
      summary: requiredAgentValue(
        json,
        'summary',
        'AgentReasoning.summary',
        (value, context) => AgentReasoningSummaryResource.fromJson(value),
        nullable: true,
      ),
      rawJson: {
        for (final entry in json.entries)
          if (!const ['effort', 'summary'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {}
  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'effort': effort?.toJson(),
    'summary': summary?.toJson(),
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentReasoning copyWith({
    Object? effort = unsetCopyWithValue,
    Object? summary = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentReasoning(
    effort: copyAgentValue<AgentReasoningEffortResource>(
      effort,
      this.effort,
      'AgentReasoning.effort',
    ),
    summary: copyAgentValue<AgentReasoningSummaryResource>(
      summary,
      this.summary,
      'AgentReasoning.summary',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// The output format for generated text.
///
/// Variants: [AgentJsonSchemaFormat], [AgentPlainTextFormat] and [UnknownAgentTextFormat].
sealed class AgentTextFormat extends AgentJsonModel {
  const AgentTextFormat();

  /// Parses known variants strictly and retains future received variants.
  factory AgentTextFormat.fromJson(Map<String, dynamic> json) =>
      switch (requireAgentString(json['type'], 'AgentTextFormat.type')) {
        'json_schema' => AgentJsonSchemaFormat.fromJson(json),
        'text' => AgentPlainTextFormat.fromJson(json),
        _ => UnknownAgentTextFormat.fromJson(json),
      };

  /// The canonical discriminator.
  String get type;

  @override
  Map<String, dynamic> toJson();

  /// Creates the `json_schema` variant.
  factory AgentTextFormat.jsonSchema({required Map<String, dynamic> schema}) =
      AgentJsonSchemaFormat;

  /// Creates the `text` variant.
  const factory AgentTextFormat.text() = AgentPlainTextFormat;
}

/// A future discriminator with a finite, deeply detached private snapshot.
/// Known malformed variants cannot use this fallback.
final class UnknownAgentTextFormat extends AgentTextFormat {
  const UnknownAgentTextFormat._(this.rawJson);

  /// Retains an unknown discriminator without admitting a malformed known one.
  factory UnknownAgentTextFormat.fromJson(Map<String, dynamic> json) {
    final type = requireAgentString(
      json['type'],
      'UnknownAgentTextFormat.type',
    );
    if (const ['json_schema', 'text'].contains(type)) {
      throw const FormatException(
        'UnknownAgentTextFormat: expected a future type',
      );
    }
    return UnknownAgentTextFormat._(
      snapshotAgentJson(json, 'UnknownAgentTextFormat'),
    );
  }

  /// The detached original received object.
  final Map<String, dynamic> rawJson;

  @override
  String get type => rawJson['type'] as String;

  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Copies this future received object.
  UnknownAgentTextFormat copyWith({Map<String, dynamic>? rawJson}) =>
      UnknownAgentTextFormat.fromJson(rawJson ?? this.rawJson);

  @override
  void validate() => throw const FormatException(
    'UnknownAgentTextFormat: future tools/transports are not writable',
  );
}

/// Constrains generated text to a JSON Schema.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentJsonSchemaFormat extends AgentTextFormat {
  /// Creates a validated [AgentJsonSchemaFormat].
  AgentJsonSchemaFormat({required Map<String, dynamic> schema})
    : schema = snapshotAgentJson(schema, 'AgentJsonSchemaFormat.schema') {
    validate();
  }

  /// The JSON Schema that generated text must match.
  final Map<String, dynamic> schema;

  /// The type of the object. Always `json_schema`.
  @override
  String get type => 'json_schema';

  /// Parses [AgentJsonSchemaFormat] with contextual, payload-free errors.
  factory AgentJsonSchemaFormat.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'schema',
      'type',
    ], 'AgentJsonSchemaFormat');
    requireAgentTag(json, 'type', 'json_schema', 'AgentJsonSchemaFormat');
    return AgentJsonSchemaFormat(
      schema: requiredAgentValue(
        json,
        'schema',
        'AgentJsonSchemaFormat.schema',
        requireAgentObject,
        nullable: false,
      )!,
    );
  }
  @override
  void validate() {
    validateAgentCount(
      schema.length,
      'AgentJsonSchemaFormat.schema',
      min: 0,
      max: 1024,
    );
    for (final key in schema.keys) {
      validateAgentLength(
        key,
        'AgentJsonSchemaFormat.schema',
        min: 1,
        max: 256,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {'schema': schema, 'type': type};

  /// Copies values; omitted arguments retain their values and null presence.
  AgentJsonSchemaFormat copyWith({Map<String, dynamic>? schema}) =>
      AgentJsonSchemaFormat(schema: schema ?? this.schema);
}

/// Generates ordinary text without a structured-output constraint.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentPlainTextFormat extends AgentTextFormat {
  /// Creates a validated [AgentPlainTextFormat].
  const AgentPlainTextFormat();

  /// The type of the object. Always `text`.
  @override
  String get type => 'text';

  /// Parses [AgentPlainTextFormat] with contextual, payload-free errors.
  factory AgentPlainTextFormat.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const ['type'], 'AgentPlainTextFormat');
    requireAgentTag(json, 'type', 'text', 'AgentPlainTextFormat');
    return const AgentPlainTextFormat();
  }
  @override
  void validate() {}
  @override
  Map<String, dynamic> toJson() => {'type': type};

  /// Copies values; omitted arguments retain their values and null presence.
  AgentPlainTextFormat copyWith() => const AgentPlainTextFormat();
}

/// The effective output format for generated text.
///
/// Variants: [AgentJsonSchemaFormatResource], [AgentPlainTextFormatResource] and [UnknownAgentTextFormatResource].
sealed class AgentTextFormatResource extends AgentJsonModel {
  const AgentTextFormatResource();

  /// Parses known variants strictly and retains future received variants.
  factory AgentTextFormatResource.fromJson(Map<String, dynamic> json) =>
      switch (requireAgentString(
        json['type'],
        'AgentTextFormatResource.type',
      )) {
        'json_schema' => AgentJsonSchemaFormatResource.fromJson(json),
        'text' => AgentPlainTextFormatResource.fromJson(json),
        _ => UnknownAgentTextFormatResource.fromJson(json),
      };

  /// The canonical discriminator.
  String get type;

  @override
  Map<String, dynamic> toJson();

  /// Creates the `json_schema` variant.
  factory AgentTextFormatResource.jsonSchema({
    required Map<String, dynamic> schema,
    Map<String, dynamic> rawJson,
  }) = AgentJsonSchemaFormatResource;

  /// Creates the `text` variant.
  factory AgentTextFormatResource.text({Map<String, dynamic> rawJson}) =
      AgentPlainTextFormatResource;
}

/// A future discriminator with a finite, deeply detached private snapshot.
/// Known malformed variants cannot use this fallback.
final class UnknownAgentTextFormatResource extends AgentTextFormatResource {
  const UnknownAgentTextFormatResource._(this.rawJson);

  /// Retains an unknown discriminator without admitting a malformed known one.
  factory UnknownAgentTextFormatResource.fromJson(Map<String, dynamic> json) {
    final type = requireAgentString(
      json['type'],
      'UnknownAgentTextFormatResource.type',
    );
    if (const ['json_schema', 'text'].contains(type)) {
      throw const FormatException(
        'UnknownAgentTextFormatResource: expected a future type',
      );
    }
    return UnknownAgentTextFormatResource._(
      snapshotAgentJson(json, 'UnknownAgentTextFormatResource'),
    );
  }

  /// The detached original received object.
  final Map<String, dynamic> rawJson;

  @override
  String get type => rawJson['type'] as String;

  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Copies this future received object.
  UnknownAgentTextFormatResource copyWith({Map<String, dynamic>? rawJson}) =>
      UnknownAgentTextFormatResource.fromJson(rawJson ?? this.rawJson);
}

/// Constrains generated text to a JSON Schema.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentJsonSchemaFormatResource extends AgentTextFormatResource {
  /// Creates a validated [AgentJsonSchemaFormatResource].
  AgentJsonSchemaFormatResource({
    required Map<String, dynamic> schema,
    Map<String, dynamic> rawJson = const {},
  }) : schema = snapshotAgentJson(
         schema,
         'AgentJsonSchemaFormatResource.schema',
       ),
       rawJson = agentExtras(rawJson, const [
         'schema',
         'type',
       ], 'AgentJsonSchemaFormatResource') {
    validate();
  }

  /// The JSON Schema that generated text must match.
  final Map<String, dynamic> schema;

  /// The type of the object. Always `json_schema`.
  @override
  String get type => 'json_schema';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentJsonSchemaFormatResource] with contextual, payload-free errors.
  factory AgentJsonSchemaFormatResource.fromJson(Map<String, dynamic> json) {
    requireAgentTag(
      json,
      'type',
      'json_schema',
      'AgentJsonSchemaFormatResource',
    );
    return AgentJsonSchemaFormatResource(
      schema: requiredAgentValue(
        json,
        'schema',
        'AgentJsonSchemaFormatResource.schema',
        requireAgentObject,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['schema', 'type'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentCount(
      schema.length,
      'AgentJsonSchemaFormatResource.schema',
      min: 0,
    );
    for (final key in schema.keys) {
      validateAgentLength(key, 'AgentJsonSchemaFormatResource.schema', min: 0);
    }
  }

  @override
  Map<String, dynamic> toJson() => {...rawJson, 'schema': schema, 'type': type};

  /// Copies values; omitted arguments retain their values and null presence.
  AgentJsonSchemaFormatResource copyWith({
    Map<String, dynamic>? schema,
    Map<String, dynamic>? rawJson,
  }) => AgentJsonSchemaFormatResource(
    schema: schema ?? this.schema,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Generates ordinary text without a structured-output constraint.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentPlainTextFormatResource extends AgentTextFormatResource {
  /// Creates a validated [AgentPlainTextFormatResource].
  AgentPlainTextFormatResource({Map<String, dynamic> rawJson = const {}})
    : rawJson = agentExtras(rawJson, const [
        'type',
      ], 'AgentPlainTextFormatResource') {
    validate();
  }

  /// The type of the object. Always `text`.
  @override
  String get type => 'text';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentPlainTextFormatResource] with contextual, payload-free errors.
  factory AgentPlainTextFormatResource.fromJson(Map<String, dynamic> json) {
    requireAgentTag(json, 'type', 'text', 'AgentPlainTextFormatResource');
    return AgentPlainTextFormatResource(
      rawJson: {
        for (final entry in json.entries)
          if (!const ['type'].contains(entry.key)) entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {}
  @override
  Map<String, dynamic> toJson() => {...rawJson, 'type': type};

  /// Copies values; omitted arguments retain their values and null presence.
  AgentPlainTextFormatResource copyWith({Map<String, dynamic>? rawJson}) =>
      AgentPlainTextFormatResource(rawJson: rawJson ?? this.rawJson);
}

/// Configuration for text generated by the agent.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentTextConfig extends AgentJsonModel {
  /// Creates a validated [AgentTextConfig].
  AgentTextConfig({
    AgentTextFormat? format,
    bool clearFormat = false,
    AgentVerbosityParam? verbosity,
    bool clearVerbosity = false,
  }) : clearFormat = clearFormat,
       format = clearFormat ? null : format,
       clearVerbosity = clearVerbosity,
       verbosity = clearVerbosity ? null : verbosity {
    validate();
  }

  /// The output format. Omission uses ordinary text (`{"type": "text"}`).
  final AgentTextFormat? format;

  /// Sends `format: null`, rather than omitting it.
  final bool clearFormat;

  /// The amount of text the model should produce. Defaults to `medium`, matching Responses.
  final AgentVerbosityParam? verbosity;

  /// Sends `verbosity: null`, rather than omitting it.
  final bool clearVerbosity;

  /// Parses [AgentTextConfig] with contextual, payload-free errors.
  factory AgentTextConfig.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'format',
      'verbosity',
    ], 'AgentTextConfig');
    return AgentTextConfig(
      format: optionalAgentValue(
        json,
        'format',
        'AgentTextConfig.format',
        (value, context) =>
            AgentTextFormat.fromJson(requireAgentObject(value, context)),
        nullable: true,
      ),
      clearFormat: json.containsKey('format') && json['format'] == null,
      verbosity: optionalAgentValue(
        json,
        'verbosity',
        'AgentTextConfig.verbosity',
        (value, context) => AgentVerbosityParam.fromJson(value),
        nullable: true,
      ),
      clearVerbosity:
          json.containsKey('verbosity') && json['verbosity'] == null,
    );
  }
  @override
  void validate() {
    if (format != null) {
      format!.validate();
    }
    if (verbosity != null) {
      validateAgentEnum(verbosity!.value, [
        'low',
        'medium',
        'high',
      ], 'AgentTextConfig.verbosity');
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    if (clearFormat)
      'format': null
    else if (format != null)
      'format': format!.toJson(),
    if (clearVerbosity)
      'verbosity': null
    else if (verbosity != null)
      'verbosity': verbosity!.toJson(),
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentTextConfig copyWith({
    Object? format = unsetCopyWithValue,
    bool? clearFormat,
    Object? verbosity = unsetCopyWithValue,
    bool? clearVerbosity,
  }) => AgentTextConfig(
    format: copyAgentValue<AgentTextFormat>(
      format,
      this.format,
      'AgentTextConfig.format',
    ),
    clearFormat:
        clearFormat ??
        (identical(format, unsetCopyWithValue)
            ? this.clearFormat
            : format == null),
    verbosity: copyAgentValue<AgentVerbosityParam>(
      verbosity,
      this.verbosity,
      'AgentTextConfig.verbosity',
    ),
    clearVerbosity:
        clearVerbosity ??
        (identical(verbosity, unsetCopyWithValue)
            ? this.clearVerbosity
            : verbosity == null),
  );
}

/// The text configuration used by an agent.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentText extends AgentJsonModel {
  /// Creates a validated [AgentText].
  AgentText({
    required this.format,
    required this.verbosity,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'format',
         'verbosity',
       ], 'AgentText') {
    validate();
  }

  /// The effective output format. Defaults to ordinary text.
  final AgentTextFormatResource format;

  /// The amount of text produced by the agent. Defaults to `medium`.
  final AgentVerbosityResource verbosity;

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentText] with contextual, payload-free errors.
  factory AgentText.fromJson(Map<String, dynamic> json) {
    return AgentText(
      format: requiredAgentValue(
        json,
        'format',
        'AgentText.format',
        (value, context) => AgentTextFormatResource.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: false,
      )!,
      verbosity: requiredAgentValue(
        json,
        'verbosity',
        'AgentText.verbosity',
        (value, context) => AgentVerbosityResource.fromJson(value),
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['format', 'verbosity'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    format.validate();
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'format': format.toJson(),
    'verbosity': verbosity.toJson(),
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentText copyWith({
    AgentTextFormatResource? format,
    AgentVerbosityResource? verbosity,
    Map<String, dynamic>? rawJson,
  }) => AgentText(
    format: format ?? this.format,
    verbosity: verbosity ?? this.verbosity,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Approximate user location used to localize web search results.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentWebSearchLocation extends AgentJsonModel {
  /// Creates a validated [AgentWebSearchLocation].
  AgentWebSearchLocation({
    String? city,
    bool clearCity = false,
    String? country,
    bool clearCountry = false,
    String? region,
    bool clearRegion = false,
    String? timezone,
    bool clearTimezone = false,
  }) : clearCity = clearCity,
       city = clearCity ? null : city,
       clearCountry = clearCountry,
       country = clearCountry ? null : country,
       clearRegion = clearRegion,
       region = clearRegion ? null : region,
       clearTimezone = clearTimezone,
       timezone = clearTimezone ? null : timezone {
    validate();
  }

  /// The city name.
  final String? city;

  /// Sends `city: null`, rather than omitting it.
  final bool clearCity;

  /// The two-letter ISO country code, such as `US`.
  final String? country;

  /// Sends `country: null`, rather than omitting it.
  final bool clearCountry;

  /// The region or state name.
  final String? region;

  /// Sends `region: null`, rather than omitting it.
  final bool clearRegion;

  /// The IANA timezone, such as `America/Los_Angeles`.
  final String? timezone;

  /// Sends `timezone: null`, rather than omitting it.
  final bool clearTimezone;

  /// Parses [AgentWebSearchLocation] with contextual, payload-free errors.
  factory AgentWebSearchLocation.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'city',
      'country',
      'region',
      'timezone',
    ], 'AgentWebSearchLocation');
    return AgentWebSearchLocation(
      city: optionalAgentValue(
        json,
        'city',
        'AgentWebSearchLocation.city',
        requireAgentString,
        nullable: true,
      ),
      clearCity: json.containsKey('city') && json['city'] == null,
      country: optionalAgentValue(
        json,
        'country',
        'AgentWebSearchLocation.country',
        requireAgentString,
        nullable: true,
      ),
      clearCountry: json.containsKey('country') && json['country'] == null,
      region: optionalAgentValue(
        json,
        'region',
        'AgentWebSearchLocation.region',
        requireAgentString,
        nullable: true,
      ),
      clearRegion: json.containsKey('region') && json['region'] == null,
      timezone: optionalAgentValue(
        json,
        'timezone',
        'AgentWebSearchLocation.timezone',
        requireAgentString,
        nullable: true,
      ),
      clearTimezone: json.containsKey('timezone') && json['timezone'] == null,
    );
  }
  @override
  void validate() {
    if (city != null) {
      validateAgentLength(
        city!,
        'AgentWebSearchLocation.city',
        min: 0,
        max: 1048576,
      );
    }
    if (country != null) {
      validateAgentLength(
        country!,
        'AgentWebSearchLocation.country',
        min: 0,
        max: 1048576,
      );
    }
    if (region != null) {
      validateAgentLength(
        region!,
        'AgentWebSearchLocation.region',
        min: 0,
        max: 1048576,
      );
    }
    if (timezone != null) {
      validateAgentLength(
        timezone!,
        'AgentWebSearchLocation.timezone',
        min: 0,
        max: 1048576,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    if (clearCity) 'city': null else 'city': ?city,
    if (clearCountry) 'country': null else 'country': ?country,
    if (clearRegion) 'region': null else 'region': ?region,
    if (clearTimezone) 'timezone': null else 'timezone': ?timezone,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentWebSearchLocation copyWith({
    Object? city = unsetCopyWithValue,
    bool? clearCity,
    Object? country = unsetCopyWithValue,
    bool? clearCountry,
    Object? region = unsetCopyWithValue,
    bool? clearRegion,
    Object? timezone = unsetCopyWithValue,
    bool? clearTimezone,
  }) => AgentWebSearchLocation(
    city: copyAgentValue<String>(
      city,
      this.city,
      'AgentWebSearchLocation.city',
    ),
    clearCity:
        clearCity ??
        (identical(city, unsetCopyWithValue) ? this.clearCity : city == null),
    country: copyAgentValue<String>(
      country,
      this.country,
      'AgentWebSearchLocation.country',
    ),
    clearCountry:
        clearCountry ??
        (identical(country, unsetCopyWithValue)
            ? this.clearCountry
            : country == null),
    region: copyAgentValue<String>(
      region,
      this.region,
      'AgentWebSearchLocation.region',
    ),
    clearRegion:
        clearRegion ??
        (identical(region, unsetCopyWithValue)
            ? this.clearRegion
            : region == null),
    timezone: copyAgentValue<String>(
      timezone,
      this.timezone,
      'AgentWebSearchLocation.timezone',
    ),
    clearTimezone:
        clearTimezone ??
        (identical(timezone, unsetCopyWithValue)
            ? this.clearTimezone
            : timezone == null),
  );
}

/// Approximate user location used to localize web search results.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentWebSearchLocationResource extends AgentJsonModel {
  /// Creates a validated [AgentWebSearchLocationResource].
  AgentWebSearchLocationResource({
    required this.city,
    required this.country,
    required this.region,
    required this.timezone,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'city',
         'country',
         'region',
         'timezone',
       ], 'AgentWebSearchLocationResource') {
    validate();
  }

  /// The city name.
  final String? city;

  /// The two-letter ISO country code, such as `US`.
  final String? country;

  /// The region or state name.
  final String? region;

  /// The IANA timezone, such as `America/Los_Angeles`.
  final String? timezone;

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentWebSearchLocationResource] with contextual, payload-free errors.
  factory AgentWebSearchLocationResource.fromJson(Map<String, dynamic> json) {
    return AgentWebSearchLocationResource(
      city: requiredAgentValue(
        json,
        'city',
        'AgentWebSearchLocationResource.city',
        requireAgentString,
        nullable: true,
      ),
      country: requiredAgentValue(
        json,
        'country',
        'AgentWebSearchLocationResource.country',
        requireAgentString,
        nullable: true,
      ),
      region: requiredAgentValue(
        json,
        'region',
        'AgentWebSearchLocationResource.region',
        requireAgentString,
        nullable: true,
      ),
      timezone: requiredAgentValue(
        json,
        'timezone',
        'AgentWebSearchLocationResource.timezone',
        requireAgentString,
        nullable: true,
      ),
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'city',
            'country',
            'region',
            'timezone',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    if (city != null) {
      validateAgentLength(city!, 'AgentWebSearchLocationResource.city', min: 0);
    }
    if (country != null) {
      validateAgentLength(
        country!,
        'AgentWebSearchLocationResource.country',
        min: 0,
      );
    }
    if (region != null) {
      validateAgentLength(
        region!,
        'AgentWebSearchLocationResource.region',
        min: 0,
      );
    }
    if (timezone != null) {
      validateAgentLength(
        timezone!,
        'AgentWebSearchLocationResource.timezone',
        min: 0,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'city': city,
    'country': country,
    'region': region,
    'timezone': timezone,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentWebSearchLocationResource copyWith({
    Object? city = unsetCopyWithValue,
    Object? country = unsetCopyWithValue,
    Object? region = unsetCopyWithValue,
    Object? timezone = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentWebSearchLocationResource(
    city: copyAgentValue<String>(
      city,
      this.city,
      'AgentWebSearchLocationResource.city',
    ),
    country: copyAgentValue<String>(
      country,
      this.country,
      'AgentWebSearchLocationResource.country',
    ),
    region: copyAgentValue<String>(
      region,
      this.region,
      'AgentWebSearchLocationResource.region',
    ),
    timezone: copyAgentValue<String>(
      timezone,
      this.timezone,
      'AgentWebSearchLocationResource.timezone',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}
