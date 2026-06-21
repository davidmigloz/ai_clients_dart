import 'package:meta/meta.dart';

/// Wrapper for an encrypted patch value used in selective `json_patch`
/// encryption.
///
/// When partial encryption mode is enabled and a patch targets an encrypted
/// field, the patch value is encrypted and wrapped in this structure. The
/// [type] discriminator (`__encrypted__`) distinguishes it from plain user
/// data.
@immutable
class EncryptedPatchValue {
  /// Discriminator marking this as an encrypted value. Always `__encrypted__`.
  String get type => '__encrypted__';

  /// The encrypted (base64-encoded) payload.
  final String value;

  /// Creates an [EncryptedPatchValue].
  const EncryptedPatchValue({required this.value});

  /// Creates an [EncryptedPatchValue] from JSON.
  factory EncryptedPatchValue.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != '__encrypted__') {
      throw FormatException(
        'EncryptedPatchValue: expected type "__encrypted__", got "$type"',
      );
    }
    final value = json['value'];
    if (value is! String) {
      throw FormatException(
        'EncryptedPatchValue: missing or invalid required "value" '
        '(expected String, got ${value.runtimeType})',
      );
    }
    return EncryptedPatchValue(value: value);
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'type': type, 'value': value};

  /// Creates a copy with replaced values.
  EncryptedPatchValue copyWith({String? value}) =>
      EncryptedPatchValue(value: value ?? this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EncryptedPatchValue &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() =>
      'EncryptedPatchValue(type: $type, value: [${value.length} chars])';
}
