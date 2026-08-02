/// The data type of a Vespa schema field.
enum SchemaFieldDataType {
  /// Integer values.
  ///
  /// Named `intType` (not `int`) to avoid colliding with Dart's `int` type.
  intType('int'),

  /// Boolean values.
  ///
  /// Named `boolType` (not `bool`) to avoid colliding with Dart's `bool` type.
  boolType('bool'),

  /// String values.
  ///
  /// Named `stringType` (not `string`) to avoid colliding with Dart's
  /// `String` type.
  stringType('string'),

  /// Embedding vector values.
  embedding('embedding'),

  /// 64-bit integer values.
  long('long'),

  /// Floating point values.
  float('float'),

  /// Unknown data type (forward-compatible fallback).
  unknown('unknown');

  const SchemaFieldDataType(this.value);

  /// The string value of this type.
  final String value;

  /// Converts to a JSON value.
  String toJson() => value;

  /// Creates a [SchemaFieldDataType] from a JSON value.
  static SchemaFieldDataType fromJson(String? value) => fromString(value);

  /// Creates a [SchemaFieldDataType] from a string value.
  static SchemaFieldDataType fromString(String? value) {
    if (value == null) return SchemaFieldDataType.unknown;
    return SchemaFieldDataType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SchemaFieldDataType.unknown,
    );
  }
}
