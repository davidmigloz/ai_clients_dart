import 'package:meta/meta.dart';

import '_system_one_helpers.dart';

/// Text or structured JSON submitted as System One state or instructions.
///
/// Objects and arrays are rendered as JSON text by the server, rather than
/// interpreted as chat messages or multimodal input.
///
/// Variants: [SystemOneStringContent], [SystemOneObjectContent], and
/// [SystemOneArrayContent].
@immutable
sealed class SystemOneContent {
  const SystemOneContent();

  /// Creates content from text.
  const factory SystemOneContent.string(String value) = SystemOneStringContent;

  /// Creates content from a JSON object.
  factory SystemOneContent.object(Map<String, dynamic> value) =
      SystemOneObjectContent;

  /// Creates content from a JSON array.
  factory SystemOneContent.array(List<Object?> values) = SystemOneArrayContent;

  /// Parses text, an object, or an array; rejects other JSON shapes.
  factory SystemOneContent.fromJson(
    Object? json, {
    String context = 'SystemOneContent',
  }) => switch (json) {
    final String value => SystemOneStringContent(value),
    final Map<Object?, Object?> value => SystemOneObjectContent(
      systemOneObject(value, context),
    ),
    final List<Object?> values => SystemOneArrayContent(values),
    _ => throw FormatException('$context must be a string, object, or array'),
  };

  /// Returns the JSON value expected by the API.
  Object toJson();
}

/// System One content containing text.
@immutable
class SystemOneStringContent extends SystemOneContent {
  /// Creates text content.
  const SystemOneStringContent(this.value);

  /// The text to evaluate.
  final String value;

  /// Creates text content from JSON.
  factory SystemOneStringContent.fromJson(Object? json) =>
      SystemOneStringContent(systemOneString(json, 'SystemOneStringContent'));

  @override
  String toJson() => value;

  /// Creates a copy with replaced text.
  SystemOneStringContent copyWith({String? value}) =>
      SystemOneStringContent(value ?? this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemOneStringContent && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'SystemOneStringContent(value: $value)';
}

/// System One content containing an immutable JSON object.
@immutable
class SystemOneObjectContent extends SystemOneContent {
  /// Creates content and copies nested JSON collections.
  SystemOneObjectContent(Map<String, dynamic> value)
    : value =
          systemOneFreezeJson(value, 'SystemOneObjectContent.value')!
              as Map<String, dynamic>;

  /// The object to evaluate.
  final Map<String, dynamic> value;

  /// Creates object content from JSON.
  factory SystemOneObjectContent.fromJson(Object? json) =>
      SystemOneObjectContent(systemOneObject(json, 'SystemOneObjectContent'));

  @override
  Map<String, dynamic> toJson() => value;

  /// Creates a copy with a replaced object.
  SystemOneObjectContent copyWith({Map<String, dynamic>? value}) =>
      SystemOneObjectContent(value ?? this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemOneObjectContent && systemOneJsonEqual(value, other.value);

  @override
  int get hashCode => systemOneJsonHash(value);

  @override
  String toString() => 'SystemOneObjectContent(value: ${value.length} entries)';
}

/// System One content containing an immutable JSON array.
@immutable
class SystemOneArrayContent extends SystemOneContent {
  /// Creates content and copies nested JSON collections.
  SystemOneArrayContent(List<Object?> values)
    : values =
          systemOneFreezeJson(values, 'SystemOneArrayContent.values')!
              as List<Object?>;

  /// The array to evaluate.
  final List<Object?> values;

  /// Creates array content from JSON.
  factory SystemOneArrayContent.fromJson(Object? json) {
    if (json is! List<Object?>) {
      throw const FormatException('SystemOneArrayContent must be an array');
    }
    return SystemOneArrayContent(json);
  }

  @override
  List<Object?> toJson() => values;

  /// Creates a copy with a replaced array.
  SystemOneArrayContent copyWith({List<Object?>? values}) =>
      SystemOneArrayContent(values ?? this.values);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemOneArrayContent &&
          systemOneJsonEqual(values, other.values);

  @override
  int get hashCode => systemOneJsonHash(values);

  @override
  String toString() => 'SystemOneArrayContent(values: ${values.length} items)';
}
