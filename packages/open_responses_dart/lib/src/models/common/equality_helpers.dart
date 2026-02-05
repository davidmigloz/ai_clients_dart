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
    if (a[key] != b[key]) return false;
  }
  return true;
}

/// Compares two lists of maps for deep equality.
bool listOfMapsEqual(
  List<Map<String, dynamic>>? a,
  List<Map<String, dynamic>>? b,
) {
  if (a == null && b == null) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (!mapsDeepEqual(a[i], b[i])) return false;
  }
  return true;
}

/// Computes a deep hash code for a list of maps.
int listOfMapsHashCode(List<Map<String, dynamic>>? list) {
  if (list == null) return 0;
  return Object.hashAll(list.map(mapDeepHashCode));
}

/// Compares two maps for deep equality (handles nested maps and lists).
bool mapsDeepEqual(Map<String, dynamic>? a, Map<String, dynamic>? b) {
  if (a == null && b == null) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (final key in a.keys) {
    if (!b.containsKey(key)) return false;
    if (!_valuesDeepEqual(a[key], b[key])) return false;
  }
  return true;
}

/// Computes a deep hash code for a map (handles nested maps and lists).
///
/// Uses sorted keys with Object.hashAll for consistent, order-independent
/// hashing without XOR collision issues.
int mapDeepHashCode(Map<String, dynamic>? map) {
  if (map == null) return 0;
  final sortedKeys = map.keys.toList()..sort();
  return Object.hashAll(
    sortedKeys.map((k) => Object.hash(k, _valueDeepHashCode(map[k]))),
  );
}

bool _valuesDeepEqual(dynamic a, dynamic b) {
  if (a is Map<String, dynamic> && b is Map<String, dynamic>) {
    return mapsDeepEqual(a, b);
  } else if (a is List && b is List) {
    return _listsDeepEqual(a, b);
  }
  return a == b;
}

int _valueDeepHashCode(dynamic value) {
  if (value is Map<String, dynamic>) {
    return mapDeepHashCode(value);
  } else if (value is List) {
    return Object.hashAll(value.map(_valueDeepHashCode));
  }
  return value.hashCode;
}

bool _listsDeepEqual(List<dynamic> a, List<dynamic> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (!_valuesDeepEqual(a[i], b[i])) return false;
  }
  return true;
}
