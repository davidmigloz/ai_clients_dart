import 'package:meta/meta.dart';

import '../../utils/additional_json_fields.dart';
import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'response_content.dart';
import 'response_item.dart';
import 'response_tool.dart';

/// Requests a stateless response using text or caller-supplied history.
@immutable
class CreateResponseRequest {
  /// Creates a [CreateResponseRequest].
  const CreateResponseRequest({
    required this.input,
    this.instructions,
    this.maxOutputTokens,
    this.maxToolCalls,
    this.metadata,
    required this.model,
    this.parallelToolCalls,
    this.promptCacheKey,
    this.reasoning,
    this.stream,
    this.temperature,
    this.text,
    this.toolChoice,
    this.tools,
    this.topP,
    this.extra,
  });

  /// Mistral Responses runs in the foreground.
  bool get background => false;

  /// Mistral uses the supplied input with truncation disabled.
  String get truncation => 'disabled';

  /// Text or ordered history, including tool results and prior output items.
  final ResponseInput input;

  /// System instructions for this request.
  final String? instructions;

  /// Maximum number of output tokens, including reasoning tokens.
  final int? maxOutputTokens;

  /// Maximum number of tool calls the model may make.
  final int? maxToolCalls;

  /// Optional labels attached to this response.
  final Map<String, String>? metadata;

  /// The Mistral model ID.
  final String model;

  /// Whether the model may issue calls in parallel.
  final bool? parallelToolCalls;

  /// A cache key used for matching shared prompt prefixes.
  final String? promptCacheKey;

  /// Reasoning effort for supported models.
  final ResponseReasoning? reasoning;

  /// Desired wire mode. The resource method selects JSON or SSE.
  final bool? stream;

  /// Sampling temperature.
  final double? temperature;

  /// Text verbosity and structured output format.
  final ResponseTextConfig? text;

  /// Tool selection policy or a named function.
  final ResponseToolChoice? toolChoice;

  /// Client-executed function tools and namespaces.
  final List<ResponseTool>? tools;

