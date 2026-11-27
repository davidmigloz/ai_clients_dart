/// Reads library timestamps from earlier integer and current ISO 8601 JSON.
DateTime? parseLibraryTimestamp(Object? value) => switch (value) {
  final DateTime date => date,
  final int seconds => DateTime.fromMillisecondsSinceEpoch(
    seconds * 1000,
    isUtc: true,
  ),
  final String iso => DateTime.parse(iso),
  null => null,
  _ => throw const FormatException('Expected a library timestamp.'),
};

/// Preserves the package's epoch-second getters.
int? libraryTimestampSeconds(Object? value) => switch (value) {
  final int seconds => seconds,
  final DateTime date =>
    date.microsecondsSinceEpoch ~/ Duration.microsecondsPerSecond,
  _ => null,
};
