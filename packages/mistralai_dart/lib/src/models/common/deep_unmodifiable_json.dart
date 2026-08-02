/// Recursively wraps arbitrary decoded-JSON [value] so every nested [Map]
/// and [List] becomes unmodifiable.
///
/// `Map.unmodifiable`/`List.unmodifiable` are shallow: they only prevent
/// mutation of the top-level container, not of maps/lists nested inside it.
/// This walks the whole structure, converting maps to `Map<String,
/// dynamic>.unmodifiable` of their (recursively converted) entries and lists
/// to `List<dynamic>.unmodifiable` of their (recursively converted)
/// elements. Scalars (including `null`) pass through unchanged.
///
/// Map keys are cast to [String] since JSON object keys are always strings
/// (this is only ever called on decoded JSON) — the result is a properly
/// `Map<String, dynamic>`-typed value, not a `dynamic`-keyed one, so it can
/// be safely `as`-cast to `Map<String, dynamic>` at call sites. (A
/// `Map<Object?, Object?>` or a `dynamic`-inferred `Map.unmodifiable` result
/// is *not* assignable to `Map<String, dynamic>` via `as` — Dart's
/// reified generics make that cast fail at runtime.)
///
/// Use this for fields that hold open/arbitrary JSON (e.g. an
/// `additionalProperties: true` schema) so external code can't mutate a
/// model's internal state through a nested container after construction —
/// e.g. `SearchIndexRetrievable.fields` or `ExecutionTool.executionConfig`.
Object? deepUnmodifiableJson(Object? value) {
  if (value is Map) {
    return Map<String, dynamic>.unmodifiable({
      for (final entry in value.entries)
        entry.key as String: deepUnmodifiableJson(entry.value),
    });
  }
  if (value is List) {
    return List<dynamic>.unmodifiable(value.map(deepUnmodifiableJson));
  }
  return value;
}
