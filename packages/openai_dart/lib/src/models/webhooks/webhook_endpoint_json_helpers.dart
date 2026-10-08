part of 'webhook_endpoint.dart';

mixin _EndpointValue {
  Map<String, dynamic> _valueJson();

  /// Serializes all effective fields into a fresh finite JSON snapshot.
  Map<String, dynamic> toJson() =>
      _endpointSnapshot(_valueJson(), 'Webhook endpoint JSON');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other.runtimeType == runtimeType &&
          other is _EndpointValue &&
          mapsDeepEqual(_valueJson(), other._valueJson());

  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(_valueJson()));
}

Map<String, dynamic> _endpointSnapshot(
  Map<String, dynamic> json,
  String context,
) =>
    _endpointFreeze(json, context, HashSet<Object>.identity())!
        as Map<String, dynamic>;

Object? _endpointFreeze(Object? value, String context, Set<Object> active) {
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
      result[entry.key as String] = _endpointFreeze(
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
      for (final child in value)
        _endpointFreeze(child, '$context item', active),
    ];
    active.remove(value);
    return List<Object?>.unmodifiable(result);
  }
  throw FormatException('$context: expected a finite JSON value');
}

Map<String, dynamic> _endpointMerge(
  Map<String, dynamic> raw,
  Set<String> known,
  Map<String, dynamic> fields,
) => {
  for (final entry in raw.entries)
    if (!known.contains(entry.key)) entry.key: entry.value,
  ...fields,
};

String? _endpointNullableString(
  Map<String, dynamic> json,
  String key,
  String context,
) {
  if (!json.containsKey(key)) {
    throw FormatException('$context.$key: expected a required nullable string');
  }
  return json[key] == null
      ? null
      : requireJsonString(json[key], '$context.$key');
}

bool _endpointBool(Object? value, String context) {
  if (value is! bool) throw FormatException('$context: expected a boolean');
  return value;
}

List<String> _endpointStrings(Object? value, String context) {
  if (value is! List<dynamic>) {
    throw FormatException('$context: expected an array');
  }
  return [
    for (var index = 0; index < value.length; index++)
      requireJsonString(value[index], '$context[$index]'),
  ];
}

WebhookEventType _endpointEvent(Object? value, String context) {
  final string = requireJsonString(value, context);
  for (final choice in WebhookEventType.values) {
    if (choice.value == string) return choice;
  }
  throw FormatException('$context: expected a canonical project event type');
}

List<WebhookEventType> _endpointWritableEvents(Object? value, String context) {
  if (value is! List<dynamic>) {
    throw FormatException('$context: expected an array');
  }
  return [
    for (var index = 0; index < value.length; index++)
      _endpointEvent(value[index], '$context[$index]'),
  ];
}

List<WebhookEndpoint> _endpointItems(Object? value, String context) {
  if (value is! List<dynamic>) {
    throw FormatException('$context: expected an array');
  }
  return [
    for (var index = 0; index < value.length; index++)
      WebhookEndpoint.fromJson(
        requireJsonObject(value[index], '$context[$index]'),
      ),
  ];
}

void _endpointName(String value, String context) {
  final length = value.runes.length;
  if (length < 1 || length > 256) {
    throw FormatException('$context: expected 1 to 256 Unicode characters');
  }
}

void _endpointUrl(String value, String context) {
  if (!value.startsWith('https://') || value.runes.length > 2048) {
    throw FormatException(
      '$context: expected an https:// prefix and at most 2048 Unicode characters',
    );
  }
}

void _endpointNonemptyEvents(List<WebhookEventType> value, String context) {
  if (value.isEmpty) {
    throw FormatException('$context: expected at least one event type');
  }
}

String? _endpointCopyString(Object? value, String context) =>
    value == null ? null : requireJsonString(value, context);

int? _endpointCopyInt(Object? value, String context) =>
    value == null ? null : requireJsonInt(value, context);

bool? _endpointCopyBool(Object? value, String context) =>
    value == null ? null : _endpointBool(value, context);

List<WebhookEventType>? _endpointCopyEvents(Object? value, String context) {
  if (value == null) return null;
  if (value is! List<dynamic>) {
    throw FormatException('$context: expected an array of project event types');
  }
  return [
    for (final item in value)
      if (item is WebhookEventType)
        item
      else
        throw FormatException(
          '$context: expected a canonical project event type',
        ),
  ];
}
