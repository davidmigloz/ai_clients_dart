import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Request to pull/download a model.
@immutable
class PullRequest {
  /// Name of the model to download.
  final String model;

  /// Allow downloading over insecure connections.
  final bool? insecure;

  /// Stream progress updates.
  final bool? stream;

  /// Creates a [PullRequest].
  const PullRequest({required this.model, this.insecure, this.stream});

  /// Creates a [PullRequest] from JSON.
  factory PullRequest.fromJson(Map<String, dynamic> json) => PullRequest(
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
  PullRequest copyWith({
    String? model,
    Object? insecure = unsetCopyWithValue,
    Object? stream = unsetCopyWithValue,
  }) {
    return PullRequest(
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
      other is PullRequest &&
          runtimeType == other.runtimeType &&
          model == other.model;

  @override
  int get hashCode => model.hashCode;

  @override
  String toString() => 'PullRequest(model: $model)';
}
