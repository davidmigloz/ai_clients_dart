import 'dart:convert';

/// JSON encoding with proper handling of special values.
///
/// This encoder:
/// - Omits null values by default
/// - Handles DateTime as ISO 8601 strings
/// - Handles Duration as milliseconds
const jsonEncoder = JsonEncoder.withIndent(null);

/// Encodes an object to JSON string, omitting null values.
String encodeJson(Object? value) {
  return jsonEncode(_sanitizeForJson(value));
}

/// Encodes an object to pretty-printed JSON string.
String encodePrettyJson(Object? value) {
  const encoder = JsonEncoder.withIndent('  ');
  return encoder.convert(_sanitizeForJson(value));
}

/// Sanitizes a value for JSON encoding.
///
/// Handles special types:
/// - DateTime → ISO 8601 string
/// - Duration → milliseconds
/// - Enum → value name
/// - Objects with toJson() method → calls toJson()
Object? _sanitizeForJson(Object? value) {
  if (value == null) return null;
  if (value is String || value is num || value is bool) return value;

  if (value is DateTime) {
    return value.toIso8601String();
  }

  if (value is Duration) {
    return value.inMilliseconds;
  }

  if (value is Enum) {
    return value.name;
  }

  if (value is List) {
    return value.map(_sanitizeForJson).toList();
  }

  if (value is Map) {
    return value.map((k, v) => MapEntry(k.toString(), _sanitizeForJson(v)));
  }

  // Try toJson() method via dynamic dispatch
  try {
    final dynamic dynamicValue = value;
    // ignore: avoid_dynamic_calls
    final json = dynamicValue.toJson();
    return _sanitizeForJson(json);
  } catch (_) {
    // Fallback to toString
    return value.toString();
  }
}

/// Removes null values from a map recursively.
Map<String, dynamic> removeNulls(Map<String, dynamic> map) {
  final result = <String, dynamic>{};
  for (final entry in map.entries) {
    if (entry.value == null) continue;
    if (entry.value is Map<String, dynamic>) {
      result[entry.key] = removeNulls(entry.value as Map<String, dynamic>);
    } else {
      result[entry.key] = entry.value;
    }
  }
  return result;
}

/// Parses a JSON string safely.
///
/// Returns null if parsing fails or if the result is null.
Map<String, dynamic>? parseJson(String? source) {
  if (source == null || source.isEmpty) return null;
  try {
    final result = jsonDecode(source);
    if (result is Map<String, dynamic>) return result;
    return null;
  } catch (_) {
    return null;
  }
}

/// Parses a JSON array string safely.
///
/// Returns an empty list if parsing fails.
List<Map<String, dynamic>> parseJsonArray(String? source) {
  if (source == null || source.isEmpty) return [];
  try {
    final result = jsonDecode(source);
    if (result is List) {
      return result.whereType<Map<String, dynamic>>().toList();
    }
    return [];
  } catch (_) {
    return [];
  }
}

/// Extension methods for JSON map access.
extension JsonMapExtension on Map<String, dynamic> {
  /// Gets a string value or null.
  String? getString(String key) {
    final value = this[key];
    if (value is String) return value;
    return null;
  }

  /// Gets a string value or throws if missing.
  String requireString(String key) {
    final value = getString(key);
    if (value == null) {
      throw FormatException('Missing required field: $key');
    }
    return value;
  }

  /// Gets an int value or null.
  int? getInt(String key) {
    final value = this[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return null;
  }

  /// Gets an int value or throws if missing.
  int requireInt(String key) {
    final value = getInt(key);
    if (value == null) {
      throw FormatException('Missing required field: $key');
    }
    return value;
  }

  /// Gets a double value or null.
  double? getDouble(String key) {
    final value = this[key];
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return null;
  }

  /// Gets a bool value or null.
  bool? getBool(String key) {
    final value = this[key];
    if (value is bool) return value;
    return null;
  }

  /// Gets a nested map or null.
  Map<String, dynamic>? getMap(String key) {
    final value = this[key];
    if (value is Map<String, dynamic>) return value;
    return null;
  }

  /// Gets a list or null.
  List<T>? getList<T>(String key) {
    final value = this[key];
    if (value is List) {
      return value.whereType<T>().toList();
    }
    return null;
  }

  /// Gets a list of maps or null.
  List<Map<String, dynamic>>? getMapList(String key) {
    final value = this[key];
    if (value is List) {
      return value.whereType<Map<String, dynamic>>().toList();
    }
    return null;
  }

  /// Gets a DateTime from an ISO 8601 string or Unix timestamp.
  DateTime? getDateTime(String key) {
    final value = this[key];
    if (value is String) {
      return DateTime.tryParse(value);
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value * 1000);
    }
    return null;
  }
}
