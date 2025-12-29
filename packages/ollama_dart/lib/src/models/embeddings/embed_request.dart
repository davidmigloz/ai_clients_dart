import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../metadata/model_options.dart';

/// Request for generating embeddings.
@immutable
class EmbedRequest {
  /// Model name.
  final String model;

  /// Text or array of texts to generate embeddings for.
  ///
  /// Can be a [String] or [List<String>].
  final Object input;

  /// If true, truncate inputs that exceed the context window.
  final bool? truncate;

  /// Number of dimensions to generate embeddings for.
  final int? dimensions;

  /// Model keep-alive duration.
  final String? keepAlive;

  /// Runtime options for embedding generation.
  final ModelOptions? options;

  /// Creates an [EmbedRequest].
  const EmbedRequest({
    required this.model,
    required this.input,
    this.truncate,
    this.dimensions,
    this.keepAlive,
    this.options,
  });

  /// Creates an [EmbedRequest] from JSON.
  factory EmbedRequest.fromJson(Map<String, dynamic> json) => EmbedRequest(
    model: json['model'] as String,
    input: json['input'] as Object,
    truncate: json['truncate'] as bool?,
    dimensions: json['dimensions'] as int?,
    keepAlive: json['keep_alive'] as String?,
    options: json['options'] != null
        ? ModelOptions.fromJson(json['options'] as Map<String, dynamic>)
        : null,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'model': model,
    'input': input,
    if (truncate != null) 'truncate': truncate,
    if (dimensions != null) 'dimensions': dimensions,
    if (keepAlive != null) 'keep_alive': keepAlive,
    if (options != null) 'options': options!.toJson(),
  };

  /// Creates a copy with replaced values.
  EmbedRequest copyWith({
    String? model,
    Object? input,
    Object? truncate = unsetCopyWithValue,
    Object? dimensions = unsetCopyWithValue,
    Object? keepAlive = unsetCopyWithValue,
    Object? options = unsetCopyWithValue,
  }) {
    return EmbedRequest(
      model: model ?? this.model,
      input: input ?? this.input,
      truncate: truncate == unsetCopyWithValue
          ? this.truncate
          : truncate as bool?,
      dimensions: dimensions == unsetCopyWithValue
          ? this.dimensions
          : dimensions as int?,
      keepAlive: keepAlive == unsetCopyWithValue
          ? this.keepAlive
          : keepAlive as String?,
      options: options == unsetCopyWithValue
          ? this.options
          : options as ModelOptions?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmbedRequest &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          input == other.input;

  @override
  int get hashCode => Object.hash(model, input);

  @override
  String toString() => 'EmbedRequest(model: $model, input: $input)';
}
