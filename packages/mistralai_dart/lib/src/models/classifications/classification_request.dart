import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// Request for text classification.
@immutable
class ClassificationRequest {
  /// The model to use for classification.
  final String model;

  /// The input text(s) to classify.
  final List<String> input;

  /// Optional metadata for the request.
  final Map<String, dynamic>? metadata;

  /// Creates a [ClassificationRequest].
  const ClassificationRequest({
    this.model = 'mistral-moderation-latest',
    required this.input,
    this.metadata,
  });

  /// Creates a [ClassificationRequest] for a single text input.
  factory ClassificationRequest.single({
    String model = 'mistral-moderation-latest',
    required String input,
  }) {
    return ClassificationRequest(model: model, input: [input]);
  }

  /// Creates a [ClassificationRequest] from JSON.
  factory ClassificationRequest.fromJson(Map<String, dynamic> json) {
    final inputValue = json['input'];
    final List<String> inputs;
    if (inputValue is String) {
      inputs = [inputValue];
    } else if (inputValue is List) {
      inputs = inputValue.map((e) => e.toString()).toList();
    } else {
      inputs = [];
    }

    return ClassificationRequest(
      model: json['model'] as String? ?? 'mistral-moderation-latest',
      input: inputs,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'model': model,
    'input': input,
    if (metadata != null) 'metadata': metadata,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassificationRequest &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          listsEqual(input, other.input) &&
          mapsEqual(metadata, other.metadata);

  @override
  int get hashCode =>
      Object.hash(model, Object.hashAll(input), mapHash(metadata));

  @override
  String toString() =>
      'ClassificationRequest(model: $model, inputs: ${input.length})';
}
