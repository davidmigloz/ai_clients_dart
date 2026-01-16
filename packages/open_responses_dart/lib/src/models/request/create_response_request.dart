import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../items/item.dart';
import '../metadata/include.dart';
import '../metadata/service_tier.dart';
import '../metadata/truncation.dart';
import '../tools/tool.dart';
import '../tools/tool_choice.dart';
import 'reasoning_config.dart';
import 'text_config.dart';

/// Request to create a response.
@immutable
class CreateResponseRequest {
  /// The model to use for generation.
  final String model;

  /// The input for the response.
  ///
  /// Can be a `String` (for simple text) or `List<Item>` (for complex messages).
  final Object input;

  /// System-level instructions for the model.
  final String? instructions;

  /// Tools available to the model.
  final List<Tool>? tools;

  /// How the model should choose which tool to call.
  final ToolChoice? toolChoice;

  /// ID of a previous response for multi-turn conversation.
  final String? previousResponseId;

  /// Maximum tokens to generate.
  final int? maxOutputTokens;

  /// Sampling temperature (0.0 - 2.0).
  final double? temperature;

  /// Top-p sampling parameter.
  final double? topP;

  /// Whether to stream the response.
  final bool? stream;

  /// Configuration for reasoning models.
  final ReasoningConfig? reasoning;

  /// Configuration for text output.
  final TextConfig? text;

  /// Truncation strategy for long inputs.
  final Truncation? truncation;

  /// Service tier for request processing.
  final ServiceTier? serviceTier;

  /// User-defined metadata.
  final Map<String, String>? metadata;

  /// Additional data to include in response.
  final List<Include>? include;

  /// Sequences that stop generation.
  final List<String>? stop;

  /// Whether to store the response for later retrieval.
  final bool? store;

  /// Creates a [CreateResponseRequest].
  const CreateResponseRequest({
    required this.model,
    required this.input,
    this.instructions,
    this.tools,
    this.toolChoice,
    this.previousResponseId,
    this.maxOutputTokens,
    this.temperature,
    this.topP,
    this.stream,
    this.reasoning,
    this.text,
    this.truncation,
    this.serviceTier,
    this.metadata,
    this.include,
    this.stop,
    this.store,
  });

  /// Creates a simple text request.
  factory CreateResponseRequest.text({
    required String model,
    required String input,
    String? instructions,
    int? maxOutputTokens,
    double? temperature,
  }) {
    return CreateResponseRequest(
      model: model,
      input: input,
      instructions: instructions,
      maxOutputTokens: maxOutputTokens,
      temperature: temperature,
    );
  }

  /// Creates a [CreateResponseRequest] from JSON.
  factory CreateResponseRequest.fromJson(Map<String, dynamic> json) {
    return CreateResponseRequest(
      model: json['model'] as String,
      input: _parseInput(json['input']),
      instructions: json['instructions'] as String?,
      tools: (json['tools'] as List?)
          ?.map((e) => Tool.fromJson(e as Map<String, dynamic>))
          .toList(),
      toolChoice: json['tool_choice'] != null
          ? ToolChoice.fromJson(json['tool_choice'])
          : null,
      previousResponseId: json['previous_response_id'] as String?,
      maxOutputTokens: json['max_output_tokens'] as int?,
      temperature: (json['temperature'] as num?)?.toDouble(),
      topP: (json['top_p'] as num?)?.toDouble(),
      stream: json['stream'] as bool?,
      reasoning: json['reasoning'] != null
          ? ReasoningConfig.fromJson(json['reasoning'] as Map<String, dynamic>)
          : null,
      text: json['text'] != null
          ? TextConfig.fromJson(json['text'] as Map<String, dynamic>)
          : null,
      truncation: json['truncation'] != null
          ? Truncation.fromJson(json['truncation'] as String)
          : null,
      serviceTier: json['service_tier'] != null
          ? ServiceTier.fromJson(json['service_tier'] as String)
          : null,
      metadata: (json['metadata'] as Map?)?.cast<String, String>(),
      include: (json['include'] as List?)
          ?.map((e) => Include.fromJson(e as String))
          .toList(),
      stop: (json['stop'] as List?)?.cast<String>(),
      store: json['store'] as bool?,
    );
  }

