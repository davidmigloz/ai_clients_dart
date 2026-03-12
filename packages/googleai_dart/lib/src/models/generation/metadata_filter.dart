import '../copy_with_sentinel.dart';
import 'condition.dart';

/// User provided filter to limit retrieval based on `Chunk` or `Document`
/// level metadata values.
class MetadataFilter {
  /// Required. The `Condition`s for the given key that will trigger this
  /// filter. Multiple `Condition`s are joined by logical ORs.
  final List<Condition> conditions;

  /// Required. The key of the metadata to filter on.
  final String key;

  /// Creates a [MetadataFilter].
  const MetadataFilter({required this.conditions, required this.key});

  /// Creates a [MetadataFilter] from JSON.
  factory MetadataFilter.fromJson(Map<String, dynamic> json) {
    return MetadataFilter(
      conditions: (json['conditions'] as List<dynamic>)
          .map((item) => Condition.fromJson(item as Map<String, dynamic>))
          .toList(),
      key: json['key'] as String,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'conditions': conditions.map((item) => item.toJson()).toList(),
    'key': key,
  };

  /// Creates a copy with replaced values.
  MetadataFilter copyWith({
    Object? conditions = unsetCopyWithValue,
    Object? key = unsetCopyWithValue,
  }) {
    return MetadataFilter(
      conditions: conditions == unsetCopyWithValue
          ? this.conditions
          : conditions! as List<Condition>,
      key: key == unsetCopyWithValue ? this.key : key! as String,
    );
  }
}
