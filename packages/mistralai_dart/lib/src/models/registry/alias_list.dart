import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Presence wrapper for a set of alias labels on update RPCs.
///
/// As a message field it carries presence, so callers can distinguish
/// "leave aliases unchanged" (field omitted) from "clear all aliases"
/// (field set, empty [values]).
@immutable
class AliasList {
  /// The alias labels.
  final List<String>? values;

  /// Creates an [AliasList].
  const AliasList({this.values});

  /// Creates an [AliasList] from JSON.
  factory AliasList.fromJson(Map<String, dynamic> json) => AliasList(
    values: (json['values'] as List?)?.map((e) => e as String).toList(),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {if (values != null) 'values': values};

  /// Creates a copy with the specified fields replaced.
  ///
  /// Pass `null` explicitly to clear nullable fields.
  AliasList copyWith({Object? values = unsetCopyWithValue}) => AliasList(
    values: values == unsetCopyWithValue
        ? this.values
        : values as List<String>?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AliasList &&
          runtimeType == other.runtimeType &&
          listsEqual(values, other.values);

  @override
  int get hashCode => listHash(values);

  @override
  String toString() => 'AliasList(values: $values)';
}
