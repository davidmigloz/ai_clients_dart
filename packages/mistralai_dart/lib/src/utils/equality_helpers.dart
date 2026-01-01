// Utilities for deep equality comparisons.
//
// These functions are used by model classes to properly implement
// equality operators for collections.

/// Compares two lists for deep equality.
///
/// Returns true if both lists are identical, both are null, or have
/// the same length and all elements are equal.
bool listEquals<T>(List<T>? a, List<T>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Compares two maps for deep equality.
///
/// Returns true if both maps are identical, both are null, or have
/// the same keys and all values are equal.
bool mapEquals<K, V>(Map<K, V>? a, Map<K, V>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (final key in a.keys) {
    if (!b.containsKey(key) || a[key] != b[key]) return false;
  }
  return true;
}
