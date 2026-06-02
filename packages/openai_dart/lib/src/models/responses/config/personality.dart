import 'package:meta/meta.dart';

/// A model-owned style preset to apply to a request.
///
/// Omit the personality to use the model's default style. Values must be at
/// most 64 characters; the server rejects longer values.
///
/// Known presets are available as variants:
/// - [FriendlyPersonality] (`Personality.friendly()`)
/// - [PragmaticPersonality] (`Personality.pragmatic()`)
///
/// The set of supported presets may expand over time; use
/// [CustomPersonality] (`Personality.custom(...)`) for any value not yet
/// modeled as a known preset.
///
/// ## Example
///
/// ```dart
/// final friendly = Personality.friendly();
/// final custom = Personality.custom('concise');
/// ```
@immutable
sealed class Personality {
  /// Creates a [Personality].
  const Personality();

  /// The friendly style preset.
  const factory Personality.friendly() = FriendlyPersonality;

  /// The pragmatic style preset.
  const factory Personality.pragmatic() = PragmaticPersonality;

  /// A custom style preset with the given [value].
  ///
  /// Use this for presets not yet modeled as a known variant. Values must be
  /// at most 64 characters.
  const factory Personality.custom(String value) = CustomPersonality;

  /// Creates a [Personality] from a JSON value.
  factory Personality.fromJson(String json) => switch (json) {
    'friendly' => const FriendlyPersonality(),
    'pragmatic' => const PragmaticPersonality(),
    _ => CustomPersonality(json),
  };

  /// The raw string value for this personality.
  String get value;

  /// Converts to JSON value.
  String toJson() => value;
}

/// The friendly style preset.
@immutable
class FriendlyPersonality extends Personality {
  /// Creates a [FriendlyPersonality].
  const FriendlyPersonality();

  @override
  String get value => 'friendly';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FriendlyPersonality && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'Personality.friendly()';
}

/// The pragmatic style preset.
@immutable
class PragmaticPersonality extends Personality {
  /// Creates a [PragmaticPersonality].
  const PragmaticPersonality();

  @override
  String get value => 'pragmatic';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PragmaticPersonality && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'Personality.pragmatic()';
}

/// A custom style preset.
///
/// Holds an arbitrary string value for presets not modeled as a known
/// variant. The value must be at most 64 characters; the server rejects
/// longer values.
@immutable
class CustomPersonality extends Personality {
  /// Creates a [CustomPersonality] with the given [value].
  ///
  /// The server rejects values longer than 64 characters; this is documented
  /// rather than enforced client-side, matching the package convention for
  /// length-limited string fields (e.g. `ServiceTier`, tool names).
  const CustomPersonality(this.value);

  /// The raw string value for this personality.
  @override
  final String value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomPersonality &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Personality.custom($value)';
}
