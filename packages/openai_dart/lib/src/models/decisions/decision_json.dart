part of 'decision_input.dart';

/// Structured evidence rendered as text by Decisions.
///
/// The root is an object or array of objects. Nested values may be any finite
/// JSON value. Limits are 32 container levels, 10,000 values (including the root),
/// and 256 KiB of compact UTF-8 JSON. Caller collections are deeply snapshotted.
@immutable
class JsonDecisionInputPart extends DecisionInputPart {
  /// Creates an immutable, validated JSON evidence part.
  JsonDecisionInputPart(Object data) : data = _snapshotDecisionJson(data);

  /// An immutable JSON object or array of objects.
  final Object data;

  @override
  String get type => 'input_json';

  /// Reads JSON evidence without evaluating custom object encoders.
  factory JsonDecisionInputPart.fromJson(Map<String, dynamic> json) {
    requireDecisionType(json, 'input_json', 'JsonDecisionInputPart');
    requireDecisionKeys(json, {'type', 'data'}, 'JsonDecisionInputPart');
    final data = json['data'];
    if (data == null) {
      throw const FormatException(
        'JsonDecisionInputPart.data: expected an object or object array',
      );
    }
    try {
      return JsonDecisionInputPart(data);
    } on ArgumentError {
      throw const FormatException(
        'JsonDecisionInputPart.data: invalid JSON or exceeded JSON limits',
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'data': data};

  /// Copies the part, snapshotting replacement data.
  JsonDecisionInputPart copyWith({Object? data}) =>
      JsonDecisionInputPart(data ?? this.data);

  @override
  bool operator ==(Object other) =>
      other is JsonDecisionInputPart &&
      runtimeType == other.runtimeType &&
      mapsDeepEqual({'data': data}, {'data': other.data});

  @override
  int get hashCode => mapDeepHashCode({'data': data});

  @override
  String toString() => 'JsonDecisionInputPart(data: [structured evidence])';
}

Object _snapshotDecisionJson(Object data) {
  if (data is! Map && (data is! List || data.any((value) => value is! Map))) {
    throw ArgumentError(
      'Decisions JSON data must be an object or array of objects',
    );
  }
  var values = 0;
  final ancestors = Set<Object>.identity();

  Object? visit(Object? value, int containerDepth) {
    if (++values > 10000) {
      throw ArgumentError('Decisions JSON exceeds 10000 values');
    }
    if (value is Map || value is List) {
      if (containerDepth >= 32 || !ancestors.add(value!)) {
        throw ArgumentError(
          'Decisions JSON is cyclic or exceeds 32 container levels',
        );
      }
      try {
        if (value is Map) {
          final entries = <String, dynamic>{};
          for (final entry in value.entries) {
            if (entry.key is! String) {
              throw ArgumentError('Decisions JSON object keys must be strings');
            }
            entries[entry.key as String] = visit(
              entry.value,
              containerDepth + 1,
            );
          }
          return Map<String, dynamic>.unmodifiable(entries);
        }
        return List<Object?>.unmodifiable(
          (value as List).map((entry) => visit(entry, containerDepth + 1)),
        );
      } finally {
        ancestors.remove(value);
      }
    }
    if (value == null ||
        value is String ||
        value is bool ||
        (value is num && value.isFinite)) {
      return value;
    }
    throw ArgumentError(
      'Decisions JSON values must be finite JSON primitives or containers',
    );
  }

  final snapshot = visit(data, 0)!;
  if (utf8.encode(jsonEncode(snapshot)).length > 256 * 1024) {
    throw ArgumentError('Decisions JSON exceeds 256 KiB of compact UTF-8 JSON');
  }
  return snapshot;
}
