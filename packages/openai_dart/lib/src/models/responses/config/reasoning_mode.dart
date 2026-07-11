import 'package:meta/meta.dart';

/// Controls the reasoning execution mode for the request.
///
/// When returned on a response, this is the effective execution mode.
///
/// Known modes are available as variants:
/// - [StandardReasoningMode] (`ReasoningMode.standard()`)
/// - [ProReasoningMode] (`ReasoningMode.pro()`)
///
/// The set of supported modes may expand over time; use
/// [CustomReasoningMode] (`ReasoningMode.custom(...)`) for any value not yet
/// modeled as a known mode.
///
/// ## Example
///
/// ```dart
/// final standard = ReasoningMode.standard();
/// final custom = ReasoningMode.custom('turbo');
/// ```
@immutable
sealed class ReasoningMode {
  /// Creates a [ReasoningMode].
  const ReasoningMode();

  /// The standard reasoning execution mode.
  const factory ReasoningMode.standard() = StandardReasoningMode;

  /// The pro reasoning execution mode.
  const factory ReasoningMode.pro() = ProReasoningMode;

  /// A custom reasoning execution mode with the given [value].
  ///
  /// Use this for modes not yet modeled as a known variant.
  const factory ReasoningMode.custom(String value) = CustomReasoningMode;

  /// Creates a [ReasoningMode] from a JSON value.
  factory ReasoningMode.fromJson(String json) => switch (json) {
    'standard' => const StandardReasoningMode(),
    'pro' => const ProReasoningMode(),
    _ => CustomReasoningMode(json),
  };

  /// The raw string value for this reasoning mode.
  String get value;

  /// Converts to JSON value.
  String toJson() => value;
}

/// The standard reasoning execution mode.
@immutable
class StandardReasoningMode extends ReasoningMode {
  /// Creates a [StandardReasoningMode].
  const StandardReasoningMode();

  @override
  String get value => 'standard';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StandardReasoningMode && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'ReasoningMode.standard()';
}

/// The pro reasoning execution mode.
@immutable
class ProReasoningMode extends ReasoningMode {
  /// Creates a [ProReasoningMode].
  const ProReasoningMode();

  @override
  String get value => 'pro';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProReasoningMode && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'ReasoningMode.pro()';
}

/// A custom reasoning execution mode.
///
/// Holds an arbitrary string value for modes not modeled as a known variant.
@immutable
class CustomReasoningMode extends ReasoningMode {
  /// Creates a [CustomReasoningMode] with the given [value].
  const CustomReasoningMode(this.value);

  /// The raw string value for this reasoning mode.
  @override
  final String value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomReasoningMode &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ReasoningMode.custom($value)';
}
