import 'package:meta/meta.dart';

import 'live_decision_questions.dart';
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
  LiveClientDelegationParam({
    this.acknowledgementDelayMs,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveClientDelegationParam',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {'acknowledgement_delay_ms', 'type'};

  /// Milliseconds before requesting an automatic spoken acknowledgment (0–800).
  /// Omission keeps the service default or the current update value.
  /// Commentary/thinking cancels pending acknowledgments across delegations.
  final int? acknowledgementDelayMs;

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
    return LiveClientDelegationParam(
      acknowledgementDelayMs: optionalLiveValue(
        json,
        'acknowledgement_delay_ms',
        'LiveClientDelegationParam',
        requireLiveInt,
        nullable: false,
      ),
      rawJson: json,
    );
  }

  @override
  void validate() {
    _validateAcknowledgementDelay(
      acknowledgementDelayMs,
      'LiveClientDelegationParam.acknowledgement_delay_ms',
    );
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    if (acknowledgementDelayMs != null)
      'acknowledgement_delay_ms': acknowledgementDelayMs,
    'type': type,
  });

  /// Copies fields; explicit null clears optional values.
  /// For nullable fields, clear flags remove the key rather than emit null.
  LiveClientDelegationParam copyWith({
    Object? acknowledgementDelayMs = liveUnset,
    Map<String, dynamic>? rawJson,
  }) => LiveClientDelegationParam(
    acknowledgementDelayMs: copyLiveValue<int>(
      acknowledgementDelayMs,
      this.acknowledgementDelayMs,
      'LiveClientDelegationParam.acknowledgement_delay_ms',
    ),
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveClientDelegationParam('
      'acknowledgementDelayMs: ${livePresence(acknowledgementDelayMs)}, '
      'type: $type, '
      'rawJson: [REDACTED])';
}

/// Delegate tasks to a Responses model managed by the Live session.
@immutable
class LiveResponsesDelegationParam extends LiveDelegation {
  /// Creates LiveResponsesDelegationParam.
  LiveResponsesDelegationParam({
    this.acknowledgementDelayMs,
    required this.responses,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveResponsesDelegationParam',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {'acknowledgement_delay_ms', 'responses', 'type'};

  /// Milliseconds before requesting an automatic spoken acknowledgment (0–800).
  /// Omission keeps the service default or the current update value.
  /// Commentary/thinking cancels pending acknowledgments across delegations.
  final int? acknowledgementDelayMs;

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
      acknowledgementDelayMs: optionalLiveValue(
        json,
        'acknowledgement_delay_ms',
        'LiveResponsesDelegationParam',
        requireLiveInt,
        nullable: false,
      ),
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
    _validateAcknowledgementDelay(
      acknowledgementDelayMs,
      'LiveResponsesDelegationParam.acknowledgement_delay_ms',
    );
    responses.validate();
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    if (acknowledgementDelayMs != null)
      'acknowledgement_delay_ms': acknowledgementDelayMs,
    'responses': responses.toJson(),
    'type': type,
  });

  /// Copies fields; explicit null clears optional values.
  /// For nullable fields, clear flags remove the key rather than emit null.
  LiveResponsesDelegationParam copyWith({
    Object? acknowledgementDelayMs = liveUnset,
    LiveResponsesDelegationSettingsInputParam? responses,
    Map<String, dynamic>? rawJson,
  }) => LiveResponsesDelegationParam(
    acknowledgementDelayMs: copyLiveValue<int>(
      acknowledgementDelayMs,
      this.acknowledgementDelayMs,
      'LiveResponsesDelegationParam.acknowledgement_delay_ms',
    ),
    responses: responses ?? this.responses,
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveResponsesDelegationParam('
      'acknowledgementDelayMs: ${livePresence(acknowledgementDelayMs)}, '
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
    this.acknowledgementDelayMs,
    this.responses,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveResponsesDelegationUpdateParam',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {'acknowledgement_delay_ms', 'responses', 'type'};

  /// Milliseconds before requesting an automatic spoken acknowledgment (0–800).
  /// Omission keeps the service default or the current update value.
  /// Commentary/thinking cancels pending acknowledgments across delegations.
  final int? acknowledgementDelayMs;

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
      acknowledgementDelayMs: optionalLiveValue(
        json,
        'acknowledgement_delay_ms',
        'LiveResponsesDelegationUpdateParam',
        requireLiveInt,
        nullable: false,
      ),
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
    _validateAcknowledgementDelay(
      acknowledgementDelayMs,
      'LiveResponsesDelegationUpdateParam.acknowledgement_delay_ms',
    );
    responses?.validate();
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    if (acknowledgementDelayMs != null)
      'acknowledgement_delay_ms': acknowledgementDelayMs,
    if (responses != null) 'responses': responses!.toJson(),
    'type': type,
  });

  /// Copies fields; explicit null clears optional values.
  /// For nullable fields, clear flags remove the key rather than emit null.
  LiveResponsesDelegationUpdateParam copyWith({
    Object? acknowledgementDelayMs = liveUnset,
    Object? responses = liveUnset,
    Map<String, dynamic>? rawJson,
  }) => LiveResponsesDelegationUpdateParam(
    acknowledgementDelayMs: copyLiveValue<int>(
      acknowledgementDelayMs,
      this.acknowledgementDelayMs,
      'LiveResponsesDelegationUpdateParam.acknowledgement_delay_ms',
    ),
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
      'acknowledgementDelayMs: ${livePresence(acknowledgementDelayMs)}, '
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

/// Startup delegation owner: the caller's application, Responses or Decisions.
sealed class LiveDelegation extends LiveJsonModel {
  /// Creates a startup delegation value.
  const LiveDelegation();

  /// The fixed delegation owner.
  String get type;

  /// Parses the three canonical startup branches.
  static LiveDelegation fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'client' => LiveClientDelegationParam.fromJson(json),
        'responses' => LiveResponsesDelegationParam.fromJson(json),
        'decisions' => LiveDecisionsDelegationParam.fromJson(json),
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

  /// Parses all three owners using distinct startup and update settings.
  static LiveDelegationUpdate fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'client' => LiveClientDelegationParam.fromJson(json),
        'responses' => LiveResponsesDelegationUpdateParam.fromJson(json),
        'decisions' => LiveDecisionsDelegationUpdateParam.fromJson(json),
        _ => throw const FormatException(
          'LiveDelegationUpdate.type: unsupported delegation owner',
        ),
      };
}

void _validateAcknowledgementDelay(int? value, String context) {
  if (value == null) return;
  requireLiveInt(value, context);
  if (value < 0 || value > 800) {
    throw FormatException('$context: expected 0–800 milliseconds');
  }
}

/// Model and native questions for Decisions-owned Live delegations.
///
/// Live evaluates one to 64 questions together. This bound is separate from
/// standalone Decisions requests. No model or question defaults are inserted.
@immutable
class LiveDecisionsSettingsInputParam extends LiveJsonModel {
  /// Creates required Decisions backend settings with an owned question list.
  LiveDecisionsSettingsInputParam({
    required this.model,
    required List<LiveDecisionQuestion> questions,
    Map<String, dynamic> rawJson = const {},
  }) : questions = List.unmodifiable(questions),
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveDecisionsSettingsInputParam',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {'model', 'questions'};

  /// Nonempty Decisions backend model name; future names remain supported.
  final String model;

  /// Ordered native questions evaluated together, with a Live-specific limit.
  final List<LiveDecisionQuestion> questions;

  /// Immutable finite future metadata; typed fields control known keys.
  final Map<String, dynamic> rawJson;

  /// Parses required model and question fields without coercion.
  factory LiveDecisionsSettingsInputParam.fromJson(Map<String, dynamic> json) =>
      LiveDecisionsSettingsInputParam(
        model: requireLiveString(
          json['model'],
          'LiveDecisionsSettingsInputParam.model',
        ),
        questions: _liveDecisionQuestionsFromJson(
          json['questions'],
          'LiveDecisionsSettingsInputParam.questions',
        ),
        rawJson: json,
      );

  @override
  void validate() {
    validateLiveLength(model, 'LiveDecisionsSettingsInputParam.model', min: 1);
    validateLiveDecisionQuestions(
      questions,
      'LiveDecisionsSettingsInputParam.questions',
    );
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'model': model,
    'questions': questions.map((question) => question.toJson()).toList(),
  });

  /// Copies every field and snapshots the supplied question collection.
  LiveDecisionsSettingsInputParam copyWith({
    String? model,
    List<LiveDecisionQuestion>? questions,
    Map<String, dynamic>? rawJson,
  }) => LiveDecisionsSettingsInputParam(
    model: model ?? this.model,
    questions: questions ?? this.questions,
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveDecisionsSettingsInputParam(model: [REDACTED], questions: [REDACTED], rawJson: [REDACTED])';
}

/// Partial Decisions backend changes; omitted fields retain current values.
@immutable
class LiveDecisionsSettingsUpdateParam extends LiveJsonModel {
  /// Creates optional nonnullable-on-wire backend updates.
  LiveDecisionsSettingsUpdateParam({
    this.model,
    List<LiveDecisionQuestion>? questions,
    Map<String, dynamic> rawJson = const {},
  }) : questions = questions == null ? null : List.unmodifiable(questions),
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveDecisionsSettingsUpdateParam',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {'model', 'questions'};

  /// New nonempty model, or omitted to retain the existing model.
  final String? model;

  /// Replacement one-to-64-question group, or omitted to retain existing ones.
  final List<LiveDecisionQuestion>? questions;

  /// Immutable finite future metadata; typed fields control known keys.
  final Map<String, dynamic> rawJson;

  /// Parses partial settings and rejects explicit null for known fields.
  factory LiveDecisionsSettingsUpdateParam.fromJson(
    Map<String, dynamic> json,
  ) => LiveDecisionsSettingsUpdateParam(
    model: optionalLiveValue(
      json,
      'model',
      'LiveDecisionsSettingsUpdateParam',
      requireLiveString,
    ),
    questions: optionalLiveValue(
      json,
      'questions',
      'LiveDecisionsSettingsUpdateParam',
      _liveDecisionQuestionsFromJson,
    ),
    rawJson: json,
  );

  @override
  void validate() {
    if (model != null) {
      validateLiveLength(
        model!,
        'LiveDecisionsSettingsUpdateParam.model',
        min: 1,
      );
    }
    if (questions != null) {
      validateLiveDecisionQuestions(
        questions!,
        'LiveDecisionsSettingsUpdateParam.questions',
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    if (model != null) 'model': model,
    if (questions != null)
      'questions': questions!.map((question) => question.toJson()).toList(),
  });

  /// Copies every field; explicit null clears an optional update, omitting it.
  LiveDecisionsSettingsUpdateParam copyWith({
    Object? model = liveUnset,
    Object? questions = liveUnset,
    Map<String, dynamic>? rawJson,
  }) => LiveDecisionsSettingsUpdateParam(
    model: copyLiveValue<String>(
      model,
      this.model,
      'LiveDecisionsSettingsUpdateParam.model',
    ),
    questions: _copyLiveDecisionQuestions(
      questions,
      this.questions,
      'LiveDecisionsSettingsUpdateParam.questions',
    ),
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveDecisionsSettingsUpdateParam(model: ${livePresence(model)}, questions: ${livePresence(questions)}, rawJson: [REDACTED])';
}

/// Delegates Live work to a Decisions backend without client-side evaluation.
@immutable
class LiveDecisionsDelegationParam extends LiveDelegation {
  /// Creates required Decisions startup settings and optional acknowledgment delay.
  LiveDecisionsDelegationParam({
    required this.decisions,
    this.acknowledgementDelayMs,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveDecisionsDelegationParam',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {'type', 'decisions', 'acknowledgement_delay_ms'};

  /// Required backend model and native question group.
  final LiveDecisionsSettingsInputParam decisions;

  /// Delay before automatic acknowledgment, from zero to 800 milliseconds.
  /// Omission leaves the service's Decisions default of 400 milliseconds.
  final int? acknowledgementDelayMs;

  @override
  String get type => 'decisions';

  /// Immutable finite future metadata; typed fields control known keys.
  final Map<String, dynamic> rawJson;

  /// Parses fixed startup delegation and required backend settings.
  factory LiveDecisionsDelegationParam.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'decisions', 'LiveDecisionsDelegationParam');
    return LiveDecisionsDelegationParam(
      decisions: LiveDecisionsSettingsInputParam.fromJson(
        requireLiveObject(
          json['decisions'],
          'LiveDecisionsDelegationParam.decisions',
        ),
      ),
      acknowledgementDelayMs: optionalLiveValue(
        json,
        'acknowledgement_delay_ms',
        'LiveDecisionsDelegationParam',
        requireLiveInt,
      ),
      rawJson: json,
    );
  }

  @override
  void validate() {
    decisions.validate();
    _validateAcknowledgementDelay(
      acknowledgementDelayMs,
      'LiveDecisionsDelegationParam.acknowledgement_delay_ms',
    );
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'type': type,
    'decisions': decisions.toJson(),
    if (acknowledgementDelayMs != null)
      'acknowledgement_delay_ms': acknowledgementDelayMs,
  });

  /// Copies fields; null delay omits it rather than emitting JSON null.
  LiveDecisionsDelegationParam copyWith({
    LiveDecisionsSettingsInputParam? decisions,
    Object? acknowledgementDelayMs = liveUnset,
    Map<String, dynamic>? rawJson,
  }) => LiveDecisionsDelegationParam(
    decisions: decisions ?? this.decisions,
    acknowledgementDelayMs: copyLiveValue<int>(
      acknowledgementDelayMs,
      this.acknowledgementDelayMs,
      'LiveDecisionsDelegationParam.acknowledgement_delay_ms',
    ),
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveDecisionsDelegationParam(type: $type, decisions: [REDACTED], acknowledgementDelayMs: ${livePresence(acknowledgementDelayMs)}, rawJson: [REDACTED])';
}

/// Updates Decisions settings without changing the session's delegation owner.
@immutable
class LiveDecisionsDelegationUpdateParam extends LiveJsonModel
    implements LiveDelegationUpdate {
  /// Creates a partial backend update with optional acknowledgment delay.
  LiveDecisionsDelegationUpdateParam({
    this.decisions,
    this.acknowledgementDelayMs,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveDecisionsDelegationUpdateParam',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {'type', 'decisions', 'acknowledgement_delay_ms'};

  /// Optional replacement fields within the current Decisions backend settings.
  final LiveDecisionsSettingsUpdateParam? decisions;

  /// Delay for subsequent delegations; omission retains the current value.
  final int? acknowledgementDelayMs;

  @override
  String get type => 'decisions';

  /// Immutable finite future metadata; typed fields control known keys.
  final Map<String, dynamic> rawJson;

  /// Parses update-only settings; explicit null is not a wire reset operation.
  factory LiveDecisionsDelegationUpdateParam.fromJson(
    Map<String, dynamic> json,
  ) {
    requireLiveType(json, 'decisions', 'LiveDecisionsDelegationUpdateParam');
    return LiveDecisionsDelegationUpdateParam(
      decisions: optionalLiveValue(
        json,
        'decisions',
        'LiveDecisionsDelegationUpdateParam',
        (value, context) => LiveDecisionsSettingsUpdateParam.fromJson(
          requireLiveObject(value, context),
        ),
      ),
      acknowledgementDelayMs: optionalLiveValue(
        json,
        'acknowledgement_delay_ms',
        'LiveDecisionsDelegationUpdateParam',
        requireLiveInt,
      ),
      rawJson: json,
    );
  }

  @override
  void validate() {
    decisions?.validate();
    _validateAcknowledgementDelay(
      acknowledgementDelayMs,
      'LiveDecisionsDelegationUpdateParam.acknowledgement_delay_ms',
    );
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'type': type,
    if (decisions != null) 'decisions': decisions!.toJson(),
    if (acknowledgementDelayMs != null)
      'acknowledgement_delay_ms': acknowledgementDelayMs,
  });

  /// Copies fields; null clears an optional field and omits its wire key.
  LiveDecisionsDelegationUpdateParam copyWith({
    Object? decisions = liveUnset,
    Object? acknowledgementDelayMs = liveUnset,
    Map<String, dynamic>? rawJson,
  }) => LiveDecisionsDelegationUpdateParam(
    decisions: copyLiveValue<LiveDecisionsSettingsUpdateParam>(
      decisions,
      this.decisions,
      'LiveDecisionsDelegationUpdateParam.decisions',
    ),
    acknowledgementDelayMs: copyLiveValue<int>(
      acknowledgementDelayMs,
      this.acknowledgementDelayMs,
      'LiveDecisionsDelegationUpdateParam.acknowledgement_delay_ms',
    ),
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveDecisionsDelegationUpdateParam(type: $type, decisions: ${livePresence(decisions)}, acknowledgementDelayMs: ${livePresence(acknowledgementDelayMs)}, rawJson: [REDACTED])';
}

/// Independently evaluates native questions after one transcript delta source.
///
/// Trigger evaluation uses shared decision items and the current transcript;
/// it does not require Decisions-owned delegation or a caller-created ID.
@immutable
class LiveDecisionTriggerInputParam extends LiveJsonModel {
  /// Creates a fixed Decisions trigger for an input or output transcript event.
  LiveDecisionTriggerInputParam({
    required this.eventType,
    required this.decisions,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveDecisionTriggerInputParam',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {'type', 'event_type', 'decisions'};

  /// Canonical input/output transcript delta event type.
  final String eventType;

  /// One to 64 native questions evaluated together for this trigger.
  final LiveDecisionQuestionsInputParam decisions;

  /// Fixed trigger kind.
  String get type => 'decisions';

  /// Immutable finite JSON snapshot; this canonical writable object is closed.
  final Map<String, dynamic> rawJson;

  /// Parses all required fields and rejects undeclared writable properties.
  factory LiveDecisionTriggerInputParam.fromJson(Map<String, dynamic> json) {
    requireClosedLiveJson(json, _knownKeys, 'LiveDecisionTriggerInputParam');
    requireLiveType(json, 'decisions', 'LiveDecisionTriggerInputParam');
    return LiveDecisionTriggerInputParam(
      eventType: requireLiveString(
        json['event_type'],
        'LiveDecisionTriggerInputParam.event_type',
      ),
      decisions: LiveDecisionQuestionsInputParam.fromJson(
        requireLiveObject(
          json['decisions'],
          'LiveDecisionTriggerInputParam.decisions',
        ),
      ),
      rawJson: json,
    );
  }

  @override
  void validate() {
    requireClosedLiveJson(rawJson, _knownKeys, 'LiveDecisionTriggerInputParam');
    if (eventType != 'session.input_transcript.delta' &&
        eventType != 'session.output_transcript.delta') {
      throw const FormatException(
        'LiveDecisionTriggerInputParam.event_type: expected an input or output transcript delta',
      );
    }
    decisions.validate();
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'type': type,
    'event_type': eventType,
    'decisions': decisions.toJson(),
  });

  /// Copies every field, preserving fixed kind and private payload ownership.
  LiveDecisionTriggerInputParam copyWith({
    String? eventType,
    LiveDecisionQuestionsInputParam? decisions,
    Map<String, dynamic>? rawJson,
  }) => LiveDecisionTriggerInputParam(
    eventType: eventType ?? this.eventType,
    decisions: decisions ?? this.decisions,
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveDecisionTriggerInputParam(type: $type, eventType: $eventType, decisions: [REDACTED], rawJson: [REDACTED])';
}

List<LiveDecisionQuestion> _liveDecisionQuestionsFromJson(
  Object? value,
  String context,
) => [
  for (final question in requireLiveList(value, context))
    LiveDecisionQuestion.fromJson(requireLiveObject(question, context)),
];

List<LiveDecisionQuestion>? _copyLiveDecisionQuestions(
  Object? value,
  List<LiveDecisionQuestion>? previous,
  String context,
) {
  if (identical(value, liveUnset)) return previous;
  if (value == null) return null;
  if (value is! List) {
    throw FormatException('$context: expected native Live questions');
  }
  return [
    for (final question in value)
      if (question is LiveDecisionQuestion)
        question
      else
        throw FormatException('$context: expected a native Live question'),
  ];
}
