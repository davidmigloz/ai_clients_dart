/// Read level for consistency vs performance tradeoffs.
///
/// Controls whether queries read from the index only (faster, but may miss
/// recently added data) or also include the write-ahead log (slower, but
/// fully consistent).
enum ReadLevel {
  /// Read from both the index and the write-ahead log.
  indexAndWal('index_and_wal'),

  /// Read from the index only (faster, may miss unindexed data).
  indexOnly('index_only'),

  /// Unknown or unsupported read level value.
  unknown('unknown');

  const ReadLevel(this.value);

  /// The API string value.
  final String value;

  /// Creates a [ReadLevel] from an API string value.
  ///
  /// Returns [ReadLevel.unknown] for unrecognized values.
  factory ReadLevel.fromJson(String value) {
    return ReadLevel.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ReadLevel.unknown,
    );
  }

  /// Converts this read level to its API string value.
  String toJson() => value;
}
