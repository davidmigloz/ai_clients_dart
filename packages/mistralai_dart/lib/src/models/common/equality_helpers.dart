/// Compares two lists for equality.
bool listsEqual<T>(List<T>? a, List<T>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Compares two maps for equality.
bool mapsEqual<K, V>(Map<K, V>? a, Map<K, V>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (final key in a.keys) {
    if (!b.containsKey(key) || a[key] != b[key]) return false;
  }
  return true;
}

/// Compares two lists of maps for shallow equality.
bool listOfMapsEqual<K, V>(List<Map<K, V>>? a, List<Map<K, V>>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (!mapsEqual(a[i], b[i])) return false;
  }
  return true;
}

/// Compares two lists of maps for deep equality (handles nested maps and lists).
bool listOfMapsDeepEqual(
  List<Map<String, dynamic>>? a,
  List<Map<String, dynamic>>? b,
) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (!mapsDeepEqual(a[i], b[i])) return false;
  }
  return true;
}

/// Compares two maps for deep equality (handles nested maps and lists).
bool mapsDeepEqual(Map<String, dynamic>? a, Map<String, dynamic>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (final key in a.keys) {
    if (!b.containsKey(key)) return false;
    if (!valuesDeepEqual(a[key], b[key])) return false;
  }
  return true;
}

/// Compares two dynamic values for deep equality (handles nested maps and lists).
bool valuesDeepEqual(dynamic a, dynamic b) {
  if (a is Map<String, dynamic> && b is Map<String, dynamic>) {
    return mapsDeepEqual(a, b);
  } else if (a is List && b is List) {
    return _listsDeepEqual(a, b);
  }
  return a == b;
}

bool _listsDeepEqual(List<dynamic> a, List<dynamic> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (!valuesDeepEqual(a[i], b[i])) return false;
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
///
/// Uses [Object.hashAllUnordered] so key-insertion order does not matter.
int mapHash<K, V>(Map<K, V>? map) {
  if (map == null) return null.hashCode;
  return Object.hashAllUnordered(
    map.entries.map((e) => Object.hash(e.key, e.value)),
  );
}

/// Content-based hash code for a nullable list of maps.
int listOfMapsHash<K, V>(List<Map<K, V>>? list) {
  if (list == null) return null.hashCode;
  return Object.hashAll(list.map(mapHash));
}

/// Computes a deep hash code for a list of maps.
int listOfMapsHashCode(List<Map<String, dynamic>>? list) {
  if (list == null) return null.hashCode;
  return Object.hashAll(list.map(mapDeepHashCode));
}

/// Computes a deep hash code for a map (handles nested maps and lists).
///
/// Uses sorted keys with [Object.hashAll] for consistent, order-independent
/// hashing without XOR collision issues.
int mapDeepHashCode(Map<String, dynamic>? map) {
  if (map == null) return null.hashCode;
  final sortedKeys = map.keys.toList()..sort();
  return Object.hashAll(
    sortedKeys.map((k) => Object.hash(k, valueDeepHashCode(map[k]))),
  );
}

/// Computes a deep hash code for a dynamic value (handles nested maps and lists).
int valueDeepHashCode(dynamic value) {
  if (value is Map<String, dynamic>) {
    return mapDeepHashCode(value);
  } else if (value is List) {
    return Object.hashAll(value.map(valueDeepHashCode));
  }
  return value.hashCode;
}
