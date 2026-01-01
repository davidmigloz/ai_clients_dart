import 'package:meta/meta.dart';

import '../../utils/equality_helpers.dart';
import 'ft_classifier_loss_function.dart';

/// Classifier target configuration for a fine-tuned classifier model.
@immutable
class ClassifierTargetOut {
  /// The name of the classifier target.
  final String name;

  /// The labels for classification.
  final List<String> labels;

  /// The weight of this target in the loss function.
  final double weight;

  /// The loss function used for this target.
  final FTClassifierLossFunction lossFunction;

  /// Creates [ClassifierTargetOut].
  const ClassifierTargetOut({
    required this.name,
    required this.labels,
    required this.weight,
    required this.lossFunction,
  });

  /// Creates from JSON.
  factory ClassifierTargetOut.fromJson(Map<String, dynamic> json) =>
      ClassifierTargetOut(
        name: json['name'] as String,
        labels: (json['labels'] as List).cast<String>(),
        weight: (json['weight'] as num).toDouble(),
        lossFunction: FTClassifierLossFunction.fromString(
          json['loss_function'] as String?,
        ),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    'labels': labels,
    'weight': weight,
    'loss_function': lossFunction.value,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassifierTargetOut &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          listEquals(labels, other.labels) &&
          weight == other.weight &&
          lossFunction == other.lossFunction;

  @override
  int get hashCode =>
      Object.hash(name, Object.hashAll(labels), weight, lossFunction);

  @override
  String toString() =>
      'ClassifierTargetOut('
      'name: $name, labels: $labels, weight: $weight, '
      'lossFunction: $lossFunction)';
}
