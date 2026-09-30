import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import '../common/think_value.dart';

/// Supported thinking controls and the default used when `think` is omitted.
///
/// Controls are booleans or model-defined strings. The descriptor may be
/// absent from a show response when the server cannot determine the controls.
@immutable
class ModelThinking {
  /// Ordered controls advertised by the model.
  final List<ThinkValue> values;

  /// Control used when a request omits `think`.
  final ThinkValue defaultValue;

  /// Creates a [ModelThinking], copying its supported controls.
  ModelThinking({required List<ThinkValue> values, required this.defaultValue})
    : values = List.unmodifiable(values);

  /// Creates a [ModelThinking] from JSON.
  ///
  /// Throws [FormatException] for missing fields or controls that are neither
  /// booleans nor strings.
  factory ModelThinking.fromJson(Map<String, dynamic> json) {
    final values = json['values'];
    if (values is! List) {
      throw const FormatException('ModelThinking: expected a "values" array');
    }
    return ModelThinking(
      values: [
        for (var i = 0; i < values.length; i++)
          _parseControl(values[i], 'values[$i]'),
      ],
      defaultValue: _parseControl(json['default'], 'default'),
    );
  }

  static ThinkValue _parseControl(Object? value, String field) {
    final control = ThinkValue.fromJson(value);
    if (control == null) {
      throw FormatException(
        'ModelThinking: "$field" must be a boolean or string',
      );
    }
    return control;
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'values': values.map((value) => value.toJson()).toList(),
    'default': defaultValue.toJson(),
  };

  /// Creates a copy with replaced values.
  ModelThinking copyWith({
    List<ThinkValue>? values,
    ThinkValue? defaultValue,
  }) => ModelThinking(
    values: values ?? this.values,
    defaultValue: defaultValue ?? this.defaultValue,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelThinking &&
          runtimeType == other.runtimeType &&
          listsEqual(values, other.values) &&
          defaultValue == other.defaultValue;

  @override
  int get hashCode => Object.hash(listHash(values), defaultValue);

  @override
  String toString() =>
      'ModelThinking(values: $values, defaultValue: $defaultValue)';
}
