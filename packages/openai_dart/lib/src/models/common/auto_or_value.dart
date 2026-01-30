import 'package:meta/meta.dart';

// =============================================================================
// AutoOrInt
// =============================================================================

/// A value that can be "auto" or an integer.
///
/// Used for hyperparameters like number of epochs or batch size where
/// the API can automatically determine the optimal value.
///
/// ## Example
///
/// ```dart
/// // Let the API choose automatically
/// final epochs = AutoOrInt.auto();
///
/// // Use a specific value
/// final epochs = AutoOrInt.value(5);
/// ```
sealed class AutoOrInt {
  const AutoOrInt();

  /// Creates an auto value.
  const factory AutoOrInt.auto() = AutoOrIntAuto;

  /// Creates a specific integer value.
  const factory AutoOrInt.value(int value) = AutoOrIntValue;

  /// Creates from JSON (string "auto" or int).
  factory AutoOrInt.fromJson(Object json) {
    if (json == 'auto') return const AutoOrIntAuto();
    if (json is int) return AutoOrIntValue(json);
    throw FormatException('Invalid AutoOrInt value: $json');
  }

  /// Converts to JSON.
  Object toJson();

  /// Whether this is an auto value.
  bool get isAuto;

  /// Gets the integer value, or null if auto.
  int? get valueOrNull;
}

/// Represents "auto" for an integer field.
@immutable
class AutoOrIntAuto extends AutoOrInt {
  /// Creates an [AutoOrIntAuto].
  const AutoOrIntAuto();

  @override
  Object toJson() => 'auto';

  @override
  bool get isAuto => true;

  @override
  int? get valueOrNull => null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AutoOrIntAuto && runtimeType == other.runtimeType;

  @override
  int get hashCode => 'auto'.hashCode;

  @override
  String toString() => 'AutoOrInt.auto()';
}

/// Represents a specific integer value.
@immutable
class AutoOrIntValue extends AutoOrInt {
  /// Creates an [AutoOrIntValue].
  const AutoOrIntValue(this.value);

  /// The integer value.
  final int value;

  @override
  Object toJson() => value;

  @override
  bool get isAuto => false;

  @override
  int? get valueOrNull => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AutoOrIntValue &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'AutoOrInt.value($value)';
}

// =============================================================================
// AutoOrDouble
// =============================================================================

/// A value that can be "auto" or a double.
///
/// Used for hyperparameters like learning rate multiplier where
/// the API can automatically determine the optimal value.
///
/// ## Example
///
/// ```dart
/// // Let the API choose automatically
/// final rate = AutoOrDouble.auto();
///
/// // Use a specific value
/// final rate = AutoOrDouble.value(0.1);
/// ```
sealed class AutoOrDouble {
  const AutoOrDouble();

  /// Creates an auto value.
  const factory AutoOrDouble.auto() = AutoOrDoubleAuto;

  /// Creates a specific double value.
  const factory AutoOrDouble.value(double value) = AutoOrDoubleValue;

  /// Creates from JSON (string "auto" or num).
  factory AutoOrDouble.fromJson(Object json) {
    if (json == 'auto') return const AutoOrDoubleAuto();
    if (json is num) return AutoOrDoubleValue(json.toDouble());
    throw FormatException('Invalid AutoOrDouble value: $json');
  }

  /// Converts to JSON.
  Object toJson();

  /// Whether this is an auto value.
  bool get isAuto;

  /// Gets the double value, or null if auto.
  double? get valueOrNull;
}

/// Represents "auto" for a double field.
@immutable
class AutoOrDoubleAuto extends AutoOrDouble {
  /// Creates an [AutoOrDoubleAuto].
  const AutoOrDoubleAuto();

  @override
  Object toJson() => 'auto';

  @override
  bool get isAuto => true;

  @override
  double? get valueOrNull => null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AutoOrDoubleAuto && runtimeType == other.runtimeType;

  @override
  int get hashCode => 'auto'.hashCode;

  @override
  String toString() => 'AutoOrDouble.auto()';
}

/// Represents a specific double value.
@immutable
class AutoOrDoubleValue extends AutoOrDouble {
  /// Creates an [AutoOrDoubleValue].
  const AutoOrDoubleValue(this.value);

  /// The double value.
  final double value;

  @override
  Object toJson() => value;

  @override
  bool get isAuto => false;

  @override
  double? get valueOrNull => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AutoOrDoubleValue &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'AutoOrDouble.value($value)';
}

// =============================================================================
// InfOrInt
// =============================================================================

/// A value that can be "inf" (infinity) or an integer.
///
/// Used for fields like max response output tokens where the model
/// can use unlimited tokens.
///
/// ## Example
///
/// ```dart
/// // Use unlimited tokens
/// final tokens = InfOrInt.inf();
///
/// // Use a specific limit
/// final tokens = InfOrInt.value(4096);
/// ```
sealed class InfOrInt {
  const InfOrInt();

  /// Creates an infinity value.
  const factory InfOrInt.inf() = InfOrIntInf;

  /// Creates a specific integer value.
  const factory InfOrInt.value(int value) = InfOrIntValue;

  /// Creates from JSON (string "inf" or int).
  factory InfOrInt.fromJson(Object json) {
    if (json == 'inf') return const InfOrIntInf();
    if (json is int) return InfOrIntValue(json);
    throw FormatException('Invalid InfOrInt value: $json');
  }

  /// Converts to JSON.
  Object toJson();

  /// Whether this is infinity.
  bool get isInf;

  /// Gets the integer value, or null if infinity.
  int? get valueOrNull;
}

/// Represents infinity for an integer field.
@immutable
class InfOrIntInf extends InfOrInt {
  /// Creates an [InfOrIntInf].
  const InfOrIntInf();

  @override
  Object toJson() => 'inf';

  @override
  bool get isInf => true;

  @override
  int? get valueOrNull => null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InfOrIntInf && runtimeType == other.runtimeType;

  @override
  int get hashCode => 'inf'.hashCode;

  @override
  String toString() => 'InfOrInt.inf()';
}

/// Represents a specific integer value.
@immutable
class InfOrIntValue extends InfOrInt {
  /// Creates an [InfOrIntValue].
  const InfOrIntValue(this.value);

  /// The integer value.
  final int value;

  @override
  Object toJson() => value;

  @override
  bool get isInf => false;

  @override
  int? get valueOrNull => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InfOrIntValue &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'InfOrInt.value($value)';
}
