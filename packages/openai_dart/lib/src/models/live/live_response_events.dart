import '../responses/streaming/response_stream_event.dart';
import 'live_json_helpers.dart';
import 'live_server_events.dart';

/// Dispatches the nested compact Responses stream while preserving its Live IDs.
///
/// [LiveResponsesLifecycleEvent] uses a reduced snapshot view, never ordinary
/// Response. [LiveResponsesGranularEvent] reuses declared granular codecs after
/// validating their known wire fields. [LiveResponsesRawEvent] retains future
/// event types or a missing type. All variants retain the entire original frame.
sealed class LiveResponsesEvent extends LiveJsonModel {
  const LiveResponsesEvent._(this.source);

  /// Parses the complete outer `response.event` Live frame and nested event.
  factory LiveResponsesEvent.fromJson(Map<String, dynamic> json) =>
      LiveResponsesEvent.fromLiveEvent(LiveResponseEvent.fromJson(json));

  /// Dispatches an already parsed Live wrapper without consuming another tap.
  factory LiveResponsesEvent.fromLiveEvent(LiveResponseEvent source) {
    final json = source.event;
    final String? type;
    if (json.containsKey('type')) {
      type = requireLiveString(json['type'], 'LiveResponsesEvent.event.type');
    } else {
      type = null;
    }
    if (_lifecycleTypes.contains(type)) {
      if (!json.containsKey('response')) {
        throw const FormatException(
          'LiveResponsesEvent.event.response: required field',
        );
      }
      if (json.containsKey('sequence_number')) {
        requireLiveInt(
          json['sequence_number'],
          'LiveResponsesEvent.event.sequence_number',
        );
      }
      final response = LiveCompactResponse.fromJson(
        requireLiveObject(
          json['response'],
          'LiveResponsesEvent.event.response',
        ),
      );
      return LiveResponsesLifecycleEvent._(source, response);
    }
    final component = _granularComponents[type];
    if (component != null) {
      _validateResponseSchema(
        _responseSchemas[component] as Map<String, dynamic>,
        json,
        'LiveResponsesEvent.event',
      );
      if (_requiresRawResponseView(json) ||
          _hasFutureResponseBranch(
            _responseSchemas[component] as Map<String, dynamic>,
            json,
          )) {
        return LiveResponsesRawEvent._(source);
      }
      // Parsing failures remain errors; never reinterpret a malformed known
      // event as future raw data. Existing codecs are not widened for Live.
      _parseGranular(json);
      return LiveResponsesGranularEvent._(source);
    }
    return LiveResponsesRawEvent._(source);
  }

  /// The immutable original Live wrapper, including future receive metadata.
  final LiveResponseEvent source;

  /// Complete immutable nested event.
  Map<String, dynamic> get event => source.event;

  /// Nested discriminator, absent only for raw typeless data.
  String? get type => event['type'] as String?;

  /// Outer server event identifier, independent of nested Responses sequence.
  String get eventId => source.eventId;

  /// Outer Live delegation identifier, preserved rather than inferred.
  String? get delegationId => source.delegationId;

  /// Distinguishes omitted delegation correlation from explicit null.
  bool get hasDelegationId => source.hasDelegationId;

  /// Optional outer client command correlation.
  String? get clientEventId => source.clientEventId;

  /// Declared nested sequence if present; raw future events may use other fields.
  int? get sequenceNumber =>
      event['sequence_number'] is int ? event['sequence_number'] as int : null;

  /// Whether this known lifecycle event ends backend generation.
  /// It never indicates Live session or audible playback completion.
  bool get isFinal => false;

  @override
  Map<String, dynamic> toJson() => source.toJson();

  /// Replaces or clears any outer correlation and re-dispatches replaced data.
  LiveResponsesEvent copyWith({
    Object? clientEventId = liveUnset,
    bool clearClientEventId = false,
    Object? delegationId = liveUnset,
    bool clearDelegationId = false,
    Object? event = liveUnset,
    Object? eventId = liveUnset,
    Object? rawJson = liveUnset,
  }) => LiveResponsesEvent.fromLiveEvent(
    source.copyWith(
      clientEventId: clientEventId,
      clearClientEventId: clearClientEventId,
      delegationId: delegationId,
      clearDelegationId: clearDelegationId,
      event: event,
      eventId: eventId,
      rawJson: rawJson,
    ),
  );

  @override
  String toString() => 'LiveResponsesEvent(data: [REDACTED])';
}

/// A known lifecycle event with a compact, lossless snapshot view.
final class LiveResponsesLifecycleEvent extends LiveResponsesEvent {
  const LiveResponsesLifecycleEvent._(super.source, this.response) : super._();

  /// Reduced lifecycle snapshot; output/tools emptiness is not pending-call proof.
  final LiveCompactResponse response;

  @override
  bool get isFinal =>
      type == 'response.completed' ||
      type == 'response.failed' ||
      type == 'response.incomplete';
}

/// A declared granular event parsed by the existing Responses codec.
final class LiveResponsesGranularEvent extends LiveResponsesEvent {
  const LiveResponsesGranularEvent._(super.source) : super._();

  /// Detached granular view, freshly parsed so its collections cannot mutate
  /// this wrapper's authoritative immutable wire snapshot.
  ResponseStreamEvent get granularEvent => _parseGranular(event);
}

/// Complete raw view for future/typeless events or codec-incompatible children.
///
/// A known granular outer type may contain a future child or a source-valid
/// branch the ordinary codec cannot represent. Known declared fields are still
/// validated before selecting this lossless finite immutable view.
final class LiveResponsesRawEvent extends LiveResponsesEvent {
  const LiveResponsesRawEvent._(super.source) : super._();
}

/// Reduced Live lifecycle snapshot with all present known Response properties.
///
/// The Live protocol declares an open nested object, not a full Response DTO.
/// Each present known property follows its canonical value contract; no ordinary
/// Response required fields or defaults are synthesized. All future properties
/// and explicit null/absence remain lossless. Instructions/tools/output cleared
/// by the backend do not reconstruct generated content or pending tool calls.
final class LiveCompactResponse extends LiveJsonModel {
  /// Snapshots a received reduced lifecycle object and checks present fields.
  LiveCompactResponse.fromJson(Map<String, dynamic> json)
    : rawJson = snapshotLiveJson(
        json,
        'LiveCompactResponse',
        knownKeys: _snapshotFields.keys.toSet(),
      ) {
    for (final entry in rawJson.entries) {
      final schema = _snapshotFields[entry.key];
      if (schema is Map<String, dynamic>) {
        _validateResponseSchema(
          schema,
          entry.value,
          'LiveCompactResponse.${entry.key}',
        );
      }
    }
  }

  /// Complete finite immutable snapshot, including future metadata.
  final Map<String, dynamic> rawJson;

  /// Present compact snapshot `metadata` value; absence is never synthesized.
  Map<String, dynamic>? get metadata =>
      rawJson['metadata'] as Map<String, dynamic>?;

  /// Whether `metadata` was supplied, including explicit null.
  bool get hasMetadata => rawJson.containsKey('metadata');

  /// Present compact snapshot `top_logprobs` value; absence is never synthesized.
  int? get topLogprobs => rawJson['top_logprobs'] as int?;

  /// Whether `top_logprobs` was supplied, including explicit null.
  bool get hasTopLogprobs => rawJson.containsKey('top_logprobs');

  /// Present compact snapshot `temperature` value; absence is never synthesized.
  num? get temperature => rawJson['temperature'] as num?;

  /// Whether `temperature` was supplied, including explicit null.
  bool get hasTemperature => rawJson.containsKey('temperature');

  /// Present compact snapshot `top_p` value; absence is never synthesized.
  num? get topP => rawJson['top_p'] as num?;

  /// Whether `top_p` was supplied, including explicit null.
  bool get hasTopP => rawJson.containsKey('top_p');

  /// Present compact snapshot `user` value; absence is never synthesized.
  String? get user => rawJson['user'] as String?;

  /// Whether `user` was supplied, including explicit null.
  bool get hasUser => rawJson.containsKey('user');

  /// Present compact snapshot `safety_identifier` value; absence is never synthesized.
  String? get safetyIdentifier => rawJson['safety_identifier'] as String?;

  /// Whether `safety_identifier` was supplied, including explicit null.
  bool get hasSafetyIdentifier => rawJson.containsKey('safety_identifier');

  /// Present compact snapshot `prompt_cache_key` value; absence is never synthesized.
  String? get promptCacheKey => rawJson['prompt_cache_key'] as String?;

  /// Whether `prompt_cache_key` was supplied, including explicit null.
  bool get hasPromptCacheKey => rawJson.containsKey('prompt_cache_key');

  /// Present compact snapshot `prompt_cache_retention` value; absence is never synthesized.
  String? get promptCacheRetention =>
      rawJson['prompt_cache_retention'] as String?;

  /// Whether `prompt_cache_retention` was supplied, including explicit null.
  bool get hasPromptCacheRetention =>
      rawJson.containsKey('prompt_cache_retention');

  /// Present compact snapshot `previous_response_id` value; absence is never synthesized.
  String? get previousResponseId => rawJson['previous_response_id'] as String?;

  /// Whether `previous_response_id` was supplied, including explicit null.
  bool get hasPreviousResponseId => rawJson.containsKey('previous_response_id');

  /// Present compact snapshot `model` value; absence is never synthesized.
  String? get model => rawJson['model'] as String?;

  /// Whether `model` was supplied, including explicit null.
  bool get hasModel => rawJson.containsKey('model');

  /// Present compact snapshot `background` value; absence is never synthesized.
  bool? get background => rawJson['background'] as bool?;

  /// Whether `background` was supplied, including explicit null.
  bool get hasBackground => rawJson.containsKey('background');

  /// Present compact snapshot `max_tool_calls` value; absence is never synthesized.
  int? get maxToolCalls => rawJson['max_tool_calls'] as int?;

  /// Whether `max_tool_calls` was supplied, including explicit null.
  bool get hasMaxToolCalls => rawJson.containsKey('max_tool_calls');

  /// Present compact snapshot `text` value; absence is never synthesized.
  Map<String, dynamic>? get text => rawJson['text'] as Map<String, dynamic>?;

  /// Whether `text` was supplied, including explicit null.
  bool get hasText => rawJson.containsKey('text');

  /// Present compact snapshot `tools` value; absence is never synthesized.
  List<dynamic>? get tools => rawJson['tools'] as List<dynamic>?;

  /// Whether `tools` was supplied, including explicit null.
  bool get hasTools => rawJson.containsKey('tools');

  /// Present compact snapshot `tool_choice` value; absence is never synthesized.
  Object? get toolChoice => rawJson['tool_choice'] as Object?;

  /// Whether `tool_choice` was supplied, including explicit null.
  bool get hasToolChoice => rawJson.containsKey('tool_choice');

  /// Present compact snapshot `prompt` value; absence is never synthesized.
  Map<String, dynamic>? get prompt =>
      rawJson['prompt'] as Map<String, dynamic>?;

  /// Whether `prompt` was supplied, including explicit null.
  bool get hasPrompt => rawJson.containsKey('prompt');

  /// Present compact snapshot `service_tier` value; absence is never synthesized.
  String? get serviceTier => rawJson['service_tier'] as String?;

  /// Whether `service_tier` was supplied, including explicit null.
  bool get hasServiceTier => rawJson.containsKey('service_tier');

  /// Present compact snapshot `truncation` value; absence is never synthesized.
  String? get truncation => rawJson['truncation'] as String?;

  /// Whether `truncation` was supplied, including explicit null.
  bool get hasTruncation => rawJson.containsKey('truncation');

  /// Present compact snapshot `id` value; absence is never synthesized.
  String? get id => rawJson['id'] as String?;

  /// Whether `id` was supplied, including explicit null.
  bool get hasId => rawJson.containsKey('id');

  /// Present compact snapshot `object` value; absence is never synthesized.
  String? get object => rawJson['object'] as String?;

  /// Whether `object` was supplied, including explicit null.
  bool get hasObject => rawJson.containsKey('object');

  /// Present compact snapshot `status` value; absence is never synthesized.
  String? get status => rawJson['status'] as String?;

  /// Whether `status` was supplied, including explicit null.
  bool get hasStatus => rawJson.containsKey('status');

  /// Present compact snapshot `access_programs` value; absence is never synthesized.
  Map<String, dynamic>? get accessPrograms =>
      rawJson['access_programs'] as Map<String, dynamic>?;

  /// Whether `access_programs` was supplied, including explicit null.
  bool get hasAccessPrograms => rawJson.containsKey('access_programs');

  /// Present compact snapshot `created_at` value; absence is never synthesized.
  num? get createdAt => rawJson['created_at'] as num?;

  /// Whether `created_at` was supplied, including explicit null.
  bool get hasCreatedAt => rawJson.containsKey('created_at');

  /// Present compact snapshot `completed_at` value; absence is never synthesized.
  num? get completedAt => rawJson['completed_at'] as num?;

  /// Whether `completed_at` was supplied, including explicit null.
  bool get hasCompletedAt => rawJson.containsKey('completed_at');

  /// Present compact snapshot `error` value; absence is never synthesized.
  Map<String, dynamic>? get error => rawJson['error'] as Map<String, dynamic>?;

  /// Whether `error` was supplied, including explicit null.
  bool get hasError => rawJson.containsKey('error');

  /// Present compact snapshot `incomplete_details` value; absence is never synthesized.
  Map<String, dynamic>? get incompleteDetails =>
      rawJson['incomplete_details'] as Map<String, dynamic>?;

  /// Whether `incomplete_details` was supplied, including explicit null.
  bool get hasIncompleteDetails => rawJson.containsKey('incomplete_details');

  /// Present compact snapshot `output` value; absence is never synthesized.
  List<dynamic>? get output => rawJson['output'] as List<dynamic>?;

  /// Whether `output` was supplied, including explicit null.
  bool get hasOutput => rawJson.containsKey('output');

  /// Present compact snapshot `reasoning` value; absence is never synthesized.
  Map<String, dynamic>? get reasoning =>
      rawJson['reasoning'] as Map<String, dynamic>?;

  /// Whether `reasoning` was supplied, including explicit null.
  bool get hasReasoning => rawJson.containsKey('reasoning');

  /// Present compact snapshot `instructions` value; absence is never synthesized.
  Object? get instructions => rawJson['instructions'] as Object?;

  /// Whether `instructions` was supplied, including explicit null.
  bool get hasInstructions => rawJson.containsKey('instructions');

  /// Present compact snapshot `output_text` value; absence is never synthesized.
  String? get outputText => rawJson['output_text'] as String?;

  /// Whether `output_text` was supplied, including explicit null.
  bool get hasOutputText => rawJson.containsKey('output_text');

  /// Present compact snapshot `usage` value; absence is never synthesized.
  Map<String, dynamic>? get usage => rawJson['usage'] as Map<String, dynamic>?;

  /// Whether `usage` was supplied, including explicit null.
  bool get hasUsage => rawJson.containsKey('usage');

  /// Present compact snapshot `prompt_cache_options` value; absence is never synthesized.
  Map<String, dynamic>? get promptCacheOptions =>
      rawJson['prompt_cache_options'] as Map<String, dynamic>?;

  /// Whether `prompt_cache_options` was supplied, including explicit null.
  bool get hasPromptCacheOptions => rawJson.containsKey('prompt_cache_options');

  /// Present compact snapshot `prompt_cache_diagnostics` value; absence is never synthesized.
  Map<String, dynamic>? get promptCacheDiagnostics =>
      rawJson['prompt_cache_diagnostics'] as Map<String, dynamic>?;

  /// Whether `prompt_cache_diagnostics` was supplied, including explicit null.
  bool get hasPromptCacheDiagnostics =>
      rawJson.containsKey('prompt_cache_diagnostics');

  /// Present compact snapshot `moderation` value; absence is never synthesized.
  Map<String, dynamic>? get moderation =>
      rawJson['moderation'] as Map<String, dynamic>?;

  /// Whether `moderation` was supplied, including explicit null.
  bool get hasModeration => rawJson.containsKey('moderation');

  /// Present compact snapshot `parallel_tool_calls` value; absence is never synthesized.
  bool? get parallelToolCalls => rawJson['parallel_tool_calls'] as bool?;

  /// Whether `parallel_tool_calls` was supplied, including explicit null.
  bool get hasParallelToolCalls => rawJson.containsKey('parallel_tool_calls');

  /// Present compact snapshot `conversation` value; absence is never synthesized.
  Map<String, dynamic>? get conversation =>
      rawJson['conversation'] as Map<String, dynamic>?;

  /// Whether `conversation` was supplied, including explicit null.
  bool get hasConversation => rawJson.containsKey('conversation');

  /// Present compact snapshot `max_output_tokens` value; absence is never synthesized.
  int? get maxOutputTokens => rawJson['max_output_tokens'] as int?;

