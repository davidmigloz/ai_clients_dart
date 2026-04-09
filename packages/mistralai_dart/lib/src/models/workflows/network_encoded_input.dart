import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'encoded_payload_options.dart';

/// Network-encoded input payload.
@immutable
class NetworkEncodedInput {
  /// The base64-encoded payload.
  final String b64payload;

  /// Whether the payload is empty.
  final bool? empty;

  /// Encoding options applied to the payload.
  final List<EncodedPayloadOptions>? encodingOptions;

  /// Creates a [NetworkEncodedInput].
  NetworkEncodedInput({
    required this.b64payload,
    this.empty,
    List<EncodedPayloadOptions>? encodingOptions,
  }) : encodingOptions = encodingOptions != null
           ? List.unmodifiable(encodingOptions)
           : null;

  /// Creates a [NetworkEncodedInput] from JSON.
  factory NetworkEncodedInput.fromJson(Map<String, dynamic> json) =>
      NetworkEncodedInput(
        b64payload: json['b64payload'] as String? ?? '',
        empty: json['empty'] as bool?,
        encodingOptions: (json['encoding_options'] as List?)
            ?.map((e) => EncodedPayloadOptions.fromJson(e as String))
            .toList(),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'b64payload': b64payload,
    if (empty != null) 'empty': empty,
    if (encodingOptions != null)
      'encoding_options': encodingOptions?.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  NetworkEncodedInput copyWith({
    String? b64payload,
    Object? empty = unsetCopyWithValue,
    Object? encodingOptions = unsetCopyWithValue,
  }) {
    return NetworkEncodedInput(
      b64payload: b64payload ?? this.b64payload,
      empty: empty == unsetCopyWithValue ? this.empty : empty as bool?,
      encodingOptions: encodingOptions == unsetCopyWithValue
          ? this.encodingOptions
          : encodingOptions as List<EncodedPayloadOptions>?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NetworkEncodedInput) return false;
    if (runtimeType != other.runtimeType) return false;
    if (!listsEqual(encodingOptions, other.encodingOptions)) return false;
    return b64payload == other.b64payload && empty == other.empty;
  }

  @override
  int get hashCode => Object.hash(b64payload, empty, listHash(encodingOptions));

  @override
  String toString() =>
      'NetworkEncodedInput(b64payload: $b64payload, empty: $empty, encodingOptions: ${encodingOptions?.length ?? 'null'})';
}
