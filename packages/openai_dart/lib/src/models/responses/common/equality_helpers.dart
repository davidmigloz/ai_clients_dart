/// Compares two lists for equality.
bool listsEqual<T>(List<T>? a, List<T>? b) {
  if (a == null && b == null) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Compares two maps for equality.
bool mapsEqual<K, V>(Map<K, V>? a, Map<K, V>? b) {
  if (a == null && b == null) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (final key in a.keys) {
    if (!b.containsKey(key) || a[key] != b[key]) return false;
  }
  return true;
}

/// Content-based hash for a map, consistent with [mapsEqual].
///
/// Uses [Object.hashAllUnordered] so key-insertion order does not matter.
int mapHashCode<K, V>(Map<K, V>? map) {
  if (map == null) return null.hashCode;
  return Object.hashAllUnordered(
    map.entries.map((e) => Object.hash(e.key, e.value)),
  );
}
