import 'package:meta/meta.dart';

import 'encrypted_patch_value.dart';

/// A JSON patch append operation.
@immutable
class JSONPatchAppend {
  /// The operation type.
  final String op;

  /// The JSON path.
  final String path;

  /// The value to append.
  ///
  /// Either a plain string ([JSONPatchAppendStringValue]) or, under selective
  /// encryption, an [EncryptedPatchValue] wrapper
  /// ([JSONPatchAppendEncryptedValue]).
  final JSONPatchAppendValue value;

  /// Creates a [JSONPatchAppend].
  const JSONPatchAppend({
    this.op = 'append',
    required this.path,
    required this.value,
  });

  /// Creates a [JSONPatchAppend] from JSON.
  factory JSONPatchAppend.fromJson(Map<String, dynamic> json) =>
      JSONPatchAppend(
        op: json['op'] as String? ?? 'append',
        path: json['path'] as String? ?? '',
        value: JSONPatchAppendValue.fromJson(json['value']),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'op': op,
    'path': path,
    'value': value.toJson(),
  };

  /// Creates a copy with replaced values.
  JSONPatchAppend copyWith({
    String? op,
    String? path,
    JSONPatchAppendValue? value,
  }) {
    return JSONPatchAppend(
      op: op ?? this.op,
      path: path ?? this.path,
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! JSONPatchAppend) return false;
    if (runtimeType != other.runtimeType) return false;
    return op == other.op && path == other.path && value == other.value;
  }

  @override
  int get hashCode => Object.hash(op, path, value);

  @override
  String toString() => 'JSONPatchAppend(op: $op, path: $path, value: $value)';
}

/// The value carried by a [JSONPatchAppend].
///
/// The API returns either a plain string ([JSONPatchAppendStringValue]) or,
/// when selective encryption is enabled, an [EncryptedPatchValue] wrapper
/// ([JSONPatchAppendEncryptedValue]).
@immutable
sealed class JSONPatchAppendValue {
  /// Const base constructor for subclasses.
  const JSONPatchAppendValue();

  /// Parses the raw JSON value (a string or an encrypted wrapper object).
  factory JSONPatchAppendValue.fromJson(Object? json) {
    if (json is String) {
      return JSONPatchAppendStringValue(json);
    }
    if (json is Map<String, dynamic>) {
      return JSONPatchAppendEncryptedValue(EncryptedPatchValue.fromJson(json));
    }
    throw FormatException(
      'JSONPatchAppendValue: expected a String or an encrypted value object, '
      'got ${json.runtimeType}',
    );
  }

  /// Serializes to the raw JSON value (a `String` or a `Map`).
  Object toJson();
}

/// A plain string append value.
@immutable
class JSONPatchAppendStringValue extends JSONPatchAppendValue {
  /// The string to append.
  final String value;

  /// Creates a [JSONPatchAppendStringValue].
  const JSONPatchAppendStringValue(this.value);

  @override
  String toJson() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JSONPatchAppendStringValue &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'JSONPatchAppendStringValue(value: $value)';
}

/// An encrypted append value (selective `json_patch` encryption).
@immutable
class JSONPatchAppendEncryptedValue extends JSONPatchAppendValue {
  /// The encrypted value wrapper.
  final EncryptedPatchValue value;

  /// Creates a [JSONPatchAppendEncryptedValue].
  const JSONPatchAppendEncryptedValue(this.value);

  @override
  Map<String, dynamic> toJson() => value.toJson();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JSONPatchAppendEncryptedValue &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'JSONPatchAppendEncryptedValue(value: $value)';
}
