import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Request for a fill-in-the-middle (FIM) completion.
///
/// FIM allows you to define the starting point of code using a [prompt],
/// and the ending point using an optional [suffix]. The model will generate
/// the code that fits in between.
@immutable
class FimCompletionRequest {
  /// The model to use for completion.
  ///
  /// Use 'codestral-latest' or a specific version like 'codestral-2405'.
  final String model;

  /// The starting point of the code (prefix).
  ///
  /// This is the code that appears before the generated content.
  final String prompt;

  /// The ending point of the code.
  ///
  /// This is the code that appears after the generated content.
  /// If provided, the model will generate code that fits between
  /// the [prompt] and [suffix].
  final String? suffix;

  /// What sampling temperature to use (0.0-1.5).
  ///
  /// Higher values make output more random, lower values more deterministic.
  final double? temperature;

  /// Nucleus sampling probability (0.0-1.0).
  ///
  /// The model considers tokens with top_p probability mass.
  final double? topP;

  /// Maximum number of tokens to generate.
  final int? maxTokens;

  /// Minimum number of tokens to generate.
  ///
  /// Useful for ensuring a minimum length of output.
  final int? minTokens;

  /// Whether to stream the response.
  final bool? stream;

  /// Stop sequences to stop generation.
  ///
  /// Can be a single string or a list of strings.
  final Object? stop;

  /// Random seed for deterministic generation.
  final int? randomSeed;

  /// Creates a [FimCompletionRequest].
  const FimCompletionRequest({
    required this.model,
    required this.prompt,
    this.suffix,
    this.temperature,
    this.topP,
    this.maxTokens,
    this.minTokens,
    this.stream,
    this.stop,
    this.randomSeed,
  });

  /// Creates a [FimCompletionRequest] from JSON.
  factory FimCompletionRequest.fromJson(Map<String, dynamic> json) =>
      FimCompletionRequest(
        model: json['model'] as String? ?? '',
        prompt: json['prompt'] as String? ?? '',
        suffix: json['suffix'] as String?,
        temperature: (json['temperature'] as num?)?.toDouble(),
        topP: (json['top_p'] as num?)?.toDouble(),
        maxTokens: json['max_tokens'] as int?,
        minTokens: json['min_tokens'] as int?,
        stream: json['stream'] as bool?,
        stop: json['stop'],
        randomSeed: json['random_seed'] as int?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'model': model,
    'prompt': prompt,
    if (suffix != null) 'suffix': suffix,
    if (temperature != null) 'temperature': temperature,
    if (topP != null) 'top_p': topP,
    if (maxTokens != null) 'max_tokens': maxTokens,
    if (minTokens != null) 'min_tokens': minTokens,
    if (stream != null) 'stream': stream,
    if (stop != null) 'stop': stop,
    if (randomSeed != null) 'random_seed': randomSeed,
  };

  /// Creates a copy with replaced values.
  FimCompletionRequest copyWith({
    String? model,
    String? prompt,
    Object? suffix = unsetCopyWithValue,
    Object? temperature = unsetCopyWithValue,
    Object? topP = unsetCopyWithValue,
    Object? maxTokens = unsetCopyWithValue,
    Object? minTokens = unsetCopyWithValue,
    Object? stream = unsetCopyWithValue,
    Object? stop = unsetCopyWithValue,
    Object? randomSeed = unsetCopyWithValue,
  }) {
    return FimCompletionRequest(
      model: model ?? this.model,
      prompt: prompt ?? this.prompt,
      suffix: suffix == unsetCopyWithValue ? this.suffix : suffix as String?,
      temperature: temperature == unsetCopyWithValue
          ? this.temperature
          : temperature as double?,
      topP: topP == unsetCopyWithValue ? this.topP : topP as double?,
      maxTokens: maxTokens == unsetCopyWithValue
          ? this.maxTokens
          : maxTokens as int?,
      minTokens: minTokens == unsetCopyWithValue
          ? this.minTokens
          : minTokens as int?,
      stream: stream == unsetCopyWithValue ? this.stream : stream as bool?,
      stop: stop == unsetCopyWithValue ? this.stop : stop,
      randomSeed: randomSeed == unsetCopyWithValue
          ? this.randomSeed
          : randomSeed as int?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FimCompletionRequest &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          prompt == other.prompt &&
          suffix == other.suffix;

  @override
  int get hashCode => Object.hash(model, prompt, suffix);

  @override
  String toString() =>
      'FimCompletionRequest(model: $model, prompt: ${prompt.length} chars)';
}
