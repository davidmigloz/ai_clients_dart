import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'encoded_payload_options.dart';
import 'json_patch_payload_value.dart';

/// A JSON patch payload response.
@immutable
class JSONPatchPayloadResponse {
  /// The payload type.
  final String type;

  /// The payload value.
  ///
  /// Either a list of JSON Patch operations
  /// ([JSONPatchPayloadOperations]) or, when encrypted, a base64-encoded
  /// string ([JSONPatchPayloadEncryptedValue]).
  final JSONPatchPayloadValue value;

  /// The encoding options applied to the payload.
  final List<EncodedPayloadOptions>? encodingOptions;

  /// Creates a [JSONPatchPayloadResponse].
  const JSONPatchPayloadResponse({
    this.type = 'json_patch',
    required this.value,
    this.encodingOptions,
  });

  /// Creates a [JSONPatchPayloadResponse] from JSON.
  factory JSONPatchPayloadResponse.fromJson(Map<String, dynamic> json) =>
      JSONPatchPayloadResponse(
        type: json['type'] as String? ?? 'json_patch',
        value: JSONPatchPayloadValue.fromJson(json['value']),
        encodingOptions: (json['encoding_options'] as List?)
            ?.map((e) => EncodedPayloadOptions.fromJson(e as String))
            .toList(),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'value': value.toJson(),
    if (encodingOptions != null)
      'encoding_options': encodingOptions?.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  JSONPatchPayloadResponse copyWith({
    String? type,
    JSONPatchPayloadValue? value,
    Object? encodingOptions = unsetCopyWithValue,
  }) {
    return JSONPatchPayloadResponse(
      type: type ?? this.type,
      value: value ?? this.value,
      encodingOptions: encodingOptions == unsetCopyWithValue
          ? this.encodingOptions
          : encodingOptions as List<EncodedPayloadOptions>?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! JSONPatchPayloadResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    if (!listsEqual(encodingOptions, other.encodingOptions)) return false;
    return type == other.type && value == other.value;
  }

  @override
  int get hashCode => Object.hash(type, value, listHash(encodingOptions));

  @override
  String toString() =>
      'JSONPatchPayloadResponse('
      'type: $type, '
      'value: $value, '
      'encodingOptions: ${encodingOptions?.length ?? 'null'}'
      ')';
}
