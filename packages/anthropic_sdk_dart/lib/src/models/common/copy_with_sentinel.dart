/// Sentinel value for copyWith to distinguish null from unset.
///
/// When a field in copyWith is set to this value, it means "keep the original".
/// When a field is set to null, it means "set to null".
const Object unsetCopyWithValue = Object();

/// Validates a list supplied through an `Object?` copyWith parameter.
List<T>? copyWithList<T>(Object? value) => switch (value) {
  null => null,
  final List<T> typed => typed,
  _ => List<T>.from(value as List<Object?>),
};

/// Validates a map supplied through an `Object?` copyWith parameter.
Map<K, V>? copyWithMap<K, V>(Object? value) => switch (value) {
  null => null,
  final Map<K, V> typed => typed,
  _ => Map<K, V>.from(value as Map<Object?, Object?>),
};

/// Checks nested JSON object literals while retaining an already typed list.
List<Map<String, dynamic>>? copyWithJsonObjectList(Object? value) =>
    switch (value) {
      null => null,
      final List<Map<String, dynamic>> typed => typed,
      _ => [
        for (final item in value as List<Object?>)
          copyWithMap<String, dynamic>(item)!,
      ],
    };
