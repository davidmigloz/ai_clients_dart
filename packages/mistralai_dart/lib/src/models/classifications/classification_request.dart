import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Request to classify text.
@immutable
class ClassificationRequest {
  /// The model to use for classification.
  final String model;

  /// Input texts, including the text of a scalar input when present.
  final List<String> input;

  /// Optional metadata for the request.
  final Map<String, dynamic>? metadata;

  final bool _scalarInput;

  /// Creates a request with an array of input texts.
  const ClassificationRequest({
    this.model = 'mistral-moderation-2603',
    required this.input,
    this.metadata,
  }) : _scalarInput = false;

  ClassificationRequest._text({
    required this.model,
    required String text,
    this.metadata,
  }) : input = [text],
       _scalarInput = true;

  /// Creates a request for one input, serialized as a one-element array.
  factory ClassificationRequest.single({
    String model = 'mistral-moderation-2603',
    required String input,
    Map<String, dynamic>? metadata,
  }) => ClassificationRequest(model: model, input: [input], metadata: metadata);

  /// Creates a request for one input, serialized as a string.
  factory ClassificationRequest.text({
    String model = 'mistral-moderation-2603',
    required String input,
    Map<String, dynamic>? metadata,
  }) => ClassificationRequest._text(
    model: model,
    text: input,
    metadata: metadata,
  );

  /// Creates a [ClassificationRequest] from JSON.
  factory ClassificationRequest.fromJson(Map<String, dynamic> json) {
    final model = json['model'] as String? ?? 'mistral-moderation-2603';
    final metadata = json['metadata'] as Map<String, dynamic>?;
    final input = json['input'];
    return switch (input) {
      final String text => ClassificationRequest._text(
        model: model,
        text: text,
        metadata: metadata,
      ),
      final List<Object?> texts => ClassificationRequest(
        model: model,
        input: List<String>.from(texts),
        metadata: metadata,
      ),
      _ => throw const FormatException(
        'Expected a string or array of text inputs',
      ),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'input': _scalarInput ? input.single : input,
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Creates a copy with replaced values.
  ///
  /// Passing [input] uses the array representation.
  ClassificationRequest copyWith({
    String? model,
    List<String>? input,
    Object? metadata = unsetCopyWithValue,
  }) {
    final nextModel = model ?? this.model;
    final nextMetadata = metadata == unsetCopyWithValue
        ? this.metadata
        : metadata == null
        ? null
        : Map<String, dynamic>.from(metadata as Map<Object?, Object?>);

    return input == null && _scalarInput
        ? ClassificationRequest._text(
            model: nextModel,
            text: this.input.single,
            metadata: nextMetadata,
          )
        : ClassificationRequest(
            model: nextModel,
            input: input ?? this.input,
            metadata: nextMetadata,
          );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassificationRequest &&
          model == other.model &&
          _scalarInput == other._scalarInput &&
          listsEqual(input, other.input) &&
          mapsDeepEqual(metadata, other.metadata);

  @override
  int get hashCode => Object.hash(
    model,
    _scalarInput,
    listHash(input),

    mapDeepHashCode(metadata),
  );

  @override
  String toString() =>
      'ClassificationRequest(model: $model, inputs: ${input.length}, '
      'metadata: ${metadata?.length})';
}
