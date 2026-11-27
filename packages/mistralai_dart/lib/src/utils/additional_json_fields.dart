import '../models/common/deep_unmodifiable_json.dart';

/// Returns the fields outside a model's known wire keys.
Map<String, dynamic>? additionalJsonFields(
  Map<String, dynamic> json,
  Set<String> known,
) {
  final extra = {
    for (final entry in json.entries)
      if (!known.contains(entry.key))
        entry.key: deepUnmodifiableJson(entry.value),
  };
  return extra.isEmpty ? null : Map<String, dynamic>.unmodifiable(extra);
}
