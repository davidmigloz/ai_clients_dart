import 'package:meta/meta.dart';

import '../common/finish_reason.dart';
import '../common/logprobs.dart';
import '../common/usage.dart';
import 'completion_prompt.dart';
import 'stop_sequence.dart';

/// A request to generate completions (legacy API).
///
/// **Note:** This API is deprecated. Use chat completions for new applications.
///
/// ## Example
///
/// ```dart
/// final request = CompletionRequest(
///   model: 'gpt-3.5-turbo-instruct',
///   prompt: 'Say this is a test',
/// );
/// ```
@immutable
class CompletionRequest {
  /// Creates a [CompletionRequest].
  const CompletionRequest({
    required this.model,
    this.prompt,
    this.bestOf,
    this.echo,
    this.frequencyPenalty,
    this.logitBias,
    this.logprobs,
    this.maxTokens,
    this.n,
    this.presencePenalty,
    this.seed,
    this.stop,
    this.stream,
    this.streamOptions,
    this.suffix,
    this.temperature,
    this.topP,
    this.user,
  });

  /// Creates a [CompletionRequest] from JSON.
  factory CompletionRequest.fromJson(Map<String, dynamic> json) {
    return CompletionRequest(
      model: json['model'] as String,
      prompt: json['prompt'] != null
          ? CompletionPrompt.fromJson(json['prompt'] as Object)
          : null,
      bestOf: json['best_of'] as int?,
      echo: json['echo'] as bool?,
      frequencyPenalty: (json['frequency_penalty'] as num?)?.toDouble(),
      logitBias: (json['logit_bias'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, (v as num).toInt()),
      ),
      logprobs: json['logprobs'] as int?,
      maxTokens: json['max_tokens'] as int?,
      n: json['n'] as int?,
      presencePenalty: (json['presence_penalty'] as num?)?.toDouble(),
      seed: json['seed'] as int?,
      stop: json['stop'] != null
          ? StopSequence.fromJson(json['stop'] as Object)
          : null,
      stream: json['stream'] as bool?,
      streamOptions: json['stream_options'] as Map<String, dynamic>?,
      suffix: json['suffix'] as String?,
      temperature: (json['temperature'] as num?)?.toDouble(),
      topP: (json['top_p'] as num?)?.toDouble(),
      user: json['user'] as String?,
    );
  }

  /// The model to use.
  ///
  /// Currently `gpt-3.5-turbo-instruct` is the main supported model.
  final String model;

  /// The prompt(s) to complete.
  final CompletionPrompt? prompt;

  /// Generates `best_of` completions and returns the best.
  final int? bestOf;

  /// Echo back the prompt in addition to the completion.
  final bool? echo;

  /// Penalty for frequency of tokens.
  final double? frequencyPenalty;

  /// Modify token likelihoods.
  final Map<String, int>? logitBias;

  /// Include log probabilities of the top tokens.
  final int? logprobs;

  /// Maximum tokens to generate.
  final int? maxTokens;

  /// Number of completions to generate.
  final int? n;

  /// Penalty for presence of tokens.
  final double? presencePenalty;

  /// Random seed for deterministic output.
  final int? seed;

  /// Stop sequences.
  final StopSequence? stop;

  /// Whether to stream the response.
  final bool? stream;

  /// Stream options.
  final Map<String, dynamic>? streamOptions;

  /// The suffix after the completion.
  final String? suffix;

  /// Sampling temperature.
  final double? temperature;

  /// Nucleus sampling parameter.
  final double? topP;

  /// A unique user identifier.
  final String? user;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'model': model,
    if (prompt != null) 'prompt': prompt!.toJson(),
    if (bestOf != null) 'best_of': bestOf,
    if (echo != null) 'echo': echo,
    if (frequencyPenalty != null) 'frequency_penalty': frequencyPenalty,
    if (logitBias != null) 'logit_bias': logitBias,
    if (logprobs != null) 'logprobs': logprobs,
    if (maxTokens != null) 'max_tokens': maxTokens,
    if (n != null) 'n': n,
    if (presencePenalty != null) 'presence_penalty': presencePenalty,
    if (seed != null) 'seed': seed,
    if (stop != null) 'stop': stop!.toJson(),
    if (stream != null) 'stream': stream,
    if (streamOptions != null) 'stream_options': streamOptions,
    if (suffix != null) 'suffix': suffix,
    if (temperature != null) 'temperature': temperature,
    if (topP != null) 'top_p': topP,
    if (user != null) 'user': user,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompletionRequest &&
          runtimeType == other.runtimeType &&
          model == other.model;

  @override
  int get hashCode => model.hashCode;

  @override
  String toString() => 'CompletionRequest(model: $model)';
}

/// A completion response (legacy API).
@immutable
class Completion {
  /// Creates a [Completion].
  const Completion({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.choices,
    required this.usage,
    this.systemFingerprint,
  });

  /// Creates a [Completion] from JSON.
  factory Completion.fromJson(Map<String, dynamic> json) {
    return Completion(
      id: json['id'] as String,
      object: json['object'] as String,
      created: json['created'] as int,
      model: json['model'] as String,
      choices: (json['choices'] as List<dynamic>)
          .map((e) => CompletionChoice.fromJson(e as Map<String, dynamic>))
          .toList(),
      usage: Usage.fromJson(json['usage'] as Map<String, dynamic>),
      systemFingerprint: json['system_fingerprint'] as String?,
    );
  }

  /// The completion ID.
  final String id;

  /// The object type (always "text_completion").
  final String object;

  /// The Unix timestamp.
  final int created;

  /// The model used.
  final String model;

  /// The completion choices.
  final List<CompletionChoice> choices;

  /// Token usage statistics.
  final Usage usage;

  /// The system fingerprint.
  final String? systemFingerprint;

  /// Gets the text of the first choice.
  String get text => choices.first.text;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'created': created,
    'model': model,
    'choices': choices.map((c) => c.toJson()).toList(),
    'usage': usage.toJson(),
    if (systemFingerprint != null) 'system_fingerprint': systemFingerprint,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Completion && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Completion(id: $id, model: $model)';
}

/// A choice in a completion response.
@immutable
class CompletionChoice {
  /// Creates a [CompletionChoice].
  const CompletionChoice({
    required this.index,
    required this.text,
    this.logprobs,
    this.finishReason,
  });

  /// Creates a [CompletionChoice] from JSON.
  factory CompletionChoice.fromJson(Map<String, dynamic> json) {
    return CompletionChoice(
      index: json['index'] as int,
      text: json['text'] as String,
      logprobs: json['logprobs'] != null
          ? Logprobs.fromJson(json['logprobs'] as Map<String, dynamic>)
          : null,
      finishReason: json['finish_reason'] != null
          ? FinishReason.fromJson(json['finish_reason'] as String)
          : null,
    );
  }

  /// The choice index.
  final int index;

  /// The generated text.
  final String text;

  /// Log probability information.
  final Logprobs? logprobs;

  /// The reason the model stopped generating.
  final FinishReason? finishReason;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'index': index,
    'text': text,
    if (logprobs != null) 'logprobs': logprobs!.toJson(),
    if (finishReason != null) 'finish_reason': finishReason!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompletionChoice &&
          runtimeType == other.runtimeType &&
          index == other.index &&
          text == other.text;

  @override
  int get hashCode => Object.hash(index, text);

  @override
  String toString() => 'CompletionChoice(index: $index)';
}
