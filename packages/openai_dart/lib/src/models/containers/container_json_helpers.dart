/// Reads a required string without coercing invalid JSON values.
String requireContainerString(Object? value, String field) {
  if (value is! String) {
    throw FormatException('$field: expected a string');
  }
  return value;
}

/// Reads a required string that has one fixed API value.
String requireContainerLiteral(Object? value, String literal, String field) {
  final parsed = requireContainerString(value, field);
  if (parsed != literal) {
    throw FormatException('$field: expected "$literal"');
  }
  return parsed;
}

/// Reads an optional string, rejecting an explicitly null value.
String? optionalContainerString(
  Map<String, dynamic> json,
  String key,
  String model,
) => json.containsKey(key)
    ? requireContainerString(json[key], '$model.$key')
    : null;

/// Reads a required JSON object.
Map<String, dynamic> requireContainerMap(Object? value, String field) {
  if (value is! Map<String, dynamic>) {
    throw FormatException('$field: expected an object');
  }
  return value;
}

/// Reads an optional object, rejecting an explicitly null value.
Map<String, dynamic>? optionalContainerMap(
  Map<String, dynamic> json,
  String key,
  String model,
) => json.containsKey(key)
    ? requireContainerMap(json[key], '$model.$key')
    : null;

/// Reads a required JSON array.
List<Object?> requireContainerList(Object? value, String field) {
  if (value is! List) {
    throw FormatException('$field: expected an array');
  }
  return value;
}

/// Reads a string array, retaining order and identifying invalid elements.
List<String> requireContainerStrings(Object? value, String field) {
  final items = requireContainerList(value, field);
  return [
    for (var i = 0; i < items.length; i++)
      requireContainerString(items[i], '$field[$i]'),
  ];
}

/// Reads an optional string array, rejecting an explicitly null value.
List<String>? optionalContainerStrings(
  Map<String, dynamic> json,
  String key,
  String model,
) => json.containsKey(key)
    ? requireContainerStrings(json[key], '$model.$key')
    : null;

/// Reads a required integer without rounding a floating-point value.
int requireContainerInt(Object? value, String field) {
  if (value is! int) {
    throw FormatException('$field: expected an integer');
  }
  return value;
}

/// Reads an optional integer, rejecting an explicitly null value.
int? optionalContainerInt(
  Map<String, dynamic> json,
  String key,
  String model,
) => json.containsKey(key)
    ? requireContainerInt(json[key], '$model.$key')
    : null;

/// Reads a required boolean.
bool requireContainerBool(Object? value, String field) {
  if (value is! bool) {
    throw FormatException('$field: expected a boolean');
  }
  return value;
}

/// Checks a required fixed discriminator.
void requireContainerType(
  Map<String, dynamic> json,
  String type,
  String model,
) {
  if (json['type'] != type) {
    throw FormatException('$model: expected type "$type"');
  }
}

/// Parses an object array with contextual malformed-element errors.
List<T> parseContainerObjects<T>(
  Object? value,
  T Function(Map<String, dynamic>) parse,
  String field,
) {
  final items = requireContainerList(value, field);
  return [
    for (var i = 0; i < items.length; i++)
      parse(requireContainerMap(items[i], '$field[$i]')),
  ];
}

/// Takes a recursively unmodifiable snapshot of a JSON object.
Map<String, dynamic> freezeContainerJsonMap(Map<String, dynamic> value) =>
    Map.unmodifiable(
      value.map(
        (key, nested) => MapEntry(key, _freezeContainerJsonValue(nested)),
      ),
    );

Object? _freezeContainerJsonValue(Object? value) => switch (value) {
  final Map<dynamic, dynamic> map => freezeContainerJsonMap({
    for (final entry in map.entries)
      requireContainerString(entry.key, 'Container JSON key'): entry.value,
  }),
  final List<dynamic> list => List<Object?>.unmodifiable(
    list.map(_freezeContainerJsonValue),
  ),
  _ => value,
};
