import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'encoded_payload_options.dart';

/// A JSON patch payload response.
@immutable
class JSONPatchPayloadResponse {
  /// The payload type.
  final String type;

  /// The list of JSON patch operations.
  final List<Map<String, dynamic>> value;

  /// The encoding options applied to the payload.
  final List<EncodedPayloadOptions>? encodingOptions;

  /// Creates a [JSONPatchPayloadResponse].
  JSONPatchPayloadResponse({
    this.type = 'json_patch',
    required List<Map<String, dynamic>> value,
    this.encodingOptions,
  }) : value = List.unmodifiable(value);

  /// Creates a [JSONPatchPayloadResponse] from JSON.
  factory JSONPatchPayloadResponse.fromJson(Map<String, dynamic> json) =>
      JSONPatchPayloadResponse(
        type: json['type'] as String? ?? 'json_patch',
        value: (json['value'] as List?)?.cast<Map<String, dynamic>>() ?? [],
        encodingOptions: (json['encoding_options'] as List?)
            ?.map((e) => EncodedPayloadOptions.fromJson(e as String))
            .toList(),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'value': value,
    if (encodingOptions != null)
      'encoding_options': encodingOptions?.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  JSONPatchPayloadResponse copyWith({
    String? type,
    List<Map<String, dynamic>>? value,
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
    if (!listOfMapsDeepEqual(value, other.value)) return false;
    if (!listsEqual(encodingOptions, other.encodingOptions)) return false;
    return type == other.type;
  }

  @override
  int get hashCode =>
      Object.hash(type, listOfMapsHashCode(value), listHash(encodingOptions));

  @override
  String toString() =>
      'JSONPatchPayloadResponse('
      'type: $type, '
      'value: ${value.length}, '
      'encodingOptions: ${encodingOptions?.length ?? 'null'}'
      ')';
}
