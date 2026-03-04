import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../items/output_item.dart';
import '../metadata/response_status.dart';
import '../metadata/service_tier.dart';
import '../metadata/truncation.dart';
import '../request/reasoning_config.dart';
import '../request/text_config.dart';
import '../tools/tool.dart';
import '../tools/tool_choice.dart';
import 'error_payload.dart';
import 'incomplete_details.dart';
import 'usage.dart';

/// A response resource from the API.
@immutable
class ResponseResource {
  /// Unique identifier.
  final String id;

  /// Object type. Always "response".
  final String object;

  /// Unix timestamp of creation.
  final int? createdAt;

  /// Unix timestamp of completion (if completed).
  final int? completedAt;

  /// The model that generated the response.
  final String? model;

  /// The response status.
  final ResponseStatus status;

  /// ID of the previous response in the chain (if any).
  final String? previousResponseId;

  /// Additional instructions that were used to guide the model.
  final String? instructions;

  /// The output items.
  final List<OutputItem>? output;

  /// Token usage statistics.
  final Usage? usage;

  /// Error information (if failed).
  final ErrorPayload? error;

  /// Details about incompleteness.
  final IncompleteDetails? incompleteDetails;

  /// The tools available to the model during response generation.
  final List<Tool>? tools;

  /// How the model chose which tool to call.
  final ToolChoice? toolChoice;

  /// How the input was truncated by the service.
  final Truncation? truncation;

  /// Whether the model was allowed to call multiple tools in parallel.
  final bool? parallelToolCalls;

  /// Configuration options for text output.
  final TextConfig? text;

  /// Temperature used for generation.
  final double? temperature;

  /// Top-p used for generation.
  final double? topP;

  /// Presence penalty used for generation.
  final double? presencePenalty;

  /// Frequency penalty used for generation.
  final double? frequencyPenalty;

  /// Number of most likely tokens returned at each position.
  final int? topLogprobs;

  /// Reasoning configuration and outputs.
  final ReasoningConfig? reasoning;

  /// Maximum output tokens the model was allowed to generate.
  final int? maxOutputTokens;

  /// Maximum tool calls the model was allowed to make.
  final int? maxToolCalls;

  /// Whether this response was stored.
  final bool? store;

  /// Whether this request was run in the background.
  final bool? background;

  /// The service tier used.
  final ServiceTier? serviceTier;

  /// User-provided metadata.
  final Map<String, String>? metadata;

  /// A stable identifier used for safety monitoring and abuse detection.
  final String? safetyIdentifier;

  /// A key used for prompt cache reads/writes.
  final String? promptCacheKey;

  /// Creates a [ResponseResource].
  const ResponseResource({
    required this.id,
    this.object = 'response',
    this.createdAt,
    this.completedAt,
    this.model,
    required this.status,
    this.previousResponseId,
    this.instructions,
    this.output,
    this.usage,
    this.error,
    this.incompleteDetails,
    this.tools,
    this.toolChoice,
    this.truncation,
    this.parallelToolCalls,
    this.text,
    this.temperature,
    this.topP,
    this.presencePenalty,
    this.frequencyPenalty,
    this.topLogprobs,
    this.reasoning,
    this.maxOutputTokens,
    this.maxToolCalls,
    this.store,
    this.background,
    this.serviceTier,
    this.metadata,
    this.safetyIdentifier,
    this.promptCacheKey,
  });

