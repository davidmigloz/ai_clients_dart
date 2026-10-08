import 'package:meta/meta.dart';

import 'live_json_helpers.dart';
import 'live_tools.dart';

/// Canonical closed values for LiveReasoningEffort.
enum LiveReasoningEffort {
  /// The `none` wire value.
  none('none'),

  /// The `minimal` wire value.
  minimal('minimal'),

  /// The `low` wire value.
  low('low'),

  /// The `medium` wire value.
  medium('medium'),

  /// The `high` wire value.
  high('high'),

  /// The `xhigh` wire value.
  xhigh('xhigh');

  const LiveReasoningEffort(this.value);

  /// The exact API wire value.
  final String value;

  /// Serializes the canonical wire value.
  String toJson() => value;

  /// Parses a closed wire value without echoing private input.
  static LiveReasoningEffort fromJson(String value) {
    for (final item in LiveReasoningEffort.values) {
      if (item.value == value) return item;
    }
    throw const FormatException(
      'LiveReasoningEffort: expected a supported value',
    );
  }
}

/// Canonical closed values for LiveReasoningSummary.
enum LiveReasoningSummary {
  /// The `concise` wire value.
  concise('concise'),

  /// The `detailed` wire value.
  detailed('detailed'),

  /// The `auto` wire value.
  auto('auto');

  const LiveReasoningSummary(this.value);

  /// The exact API wire value.
  final String value;

  /// Serializes the canonical wire value.
  String toJson() => value;

  /// Parses a closed wire value without echoing private input.
  static LiveReasoningSummary fromJson(String value) {
    for (final item in LiveReasoningSummary.values) {
      if (item.value == value) return item;
    }
    throw const FormatException(
      'LiveReasoningSummary: expected a supported value',
    );
  }
}

/// Canonical closed values for LiveTextVerbosity.
enum LiveTextVerbosity {
  /// The `low` wire value.
  low('low'),

  /// The `medium` wire value.
  medium('medium'),

  /// The `high` wire value.
  high('high');

  const LiveTextVerbosity(this.value);

  /// The exact API wire value.
  final String value;

  /// Serializes the canonical wire value.
  String toJson() => value;

  /// Parses a closed wire value without echoing private input.
  static LiveTextVerbosity fromJson(String value) {
    for (final item in LiveTextVerbosity.values) {
      if (item.value == value) return item;
    }
    throw const FormatException(
      'LiveTextVerbosity: expected a supported value',
    );
  }
}

/// Canonical closed values for LiveResponsesServiceTier.
enum LiveResponsesServiceTier {
  /// The `auto` wire value.
  auto('auto'),

  /// The `default` wire value.
  defaultTier('default'),

  /// The `fast_tier_temp_pilot` wire value.
  fastTierTempPilot('fast_tier_temp_pilot'),

  /// The `flex` wire value.
  flex('flex'),

  /// The `priority` wire value.
  priority('priority'),

  /// The `ultrafast` wire value.
  ultrafast('ultrafast');

  const LiveResponsesServiceTier(this.value);

  /// The exact API wire value.
  final String value;

  /// Serializes the canonical wire value.
  String toJson() => value;

  /// Parses a closed wire value without echoing private input.
  static LiveResponsesServiceTier fromJson(String value) {
    for (final item in LiveResponsesServiceTier.values) {
      if (item.value == value) return item;
    }
    throw const FormatException(
      'LiveResponsesServiceTier: expected a supported value',
    );
  }
}

/// Canonical closed values for LiveToolChoiceEnum.
enum LiveToolChoiceEnum {
  /// The `auto` wire value.
  auto('auto'),

  /// The `none` wire value.
  none('none'),

  /// The `required` wire value.
  required('required');

  const LiveToolChoiceEnum(this.value);

  /// The exact API wire value.
  final String value;

  /// Serializes the canonical wire value.
  String toJson() => value;

  /// Parses a closed wire value without echoing private input.
  static LiveToolChoiceEnum fromJson(String value) {
    for (final item in LiveToolChoiceEnum.values) {
      if (item.value == value) return item;
    }
    throw const FormatException(
      'LiveToolChoiceEnum: expected a supported value',
    );
  }
}

