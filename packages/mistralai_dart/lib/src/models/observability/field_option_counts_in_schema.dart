import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'filter_payload.dart';

/// Request to get counts for field option values.
@immutable
class FieldOptionCountsInSchema {
  /// Optional filter parameters.
  final FilterPayload? filterParams;

  /// Creates a [FieldOptionCountsInSchema].
  const FieldOptionCountsInSchema({this.filterParams});

  /// Creates a [FieldOptionCountsInSchema] from JSON.
  factory FieldOptionCountsInSchema.fromJson(Map<String, dynamic> json) =>
      FieldOptionCountsInSchema(
        filterParams: json['filter_params'] != null
            ? FilterPayload.fromJson(
                json['filter_params'] as Map<String, dynamic>,
              )
            : null,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (filterParams != null) 'filter_params': filterParams!.toJson(),
  };

  /// Creates a copy with replaced values.
  FieldOptionCountsInSchema copyWith({
    Object? filterParams = unsetCopyWithValue,
  }) {
    return FieldOptionCountsInSchema(
      filterParams: filterParams == unsetCopyWithValue
          ? this.filterParams
          : filterParams as FilterPayload?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FieldOptionCountsInSchema) return false;
    if (runtimeType != other.runtimeType) return false;
    return filterParams == other.filterParams;
  }

  @override
  int get hashCode => filterParams.hashCode;

  @override
  String toString() => 'FieldOptionCountsInSchema(filterParams: $filterParams)';
}
