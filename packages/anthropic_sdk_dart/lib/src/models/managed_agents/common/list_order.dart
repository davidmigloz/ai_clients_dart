/// Sort order for paginated list operations.
enum ListOrder {
  /// Ascending order (oldest first).
  asc('asc'),

  /// Descending order (newest first).
  desc('desc'),

  /// Unknown order — fallback for unrecognized values.
  unknown('unknown');

  const ListOrder(this.value);

  /// JSON value for this list order.
  final String value;

  /// Parses a [ListOrder] from JSON.
  static ListOrder fromJson(String value) => switch (value) {
    'asc' => ListOrder.asc,
    'desc' => ListOrder.desc,
    _ => ListOrder.unknown,
  };

  /// Converts this list order to JSON.
  String toJson() => value;
}
