import '../copy_with_sentinel.dart';
import 'grounding_chunk_string_list.dart';

/// Custom metadata associated with a grounding chunk.
class GroundingChunkCustomMetadata {
  /// Optional. Key of the metadata.
  final String? key;

  /// Optional. Numeric value of the metadata.
  final double? numericValue;

  /// Optional. String list value of the metadata.
  final GroundingChunkStringList? stringListValue;

  /// Optional. String value of the metadata.
  final String? stringValue;

  /// Creates a [GroundingChunkCustomMetadata].
  const GroundingChunkCustomMetadata({
    this.key,
    this.numericValue,
    this.stringListValue,
    this.stringValue,
  });

  /// Creates a [GroundingChunkCustomMetadata] from JSON.
  factory GroundingChunkCustomMetadata.fromJson(Map<String, dynamic> json) =>
      GroundingChunkCustomMetadata(
        key: json['key'] as String?,
        numericValue: json['numericValue'] != null
            ? (json['numericValue'] as num).toDouble()
            : null,
        stringListValue: json['stringListValue'] != null
            ? GroundingChunkStringList.fromJson(
                json['stringListValue'] as Map<String, dynamic>,
              )
            : null,
        stringValue: json['stringValue'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (key != null) 'key': key,
    if (numericValue != null) 'numericValue': numericValue,
    if (stringListValue != null) 'stringListValue': stringListValue!.toJson(),
    if (stringValue != null) 'stringValue': stringValue,
  };

  /// Creates a copy with replaced values.
  GroundingChunkCustomMetadata copyWith({
    Object? key = unsetCopyWithValue,
    Object? numericValue = unsetCopyWithValue,
    Object? stringListValue = unsetCopyWithValue,
    Object? stringValue = unsetCopyWithValue,
  }) {
    return GroundingChunkCustomMetadata(
      key: key == unsetCopyWithValue ? this.key : key as String?,
      numericValue: numericValue == unsetCopyWithValue
          ? this.numericValue
          : numericValue as double?,
      stringListValue: stringListValue == unsetCopyWithValue
          ? this.stringListValue
          : stringListValue as GroundingChunkStringList?,
      stringValue: stringValue == unsetCopyWithValue
          ? this.stringValue
          : stringValue as String?,
    );
  }

  @override
  String toString() =>
      'GroundingChunkCustomMetadata(key: $key, numericValue: $numericValue, stringListValue: $stringListValue, stringValue: $stringValue)';
}
