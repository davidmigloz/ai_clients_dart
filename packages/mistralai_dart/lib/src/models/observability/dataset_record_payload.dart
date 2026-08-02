import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// Caller-authored input object stored on a dataset record.
///
/// This schema has `additionalProperties: true` with no defined properties,
/// so the entire payload is captured as a free-form map.
@immutable
class DatasetRecordPayload {
  /// The raw payload data.
  final Map<String, dynamic> data;

  /// Creates a [DatasetRecordPayload].
  DatasetRecordPayload(Map<String, dynamic> data)
    : data = Map.unmodifiable(data);

  /// Creates a [DatasetRecordPayload] from JSON.
  factory DatasetRecordPayload.fromJson(Map<String, dynamic> json) =>
      DatasetRecordPayload(json);

  /// Converts to JSON.
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(data);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DatasetRecordPayload) return false;
    if (runtimeType != other.runtimeType) return false;
    return mapsDeepEqual(data, other.data);
  }

  @override
  int get hashCode => mapDeepHashCode(data);

  @override
  String toString() => 'DatasetRecordPayload(${data.length} keys)';
}
