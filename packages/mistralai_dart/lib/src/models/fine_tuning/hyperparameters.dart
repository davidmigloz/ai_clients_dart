import 'package:meta/meta.dart';

/// Hyperparameters for fine-tuning.
@immutable
class Hyperparameters {
  /// Number of training steps. Recommended range is [1, 10].
  final int? trainingSteps;

  /// Learning rate multiplier.
  final double? learningRate;

  /// Warmup fraction for learning rate.
  final double? warmupFraction;

  /// Weight decay for regularization.
  final double? weightDecay;

  /// Creates [Hyperparameters].
  const Hyperparameters({
    this.trainingSteps,
    this.learningRate,
    this.warmupFraction,
    this.weightDecay,
  });

  /// Creates [Hyperparameters] from JSON.
  factory Hyperparameters.fromJson(Map<String, dynamic> json) =>
      Hyperparameters(
        trainingSteps: json['training_steps'] as int?,
        learningRate: (json['learning_rate'] as num?)?.toDouble(),
        warmupFraction: (json['warmup_fraction'] as num?)?.toDouble(),
        weightDecay: (json['weight_decay'] as num?)?.toDouble(),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (trainingSteps != null) 'training_steps': trainingSteps,
    if (learningRate != null) 'learning_rate': learningRate,
    if (warmupFraction != null) 'warmup_fraction': warmupFraction,
    if (weightDecay != null) 'weight_decay': weightDecay,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Hyperparameters &&
          runtimeType == other.runtimeType &&
          trainingSteps == other.trainingSteps &&
          learningRate == other.learningRate &&
          warmupFraction == other.warmupFraction &&
          weightDecay == other.weightDecay;

  @override
  int get hashCode =>
      Object.hash(trainingSteps, learningRate, warmupFraction, weightDecay);

  @override
  String toString() =>
      'Hyperparameters(trainingSteps: $trainingSteps, '
      'learningRate: $learningRate)';
}
