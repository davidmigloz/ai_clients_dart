import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'encoded_payload_options.dart';

/// A JSON payload response.
@immutable
class JSONPayloadResponse {
  /// The payload type.
  final String type;

  /// The JSON value.
  final Object value;

  /// The encoding options applied to the payload.
  final List<EncodedPayloadOptions>? encodingOptions;

  /// Creates a [JSONPayloadResponse].
  const JSONPayloadResponse({
    this.type = 'json',
    required this.value,
    this.encodingOptions,
  });

  /// Creates a [JSONPayloadResponse] from JSON.
  factory JSONPayloadResponse.fromJson(Map<String, dynamic> json) =>
      JSONPayloadResponse(
        type: json['type'] as String? ?? 'json',
        value: json['value'] ?? const <String, dynamic>{},
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
  JSONPayloadResponse copyWith({
    String? type,
    Object? value,
    Object? encodingOptions = unsetCopyWithValue,
  }) {
    return JSONPayloadResponse(
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
    if (other is! JSONPayloadResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    if (!listsEqual(encodingOptions, other.encodingOptions)) return false;
    return type == other.type && valuesDeepEqual(value, other.value);
  }

  @override
  int get hashCode =>
      Object.hash(type, valueDeepHashCode(value), listHash(encodingOptions));

  @override
  String toString() =>
      'JSONPayloadResponse('
      'type: $type, '
      'value: $value, '
      'encodingOptions: ${encodingOptions?.length ?? 'null'}'
      ')';
}
