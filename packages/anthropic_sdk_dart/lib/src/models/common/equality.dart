/// Compares two lists for shallow element-wise equality.
bool listsEqual<T>(List<T>? a, List<T>? b) {
  if (a == null && b == null) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Compares two maps for shallow key/value equality.
bool mapsEqual<K, V>(Map<K, V>? a, Map<K, V>? b) {
  if (a == null && b == null) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (final key in a.keys) {
    if (!b.containsKey(key) || a[key] != b[key]) return false;
  }
  return true;
}

/// Compares two lists of maps for shallow equality.
bool listOfMapsEqual<K, V>(List<Map<K, V>>? a, List<Map<K, V>>? b) {
  if (a == null && b == null) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (!mapsEqual(a[i], b[i])) return false;
  }
  return true;
}

// ============================================================================
// Hash helpers
// ============================================================================

/// Content-based hash code for a nullable list.
int listHash<T>(List<T>? list) {
  if (list == null) return null.hashCode;
  return Object.hashAll(list);
}

/// Content-based hash code for a nullable map (order-independent).
int mapHash<K, V>(Map<K, V>? map) {
  if (map == null) return null.hashCode;
  var hash = 0;
  for (final entry in map.entries) {
    hash ^= Object.hash(entry.key, entry.value);
  }
  return hash;
}

/// Content-based hash code for a nullable list of maps.
int listOfMapsHash<K, V>(List<Map<K, V>>? list) {
  if (list == null) return null.hashCode;
  return Object.hashAll(list.map(mapHash));
}
