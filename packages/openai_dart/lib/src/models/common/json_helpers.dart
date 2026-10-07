/// Reads a string with a contextual error instead of coercing malformed JSON.
String requireJsonString(Object? value, String field) {
  if (value is! String) throw FormatException('$field: expected a string');
  return value;
}

/// Reads an integer without rounding a fractional number.
int requireJsonInt(Object? value, String field) {
  if (value is! int) throw FormatException('$field: expected an integer');
  return value;
}

/// Reads an object and normalizes dynamically typed string-keyed maps.
Map<String, dynamic> requireJsonObject(Object? value, String field) {
  if (value is! Map<dynamic, dynamic>) {
    throw FormatException('$field: expected an object');
  }
  return {
    for (final entry in value.entries)
      requireJsonString(entry.key, '$field key'): entry.value,
  };
}

/// Reads an optional string, allowing explicit null only when requested.
String? optionalJsonString(
  Map<String, dynamic> json,
  String key,
  String model, {
  bool nullable = false,
}) => !json.containsKey(key) || (nullable && json[key] == null)
    ? null
    : requireJsonString(json[key], '$model.$key');

/// Reads an optional nonnullable integer.
int? optionalJsonInt(Map<String, dynamic> json, String key, String model) =>
    json.containsKey(key) ? requireJsonInt(json[key], '$model.$key') : null;

/// Reads an optional nonnullable boolean.
bool? optionalJsonBool(Map<String, dynamic> json, String key, String model) {
  if (!json.containsKey(key)) return null;
  final value = json[key];
  if (value is! bool) throw FormatException('$model.$key: expected a boolean');
  return value;
}

/// Checks a required fixed discriminator.
void requireJsonType(Map<String, dynamic> json, String type, String model) {
  if (json['type'] != type) {
    throw FormatException('$model.type: expected "$type"');
  }
}

/// Takes a recursively unmodifiable snapshot of a JSON object.
Map<String, dynamic> freezeJsonObject(Map<String, dynamic> json) =>
    Map<String, dynamic>.unmodifiable({
      for (final entry in json.entries)
        entry.key: _freezeJsonValue(entry.value),
    });

Object? _freezeJsonValue(Object? value) => switch (value) {
  final Map<dynamic, dynamic> map => freezeJsonObject(
    requireJsonObject(map, 'JSON object'),
  ),
  final List<dynamic> list => List<Object?>.unmodifiable(
    list.map(_freezeJsonValue),
  ),
  _ => value,
};
