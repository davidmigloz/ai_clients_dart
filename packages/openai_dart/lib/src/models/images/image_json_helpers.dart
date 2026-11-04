import '../common/copy_with_sentinel.dart';
import '../common/json_helpers.dart';

/// Reads the optional nullable image safety identifier without coercion.
String? readImageSafetyIdentifier(
  Map<String, dynamic> json,
  String context, {
  bool validateLength = false,
}) {
  final value = optionalJsonString(
    json,
    'safety_identifier',
    context,
    nullable: true,
  );
  if (validateLength) validateImageSafetyIdentifier(value);
  return value;
}

/// Applies the canonical Unicode code-point bound without exposing values.
void validateImageSafetyIdentifier(String? value) {
  if (value != null && value.runes.length > 128) {
    throw const FormatException(
      'Image safetyIdentifier: maximum 128 characters',
    );
  }
}

/// Copies a nullable field without disclosing invalid caller data.
T? copyImageValue<T>(Object? value, T? current, String context) {
  if (identical(value, unsetCopyWithValue)) return current;
  if (value == null) return null;
  if (value is! T) {
    throw FormatException('$context: expected the declared type');
  }
  return value as T;
}

/// Stable private diagnostic summary.
String imageIdentifierSummary(String? value) =>
    value == null ? 'null' : '[REDACTED]';
