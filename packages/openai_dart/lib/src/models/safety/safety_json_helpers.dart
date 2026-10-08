part of 'safety.dart';

mixin _SafetyValue {
  Map<String, dynamic> _valueJson();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other.runtimeType == runtimeType &&
          other is _SafetyValue &&
          mapsDeepEqual(_valueJson(), other._valueJson());

  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(_valueJson()));
}

Map<String, dynamic> _safetySnapshot(
  Map<String, dynamic> json,
  String context,
) =>
    _safetyFreeze(json, context, HashSet<Object>.identity())!
        as Map<String, dynamic>;

Object? _safetyFreeze(Object? value, String context, Set<Object> active) {
  if (value == null || value is String || value is bool) return value;
  if (value is num && value.isFinite) return value;
  if (value is Map<dynamic, dynamic>) {
    if (!active.add(value)) {
      throw FormatException('$context: expected finite JSON without cycles');
    }
    final result = <String, dynamic>{};
    for (final entry in value.entries) {
      if (entry.key is! String) {
        throw FormatException('$context: expected string object keys');
      }
      result[entry.key as String] = _safetyFreeze(
        entry.value,
        '$context member',
        active,
      );
    }
    active.remove(value);
    return Map<String, dynamic>.unmodifiable(result);
  }
  if (value is List<dynamic>) {
    if (!active.add(value)) {
      throw FormatException('$context: expected finite JSON without cycles');
    }
    final result = <Object?>[
      for (final child in value) _safetyFreeze(child, '$context item', active),
    ];
    active.remove(value);
    return List<Object?>.unmodifiable(result);
  }
  throw FormatException('$context: expected a finite JSON value');
}

Map<String, dynamic> _safetyMerge(
  Map<String, dynamic> raw,
  Set<String> known,
  Map<String, dynamic> fields,
) => {
  for (final entry in raw.entries)
    if (!known.contains(entry.key)) entry.key: entry.value,
  ...fields,
};

String? _safetyNullableString(
  Map<String, dynamic> json,
  String key,
  String context,
) {
  if (!json.containsKey(key)) {
    throw FormatException('$context.$key: expected a required nullable string');
  }
  return _safetyCopyString(json[key], '$context.$key');
}

String? _safetyCopyString(Object? value, String context) =>
    value == null ? null : requireJsonString(value, context);

bool _safetyBool(Object? value, String context) {
  if (value is! bool) throw FormatException('$context: expected a boolean');
  return value;
}

void _safetyObject(Map<String, dynamic> json, String expected, String context) {
  if (json['object'] != expected) {
    throw FormatException(
      '$context.object: expected the canonical fixed value',
    );
  }
}

void _safetyRawChoice(
  bool unknown,
  String? raw,
  String context,
  bool Function(String) isUnknown,
) {
  if (unknown ? raw == null || !isUnknown(raw) : raw != null) {
    throw FormatException(
      '$context: expected a raw value only for an unknown choice',
    );
  }
}
