part of 'webhook_event.dart';

mixin _WebhookValue {
  Map<String, dynamic> get rawJson;
  Map<String, dynamic> _valueJson();

  /// Serializes every effective field, including finite received metadata.
  Map<String, dynamic> toJson() =>
      _snapshotWebhookJson(_valueJson(), runtimeType.toString());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other.runtimeType == runtimeType &&
          other is _WebhookValue &&
          mapsDeepEqual(_valueJson(), other._valueJson());

  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(_valueJson()));
}

Map<String, dynamic> _snapshotWebhookJson(
  Map<String, dynamic> json,
  String context,
) =>
    _freezeWebhookValue(json, context, HashSet<Object>.identity())!
        as Map<String, dynamic>;

Object? _freezeWebhookValue(Object? value, String context, Set<Object> active) {
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
      result[entry.key as String] = _freezeWebhookValue(
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
        _freezeWebhookValue(child, '$context item', active),
    ];
    active.remove(value);
    return List<Object?>.unmodifiable(result);
  }
  throw FormatException('$context: expected a finite JSON value');
}

Map<String, dynamic> _mergeWebhookJson(
  Map<String, dynamic> raw,
  Set<String> known,
  Map<String, dynamic> fields,
) => {
  for (final entry in raw.entries)
    if (!known.contains(entry.key)) entry.key: entry.value,
  ...fields,
};

void _requireEventObject(
  Map<String, dynamic> json,
  String context, {
  required bool required,
}) {
  if ((required || json.containsKey('object')) && json['object'] != 'event') {
    throw FormatException('$context.object: expected event');
  }
}

void _requireAlertId(String value, String context) {
  if (value.length != 38 || !RegExp(r'^alert_[0-9a-f]{32}$').hasMatch(value)) {
    throw FormatException('$context: expected a canonical safety alert ID');
  }
}

List<WebhookSipHeader> _sipHeaders(Object? value, String context) {
  if (value is! List<dynamic>) {
    throw FormatException('$context: expected an array');
  }
  return List<WebhookSipHeader>.unmodifiable([
    for (var index = 0; index < value.length; index++)
      WebhookSipHeader.fromJson(
        requireJsonObject(value[index], '$context[$index]'),
      ),
  ]);
}