/// Delegate tasks to your application. The Live session emits delegation events that your backend handles.
@immutable
class LiveClientDelegationParam extends LiveDelegation
    implements LiveDelegationUpdate {
  /// Creates LiveClientDelegationParam.
  LiveClientDelegationParam({Map<String, dynamic> rawJson = const {}})
    : rawJson = snapshotLiveJson(
        rawJson,
        'LiveClientDelegationParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }

  static const _knownKeys = {'type'};

  /// The delegation owner. Always `client` for tasks handled by your application.
  @override
  String get type => 'client';

  /// Immutable finite JSON; typed fields control known wire members.
  final Map<String, dynamic> rawJson;

  /// Parses LiveClientDelegationParam with contextual validation.
  factory LiveClientDelegationParam.fromJson(Map<String, dynamic> json) {
    requireLiveType(
      json,
      'client',
      'LiveClientDelegationParam',
      key: 'type',
      required: true,
    );
    return LiveClientDelegationParam(rawJson: json);
  }

  @override
  void validate() {}

  @override
  Map<String, dynamic> toJson() =>
      mergeLiveJson(rawJson, _knownKeys, {'type': type});

  /// Copies fields; explicit null clears optional values.
  /// For nullable fields, clear flags remove the key rather than emit null.
  LiveClientDelegationParam copyWith({Map<String, dynamic>? rawJson}) =>
      LiveClientDelegationParam(rawJson: rawJson ?? this.rawJson);

  @override
  String toString() =>
      'LiveClientDelegationParam('
      'type: $type, '
      'rawJson: [REDACTED])';
}

/// Delegate tasks to a Responses model managed by the Live session.
@immutable
class LiveResponsesDelegationParam extends LiveDelegation {
  /// Creates LiveResponsesDelegationParam.
  LiveResponsesDelegationParam({
    required this.responses,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveResponsesDelegationParam',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {'responses', 'type'};

  /// Backend model, prompt, and tools used when the Live session delegates a task to Responses.
  final LiveResponsesDelegationSettingsInputParam responses;

  /// The delegation owner. Always `responses` for tasks handled by the Responses API.
  @override
  String get type => 'responses';

  /// Immutable finite JSON; typed fields control known wire members.
  final Map<String, dynamic> rawJson;

  /// Parses LiveResponsesDelegationParam with contextual validation.
  factory LiveResponsesDelegationParam.fromJson(Map<String, dynamic> json) {
    requireLiveType(
      json,
      'responses',
      'LiveResponsesDelegationParam',
      key: 'type',
      required: true,
    );
    return LiveResponsesDelegationParam(
      responses: LiveResponsesDelegationSettingsInputParam.fromJson(
        requireLiveObject(
          json['responses'],
          'LiveResponsesDelegationParam.responses',
        ),
      ),
      rawJson: json,
    );
  }

  @override
  void validate() {
    responses.validate();
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'responses': responses.toJson(),
    'type': type,
  });

  /// Copies fields; explicit null clears optional values.
  /// For nullable fields, clear flags remove the key rather than emit null.
  LiveResponsesDelegationParam copyWith({
    LiveResponsesDelegationSettingsInputParam? responses,
    Map<String, dynamic>? rawJson,
  }) => LiveResponsesDelegationParam(
    responses: responses ?? this.responses,
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveResponsesDelegationParam('
      'responses: ${livePresence(responses)}, '
      'type: $type, '
      'rawJson: [REDACTED])';
}

/// Update the Responses backend for an existing Live session without changing delegation ownership.
@immutable
class LiveResponsesDelegationUpdateParam extends LiveJsonModel
    implements LiveDelegationUpdate {
  /// Creates LiveResponsesDelegationUpdateParam.
  LiveResponsesDelegationUpdateParam({
    this.responses,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveResponsesDelegationUpdateParam',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {'responses', 'type'};

  /// Responses backend settings to update. Omitted settings keep their existing values.
  final LiveResponsesDelegationSettingsUpdateInputParam? responses;

  /// The delegation owner. Always `responses` for tasks handled by the Responses API.
  @override
  String get type => 'responses';

  /// Immutable finite JSON; typed fields control known wire members.
  final Map<String, dynamic> rawJson;

  /// Parses LiveResponsesDelegationUpdateParam with contextual validation.
  factory LiveResponsesDelegationUpdateParam.fromJson(
    Map<String, dynamic> json,
  ) {
    requireLiveType(
      json,
      'responses',
      'LiveResponsesDelegationUpdateParam',
      key: 'type',
      required: true,
    );
    return LiveResponsesDelegationUpdateParam(
      responses: optionalLiveValue(
        json,
        'responses',
        'LiveResponsesDelegationUpdateParam',
        (value, context) =>
            LiveResponsesDelegationSettingsUpdateInputParam.fromJson(
              requireLiveObject(value, context),
            ),
        nullable: false,
      ),
      rawJson: json,
    );
  }

  @override
  void validate() {
    responses?.validate();
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    if (responses != null) 'responses': responses!.toJson(),
    'type': type,
  });

  /// Copies fields; explicit null clears optional values.
  /// For nullable fields, clear flags remove the key rather than emit null.
  LiveResponsesDelegationUpdateParam copyWith({
    Object? responses = liveUnset,
    Map<String, dynamic>? rawJson,
  }) => LiveResponsesDelegationUpdateParam(
    responses: copyLiveValue<LiveResponsesDelegationSettingsUpdateInputParam>(
      responses,
      this.responses,
      'LiveResponsesDelegationUpdateParam.responses',
    ),
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveResponsesDelegationUpdateParam('
      'responses: ${livePresence(responses)}, '
      'type: $type, '
      'rawJson: [REDACTED])';
}

/// Reasoning options for Responses requests made on behalf of the Live session.
@immutable
class LiveDelegationReasoningInputParam extends LiveJsonModel {
  /// Creates LiveDelegationReasoningInputParam.
  LiveDelegationReasoningInputParam({
    this.effort,
    bool hasEffort = false,
    this.summary,
    bool hasSummary = false,
    Map<String, dynamic> rawJson = const {},
  }) : hasEffort = hasEffort || effort != null,
       hasSummary = hasSummary || summary != null,
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveDelegationReasoningInputParam',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {'effort', 'summary'};

  /// How much reasoning effort the delegated Responses model should use. Supported values depend on the backend model.
  final LiveReasoningEffort? effort;

  /// Distinguishes omission from explicit null for effort.
  final bool hasEffort;

  /// The reasoning summary to request from the delegated Responses model, when supported.
  final LiveReasoningSummary? summary;

  /// Distinguishes omission from explicit null for summary.
  final bool hasSummary;

  /// Immutable finite JSON; typed fields control known wire members.
  final Map<String, dynamic> rawJson;

  /// Parses LiveDelegationReasoningInputParam with contextual validation.
  factory LiveDelegationReasoningInputParam.fromJson(
    Map<String, dynamic> json,
  ) {
    return LiveDelegationReasoningInputParam(
      effort: optionalLiveValue(
        json,
        'effort',
        'LiveDelegationReasoningInputParam',
        (value, context) =>
            LiveReasoningEffort.fromJson(requireLiveString(value, context)),
        nullable: true,
      ),
      hasEffort: json.containsKey('effort'),
      summary: optionalLiveValue(
        json,
        'summary',
        'LiveDelegationReasoningInputParam',
        (value, context) =>
            LiveReasoningSummary.fromJson(requireLiveString(value, context)),
        nullable: true,
      ),
      hasSummary: json.containsKey('summary'),
      rawJson: json,
    );
  }

  @override
  void validate() {}

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    if (hasEffort) 'effort': effort?.toJson(),
    if (hasSummary) 'summary': summary?.toJson(),
  });

  /// Copies fields; explicit null clears optional values.
  /// For nullable fields, clear flags remove the key rather than emit null.
  LiveDelegationReasoningInputParam copyWith({
    Object? effort = liveUnset,
    bool clearEffort = false,
    Object? summary = liveUnset,
    bool clearSummary = false,
    Map<String, dynamic>? rawJson,
  }) => LiveDelegationReasoningInputParam(
    effort: clearEffort
        ? null
        : copyLiveValue<LiveReasoningEffort>(
            effort,
            this.effort,
            'LiveDelegationReasoningInputParam.effort',
          ),
    hasEffort: !clearEffort && (!identical(effort, liveUnset) || hasEffort),
    summary: clearSummary
        ? null
        : copyLiveValue<LiveReasoningSummary>(
            summary,
            this.summary,
            'LiveDelegationReasoningInputParam.summary',
          ),
    hasSummary: !clearSummary && (!identical(summary, liveUnset) || hasSummary),
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveDelegationReasoningInputParam('
      'effort: ${livePresence(effort)}, '
      'hasEffort: $hasEffort, '
      'summary: ${livePresence(summary)}, '
      'hasSummary: $hasSummary, '
      'rawJson: [REDACTED])';
}

/// Text generation options for the Live session’s Responses backend.
@immutable
class LiveDelegationTextInputParam extends LiveJsonModel {
  /// Creates LiveDelegationTextInputParam.
  LiveDelegationTextInputParam({
    this.verbosity,
    bool hasVerbosity = false,
    Map<String, dynamic> rawJson = const {},
  }) : hasVerbosity = hasVerbosity || verbosity != null,
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveDelegationTextInputParam',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {'verbosity'};

  /// The amount of detail in text generated by the Responses backend. This does not configure the Live model’s spoken delivery.
  final LiveTextVerbosity? verbosity;

  /// Distinguishes omission from explicit null for verbosity.
  final bool hasVerbosity;

  /// Immutable finite JSON; typed fields control known wire members.
  final Map<String, dynamic> rawJson;

  /// Parses LiveDelegationTextInputParam with contextual validation.
  factory LiveDelegationTextInputParam.fromJson(Map<String, dynamic> json) {
    return LiveDelegationTextInputParam(
      verbosity: optionalLiveValue(
        json,
        'verbosity',
        'LiveDelegationTextInputParam',
        (value, context) =>
            LiveTextVerbosity.fromJson(requireLiveString(value, context)),
        nullable: true,
      ),
      hasVerbosity: json.containsKey('verbosity'),
      rawJson: json,
    );
  }

  @override
  void validate() {}

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    if (hasVerbosity) 'verbosity': verbosity?.toJson(),
  });

  /// Copies fields; explicit null clears optional values.
  /// For nullable fields, clear flags remove the key rather than emit null.
  LiveDelegationTextInputParam copyWith({
    Object? verbosity = liveUnset,
    bool clearVerbosity = false,
    Map<String, dynamic>? rawJson,
  }) => LiveDelegationTextInputParam(
    verbosity: clearVerbosity
        ? null
        : copyLiveValue<LiveTextVerbosity>(
            verbosity,
            this.verbosity,
            'LiveDelegationTextInputParam.verbosity',
          ),
    hasVerbosity:
        !clearVerbosity && (!identical(verbosity, liveUnset) || hasVerbosity),
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveDelegationTextInputParam('
      'verbosity: ${livePresence(verbosity)}, '
      'hasVerbosity: $hasVerbosity, '
      'rawJson: [REDACTED])';
}

/// Model, prompt, and tool settings for tasks delegated by the Live session to a Responses backend.
@immutable
class LiveResponsesDelegationSettingsInputParam extends LiveJsonModel {
  /// Creates LiveResponsesDelegationSettingsInputParam.
  LiveResponsesDelegationSettingsInputParam({
    this.instructions,
    bool hasInstructions = false,
    this.maxOutputTokens,
    bool hasMaxOutputTokens = false,
    required this.model,
    this.parallelToolCalls,
    bool hasParallelToolCalls = false,
    this.reasoning,
    bool hasReasoning = false,
    this.serviceTier,
    bool hasServiceTier = false,
    this.text,
    bool hasText = false,
    this.toolChoice,
    List<LiveTool>? tools,
    Map<String, dynamic> rawJson = const {},
  }) : hasInstructions = hasInstructions || instructions != null,
       hasMaxOutputTokens = hasMaxOutputTokens || maxOutputTokens != null,
       hasParallelToolCalls = hasParallelToolCalls || parallelToolCalls != null,
       hasReasoning = hasReasoning || reasoning != null,
       hasServiceTier = hasServiceTier || serviceTier != null,
       hasText = hasText || text != null,
       tools = tools == null ? null : List.unmodifiable(tools),
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveResponsesDelegationSettingsInputParam',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {
    'instructions',
    'max_output_tokens',
    'model',
    'parallel_tool_calls',
    'reasoning',
    'service_tier',
    'text',
    'tool_choice',
    'tools',
  };

  /// Instructions for the delegated Responses model, separate from Live instructions. See [backend prompting](https://developers.openai.com/api/docs/guides/live-delegation#start-with-your-existing-backend-prompt).
  final String? instructions;

  /// Distinguishes omission from explicit null for instructions.
  final bool hasInstructions;

  /// Maximum number of output tokens for each delegated response.
  final int? maxOutputTokens;

  /// Distinguishes omission from explicit null for max_output_tokens.
  final bool hasMaxOutputTokens;

  /// The model used for server-owned Responses delegations.
  final String model;

  /// Whether the delegated Responses model may request multiple tool calls in a single response.
  final bool? parallelToolCalls;

  /// Distinguishes omission from explicit null for parallel_tool_calls.
  final bool hasParallelToolCalls;

  /// Reasoning settings passed to each delegated Responses request.
  final LiveDelegationReasoningInputParam? reasoning;

  /// Distinguishes omission from explicit null for reasoning.
  final bool hasReasoning;

  /// Service tier for delegated Responses requests.
  final LiveResponsesServiceTier? serviceTier;

  /// Distinguishes omission from explicit null for service_tier.
  final bool hasServiceTier;

  /// Text generation settings passed to each delegated Responses request.
  final LiveDelegationTextInputParam? text;

  /// Distinguishes omission from explicit null for text.
  final bool hasText;

  /// Controls which tool the Responses backend uses when handling a task delegated by the Live model.
  final LiveToolChoice? toolChoice;

  /// Tools available to the Responses backend while it handles tasks delegated by the Live model.
  final List<LiveTool>? tools;

  /// Immutable finite JSON; typed fields control known wire members.
  final Map<String, dynamic> rawJson;

  /// Parses LiveResponsesDelegationSettingsInputParam with contextual validation.
  factory LiveResponsesDelegationSettingsInputParam.fromJson(
    Map<String, dynamic> json,
  ) {
    return LiveResponsesDelegationSettingsInputParam(
      instructions: optionalLiveValue(
        json,
        'instructions',
        'LiveResponsesDelegationSettingsInputParam',
        requireLiveString,
        nullable: true,
      ),
      hasInstructions: json.containsKey('instructions'),
      maxOutputTokens: optionalLiveValue(
        json,
        'max_output_tokens',
        'LiveResponsesDelegationSettingsInputParam',
        requireLiveInt,
        nullable: true,
      ),
      hasMaxOutputTokens: json.containsKey('max_output_tokens'),
      model: requireLiveString(
        json['model'],
        'LiveResponsesDelegationSettingsInputParam.model',
      ),
      parallelToolCalls: optionalLiveValue(
        json,
        'parallel_tool_calls',
        'LiveResponsesDelegationSettingsInputParam',
        requireLiveBool,
        nullable: true,
      ),
      hasParallelToolCalls: json.containsKey('parallel_tool_calls'),
      reasoning: optionalLiveValue(
        json,
        'reasoning',
        'LiveResponsesDelegationSettingsInputParam',
        (value, context) => LiveDelegationReasoningInputParam.fromJson(
          requireLiveObject(value, context),
        ),
        nullable: true,
      ),
      hasReasoning: json.containsKey('reasoning'),
      serviceTier: optionalLiveValue(
        json,
        'service_tier',
        'LiveResponsesDelegationSettingsInputParam',
        (value, context) => LiveResponsesServiceTier.fromJson(
          requireLiveString(value, context),
        ),
        nullable: true,
      ),
      hasServiceTier: json.containsKey('service_tier'),
      text: optionalLiveValue(
        json,
        'text',
        'LiveResponsesDelegationSettingsInputParam',
        (value, context) => LiveDelegationTextInputParam.fromJson(
          requireLiveObject(value, context),
        ),
        nullable: true,
      ),
      hasText: json.containsKey('text'),
      toolChoice: optionalLiveValue(
        json,
        'tool_choice',
        'LiveResponsesDelegationSettingsInputParam',
        (value, context) => LiveToolChoice.fromJson(value),
        nullable: false,
      ),
      tools: optionalLiveValue(
        json,
        'tools',
        'LiveResponsesDelegationSettingsInputParam',
        (value, context) => requireLiveList(value, context)
            .map((item) => LiveTool.fromJson(requireLiveObject(item, context)))
            .toList(),
        nullable: false,
      ),
      rawJson: json,
    );
  }

  @override
  void validate() {
    if (maxOutputTokens != null) {
      if (!maxOutputTokens!.isFinite || maxOutputTokens! < 16) {
        throw const FormatException(
          'LiveResponsesDelegationSettingsInputParam.max_output_tokens: unsupported integer value',
        );
      }
    }
    reasoning?.validate();
    text?.validate();
    toolChoice?.validate();
    for (final item in tools ?? const <LiveTool>[]) {
      item.validate();
    }
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    if (hasInstructions) 'instructions': instructions,
    if (hasMaxOutputTokens) 'max_output_tokens': maxOutputTokens,
    'model': model,
    if (hasParallelToolCalls) 'parallel_tool_calls': parallelToolCalls,
    if (hasReasoning) 'reasoning': reasoning?.toJson(),
    if (hasServiceTier) 'service_tier': serviceTier?.toJson(),
    if (hasText) 'text': text?.toJson(),
    if (toolChoice != null) 'tool_choice': toolChoice!.toJson(),
    if (tools != null) 'tools': tools!.map((item) => item.toJson()).toList(),
  });

  /// Copies fields; explicit null clears optional values.
  /// For nullable fields, clear flags remove the key rather than emit null.
  LiveResponsesDelegationSettingsInputParam copyWith({
    Object? instructions = liveUnset,
    bool clearInstructions = false,
    Object? maxOutputTokens = liveUnset,
    bool clearMaxOutputTokens = false,
    String? model,
    Object? parallelToolCalls = liveUnset,
    bool clearParallelToolCalls = false,
    Object? reasoning = liveUnset,
    bool clearReasoning = false,
    Object? serviceTier = liveUnset,
    bool clearServiceTier = false,
    Object? text = liveUnset,
    bool clearText = false,
    Object? toolChoice = liveUnset,
    Object? tools = liveUnset,
    Map<String, dynamic>? rawJson,
  }) => LiveResponsesDelegationSettingsInputParam(
    instructions: clearInstructions
        ? null
        : copyLiveValue<String>(
            instructions,
            this.instructions,
            'LiveResponsesDelegationSettingsInputParam.instructions',
          ),
    hasInstructions:
        !clearInstructions &&
        (!identical(instructions, liveUnset) || hasInstructions),
    maxOutputTokens: clearMaxOutputTokens
        ? null
        : copyLiveValue<int>(
            maxOutputTokens,
            this.maxOutputTokens,
            'LiveResponsesDelegationSettingsInputParam.max_output_tokens',
          ),
    hasMaxOutputTokens:
        !clearMaxOutputTokens &&
        (!identical(maxOutputTokens, liveUnset) || hasMaxOutputTokens),
    model: model ?? this.model,
    parallelToolCalls: clearParallelToolCalls
        ? null
        : copyLiveValue<bool>(
            parallelToolCalls,
            this.parallelToolCalls,
            'LiveResponsesDelegationSettingsInputParam.parallel_tool_calls',
          ),
    hasParallelToolCalls:
        !clearParallelToolCalls &&
        (!identical(parallelToolCalls, liveUnset) || hasParallelToolCalls),
    reasoning: clearReasoning
        ? null
        : copyLiveValue<LiveDelegationReasoningInputParam>(
            reasoning,
            this.reasoning,
            'LiveResponsesDelegationSettingsInputParam.reasoning',
          ),
    hasReasoning:
        !clearReasoning && (!identical(reasoning, liveUnset) || hasReasoning),
    serviceTier: clearServiceTier
        ? null
        : copyLiveValue<LiveResponsesServiceTier>(
            serviceTier,
            this.serviceTier,
            'LiveResponsesDelegationSettingsInputParam.service_tier',
          ),
    hasServiceTier:
        !clearServiceTier &&
        (!identical(serviceTier, liveUnset) || hasServiceTier),
    text: clearText
        ? null
        : copyLiveValue<LiveDelegationTextInputParam>(
            text,
            this.text,
            'LiveResponsesDelegationSettingsInputParam.text',
          ),
    hasText: !clearText && (!identical(text, liveUnset) || hasText),
    toolChoice: copyLiveValue<LiveToolChoice>(
      toolChoice,
      this.toolChoice,
      'LiveResponsesDelegationSettingsInputParam.tool_choice',
    ),
    tools: copyLiveValue<List<LiveTool>>(
      tools,
      this.tools,
      'LiveResponsesDelegationSettingsInputParam.tools',
    ),
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveResponsesDelegationSettingsInputParam('
      'instructions: ${livePresence(instructions)}, '
      'hasInstructions: $hasInstructions, '
      'maxOutputTokens: ${livePresence(maxOutputTokens)}, '
      'hasMaxOutputTokens: $hasMaxOutputTokens, '
      'model: ${livePresence(model)}, '
      'parallelToolCalls: ${livePresence(parallelToolCalls)}, '
      'hasParallelToolCalls: $hasParallelToolCalls, '
      'reasoning: ${livePresence(reasoning)}, '
      'hasReasoning: $hasReasoning, '
      'serviceTier: ${livePresence(serviceTier)}, '
      'hasServiceTier: $hasServiceTier, '
      'text: ${livePresence(text)}, '
      'hasText: $hasText, '
      'toolChoice: ${livePresence(toolChoice)}, '
      'tools: ${livePresence(tools)}, '
      'rawJson: [REDACTED])';
}

/// Updates to the Responses backend of an existing Live session. Omitted settings retain their current values.
@immutable
class LiveResponsesDelegationSettingsUpdateInputParam extends LiveJsonModel {
  /// Creates LiveResponsesDelegationSettingsUpdateInputParam.
  LiveResponsesDelegationSettingsUpdateInputParam({
    this.instructions,
    bool hasInstructions = false,
    this.maxOutputTokens,
    bool hasMaxOutputTokens = false,
    this.model,
    this.parallelToolCalls,
    bool hasParallelToolCalls = false,
    this.reasoning,
    bool hasReasoning = false,
    this.serviceTier,
    bool hasServiceTier = false,
    this.text,
    bool hasText = false,
    this.toolChoice,
    List<LiveTool>? tools,
    Map<String, dynamic> rawJson = const {},
  }) : hasInstructions = hasInstructions || instructions != null,
       hasMaxOutputTokens = hasMaxOutputTokens || maxOutputTokens != null,
       hasParallelToolCalls = hasParallelToolCalls || parallelToolCalls != null,
       hasReasoning = hasReasoning || reasoning != null,
       hasServiceTier = hasServiceTier || serviceTier != null,
       hasText = hasText || text != null,
       tools = tools == null ? null : List.unmodifiable(tools),
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveResponsesDelegationSettingsUpdateInputParam',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {
    'instructions',
    'max_output_tokens',
    'model',
    'parallel_tool_calls',
    'reasoning',
    'service_tier',
    'text',
    'tool_choice',
    'tools',
  };

  /// Instructions for the delegated Responses model, separate from Live instructions. See [backend prompting](https://developers.openai.com/api/docs/guides/live-delegation#start-with-your-existing-backend-prompt).
  final String? instructions;

  /// Distinguishes omission from explicit null for instructions.
  final bool hasInstructions;

  /// Maximum number of output tokens for each delegated response.
  final int? maxOutputTokens;

  /// Distinguishes omission from explicit null for max_output_tokens.
  final bool hasMaxOutputTokens;

  /// The Responses backend model to use for subsequent delegated requests. Omit to keep the current backend model.
  final String? model;

  /// Whether the delegated Responses model may request multiple tool calls in a single response.
  final bool? parallelToolCalls;

  /// Distinguishes omission from explicit null for parallel_tool_calls.
  final bool hasParallelToolCalls;

  /// Reasoning settings passed to each delegated Responses request.
  final LiveDelegationReasoningInputParam? reasoning;

  /// Distinguishes omission from explicit null for reasoning.
  final bool hasReasoning;

  /// Service tier for delegated Responses requests.
  final LiveResponsesServiceTier? serviceTier;

  /// Distinguishes omission from explicit null for service_tier.
  final bool hasServiceTier;

  /// Text generation settings passed to each delegated Responses request.
  final LiveDelegationTextInputParam? text;

  /// Distinguishes omission from explicit null for text.
  final bool hasText;

  /// Controls which tool the Responses backend uses when handling a task delegated by the Live model.
  final LiveToolChoice? toolChoice;

  /// Tools available to the Responses backend while it handles tasks delegated by the Live model.
  final List<LiveTool>? tools;

  /// Immutable finite JSON; typed fields control known wire members.
  final Map<String, dynamic> rawJson;

  /// Parses LiveResponsesDelegationSettingsUpdateInputParam with contextual validation.
  factory LiveResponsesDelegationSettingsUpdateInputParam.fromJson(
    Map<String, dynamic> json,
  ) {
    return LiveResponsesDelegationSettingsUpdateInputParam(
      instructions: optionalLiveValue(
        json,
        'instructions',
        'LiveResponsesDelegationSettingsUpdateInputParam',
        requireLiveString,
        nullable: true,
      ),
      hasInstructions: json.containsKey('instructions'),
      maxOutputTokens: optionalLiveValue(
        json,
        'max_output_tokens',
        'LiveResponsesDelegationSettingsUpdateInputParam',
        requireLiveInt,
        nullable: true,
      ),
      hasMaxOutputTokens: json.containsKey('max_output_tokens'),
      model: optionalLiveValue(
        json,
        'model',
        'LiveResponsesDelegationSettingsUpdateInputParam',
        requireLiveString,
        nullable: false,
      ),
      parallelToolCalls: optionalLiveValue(
        json,
        'parallel_tool_calls',
        'LiveResponsesDelegationSettingsUpdateInputParam',
        requireLiveBool,
        nullable: true,
      ),
      hasParallelToolCalls: json.containsKey('parallel_tool_calls'),
      reasoning: optionalLiveValue(
        json,
        'reasoning',
        'LiveResponsesDelegationSettingsUpdateInputParam',
        (value, context) => LiveDelegationReasoningInputParam.fromJson(
          requireLiveObject(value, context),
        ),
        nullable: true,
      ),
      hasReasoning: json.containsKey('reasoning'),
      serviceTier: optionalLiveValue(
        json,
        'service_tier',
        'LiveResponsesDelegationSettingsUpdateInputParam',
        (value, context) => LiveResponsesServiceTier.fromJson(
          requireLiveString(value, context),
        ),
        nullable: true,
      ),
      hasServiceTier: json.containsKey('service_tier'),
      text: optionalLiveValue(
        json,
        'text',
        'LiveResponsesDelegationSettingsUpdateInputParam',
        (value, context) => LiveDelegationTextInputParam.fromJson(
          requireLiveObject(value, context),
        ),
        nullable: true,
      ),
      hasText: json.containsKey('text'),
      toolChoice: optionalLiveValue(
        json,
        'tool_choice',
        'LiveResponsesDelegationSettingsUpdateInputParam',
        (value, context) => LiveToolChoice.fromJson(value),
        nullable: false,
      ),
      tools: optionalLiveValue(
        json,
        'tools',
        'LiveResponsesDelegationSettingsUpdateInputParam',
        (value, context) => requireLiveList(value, context)
            .map((item) => LiveTool.fromJson(requireLiveObject(item, context)))
            .toList(),
        nullable: false,
      ),
      rawJson: json,
    );
  }

  @override
  void validate() {
    if (maxOutputTokens != null) {
      if (!maxOutputTokens!.isFinite || maxOutputTokens! < 16) {
        throw const FormatException(
          'LiveResponsesDelegationSettingsUpdateInputParam.max_output_tokens: unsupported integer value',
        );
      }
    }
    reasoning?.validate();
    text?.validate();
    toolChoice?.validate();
    for (final item in tools ?? const <LiveTool>[]) {
      item.validate();
    }
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    if (hasInstructions) 'instructions': instructions,
    if (hasMaxOutputTokens) 'max_output_tokens': maxOutputTokens,
    if (model != null) 'model': model,
    if (hasParallelToolCalls) 'parallel_tool_calls': parallelToolCalls,
    if (hasReasoning) 'reasoning': reasoning?.toJson(),
    if (hasServiceTier) 'service_tier': serviceTier?.toJson(),
    if (hasText) 'text': text?.toJson(),
    if (toolChoice != null) 'tool_choice': toolChoice!.toJson(),
    if (tools != null) 'tools': tools!.map((item) => item.toJson()).toList(),
  });

  /// Copies fields; explicit null clears optional values.
  /// For nullable fields, clear flags remove the key rather than emit null.
  LiveResponsesDelegationSettingsUpdateInputParam copyWith({
    Object? instructions = liveUnset,
    bool clearInstructions = false,
    Object? maxOutputTokens = liveUnset,
    bool clearMaxOutputTokens = false,
    Object? model = liveUnset,
    Object? parallelToolCalls = liveUnset,
    bool clearParallelToolCalls = false,
    Object? reasoning = liveUnset,
    bool clearReasoning = false,
    Object? serviceTier = liveUnset,
    bool clearServiceTier = false,
    Object? text = liveUnset,
    bool clearText = false,
    Object? toolChoice = liveUnset,
    Object? tools = liveUnset,
    Map<String, dynamic>? rawJson,
  }) => LiveResponsesDelegationSettingsUpdateInputParam(
    instructions: clearInstructions
        ? null
        : copyLiveValue<String>(
            instructions,
            this.instructions,
            'LiveResponsesDelegationSettingsUpdateInputParam.instructions',
          ),
    hasInstructions:
        !clearInstructions &&
        (!identical(instructions, liveUnset) || hasInstructions),
    maxOutputTokens: clearMaxOutputTokens
        ? null
        : copyLiveValue<int>(
            maxOutputTokens,
            this.maxOutputTokens,
            'LiveResponsesDelegationSettingsUpdateInputParam.max_output_tokens',
          ),
    hasMaxOutputTokens:
        !clearMaxOutputTokens &&
        (!identical(maxOutputTokens, liveUnset) || hasMaxOutputTokens),
    model: copyLiveValue<String>(
      model,
      this.model,
      'LiveResponsesDelegationSettingsUpdateInputParam.model',
    ),
    parallelToolCalls: clearParallelToolCalls
        ? null
        : copyLiveValue<bool>(
            parallelToolCalls,
            this.parallelToolCalls,
            'LiveResponsesDelegationSettingsUpdateInputParam.parallel_tool_calls',
          ),
    hasParallelToolCalls:
        !clearParallelToolCalls &&
        (!identical(parallelToolCalls, liveUnset) || hasParallelToolCalls),
    reasoning: clearReasoning
        ? null
        : copyLiveValue<LiveDelegationReasoningInputParam>(
            reasoning,
            this.reasoning,
            'LiveResponsesDelegationSettingsUpdateInputParam.reasoning',
          ),
    hasReasoning:
        !clearReasoning && (!identical(reasoning, liveUnset) || hasReasoning),
    serviceTier: clearServiceTier
        ? null
        : copyLiveValue<LiveResponsesServiceTier>(
            serviceTier,
            this.serviceTier,
            'LiveResponsesDelegationSettingsUpdateInputParam.service_tier',
          ),
    hasServiceTier:
        !clearServiceTier &&
        (!identical(serviceTier, liveUnset) || hasServiceTier),
    text: clearText
        ? null
        : copyLiveValue<LiveDelegationTextInputParam>(
            text,
            this.text,
            'LiveResponsesDelegationSettingsUpdateInputParam.text',
          ),
    hasText: !clearText && (!identical(text, liveUnset) || hasText),
    toolChoice: copyLiveValue<LiveToolChoice>(
      toolChoice,
      this.toolChoice,
      'LiveResponsesDelegationSettingsUpdateInputParam.tool_choice',
    ),
    tools: copyLiveValue<List<LiveTool>>(
      tools,
      this.tools,
      'LiveResponsesDelegationSettingsUpdateInputParam.tools',
    ),
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveResponsesDelegationSettingsUpdateInputParam('
      'instructions: ${livePresence(instructions)}, '
      'hasInstructions: $hasInstructions, '
      'maxOutputTokens: ${livePresence(maxOutputTokens)}, '
      'hasMaxOutputTokens: $hasMaxOutputTokens, '
      'model: ${livePresence(model)}, '
      'parallelToolCalls: ${livePresence(parallelToolCalls)}, '
      'hasParallelToolCalls: $hasParallelToolCalls, '
      'reasoning: ${livePresence(reasoning)}, '
      'hasReasoning: $hasReasoning, '
      'serviceTier: ${livePresence(serviceTier)}, '
      'hasServiceTier: $hasServiceTier, '
      'text: ${livePresence(text)}, '
      'hasText: $hasText, '
      'toolChoice: ${livePresence(toolChoice)}, '
      'tools: ${livePresence(tools)}, '
      'rawJson: [REDACTED])';
}

/// Startup delegation owner: the caller's application or Responses.
sealed class LiveDelegation extends LiveJsonModel {
  /// Creates a startup delegation value.
  const LiveDelegation();

  /// The fixed delegation owner.
  String get type;

  /// Parses the two canonical startup branches.
  static LiveDelegation fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'client' => LiveClientDelegationParam.fromJson(json),
        'responses' => LiveResponsesDelegationParam.fromJson(json),
        _ => throw const FormatException(
          'LiveDelegation.type: unsupported delegation owner',
        ),
      };
}

/// Backend settings updates; startup delegation mode remains immutable.
sealed class LiveDelegationUpdate {
  /// Creates a delegation update value.
  const LiveDelegationUpdate();

  /// Serializes the canonical update branch.
  Map<String, dynamic> toJson();

  /// Validates backend settings before they are sent.
  void validate();

  /// The fixed delegation owner.
  String get type;

  /// Parses client or Responses updates using the distinct update settings.
  static LiveDelegationUpdate fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'client' => LiveClientDelegationParam.fromJson(json),
        'responses' => LiveResponsesDelegationUpdateParam.fromJson(json),
        _ => throw const FormatException(
          'LiveDelegationUpdate.type: unsupported delegation owner',
        ),
      };
}
