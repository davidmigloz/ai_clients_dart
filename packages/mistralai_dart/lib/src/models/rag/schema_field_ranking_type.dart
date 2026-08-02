/// The ranking type of a Vespa schema field.
enum SchemaFieldRankingType {
  /// Count-based ranking.
  count('count'),

  /// Embedding-based ranking.
  embedding('embedding'),

  /// Timestamp-based ranking.
  timestamp('timestamp'),

  /// Text-based ranking.
  text('text'),

  /// String-based ranking.
  ///
  /// Named `stringType` (not `string`) to avoid colliding with Dart's
  /// `String` type.
  stringType('string'),

  /// Boolean-based ranking.
  ///
  /// Named `boolType` (not `bool`) to avoid colliding with Dart's `bool`
  /// type.
  boolType('bool'),

  /// Integer-based ranking.
  ///
  /// Named `intType` (not `int`) to avoid colliding with Dart's `int` type.
  intType('int'),

  /// Language-based ranking.
  language('language'),

  /// Unknown ranking type (forward-compatible fallback).
  unknown('unknown');

  const SchemaFieldRankingType(this.value);

  /// The string value of this type.
  final String value;

  /// Converts to a JSON value.
  String toJson() => value;

  /// Creates a [SchemaFieldRankingType] from a JSON value.
  static SchemaFieldRankingType fromJson(String? value) => fromString(value);

  /// Creates a [SchemaFieldRankingType] from a string value.
  static SchemaFieldRankingType fromString(String? value) {
    if (value == null) return SchemaFieldRankingType.unknown;
    return SchemaFieldRankingType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SchemaFieldRankingType.unknown,
    );
  }
}