  /// Nucleus sampling probability.
  final double? topP;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [CreateResponseRequest] from JSON.
  factory CreateResponseRequest.fromJson(Map<String, dynamic> json) {
    if (json['background'] case final value? when value != false) {
      throw FormatException(
        'CreateResponseRequest: unexpected background $value',
      );
    }
    if (json['truncation'] case final value? when value != 'disabled') {
      throw FormatException(
        'CreateResponseRequest: unexpected truncation $value',
      );
    }
    if (json['input'] == null) {
      throw const FormatException('CreateResponseRequest: missing input');
    }
    if (json['model'] == null) {
      throw const FormatException('CreateResponseRequest: missing model');
    }
    return CreateResponseRequest(
      input: ResponseInput.fromJson(json['input'] as Object),
      instructions: json['instructions'] == null
          ? null
          : json['instructions'] as String,
      maxOutputTokens: json['max_output_tokens'] == null
          ? null
          : json['max_output_tokens'] as int,
      maxToolCalls: json['max_tool_calls'] == null
          ? null
          : json['max_tool_calls'] as int,
      metadata: json['metadata'] == null
          ? null
          : (json['metadata'] as Map<String, dynamic>).map(
              (key, item) => MapEntry(key, item as String),
            ),
      model: json['model'] as String,
      parallelToolCalls: json['parallel_tool_calls'] == null
          ? null
          : json['parallel_tool_calls'] as bool,
      promptCacheKey: json['prompt_cache_key'] == null
          ? null
          : json['prompt_cache_key'] as String,
      reasoning: json['reasoning'] == null
          ? null
          : ResponseReasoning.fromJson(
              json['reasoning'] as Map<String, dynamic>,
            ),
      stream: json['stream'] == null ? null : json['stream'] as bool,
      temperature: json['temperature'] == null
          ? null
          : (json['temperature'] as num).toDouble(),
      text: json['text'] == null
          ? null
          : ResponseTextConfig.fromJson(json['text'] as Map<String, dynamic>),
      toolChoice: json['tool_choice'] == null
          ? null
          : ResponseToolChoice.fromJson(json['tool_choice'] as Object),
      tools: json['tools'] == null
          ? null
          : (json['tools'] as List)
                .map(
                  (item) => ResponseTool.fromJson(item as Map<String, dynamic>),
                )
                .toList(),
      topP: json['top_p'] == null ? null : (json['top_p'] as num).toDouble(),
      extra: additionalJsonFields(json, const {
        'input',
        'instructions',
        'max_output_tokens',
        'max_tool_calls',
        'metadata',
        'model',
        'parallel_tool_calls',
        'prompt_cache_key',
        'reasoning',
        'stream',
        'temperature',
        'text',
        'tool_choice',
        'tools',
        'top_p',
        'background',
        'truncation',
      }),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    ...?extra,
    'background': background,
    'truncation': truncation,
    'input': input.toJson(),
    'instructions': ?instructions,
    'max_output_tokens': ?maxOutputTokens,
    'max_tool_calls': ?maxToolCalls,
    'metadata': ?metadata,
    'model': model,
    'parallel_tool_calls': ?parallelToolCalls,
    'prompt_cache_key': ?promptCacheKey,
    if (reasoning != null) 'reasoning': reasoning!.toJson(),
    'stream': ?stream,
    'temperature': ?temperature,
    if (text != null) 'text': text!.toJson(),
    if (toolChoice != null) 'tool_choice': toolChoice!.toJson(),
    if (tools != null) 'tools': tools!.map((item) => item.toJson()).toList(),
    'top_p': ?topP,
  };

  /// Creates a copy with the given fields replaced.
  CreateResponseRequest copyWith({
    ResponseInput? input,
    Object? instructions = unsetCopyWithValue,
    Object? maxOutputTokens = unsetCopyWithValue,
    Object? maxToolCalls = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
    String? model,
    Object? parallelToolCalls = unsetCopyWithValue,
    Object? promptCacheKey = unsetCopyWithValue,
    Object? reasoning = unsetCopyWithValue,
    Object? stream = unsetCopyWithValue,
    Object? temperature = unsetCopyWithValue,
    Object? text = unsetCopyWithValue,
    Object? toolChoice = unsetCopyWithValue,
    Object? tools = unsetCopyWithValue,
    Object? topP = unsetCopyWithValue,
    Object? extra = unsetCopyWithValue,
  }) => CreateResponseRequest(
    input: input ?? this.input,
    instructions: instructions == unsetCopyWithValue
        ? this.instructions
        : instructions as String?,
    maxOutputTokens: maxOutputTokens == unsetCopyWithValue
        ? this.maxOutputTokens
        : maxOutputTokens as int?,
    maxToolCalls: maxToolCalls == unsetCopyWithValue
        ? this.maxToolCalls
        : maxToolCalls as int?,
    metadata: metadata == unsetCopyWithValue
        ? this.metadata
        : (metadata as Map?)?.cast<String, String>(),
    model: model ?? this.model,
    parallelToolCalls: parallelToolCalls == unsetCopyWithValue
        ? this.parallelToolCalls
        : parallelToolCalls as bool?,
    promptCacheKey: promptCacheKey == unsetCopyWithValue
        ? this.promptCacheKey
        : promptCacheKey as String?,
    reasoning: reasoning == unsetCopyWithValue
        ? this.reasoning
        : reasoning as ResponseReasoning?,
    stream: stream == unsetCopyWithValue ? this.stream : stream as bool?,
    temperature: temperature == unsetCopyWithValue
        ? this.temperature
        : (temperature as num?)?.toDouble(),
    text: text == unsetCopyWithValue ? this.text : text as ResponseTextConfig?,
    toolChoice: toolChoice == unsetCopyWithValue
        ? this.toolChoice
        : toolChoice as ResponseToolChoice?,
    tools: tools == unsetCopyWithValue
        ? this.tools
        : (tools as List?)?.cast<ResponseTool>(),
    topP: topP == unsetCopyWithValue ? this.topP : (topP as num?)?.toDouble(),
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateResponseRequest &&
          runtimeType == other.runtimeType &&
          input == other.input &&
          instructions == other.instructions &&
          maxOutputTokens == other.maxOutputTokens &&
          maxToolCalls == other.maxToolCalls &&
          valuesDeepEqual(metadata, other.metadata) &&
          model == other.model &&
          parallelToolCalls == other.parallelToolCalls &&
          promptCacheKey == other.promptCacheKey &&
          reasoning == other.reasoning &&
          stream == other.stream &&
          temperature == other.temperature &&
          text == other.text &&
          toolChoice == other.toolChoice &&
          valuesDeepEqual(tools, other.tools) &&
          topP == other.topP &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([
    input,
    instructions,
    maxOutputTokens,
    maxToolCalls,
    valueDeepHashCode(metadata),
    model,
    parallelToolCalls,
    promptCacheKey,
    reasoning,
    stream,
    temperature,
    text,
    toolChoice,
    valueDeepHashCode(tools),
    topP,
    valueDeepHashCode(extra),
  ]);

  @override
  String toString() =>
      'CreateResponseRequest('
      'input: $input, '
      'instructions: $instructions, '
      'maxOutputTokens: $maxOutputTokens, '
      'maxToolCalls: $maxToolCalls, '
      'metadata: ${metadata?.length}, '
      'model: $model, '
      'parallelToolCalls: $parallelToolCalls, '
      'promptCacheKey: $promptCacheKey, '
      'reasoning: $reasoning, '
      'stream: $stream, '
      'temperature: $temperature, '
      'text: $text, '
      'toolChoice: $toolChoice, '
      'tools: ${tools?.length}, '
      'topP: $topP, '
      'extra: ${extra?.length})';
}

/// A completed or in-progress result returned by Mistral Responses.
@immutable
class MistralResponse {
  /// Creates a [MistralResponse].
  const MistralResponse({
    this.background,
    this.completedAt,
    required this.createdAt,
    this.error,
    required this.id,
    this.incompleteDetails,
    this.instructions,
    this.maxOutputTokens,
    this.maxToolCalls,
    this.metadata,
    required this.model,
    required this.output,
    required this.parallelToolCalls,
    this.previousResponseId,
    this.promptCacheKey,
    this.promptCacheRetention,
    this.reasoning,
    this.safetyIdentifier,
    this.serviceTier,
    this.status,
    this.temperature,
    this.text,
    required this.toolChoice,
    required this.tools,
    this.topLogprobs,
    this.topP,
    this.truncation,
    this.usage,
    this.user,
    this.extra,
  });

  /// The fixed object discriminator.
  String get object => 'response';

  /// The background field.
  final bool? background;

  /// The completed_at field.
  final double? completedAt;

  /// The created_at field.
  final double createdAt;

  /// The error field.
  final ResponseError? error;

  /// The id field.
  final String id;

  /// The incomplete_details field.
  final ResponseIncompleteDetails? incompleteDetails;

  /// The instructions field.
  final String? instructions;

  /// The max_output_tokens field.
  final int? maxOutputTokens;

  /// The max_tool_calls field.
  final int? maxToolCalls;

  /// The metadata field.
  final Map<String, String>? metadata;

  /// The model field.
  final String model;

  /// The output field.
  final List<ResponseOutputItem> output;

  /// Joins generated text in output order, excluding reasoning and refusals.
  String get outputText => output
      .whereType<ResponseOutputMessage>()
      .expand((item) => item.content)
      .whereType<ResponseOutputText>()
      .map((part) => part.text)
      .join();

  /// The parallel_tool_calls field.
  final bool parallelToolCalls;

  /// The previous_response_id field.
  final String? previousResponseId;

  /// The prompt_cache_key field.
  final String? promptCacheKey;

  /// The prompt_cache_retention field.
  final String? promptCacheRetention;

  /// The reasoning field.
  final ResponseReasoning? reasoning;

  /// The safety_identifier field.
  final String? safetyIdentifier;

  /// The service_tier field.
  final String? serviceTier;

  /// The status field.
  final String? status;

  /// The temperature field.
  final double? temperature;

  /// The text field.
  final ResponseTextConfig? text;

  /// The tool_choice field.
  final ResponseToolChoice toolChoice;

  /// The tools field.
  final List<ResponseTool> tools;

  /// The top_logprobs field.
  final int? topLogprobs;

  /// The top_p field.
  final double? topP;

  /// The truncation field.
  final String? truncation;

  /// The usage field.
  final ResponseUsage? usage;

  /// The user field.
  final String? user;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [MistralResponse] from JSON.
  factory MistralResponse.fromJson(Map<String, dynamic> json) {
    if (json['object'] case final value? when value != 'response') {
      throw FormatException('MistralResponse: unexpected object $value');
    }
    if (json['created_at'] == null) {
      throw const FormatException('MistralResponse: missing created_at');
    }
    if (json['id'] == null) {
      throw const FormatException('MistralResponse: missing id');
    }
    if (json['model'] == null) {
      throw const FormatException('MistralResponse: missing model');
    }
    if (json['output'] == null) {
      throw const FormatException('MistralResponse: missing output');
    }
    if (json['parallel_tool_calls'] == null) {
      throw const FormatException(
        'MistralResponse: missing parallel_tool_calls',
      );
    }
    if (json['tool_choice'] == null) {
      throw const FormatException('MistralResponse: missing tool_choice');
    }
    if (json['tools'] == null) {
      throw const FormatException('MistralResponse: missing tools');
    }
    return MistralResponse(
      background: json['background'] == null
          ? null
          : json['background'] as bool,
      completedAt: json['completed_at'] == null
          ? null
          : (json['completed_at'] as num).toDouble(),
      createdAt: (json['created_at'] as num).toDouble(),
      error: json['error'] == null
          ? null
          : ResponseError.fromJson(json['error'] as Map<String, dynamic>),
      id: json['id'] as String,
      incompleteDetails: json['incomplete_details'] == null
          ? null
          : ResponseIncompleteDetails.fromJson(
              json['incomplete_details'] as Map<String, dynamic>,
            ),
      instructions: json['instructions'] == null
          ? null
          : json['instructions'] as String,
      maxOutputTokens: json['max_output_tokens'] == null
          ? null
          : json['max_output_tokens'] as int,
      maxToolCalls: json['max_tool_calls'] == null
          ? null
          : json['max_tool_calls'] as int,
      metadata: json['metadata'] == null
          ? null
          : (json['metadata'] as Map<String, dynamic>).map(
              (key, item) => MapEntry(key, item as String),
            ),
      model: json['model'] as String,
      output: (json['output'] as List)
          .map(
            (item) => ResponseOutputItem.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      parallelToolCalls: json['parallel_tool_calls'] as bool,
      previousResponseId: json['previous_response_id'] == null
          ? null
          : json['previous_response_id'] as String,
      promptCacheKey: json['prompt_cache_key'] == null
          ? null
          : json['prompt_cache_key'] as String,
      promptCacheRetention: json['prompt_cache_retention'] == null
          ? null
          : json['prompt_cache_retention'] as String,
      reasoning: json['reasoning'] == null
          ? null
          : ResponseReasoning.fromJson(
              json['reasoning'] as Map<String, dynamic>,
            ),
      safetyIdentifier: json['safety_identifier'] == null
          ? null
          : json['safety_identifier'] as String,
      serviceTier: json['service_tier'] == null
          ? null
          : json['service_tier'] as String,
      status: json['status'] == null ? null : json['status'] as String,
      temperature: json['temperature'] == null
          ? null
          : (json['temperature'] as num).toDouble(),
      text: json['text'] == null
          ? null
          : ResponseTextConfig.fromJson(json['text'] as Map<String, dynamic>),
      toolChoice: ResponseToolChoice.fromJson(json['tool_choice'] as Object),
      tools: (json['tools'] as List)
          .map((item) => ResponseTool.fromJson(item as Map<String, dynamic>))
          .toList(),
      topLogprobs: json['top_logprobs'] == null
          ? null
          : json['top_logprobs'] as int,
      topP: json['top_p'] == null ? null : (json['top_p'] as num).toDouble(),
      truncation: json['truncation'] == null
          ? null
          : json['truncation'] as String,
      usage: json['usage'] == null
          ? null
          : ResponseUsage.fromJson(json['usage'] as Map<String, dynamic>),
      user: json['user'] == null ? null : json['user'] as String,
      extra: additionalJsonFields(json, const {
        'background',
        'completed_at',
        'created_at',
        'error',
        'id',
        'incomplete_details',
        'instructions',
        'max_output_tokens',
        'max_tool_calls',
        'metadata',
        'model',
        'output',
        'parallel_tool_calls',
        'previous_response_id',
        'prompt_cache_key',
        'prompt_cache_retention',
        'reasoning',
        'safety_identifier',
        'service_tier',
        'status',
        'temperature',
        'text',
        'tool_choice',
        'tools',
        'top_logprobs',
        'top_p',
        'truncation',
        'usage',
        'user',
        'object',
      }),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    ...?extra,
    'object': object,
    'background': ?background,
    'completed_at': ?completedAt,
    'created_at': createdAt,
    if (error != null) 'error': error!.toJson(),
    'id': id,
    if (incompleteDetails != null)
      'incomplete_details': incompleteDetails!.toJson(),
    'instructions': ?instructions,
    'max_output_tokens': ?maxOutputTokens,
    'max_tool_calls': ?maxToolCalls,
    'metadata': ?metadata,
    'model': model,
    'output': output.map((item) => item.toJson()).toList(),
    'parallel_tool_calls': parallelToolCalls,
    'previous_response_id': ?previousResponseId,
    'prompt_cache_key': ?promptCacheKey,
    'prompt_cache_retention': ?promptCacheRetention,
    if (reasoning != null) 'reasoning': reasoning!.toJson(),
    'safety_identifier': ?safetyIdentifier,
    'service_tier': ?serviceTier,
    'status': ?status,
    'temperature': ?temperature,
    if (text != null) 'text': text!.toJson(),
    'tool_choice': toolChoice.toJson(),
    'tools': tools.map((item) => item.toJson()).toList(),
    'top_logprobs': ?topLogprobs,
    'top_p': ?topP,
    'truncation': ?truncation,
    if (usage != null) 'usage': usage!.toJson(),
    'user': ?user,
  };

  /// Creates a copy with the given fields replaced.
  MistralResponse copyWith({
    Object? background = unsetCopyWithValue,
    Object? completedAt = unsetCopyWithValue,
    double? createdAt,
    Object? error = unsetCopyWithValue,
    String? id,
    Object? incompleteDetails = unsetCopyWithValue,
    Object? instructions = unsetCopyWithValue,
    Object? maxOutputTokens = unsetCopyWithValue,
    Object? maxToolCalls = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
    String? model,
    List<ResponseOutputItem>? output,
    bool? parallelToolCalls,
    Object? previousResponseId = unsetCopyWithValue,
    Object? promptCacheKey = unsetCopyWithValue,
    Object? promptCacheRetention = unsetCopyWithValue,
    Object? reasoning = unsetCopyWithValue,
    Object? safetyIdentifier = unsetCopyWithValue,
    Object? serviceTier = unsetCopyWithValue,
    Object? status = unsetCopyWithValue,
    Object? temperature = unsetCopyWithValue,
    Object? text = unsetCopyWithValue,
    ResponseToolChoice? toolChoice,
    List<ResponseTool>? tools,
    Object? topLogprobs = unsetCopyWithValue,
    Object? topP = unsetCopyWithValue,
    Object? truncation = unsetCopyWithValue,
    Object? usage = unsetCopyWithValue,
    Object? user = unsetCopyWithValue,
    Object? extra = unsetCopyWithValue,
  }) => MistralResponse(
    background: background == unsetCopyWithValue
        ? this.background
        : background as bool?,
    completedAt: completedAt == unsetCopyWithValue
        ? this.completedAt
        : (completedAt as num?)?.toDouble(),
    createdAt: createdAt ?? this.createdAt,
    error: error == unsetCopyWithValue ? this.error : error as ResponseError?,
    id: id ?? this.id,
    incompleteDetails: incompleteDetails == unsetCopyWithValue
        ? this.incompleteDetails
        : incompleteDetails as ResponseIncompleteDetails?,
    instructions: instructions == unsetCopyWithValue
        ? this.instructions
        : instructions as String?,
    maxOutputTokens: maxOutputTokens == unsetCopyWithValue
        ? this.maxOutputTokens
        : maxOutputTokens as int?,
    maxToolCalls: maxToolCalls == unsetCopyWithValue
        ? this.maxToolCalls
        : maxToolCalls as int?,
    metadata: metadata == unsetCopyWithValue
        ? this.metadata
        : (metadata as Map?)?.cast<String, String>(),
    model: model ?? this.model,
    output: output ?? this.output,
    parallelToolCalls: parallelToolCalls ?? this.parallelToolCalls,
    previousResponseId: previousResponseId == unsetCopyWithValue
        ? this.previousResponseId
        : previousResponseId as String?,
    promptCacheKey: promptCacheKey == unsetCopyWithValue
        ? this.promptCacheKey
        : promptCacheKey as String?,
    promptCacheRetention: promptCacheRetention == unsetCopyWithValue
        ? this.promptCacheRetention
        : promptCacheRetention as String?,
    reasoning: reasoning == unsetCopyWithValue
        ? this.reasoning
        : reasoning as ResponseReasoning?,
    safetyIdentifier: safetyIdentifier == unsetCopyWithValue
        ? this.safetyIdentifier
        : safetyIdentifier as String?,
    serviceTier: serviceTier == unsetCopyWithValue
        ? this.serviceTier
        : serviceTier as String?,
    status: status == unsetCopyWithValue ? this.status : status as String?,
    temperature: temperature == unsetCopyWithValue
        ? this.temperature
        : (temperature as num?)?.toDouble(),
    text: text == unsetCopyWithValue ? this.text : text as ResponseTextConfig?,
    toolChoice: toolChoice ?? this.toolChoice,
    tools: tools ?? this.tools,
    topLogprobs: topLogprobs == unsetCopyWithValue
        ? this.topLogprobs
        : topLogprobs as int?,
    topP: topP == unsetCopyWithValue ? this.topP : (topP as num?)?.toDouble(),
    truncation: truncation == unsetCopyWithValue
        ? this.truncation
        : truncation as String?,
    usage: usage == unsetCopyWithValue ? this.usage : usage as ResponseUsage?,
    user: user == unsetCopyWithValue ? this.user : user as String?,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MistralResponse &&
          runtimeType == other.runtimeType &&
          background == other.background &&
          completedAt == other.completedAt &&
          createdAt == other.createdAt &&
          error == other.error &&
          id == other.id &&
          incompleteDetails == other.incompleteDetails &&
          instructions == other.instructions &&
          maxOutputTokens == other.maxOutputTokens &&
          maxToolCalls == other.maxToolCalls &&
          valuesDeepEqual(metadata, other.metadata) &&
          model == other.model &&
          valuesDeepEqual(output, other.output) &&
          parallelToolCalls == other.parallelToolCalls &&
          previousResponseId == other.previousResponseId &&
          promptCacheKey == other.promptCacheKey &&
          promptCacheRetention == other.promptCacheRetention &&
          reasoning == other.reasoning &&
          safetyIdentifier == other.safetyIdentifier &&
          serviceTier == other.serviceTier &&
          status == other.status &&
          temperature == other.temperature &&
          text == other.text &&
          toolChoice == other.toolChoice &&
          valuesDeepEqual(tools, other.tools) &&
          topLogprobs == other.topLogprobs &&
          topP == other.topP &&
          truncation == other.truncation &&
          usage == other.usage &&
          user == other.user &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([
    background,
    completedAt,
    createdAt,
    error,
    id,
    incompleteDetails,
    instructions,
    maxOutputTokens,
    maxToolCalls,
    valueDeepHashCode(metadata),
    model,
    valueDeepHashCode(output),
    parallelToolCalls,
    previousResponseId,
    promptCacheKey,
    promptCacheRetention,
    reasoning,
    safetyIdentifier,
    serviceTier,
    status,
    temperature,
    text,
    toolChoice,
    valueDeepHashCode(tools),
    topLogprobs,
    topP,
    truncation,
    usage,
    user,
    valueDeepHashCode(extra),
  ]);

  @override
  String toString() =>
      'MistralResponse('
      'background: $background, '
      'completedAt: $completedAt, '
      'createdAt: $createdAt, '
      'error: $error, '
      'id: $id, '
      'incompleteDetails: $incompleteDetails, '
      'instructions: $instructions, '
      'maxOutputTokens: $maxOutputTokens, '
      'maxToolCalls: $maxToolCalls, '
      'metadata: ${metadata?.length}, '
      'model: $model, '
      'output: ${output.length}, '
      'parallelToolCalls: $parallelToolCalls, '
      'previousResponseId: $previousResponseId, '
      'promptCacheKey: $promptCacheKey, '
      'promptCacheRetention: $promptCacheRetention, '
      'reasoning: $reasoning, '
      'safetyIdentifier: $safetyIdentifier, '
      'serviceTier: $serviceTier, '
      'status: $status, '
      'temperature: $temperature, '
      'text: $text, '
      'toolChoice: $toolChoice, '
      'tools: ${tools.length}, '
      'topLogprobs: $topLogprobs, '
      'topP: $topP, '
      'truncation: $truncation, '
      'usage: $usage, '
      'user: $user, '
      'extra: ${extra?.length})';
}

/// The CountResponseInputTokensRequest wire payload.
@immutable
class CountResponseInputTokensRequest {
  /// Creates a [CountResponseInputTokensRequest].
  const CountResponseInputTokensRequest({
    required this.input,
    this.instructions,
    required this.model,
    this.parallelToolCalls,
    this.reasoning,
    this.text,
    this.toolChoice,
    this.tools,
    this.extra,
  });

  /// Mistral uses the supplied input with truncation disabled.
  String get truncation => 'disabled';

  /// The input field.
  final ResponseInput input;

  /// The instructions field.
  final String? instructions;

  /// The model field.
  final String model;

  /// The parallel_tool_calls field.
  final bool? parallelToolCalls;

  /// The reasoning field.
  final ResponseReasoning? reasoning;

  /// The text field.
  final ResponseTextConfig? text;

  /// The tool_choice field.
  final ResponseToolChoice? toolChoice;

  /// The tools field.
  final List<ResponseTool>? tools;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [CountResponseInputTokensRequest] from JSON.
  factory CountResponseInputTokensRequest.fromJson(Map<String, dynamic> json) {
    if (json['truncation'] case final value? when value != 'disabled') {
      throw FormatException(
        'CountResponseInputTokensRequest: unexpected truncation $value',
      );
    }
    if (json['input'] == null) {
      throw const FormatException(
        'CountResponseInputTokensRequest: missing input',
      );
    }
    if (json['model'] == null) {
      throw const FormatException(
        'CountResponseInputTokensRequest: missing model',
      );
    }
    return CountResponseInputTokensRequest(
      input: ResponseInput.fromJson(json['input'] as Object),
      instructions: json['instructions'] == null
          ? null
          : json['instructions'] as String,
      model: json['model'] as String,
      parallelToolCalls: json['parallel_tool_calls'] == null
          ? null
          : json['parallel_tool_calls'] as bool,
      reasoning: json['reasoning'] == null
          ? null
          : ResponseReasoning.fromJson(
              json['reasoning'] as Map<String, dynamic>,
            ),
      text: json['text'] == null
          ? null
          : ResponseTextConfig.fromJson(json['text'] as Map<String, dynamic>),
      toolChoice: json['tool_choice'] == null
          ? null
          : ResponseToolChoice.fromJson(json['tool_choice'] as Object),
      tools: json['tools'] == null
          ? null
          : (json['tools'] as List)
                .map(
                  (item) => ResponseTool.fromJson(item as Map<String, dynamic>),
                )
                .toList(),
      extra: additionalJsonFields(json, const {
        'input',
        'instructions',
        'model',
        'parallel_tool_calls',
        'reasoning',
        'text',
        'tool_choice',
        'tools',
        'truncation',
      }),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    ...?extra,
    'truncation': truncation,
    'input': input.toJson(),
    'instructions': ?instructions,
    'model': model,
    'parallel_tool_calls': ?parallelToolCalls,
    if (reasoning != null) 'reasoning': reasoning!.toJson(),
    if (text != null) 'text': text!.toJson(),
    if (toolChoice != null) 'tool_choice': toolChoice!.toJson(),
    if (tools != null) 'tools': tools!.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  CountResponseInputTokensRequest copyWith({
    ResponseInput? input,
    Object? instructions = unsetCopyWithValue,
    String? model,
    Object? parallelToolCalls = unsetCopyWithValue,
    Object? reasoning = unsetCopyWithValue,
    Object? text = unsetCopyWithValue,
    Object? toolChoice = unsetCopyWithValue,
    Object? tools = unsetCopyWithValue,
    Object? extra = unsetCopyWithValue,
  }) => CountResponseInputTokensRequest(
    input: input ?? this.input,
    instructions: instructions == unsetCopyWithValue
        ? this.instructions
        : instructions as String?,
    model: model ?? this.model,
    parallelToolCalls: parallelToolCalls == unsetCopyWithValue
        ? this.parallelToolCalls
        : parallelToolCalls as bool?,
    reasoning: reasoning == unsetCopyWithValue
        ? this.reasoning
        : reasoning as ResponseReasoning?,
    text: text == unsetCopyWithValue ? this.text : text as ResponseTextConfig?,
    toolChoice: toolChoice == unsetCopyWithValue
        ? this.toolChoice
        : toolChoice as ResponseToolChoice?,
    tools: tools == unsetCopyWithValue
        ? this.tools
        : (tools as List?)?.cast<ResponseTool>(),
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountResponseInputTokensRequest &&
          runtimeType == other.runtimeType &&
          input == other.input &&
          instructions == other.instructions &&
          model == other.model &&
          parallelToolCalls == other.parallelToolCalls &&
          reasoning == other.reasoning &&
          text == other.text &&
          toolChoice == other.toolChoice &&
          valuesDeepEqual(tools, other.tools) &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([
    input,
    instructions,
    model,
    parallelToolCalls,
    reasoning,
    text,
    toolChoice,
    valueDeepHashCode(tools),
    valueDeepHashCode(extra),
  ]);

  @override
  String toString() =>
      'CountResponseInputTokensRequest('
      'input: $input, '
      'instructions: $instructions, '
      'model: $model, '
      'parallelToolCalls: $parallelToolCalls, '
      'reasoning: $reasoning, '
      'text: $text, '
      'toolChoice: $toolChoice, '
      'tools: ${tools?.length}, '
      'extra: ${extra?.length})';
}

/// The CountResponseInputTokensResponse wire payload.
@immutable
class ResponseInputTokenCount {
  /// Creates a [ResponseInputTokenCount].
  const ResponseInputTokenCount({required this.inputTokens, this.extra});

  /// The fixed object discriminator.
  String get object => 'response.input_tokens';

  /// The input_tokens field.
  final int inputTokens;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseInputTokenCount] from JSON.
  factory ResponseInputTokenCount.fromJson(Map<String, dynamic> json) {
    if (json['object'] case final value?
        when value != 'response.input_tokens') {
      throw FormatException(
        'ResponseInputTokenCount: unexpected object $value',
      );
    }
    if (json['input_tokens'] == null) {
      throw const FormatException(
        'ResponseInputTokenCount: missing input_tokens',
      );
    }
    return ResponseInputTokenCount(
      inputTokens: json['input_tokens'] as int,
      extra: additionalJsonFields(json, const {'input_tokens', 'object'}),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    ...?extra,
    'object': object,
    'input_tokens': inputTokens,
  };

  /// Creates a copy with the given fields replaced.
  ResponseInputTokenCount copyWith({
    int? inputTokens,
    Object? extra = unsetCopyWithValue,
  }) => ResponseInputTokenCount(
    inputTokens: inputTokens ?? this.inputTokens,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseInputTokenCount &&
          runtimeType == other.runtimeType &&
          inputTokens == other.inputTokens &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([inputTokens, valueDeepHashCode(extra)]);

  @override
  String toString() =>
      'ResponseInputTokenCount('
      'inputTokens: $inputTokens, '
      'extra: ${extra?.length})';
}

/// The ResponsesError wire payload.
@immutable
class ResponseError {
  /// Creates a [ResponseError].
  const ResponseError({
    required this.code,
    required this.message,
    this.misalignment,
    this.param,
    required this.reason,
    this.type,
    this.extra,
  });

  /// The code field.
  final String code;

  /// The message field.
  final String message;

  /// The misalignment field.
  final ResponseMisalignment? misalignment;

  /// The param field.
  final String? param;

  /// The reason field.
  final String reason;

  /// The type field.
  final String? type;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseError] from JSON.
  factory ResponseError.fromJson(Map<String, dynamic> json) {
    if (json['code'] == null) {
      throw const FormatException('ResponseError: missing code');
    }
    if (json['message'] == null) {
      throw const FormatException('ResponseError: missing message');
    }
    if (json['reason'] == null) {
      throw const FormatException('ResponseError: missing reason');
    }
    return ResponseError(
      code: json['code'] as String,
      message: json['message'] as String,
      misalignment: json['misalignment'] == null
          ? null
          : ResponseMisalignment.fromJson(
              json['misalignment'] as Map<String, dynamic>,
            ),
      param: json['param'] == null ? null : json['param'] as String,
      reason: json['reason'] as String,
      type: json['type'] == null ? null : json['type'] as String,
      extra: additionalJsonFields(json, const {
        'code',
        'message',
        'misalignment',
        'param',
        'reason',
        'type',
      }),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    ...?extra,
    'code': code,
    'message': message,
    if (misalignment != null) 'misalignment': misalignment!.toJson(),
    'param': ?param,
    'reason': reason,
    'type': ?type,
  };

  /// Creates a copy with the given fields replaced.
  ResponseError copyWith({
    String? code,
    String? message,
    Object? misalignment = unsetCopyWithValue,
    Object? param = unsetCopyWithValue,
    String? reason,
    Object? type = unsetCopyWithValue,
    Object? extra = unsetCopyWithValue,
  }) => ResponseError(
    code: code ?? this.code,
    message: message ?? this.message,
    misalignment: misalignment == unsetCopyWithValue
        ? this.misalignment
        : misalignment as ResponseMisalignment?,
    param: param == unsetCopyWithValue ? this.param : param as String?,
    reason: reason ?? this.reason,
    type: type == unsetCopyWithValue ? this.type : type as String?,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseError &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          message == other.message &&
          misalignment == other.misalignment &&
          param == other.param &&
          reason == other.reason &&
          type == other.type &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([
    code,
    message,
    misalignment,
    param,
    reason,
    type,
    valueDeepHashCode(extra),
  ]);

  @override
  String toString() =>
      'ResponseError('
      'code: $code, '
      'message: $message, '
      'misalignment: $misalignment, '
      'param: $param, '
      'reason: $reason, '
      'type: $type, '
      'extra: ${extra?.length})';
}

/// The ResponsesIncompleteDetails wire payload.
@immutable
class ResponseIncompleteDetails {
  /// Creates a [ResponseIncompleteDetails].
  const ResponseIncompleteDetails({this.reason, this.extra});

  /// The reason field.
  final String? reason;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseIncompleteDetails] from JSON.
  factory ResponseIncompleteDetails.fromJson(Map<String, dynamic> json) {
    return ResponseIncompleteDetails(
      reason: json['reason'] == null ? null : json['reason'] as String,
      extra: additionalJsonFields(json, const {'reason'}),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {...?extra, 'reason': ?reason};

  /// Creates a copy with the given fields replaced.
  ResponseIncompleteDetails copyWith({
    Object? reason = unsetCopyWithValue,
    Object? extra = unsetCopyWithValue,
  }) => ResponseIncompleteDetails(
    reason: reason == unsetCopyWithValue ? this.reason : reason as String?,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseIncompleteDetails &&
          runtimeType == other.runtimeType &&
          reason == other.reason &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([reason, valueDeepHashCode(extra)]);

  @override
  String toString() =>
      'ResponseIncompleteDetails('
      'reason: $reason, '
      'extra: ${extra?.length})';
}

/// The ResponsesUsage wire payload.
@immutable
class ResponseUsage {
  /// Creates a [ResponseUsage].
  const ResponseUsage({
    required this.inputTokens,
    required this.inputTokensDetails,
    required this.outputTokens,
    required this.outputTokensDetails,
    required this.totalTokens,
    this.extra,
  });

  /// The input_tokens field.
  final int inputTokens;

  /// The input_tokens_details field.
  final ResponseInputTokensDetails inputTokensDetails;

  /// The output_tokens field.
  final int outputTokens;

  /// The output_tokens_details field.
  final ResponseOutputTokensDetails outputTokensDetails;

  /// The total_tokens field.
  final int totalTokens;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseUsage] from JSON.
  factory ResponseUsage.fromJson(Map<String, dynamic> json) {
    if (json['input_tokens'] == null) {
      throw const FormatException('ResponseUsage: missing input_tokens');
    }
    if (json['input_tokens_details'] == null) {
      throw const FormatException(
        'ResponseUsage: missing input_tokens_details',
      );
    }
    if (json['output_tokens'] == null) {
      throw const FormatException('ResponseUsage: missing output_tokens');
    }
    if (json['output_tokens_details'] == null) {
      throw const FormatException(
        'ResponseUsage: missing output_tokens_details',
      );
    }
    if (json['total_tokens'] == null) {
      throw const FormatException('ResponseUsage: missing total_tokens');
    }
    return ResponseUsage(
      inputTokens: json['input_tokens'] as int,
      inputTokensDetails: ResponseInputTokensDetails.fromJson(
        json['input_tokens_details'] as Map<String, dynamic>,
      ),
      outputTokens: json['output_tokens'] as int,
      outputTokensDetails: ResponseOutputTokensDetails.fromJson(
        json['output_tokens_details'] as Map<String, dynamic>,
      ),
      totalTokens: json['total_tokens'] as int,
      extra: additionalJsonFields(json, const {
        'input_tokens',
        'input_tokens_details',
        'output_tokens',
        'output_tokens_details',
        'total_tokens',
      }),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    ...?extra,
    'input_tokens': inputTokens,
    'input_tokens_details': inputTokensDetails.toJson(),
    'output_tokens': outputTokens,
    'output_tokens_details': outputTokensDetails.toJson(),
    'total_tokens': totalTokens,
  };

  /// Creates a copy with the given fields replaced.
  ResponseUsage copyWith({
    int? inputTokens,
    ResponseInputTokensDetails? inputTokensDetails,
    int? outputTokens,
    ResponseOutputTokensDetails? outputTokensDetails,
    int? totalTokens,
    Object? extra = unsetCopyWithValue,
  }) => ResponseUsage(
    inputTokens: inputTokens ?? this.inputTokens,
    inputTokensDetails: inputTokensDetails ?? this.inputTokensDetails,
    outputTokens: outputTokens ?? this.outputTokens,
    outputTokensDetails: outputTokensDetails ?? this.outputTokensDetails,
    totalTokens: totalTokens ?? this.totalTokens,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseUsage &&
          runtimeType == other.runtimeType &&
          inputTokens == other.inputTokens &&
          inputTokensDetails == other.inputTokensDetails &&
          outputTokens == other.outputTokens &&
          outputTokensDetails == other.outputTokensDetails &&
          totalTokens == other.totalTokens &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([
    inputTokens,
    inputTokensDetails,
    outputTokens,
    outputTokensDetails,
    totalTokens,
    valueDeepHashCode(extra),
  ]);

  @override
  String toString() =>
      'ResponseUsage('
      'inputTokens: $inputTokens, '
      'inputTokensDetails: $inputTokensDetails, '
      'outputTokens: $outputTokens, '
      'outputTokensDetails: $outputTokensDetails, '
      'totalTokens: $totalTokens, '
      'extra: ${extra?.length})';
}

/// The ResponsesInputTokensDetails wire payload.
@immutable
class ResponseInputTokensDetails {
  /// Creates a [ResponseInputTokensDetails].
  const ResponseInputTokensDetails({
    required this.cacheWriteTokens,
    required this.cachedTokens,
    this.extra,
  });

  /// The cache_write_tokens field.
  final int cacheWriteTokens;

  /// The cached_tokens field.
  final int cachedTokens;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseInputTokensDetails] from JSON.
  factory ResponseInputTokensDetails.fromJson(Map<String, dynamic> json) {
    if (json['cache_write_tokens'] == null) {
      throw const FormatException(
        'ResponseInputTokensDetails: missing cache_write_tokens',
      );
    }
    if (json['cached_tokens'] == null) {
      throw const FormatException(
        'ResponseInputTokensDetails: missing cached_tokens',
      );
    }
    return ResponseInputTokensDetails(
      cacheWriteTokens: json['cache_write_tokens'] as int,
      cachedTokens: json['cached_tokens'] as int,
      extra: additionalJsonFields(json, const {
        'cache_write_tokens',
        'cached_tokens',
      }),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    ...?extra,
    'cache_write_tokens': cacheWriteTokens,
    'cached_tokens': cachedTokens,
  };

  /// Creates a copy with the given fields replaced.
  ResponseInputTokensDetails copyWith({
    int? cacheWriteTokens,
    int? cachedTokens,
    Object? extra = unsetCopyWithValue,
  }) => ResponseInputTokensDetails(
    cacheWriteTokens: cacheWriteTokens ?? this.cacheWriteTokens,
    cachedTokens: cachedTokens ?? this.cachedTokens,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseInputTokensDetails &&
          runtimeType == other.runtimeType &&
          cacheWriteTokens == other.cacheWriteTokens &&
          cachedTokens == other.cachedTokens &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([
    cacheWriteTokens,
    cachedTokens,
    valueDeepHashCode(extra),
  ]);

  @override
  String toString() =>
      'ResponseInputTokensDetails('
      'cacheWriteTokens: $cacheWriteTokens, '
      'cachedTokens: $cachedTokens, '
      'extra: ${extra?.length})';
}

/// The ResponsesOutputTokensDetails wire payload.
@immutable
class ResponseOutputTokensDetails {
  /// Creates a [ResponseOutputTokensDetails].
  const ResponseOutputTokensDetails({
    required this.reasoningTokens,
    this.extra,
  });

  /// The reasoning_tokens field.
  final int reasoningTokens;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseOutputTokensDetails] from JSON.
  factory ResponseOutputTokensDetails.fromJson(Map<String, dynamic> json) {
    if (json['reasoning_tokens'] == null) {
      throw const FormatException(
        'ResponseOutputTokensDetails: missing reasoning_tokens',
      );
    }
    return ResponseOutputTokensDetails(
      reasoningTokens: json['reasoning_tokens'] as int,
      extra: additionalJsonFields(json, const {'reasoning_tokens'}),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    ...?extra,
    'reasoning_tokens': reasoningTokens,
  };

  /// Creates a copy with the given fields replaced.
  ResponseOutputTokensDetails copyWith({
    int? reasoningTokens,
    Object? extra = unsetCopyWithValue,
  }) => ResponseOutputTokensDetails(
    reasoningTokens: reasoningTokens ?? this.reasoningTokens,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseOutputTokensDetails &&
          runtimeType == other.runtimeType &&
          reasoningTokens == other.reasoningTokens &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode =>
      Object.hashAll([reasoningTokens, valueDeepHashCode(extra)]);

  @override
  String toString() =>
      'ResponseOutputTokensDetails('
      'reasoningTokens: $reasoningTokens, '
      'extra: ${extra?.length})';
}

/// The ResponsesMisalignment wire payload.
@immutable
class ResponseMisalignment {
  /// Creates a [ResponseMisalignment].
  const ResponseMisalignment({
    this.detailedExplanation,
    this.errorType,
    this.reviewTarget,
    this.steer,
    this.extra,
  });

  /// The detailed_explanation field.
  final String? detailedExplanation;

  /// The error_type field.
  final String? errorType;

  /// The review_target field.
  final String? reviewTarget;

  /// The steer field.
  final ResponseMisalignmentSteer? steer;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseMisalignment] from JSON.
  factory ResponseMisalignment.fromJson(Map<String, dynamic> json) {
    return ResponseMisalignment(
      detailedExplanation: json['detailed_explanation'] == null
          ? null
          : json['detailed_explanation'] as String,
      errorType: json['error_type'] == null
          ? null
          : json['error_type'] as String,
      reviewTarget: json['review_target'] == null
          ? null
          : json['review_target'] as String,
      steer: json['steer'] == null
          ? null
          : ResponseMisalignmentSteer.fromJson(
              json['steer'] as Map<String, dynamic>,
            ),
      extra: additionalJsonFields(json, const {
        'detailed_explanation',
        'error_type',
        'review_target',
        'steer',
      }),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    ...?extra,
    'detailed_explanation': ?detailedExplanation,
    'error_type': ?errorType,
    'review_target': ?reviewTarget,
    if (steer != null) 'steer': steer!.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  ResponseMisalignment copyWith({
    Object? detailedExplanation = unsetCopyWithValue,
    Object? errorType = unsetCopyWithValue,
    Object? reviewTarget = unsetCopyWithValue,
    Object? steer = unsetCopyWithValue,
    Object? extra = unsetCopyWithValue,
  }) => ResponseMisalignment(
    detailedExplanation: detailedExplanation == unsetCopyWithValue
        ? this.detailedExplanation
        : detailedExplanation as String?,
    errorType: errorType == unsetCopyWithValue
        ? this.errorType
        : errorType as String?,
    reviewTarget: reviewTarget == unsetCopyWithValue
        ? this.reviewTarget
        : reviewTarget as String?,
    steer: steer == unsetCopyWithValue
        ? this.steer
        : steer as ResponseMisalignmentSteer?,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseMisalignment &&
          runtimeType == other.runtimeType &&
          detailedExplanation == other.detailedExplanation &&
          errorType == other.errorType &&
          reviewTarget == other.reviewTarget &&
          steer == other.steer &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([
    detailedExplanation,
    errorType,
    reviewTarget,
    steer,
    valueDeepHashCode(extra),
  ]);

  @override
  String toString() =>
      'ResponseMisalignment('
      'detailedExplanation: $detailedExplanation, '
      'errorType: $errorType, '
      'reviewTarget: $reviewTarget, '
      'steer: $steer, '
      'extra: ${extra?.length})';
}

/// The ResponsesMisalignmentSteer wire payload.
@immutable
class ResponseMisalignmentSteer {
  /// Creates a [ResponseMisalignmentSteer].
  const ResponseMisalignmentSteer({required this.message, this.extra});

  /// The message field.
  final String message;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseMisalignmentSteer] from JSON.
  factory ResponseMisalignmentSteer.fromJson(Map<String, dynamic> json) {
    if (json['message'] == null) {
      throw const FormatException('ResponseMisalignmentSteer: missing message');
    }
    return ResponseMisalignmentSteer(
      message: json['message'] as String,
      extra: additionalJsonFields(json, const {'message'}),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {...?extra, 'message': message};

  /// Creates a copy with the given fields replaced.
  ResponseMisalignmentSteer copyWith({
    String? message,
    Object? extra = unsetCopyWithValue,
  }) => ResponseMisalignmentSteer(
    message: message ?? this.message,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseMisalignmentSteer &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([message, valueDeepHashCode(extra)]);

  @override
  String toString() =>
      'ResponseMisalignmentSteer('
      'message: $message, '
      'extra: ${extra?.length})';
}
