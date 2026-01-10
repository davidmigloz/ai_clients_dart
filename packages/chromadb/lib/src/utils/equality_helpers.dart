/// Deep equality check for nested lists and objects.
bool deepEquals(Object? a, Object? b) {
  if (a == null && b == null) return true;
  if (a == null || b == null) return false;
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!deepEquals(a[i], b[i])) return false;
    }
    return true;
  }
  return a == b;
}

/// Shallow list equality check.
bool listsEqual<T>(List<T>? a, List<T>? b) {
  if (a == null && b == null) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Map equality check.
bool mapsEqual(Map<String, dynamic>? a, Map<String, dynamic>? b) {
  if (a == null && b == null) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (final key in a.keys) {
    if (!b.containsKey(key) || a[key] != b[key]) return false;
  }
  return true;
}

/// Computes a consistent hash code for a map.
///
/// Unlike `Object.hashAll(map.entries)`, this properly hashes by key-value
/// pairs rather than MapEntry identity.
int mapHashCode(Map<String, dynamic>? map) {
  if (map == null) return 0;
  var hash = 0;
  for (final entry in map.entries) {
    // XOR so order doesn't matter (maps are unordered)
    hash ^= Object.hash(entry.key, entry.value);
  }
  return hash;
}
