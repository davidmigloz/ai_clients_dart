import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Request to show model details.
@immutable
class ShowRequest {
  /// Model name to show.
  final String model;

  /// If true, includes large verbose fields in the response.
  final bool? verbose;

  /// Creates a [ShowRequest].
  const ShowRequest({required this.model, this.verbose});

  /// Creates a [ShowRequest] from JSON.
  factory ShowRequest.fromJson(Map<String, dynamic> json) => ShowRequest(
    model: json['model'] as String,
    verbose: json['verbose'] as bool?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'model': model,
    if (verbose != null) 'verbose': verbose,
  };

  /// Creates a copy with replaced values.
  ShowRequest copyWith({String? model, Object? verbose = unsetCopyWithValue}) {
    return ShowRequest(
      model: model ?? this.model,
      verbose: verbose == unsetCopyWithValue ? this.verbose : verbose as bool?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShowRequest &&
          runtimeType == other.runtimeType &&
          model == other.model;

  @override
  int get hashCode => model.hashCode;

  @override
  String toString() => 'ShowRequest(model: $model)';
}
