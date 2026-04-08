/// Options for encoded payloads.
enum EncodedPayloadOptions {
  /// Payload is offloaded.
  offloaded('offloaded'),

  /// Payload is encrypted.
  encrypted('encrypted'),

  /// Payload is partially encrypted.
  encryptedPartial('encrypted-partial'),

  /// Unknown option (forward-compatibility fallback).
  unknown('unknown');

  const EncodedPayloadOptions(this.value);

  /// The string value of this enum member.
  final String value;

  /// Creates a [EncodedPayloadOptions] from a JSON string value.
  static EncodedPayloadOptions fromJson(String? value) {
    if (value == null) return EncodedPayloadOptions.unknown;
    return EncodedPayloadOptions.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EncodedPayloadOptions.unknown,
    );
  }

  /// Returns the string value for JSON serialization.
  String toJson() => value;
}
