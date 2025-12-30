import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'model_summary.dart';

/// Response containing a list of models.
@immutable
class ListResponse {
  /// List of available models.
  final List<ModelSummary>? models;

  /// Creates a [ListResponse].
  const ListResponse({this.models});

  /// Creates a [ListResponse] from JSON.
  factory ListResponse.fromJson(Map<String, dynamic> json) => ListResponse(
    models: (json['models'] as List?)
        ?.map((e) => ModelSummary.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (models != null) 'models': models!.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  ListResponse copyWith({Object? models = unsetCopyWithValue}) {
    return ListResponse(
      models: models == unsetCopyWithValue
          ? this.models
          : models as List<ModelSummary>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListResponse && runtimeType == other.runtimeType;

  @override
  int get hashCode => models.hashCode;

  @override
  String toString() => 'ListResponse(models: ${models?.length ?? 0} models)';
}
