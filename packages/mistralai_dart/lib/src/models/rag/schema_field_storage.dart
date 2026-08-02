/// The storage mode of a Vespa schema field.
enum SchemaFieldStorage {
  /// Field is kept in memory.
  inMemory('in_memory'),

  /// Field is kept on disk.
  onDisk('on_disk'),

  /// Unknown storage mode (forward-compatible fallback).
  unknown('unknown');

  const SchemaFieldStorage(this.value);

  /// The string value of this type.
  final String value;

  /// Converts to a JSON value.
  String toJson() => value;

  /// Creates a [SchemaFieldStorage] from a JSON value.
  static SchemaFieldStorage fromJson(String? value) => fromString(value);

  /// Creates a [SchemaFieldStorage] from a string value.
  static SchemaFieldStorage fromString(String? value) {
    if (value == null) return SchemaFieldStorage.unknown;
    return SchemaFieldStorage.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SchemaFieldStorage.unknown,
    );
  }
}
