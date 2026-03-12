import '../copy_with_sentinel.dart';

/// A list of strings associated with a grounding chunk.
class GroundingChunkStringList {
  /// Optional. The string values.
  final List<String>? values;

  /// Creates a [GroundingChunkStringList].
  const GroundingChunkStringList({this.values});

  /// Creates a [GroundingChunkStringList] from JSON.
  factory GroundingChunkStringList.fromJson(Map<String, dynamic> json) =>
      GroundingChunkStringList(
        values: (json['values'] as List?)?.map((e) => e as String).toList(),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {if (values != null) 'values': values};

  /// Creates a copy with replaced values.
  GroundingChunkStringList copyWith({Object? values = unsetCopyWithValue}) {
    return GroundingChunkStringList(
      values: values == unsetCopyWithValue
          ? this.values
          : values as List<String>?,
    );
  }

  @override
  String toString() => 'GroundingChunkStringList(values: $values)';
}
