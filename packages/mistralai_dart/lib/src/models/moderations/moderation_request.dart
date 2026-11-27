import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Request to moderate text.
@immutable
class ModerationRequest {
  /// The model to use for moderation.
  final String model;

  /// Input texts, including the text of a scalar input when present.
  final List<String> input;

  /// Optional metadata for the request.
  final Map<String, dynamic>? metadata;

  /// Named moderation queries. Omit to use the model's default categories.
  final Map<String, String>? queries;

  final bool _scalarInput;

  /// Creates a request with an array of input texts.
  const ModerationRequest({
    this.model = 'mistral-moderation-2603',
    required this.input,
    this.metadata,
    this.queries,
  }) : _scalarInput = false;

  ModerationRequest._text({
    required this.model,
    required String text,
    this.metadata,
    this.queries,
  }) : input = [text],
       _scalarInput = true;

  /// Creates a request for one input, serialized as a one-element array.
  factory ModerationRequest.single({
    String model = 'mistral-moderation-2603',
    required String input,
    Map<String, dynamic>? metadata,
    Map<String, String>? queries,
  }) => ModerationRequest(
    model: model,
    input: [input],
    metadata: metadata,
    queries: queries,
  );

  /// Creates a request for one input, serialized as a string.
  factory ModerationRequest.text({
    String model = 'mistral-moderation-2603',
    required String input,
    Map<String, dynamic>? metadata,
    Map<String, String>? queries,
  }) => ModerationRequest._text(
    model: model,
    text: input,
    metadata: metadata,
    queries: queries,
  );

  /// Creates a [ModerationRequest] from JSON.
  factory ModerationRequest.fromJson(Map<String, dynamic> json) {
    final model = json['model'] as String? ?? 'mistral-moderation-2603';
    final metadata = json['metadata'] as Map<String, dynamic>?;
    final queriesJson = json['queries'];
    final queries = queriesJson == null
        ? null
        : Map<String, String>.from(queriesJson as Map<Object?, Object?>);
    if (queries != null && queries.isEmpty) {
      throw const FormatException('Moderation queries must not be empty');
    }
    final input = json['input'];
    return switch (input) {
      final String text => ModerationRequest._text(
        model: model,
        text: text,
        metadata: metadata,
        queries: queries,
      ),
      final List<Object?> texts => ModerationRequest(
        model: model,
        input: List<String>.from(texts),
        metadata: metadata,
        queries: queries,
      ),
      _ => throw const FormatException(
        'Expected a string or array of text inputs',
      ),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() {
    if (queries != null && queries!.isEmpty) {
      throw ArgumentError('Moderation queries must not be empty');
    }

    return {
      'model': model,
      'input': _scalarInput ? input.single : input,
      if (metadata != null) 'metadata': metadata,
      if (queries != null) 'queries': queries,
    };
  }

  /// Creates a copy with replaced values.
  ///
  /// Passing [input] uses the array representation.
  ModerationRequest copyWith({
    String? model,
    List<String>? input,
    Object? metadata = unsetCopyWithValue,
    Object? queries = unsetCopyWithValue,
  }) {
    final nextModel = model ?? this.model;
    final nextMetadata = metadata == unsetCopyWithValue
        ? this.metadata
        : metadata == null
        ? null
        : Map<String, dynamic>.from(metadata as Map<Object?, Object?>);
    final nextQueries = queries == unsetCopyWithValue
        ? this.queries
        : queries == null
        ? null
        : Map<String, String>.from(queries as Map<Object?, Object?>);
    return input == null && _scalarInput
        ? ModerationRequest._text(
            model: nextModel,
            text: this.input.single,
            metadata: nextMetadata,
            queries: nextQueries,
          )
        : ModerationRequest(
            model: nextModel,
            input: input ?? this.input,
            metadata: nextMetadata,
            queries: nextQueries,
          );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModerationRequest &&
          model == other.model &&
          _scalarInput == other._scalarInput &&
          listsEqual(input, other.input) &&
          mapsEqual(queries, other.queries) &&
          mapsDeepEqual(metadata, other.metadata);

  @override
  int get hashCode => Object.hash(
    model,
    _scalarInput,
    listHash(input),
    mapHash(queries),
    mapDeepHashCode(metadata),
  );

  @override
  String toString() =>
      'ModerationRequest(model: $model, inputs: ${input.length}, '
      'queries: ${queries?.length}, '
      'metadata: ${metadata?.length})';
}