  static Object _parseInput(Object? input) {
    if (input is String) return input;
    if (input is List) {
      return input
          .map((e) => Item.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw FormatException('Invalid input format: $input');
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'model': model,
    'input': _inputToJson(),
    if (instructions != null) 'instructions': instructions,
    if (tools != null) 'tools': tools!.map((e) => e.toJson()).toList(),
    if (toolChoice != null) 'tool_choice': toolChoice!.toJson(),
    if (previousResponseId != null) 'previous_response_id': previousResponseId,
    if (maxOutputTokens != null) 'max_output_tokens': maxOutputTokens,
    if (temperature != null) 'temperature': temperature,
    if (topP != null) 'top_p': topP,
    if (stream != null) 'stream': stream,
    if (reasoning != null) 'reasoning': reasoning!.toJson(),
    if (text != null) 'text': text!.toJson(),
    if (truncation != null) 'truncation': truncation!.toJson(),
    if (serviceTier != null) 'service_tier': serviceTier!.toJson(),
    if (metadata != null) 'metadata': metadata,
    if (include != null) 'include': include!.map((e) => e.toJson()).toList(),
    if (stop != null) 'stop': stop,
    if (store != null) 'store': store,
  };

  Object _inputToJson() {
    if (input is String) return input;
    if (input is List<Item>) {
      return (input as List<Item>).map((e) => e.toJson()).toList();
    }
    throw StateError('Invalid input type: ${input.runtimeType}');
  }

  /// Creates a copy with replaced values.
  CreateResponseRequest copyWith({
    String? model,
    Object? input,
    Object? instructions = unsetCopyWithValue,
    Object? tools = unsetCopyWithValue,
    Object? toolChoice = unsetCopyWithValue,
    Object? previousResponseId = unsetCopyWithValue,
    Object? maxOutputTokens = unsetCopyWithValue,
    Object? temperature = unsetCopyWithValue,
    Object? topP = unsetCopyWithValue,
    Object? stream = unsetCopyWithValue,
    Object? reasoning = unsetCopyWithValue,
    Object? text = unsetCopyWithValue,
    Object? truncation = unsetCopyWithValue,
    Object? serviceTier = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
    Object? include = unsetCopyWithValue,
    Object? stop = unsetCopyWithValue,
    Object? store = unsetCopyWithValue,
  }) {
    return CreateResponseRequest(
      model: model ?? this.model,
      input: input ?? this.input,
      instructions: instructions == unsetCopyWithValue
          ? this.instructions
          : instructions as String?,
      tools: tools == unsetCopyWithValue ? this.tools : tools as List<Tool>?,
      toolChoice: toolChoice == unsetCopyWithValue
          ? this.toolChoice
          : toolChoice as ToolChoice?,
      previousResponseId: previousResponseId == unsetCopyWithValue
          ? this.previousResponseId
          : previousResponseId as String?,
      maxOutputTokens: maxOutputTokens == unsetCopyWithValue
          ? this.maxOutputTokens
          : maxOutputTokens as int?,
      temperature: temperature == unsetCopyWithValue
          ? this.temperature
          : temperature as double?,
      topP: topP == unsetCopyWithValue ? this.topP : topP as double?,
      stream: stream == unsetCopyWithValue ? this.stream : stream as bool?,
      reasoning: reasoning == unsetCopyWithValue
          ? this.reasoning
          : reasoning as ReasoningConfig?,
      text: text == unsetCopyWithValue ? this.text : text as TextConfig?,
      truncation: truncation == unsetCopyWithValue
          ? this.truncation
          : truncation as Truncation?,
      serviceTier: serviceTier == unsetCopyWithValue
          ? this.serviceTier
          : serviceTier as ServiceTier?,
      metadata: metadata == unsetCopyWithValue
          ? this.metadata
          : metadata as Map<String, String>?,
      include: include == unsetCopyWithValue
          ? this.include
          : include as List<Include>?,
      stop: stop == unsetCopyWithValue ? this.stop : stop as List<String>?,
      store: store == unsetCopyWithValue ? this.store : store as bool?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateResponseRequest &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          input == other.input &&
          instructions == other.instructions &&
          toolChoice == other.toolChoice &&
          previousResponseId == other.previousResponseId &&
          maxOutputTokens == other.maxOutputTokens &&
          temperature == other.temperature &&
          topP == other.topP &&
          stream == other.stream &&
          reasoning == other.reasoning &&
          text == other.text &&
          truncation == other.truncation &&
          serviceTier == other.serviceTier &&
          store == other.store;

  @override
  int get hashCode => Object.hash(
    model,
    input,
    instructions,
    toolChoice,
    previousResponseId,
    maxOutputTokens,
    temperature,
    topP,
    stream,
    reasoning,
    text,
    truncation,
    serviceTier,
    store,
  );

  @override
  String toString() =>
      'CreateResponseRequest(model: $model, input: $input, ...)';
}
