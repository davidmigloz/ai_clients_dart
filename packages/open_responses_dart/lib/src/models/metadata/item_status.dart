/// The status of an item.
enum ItemStatus {
  /// Unknown status (fallback for unrecognized values).
  unknown('unknown'),

  /// Item is being processed.
  inProgress('in_progress'),

  /// Item processing completed.
  completed('completed'),

  /// Item processing incomplete.
  incomplete('incomplete');

  /// The JSON value for this status.
  final String value;

  const ItemStatus(this.value);

  /// Creates an [ItemStatus] from a JSON value.
  factory ItemStatus.fromJson(String json) {
    return ItemStatus.values.firstWhere(
      (e) => e.value == json,
      orElse: () => ItemStatus.unknown,
    );
  }

  /// Converts to JSON value.
  String toJson() => value;
}
