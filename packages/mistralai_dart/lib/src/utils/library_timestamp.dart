/// Reads the API's ISO 8601 timestamp or a previously serialized Unix value.
int? parseLibraryTimestamp(Object? value) => switch (value) {
  final int seconds => seconds,
  final String iso => DateTime.parse(iso).millisecondsSinceEpoch ~/ 1000,
  null => null,
  _ => throw const FormatException('Expected a library timestamp.'),
};

/// Encodes Unix seconds as the ISO 8601 timestamps used by Libraries.
String formatLibraryTimestamp(int value) => DateTime.fromMillisecondsSinceEpoch(
  value * 1000,
  isUtc: true,
).toIso8601String();
