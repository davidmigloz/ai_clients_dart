import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'running_model.dart';

/// Response containing currently running models.
@immutable
class PsResponse {
  /// Currently running models.
  final List<RunningModel>? models;

  /// Creates a [PsResponse].
  const PsResponse({this.models});

  /// Creates a [PsResponse] from JSON.
  factory PsResponse.fromJson(Map<String, dynamic> json) => PsResponse(
    models: (json['models'] as List?)
        ?.map((e) => RunningModel.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (models != null) 'models': models!.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  PsResponse copyWith({Object? models = unsetCopyWithValue}) {
    return PsResponse(
      models: models == unsetCopyWithValue
          ? this.models
          : models as List<RunningModel>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PsResponse && runtimeType == other.runtimeType;

  @override
  int get hashCode => models.hashCode;

  @override
  String toString() =>
      'PsResponse(models: ${models?.length ?? 0} running models)';
}
