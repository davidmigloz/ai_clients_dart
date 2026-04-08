import 'package:meta/meta.dart';

/// A count for a specific field option value.
@immutable
class FieldOptionCountItem {
  /// The option value.
  final String value;

  /// The count of occurrences.
  final int count;

  /// Creates a [FieldOptionCountItem].
  const FieldOptionCountItem({required this.value, required this.count});

  /// Creates a [FieldOptionCountItem] from JSON.
  factory FieldOptionCountItem.fromJson(Map<String, dynamic> json) =>
      FieldOptionCountItem(
        value: json['value'] as String? ?? '',
        count: json['count'] as int? ?? 0,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'value': value, 'count': count};

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FieldOptionCountItem) return false;
    if (runtimeType != other.runtimeType) return false;
    return value == other.value && count == other.count;
  }

  @override
  int get hashCode => Object.hash(value, count);

  @override
  String toString() => 'FieldOptionCountItem(value: $value, count: $count)';
}
