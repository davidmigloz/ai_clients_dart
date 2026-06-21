import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// The value carried by a [JSONPatchPayloadResponse].
///
/// The API returns one of two shapes for this field:
/// - a list of JSON Patch operations (the unencrypted case), modeled by
///   [JSONPatchPayloadOperations];
/// - a base64-encoded string (when the payload is encrypted), modeled by
///   [JSONPatchPayloadEncryptedValue].
@immutable
sealed class JSONPatchPayloadValue {
  /// Const base constructor for subclasses.
  const JSONPatchPayloadValue();

  /// Parses the raw JSON value, which is either an array of operations or a
  /// string (when encrypted).
  factory JSONPatchPayloadValue.fromJson(Object? json) {
    if (json is String) {
      return JSONPatchPayloadEncryptedValue(json);
    }
    if (json is List) {
      return JSONPatchPayloadOperations(
        json
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList(growable: false),
      );
    }
    throw FormatException(
      'JSONPatchPayloadValue: expected a List of operations or an encrypted '
      'String, got ${json.runtimeType}',
    );
  }

  /// Serializes to the raw JSON value (a `List` or a `String`).
  Object toJson();
}

/// A list of JSON Patch operations (the unencrypted payload case).
@immutable
class JSONPatchPayloadOperations extends JSONPatchPayloadValue {
  /// The list of JSON Patch operations.
  final List<Map<String, dynamic>> operations;

  /// Creates a [JSONPatchPayloadOperations].
  JSONPatchPayloadOperations(List<Map<String, dynamic>> operations)
    : operations = List.unmodifiable(operations);

  @override
  List<Map<String, dynamic>> toJson() => operations;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JSONPatchPayloadOperations &&
          runtimeType == other.runtimeType &&
          listOfMapsDeepEqual(operations, other.operations);

  @override
  int get hashCode => listOfMapsHashCode(operations);

  @override
  String toString() =>
      'JSONPatchPayloadOperations(operations: ${operations.length})';
}

/// A base64-encoded encrypted payload value.
@immutable
class JSONPatchPayloadEncryptedValue extends JSONPatchPayloadValue {
  /// The base64-encoded encrypted payload.
  final String data;

  /// Creates a [JSONPatchPayloadEncryptedValue].
  const JSONPatchPayloadEncryptedValue(this.data);

  @override
  String toJson() => data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JSONPatchPayloadEncryptedValue &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() =>
      'JSONPatchPayloadEncryptedValue(data: [${data.length} chars])';
}
