import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import 'field_option_count_item.dart';

/// Response containing counts for field option values.
@immutable
class FieldOptionCounts {
  /// The count items.
  final List<FieldOptionCountItem> counts;

  /// Creates a [FieldOptionCounts].
  FieldOptionCounts({required List<FieldOptionCountItem> counts})
    : counts = List.unmodifiable(counts);

  /// Creates a [FieldOptionCounts] from JSON.
  factory FieldOptionCounts.fromJson(Map<String, dynamic> json) =>
      FieldOptionCounts(
        counts:
            (json['counts'] as List?)
                ?.map(
                  (e) =>
                      FieldOptionCountItem.fromJson(e as Map<String, dynamic>),
                )
                .toList() ??
            [],
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'counts': counts.map((e) => e.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FieldOptionCounts) return false;
    if (runtimeType != other.runtimeType) return false;
    return listsEqual(counts, other.counts);
  }

  @override
  int get hashCode => listHash(counts);

  @override
  String toString() => 'FieldOptionCounts(counts: ${counts.length} items)';
}