  /// Whether `max_output_tokens` was supplied, including explicit null.
  bool get hasMaxOutputTokens => rawJson.containsKey('max_output_tokens');

  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies every known member; clear flags omit keys and null remains explicit.
  /// Supplied rawJson replaces only future metadata while known values remain.
  LiveCompactResponse copyWith({
    Object? metadata = liveUnset,
    bool clearMetadata = false,
    Object? topLogprobs = liveUnset,
    bool clearTopLogprobs = false,
    Object? temperature = liveUnset,
    bool clearTemperature = false,
    Object? topP = liveUnset,
    bool clearTopP = false,
    Object? user = liveUnset,
    bool clearUser = false,
    Object? safetyIdentifier = liveUnset,
    bool clearSafetyIdentifier = false,
    Object? promptCacheKey = liveUnset,
    bool clearPromptCacheKey = false,
    Object? promptCacheRetention = liveUnset,
    bool clearPromptCacheRetention = false,
    Object? previousResponseId = liveUnset,
    bool clearPreviousResponseId = false,
    Object? model = liveUnset,
    bool clearModel = false,
    Object? background = liveUnset,
    bool clearBackground = false,
    Object? maxToolCalls = liveUnset,
    bool clearMaxToolCalls = false,
    Object? text = liveUnset,
    bool clearText = false,
    Object? tools = liveUnset,
    bool clearTools = false,
    Object? toolChoice = liveUnset,
    bool clearToolChoice = false,
    Object? prompt = liveUnset,
    bool clearPrompt = false,
    Object? serviceTier = liveUnset,
    bool clearServiceTier = false,
    Object? truncation = liveUnset,
    bool clearTruncation = false,
    Object? id = liveUnset,
    bool clearId = false,
    Object? object = liveUnset,
    bool clearObject = false,
    Object? status = liveUnset,
    bool clearStatus = false,
    Object? accessPrograms = liveUnset,
    bool clearAccessPrograms = false,
    Object? createdAt = liveUnset,
    bool clearCreatedAt = false,
    Object? completedAt = liveUnset,
    bool clearCompletedAt = false,
    Object? error = liveUnset,
    bool clearError = false,
    Object? incompleteDetails = liveUnset,
    bool clearIncompleteDetails = false,
    Object? output = liveUnset,
    bool clearOutput = false,
    Object? reasoning = liveUnset,
    bool clearReasoning = false,
    Object? instructions = liveUnset,
    bool clearInstructions = false,
    Object? outputText = liveUnset,
    bool clearOutputText = false,
    Object? usage = liveUnset,
    bool clearUsage = false,
    Object? promptCacheOptions = liveUnset,
    bool clearPromptCacheOptions = false,
    Object? promptCacheDiagnostics = liveUnset,
    bool clearPromptCacheDiagnostics = false,
    Object? moderation = liveUnset,
    bool clearModeration = false,
    Object? parallelToolCalls = liveUnset,
    bool clearParallelToolCalls = false,
    Object? conversation = liveUnset,
    bool clearConversation = false,
    Object? maxOutputTokens = liveUnset,
    bool clearMaxOutputTokens = false,
    Map<String, dynamic>? rawJson,
  }) {
    final result = <String, dynamic>{
      for (final entry
          in rawJson?.entries ?? const <MapEntry<String, dynamic>>[])
        if (!_snapshotFields.containsKey(entry.key)) entry.key: entry.value,
      for (final entry in this.rawJson.entries)
        if (rawJson == null || _snapshotFields.containsKey(entry.key))
          entry.key: entry.value,
      if (!identical(metadata, liveUnset)) 'metadata': metadata,
      if (!identical(topLogprobs, liveUnset)) 'top_logprobs': topLogprobs,
      if (!identical(temperature, liveUnset)) 'temperature': temperature,
      if (!identical(topP, liveUnset)) 'top_p': topP,
      if (!identical(user, liveUnset)) 'user': user,
      if (!identical(safetyIdentifier, liveUnset))
        'safety_identifier': safetyIdentifier,
      if (!identical(promptCacheKey, liveUnset))
        'prompt_cache_key': promptCacheKey,
      if (!identical(promptCacheRetention, liveUnset))
        'prompt_cache_retention': promptCacheRetention,
      if (!identical(previousResponseId, liveUnset))
        'previous_response_id': previousResponseId,
      if (!identical(model, liveUnset)) 'model': model,
      if (!identical(background, liveUnset)) 'background': background,
      if (!identical(maxToolCalls, liveUnset)) 'max_tool_calls': maxToolCalls,
      if (!identical(text, liveUnset)) 'text': text,
      if (!identical(tools, liveUnset)) 'tools': tools,
      if (!identical(toolChoice, liveUnset)) 'tool_choice': toolChoice,
      if (!identical(prompt, liveUnset)) 'prompt': prompt,
      if (!identical(serviceTier, liveUnset)) 'service_tier': serviceTier,
      if (!identical(truncation, liveUnset)) 'truncation': truncation,
      if (!identical(id, liveUnset)) 'id': id,
      if (!identical(object, liveUnset)) 'object': object,
      if (!identical(status, liveUnset)) 'status': status,
      if (!identical(accessPrograms, liveUnset))
        'access_programs': accessPrograms,
      if (!identical(createdAt, liveUnset)) 'created_at': createdAt,
      if (!identical(completedAt, liveUnset)) 'completed_at': completedAt,
      if (!identical(error, liveUnset)) 'error': error,
      if (!identical(incompleteDetails, liveUnset))
        'incomplete_details': incompleteDetails,
      if (!identical(output, liveUnset)) 'output': output,
      if (!identical(reasoning, liveUnset)) 'reasoning': reasoning,
      if (!identical(instructions, liveUnset)) 'instructions': instructions,
      if (!identical(outputText, liveUnset)) 'output_text': outputText,
      if (!identical(usage, liveUnset)) 'usage': usage,
      if (!identical(promptCacheOptions, liveUnset))
        'prompt_cache_options': promptCacheOptions,
      if (!identical(promptCacheDiagnostics, liveUnset))
        'prompt_cache_diagnostics': promptCacheDiagnostics,
      if (!identical(moderation, liveUnset)) 'moderation': moderation,
      if (!identical(parallelToolCalls, liveUnset))
        'parallel_tool_calls': parallelToolCalls,
      if (!identical(conversation, liveUnset)) 'conversation': conversation,
      if (!identical(maxOutputTokens, liveUnset))
        'max_output_tokens': maxOutputTokens,
    };
    <String>{
      if (clearMetadata) 'metadata',
      if (clearTopLogprobs) 'top_logprobs',
      if (clearTemperature) 'temperature',
      if (clearTopP) 'top_p',
      if (clearUser) 'user',
      if (clearSafetyIdentifier) 'safety_identifier',
      if (clearPromptCacheKey) 'prompt_cache_key',
      if (clearPromptCacheRetention) 'prompt_cache_retention',
      if (clearPreviousResponseId) 'previous_response_id',
      if (clearModel) 'model',
      if (clearBackground) 'background',
      if (clearMaxToolCalls) 'max_tool_calls',
      if (clearText) 'text',
      if (clearTools) 'tools',
      if (clearToolChoice) 'tool_choice',
      if (clearPrompt) 'prompt',
      if (clearServiceTier) 'service_tier',
      if (clearTruncation) 'truncation',
      if (clearId) 'id',
      if (clearObject) 'object',
      if (clearStatus) 'status',
      if (clearAccessPrograms) 'access_programs',
      if (clearCreatedAt) 'created_at',
      if (clearCompletedAt) 'completed_at',
      if (clearError) 'error',
      if (clearIncompleteDetails) 'incomplete_details',
      if (clearOutput) 'output',
      if (clearReasoning) 'reasoning',
      if (clearInstructions) 'instructions',
      if (clearOutputText) 'output_text',
      if (clearUsage) 'usage',
      if (clearPromptCacheOptions) 'prompt_cache_options',
      if (clearPromptCacheDiagnostics) 'prompt_cache_diagnostics',
      if (clearModeration) 'moderation',
      if (clearParallelToolCalls) 'parallel_tool_calls',
      if (clearConversation) 'conversation',
      if (clearMaxOutputTokens) 'max_output_tokens',
    }.forEach(result.remove);
    return LiveCompactResponse.fromJson(result);
  }

  @override
  String toString() => 'LiveCompactResponse(data: [REDACTED])';
}

ResponseStreamEvent _parseGranular(Map<String, dynamic> json) {
  try {
    return ResponseStreamEvent.fromJson(json);
  } catch (_) {
    throw const FormatException(
      'LiveResponsesEvent.event: malformed known Responses event',
    );
  }
}

void _validateResponseSchema(
  Map<String, dynamic> schema,
  Object? value,
  String context,
) {
  final ref = schema[r'$ref'];
  if (ref is String) {
    _validateResponseSchema(
      _responseSchemas[ref.split('/').last] as Map<String, dynamic>,
      value,
      context,
    );
  }
  for (final branch in schema['allOf'] as List? ?? const []) {
    _validateResponseSchema(branch as Map<String, dynamic>, value, context);
  }
  final alternatives = schema['oneOf'] ?? schema['anyOf'];
  if (alternatives is List) {
    // Unknown discriminated receive-only branches remain raw future data. A
    // recognized discriminator always selects its declared shape and never
    // hides malformed members behind a different branch or raw fallback.
    final tagged = _taggedResponseBranches(alternatives, value);
    if (tagged != null && tagged.isEmpty) return;
    FormatException? failure;
    var matches = 0;
    for (final branch in tagged ?? alternatives) {
      try {
        _validateResponseSchema(branch as Map<String, dynamic>, value, context);
        matches++;
      } on FormatException catch (error) {
        failure ??= error;
      }
    }
    if (matches == 0) {
      throw failure ?? FormatException('$context: malformed known value');
    }
  }
  final forbidden = schema['not'];
  if (forbidden is Map<String, dynamic>) {
    var matchesForbidden = false;
    try {
      _validateResponseSchema(forbidden, value, context);
      matchesForbidden = true;
    } on FormatException {
      // Values outside the forbidden shape remain valid.
    }
    if (matchesForbidden) {
      throw FormatException('$context: forbidden value shape');
    }
  }
  final type = schema['type'];
  if (type is List) {
    if (!type.any((kind) => _matchesResponseType(kind, value))) {
      throw FormatException('$context: invalid JSON kind');
    }
  } else if (type is String && !_matchesResponseType(type, value)) {
    throw FormatException('$context: expected $type');
  }
  if (schema.containsKey('const') && schema['const'] != value) {
    throw FormatException('$context: unexpected constant');
  }
  final allowed = schema['enum'];
  if (allowed is List && !allowed.contains(value)) {
    throw FormatException('$context: unsupported known value');
  }
  if (value is String) {
    final count = value.runes.length;
    if ((schema['minLength'] is int && count < (schema['minLength'] as int)) ||
        (schema['maxLength'] is int && count > (schema['maxLength'] as int))) {
      throw FormatException('$context: invalid string length');
    }
    final pattern = schema['pattern'];
    if (pattern is String && !RegExp(pattern).hasMatch(value)) {
      throw FormatException('$context: invalid string shape');
    }
  }
  if (value is num) {
    if (!value.isFinite ||
        (schema['minimum'] is num && value < (schema['minimum'] as num)) ||
        (schema['maximum'] is num && value > (schema['maximum'] as num))) {
      throw FormatException('$context: invalid numeric value');
    }
  }
  if (value is List) {
    if ((schema['minItems'] is int &&
            value.length < (schema['minItems'] as int)) ||
        (schema['maxItems'] is int &&
            value.length > (schema['maxItems'] as int))) {
      throw FormatException('$context: invalid item count');
    }
    final items = schema['items'];
    if (items is Map<String, dynamic>) {
      for (var index = 0; index < value.length; index++) {
        _validateResponseSchema(items, value[index], '$context[$index]');
      }
    }
  }
  if (value is Map<String, dynamic>) {
    final properties =
        schema['properties'] as Map<String, dynamic>? ?? const {};
    for (final key in schema['required'] as List? ?? const []) {
      if (!value.containsKey(key)) {
        throw FormatException('$context.$key: required field');
      }
    }
    if ((schema['minProperties'] is int &&
            value.length < (schema['minProperties'] as int)) ||
        (schema['maxProperties'] is int &&
            value.length > (schema['maxProperties'] as int))) {
      throw FormatException('$context: invalid property count');
    }
    for (final entry in value.entries) {
      final child = properties[entry.key];
      if (child is Map<String, dynamic>) {
        _validateResponseSchema(child, entry.value, '$context.${entry.key}');
      } else {
        // Future receive-only metadata is deliberately open even if a writable
        // sibling declares a closed object. Typed map values remain validated.
        final additional = schema['additionalProperties'];
        if (additional is Map<String, dynamic>) {
          _validateResponseSchema(additional, entry.value, '$context member');
        }
      }
      final names = schema['propertyNames'];
      if (names is Map<String, dynamic>) {
        _validateResponseSchema(names, entry.key, '$context member name');
      }
    }
  }
}

bool _requiresRawResponseView(Map<String, dynamic> event) {
  if (event['type'] != 'response.output_item.added' &&
      event['type'] != 'response.output_item.done') {
    return false;
  }
  final item = event['item'];
  if (item is! Map<String, dynamic>) return false;
  // Explicit ordinary-codec admission, checked before parser invocation.
  // Known source branches without an ordinary codec remain complete raw views.
  if (!_ordinaryOutputItemTypes.contains(item['type']) ||
      item['id'] is! String) {
    return true;
  }
  if (item['type'] == 'mcp_call') {
    // The ordinary codec requires call_id and represents error as a string;
    // canonical MCP output allows no call_id and a structured execution error.
    return item['call_id'] is! String ||
        (item['error'] != null && item['error'] is! String);
  }
  return false;
}

bool _hasFutureResponseBranch(Map<String, dynamic> schema, Object? value) {
  final ref = schema[r'$ref'];
  if (ref is String &&
      _hasFutureResponseBranch(
        _responseSchemas[ref.split('/').last] as Map<String, dynamic>,
        value,
      )) {
    return true;
  }
  for (final branch in schema['allOf'] as List? ?? const []) {
    if (_hasFutureResponseBranch(branch as Map<String, dynamic>, value)) {
      return true;
    }
  }
  final alternatives = schema['oneOf'] ?? schema['anyOf'];
  if (alternatives is List) {
    final tagged = _taggedResponseBranches(alternatives, value);
    if (tagged != null && tagged.isEmpty) return true;
    for (final branch in tagged ?? alternatives) {
      final shape = branch as Map<String, dynamic>;
      try {
        _validateResponseSchema(shape, value, 'LiveResponsesEvent.event');
      } on FormatException {
        continue;
      }
      if (_hasFutureResponseBranch(shape, value)) return true;
    }
  }
  if (value is Map<String, dynamic>) {
    final properties = schema['properties'];
    if (properties is Map<String, dynamic>) {
      for (final entry in value.entries) {
        final shape = properties[entry.key];
        if (shape is Map<String, dynamic> &&
            _hasFutureResponseBranch(shape, entry.value)) {
          return true;
        }
      }
    }
  }
  if (value is List && schema['items'] is Map<String, dynamic>) {
    for (final item in value) {
      if (_hasFutureResponseBranch(
        schema['items'] as Map<String, dynamic>,
        item,
      )) {
        return true;
      }
    }
  }
  return false;
}

bool _matchesResponseType(Object? type, Object? value) => switch (type) {
  'null' => value == null,
  'string' => value is String,
  'number' => value is num && value.isFinite,
  'integer' => value is int && value.isFinite,
  'boolean' => value is bool,
  'array' => value is List,
  'object' => value is Map<String, dynamic>,
  _ => true,
};

List<dynamic>? _taggedResponseBranches(List<dynamic> branches, Object? value) {
  if (value is! Map<String, dynamic> || value['type'] is! String) return null;
  final tagged = <dynamic>[];
  var allTagged = true;
  for (final branch in branches) {
    final shape = _responseObjectShape(branch as Map<String, dynamic>);
    if (shape['type'] == 'null') continue;
    final properties = shape['properties'];
    final discriminator = properties is Map ? properties['type'] : null;
    final choices = discriminator is Map ? discriminator['enum'] : null;
    if (choices is! List ||
        !(shape['required'] as List? ?? const []).contains('type')) {
      allTagged = false;
      break;
    }
    if (choices.contains(value['type'])) tagged.add(branch);
  }
  return allTagged ? tagged : null;
}

Map<String, dynamic> _responseObjectShape(Map<String, dynamic> schema) {
  final result = <String, dynamic>{};
  final properties = <String, dynamic>{};
  final required = <dynamic>[];
  void merge(Map<String, dynamic> shape) {
    final ref = shape[r'$ref'];
    if (ref is String) {
      merge(_responseSchemas[ref.split('/').last] as Map<String, dynamic>);
    }
    for (final branch in shape['allOf'] as List? ?? const []) {
      merge(branch as Map<String, dynamic>);
    }
    if (shape['type'] != null) result['type'] = shape['type'];
    final members = shape['properties'];
    if (members is Map<String, dynamic>) properties.addAll(members);
    required.addAll(shape['required'] as List? ?? const []);
  }

  merge(schema);
  return {...result, 'properties': properties, 'required': required};
}

const Set<String> _lifecycleTypes = {
  'response.completed',
  'response.created',
  'response.failed',
  'response.in_progress',
  'response.incomplete',
  'response.queued',
};

const Map<String, String> _granularComponents = {
  'response.output_item.added': 'ResponseOutputItemAddedEvent',
  'response.output_item.done': 'ResponseOutputItemDoneEvent',
  'response.content_part.added': 'ResponseContentPartAddedEvent',
  'response.content_part.done': 'ResponseContentPartDoneEvent',
  'response.output_text.delta': 'ResponseTextDeltaEvent',
  'response.output_text.done': 'ResponseTextDoneEvent',
  'response.output_text.annotation.added':
      'ResponseOutputTextAnnotationAddedEvent',
  'response.refusal.delta': 'ResponseRefusalDeltaEvent',
  'response.refusal.done': 'ResponseRefusalDoneEvent',
  'response.function_call_arguments.delta':
      'ResponseFunctionCallArgumentsDeltaEvent',
  'response.function_call_arguments.done':
      'ResponseFunctionCallArgumentsDoneEvent',
  'response.reasoning_text.delta': 'ResponseReasoningTextDeltaEvent',
  'response.reasoning_text.done': 'ResponseReasoningTextDoneEvent',
  'response.reasoning_summary_part.added':
      'ResponseReasoningSummaryPartAddedEvent',
  'response.reasoning_summary_part.done':
      'ResponseReasoningSummaryPartDoneEvent',
  'response.reasoning_summary_text.delta':
      'ResponseReasoningSummaryTextDeltaEvent',
  'response.reasoning_summary_text.done':
      'ResponseReasoningSummaryTextDoneEvent',
  'response.compaction.compacting':
      'ResponseCompactionCompactingStreamingEvent',
  'response.audio.delta': 'ResponseAudioDeltaEvent',
  'response.audio.done': 'ResponseAudioDoneEvent',
  'response.audio.transcript.delta': 'ResponseAudioTranscriptDeltaEvent',
  'response.audio.transcript.done': 'ResponseAudioTranscriptDoneEvent',
  'response.web_search_call.in_progress':
      'ResponseWebSearchCallInProgressEvent',
  'response.web_search_call.searching': 'ResponseWebSearchCallSearchingEvent',
  'response.web_search_call.completed': 'ResponseWebSearchCallCompletedEvent',
  'response.file_search_call.in_progress':
      'ResponseFileSearchCallInProgressEvent',
  'response.file_search_call.searching': 'ResponseFileSearchCallSearchingEvent',
  'response.file_search_call.completed': 'ResponseFileSearchCallCompletedEvent',
  'response.code_interpreter_call.in_progress':
      'ResponseCodeInterpreterCallInProgressEvent',
  'response.code_interpreter_call.interpreting':
      'ResponseCodeInterpreterCallInterpretingEvent',
  'response.code_interpreter_call_code.delta':
      'ResponseCodeInterpreterCallCodeDeltaEvent',
  'response.code_interpreter_call_code.done':
      'ResponseCodeInterpreterCallCodeDoneEvent',
  'response.code_interpreter_call.completed':
      'ResponseCodeInterpreterCallCompletedEvent',
  'response.shell_call_command.added':
      'ResponseShellCallCommandAddedStreamingEvent',
  'response.shell_call_command.delta':
      'ResponseShellCallCommandDeltaStreamingEvent',
  'response.shell_call_command.done':
      'ResponseShellCallCommandDoneStreamingEvent',
  'response.shell_call_output_content.delta':
      'ResponseShellCallOutputContentDeltaStreamingEvent',
  'response.shell_call_output_content.done':
      'ResponseShellCallOutputContentDoneStreamingEvent',
  'response.image_generation_call.in_progress':
      'ResponseImageGenCallInProgressEvent',
  'response.image_generation_call.generating':
      'ResponseImageGenCallGeneratingEvent',
  'response.image_generation_call.partial_image':
      'ResponseImageGenCallPartialImageEvent',
  'response.image_generation_call.completed':
      'ResponseImageGenCallCompletedEvent',
  'response.mcp_call.in_progress': 'ResponseMCPCallInProgressEvent',
  'response.mcp_call.completed': 'ResponseMCPCallCompletedEvent',
  'response.mcp_call.failed': 'ResponseMCPCallFailedEvent',
  'response.mcp_call_arguments.delta': 'ResponseMCPCallArgumentsDeltaEvent',
  'response.mcp_call_arguments.done': 'ResponseMCPCallArgumentsDoneEvent',
  'response.mcp_list_tools.in_progress': 'ResponseMCPListToolsInProgressEvent',
  'response.mcp_list_tools.completed': 'ResponseMCPListToolsCompletedEvent',
  'response.mcp_list_tools.failed': 'ResponseMCPListToolsFailedEvent',
  'response.custom_tool_call_input.delta':
      'ResponseCustomToolCallInputDeltaEvent',
  'response.custom_tool_call_input.done':
      'ResponseCustomToolCallInputDoneEvent',
  'error': 'ResponseErrorEvent',
};

