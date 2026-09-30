// Internal JSON helpers for System One's typed and arbitrary JSON values.
// ignore_for_file: public_member_api_docs

import '../common/equality_helpers.dart';

Map<String, dynamic> systemOneObject(Object? value, String context) {
  if (value is! Map<Object?, Object?>) {
    throw FormatException('$context must be a JSON object');
  }
  final result = <String, dynamic>{};
  for (final entry in value.entries) {
    final key = entry.key;
    if (key is! String) {
      throw FormatException('$context object keys must be strings');
    }
    result[key] = entry.value;
  }
  return result;
}

String systemOneString(Object? value, String context) {
  if (value is! String) {
    throw FormatException('$context must be a string');
  }
  return value;
}

double systemOneDouble(Object? value, String context) {
  if (value is! num || !value.isFinite) {
    throw FormatException('$context must be a finite number');
  }
  return value.toDouble();
}

int systemOneInt(Object? value, String context) {
  if (value is! int) {
    throw FormatException('$context must be an integer');
  }
  return value;
}

void systemOneDiscriminator(
  Map<String, dynamic> json,
  String expected,
  String context,
) {
  if (json['type'] != expected) {
    throw FormatException('$context.type must be "$expected"');
  }
}

Object? systemOneFreezeJson(Object? value, String context) {
  if (value == null || value is String || value is bool) return value;
  if (value is num && value.isFinite) return value;
  if (value is Map<Object?, Object?>) {
    final object = systemOneObject(value, context);
    return Map<String, dynamic>.unmodifiable({
      for (final entry in object.entries)
        entry.key: systemOneFreezeJson(entry.value, '$context.${entry.key}'),
    });
  }
  if (value is List) {
    return List<Object?>.unmodifiable([
      for (var i = 0; i < value.length; i++)
        systemOneFreezeJson(value[i], '$context[$i]'),
    ]);
  }
  throw FormatException('$context must contain only JSON values');
}

Map<String, dynamic> systemOneUnknownJson(
  Map<String, dynamic> rawJson,
  String context,
) {
  systemOneString(rawJson['type'], '$context.type');
  return systemOneFreezeJson(rawJson, '$context.rawJson')!
      as Map<String, dynamic>;
}

bool systemOneJsonEqual(Object? a, Object? b) =>
    mapsDeepEqual({'value': a}, {'value': b});

int systemOneJsonHash(Object? value) => mapDeepHashCode({'value': value});

bool systemOneOrderedMapsEqual<V>(Map<String, V> a, Map<String, V> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  final other = b.entries.iterator;
  for (final entry in a.entries) {
    if (!other.moveNext() ||
        entry.key != other.current.key ||
        entry.value != other.current.value) {
      return false;
    }
  }
  return true;
}

int systemOneOrderedMapHash<V>(Map<String, V> value) => Object.hashAll(
  value.entries.map((entry) => Object.hash(entry.key, entry.value)),
);

Map<String, double> systemOneProbabilities(Object? value, String context) {
  final json = systemOneObject(value, context);
  return {
    for (final entry in json.entries)
      entry.key: systemOneDouble(entry.value, '$context.${entry.key}'),
  };
}

Map<String, String> systemOneStringMap(Object? value, String context) {
  final json = systemOneObject(value, context);
  return {
    for (final entry in json.entries)
      entry.key: systemOneString(entry.value, '$context.${entry.key}'),
  };
}
