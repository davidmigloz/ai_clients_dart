import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Floating-point attribute value in a Tempo trace.
@immutable
class TempoTraceAttributeDoubleValue {
  /// Numeric value of the attribute.
  final double doubleValue;

  /// Creates a floating-point trace attribute value.
  const TempoTraceAttributeDoubleValue({required this.doubleValue});

  /// Decodes the value from JSON.
  factory TempoTraceAttributeDoubleValue.fromJson(Map<String, dynamic> json) {
    final doubleValue = json['doubleValue'];
    if (doubleValue is! num) {
      throw const FormatException('Expected a numeric trace doubleValue');
    }
    return TempoTraceAttributeDoubleValue(doubleValue: doubleValue.toDouble());
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'doubleValue': doubleValue};

  /// Creates a copy with the value replaced.
  TempoTraceAttributeDoubleValue copyWith({double? doubleValue}) =>
      TempoTraceAttributeDoubleValue(
        doubleValue: doubleValue ?? this.doubleValue,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TempoTraceAttributeDoubleValue &&
          doubleValue == other.doubleValue;

  @override
  int get hashCode => doubleValue.hashCode;

  @override
  String toString() =>
      'TempoTraceAttributeDoubleValue(doubleValue: $doubleValue)';
}

/// A scalar element in a Tempo trace attribute array.
@immutable
class TempoTraceAttributeArrayElement {
  /// Boolean value.
  final bool? boolValue;

  /// Floating-point value.
  final double? doubleValue;

  /// Integer value encoded as a decimal string.
  final String? intValue;

  /// String value.
  final String? stringValue;

  /// Creates an array element.
  const TempoTraceAttributeArrayElement({
    this.boolValue,
    this.doubleValue,
    this.intValue,
    this.stringValue,
  });

  /// Decodes an array element from JSON.
  factory TempoTraceAttributeArrayElement.fromJson(Map<String, dynamic> json) =>
      TempoTraceAttributeArrayElement(
        boolValue: json['boolValue'] as bool?,
        doubleValue: (json['doubleValue'] as num?)?.toDouble(),
        intValue: json['intValue'] as String?,
        stringValue: json['stringValue'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (boolValue != null) 'boolValue': boolValue,
    if (doubleValue != null) 'doubleValue': doubleValue,
    if (intValue != null) 'intValue': intValue,
    if (stringValue != null) 'stringValue': stringValue,
  };

  /// Creates a copy with replaced values.
  TempoTraceAttributeArrayElement copyWith({
    Object? boolValue = unsetCopyWithValue,
    Object? doubleValue = unsetCopyWithValue,
    Object? intValue = unsetCopyWithValue,
    Object? stringValue = unsetCopyWithValue,
  }) => TempoTraceAttributeArrayElement(
    boolValue: boolValue == unsetCopyWithValue
        ? this.boolValue
        : boolValue as bool?,
    doubleValue: doubleValue == unsetCopyWithValue
        ? this.doubleValue
        : (doubleValue as num?)?.toDouble(),
    intValue: intValue == unsetCopyWithValue
        ? this.intValue
        : intValue as String?,
    stringValue: stringValue == unsetCopyWithValue
        ? this.stringValue
        : stringValue as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TempoTraceAttributeArrayElement &&
          boolValue == other.boolValue &&
          doubleValue == other.doubleValue &&
          intValue == other.intValue &&
          stringValue == other.stringValue;

  @override
  int get hashCode =>
      Object.hash(boolValue, doubleValue, intValue, stringValue);

  @override
  String toString() =>
      'TempoTraceAttributeArrayElement(boolValue: $boolValue, doubleValue: $doubleValue, intValue: $intValue, stringValue: $stringValue)';
}