// Structural source projections from immutable OpenAPI 0ef225c4; annotations
// remain in the authoritative spec. No runtime schema fetch or checker policy.
const Map<String, dynamic> _snapshotFields = {
  'metadata': {r'$ref': '#/components/schemas/Metadata'},
  'top_logprobs': {
    'anyOf': [
      {'type': 'integer', 'minimum': 0, 'maximum': 20},
      {'type': 'null'},
    ],
  },
  'temperature': {
    'anyOf': [
      {'type': 'number', 'minimum': 0, 'maximum': 2},
      {'type': 'null'},
    ],
  },
  'top_p': {
    'anyOf': [
      {'type': 'number', 'minimum': 0, 'maximum': 1},
      {'type': 'null'},
    ],
  },
  'user': {
    'type': ['string', 'null'],
  },
  'safety_identifier': {
    'anyOf': [
      {'type': 'string', 'maxLength': 128},
      {'type': 'null'},
    ],
  },
  'prompt_cache_key': {
    'anyOf': [
      {'type': 'string'},
      {'type': 'null'},
    ],
  },
  'prompt_cache_retention': {
    'anyOf': [
      {
        'type': 'string',
        'enum': ['in_memory', '24h'],
      },
      {'type': 'null'},
    ],
  },
  'previous_response_id': {
    'anyOf': [
      {'type': 'string'},
      {'type': 'null'},
    ],
  },
  'model': {r'$ref': '#/components/schemas/ModelIdsResponses'},
  'background': {
    'anyOf': [
      {'type': 'boolean'},
      {'type': 'null'},
    ],
  },
  'max_tool_calls': {
    'anyOf': [
      {'type': 'integer'},
      {'type': 'null'},
    ],
  },
  'text': {r'$ref': '#/components/schemas/ResponseTextParam'},
  'tools': {r'$ref': '#/components/schemas/ToolsArray'},
  'tool_choice': {r'$ref': '#/components/schemas/ToolChoiceParam'},
  'prompt': {r'$ref': '#/components/schemas/Prompt'},
  'service_tier': {r'$ref': '#/components/schemas/ServiceTierResponses'},
  'truncation': {
    'anyOf': [
      {
        'type': 'string',
        'enum': ['auto', 'disabled'],
      },
      {'type': 'null'},
    ],
  },
  'id': {'type': 'string'},
  'object': {
    'type': 'string',
    'enum': ['response'],
  },
  'status': {
    'type': 'string',
    'enum': [
      'completed',
      'failed',
      'in_progress',
      'cancelled',
      'queued',
      'incomplete',
    ],
  },
  'access_programs': {
    'anyOf': [
      {r'$ref': '#/components/schemas/AccessProgramsBody'},
      {'type': 'null'},
    ],
  },
  'created_at': {'type': 'number'},
  'completed_at': {
    'anyOf': [
      {'type': 'number'},
      {'type': 'null'},
    ],
  },
  'error': {r'$ref': '#/components/schemas/ResponseError'},
  'incomplete_details': {
    'anyOf': [
      {
        'type': 'object',
        'properties': {
          'reason': {
            'type': 'string',
            'enum': [
              'max_output_tokens',
              'max_messages',
              'content_filter',
              'steered',
            ],
          },
        },
      },
      {'type': 'null'},
    ],
  },
  'output': {
    'type': 'array',
    'items': {r'$ref': '#/components/schemas/OutputItem'},
  },
  'reasoning': {
    'anyOf': [
      {r'$ref': '#/components/schemas/Reasoning'},
      {'type': 'null'},
    ],
  },
  'instructions': {
    'anyOf': [
      {
        'oneOf': [
          {'type': 'string'},
          {
            'type': 'array',
            'items': {r'$ref': '#/components/schemas/InputItem'},
          },
        ],
      },
      {'type': 'null'},
    ],
  },
  'output_text': {
    'anyOf': [
      {'type': 'string'},
      {'type': 'null'},
    ],
  },
  'usage': {
    'anyOf': [
      {r'$ref': '#/components/schemas/ResponseUsage'},
      {'type': 'null'},
    ],
  },
  'prompt_cache_options': {r'$ref': '#/components/schemas/PromptCacheOptions'},
  'prompt_cache_diagnostics': {
    r'$ref': '#/components/schemas/PromptCacheDiagnostics',
  },
  'moderation': {
    'anyOf': [
      {r'$ref': '#/components/schemas/Moderation'},
      {'type': 'null'},
    ],
  },
  'parallel_tool_calls': {'type': 'boolean'},
  'conversation': {
    'anyOf': [
      {r'$ref': '#/components/schemas/ResponseConversation'},
      {'type': 'null'},
    ],
  },
  'max_output_tokens': {
    'anyOf': [
      {'type': 'integer'},
      {'type': 'null'},
    ],
  },
};

