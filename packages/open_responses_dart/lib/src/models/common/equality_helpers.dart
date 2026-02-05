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
    if (!_mapsDeepEqual(a[i], b[i])) return false;
  }
  return true;
}

bool _mapsDeepEqual(Map<String, dynamic> a, Map<String, dynamic> b) {
  if (a.length != b.length) return false;
  for (final key in a.keys) {
    if (!b.containsKey(key)) return false;
    final va = a[key];
    final vb = b[key];
    if (va is Map<String, dynamic> && vb is Map<String, dynamic>) {
      if (!_mapsDeepEqual(va, vb)) return false;
    } else if (va is List && vb is List) {
      if (!_listsDeepEqual(va, vb)) return false;
    } else if (va != vb) {
      return false;
    }
  }
  return true;
}

bool _listsDeepEqual(List<dynamic> a, List<dynamic> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    final va = a[i];
    final vb = b[i];
    if (va is Map<String, dynamic> && vb is Map<String, dynamic>) {
      if (!_mapsDeepEqual(va, vb)) return false;
    } else if (va is List && vb is List) {
      if (!_listsDeepEqual(va, vb)) return false;
    } else if (va != vb) {
      return false;
    }
  }
  return true;
}
