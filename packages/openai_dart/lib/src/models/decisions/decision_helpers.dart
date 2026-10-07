/// Reads a required string without coercing invalid JSON values.
String requireDecisionString(Object? value, String field) {
  if (value is! String) {
    throw FormatException('$field: expected a string');
  }
  return value;
}

/// Reads a string that may be omitted but may not be explicitly null.
String? optionalDecisionString(
  Map<String, dynamic> json,
  String key,
  String model,
) => json.containsKey(key)
    ? requireDecisionString(json[key], '$model.$key')
    : null;

/// Reads a required nullable string, distinguishing omission from null.
String? requireNullableDecisionString(
  Map<String, dynamic> json,
  String key,
  String model,
) {
  if (!json.containsKey(key)) {
    throw FormatException('$model: missing required "$key"');
  }
  final value = json[key];
  return value == null ? null : requireDecisionString(value, '$model.$key');
}

/// Reads a required JSON object.
Map<String, dynamic> requireDecisionMap(Object? value, String field) {
  if (value is! Map<String, dynamic>) {
    throw FormatException('$field: expected an object');
  }
  return value;
}

/// Reads a required JSON array.
List<Object?> requireDecisionList(Object? value, String field) {
  if (value is! List) {
    throw FormatException('$field: expected an array');
  }
  return value;
}

/// Reads a required number, including integer-valued JSON numbers.
double requireDecisionNumber(Object? value, String field) {
  if (value is! num) {
    throw FormatException('$field: expected a number');
  }
  return value.toDouble();
}

/// Reads a required integer without rounding a floating-point value.
int requireDecisionInt(Object? value, String field) {
  if (value is! int) {
    throw FormatException('$field: expected an integer');
  }
  return value;
}

/// Checks a fixed discriminator, allowing omission only when specified.
void requireDecisionType(
  Map<String, dynamic> json,
  String type,
  String model, {
  bool optional = false,
}) {
  if (optional && !json.containsKey('type')) return;
  if (json['type'] != type) {
    throw FormatException('$model: expected type "$type"');
  }
}

/// Parses object arrays with a field and index in malformed-element errors.
List<T> parseDecisionObjects<T>(
  Object? value,
  T Function(Map<String, dynamic>) parse,
  String field,
) {
  final items = requireDecisionList(value, field);
  return [
    for (var i = 0; i < items.length; i++)
      parse(requireDecisionMap(items[i], '$field[$i]')),
  ];
}