const Map<String, dynamic> _responseSchemas = {
  'AccessProgramsBody': {
    'properties': {
      'cyber': {r'$ref': '#/components/schemas/CyberAccessProgramEnum'},
    },
    'type': 'object',
    'required': ['cyber'],
  },
  'AdditionalTools': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['additional_tools'],
      },
      'id': {'type': 'string'},
      'role': {r'$ref': '#/components/schemas/MessageRole'},
      'tools': {
        'items': {r'$ref': '#/components/schemas/Tool'},
        'type': 'array',
      },
    },
    'type': 'object',
    'required': ['type', 'id', 'role', 'tools'],
  },
  'AdditionalToolsItemParam': {
    'properties': {
      'id': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'type': {
        'type': 'string',
        'enum': ['additional_tools'],
      },
      'role': {
        'type': 'string',
        'enum': ['developer'],
      },
      'tools': {
        'items': {r'$ref': '#/components/schemas/Tool'},
        'type': 'array',
      },
    },
    'type': 'object',
    'required': ['type', 'role', 'tools'],
  },
  'Annotation': {
    'oneOf': [
      {r'$ref': '#/components/schemas/FileCitationBody'},
      {r'$ref': '#/components/schemas/UrlCitationBody'},
      {r'$ref': '#/components/schemas/ContainerFileCitationBody'},
      {r'$ref': '#/components/schemas/FilePath'},
    ],
  },
  'ApplyPatchCallOutputStatus': {
    'type': 'string',
    'enum': ['completed', 'failed'],
  },
  'ApplyPatchCallOutputStatusParam': {
    'type': 'string',
    'enum': ['completed', 'failed'],
  },
  'ApplyPatchCallStatus': {
    'type': 'string',
    'enum': ['in_progress', 'completed'],
  },
  'ApplyPatchCallStatusParam': {
    'type': 'string',
    'enum': ['in_progress', 'completed'],
  },
  'ApplyPatchCreateFileOperation': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['create_file'],
      },
      'path': {'type': 'string'},
      'diff': {'type': 'string'},
    },
    'type': 'object',
    'required': ['type', 'path', 'diff'],
  },
  'ApplyPatchCreateFileOperationParam': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['create_file'],
      },
      'path': {'type': 'string', 'minLength': 1},
      'diff': {'type': 'string', 'maxLength': 10485760},
    },
    'type': 'object',
    'required': ['type', 'path', 'diff'],
  },
  'ApplyPatchDeleteFileOperation': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['delete_file'],
      },
      'path': {'type': 'string'},
    },
    'type': 'object',
    'required': ['type', 'path'],
  },
  'ApplyPatchDeleteFileOperationParam': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['delete_file'],
      },
      'path': {'type': 'string', 'minLength': 1},
    },
    'type': 'object',
    'required': ['type', 'path'],
  },
  'ApplyPatchOperationParam': {
    'oneOf': [
      {r'$ref': '#/components/schemas/ApplyPatchCreateFileOperationParam'},
      {r'$ref': '#/components/schemas/ApplyPatchDeleteFileOperationParam'},
      {r'$ref': '#/components/schemas/ApplyPatchUpdateFileOperationParam'},
    ],
  },
  'ApplyPatchToolCall': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['apply_patch_call'],
      },
      'id': {'type': 'string'},
      'call_id': {'type': 'string'},
      'caller': {
        'anyOf': [
          {r'$ref': '#/components/schemas/ToolCallCaller'},
          {'type': 'null'},
        ],
      },
      'status': {r'$ref': '#/components/schemas/ApplyPatchCallStatus'},
      'operation': {
        'oneOf': [
          {r'$ref': '#/components/schemas/ApplyPatchCreateFileOperation'},
          {r'$ref': '#/components/schemas/ApplyPatchDeleteFileOperation'},
          {r'$ref': '#/components/schemas/ApplyPatchUpdateFileOperation'},
        ],
      },
      'created_by': {'type': 'string'},
    },
    'type': 'object',
    'required': ['type', 'id', 'call_id', 'status', 'operation'],
  },
  'ApplyPatchToolCallItemParam': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['apply_patch_call'],
      },
      'id': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'call_id': {'type': 'string', 'maxLength': 64, 'minLength': 1},
      'caller': {
        'anyOf': [
          {r'$ref': '#/components/schemas/ToolCallCallerParam'},
          {'type': 'null'},
        ],
      },
      'status': {r'$ref': '#/components/schemas/ApplyPatchCallStatusParam'},
      'operation': {r'$ref': '#/components/schemas/ApplyPatchOperationParam'},
    },
    'type': 'object',
    'required': ['type', 'call_id', 'status', 'operation'],
  },
  'ApplyPatchToolCallOutput': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['apply_patch_call_output'],
      },
      'id': {'type': 'string'},
      'call_id': {'type': 'string'},
      'caller': {
        'anyOf': [
          {r'$ref': '#/components/schemas/ToolCallCaller'},
          {'type': 'null'},
        ],
      },
      'status': {r'$ref': '#/components/schemas/ApplyPatchCallOutputStatus'},
      'output': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'created_by': {'type': 'string'},
    },
    'type': 'object',
    'required': ['type', 'id', 'call_id', 'status'],
  },
  'ApplyPatchToolCallOutputItemParam': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['apply_patch_call_output'],
      },
      'id': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'call_id': {'type': 'string', 'maxLength': 64, 'minLength': 1},
      'caller': {
        'anyOf': [
          {r'$ref': '#/components/schemas/ToolCallCallerParam'},
          {'type': 'null'},
        ],
      },
      'status': {
        r'$ref': '#/components/schemas/ApplyPatchCallOutputStatusParam',
      },
      'output': {
        'anyOf': [
          {'type': 'string', 'maxLength': 10485760},
          {'type': 'null'},
        ],
      },
    },
    'type': 'object',
    'required': ['type', 'call_id', 'status'],
  },
  'ApplyPatchToolParam': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['apply_patch'],
      },
      'allowed_callers': {
        'anyOf': [
          {
            'items': {
              r'$ref': '#/components/schemas/CallableToolAllowedCaller',
            },
            'type': 'array',
            'minItems': 1,
          },
          {'type': 'null'},
        ],
      },
    },
    'type': 'object',
    'required': ['type'],
  },
  'ApplyPatchUpdateFileOperation': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['update_file'],
      },
      'path': {'type': 'string'},
      'diff': {'type': 'string'},
    },
    'type': 'object',
    'required': ['type', 'path', 'diff'],
  },
  'ApplyPatchUpdateFileOperationParam': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['update_file'],
      },
      'path': {'type': 'string', 'minLength': 1},
      'diff': {'type': 'string', 'maxLength': 10485760},
    },
    'type': 'object',
    'required': ['type', 'path', 'diff'],
  },
  'ApproximateLocation': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['approximate'],
      },
      'country': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'region': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'city': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'timezone': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
    },
    'type': 'object',
    'required': ['type'],
  },
  'AutoCodeInterpreterToolParam': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['auto'],
      },
      'file_ids': {
        'items': {'type': 'string'},
        'type': 'array',
        'maxItems': 50,
      },
      'memory_limit': {
        'anyOf': [
          {r'$ref': '#/components/schemas/ContainerMemoryLimit'},
          {'type': 'null'},
        ],
      },
      'network_policy': {
        'oneOf': [
          {r'$ref': '#/components/schemas/ContainerNetworkPolicyDisabledParam'},
          {
            r'$ref':
                '#/components/schemas/ContainerNetworkPolicyAllowlistParam',
          },
        ],
      },
    },
    'type': 'object',
    'required': ['type'],
  },
  'CacheMissReasonTypeEnum': {
    'type': 'string',
    'enum': [
      'model_changed',
      'prompt_cache_key_changed',
      'tools_changed',
      'text_format_changed',
      'reasoning_effort_changed',
      'verbosity_changed',
      'context_compacted',
      'input_changed',
      'service_tier_changed',
    ],
  },
  'CallableToolAllowedCaller': {
    'type': 'string',
    'enum': ['direct', 'programmatic'],
  },
  'ClickButtonType': {
    'type': 'string',
    'enum': ['left', 'right', 'wheel', 'back', 'forward'],
  },
  'ClickParam': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['click'],
      },
      'button': {r'$ref': '#/components/schemas/ClickButtonType'},
      'x': {'type': 'integer'},
      'y': {'type': 'integer'},
      'keys': {
        'anyOf': [
          {
            'items': {'type': 'string'},
            'type': 'array',
          },
          {'type': 'null'},
        ],
      },
    },
    'type': 'object',
    'required': ['type', 'button', 'x', 'y'],
  },
  'CodeInterpreterOutputImage': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['image'],
      },
      'url': {'type': 'string'},
    },
    'type': 'object',
    'required': ['type', 'url'],
  },
  'CodeInterpreterOutputLogs': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['logs'],
      },
      'logs': {'type': 'string'},
    },
    'type': 'object',
    'required': ['type', 'logs'],
  },
  'CodeInterpreterTool': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['code_interpreter'],
      },
      'container': {
        'oneOf': [
          {'type': 'string'},
          {r'$ref': '#/components/schemas/AutoCodeInterpreterToolParam'},
        ],
      },
      'allowed_callers': {
        'anyOf': [
          {
            'type': 'array',
            'minItems': 1,
            'items': {
              r'$ref': '#/components/schemas/CallableToolAllowedCaller',
            },
          },
          {'type': 'null'},
        ],
      },
    },
    'required': ['type', 'container'],
  },
  'CodeInterpreterToolCall': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['code_interpreter_call'],
      },
      'id': {'type': 'string'},
      'status': {
        'type': 'string',
        'enum': [
          'in_progress',
          'completed',
          'incomplete',
          'interpreting',
          'failed',
        ],
      },
      'container_id': {'type': 'string'},
      'code': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'outputs': {
        'anyOf': [
          {
            'type': 'array',
            'items': {
              'oneOf': [
                {r'$ref': '#/components/schemas/CodeInterpreterOutputLogs'},
                {r'$ref': '#/components/schemas/CodeInterpreterOutputImage'},
              ],
            },
          },
          {'type': 'null'},
        ],
      },
    },
    'required': ['type', 'id', 'status', 'container_id', 'code', 'outputs'],
  },
  'CompactionBody': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['compaction'],
      },
      'id': {'type': 'string'},
      'encrypted_content': {'type': 'string'},
      'created_by': {'type': 'string'},
    },
    'type': 'object',
    'required': ['type', 'id', 'encrypted_content'],
  },
  'CompactionSummaryItemParam': {
    'properties': {
      'id': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'type': {
        'type': 'string',
        'enum': ['compaction'],
      },
      'encrypted_content': {'type': 'string', 'maxLength': 104857600},
    },
    'type': 'object',
    'required': ['type', 'encrypted_content'],
  },
  'CompactionTriggerItemParam': {
    'properties': {
      'id': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'type': {
        'type': 'string',
        'enum': ['compaction_trigger'],
      },
    },
    'type': 'object',
    'required': ['type'],
  },
  'ComparisonFilter': {
    'type': 'object',
    'additionalProperties': false,
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['eq', 'ne', 'gt', 'gte', 'lt', 'lte', 'in', 'nin'],
      },
      'key': {'type': 'string'},
      'value': {
        'oneOf': [
          {'type': 'string'},
          {'type': 'number'},
          {'type': 'boolean'},
          {
            'type': 'array',
            'items': {
              'oneOf': [
                {'type': 'string'},
                {'type': 'number'},
              ],
            },
          },
        ],
      },
    },
    'required': ['type', 'key', 'value'],
  },
  'CompoundFilter': {
    'type': 'object',
    'additionalProperties': false,
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['and', 'or'],
      },
      'filters': {
        'type': 'array',
        'items': {
          'oneOf': [
            {r'$ref': '#/components/schemas/ComparisonFilter'},
            {r'$ref': '#/components/schemas/CompoundFilter'},
          ],
        },
      },
    },
    'required': ['type', 'filters'],
  },
  'ComputerAction': {
    'oneOf': [
      {r'$ref': '#/components/schemas/ClickParam'},
      {r'$ref': '#/components/schemas/DoubleClickAction'},
      {r'$ref': '#/components/schemas/DragParam'},
      {r'$ref': '#/components/schemas/KeyPressAction'},
      {r'$ref': '#/components/schemas/MoveParam'},
      {r'$ref': '#/components/schemas/ScreenshotParam'},
      {r'$ref': '#/components/schemas/ScrollParam'},
      {r'$ref': '#/components/schemas/TypeParam'},
      {r'$ref': '#/components/schemas/WaitParam'},
    ],
  },
  'ComputerActionList': {
    'type': 'array',
    'items': {r'$ref': '#/components/schemas/ComputerAction'},
  },
  'ComputerCallOutputItemParam': {
    'properties': {
      'id': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'call_id': {'type': 'string', 'maxLength': 64, 'minLength': 1},
      'type': {
        'type': 'string',
        'enum': ['computer_call_output'],
      },
      'output': {r'$ref': '#/components/schemas/ComputerScreenshotImage'},
      'acknowledged_safety_checks': {
        'anyOf': [
          {
            'items': {
              r'$ref': '#/components/schemas/ComputerCallSafetyCheckParam',
            },
            'type': 'array',
          },
          {'type': 'null'},
        ],
      },
      'status': {
        'anyOf': [
          {r'$ref': '#/components/schemas/FunctionCallItemStatus'},
          {'type': 'null'},
        ],
      },
    },
    'type': 'object',
    'required': ['call_id', 'type', 'output'],
  },
  'ComputerCallOutputStatus': {
    'type': 'string',
    'enum': ['completed', 'incomplete', 'failed'],
  },
  'ComputerCallSafetyCheckParam': {
    'properties': {
      'id': {'type': 'string'},
      'code': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'message': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
    },
    'type': 'object',
    'required': ['id'],
  },
  'ComputerEnvironment': {
    'type': 'string',
    'enum': ['windows', 'mac', 'linux', 'ubuntu', 'browser'],
  },
  'ComputerScreenshotImage': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['computer_screenshot'],
      },
      'image_url': {'type': 'string'},
      'file_id': {'type': 'string'},
    },
    'required': ['type'],
  },
  'ComputerTool': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['computer'],
      },
    },
    'type': 'object',
    'required': ['type'],
  },
  'ComputerToolCall': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['computer_call'],
      },
      'id': {'type': 'string'},
      'call_id': {'type': 'string'},
      'action': {r'$ref': '#/components/schemas/ComputerAction'},
      'actions': {r'$ref': '#/components/schemas/ComputerActionList'},
      'pending_safety_checks': {
        'type': 'array',
        'items': {r'$ref': '#/components/schemas/ComputerCallSafetyCheckParam'},
      },
      'status': {
        'type': 'string',
        'enum': ['in_progress', 'completed', 'incomplete'],
      },
    },
    'required': ['type', 'id', 'call_id', 'pending_safety_checks', 'status'],
  },
  'ComputerToolCallOutput': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['computer_call_output'],
      },
      'id': {'type': 'string'},
      'call_id': {'type': 'string'},
      'acknowledged_safety_checks': {
        'type': 'array',
        'items': {r'$ref': '#/components/schemas/ComputerCallSafetyCheckParam'},
      },
      'output': {r'$ref': '#/components/schemas/ComputerScreenshotImage'},
      'status': {
        'type': 'string',
        'enum': ['in_progress', 'completed', 'incomplete'],
      },
    },
    'required': ['type', 'call_id', 'output'],
  },
  'ComputerToolCallOutputResource': {
    'allOf': [
      {r'$ref': '#/components/schemas/ComputerToolCallOutput'},
      {
        'type': 'object',
        'properties': {
          'status': {r'$ref': '#/components/schemas/ComputerCallOutputStatus'},
          'created_by': {'type': 'string'},
        },
        'required': ['id', 'status'],
      },
    ],
  },
  'ComputerUsePreviewTool': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['computer_use_preview'],
      },
      'environment': {r'$ref': '#/components/schemas/ComputerEnvironment'},
      'display_width': {'type': 'integer'},
      'display_height': {'type': 'integer'},
    },
    'type': 'object',
    'required': ['type', 'environment', 'display_width', 'display_height'],
  },
  'ContainerAutoParam': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['container_auto'],
      },
      'file_ids': {
        'items': {'type': 'string'},
        'type': 'array',
        'maxItems': 50,
      },
      'memory_limit': {
        'anyOf': [
          {r'$ref': '#/components/schemas/ContainerMemoryLimit'},
          {'type': 'null'},
        ],
      },
      'network_policy': {
        'oneOf': [
          {r'$ref': '#/components/schemas/ContainerNetworkPolicyDisabledParam'},
          {
            r'$ref':
                '#/components/schemas/ContainerNetworkPolicyAllowlistParam',
          },
        ],
      },
      'skills': {
        'items': {
          'oneOf': [
            {r'$ref': '#/components/schemas/SkillReferenceParam'},
            {r'$ref': '#/components/schemas/InlineSkillParam'},
          ],
        },
        'type': 'array',
        'maxItems': 200,
      },
    },
    'type': 'object',
    'required': ['type'],
  },
  'ContainerFileCitationBody': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['container_file_citation'],
      },
      'container_id': {'type': 'string'},
      'file_id': {'type': 'string'},
      'start_index': {'type': 'integer'},
      'end_index': {'type': 'integer'},
      'filename': {'type': 'string'},
    },
    'type': 'object',
    'required': [
      'type',
      'container_id',
      'file_id',
      'start_index',
      'end_index',
      'filename',
    ],
  },
  'ContainerMemoryLimit': {
    'type': 'string',
    'enum': ['1g', '4g', '16g', '64g'],
  },
  'ContainerNetworkPolicyAllowlistParam': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['allowlist'],
      },
      'allowed_domains': {
        'items': {'type': 'string'},
        'type': 'array',
        'minItems': 1,
      },
      'domain_secrets': {
        'items': {
          r'$ref':
              '#/components/schemas/ContainerNetworkPolicyDomainSecretParam',
        },
        'type': 'array',
        'minItems': 1,
      },
    },
    'type': 'object',
    'required': ['type', 'allowed_domains'],
  },
  'ContainerNetworkPolicyDisabledParam': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['disabled'],
      },
    },
    'type': 'object',
    'required': ['type'],
  },
  'ContainerNetworkPolicyDomainSecretParam': {
    'properties': {
      'domain': {'type': 'string', 'minLength': 1},
      'name': {'type': 'string', 'minLength': 1},
      'value': {'type': 'string', 'maxLength': 10485760, 'minLength': 1},
    },
    'type': 'object',
    'required': ['domain', 'name', 'value'],
  },
  'ContainerReferenceParam': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['container_reference'],
      },
      'container_id': {'type': 'string'},
    },
    'type': 'object',
    'required': ['type', 'container_id'],
  },
  'ContainerReferenceResource': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['container_reference'],
      },
      'container_id': {'type': 'string'},
    },
    'type': 'object',
    'required': ['type', 'container_id'],
  },
  'CoordParam': {
    'properties': {
      'x': {'type': 'integer'},
      'y': {'type': 'integer'},
    },
    'type': 'object',
    'required': ['x', 'y'],
  },
  'CustomGrammarFormatParam': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['grammar'],
      },
      'syntax': {r'$ref': '#/components/schemas/GrammarSyntax1'},
      'definition': {'type': 'string'},
    },
    'type': 'object',
    'required': ['type', 'syntax', 'definition'],
  },
  'CustomTextFormatParam': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['text'],
      },
    },
    'type': 'object',
    'required': ['type'],
  },
  'CustomToolCall': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['custom_tool_call'],
      },
      'id': {'type': 'string'},
      'call_id': {'type': 'string'},
      'caller': {
        'anyOf': [
          {r'$ref': '#/components/schemas/ToolCallCaller'},
          {'type': 'null'},
        ],
      },
      'namespace': {'type': 'string'},
      'name': {'type': 'string'},
      'input': {'type': 'string'},
      'async': {'type': 'boolean'},
    },
    'required': ['type', 'call_id', 'name', 'input'],
  },
  'CustomToolCallOutput': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['custom_tool_call_output'],
      },
      'id': {'type': 'string'},
      'call_id': {'type': 'string'},
      'caller': {
        'anyOf': [
          {r'$ref': '#/components/schemas/ToolCallCallerParam'},
          {'type': 'null'},
        ],
      },
      'output': {
        'oneOf': [
          {'type': 'string'},
          {
            'type': 'array',
            'items': {
              r'$ref': '#/components/schemas/FunctionAndCustomToolCallOutput',
            },
          },
        ],
      },
    },
    'required': ['type', 'call_id', 'output'],
  },
  'CustomToolCallOutputResource': {
    'allOf': [
      {r'$ref': '#/components/schemas/CustomToolCallOutput'},
      {
        'type': 'object',
        'properties': {
          'id': {'type': 'string'},
          'status': {
            r'$ref': '#/components/schemas/FunctionCallOutputStatusEnum',
          },
          'created_by': {'type': 'string'},
        },
        'required': ['id', 'status'],
      },
    ],
  },
  'CustomToolParam': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['custom'],
      },
      'name': {'type': 'string'},
      'async': {'type': 'boolean'},
      'description': {'type': 'string'},
      'format': {
        'oneOf': [
          {r'$ref': '#/components/schemas/CustomTextFormatParam'},
          {r'$ref': '#/components/schemas/CustomGrammarFormatParam'},
        ],
      },
      'defer_loading': {'type': 'boolean'},
      'allowed_callers': {
        'anyOf': [
          {
            'items': {
              r'$ref': '#/components/schemas/CallableToolAllowedCaller',
            },
            'type': 'array',
            'minItems': 1,
          },
          {'type': 'null'},
        ],
      },
    },
    'type': 'object',
    'required': ['type', 'name'],
  },
  'CyberAccessProgramEnum': {
    'type': 'string',
    'enum': ['standard', 'daybreak_blue', 'daybreak_red'],
  },
  'DetailEnum': {
    'type': 'string',
    'enum': ['low', 'high', 'auto', 'original'],
  },
  'DirectToolCallCaller': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['direct'],
      },
    },
    'type': 'object',
    'required': ['type'],
  },
  'DirectToolCallCallerParam': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['direct'],
      },
    },
    'type': 'object',
    'required': ['type'],
  },
  'DoubleClickAction': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['double_click'],
      },
      'x': {'type': 'integer'},
      'y': {'type': 'integer'},
      'keys': {
        'anyOf': [
          {
            'items': {'type': 'string'},
            'type': 'array',
          },
          {'type': 'null'},
        ],
      },
    },
    'type': 'object',
    'required': ['type', 'x', 'y', 'keys'],
  },
  'DragParam': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['drag'],
      },
      'path': {
        'items': {r'$ref': '#/components/schemas/CoordParam'},
        'type': 'array',
      },
      'keys': {
        'anyOf': [
          {
            'items': {'type': 'string'},
            'type': 'array',
          },
          {'type': 'null'},
        ],
      },
    },
    'type': 'object',
    'required': ['type', 'path'],
  },
  'EasyInputMessage': {
    'type': 'object',
    'properties': {
      'role': {
        'type': 'string',
        'enum': ['user', 'assistant', 'system', 'developer'],
      },
      'content': {
        'oneOf': [
          {'type': 'string'},
          {r'$ref': '#/components/schemas/InputMessageContentList'},
        ],
      },
      'phase': {
        'anyOf': [
          {r'$ref': '#/components/schemas/MessagePhase'},
          {'type': 'null'},
        ],
      },
      'type': {
        'type': 'string',
        'enum': ['message'],
      },
    },
    'required': ['role', 'content'],
  },
  'EmptyModelParam': {
    'properties': <String, dynamic>{},
    'type': 'object',
    'required': <dynamic>[],
  },
  'FileCitationBody': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['file_citation'],
      },
      'file_id': {'type': 'string'},
      'index': {'type': 'integer'},
      'filename': {'type': 'string'},
    },
    'type': 'object',
    'required': ['type', 'file_id', 'index', 'filename'],
  },
  'FileDetailEnum': {
    'type': 'string',
    'enum': ['auto', 'low', 'high'],
  },
  'FileInputDetail': {
    'type': 'string',
    'enum': ['auto', 'low', 'high'],
  },
  'FilePath': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['file_path'],
      },
      'file_id': {'type': 'string'},
      'index': {'type': 'integer'},
    },
    'required': ['type', 'file_id', 'index'],
  },
  'FileSearchTool': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['file_search'],
      },
      'vector_store_ids': {
        'items': {'type': 'string'},
        'type': 'array',
      },
      'max_num_results': {'type': 'integer'},
      'ranking_options': {r'$ref': '#/components/schemas/RankingOptions'},
      'filters': {
        'anyOf': [
          {r'$ref': '#/components/schemas/Filters'},
          {'type': 'null'},
        ],
      },
    },
    'type': 'object',
    'required': ['type', 'vector_store_ids'],
  },
  'FileSearchToolCall': {
    'type': 'object',
    'properties': {
      'id': {'type': 'string'},
      'type': {
        'type': 'string',
        'enum': ['file_search_call'],
      },
      'status': {
        'type': 'string',
        'enum': [
          'in_progress',
          'searching',
          'completed',
          'incomplete',
          'failed',
        ],
      },
      'queries': {
        'type': 'array',
        'items': {'type': 'string'},
      },
      'results': {
        'anyOf': [
          {
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'file_id': {'type': 'string'},
                'text': {'type': 'string'},
                'filename': {'type': 'string'},
                'attributes': {
                  r'$ref': '#/components/schemas/VectorStoreFileAttributes',
                },
                'score': {'type': 'number'},
              },
            },
          },
          {'type': 'null'},
        ],
      },
    },
    'required': ['id', 'type', 'status', 'queries'],
  },
  'Filters': {
    'anyOf': [
      {r'$ref': '#/components/schemas/ComparisonFilter'},
      {r'$ref': '#/components/schemas/CompoundFilter'},
    ],
  },
  'FunctionAndCustomToolCallOutput': {
    'oneOf': [
      {r'$ref': '#/components/schemas/InputTextContent'},
      {r'$ref': '#/components/schemas/InputImageContent'},
      {r'$ref': '#/components/schemas/InputFileContent'},
    ],
  },
  'FunctionCallItemStatus': {
    'type': 'string',
    'enum': ['in_progress', 'completed', 'incomplete'],
  },
  'FunctionCallOutputItemParam': {
    'properties': {
      'id': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'call_id': {
        'anyOf': [
          {'type': 'string', 'maxLength': 64, 'minLength': 1},
          {'type': 'null'},
        ],
      },
      'type': {
        'type': 'string',
        'enum': ['function_call_output'],
      },
      'output': {
        'oneOf': [
          {'type': 'string', 'maxLength': 10485760},
          {
            'items': {
              'oneOf': [
                {r'$ref': '#/components/schemas/InputTextContentParam'},
                {
                  r'$ref':
                      '#/components/schemas/InputImageContentParamAutoParam',
                },
                {r'$ref': '#/components/schemas/InputFileContentParam'},
              ],
            },
            'type': 'array',
          },
        ],
      },
      'name': {
        'anyOf': [
          {'type': 'string', 'maxLength': 128, 'minLength': 1},
          {'type': 'null'},
        ],
      },
      'namespace': {
        'anyOf': [
          {
            'type': 'string',
            'maxLength': 64,
            'minLength': 1,
            'pattern': r'^[a-zA-Z0-9_-]+$',
          },
          {'type': 'null'},
        ],
      },
      'caller': {
        'anyOf': [
          {r'$ref': '#/components/schemas/ToolCallCallerParam'},
          {'type': 'null'},
        ],
      },
      'status': {
        'anyOf': [
          {r'$ref': '#/components/schemas/FunctionCallItemStatus'},
          {'type': 'null'},
        ],
      },
    },
    'type': 'object',
    'required': ['type', 'output'],
  },
  'FunctionCallOutputStatusEnum': {
    'type': 'string',
    'enum': ['in_progress', 'completed', 'incomplete'],
  },
  'FunctionCallStatus': {
    'type': 'string',
    'enum': ['in_progress', 'completed', 'incomplete'],
  },
  'FunctionShellAction': {
    'properties': {
      'commands': {
        'items': {'type': 'string'},
        'type': 'array',
      },
      'timeout_ms': {
        'anyOf': [
          {'type': 'integer'},
          {'type': 'null'},
        ],
      },
      'max_output_length': {
        'anyOf': [
          {'type': 'integer'},
          {'type': 'null'},
        ],
      },
    },
    'type': 'object',
    'required': ['commands', 'timeout_ms', 'max_output_length'],
  },
  'FunctionShellActionParam': {
    'properties': {
      'commands': {
        'items': {'type': 'string'},
        'type': 'array',
      },
      'timeout_ms': {
        'anyOf': [
          {'type': 'integer'},
          {'type': 'null'},
        ],
      },
      'max_output_length': {
        'anyOf': [
          {'type': 'integer'},
          {'type': 'null'},
        ],
      },
    },
    'type': 'object',
    'required': ['commands'],
  },
  'FunctionShellCall': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['shell_call'],
      },
      'id': {'type': 'string'},
      'call_id': {'type': 'string'},
      'caller': {
        'anyOf': [
          {r'$ref': '#/components/schemas/ToolCallCaller'},
          {'type': 'null'},
        ],
      },
      'action': {r'$ref': '#/components/schemas/FunctionShellAction'},
      'status': {r'$ref': '#/components/schemas/FunctionShellCallStatus'},
      'environment': {
        'anyOf': [
          {
            'oneOf': [
              {r'$ref': '#/components/schemas/LocalEnvironmentResource'},
              {r'$ref': '#/components/schemas/ContainerReferenceResource'},
            ],
          },
          {'type': 'null'},
        ],
      },
      'created_by': {'type': 'string'},
    },
    'type': 'object',
    'required': ['type', 'id', 'call_id', 'action', 'status', 'environment'],
  },
  'FunctionShellCallItemParam': {
    'properties': {
      'id': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'call_id': {'type': 'string', 'maxLength': 64, 'minLength': 1},
      'caller': {
        'anyOf': [
          {r'$ref': '#/components/schemas/ToolCallCallerParam'},
          {'type': 'null'},
        ],
      },
      'type': {
        'type': 'string',
        'enum': ['shell_call'],
      },
      'action': {r'$ref': '#/components/schemas/FunctionShellActionParam'},
      'status': {
        'anyOf': [
          {r'$ref': '#/components/schemas/FunctionShellCallItemStatus'},
          {'type': 'null'},
        ],
      },
      'environment': {
        'anyOf': [
          {
            'oneOf': [
              {r'$ref': '#/components/schemas/LocalEnvironmentParam'},
              {r'$ref': '#/components/schemas/ContainerReferenceParam'},
            ],
          },
          {'type': 'null'},
        ],
      },
    },
    'type': 'object',
    'required': ['call_id', 'type', 'action'],
  },
  'FunctionShellCallItemStatus': {
    'type': 'string',
    'enum': ['in_progress', 'completed', 'incomplete'],
  },
  'FunctionShellCallOutput': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['shell_call_output'],
      },
      'id': {'type': 'string'},
      'call_id': {'type': 'string'},
      'caller': {
        'anyOf': [
          {r'$ref': '#/components/schemas/ToolCallCaller'},
          {'type': 'null'},
        ],
      },
      'status': {
        r'$ref': '#/components/schemas/FunctionShellCallOutputStatusEnum',
      },
      'output': {
        'items': {
          r'$ref': '#/components/schemas/FunctionShellCallOutputContent',
        },
        'type': 'array',
      },
      'max_output_length': {
        'anyOf': [
          {'type': 'integer'},
          {'type': 'null'},
        ],
      },
      'created_by': {'type': 'string'},
    },
    'type': 'object',
    'required': [
      'type',
      'id',
      'call_id',
      'status',
      'output',
      'max_output_length',
    ],
  },
  'FunctionShellCallOutputContent': {
    'properties': {
      'stdout': {'type': 'string'},
      'stderr': {'type': 'string'},
      'outcome': {
        'oneOf': [
          {
            r'$ref':
                '#/components/schemas/FunctionShellCallOutputTimeoutOutcome',
          },
          {r'$ref': '#/components/schemas/FunctionShellCallOutputExitOutcome'},
        ],
      },
      'created_by': {'type': 'string'},
    },
    'type': 'object',
    'required': ['stdout', 'stderr', 'outcome'],
  },
  'FunctionShellCallOutputContentParam': {
    'properties': {
      'stdout': {'type': 'string', 'maxLength': 10485760},
      'stderr': {'type': 'string', 'maxLength': 10485760},
      'outcome': {
        r'$ref': '#/components/schemas/FunctionShellCallOutputOutcomeParam',
      },
    },
    'type': 'object',
    'required': ['stdout', 'stderr', 'outcome'],
  },
  'FunctionShellCallOutputExitOutcome': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['exit'],
      },
      'exit_code': {'type': 'integer'},
    },
    'type': 'object',
    'required': ['type', 'exit_code'],
  },
  'FunctionShellCallOutputExitOutcomeParam': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['exit'],
      },
      'exit_code': {'type': 'integer'},
    },
    'type': 'object',
    'required': ['type', 'exit_code'],
  },
  'FunctionShellCallOutputItemParam': {
    'properties': {
      'id': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'call_id': {'type': 'string', 'maxLength': 64, 'minLength': 1},
      'caller': {
        'anyOf': [
          {r'$ref': '#/components/schemas/ToolCallCallerParam'},
          {'type': 'null'},
        ],
      },
      'type': {
        'type': 'string',
        'enum': ['shell_call_output'],
      },
      'output': {
        'items': {
          r'$ref': '#/components/schemas/FunctionShellCallOutputContentParam',
        },
        'type': 'array',
      },
      'status': {
        'anyOf': [
          {r'$ref': '#/components/schemas/FunctionShellCallItemStatus'},
          {'type': 'null'},
        ],
      },
      'max_output_length': {
        'anyOf': [
          {'type': 'integer'},
          {'type': 'null'},
        ],
      },
    },
    'type': 'object',
    'required': ['call_id', 'type', 'output'],
  },
  'FunctionShellCallOutputOutcomeParam': {
    'oneOf': [
      {
        r'$ref':
            '#/components/schemas/FunctionShellCallOutputTimeoutOutcomeParam',
      },
      {r'$ref': '#/components/schemas/FunctionShellCallOutputExitOutcomeParam'},
    ],
  },
  'FunctionShellCallOutputStatusEnum': {
    'type': 'string',
    'enum': ['in_progress', 'completed', 'incomplete'],
  },
  'FunctionShellCallOutputTimeoutOutcome': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['timeout'],
      },
    },
    'type': 'object',
    'required': ['type'],
  },
  'FunctionShellCallOutputTimeoutOutcomeParam': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['timeout'],
      },
    },
    'type': 'object',
    'required': ['type'],
  },
  'FunctionShellCallStatus': {
    'type': 'string',
    'enum': ['in_progress', 'completed', 'incomplete'],
  },
  'FunctionShellToolParam': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['shell'],
      },
      'environment': {
        'anyOf': [
          {
            'oneOf': [
              {r'$ref': '#/components/schemas/ContainerAutoParam'},
              {r'$ref': '#/components/schemas/LocalEnvironmentParam'},
              {r'$ref': '#/components/schemas/ContainerReferenceParam'},
            ],
          },
          {'type': 'null'},
        ],
      },
      'allowed_callers': {
        'anyOf': [
          {
            'items': {
              r'$ref': '#/components/schemas/CallableToolAllowedCaller',
            },
            'type': 'array',
            'minItems': 1,
          },
          {'type': 'null'},
        ],
      },
    },
    'type': 'object',
    'required': ['type'],
  },
  'FunctionTool': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['function'],
      },
      'name': {'type': 'string'},
      'async': {'type': 'boolean'},
      'description': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'parameters': {
        'anyOf': [
          {'additionalProperties': <String, dynamic>{}, 'type': 'object'},
          {'type': 'null'},
        ],
      },
      'output_schema': {
        'anyOf': [
          {'additionalProperties': <String, dynamic>{}, 'type': 'object'},
          {'type': 'null'},
        ],
      },
      'strict': {
        'anyOf': [
          {'type': 'boolean'},
          {'type': 'null'},
        ],
      },
      'defer_loading': {'type': 'boolean'},
      'allowed_callers': {
        'anyOf': [
          {
            'items': {
              r'$ref': '#/components/schemas/CallableToolAllowedCaller',
            },
            'type': 'array',
          },
          {'type': 'null'},
        ],
      },
    },
    'type': 'object',
    'required': ['type', 'name', 'strict', 'parameters'],
  },
  'FunctionToolCall': {
    'type': 'object',
    'properties': {
      'id': {'type': 'string'},
      'type': {
        'type': 'string',
        'enum': ['function_call'],
      },
      'call_id': {'type': 'string'},
      'caller': {
        'anyOf': [
          {r'$ref': '#/components/schemas/ToolCallCaller'},
          {'type': 'null'},
        ],
      },
      'namespace': {'type': 'string'},
      'name': {'type': 'string'},
      'arguments': {'type': 'string'},
      'status': {
        'type': 'string',
        'enum': ['in_progress', 'completed', 'incomplete'],
      },
      'async': {'type': 'boolean'},
    },
    'required': ['type', 'call_id', 'name', 'arguments'],
  },
  'FunctionToolCallOutput': {
    'type': 'object',
    'properties': {
      'id': {'type': 'string'},
      'type': {
        'type': 'string',
        'enum': ['function_call_output'],
      },
      'call_id': {'type': 'string'},
      'name': {'type': 'string'},
      'namespace': {'type': 'string'},
      'caller': {
        'anyOf': [
          {r'$ref': '#/components/schemas/ToolCallCallerParam'},
          {'type': 'null'},
        ],
      },
      'output': {
        'oneOf': [
          {'type': 'string'},
          {
            'type': 'array',
            'items': {
              r'$ref': '#/components/schemas/FunctionAndCustomToolCallOutput',
            },
          },
        ],
      },
      'status': {
        'type': 'string',
        'enum': ['in_progress', 'completed', 'incomplete'],
      },
    },
    'required': ['type', 'output'],
  },
  'FunctionToolCallOutputResource': {
    'allOf': [
      {r'$ref': '#/components/schemas/FunctionToolCallOutput'},
      {
        'type': 'object',
        'properties': {
          'id': {'type': 'string'},
          'status': {
            r'$ref': '#/components/schemas/FunctionCallOutputStatusEnum',
          },
          'created_by': {'type': 'string'},
        },
        'required': ['id', 'status'],
      },
    ],
  },
  'FunctionToolParam': {
    'properties': {
      'name': {
        'type': 'string',
        'maxLength': 128,
        'minLength': 1,
        'pattern': r'^[a-zA-Z0-9_-]+$',
      },
      'description': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'parameters': {
        'anyOf': [
          {r'$ref': '#/components/schemas/EmptyModelParam'},
          {'type': 'null'},
        ],
      },
      'strict': {
        'anyOf': [
          {'type': 'boolean'},
          {'type': 'null'},
        ],
      },
      'type': {
        'type': 'string',
        'enum': ['function'],
      },
      'async': {'type': 'boolean'},
      'output_schema': {
        'anyOf': [
          {'additionalProperties': <String, dynamic>{}, 'type': 'object'},
          {'type': 'null'},
        ],
      },
      'defer_loading': {'type': 'boolean'},
      'allowed_callers': {
        'anyOf': [
          {
            'items': {
              r'$ref': '#/components/schemas/CallableToolAllowedCaller',
            },
            'type': 'array',
            'minItems': 1,
          },
          {'type': 'null'},
        ],
      },
    },
    'type': 'object',
    'required': ['name', 'type'],
  },
  'GrammarSyntax1': {
    'type': 'string',
    'enum': ['lark', 'regex'],
  },
  'HTTPError': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['http_error'],
      },
      'code': {'type': 'integer'},
      'message': {'type': 'string'},
    },
    'type': 'object',
    'required': ['type', 'code', 'message'],
  },
  'HybridSearchOptions': {
    'properties': {
      'embedding_weight': {'type': 'number'},
      'text_weight': {'type': 'number'},
    },
    'type': 'object',
    'required': ['embedding_weight', 'text_weight'],
  },
  'ImageBackground': {
    'type': 'string',
    'enum': ['transparent', 'opaque', 'auto'],
  },
  'ImageDetail': {
    'type': 'string',
    'enum': ['low', 'high', 'auto', 'original'],
  },
  'ImageGenActionEnum': {
    'type': 'string',
    'enum': ['generate', 'edit', 'auto'],
  },
  'ImageGenTool': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['image_generation'],
      },
      'model': {
        'anyOf': [
          {'type': 'string'},
          {
            'type': 'string',
            'enum': [
              'gpt-image-1',
              'gpt-image-1-mini',
              'gpt-image-1.5',
              'gpt-image-2',
              'gpt-image-2-2026-04-21',
              'gpt-image-2.5-sunburst',
              'gpt-image-2.5-sunburst-2026-09-08',
              'gpt-image-2.5-flare',
              'gpt-image-2.5-flare-2026-09-08',
            ],
          },
        ],
      },
      'quality': {
        'type': 'string',
        'enum': ['low', 'medium', 'high', 'xhigh', 'max', 'auto'],
      },
      'size': {
        'anyOf': [
          {'type': 'string'},
          {
            'type': 'string',
            'enum': ['1024x1024', '1024x1536', '1536x1024', 'auto'],
          },
        ],
      },
      'output_format': {
        'type': 'string',
        'enum': ['png', 'webp', 'jpeg'],
      },
      'output_compression': {'type': 'integer', 'minimum': 0, 'maximum': 100},
      'moderation': {
        'type': 'string',
        'enum': ['auto', 'low'],
      },
      'background': {
        'type': 'string',
        'enum': ['transparent', 'opaque', 'auto'],
      },
      'input_fidelity': {
        'anyOf': [
          {r'$ref': '#/components/schemas/InputFidelity'},
          {'type': 'null'},
        ],
      },
      'input_image_mask': {
        'type': 'object',
        'properties': {
          'image_url': {'type': 'string'},
          'file_id': {'type': 'string'},
        },
        'required': <dynamic>[],
        'additionalProperties': false,
      },
      'partial_images': {'type': 'integer', 'minimum': 0, 'maximum': 3},
      'action': {r'$ref': '#/components/schemas/ImageGenActionEnum'},
    },
    'required': ['type'],
  },
  'ImageGenToolCall': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['image_generation_call'],
      },
      'id': {'type': 'string'},
      'status': {
        'type': 'string',
        'enum': ['in_progress', 'completed', 'generating', 'failed'],
      },
      'result': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'size': {
        'anyOf': [
          {
            'anyOf': [
              {'type': 'string'},
              {
                'type': 'string',
                'enum': ['1024x1024', '1024x1536', '1536x1024'],
              },
            ],
          },
          {'type': 'null'},
        ],
      },
      'quality': {
        'anyOf': [
          {
            'type': 'string',
            'enum': ['low', 'medium', 'high', 'xhigh', 'max', 'auto'],
          },
          {'type': 'null'},
        ],
      },
      'action': {
        'anyOf': [
          {r'$ref': '#/components/schemas/ImageGenActionEnum'},
          {'type': 'null'},
        ],
      },
      'background': {
        'anyOf': [
          {r'$ref': '#/components/schemas/ImageBackground'},
          {'type': 'null'},
        ],
      },
      'output_format': {
        'anyOf': [
          {r'$ref': '#/components/schemas/ImageOutputFormat'},
          {'type': 'null'},
        ],
      },
      'revised_prompt': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
    },
    'type': 'object',
    'required': ['type', 'id', 'status', 'result'],
  },
  'ImageOutputFormat': {
    'type': 'string',
    'enum': ['png', 'webp', 'jpeg'],
  },
  'InlineSkillParam': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['inline'],
      },
      'name': {'type': 'string'},
      'description': {'type': 'string'},
      'source': {r'$ref': '#/components/schemas/InlineSkillSourceParam'},
    },
    'type': 'object',
    'required': ['type', 'name', 'description', 'source'],
  },
  'InlineSkillSourceParam': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['base64'],
      },
      'media_type': {
        'type': 'string',
        'enum': ['application/zip'],
      },
      'data': {'type': 'string', 'maxLength': 70254592, 'minLength': 1},
    },
    'type': 'object',
    'required': ['type', 'media_type', 'data'],
  },
  'InputContent': {
    'oneOf': [
      {r'$ref': '#/components/schemas/InputTextContent'},
      {r'$ref': '#/components/schemas/InputImageContent'},
      {r'$ref': '#/components/schemas/InputFileContent'},
    ],
  },
  'InputFidelity': {
    'type': 'string',
    'enum': ['high', 'low'],
  },
  'InputFileContent': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['input_file'],
      },
      'file_id': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'filename': {'type': 'string'},
      'file_data': {'type': 'string'},
      'prompt_cache_breakpoint': {
        r'$ref': '#/components/schemas/PromptCacheBreakpointConfig',
      },
      'file_url': {'type': 'string'},
      'detail': {r'$ref': '#/components/schemas/FileInputDetail'},
    },
    'type': 'object',
    'required': ['type'],
  },
  'InputFileContentParam': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['input_file'],
      },
      'file_id': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'filename': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'file_data': {
        'anyOf': [
          {'type': 'string', 'maxLength': 73400320},
          {'type': 'null'},
        ],
      },
      'file_url': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'detail': {r'$ref': '#/components/schemas/FileDetailEnum'},
      'prompt_cache_breakpoint': {
        'anyOf': [
          {r'$ref': '#/components/schemas/PromptCacheBreakpointParam'},
          {'type': 'null'},
        ],
      },
    },
    'type': 'object',
    'required': ['type'],
  },
  'InputImageContent': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['input_image'],
      },
      'image_url': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'file_id': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'detail': {r'$ref': '#/components/schemas/ImageDetail'},
      'prompt_cache_breakpoint': {
        r'$ref': '#/components/schemas/PromptCacheBreakpointConfig',
      },
    },
    'type': 'object',
    'required': ['type', 'detail'],
  },
  'InputImageContentParamAutoParam': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['input_image'],
      },
      'image_url': {
        'anyOf': [
          {'type': 'string', 'maxLength': 20971520},
          {'type': 'null'},
        ],
      },
      'file_id': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'detail': {
        'anyOf': [
          {r'$ref': '#/components/schemas/DetailEnum'},
          {'type': 'null'},
        ],
      },
      'prompt_cache_breakpoint': {
        'anyOf': [
          {r'$ref': '#/components/schemas/PromptCacheBreakpointParam'},
          {'type': 'null'},
        ],
      },
    },
    'type': 'object',
    'required': ['type'],
  },
  'InputItem': {
    'oneOf': [
      {r'$ref': '#/components/schemas/EasyInputMessage'},
      {'type': 'object', r'$ref': '#/components/schemas/Item'},
      {r'$ref': '#/components/schemas/CompactionTriggerItemParam'},
      {r'$ref': '#/components/schemas/ItemReferenceParam'},
      {r'$ref': '#/components/schemas/ProgramItemParam'},
      {r'$ref': '#/components/schemas/ProgramOutputItemParam'},
    ],
  },
  'InputMessage': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['message'],
      },
      'role': {
        'type': 'string',
        'enum': ['user', 'system', 'developer'],
      },
      'status': {
        'type': 'string',
        'enum': ['in_progress', 'completed', 'incomplete'],
      },
      'content': {r'$ref': '#/components/schemas/InputMessageContentList'},
    },
    'required': ['role', 'content'],
  },
  'InputMessageContentList': {
    'type': 'array',
    'items': {r'$ref': '#/components/schemas/InputContent'},
  },
  'InputTextContent': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['input_text'],
      },
      'text': {'type': 'string'},
      'prompt_cache_breakpoint': {
        r'$ref': '#/components/schemas/PromptCacheBreakpointConfig',
      },
    },
    'type': 'object',
    'required': ['type', 'text'],
  },
  'InputTextContentParam': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['input_text'],
      },
      'text': {'type': 'string', 'maxLength': 10485760},
      'prompt_cache_breakpoint': {
        'anyOf': [
          {r'$ref': '#/components/schemas/PromptCacheBreakpointParam'},
          {'type': 'null'},
        ],
      },
    },
    'type': 'object',
    'required': ['type', 'text'],
  },
  'Item': {
    'type': 'object',
    'oneOf': [
      {r'$ref': '#/components/schemas/InputMessage'},
      {r'$ref': '#/components/schemas/OutputMessage'},
      {r'$ref': '#/components/schemas/FileSearchToolCall'},
      {r'$ref': '#/components/schemas/ComputerToolCall'},
      {r'$ref': '#/components/schemas/ComputerCallOutputItemParam'},
      {r'$ref': '#/components/schemas/WebSearchToolCall'},
      {r'$ref': '#/components/schemas/FunctionToolCall'},
      {r'$ref': '#/components/schemas/FunctionCallOutputItemParam'},
      {r'$ref': '#/components/schemas/ToolSearchCallItemParam'},
      {r'$ref': '#/components/schemas/ToolSearchOutputItemParam'},
      {r'$ref': '#/components/schemas/AdditionalToolsItemParam'},
      {r'$ref': '#/components/schemas/ResponseConfigurationUpdateItemParam'},
      {r'$ref': '#/components/schemas/ReasoningItem'},
      {r'$ref': '#/components/schemas/CompactionSummaryItemParam'},
      {r'$ref': '#/components/schemas/ImageGenToolCall'},
      {r'$ref': '#/components/schemas/CodeInterpreterToolCall'},
      {r'$ref': '#/components/schemas/LocalShellToolCall'},
      {r'$ref': '#/components/schemas/LocalShellToolCallOutput'},
      {r'$ref': '#/components/schemas/FunctionShellCallItemParam'},
      {r'$ref': '#/components/schemas/FunctionShellCallOutputItemParam'},
      {r'$ref': '#/components/schemas/ApplyPatchToolCallItemParam'},
      {r'$ref': '#/components/schemas/ApplyPatchToolCallOutputItemParam'},
      {r'$ref': '#/components/schemas/MCPListTools'},
      {r'$ref': '#/components/schemas/MCPApprovalRequest'},
      {r'$ref': '#/components/schemas/MCPApprovalResponse'},
      {r'$ref': '#/components/schemas/MCPToolCall'},
      {r'$ref': '#/components/schemas/CustomToolCallOutput'},
      {r'$ref': '#/components/schemas/CustomToolCall'},
    ],
  },
  'ItemReferenceParam': {
    'properties': {
      'type': {
        'anyOf': [
          {
            'type': 'string',
            'enum': ['item_reference'],
          },
          {'type': 'null'},
        ],
      },
      'id': {'type': 'string'},
    },
    'type': 'object',
    'required': ['id'],
  },
  'KeyPressAction': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['keypress'],
      },
      'keys': {
        'items': {'type': 'string'},
        'type': 'array',
      },
    },
    'type': 'object',
    'required': ['type', 'keys'],
  },
  'LocalEnvironmentParam': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['local'],
      },
      'skills': {
        'items': {r'$ref': '#/components/schemas/LocalSkillParam'},
        'type': 'array',
        'maxItems': 200,
      },
    },
    'type': 'object',
    'required': ['type'],
  },
  'LocalEnvironmentResource': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['local'],
      },
    },
    'type': 'object',
    'required': ['type'],
  },
  'LocalShellExecAction': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['exec'],
      },
      'command': {
        'items': {'type': 'string'},
        'type': 'array',
      },
      'timeout_ms': {
        'anyOf': [
          {'type': 'integer'},
          {'type': 'null'},
        ],
      },
      'working_directory': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'env': {
        'additionalProperties': {'type': 'string'},
        'type': 'object',
      },
      'user': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
    },
    'type': 'object',
    'required': ['type', 'command', 'env'],
  },
  'LocalShellToolCall': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['local_shell_call'],
      },
      'id': {'type': 'string'},
      'call_id': {'type': 'string'},
      'action': {r'$ref': '#/components/schemas/LocalShellExecAction'},
      'status': {
        'type': 'string',
        'enum': ['in_progress', 'completed', 'incomplete'],
      },
    },
    'required': ['type', 'id', 'call_id', 'action', 'status'],
  },
  'LocalShellToolCallOutput': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['local_shell_call_output'],
      },
      'id': {'type': 'string'},
      'output': {'type': 'string'},
      'status': {
        'anyOf': [
          {
            'type': 'string',
            'enum': ['in_progress', 'completed', 'incomplete'],
          },
          {'type': 'null'},
        ],
      },
    },
    'required': ['id', 'type', 'call_id', 'output'],
  },
  'LocalShellToolParam': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['local_shell'],
      },
    },
    'type': 'object',
    'required': ['type'],
  },
  'LocalSkillParam': {
    'properties': {
      'name': {'type': 'string'},
      'description': {'type': 'string'},
      'path': {'type': 'string'},
    },
    'type': 'object',
    'required': ['name', 'description', 'path'],
  },
  'LogProb': {
    'properties': {
      'token': {'type': 'string'},
      'logprob': {'type': 'number'},
      'bytes': {
        'items': {'type': 'integer'},
        'type': 'array',
      },
      'top_logprobs': {
        'items': {r'$ref': '#/components/schemas/TopLogProb'},
        'type': 'array',
      },
    },
    'type': 'object',
    'required': ['token', 'logprob', 'bytes', 'top_logprobs'],
  },
  'MCPApprovalRequest': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['mcp_approval_request'],
      },
      'id': {'type': 'string'},
      'server_label': {'type': 'string'},
      'name': {'type': 'string'},
      'arguments': {'type': 'string'},
    },
    'required': ['type', 'id', 'server_label', 'name', 'arguments'],
  },
  'MCPApprovalResponse': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['mcp_approval_response'],
      },
      'id': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'approval_request_id': {'type': 'string'},
      'approve': {'type': 'boolean'},
      'reason': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
    },
    'required': ['type', 'request_id', 'approve', 'approval_request_id'],
  },
  'MCPApprovalResponseResource': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['mcp_approval_response'],
      },
      'id': {'type': 'string'},
      'approval_request_id': {'type': 'string'},
      'approve': {'type': 'boolean'},
      'reason': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
    },
    'required': ['type', 'id', 'request_id', 'approve', 'approval_request_id'],
  },
  'MCPListTools': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['mcp_list_tools'],
      },
      'id': {'type': 'string'},
      'server_label': {'type': 'string'},
      'tools': {
        'type': 'array',
        'items': {r'$ref': '#/components/schemas/MCPListToolsTool'},
      },
      'error': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
    },
    'required': ['type', 'id', 'server_label', 'tools'],
  },
  'MCPListToolsTool': {
    'type': 'object',
    'properties': {
      'name': {'type': 'string'},
      'description': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'input_schema': {'type': 'object'},
      'annotations': {
        'anyOf': [
          {'type': 'object'},
          {'type': 'null'},
        ],
      },
    },
    'required': ['name', 'input_schema'],
  },
  'MCPProtocolError': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['mcp_protocol_error'],
      },
      'code': {'type': 'integer'},
      'message': {'type': 'string'},
    },
    'type': 'object',
    'required': ['type', 'code', 'message'],
  },
  'MCPTool': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['mcp'],
      },
      'server_label': {'type': 'string'},
      'server_url': {'type': 'string'},
      'connector_id': {
        'type': 'string',
        'enum': [
          'connector_dropbox',
          'connector_gmail',
          'connector_googlecalendar',
          'connector_googledrive',
          'connector_microsoftteams',
          'connector_outlookcalendar',
          'connector_outlookemail',
          'connector_sharepoint',
        ],
      },
      'tunnel_id': {'type': 'string', 'pattern': r'^tunnel_[a-z0-9]{32}$'},
      'authorization': {'type': 'string'},
      'server_description': {'type': 'string'},
      'headers': {
        'anyOf': [
          {
            'type': 'object',
            'additionalProperties': {'type': 'string'},
          },
          {'type': 'null'},
        ],
      },
      'allowed_tools': {
        'anyOf': [
          {
            'oneOf': [
              {
                'type': 'array',
                'items': {'type': 'string'},
              },
              {r'$ref': '#/components/schemas/MCPToolFilter'},
            ],
          },
          {'type': 'null'},
        ],
      },
      'allowed_callers': {
        'anyOf': [
          {
            'type': 'array',
            'minItems': 1,
            'items': {
              r'$ref': '#/components/schemas/CallableToolAllowedCaller',
            },
          },
          {'type': 'null'},
        ],
      },
      'require_approval': {
        'anyOf': [
          {
            'oneOf': [
              {
                'type': 'object',
                'properties': {
                  'always': {r'$ref': '#/components/schemas/MCPToolFilter'},
                  'never': {r'$ref': '#/components/schemas/MCPToolFilter'},
                },
                'additionalProperties': false,
              },
              {
                'type': 'string',
                'enum': ['always', 'never'],
              },
            ],
          },
          {'type': 'null'},
        ],
      },
      'defer_loading': {'type': 'boolean'},
    },
    'required': ['type', 'server_label'],
  },
  'MCPToolCall': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['mcp_call'],
      },
      'id': {'type': 'string'},
      'server_label': {'type': 'string'},
      'name': {'type': 'string'},
      'arguments': {'type': 'string'},
      'output': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'error': {
        'anyOf': [
          {r'$ref': '#/components/schemas/MCPToolCallError'},
          {'type': 'null'},
        ],
      },
      'status': {r'$ref': '#/components/schemas/MCPToolCallStatus'},
      'approval_request_id': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
    },
    'required': ['type', 'id', 'server_label', 'name', 'arguments'],
  },
  'MCPToolCallError': {
    'oneOf': [
      {r'$ref': '#/components/schemas/MCPProtocolError'},
      {r'$ref': '#/components/schemas/MCPToolExecutionError'},
      {r'$ref': '#/components/schemas/HTTPError'},
    ],
  },
  'MCPToolCallStatus': {
    'type': 'string',
    'enum': ['in_progress', 'completed', 'incomplete', 'calling', 'failed'],
  },
  'MCPToolExecutionError': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['mcp_tool_execution_error'],
      },
      'content': <String, dynamic>{},
    },
    'type': 'object',
    'required': ['type', 'content'],
  },
  'MCPToolFilter': {
    'type': 'object',
    'properties': {
      'tool_names': {
        'type': 'array',
        'items': {'type': 'string'},
      },
      'read_only': {'type': 'boolean'},
    },
    'required': <dynamic>[],
    'additionalProperties': false,
  },
  'MessagePhase': {
    'type': 'string',
    'enum': ['commentary', 'final_answer'],
  },
  'MessageRole': {
    'type': 'string',
    'enum': [
      'unknown',
      'user',
      'assistant',
      'system',
      'critic',
      'discriminator',
      'developer',
      'tool',
    ],
  },
  'Metadata': {
    'anyOf': [
      {
        'type': 'object',
        'additionalProperties': {'type': 'string'},
      },
      {'type': 'null'},
    ],
  },
  'MisalignmentErrorDetailsResource': {
    'properties': {
      'review_target': {
        'anyOf': [
          {
            'not': {'pattern': '[^A-Za-z0-9._~:-]'},
            'type': 'string',
            'maxLength': 96,
            'minLength': 1,
            'pattern': r'^[A-Za-z0-9._~:-]+$',
          },
          {'type': 'null'},
        ],
      },
      'error_type': {r'$ref': '#/components/schemas/_MisalignmentErrorType'},
      'detailed_explanation': {'type': 'string'},
      'steer': {r'$ref': '#/components/schemas/_MisalignmentSteer'},
    },
    'type': 'object',
    'required': <dynamic>[],
  },
  'ModelIdsResponses': {
    'anyOf': [
      {r'$ref': '#/components/schemas/ModelIdsShared'},
      {
        'type': 'string',
        'enum': [
          'o1-pro',
          'o1-pro-2025-03-19',
          'o3-pro',
          'o3-pro-2025-06-10',
          'o3-deep-research',
          'o3-deep-research-2025-06-26',
          'o4-mini-deep-research',
          'o4-mini-deep-research-2025-06-26',
          'computer-use-preview',
          'computer-use-preview-2025-03-11',
          'gpt-5.5-pro',
          'gpt-5.5-pro-2026-04-23',
          'gpt-5-codex',
          'gpt-5-pro',
          'gpt-5-pro-2025-10-06',
          'gpt-5.1-codex-max',
          'gpt-daybreak-blue-latest',
          'gpt-daybreak-red-latest',
          'gpt-5.6-cyber',
          'gpt-rosalind-research',
        ],
      },
    ],
  },
  'ModelIdsShared': {
    'anyOf': [
      {'type': 'string'},
      {
        'type': 'string',
        'enum': [
          'gpt-6-astra',
          'gpt-6.1-sol',
          'gpt-6-sol',
          'gpt-6-luna',
          'gpt-5.6-sol',
          'gpt-5.6-terra',
          'gpt-5.6-luna',
          'gpt-5.5',
          'gpt-5.5-2026-04-23',
          'gpt-5.4',
          'gpt-5.4-mini',
          'gpt-5.4-nano',
          'gpt-5.4-mini-2026-03-17',
          'gpt-5.4-nano-2026-03-17',
          'gpt-5.3-chat-latest',
          'gpt-5.2',
          'gpt-5.2-2025-12-11',
          'gpt-5.2-chat-latest',
          'gpt-5.2-pro',
          'gpt-5.2-pro-2025-12-11',
          'gpt-5.1',
          'gpt-5.1-2025-11-13',
          'gpt-5.1-codex',
          'gpt-5.1-mini',
          'gpt-5.1-chat-latest',
          'gpt-5',
          'gpt-5-mini',
          'gpt-5-nano',
          'gpt-5-2025-08-07',
          'gpt-5-mini-2025-08-07',
          'gpt-5-nano-2025-08-07',
          'gpt-5-chat-latest',
          'gpt-4.1',
          'gpt-4.1-mini',
          'gpt-4.1-nano',
          'gpt-4.1-2025-04-14',
          'gpt-4.1-mini-2025-04-14',
          'gpt-4.1-nano-2025-04-14',
          'o4-mini',
          'o4-mini-2025-04-16',
          'o3',
          'o3-2025-04-16',
          'o3-mini',
          'o3-mini-2025-01-31',
          'o1',
          'o1-2024-12-17',
          'o1-preview',
          'o1-preview-2024-09-12',
          'o1-mini',
          'o1-mini-2024-09-12',
          'gpt-4o',
          'gpt-4o-2024-11-20',
          'gpt-4o-2024-08-06',
          'gpt-4o-2024-05-13',
          'gpt-audio-mini',
          'gpt-audio-mini-2025-12-15',
          'gpt-4o-audio-preview',
          'gpt-4o-audio-preview-2024-10-01',
          'gpt-4o-audio-preview-2024-12-17',
          'gpt-4o-audio-preview-2025-06-03',
          'gpt-4o-mini-audio-preview',
          'gpt-4o-mini-audio-preview-2024-12-17',
          'gpt-4o-search-preview',
          'gpt-4o-mini-search-preview',
          'gpt-4o-search-preview-2025-03-11',
          'gpt-4o-mini-search-preview-2025-03-11',
          'chatgpt-4o-latest',
          'codex-mini-latest',
          'gpt-4o-mini',
          'gpt-4o-mini-2024-07-18',
          'gpt-4-turbo',
          'gpt-4-turbo-2024-04-09',
          'gpt-4-0125-preview',
          'gpt-4-turbo-preview',
          'gpt-4-1106-preview',
          'gpt-4-vision-preview',
          'gpt-4',
          'gpt-4-0314',
          'gpt-4-0613',
          'gpt-4-32k',
          'gpt-4-32k-0314',
          'gpt-4-32k-0613',
          'gpt-3.5-turbo',
          'gpt-3.5-turbo-16k',
          'gpt-3.5-turbo-0301',
          'gpt-3.5-turbo-0613',
          'gpt-3.5-turbo-1106',
          'gpt-3.5-turbo-0125',
          'gpt-3.5-turbo-16k-0613',
        ],
      },
    ],
  },
  'Moderation': {
    'properties': {
      'input': {
        'oneOf': [
          {r'$ref': '#/components/schemas/ModerationResultBody'},
          {r'$ref': '#/components/schemas/ModerationErrorBody'},
        ],
      },
      'output': {
        'oneOf': [
          {r'$ref': '#/components/schemas/ModerationResultBody'},
          {r'$ref': '#/components/schemas/ModerationErrorBody'},
        ],
      },
    },
    'type': 'object',
    'required': ['input', 'output'],
  },
  'ModerationErrorBody': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['error'],
      },
      'code': {'type': 'string'},
      'message': {'type': 'string'},
    },
    'type': 'object',
    'required': ['type', 'code', 'message'],
  },
  'ModerationInputType': {
    'type': 'string',
    'enum': ['text', 'image'],
  },
  'ModerationResultBody': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['moderation_result'],
      },
      'model': {'type': 'string'},
      'flagged': {'type': 'boolean'},
      'categories': {
        'additionalProperties': {'type': 'boolean'},
        'type': 'object',
      },
      'category_scores': {
        'additionalProperties': {'type': 'number'},
        'type': 'object',
      },
      'category_applied_input_types': {
        'additionalProperties': {
          'items': {r'$ref': '#/components/schemas/ModerationInputType'},
          'type': 'array',
        },
        'type': 'object',
      },
    },
    'type': 'object',
    'required': [
      'type',
      'model',
      'flagged',
      'categories',
      'category_scores',
      'category_applied_input_types',
    ],
  },
  'MoveParam': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['move'],
      },
      'x': {'type': 'integer'},
      'y': {'type': 'integer'},
      'keys': {
        'anyOf': [
          {
            'items': {'type': 'string'},
            'type': 'array',
          },
          {'type': 'null'},
        ],
      },
    },
    'type': 'object',
    'required': ['type', 'x', 'y'],
  },
  'NamespaceToolParam': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['namespace'],
      },
      'name': {'type': 'string', 'minLength': 1},
      'description': {'type': 'string'},
      'tools': {
        'items': {
          'oneOf': [
            {r'$ref': '#/components/schemas/FunctionToolParam'},
            {r'$ref': '#/components/schemas/CustomToolParam'},
          ],
        },
        'type': 'array',
        'minItems': 1,
      },
    },
    'type': 'object',
    'required': ['type', 'name', 'description', 'tools'],
  },
  'OutputContent': {
    'oneOf': [
      {r'$ref': '#/components/schemas/OutputTextContent'},
      {r'$ref': '#/components/schemas/RefusalContent'},
      {r'$ref': '#/components/schemas/ReasoningTextContent'},
    ],
  },
  'OutputItem': {
    'oneOf': [
      {r'$ref': '#/components/schemas/OutputMessage'},
      {r'$ref': '#/components/schemas/FileSearchToolCall'},
      {r'$ref': '#/components/schemas/FunctionToolCall'},
      {r'$ref': '#/components/schemas/FunctionToolCallOutputResource'},
      {r'$ref': '#/components/schemas/WebSearchToolCall'},
      {r'$ref': '#/components/schemas/ComputerToolCall'},
      {r'$ref': '#/components/schemas/ComputerToolCallOutputResource'},
      {r'$ref': '#/components/schemas/ReasoningItem'},
      {r'$ref': '#/components/schemas/Program'},
      {r'$ref': '#/components/schemas/ProgramOutput'},
      {r'$ref': '#/components/schemas/ToolSearchCall'},
      {r'$ref': '#/components/schemas/ToolSearchOutput'},
      {r'$ref': '#/components/schemas/AdditionalTools'},
      {r'$ref': '#/components/schemas/CompactionBody'},
      {r'$ref': '#/components/schemas/ImageGenToolCall'},
      {r'$ref': '#/components/schemas/CodeInterpreterToolCall'},
      {r'$ref': '#/components/schemas/LocalShellToolCall'},
      {r'$ref': '#/components/schemas/LocalShellToolCallOutput'},
      {r'$ref': '#/components/schemas/FunctionShellCall'},
      {r'$ref': '#/components/schemas/FunctionShellCallOutput'},
      {r'$ref': '#/components/schemas/ApplyPatchToolCall'},
      {r'$ref': '#/components/schemas/ApplyPatchToolCallOutput'},
      {r'$ref': '#/components/schemas/MCPToolCall'},
      {r'$ref': '#/components/schemas/MCPListTools'},
      {r'$ref': '#/components/schemas/MCPApprovalRequest'},
      {r'$ref': '#/components/schemas/MCPApprovalResponseResource'},
      {r'$ref': '#/components/schemas/CustomToolCall'},
      {r'$ref': '#/components/schemas/CustomToolCallOutputResource'},
    ],
  },
  'OutputMessage': {
    'type': 'object',
    'properties': {
      'id': {'type': 'string'},
      'type': {
        'type': 'string',
        'enum': ['message'],
      },
      'role': {
        'type': 'string',
        'enum': ['assistant'],
      },
      'content': {
        'type': 'array',
        'items': {r'$ref': '#/components/schemas/OutputMessageContent'},
      },
      'phase': {
        'anyOf': [
          {r'$ref': '#/components/schemas/MessagePhase'},
          {'type': 'null'},
        ],
      },
      'status': {
        'type': 'string',
        'enum': ['in_progress', 'completed', 'incomplete'],
      },
    },
    'required': ['id', 'type', 'role', 'content', 'status'],
  },
  'OutputMessageContent': {
    'oneOf': [
      {r'$ref': '#/components/schemas/OutputTextContent'},
      {r'$ref': '#/components/schemas/RefusalContent'},
    ],
  },
  'OutputTextContent': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['output_text'],
      },
      'text': {'type': 'string'},
      'annotations': {
        'items': {r'$ref': '#/components/schemas/Annotation'},
        'type': 'array',
      },
      'logprobs': {
        'items': {r'$ref': '#/components/schemas/LogProb'},
        'type': 'array',
      },
    },
    'type': 'object',
    'required': ['type', 'text', 'annotations', 'logprobs'],
  },
  'Program': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['program'],
      },
      'id': {'type': 'string'},
      'call_id': {'type': 'string'},
      'code': {'type': 'string'},
      'fingerprint': {'type': 'string'},
    },
    'type': 'object',
    'required': ['type', 'id', 'call_id', 'code', 'fingerprint'],
  },
  'ProgramItemParam': {
    'properties': {
      'id': {'type': 'string'},
      'type': {
        'type': 'string',
        'enum': ['program'],
      },
      'call_id': {'type': 'string', 'maxLength': 64, 'minLength': 1},
      'code': {'type': 'string', 'maxLength': 10485760},
      'fingerprint': {'type': 'string', 'maxLength': 10485760},
    },
    'type': 'object',
    'required': ['id', 'type', 'call_id', 'code', 'fingerprint'],
  },
  'ProgramOutput': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['program_output'],
      },
      'id': {'type': 'string'},
      'call_id': {'type': 'string'},
      'result': {'type': 'string'},
      'status': {r'$ref': '#/components/schemas/ProgramOutputStatus'},
    },
    'type': 'object',
    'required': ['type', 'id', 'call_id', 'result', 'status'],
  },
  'ProgramOutputItemParam': {
    'properties': {
      'id': {'type': 'string'},
      'type': {
        'type': 'string',
        'enum': ['program_output'],
      },
      'call_id': {'type': 'string', 'maxLength': 64, 'minLength': 1},
      'result': {'type': 'string', 'maxLength': 10485760},
      'status': {r'$ref': '#/components/schemas/ProgramOutputItemStatus'},
    },
    'type': 'object',
    'required': ['id', 'type', 'call_id', 'result', 'status'],
  },
  'ProgramOutputItemStatus': {
    'type': 'string',
    'enum': ['completed', 'incomplete'],
  },
  'ProgramOutputStatus': {
    'type': 'string',
    'enum': ['completed', 'incomplete'],
  },
  'ProgramToolCallCaller': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['program'],
      },
      'caller_id': {'type': 'string'},
    },
    'type': 'object',
    'required': ['type', 'caller_id'],
  },
  'ProgramToolCallCallerParam': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['program'],
      },
      'caller_id': {'type': 'string', 'maxLength': 64, 'minLength': 1},
    },
    'type': 'object',
    'required': ['type', 'caller_id'],
  },
  'ProgrammaticToolCallingParam': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['programmatic_tool_calling'],
      },
    },
    'type': 'object',
    'required': ['type'],
  },
  'Prompt': {
    'anyOf': [
      {
        'type': 'object',
        'required': ['id'],
        'properties': {
          'id': {'type': 'string'},
          'version': {
            'anyOf': [
              {'type': 'string'},
              {'type': 'null'},
            ],
          },
          'variables': {
            r'$ref': '#/components/schemas/ResponsePromptVariables',
          },
        },
      },
      {'type': 'null'},
    ],
  },
  'PromptCacheBreakpointConfig': {
    'properties': {
      'mode': {
        'type': 'string',
        'enum': ['explicit'],
      },
    },
    'type': 'object',
    'required': ['mode'],
  },
  'PromptCacheBreakpointParam': {
    'properties': {
      'mode': {
        'type': 'string',
        'enum': ['explicit'],
      },
    },
    'type': 'object',
    'required': ['mode'],
  },
  'PromptCacheComparisonResponseNotFoundDiagnosticsBody': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['comparison_response_not_found'],
      },
    },
    'type': 'object',
    'required': ['type'],
  },
  'PromptCacheDiagnostics': {
    'oneOf': [
      {r'$ref': '#/components/schemas/PromptCacheMissDiagnosticsBody'},
      {r'$ref': '#/components/schemas/PromptCacheHitDiagnosticsBody'},
      {
        r'$ref':
            '#/components/schemas/PromptCacheComparisonResponseNotFoundDiagnosticsBody',
      },
      {r'$ref': '#/components/schemas/PromptCacheUnavailableDiagnosticsBody'},
    ],
  },
  'PromptCacheHitDiagnosticsBody': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['cache_hit'],
      },
    },
    'type': 'object',
    'required': ['type'],
  },
  'PromptCacheMissDiagnosticsBody': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['cache_miss'],
      },
      'reason': {r'$ref': '#/components/schemas/CacheMissReasonTypeEnum'},
      'cache_missed_tokens': {'type': 'integer'},
      'comparison_reusable_tokens': {'type': 'integer'},
    },
    'type': 'object',
    'required': ['type', 'reason', 'cache_missed_tokens'],
  },
  'PromptCacheModeEnum': {
    'type': 'string',
    'enum': ['implicit', 'explicit'],
  },
  'PromptCacheOptions': {
    'properties': {
      'ttl': {r'$ref': '#/components/schemas/PromptCacheTTLEnum'},
      'mode': {r'$ref': '#/components/schemas/PromptCacheModeEnum'},
      'comparison_response_id': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
    },
    'type': 'object',
    'required': ['ttl', 'mode'],
  },
  'PromptCacheTTLEnum': {
    'type': 'string',
    'enum': ['30m'],
  },
  'PromptCacheUnavailableDiagnosticsBody': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['unavailable'],
      },
    },
    'type': 'object',
    'required': ['type'],
  },
  'RankerVersionType': {
    'type': 'string',
    'enum': ['auto', 'default-2024-11-15'],
  },
  'RankingOptions': {
    'properties': {
      'ranker': {r'$ref': '#/components/schemas/RankerVersionType'},
      'score_threshold': {'type': 'number'},
      'hybrid_search': {r'$ref': '#/components/schemas/HybridSearchOptions'},
    },
    'type': 'object',
    'required': <dynamic>[],
  },
  'Reasoning': {
    'type': 'object',
    'properties': {
      'mode': {r'$ref': '#/components/schemas/ReasoningModeEnum'},
      'effort': {r'$ref': '#/components/schemas/ReasoningEffort'},
      'summary': {
        'anyOf': [
          {
            'type': 'string',
            'enum': ['auto', 'concise', 'detailed'],
          },
          {'type': 'null'},
        ],
      },
      'context': {
        'anyOf': [
          {
            'type': 'string',
            'enum': ['auto', 'current_turn', 'all_turns'],
          },
          {'type': 'null'},
        ],
      },
      'generate_summary': {
        'anyOf': [
          {
            'type': 'string',
            'enum': ['auto', 'concise', 'detailed'],
          },
          {'type': 'null'},
        ],
      },
    },
  },
  'ReasoningEffort': {
    'anyOf': [
      {
        'type': 'string',
        'enum': ['none', 'minimal', 'low', 'medium', 'high', 'xhigh', 'max'],
      },
      {'type': 'null'},
    ],
  },
  'ReasoningItem': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['reasoning'],
      },
      'id': {'type': 'string'},
      'encrypted_content': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'summary': {
        'type': 'array',
        'items': {r'$ref': '#/components/schemas/SummaryTextContent'},
      },
      'content': {
        'type': 'array',
        'items': {r'$ref': '#/components/schemas/ReasoningTextContent'},
      },
      'status': {
        'type': 'string',
        'enum': ['in_progress', 'completed', 'incomplete'],
      },
    },
    'required': ['id', 'summary', 'type'],
  },
  'ReasoningModeEnum': {
    'anyOf': [
      {'type': 'string'},
      {
        'type': 'string',
        'enum': ['standard', 'pro'],
      },
    ],
  },
  'ReasoningTextContent': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['reasoning_text'],
      },
      'text': {'type': 'string'},
    },
    'type': 'object',
    'required': ['type', 'text'],
  },
  'RefusalContent': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['refusal'],
      },
      'refusal': {'type': 'string'},
    },
    'type': 'object',
    'required': ['type', 'refusal'],
  },
  'ResponseAudioDeltaEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.audio.delta'],
      },
      'sequence_number': {'type': 'integer'},
      'delta': {'type': 'string'},
    },
    'required': ['type', 'delta', 'sequence_number'],
  },
  'ResponseAudioDoneEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.audio.done'],
      },
      'sequence_number': {'type': 'integer'},
    },
    'required': ['type', 'sequence_number', 'response_id'],
  },
  'ResponseAudioTranscriptDeltaEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.audio.transcript.delta'],
      },
      'delta': {'type': 'string'},
      'sequence_number': {'type': 'integer'},
    },
    'required': ['type', 'response_id', 'delta', 'sequence_number'],
  },
  'ResponseAudioTranscriptDoneEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.audio.transcript.done'],
      },
      'sequence_number': {'type': 'integer'},
    },
    'required': ['type', 'response_id', 'sequence_number'],
  },
  'ResponseCodeInterpreterCallCodeDeltaEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.code_interpreter_call_code.delta'],
      },
      'output_index': {'type': 'integer'},
      'item_id': {'type': 'string'},
      'delta': {'type': 'string'},
      'sequence_number': {'type': 'integer'},
    },
    'required': ['type', 'output_index', 'item_id', 'delta', 'sequence_number'],
  },
  'ResponseCodeInterpreterCallCodeDoneEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.code_interpreter_call_code.done'],
      },
      'output_index': {'type': 'integer'},
      'item_id': {'type': 'string'},
      'code': {'type': 'string'},
      'sequence_number': {'type': 'integer'},
    },
    'required': ['type', 'output_index', 'item_id', 'code', 'sequence_number'],
  },
  'ResponseCodeInterpreterCallCompletedEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.code_interpreter_call.completed'],
      },
      'output_index': {'type': 'integer'},
      'item_id': {'type': 'string'},
      'sequence_number': {'type': 'integer'},
    },
    'required': ['type', 'output_index', 'item_id', 'sequence_number'],
  },
  'ResponseCodeInterpreterCallInProgressEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.code_interpreter_call.in_progress'],
      },
      'output_index': {'type': 'integer'},
      'item_id': {'type': 'string'},
      'sequence_number': {'type': 'integer'},
    },
    'required': ['type', 'output_index', 'item_id', 'sequence_number'],
  },
  'ResponseCodeInterpreterCallInterpretingEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.code_interpreter_call.interpreting'],
      },
      'output_index': {'type': 'integer'},
      'item_id': {'type': 'string'},
      'sequence_number': {'type': 'integer'},
    },
    'required': ['type', 'output_index', 'item_id', 'sequence_number'],
  },
  'ResponseCompactionCompactingStreamingEvent': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.compaction.compacting'],
      },
      'sequence_number': {'type': 'integer'},
      'output_index': {'type': 'integer'},
      'item_id': {'type': 'string'},
    },
    'type': 'object',
    'required': ['type', 'sequence_number', 'output_index', 'item_id'],
  },
  'ResponseConfigurationUpdateItemParam': {
    'type': 'object',
    'properties': {
      'id': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'type': {
        'type': 'string',
        'enum': ['configuration_update'],
      },
      'reasoning': {
        'type': 'object',
        'properties': {
          'effort': {r'$ref': '#/components/schemas/ReasoningEffort'},
        },
      },
    },
    'required': ['type'],
  },
  'ResponseContentPartAddedEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.content_part.added'],
      },
      'item_id': {'type': 'string'},
      'output_index': {'type': 'integer'},
      'content_index': {'type': 'integer'},
      'part': {r'$ref': '#/components/schemas/OutputContent'},
      'sequence_number': {'type': 'integer'},
    },
    'required': [
      'type',
      'item_id',
      'output_index',
      'content_index',
      'part',
      'sequence_number',
    ],
  },
  'ResponseContentPartDoneEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.content_part.done'],
      },
      'item_id': {'type': 'string'},
      'output_index': {'type': 'integer'},
      'content_index': {'type': 'integer'},
      'sequence_number': {'type': 'integer'},
      'part': {r'$ref': '#/components/schemas/OutputContent'},
    },
    'required': [
      'type',
      'item_id',
      'output_index',
      'content_index',
      'part',
      'sequence_number',
    ],
  },
  'ResponseConversation': {
    'properties': {
      'id': {'type': 'string'},
    },
    'type': 'object',
    'required': ['id'],
  },
  'ResponseCustomToolCallInputDeltaEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.custom_tool_call_input.delta'],
      },
      'sequence_number': {'type': 'integer'},
      'output_index': {'type': 'integer'},
      'item_id': {'type': 'string'},
      'delta': {'type': 'string'},
    },
    'required': ['type', 'output_index', 'item_id', 'delta', 'sequence_number'],
  },
  'ResponseCustomToolCallInputDoneEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.custom_tool_call_input.done'],
      },
      'sequence_number': {'type': 'integer'},
      'output_index': {'type': 'integer'},
      'item_id': {'type': 'string'},
      'input': {'type': 'string'},
    },
    'required': ['type', 'output_index', 'item_id', 'input', 'sequence_number'],
  },
  'ResponseError': {
    'anyOf': [
      {
        'type': 'object',
        'properties': {
          'code': {r'$ref': '#/components/schemas/ResponseErrorCode'},
          'message': {'type': 'string'},
          'misalignment': {
            r'$ref': '#/components/schemas/MisalignmentErrorDetailsResource',
          },
        },
        'required': ['code', 'message'],
      },
      {'type': 'null'},
    ],
  },
  'ResponseErrorCode': {
    'type': 'string',
    'enum': [
      'server_error',
      'rate_limit_exceeded',
      'invalid_prompt',
      'data_residency_mismatch',
      'bio_policy',
      'misalignment_policy_violation',
      'vector_store_timeout',
      'invalid_image',
      'invalid_image_format',
      'invalid_base64_image',
      'invalid_image_url',
      'image_too_large',
      'image_too_small',
      'image_parse_error',
      'image_content_policy_violation',
      'invalid_image_mode',
      'image_file_too_large',
      'unsupported_image_media_type',
      'empty_image_file',
      'failed_to_download_image',
      'image_file_not_found',
    ],
  },
  'ResponseErrorEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['error'],
      },
      'code': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'message': {'type': 'string'},
      'param': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'sequence_number': {'type': 'integer'},
    },
    'required': ['type', 'code', 'message', 'param', 'sequence_number'],
  },
  'ResponseFileSearchCallCompletedEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.file_search_call.completed'],
      },
      'output_index': {'type': 'integer'},
      'item_id': {'type': 'string'},
      'sequence_number': {'type': 'integer'},
    },
    'required': ['type', 'output_index', 'item_id', 'sequence_number'],
  },
  'ResponseFileSearchCallInProgressEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.file_search_call.in_progress'],
      },
      'output_index': {'type': 'integer'},
      'item_id': {'type': 'string'},
      'sequence_number': {'type': 'integer'},
    },
    'required': ['type', 'output_index', 'item_id', 'sequence_number'],
  },
  'ResponseFileSearchCallSearchingEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.file_search_call.searching'],
      },
      'output_index': {'type': 'integer'},
      'item_id': {'type': 'string'},
      'sequence_number': {'type': 'integer'},
    },
    'required': ['type', 'output_index', 'item_id', 'sequence_number'],
  },
  'ResponseFormatJsonObject': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['json_object'],
      },
    },
    'required': ['type'],
  },
  'ResponseFormatJsonSchemaSchema': {
    'type': 'object',
    'additionalProperties': true,
  },
  'ResponseFormatText': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['text'],
      },
    },
    'required': ['type'],
  },
  'ResponseFunctionCallArgumentsDeltaEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.function_call_arguments.delta'],
      },
      'item_id': {'type': 'string'},
      'output_index': {'type': 'integer'},
      'sequence_number': {'type': 'integer'},
      'delta': {'type': 'string'},
    },
    'required': ['type', 'item_id', 'output_index', 'delta', 'sequence_number'],
  },
  'ResponseFunctionCallArgumentsDoneEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.function_call_arguments.done'],
      },
      'item_id': {'type': 'string'},
      'output_index': {'type': 'integer'},
      'sequence_number': {'type': 'integer'},
      'arguments': {'type': 'string'},
    },
    'required': [
      'type',
      'item_id',
      'output_index',
      'arguments',
      'sequence_number',
    ],
  },
  'ResponseImageGenCallCompletedEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.image_generation_call.completed'],
      },
      'output_index': {'type': 'integer'},
      'sequence_number': {'type': 'integer'},
      'item_id': {'type': 'string'},
    },
    'required': ['type', 'output_index', 'item_id', 'sequence_number'],
  },
  'ResponseImageGenCallGeneratingEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.image_generation_call.generating'],
      },
      'output_index': {'type': 'integer'},
      'item_id': {'type': 'string'},
      'sequence_number': {'type': 'integer'},
    },
    'required': ['type', 'output_index', 'item_id', 'sequence_number'],
  },
  'ResponseImageGenCallInProgressEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.image_generation_call.in_progress'],
      },
      'output_index': {'type': 'integer'},
      'item_id': {'type': 'string'},
      'sequence_number': {'type': 'integer'},
    },
    'required': ['type', 'output_index', 'item_id', 'sequence_number'],
  },
  'ResponseImageGenCallPartialImageEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.image_generation_call.partial_image'],
      },
      'output_index': {'type': 'integer'},
      'item_id': {'type': 'string'},
      'sequence_number': {'type': 'integer'},
      'partial_image_index': {'type': 'integer'},
      'partial_image_b64': {'type': 'string'},
      'size': {'type': 'string'},
      'quality': {'type': 'string'},
      'background': {'type': 'string'},
      'output_format': {'type': 'string'},
    },
    'required': [
      'type',
      'output_index',
      'item_id',
      'sequence_number',
      'partial_image_index',
      'partial_image_b64',
    ],
  },
  'ResponseLogProb': {
    'type': 'object',
    'properties': {
      'token': {'type': 'string'},
      'logprob': {'type': 'number'},
      'top_logprobs': {
        'type': 'array',
        'items': {
          'type': 'object',
          'properties': {
            'token': {'type': 'string'},
            'logprob': {'type': 'number'},
          },
        },
      },
    },
    'required': ['token', 'logprob'],
  },
  'ResponseMCPCallArgumentsDeltaEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.mcp_call_arguments.delta'],
      },
      'output_index': {'type': 'integer'},
      'item_id': {'type': 'string'},
      'delta': {'type': 'string'},
      'sequence_number': {'type': 'integer'},
    },
    'required': ['type', 'output_index', 'item_id', 'delta', 'sequence_number'],
  },
  'ResponseMCPCallArgumentsDoneEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.mcp_call_arguments.done'],
      },
      'output_index': {'type': 'integer'},
      'item_id': {'type': 'string'},
      'arguments': {'type': 'string'},
      'sequence_number': {'type': 'integer'},
    },
    'required': [
      'type',
      'output_index',
      'item_id',
      'arguments',
      'sequence_number',
    ],
  },
  'ResponseMCPCallCompletedEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.mcp_call.completed'],
      },
      'item_id': {'type': 'string'},
      'output_index': {'type': 'integer'},
      'sequence_number': {'type': 'integer'},
    },
    'required': ['type', 'item_id', 'output_index', 'sequence_number'],
  },
  'ResponseMCPCallFailedEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.mcp_call.failed'],
      },
      'item_id': {'type': 'string'},
      'output_index': {'type': 'integer'},
      'sequence_number': {'type': 'integer'},
    },
    'required': ['type', 'item_id', 'output_index', 'sequence_number'],
  },
  'ResponseMCPCallInProgressEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.mcp_call.in_progress'],
      },
      'sequence_number': {'type': 'integer'},
      'output_index': {'type': 'integer'},
      'item_id': {'type': 'string'},
    },
    'required': ['type', 'output_index', 'item_id', 'sequence_number'],
  },
  'ResponseMCPListToolsCompletedEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.mcp_list_tools.completed'],
      },
      'item_id': {'type': 'string'},
      'output_index': {'type': 'integer'},
      'sequence_number': {'type': 'integer'},
    },
    'required': ['type', 'item_id', 'output_index', 'sequence_number'],
  },
  'ResponseMCPListToolsFailedEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.mcp_list_tools.failed'],
      },
      'item_id': {'type': 'string'},
      'output_index': {'type': 'integer'},
      'sequence_number': {'type': 'integer'},
    },
    'required': ['type', 'item_id', 'output_index', 'sequence_number'],
  },
  'ResponseMCPListToolsInProgressEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.mcp_list_tools.in_progress'],
      },
      'item_id': {'type': 'string'},
      'output_index': {'type': 'integer'},
      'sequence_number': {'type': 'integer'},
    },
    'required': ['type', 'item_id', 'output_index', 'sequence_number'],
  },
  'ResponseOutputItemAddedEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.output_item.added'],
      },
      'output_index': {'type': 'integer'},
      'sequence_number': {'type': 'integer'},
      'item': {r'$ref': '#/components/schemas/OutputItem'},
    },
    'required': ['type', 'output_index', 'item', 'sequence_number'],
  },
  'ResponseOutputItemDoneEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.output_item.done'],
      },
      'output_index': {'type': 'integer'},
      'sequence_number': {'type': 'integer'},
      'item': {r'$ref': '#/components/schemas/OutputItem'},
    },
    'required': ['type', 'output_index', 'item', 'sequence_number'],
  },
  'ResponseOutputTextAnnotationAddedEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.output_text.annotation.added'],
      },
      'item_id': {'type': 'string'},
      'output_index': {'type': 'integer'},
      'content_index': {'type': 'integer'},
      'annotation_index': {'type': 'integer'},
      'sequence_number': {'type': 'integer'},
      'annotation': {
        'anyOf': [
          {r'$ref': '#/components/schemas/Annotation'},
          {'type': 'null'},
        ],
      },
    },
    'required': [
      'type',
      'item_id',
      'output_index',
      'content_index',
      'annotation_index',
      'annotation',
      'sequence_number',
    ],
  },
  'ResponsePromptVariables': {
    'anyOf': [
      {
        'type': 'object',
        'additionalProperties': {
          'oneOf': [
            {'type': 'string'},
            {r'$ref': '#/components/schemas/InputTextContent'},
            {r'$ref': '#/components/schemas/InputImageContent'},
            {r'$ref': '#/components/schemas/InputFileContent'},
          ],
        },
      },
      {'type': 'null'},
    ],
  },
  'ResponseReasoningSummaryPartAddedEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.reasoning_summary_part.added'],
      },
      'item_id': {'type': 'string'},
      'output_index': {'type': 'integer'},
      'summary_index': {'type': 'integer'},
      'sequence_number': {'type': 'integer'},
      'part': {
        'type': 'object',
        'properties': {
          'type': {
            'type': 'string',
            'enum': ['summary_text'],
          },
          'text': {'type': 'string'},
        },
        'required': ['type', 'text'],
      },
    },
    'required': [
      'type',
      'item_id',
      'output_index',
      'summary_index',
      'part',
      'sequence_number',
    ],
  },
  'ResponseReasoningSummaryPartDoneEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.reasoning_summary_part.done'],
      },
      'item_id': {'type': 'string'},
      'output_index': {'type': 'integer'},
      'summary_index': {'type': 'integer'},
      'status': {
        'type': 'string',
        'enum': ['incomplete'],
      },
      'sequence_number': {'type': 'integer'},
      'part': {
        'type': 'object',
        'properties': {
          'type': {
            'type': 'string',
            'enum': ['summary_text'],
          },
          'text': {'type': 'string'},
        },
        'required': ['type', 'text'],
      },
    },
    'required': [
      'type',
      'item_id',
      'output_index',
      'summary_index',
      'part',
      'sequence_number',
    ],
  },
  'ResponseReasoningSummaryTextDeltaEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.reasoning_summary_text.delta'],
      },
      'item_id': {'type': 'string'},
      'output_index': {'type': 'integer'},
      'summary_index': {'type': 'integer'},
      'delta': {'type': 'string'},
      'sequence_number': {'type': 'integer'},
    },
    'required': [
      'type',
      'item_id',
      'output_index',
      'summary_index',
      'delta',
      'sequence_number',
    ],
  },
  'ResponseReasoningSummaryTextDoneEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.reasoning_summary_text.done'],
      },
      'item_id': {'type': 'string'},
      'output_index': {'type': 'integer'},
      'summary_index': {'type': 'integer'},
      'text': {'type': 'string'},
      'sequence_number': {'type': 'integer'},
    },
    'required': [
      'type',
      'item_id',
      'output_index',
      'summary_index',
      'text',
      'sequence_number',
    ],
  },
  'ResponseReasoningTextDeltaEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.reasoning_text.delta'],
      },
      'item_id': {'type': 'string'},
      'output_index': {'type': 'integer'},
      'content_index': {'type': 'integer'},
      'delta': {'type': 'string'},
      'sequence_number': {'type': 'integer'},
    },
    'required': [
      'type',
      'item_id',
      'output_index',
      'content_index',
      'delta',
      'sequence_number',
    ],
  },
  'ResponseReasoningTextDoneEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.reasoning_text.done'],
      },
      'item_id': {'type': 'string'},
      'output_index': {'type': 'integer'},
      'content_index': {'type': 'integer'},
      'text': {'type': 'string'},
      'sequence_number': {'type': 'integer'},
    },
    'required': [
      'type',
      'item_id',
      'output_index',
      'content_index',
      'text',
      'sequence_number',
    ],
  },
  'ResponseRefusalDeltaEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.refusal.delta'],
      },
      'item_id': {'type': 'string'},
      'output_index': {'type': 'integer'},
      'content_index': {'type': 'integer'},
      'delta': {'type': 'string'},
      'sequence_number': {'type': 'integer'},
    },
    'required': [
      'type',
      'item_id',
      'output_index',
      'content_index',
      'delta',
      'sequence_number',
    ],
  },
  'ResponseRefusalDoneEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.refusal.done'],
      },
      'item_id': {'type': 'string'},
      'output_index': {'type': 'integer'},
      'content_index': {'type': 'integer'},
      'refusal': {'type': 'string'},
      'sequence_number': {'type': 'integer'},
    },
    'required': [
      'type',
      'item_id',
      'output_index',
      'content_index',
      'refusal',
      'sequence_number',
    ],
  },
  'ResponseShellCallCommandAddedStreamingEvent': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.shell_call_command.added'],
      },
      'sequence_number': {'type': 'integer'},
      'output_index': {'type': 'integer'},
      'command_index': {'type': 'integer'},
      'command': {'type': 'string'},
    },
    'type': 'object',
    'required': [
      'type',
      'sequence_number',
      'output_index',
      'command_index',
      'command',
    ],
  },
  'ResponseShellCallCommandDeltaStreamingEvent': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.shell_call_command.delta'],
      },
      'sequence_number': {'type': 'integer'},
      'output_index': {'type': 'integer'},
      'command_index': {'type': 'integer'},
      'delta': {'type': 'string'},
      'obfuscation': {'type': 'string'},
    },
    'type': 'object',
    'required': [
      'type',
      'sequence_number',
      'output_index',
      'command_index',
      'delta',
    ],
  },
  'ResponseShellCallCommandDoneStreamingEvent': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.shell_call_command.done'],
      },
      'sequence_number': {'type': 'integer'},
      'output_index': {'type': 'integer'},
      'command_index': {'type': 'integer'},
      'command': {'type': 'string'},
    },
    'type': 'object',
    'required': [
      'type',
      'sequence_number',
      'output_index',
      'command_index',
      'command',
    ],
  },
  'ResponseShellCallOutputContentDeltaStreamingEvent': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.shell_call_output_content.delta'],
      },
      'sequence_number': {'type': 'integer'},
      'item_id': {'type': 'string'},
      'output_index': {'type': 'integer'},
      'command_index': {'type': 'integer'},
      'delta': {r'$ref': '#/components/schemas/ShellCallOutputDelta'},
    },
    'type': 'object',
    'required': [
      'type',
      'sequence_number',
      'item_id',
      'output_index',
      'command_index',
      'delta',
    ],
  },
  'ResponseShellCallOutputContentDoneStreamingEvent': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.shell_call_output_content.done'],
      },
      'sequence_number': {'type': 'integer'},
      'item_id': {'type': 'string'},
      'output_index': {'type': 'integer'},
      'command_index': {'type': 'integer'},
      'output': {
        'items': {
          r'$ref': '#/components/schemas/FunctionShellCallOutputContent',
        },
        'type': 'array',
      },
    },
    'type': 'object',
    'required': [
      'type',
      'sequence_number',
      'item_id',
      'output_index',
      'command_index',
      'output',
    ],
  },
  'ResponseTextDeltaEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.output_text.delta'],
      },
      'item_id': {'type': 'string'},
      'output_index': {'type': 'integer'},
      'content_index': {'type': 'integer'},
      'delta': {'type': 'string'},
      'sequence_number': {'type': 'integer'},
      'logprobs': {
        'type': 'array',
        'items': {r'$ref': '#/components/schemas/ResponseLogProb'},
      },
    },
    'required': [
      'type',
      'item_id',
      'output_index',
      'content_index',
      'delta',
      'sequence_number',
      'logprobs',
    ],
  },
  'ResponseTextDoneEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.output_text.done'],
      },
      'item_id': {'type': 'string'},
      'output_index': {'type': 'integer'},
      'content_index': {'type': 'integer'},
      'text': {'type': 'string'},
      'sequence_number': {'type': 'integer'},
      'logprobs': {
        'type': 'array',
        'items': {r'$ref': '#/components/schemas/ResponseLogProb'},
      },
    },
    'required': [
      'type',
      'item_id',
      'output_index',
      'content_index',
      'text',
      'sequence_number',
      'logprobs',
    ],
  },
  'ResponseTextParam': {
    'type': 'object',
    'properties': {
      'format': {
        r'$ref': '#/components/schemas/TextResponseFormatConfiguration',
      },
      'verbosity': {r'$ref': '#/components/schemas/Verbosity'},
    },
  },
  'ResponseUsage': {
    'type': 'object',
    'properties': {
      'input_tokens': {'type': 'integer'},
      'input_tokens_details': {
        'type': 'object',
        'properties': {
          'cached_tokens': {'type': 'integer'},
          'cache_write_tokens': {'type': 'integer'},
        },
        'required': ['cached_tokens', 'cache_write_tokens'],
      },
      'output_tokens': {'type': 'integer'},
      'output_tokens_details': {
        'type': 'object',
        'properties': {
          'reasoning_tokens': {'type': 'integer'},
        },
        'required': ['reasoning_tokens'],
      },
      'total_tokens': {'type': 'integer'},
    },
    'required': [
      'input_tokens',
      'input_tokens_details',
      'output_tokens',
      'output_tokens_details',
      'total_tokens',
    ],
  },
  'ResponseWebSearchCallCompletedEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.web_search_call.completed'],
      },
      'output_index': {'type': 'integer'},
      'item_id': {'type': 'string'},
      'sequence_number': {'type': 'integer'},
    },
    'required': ['type', 'output_index', 'item_id', 'sequence_number'],
  },
  'ResponseWebSearchCallInProgressEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.web_search_call.in_progress'],
      },
      'output_index': {'type': 'integer'},
      'item_id': {'type': 'string'},
      'sequence_number': {'type': 'integer'},
    },
    'required': ['type', 'output_index', 'item_id', 'sequence_number'],
  },
  'ResponseWebSearchCallSearchingEvent': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['response.web_search_call.searching'],
      },
      'output_index': {'type': 'integer'},
      'item_id': {'type': 'string'},
      'sequence_number': {'type': 'integer'},
    },
    'required': ['type', 'output_index', 'item_id', 'sequence_number'],
  },
  'ScreenshotParam': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['screenshot'],
      },
    },
    'type': 'object',
    'required': ['type'],
  },
  'ScrollParam': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['scroll'],
      },
      'x': {'type': 'integer'},
      'y': {'type': 'integer'},
      'scroll_x': {'type': 'integer'},
      'scroll_y': {'type': 'integer'},
      'keys': {
        'anyOf': [
          {
            'items': {'type': 'string'},
            'type': 'array',
          },
          {'type': 'null'},
        ],
      },
    },
    'type': 'object',
    'required': ['type', 'x', 'y', 'scroll_x', 'scroll_y'],
  },
  'SearchContentType': {
    'type': 'string',
    'enum': ['text', 'image'],
  },
  'SearchContextSize': {
    'type': 'string',
    'enum': ['low', 'medium', 'high'],
  },
  'ServiceTierResponses': {
    'anyOf': [
      {
        'type': 'string',
        'enum': [
          'auto',
          'default',
          'flex',
          'scale',
          'priority',
          'fast',
          'ultrafast',
        ],
      },
      {'type': 'null'},
    ],
  },
  'ShellCallOutputDelta': {
    'properties': {
      'stdout': {'type': 'string'},
      'stderr': {'type': 'string'},
    },
    'type': 'object',
    'required': <dynamic>[],
  },
  'SkillReferenceParam': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['skill_reference'],
      },
      'skill_id': {'type': 'string', 'maxLength': 64, 'minLength': 1},
      'version': {'type': 'string'},
    },
    'type': 'object',
    'required': ['type', 'skill_id'],
  },
  'SpecificApplyPatchParam': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['apply_patch'],
      },
    },
    'type': 'object',
    'required': ['type'],
  },
  'SpecificFunctionShellParam': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['shell'],
      },
    },
    'type': 'object',
    'required': ['type'],
  },
  'SpecificProgrammaticToolCallingParam': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['programmatic_tool_calling'],
      },
    },
    'type': 'object',
    'required': ['type'],
  },
  'SummaryTextContent': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['summary_text'],
      },
      'text': {'type': 'string'},
    },
    'type': 'object',
    'required': ['type', 'text'],
  },
  'TextResponseFormatConfiguration': {
    'oneOf': [
      {r'$ref': '#/components/schemas/ResponseFormatText'},
      {r'$ref': '#/components/schemas/TextResponseFormatJsonSchema'},
      {r'$ref': '#/components/schemas/ResponseFormatJsonObject'},
    ],
  },
  'TextResponseFormatJsonSchema': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['json_schema'],
      },
      'description': {'type': 'string'},
      'name': {'type': 'string'},
      'schema': {
        r'$ref': '#/components/schemas/ResponseFormatJsonSchemaSchema',
      },
      'strict': {
        'anyOf': [
          {'type': 'boolean'},
          {'type': 'null'},
        ],
      },
    },
    'required': ['type', 'schema', 'name'],
  },
  'Tool': {
    'oneOf': [
      {r'$ref': '#/components/schemas/FunctionTool'},
      {r'$ref': '#/components/schemas/FileSearchTool'},
      {r'$ref': '#/components/schemas/ComputerTool'},
      {r'$ref': '#/components/schemas/ComputerUsePreviewTool'},
      {r'$ref': '#/components/schemas/WebSearchTool'},
      {r'$ref': '#/components/schemas/MCPTool'},
      {r'$ref': '#/components/schemas/CodeInterpreterTool'},
      {r'$ref': '#/components/schemas/ProgrammaticToolCallingParam'},
      {r'$ref': '#/components/schemas/ImageGenTool'},
      {r'$ref': '#/components/schemas/LocalShellToolParam'},
      {r'$ref': '#/components/schemas/FunctionShellToolParam'},
      {r'$ref': '#/components/schemas/CustomToolParam'},
      {r'$ref': '#/components/schemas/NamespaceToolParam'},
      {r'$ref': '#/components/schemas/ToolSearchToolParam'},
      {r'$ref': '#/components/schemas/WebSearchPreviewTool'},
      {r'$ref': '#/components/schemas/ApplyPatchToolParam'},
    ],
  },
  'ToolCallCaller': {
    'oneOf': [
      {r'$ref': '#/components/schemas/DirectToolCallCaller'},
      {r'$ref': '#/components/schemas/ProgramToolCallCaller'},
    ],
  },
  'ToolCallCallerParam': {
    'oneOf': [
      {r'$ref': '#/components/schemas/DirectToolCallCallerParam'},
      {r'$ref': '#/components/schemas/ProgramToolCallCallerParam'},
    ],
  },
  'ToolChoiceAllowed': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['allowed_tools'],
      },
      'mode': {
        'type': 'string',
        'enum': ['auto', 'required'],
      },
      'tools': {
        'type': 'array',
        'items': {'type': 'object', 'additionalProperties': true},
      },
    },
    'required': ['type', 'mode', 'tools'],
  },
  'ToolChoiceCustom': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['custom'],
      },
      'name': {'type': 'string'},
    },
    'required': ['type', 'name'],
  },
  'ToolChoiceFunction': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['function'],
      },
      'name': {'type': 'string'},
    },
    'required': ['type', 'name'],
  },
  'ToolChoiceMCP': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['mcp'],
      },
      'server_label': {'type': 'string'},
      'name': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
    },
    'required': ['type', 'server_label'],
  },
  'ToolChoiceOptions': {
    'type': 'string',
    'enum': ['none', 'auto', 'required'],
  },
  'ToolChoiceParam': {
    'oneOf': [
      {r'$ref': '#/components/schemas/ToolChoiceOptions'},
      {r'$ref': '#/components/schemas/ToolChoiceAllowed'},
      {r'$ref': '#/components/schemas/ToolChoiceTypes'},
      {r'$ref': '#/components/schemas/ToolChoiceFunction'},
      {r'$ref': '#/components/schemas/ToolChoiceMCP'},
      {r'$ref': '#/components/schemas/ToolChoiceCustom'},
      {r'$ref': '#/components/schemas/SpecificProgrammaticToolCallingParam'},
      {r'$ref': '#/components/schemas/SpecificApplyPatchParam'},
      {r'$ref': '#/components/schemas/SpecificFunctionShellParam'},
    ],
  },
  'ToolChoiceTypes': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': [
          'file_search',
          'web_search_preview',
          'computer',
          'computer_use_preview',
          'computer_use',
          'web_search_preview_2025_03_11',
          'image_generation',
          'code_interpreter',
        ],
      },
    },
    'required': ['type'],
  },
  'ToolSearchCall': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['tool_search_call'],
      },
      'id': {'type': 'string'},
      'call_id': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'execution': {r'$ref': '#/components/schemas/ToolSearchExecutionType'},
      'arguments': <String, dynamic>{},
      'status': {r'$ref': '#/components/schemas/FunctionCallStatus'},
      'created_by': {'type': 'string'},
    },
    'type': 'object',
    'required': ['type', 'id', 'call_id', 'execution', 'arguments', 'status'],
  },
  'ToolSearchCallItemParam': {
    'properties': {
      'id': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'call_id': {
        'anyOf': [
          {'type': 'string', 'maxLength': 64, 'minLength': 1},
          {'type': 'null'},
        ],
      },
      'type': {
        'type': 'string',
        'enum': ['tool_search_call'],
      },
      'execution': {r'$ref': '#/components/schemas/ToolSearchExecutionType'},
      'arguments': {r'$ref': '#/components/schemas/EmptyModelParam'},
      'status': {
        'anyOf': [
          {r'$ref': '#/components/schemas/FunctionCallItemStatus'},
          {'type': 'null'},
        ],
      },
    },
    'type': 'object',
    'required': ['type', 'arguments'],
  },
  'ToolSearchExecutionType': {
    'type': 'string',
    'enum': ['server', 'client'],
  },
  'ToolSearchOutput': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['tool_search_output'],
      },
      'id': {'type': 'string'},
      'call_id': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'execution': {r'$ref': '#/components/schemas/ToolSearchExecutionType'},
      'tools': {
        'items': {r'$ref': '#/components/schemas/Tool'},
        'type': 'array',
      },
      'status': {r'$ref': '#/components/schemas/FunctionCallOutputStatusEnum'},
      'created_by': {'type': 'string'},
    },
    'type': 'object',
    'required': ['type', 'id', 'call_id', 'execution', 'tools', 'status'],
  },
  'ToolSearchOutputFunctionToolParam': {
    'properties': {
      'name': {
        'type': 'string',
        'maxLength': 128,
        'minLength': 1,
        'pattern': r'^(?![\s\S]*[\r\n])[a-zA-Z0-9_.-]+$',
      },
      'description': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'parameters': {
        'anyOf': [
          {r'$ref': '#/components/schemas/EmptyModelParam'},
          {'type': 'null'},
        ],
      },
      'strict': {
        'anyOf': [
          {'type': 'boolean'},
          {'type': 'null'},
        ],
      },
      'type': {
        'type': 'string',
        'enum': ['function'],
      },
      'async': {'type': 'boolean'},
      'output_schema': {
        'anyOf': [
          {'additionalProperties': <String, dynamic>{}, 'type': 'object'},
          {'type': 'null'},
        ],
      },
      'defer_loading': {'type': 'boolean'},
      'allowed_callers': {
        'anyOf': [
          {
            'items': {
              r'$ref': '#/components/schemas/CallableToolAllowedCaller',
            },
            'type': 'array',
            'minItems': 1,
          },
          {'type': 'null'},
        ],
      },
    },
    'type': 'object',
    'required': ['name', 'type'],
  },
  'ToolSearchOutputItemParam': {
    'properties': {
      'id': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'call_id': {
        'anyOf': [
          {'type': 'string', 'maxLength': 64, 'minLength': 1},
          {'type': 'null'},
        ],
      },
      'type': {
        'type': 'string',
        'enum': ['tool_search_output'],
      },
      'execution': {r'$ref': '#/components/schemas/ToolSearchExecutionType'},
      'tools': {
        'items': {r'$ref': '#/components/schemas/ToolSearchOutputTool'},
        'type': 'array',
      },
      'status': {
        'anyOf': [
          {r'$ref': '#/components/schemas/FunctionCallItemStatus'},
          {'type': 'null'},
        ],
      },
    },
    'type': 'object',
    'required': ['type', 'tools'],
  },
  'ToolSearchOutputNamespaceToolParam': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['namespace'],
      },
      'name': {'type': 'string', 'minLength': 1},
      'description': {'type': 'string'},
      'tools': {
        'items': {
          'oneOf': [
            {r'$ref': '#/components/schemas/ToolSearchOutputFunctionToolParam'},
            {r'$ref': '#/components/schemas/CustomToolParam'},
          ],
        },
        'type': 'array',
        'minItems': 1,
      },
    },
    'type': 'object',
    'required': ['type', 'name', 'description', 'tools'],
  },
  'ToolSearchOutputTool': {
    'oneOf': [
      {r'$ref': '#/components/schemas/FunctionTool'},
      {r'$ref': '#/components/schemas/FileSearchTool'},
      {r'$ref': '#/components/schemas/ComputerTool'},
      {r'$ref': '#/components/schemas/ComputerUsePreviewTool'},
      {r'$ref': '#/components/schemas/WebSearchTool'},
      {r'$ref': '#/components/schemas/MCPTool'},
      {r'$ref': '#/components/schemas/CodeInterpreterTool'},
      {r'$ref': '#/components/schemas/ProgrammaticToolCallingParam'},
      {r'$ref': '#/components/schemas/ImageGenTool'},
      {r'$ref': '#/components/schemas/LocalShellToolParam'},
      {r'$ref': '#/components/schemas/FunctionShellToolParam'},
      {r'$ref': '#/components/schemas/CustomToolParam'},
      {r'$ref': '#/components/schemas/ToolSearchOutputNamespaceToolParam'},
      {r'$ref': '#/components/schemas/ToolSearchToolParam'},
      {r'$ref': '#/components/schemas/WebSearchPreviewTool'},
      {r'$ref': '#/components/schemas/ApplyPatchToolParam'},
    ],
  },
  'ToolSearchToolParam': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['tool_search'],
      },
      'execution': {r'$ref': '#/components/schemas/ToolSearchExecutionType'},
      'description': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'parameters': {
        'anyOf': [
          {r'$ref': '#/components/schemas/EmptyModelParam'},
          {'type': 'null'},
        ],
      },
    },
    'type': 'object',
    'required': ['type'],
  },
  'ToolsArray': {
    'type': 'array',
    'items': {r'$ref': '#/components/schemas/Tool'},
  },
  'TopLogProb': {
    'properties': {
      'token': {'type': 'string'},
      'logprob': {'type': 'number'},
      'bytes': {
        'items': {'type': 'integer'},
        'type': 'array',
      },
    },
    'type': 'object',
    'required': ['token', 'logprob', 'bytes'],
  },
  'TypeParam': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['type'],
      },
      'text': {'type': 'string'},
    },
    'type': 'object',
    'required': ['type', 'text'],
  },
  'UrlCitationBody': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['url_citation'],
      },
      'url': {'type': 'string'},
      'start_index': {'type': 'integer'},
      'end_index': {'type': 'integer'},
      'title': {'type': 'string'},
    },
    'type': 'object',
    'required': ['type', 'url', 'start_index', 'end_index', 'title'],
  },
  'VectorStoreFileAttributes': {
    'anyOf': [
      {
        'type': 'object',
        'maxProperties': 16,
        'propertyNames': {'type': 'string', 'maxLength': 64},
        'additionalProperties': {
          'oneOf': [
            {'type': 'string', 'maxLength': 512},
            {'type': 'number'},
            {'type': 'boolean'},
          ],
        },
      },
      {'type': 'null'},
    ],
  },
  'Verbosity': {
    'anyOf': [
      {
        'type': 'string',
        'enum': ['low', 'medium', 'high'],
      },
      {'type': 'null'},
    ],
  },
  'WaitParam': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['wait'],
      },
    },
    'type': 'object',
    'required': ['type'],
  },
  'WebSearchActionFind': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['find_in_page'],
      },
      'url': {'type': 'string'},
      'pattern': {'type': 'string'},
    },
    'required': ['type', 'url', 'pattern'],
  },
  'WebSearchActionOpenPage': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['open_page'],
      },
      'url': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
    },
    'required': ['type'],
  },
  'WebSearchActionSearch': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['search'],
      },
      'query': {'type': 'string'},
      'queries': {
        'type': 'array',
        'items': {'type': 'string'},
      },
      'sources': {
        'type': 'array',
        'items': {
          'type': 'object',
          'properties': {
            'type': {
              'type': 'string',
              'enum': ['url'],
            },
            'url': {'type': 'string'},
          },
          'required': ['type', 'url'],
        },
      },
    },
    'required': ['type'],
  },
  'WebSearchApproximateLocation': {
    'anyOf': [
      {
        'type': 'object',
        'properties': {
          'type': {
            'type': 'string',
            'enum': ['approximate'],
          },
          'country': {
            'anyOf': [
              {'type': 'string'},
              {'type': 'null'},
            ],
          },
          'region': {
            'anyOf': [
              {'type': 'string'},
              {'type': 'null'},
            ],
          },
          'city': {
            'anyOf': [
              {'type': 'string'},
              {'type': 'null'},
            ],
          },
          'timezone': {
            'anyOf': [
              {'type': 'string'},
              {'type': 'null'},
            ],
          },
        },
      },
      {'type': 'null'},
    ],
  },
  'WebSearchCallStatus': {
    'type': 'string',
    'enum': ['in_progress', 'searching', 'completed', 'failed', 'incomplete'],
  },
  'WebSearchPreviewTool': {
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['web_search_preview', 'web_search_preview_2025_03_11'],
      },
      'user_location': {
        'anyOf': [
          {r'$ref': '#/components/schemas/ApproximateLocation'},
          {'type': 'null'},
        ],
      },
      'search_context_size': {
        r'$ref': '#/components/schemas/SearchContextSize',
      },
      'search_content_types': {
        'items': {r'$ref': '#/components/schemas/SearchContentType'},
        'type': 'array',
      },
    },
    'type': 'object',
    'required': ['type'],
  },
  'WebSearchTool': {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['web_search', 'web_search_2025_08_26'],
      },
      'external_web_access': {'type': 'boolean'},
      'filters': {
        'anyOf': [
          {
            'type': 'object',
            'properties': {
              'allowed_domains': {
                'anyOf': [
                  {
                    'type': 'array',
                    'items': {'type': 'string'},
                  },
                  {'type': 'null'},
                ],
              },
            },
          },
          {'type': 'null'},
        ],
      },
      'user_location': {
        r'$ref': '#/components/schemas/WebSearchApproximateLocation',
      },
      'search_context_size': {
        'type': 'string',
        'enum': ['low', 'medium', 'high'],
      },
    },
    'required': ['type'],
  },
  'WebSearchToolCall': {
    'type': 'object',
    'properties': {
      'id': {'type': 'string'},
      'type': {
        'type': 'string',
        'enum': ['web_search_call'],
      },
      'status': {r'$ref': '#/components/schemas/WebSearchCallStatus'},
      'action': {
        'type': 'object',
        'oneOf': [
          {r'$ref': '#/components/schemas/WebSearchActionSearch'},
          {r'$ref': '#/components/schemas/WebSearchActionOpenPage'},
          {r'$ref': '#/components/schemas/WebSearchActionFind'},
        ],
      },
    },
    'required': ['id', 'type', 'status'],
  },
  '_MisalignmentErrorType': {
    'anyOf': [
      {'type': 'string'},
      {
        'type': 'string',
        'enum': [
          'potentially_unintended_data_transfer',
          'potentially_unintended_data_access',
          'potentially_unintended_destructive_activity',
          'other',
        ],
      },
    ],
  },
  '_MisalignmentSteer': {
    'properties': {
      'message': {'type': 'string'},
    },
    'type': 'object',
    'required': ['message'],
  },
};

const Set<String> _ordinaryOutputItemTypes = {
  'message',
  'function_call',
  'reasoning',
  'compaction',
  'web_search_call',
  'file_search_call',
  'code_interpreter_call',
  'image_generation_call',
  'local_shell_call',
  'local_shell_call_output',
  'shell_call',
  'shell_call_output',
  'mcp_call',
  'tool_search_call',
  'tool_search_output',
  'computer_call',
  'custom_tool_call',
  'custom_tool_call_output',
  'additional_tools',
  'program',
  'program_output',
  'agent_message',
  'multi_agent_call',
  'multi_agent_call_output',
};
