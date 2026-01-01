import 'package:meta/meta.dart';

/// A training checkpoint from a fine-tuning job.
@immutable
class Checkpoint {
  /// Unique identifier for the checkpoint.
  final String name;

  /// Step number at which this checkpoint was created.
  final int stepNumber;

  /// Training loss at this checkpoint.
  final double? trainingLoss;

  /// Validation loss at this checkpoint.
  final double? validationLoss;

  /// Training loss at this checkpoint (alternative field).
  final double? metrics;

  /// Timestamp when the checkpoint was created.
  final DateTime? createdAt;

  /// Creates a [Checkpoint].
  const Checkpoint({
    required this.name,
    required this.stepNumber,
    this.trainingLoss,
    this.validationLoss,
    this.metrics,
    this.createdAt,
  });

  /// Creates a [Checkpoint] from JSON.
  factory Checkpoint.fromJson(Map<String, dynamic> json) => Checkpoint(
    name: json['name'] as String? ?? '',
    stepNumber: json['step_number'] as int? ?? 0,
    trainingLoss: (json['training_loss'] as num?)?.toDouble(),
    validationLoss: (json['validation_loss'] as num?)?.toDouble(),
    metrics: (json['metrics'] as num?)?.toDouble(),
    createdAt: json['created_at'] != null
        ? DateTime.tryParse(json['created_at'] as String)
        : null,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    'step_number': stepNumber,
    if (trainingLoss != null) 'training_loss': trainingLoss,
    if (validationLoss != null) 'validation_loss': validationLoss,
    if (metrics != null) 'metrics': metrics,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Checkpoint &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          stepNumber == other.stepNumber;

  @override
  int get hashCode => Object.hash(name, stepNumber);

  @override
  String toString() =>
      'Checkpoint(name: $name, stepNumber: $stepNumber, loss: $trainingLoss)';
}