  /// Creates a [ResponseResource] from JSON.
  factory ResponseResource.fromJson(Map<String, dynamic> json) {
    return ResponseResource(
      id: json['id'] as String,
      object: json['object'] as String? ?? 'response',
      createdAt: json['created_at'] as int?,
      completedAt: json['completed_at'] as int?,
      model: json['model'] as String?,
      status: ResponseStatus.fromJson(json['status'] as String),
      previousResponseId: json['previous_response_id'] as String?,
      instructions: json['instructions'] as String?,
      output: (json['output'] as List?)
          ?.map((e) => OutputItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      usage: json['usage'] != null
          ? Usage.fromJson(json['usage'] as Map<String, dynamic>)
          : null,
      error: json['error'] != null
          ? ErrorPayload.fromJson(json['error'] as Map<String, dynamic>)
          : null,
      incompleteDetails: json['incomplete_details'] != null
          ? IncompleteDetails.fromJson(
              json['incomplete_details'] as Map<String, dynamic>,
            )
          : null,
      tools: (json['tools'] as List?)
          ?.map((e) => Tool.fromJson(e as Map<String, dynamic>))
          .toList(),
      toolChoice: json['tool_choice'] != null
          ? ToolChoice.fromJson(json['tool_choice'])
          : null,
      truncation: json['truncation'] != null
          ? Truncation.fromJson(json['truncation'] as String)
          : null,
      parallelToolCalls: json['parallel_tool_calls'] as bool?,
      text: json['text'] != null
          ? TextConfig.fromJson(json['text'] as Map<String, dynamic>)
          : null,
      temperature: (json['temperature'] as num?)?.toDouble(),
      topP: (json['top_p'] as num?)?.toDouble(),
      presencePenalty: (json['presence_penalty'] as num?)?.toDouble(),
      frequencyPenalty: (json['frequency_penalty'] as num?)?.toDouble(),
      topLogprobs: json['top_logprobs'] as int?,
      reasoning: json['reasoning'] != null
          ? ReasoningConfig.fromJson(json['reasoning'] as Map<String, dynamic>)
          : null,
      maxOutputTokens: json['max_output_tokens'] as int?,
      maxToolCalls: json['max_tool_calls'] as int?,
      store: json['store'] as bool?,
      background: json['background'] as bool?,
      serviceTier: json['service_tier'] != null
          ? ServiceTier.fromJson(json['service_tier'] as String)
          : null,
      metadata: (json['metadata'] as Map?)?.cast<String, String>(),
      safetyIdentifier: json['safety_identifier'] as String?,
      promptCacheKey: json['prompt_cache_key'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    if (createdAt != null) 'created_at': createdAt,
    if (completedAt != null) 'completed_at': completedAt,
    if (model != null) 'model': model,
    'status': status.toJson(),
    if (previousResponseId != null) 'previous_response_id': previousResponseId,
    if (instructions != null) 'instructions': instructions,
    if (output != null) 'output': output!.map((e) => e.toJson()).toList(),
    if (usage != null) 'usage': usage!.toJson(),
    if (error != null) 'error': error!.toJson(),
    if (incompleteDetails != null)
      'incomplete_details': incompleteDetails!.toJson(),
    if (tools != null) 'tools': tools!.map((e) => e.toJson()).toList(),
    if (toolChoice != null) 'tool_choice': toolChoice!.toJson(),
    if (truncation != null) 'truncation': truncation!.toJson(),
    if (parallelToolCalls != null) 'parallel_tool_calls': parallelToolCalls,
    if (text != null) 'text': text!.toJson(),
    if (temperature != null) 'temperature': temperature,
    if (topP != null) 'top_p': topP,
    if (presencePenalty != null) 'presence_penalty': presencePenalty,
    if (frequencyPenalty != null) 'frequency_penalty': frequencyPenalty,
    if (topLogprobs != null) 'top_logprobs': topLogprobs,
    if (reasoning != null) 'reasoning': reasoning!.toJson(),
    if (maxOutputTokens != null) 'max_output_tokens': maxOutputTokens,
    if (maxToolCalls != null) 'max_tool_calls': maxToolCalls,
    if (store != null) 'store': store,
    if (background != null) 'background': background,
    if (serviceTier != null) 'service_tier': serviceTier!.toJson(),
    if (metadata != null) 'metadata': metadata,
    if (safetyIdentifier != null) 'safety_identifier': safetyIdentifier,
    if (promptCacheKey != null) 'prompt_cache_key': promptCacheKey,
  };

  /// Creates a copy with replaced values.
  ResponseResource copyWith({
    String? id,
    String? object,
    Object? createdAt = unsetCopyWithValue,
    Object? completedAt = unsetCopyWithValue,
    Object? model = unsetCopyWithValue,
    ResponseStatus? status,
    Object? previousResponseId = unsetCopyWithValue,
    Object? instructions = unsetCopyWithValue,
    Object? output = unsetCopyWithValue,
    Object? usage = unsetCopyWithValue,
    Object? error = unsetCopyWithValue,
    Object? incompleteDetails = unsetCopyWithValue,
    Object? tools = unsetCopyWithValue,
    Object? toolChoice = unsetCopyWithValue,
    Object? truncation = unsetCopyWithValue,
    Object? parallelToolCalls = unsetCopyWithValue,
    Object? text = unsetCopyWithValue,
    Object? temperature = unsetCopyWithValue,
    Object? topP = unsetCopyWithValue,
    Object? presencePenalty = unsetCopyWithValue,
    Object? frequencyPenalty = unsetCopyWithValue,
    Object? topLogprobs = unsetCopyWithValue,
    Object? reasoning = unsetCopyWithValue,
    Object? maxOutputTokens = unsetCopyWithValue,
    Object? maxToolCalls = unsetCopyWithValue,
    Object? store = unsetCopyWithValue,
    Object? background = unsetCopyWithValue,
    Object? serviceTier = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
    Object? safetyIdentifier = unsetCopyWithValue,
    Object? promptCacheKey = unsetCopyWithValue,
  }) {
    return ResponseResource(
      id: id ?? this.id,
      object: object ?? this.object,
      createdAt: createdAt == unsetCopyWithValue
          ? this.createdAt
          : createdAt as int?,
      completedAt: completedAt == unsetCopyWithValue
          ? this.completedAt
          : completedAt as int?,
      model: model == unsetCopyWithValue ? this.model : model as String?,
      status: status ?? this.status,
      previousResponseId: previousResponseId == unsetCopyWithValue
          ? this.previousResponseId
          : previousResponseId as String?,
      instructions: instructions == unsetCopyWithValue
          ? this.instructions
          : instructions as String?,
      output: output == unsetCopyWithValue
          ? this.output
          : output as List<OutputItem>?,
      usage: usage == unsetCopyWithValue ? this.usage : usage as Usage?,
      error: error == unsetCopyWithValue ? this.error : error as ErrorPayload?,
      incompleteDetails: incompleteDetails == unsetCopyWithValue
          ? this.incompleteDetails
          : incompleteDetails as IncompleteDetails?,
      tools: tools == unsetCopyWithValue ? this.tools : tools as List<Tool>?,
      toolChoice: toolChoice == unsetCopyWithValue
          ? this.toolChoice
          : toolChoice as ToolChoice?,
      truncation: truncation == unsetCopyWithValue
          ? this.truncation
          : truncation as Truncation?,
      parallelToolCalls: parallelToolCalls == unsetCopyWithValue
          ? this.parallelToolCalls
          : parallelToolCalls as bool?,
      text: text == unsetCopyWithValue ? this.text : text as TextConfig?,
      temperature: temperature == unsetCopyWithValue
          ? this.temperature
          : temperature as double?,
      topP: topP == unsetCopyWithValue ? this.topP : topP as double?,
      presencePenalty: presencePenalty == unsetCopyWithValue
          ? this.presencePenalty
          : presencePenalty as double?,
      frequencyPenalty: frequencyPenalty == unsetCopyWithValue
          ? this.frequencyPenalty
          : frequencyPenalty as double?,
      topLogprobs: topLogprobs == unsetCopyWithValue
          ? this.topLogprobs
          : topLogprobs as int?,
      reasoning: reasoning == unsetCopyWithValue
          ? this.reasoning
          : reasoning as ReasoningConfig?,
      maxOutputTokens: maxOutputTokens == unsetCopyWithValue
          ? this.maxOutputTokens
          : maxOutputTokens as int?,
      maxToolCalls: maxToolCalls == unsetCopyWithValue
          ? this.maxToolCalls
          : maxToolCalls as int?,
      store: store == unsetCopyWithValue ? this.store : store as bool?,
      background: background == unsetCopyWithValue
          ? this.background
          : background as bool?,
      serviceTier: serviceTier == unsetCopyWithValue
          ? this.serviceTier
          : serviceTier as ServiceTier?,
      metadata: metadata == unsetCopyWithValue
          ? this.metadata
          : metadata as Map<String, String>?,
      safetyIdentifier: safetyIdentifier == unsetCopyWithValue
          ? this.safetyIdentifier
          : safetyIdentifier as String?,
      promptCacheKey: promptCacheKey == unsetCopyWithValue
          ? this.promptCacheKey
          : promptCacheKey as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseResource &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          object == other.object &&
          createdAt == other.createdAt &&
          completedAt == other.completedAt &&
          model == other.model &&
          status == other.status &&
          previousResponseId == other.previousResponseId &&
          instructions == other.instructions &&
          listsEqual(output, other.output) &&
          usage == other.usage &&
          error == other.error &&
          incompleteDetails == other.incompleteDetails &&
          listsEqual(tools, other.tools) &&
          toolChoice == other.toolChoice &&
          truncation == other.truncation &&
          parallelToolCalls == other.parallelToolCalls &&
          text == other.text &&
          temperature == other.temperature &&
          topP == other.topP &&
          presencePenalty == other.presencePenalty &&
          frequencyPenalty == other.frequencyPenalty &&
          topLogprobs == other.topLogprobs &&
          reasoning == other.reasoning &&
          maxOutputTokens == other.maxOutputTokens &&
          maxToolCalls == other.maxToolCalls &&
          store == other.store &&
          background == other.background &&
          serviceTier == other.serviceTier &&
          mapsEqual(metadata, other.metadata) &&
          safetyIdentifier == other.safetyIdentifier &&
          promptCacheKey == other.promptCacheKey;

  @override
  int get hashCode => Object.hashAll([
    id,
    object,
    createdAt,
    completedAt,
    model,
    status,
    previousResponseId,
    instructions,
    listHash(output),
    usage,
    error,
    incompleteDetails,
    listHash(tools),
    toolChoice,
    truncation,
    parallelToolCalls,
    text,
    temperature,
    topP,
    presencePenalty,
    frequencyPenalty,
    topLogprobs,
    reasoning,
    maxOutputTokens,
    maxToolCalls,
    store,
    background,
    serviceTier,
    mapHash(metadata),
    safetyIdentifier,
    promptCacheKey,
  ]);

  @override
  String toString() =>
      'ResponseResource(id: $id, model: $model, status: $status, ...)';
}
