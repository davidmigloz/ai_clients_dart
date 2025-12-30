import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Request to push/publish a model.
@immutable
class PushRequest {
  /// Name of the model to publish.
  final String model;

  /// Allow publishing over insecure connections.
  final bool? insecure;

  /// Stream progress updates.
  final bool? stream;

  /// Creates a [PushRequest].
  const PushRequest({required this.model, this.insecure, this.stream});

  /// Creates a [PushRequest] from JSON.
  factory PushRequest.fromJson(Map<String, dynamic> json) => PushRequest(
    model: json['model'] as String,
    insecure: json['insecure'] as bool?,
    stream: json['stream'] as bool?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'model': model,
    if (insecure != null) 'insecure': insecure,
    if (stream != null) 'stream': stream,
  };

  /// Creates a copy with replaced values.
  PushRequest copyWith({
    String? model,
    Object? insecure = unsetCopyWithValue,
    Object? stream = unsetCopyWithValue,
  }) {
    return PushRequest(
      model: model ?? this.model,
      insecure: insecure == unsetCopyWithValue
          ? this.insecure
          : insecure as bool?,
      stream: stream == unsetCopyWithValue ? this.stream : stream as bool?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PushRequest &&
          runtimeType == other.runtimeType &&
          model == other.model;

  @override
  int get hashCode => model.hashCode;

  @override
  String toString() => 'PushRequest(model: $model)';
}
