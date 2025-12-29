import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Runtime options that control text generation.
@immutable
class ModelOptions {
  /// Random seed used for reproducible outputs.
  final int? seed;

  /// Controls randomness in generation (higher = more random).
  final double? temperature;

  /// Limits next token selection to the K most likely.
  final int? topK;

  /// Cumulative probability threshold for nucleus sampling.
  final double? topP;

  /// Minimum probability threshold for token selection.
  final double? minP;

  /// Stop sequences that will halt generation.
  ///
  /// Can be a single string or a list of strings.
  final Object? stop;

  /// Context length size (number of tokens).
  final int? numCtx;

  /// Maximum number of tokens to generate.
  final int? numPredict;

  /// Creates a [ModelOptions].
  const ModelOptions({
    this.seed,
    this.temperature,
    this.topK,
    this.topP,
    this.minP,
    this.stop,
    this.numCtx,
    this.numPredict,
  });

  /// Creates a [ModelOptions] from JSON.
  factory ModelOptions.fromJson(Map<String, dynamic> json) => ModelOptions(
    seed: json['seed'] as int?,
    temperature: (json['temperature'] as num?)?.toDouble(),
    topK: json['top_k'] as int?,
    topP: (json['top_p'] as num?)?.toDouble(),
    minP: (json['min_p'] as num?)?.toDouble(),
    stop: json['stop'],
    numCtx: json['num_ctx'] as int?,
    numPredict: json['num_predict'] as int?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (seed != null) 'seed': seed,
    if (temperature != null) 'temperature': temperature,
    if (topK != null) 'top_k': topK,
    if (topP != null) 'top_p': topP,
    if (minP != null) 'min_p': minP,
    if (stop != null) 'stop': stop,
    if (numCtx != null) 'num_ctx': numCtx,
    if (numPredict != null) 'num_predict': numPredict,
  };

  /// Creates a copy with replaced values.
  ModelOptions copyWith({
    Object? seed = unsetCopyWithValue,
    Object? temperature = unsetCopyWithValue,
    Object? topK = unsetCopyWithValue,
    Object? topP = unsetCopyWithValue,
    Object? minP = unsetCopyWithValue,
    Object? stop = unsetCopyWithValue,
    Object? numCtx = unsetCopyWithValue,
    Object? numPredict = unsetCopyWithValue,
  }) {
    return ModelOptions(
      seed: seed == unsetCopyWithValue ? this.seed : seed as int?,
      temperature: temperature == unsetCopyWithValue
          ? this.temperature
          : temperature as double?,
      topK: topK == unsetCopyWithValue ? this.topK : topK as int?,
      topP: topP == unsetCopyWithValue ? this.topP : topP as double?,
      minP: minP == unsetCopyWithValue ? this.minP : minP as double?,
      stop: stop == unsetCopyWithValue ? this.stop : stop,
      numCtx: numCtx == unsetCopyWithValue ? this.numCtx : numCtx as int?,
      numPredict: numPredict == unsetCopyWithValue
          ? this.numPredict
          : numPredict as int?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelOptions &&
          runtimeType == other.runtimeType &&
          seed == other.seed &&
          temperature == other.temperature &&
          topK == other.topK &&
          topP == other.topP &&
          minP == other.minP &&
          stop == other.stop &&
          numCtx == other.numCtx &&
          numPredict == other.numPredict;

  @override
  int get hashCode => Object.hash(
    seed,
    temperature,
    topK,
    topP,
    minP,
    stop,
    numCtx,
    numPredict,
  );

  @override
  String toString() =>
      'ModelOptions('
      'seed: $seed, '
      'temperature: $temperature, '
      'topK: $topK, '
      'topP: $topP, '
      'minP: $minP, '
      'stop: $stop, '
      'numCtx: $numCtx, '
      'numPredict: $numPredict)';
}
