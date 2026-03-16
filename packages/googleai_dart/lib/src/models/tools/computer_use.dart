import '../copy_with_sentinel.dart';
import 'computer_use_environment.dart';

/// Computer Use tool type.
///
/// Allows the model to interact directly with the computer. If enabled,
/// it automatically populates computer-use specific Function Declarations.
class ComputerUse {
  /// The environment being operated.
  ///
  /// Currently only [ComputerUseEnvironment.browser] is supported.
  final ComputerUseEnvironment? environment;

  /// List of predefined functions to exclude from the model call.
  ///
  /// By default, predefined functions are included in the final model call.
  /// Some can be explicitly excluded to use a more restricted action space
  /// or to provide improved definitions for predefined functions.
  final List<String>? excludedPredefinedFunctions;

  /// Creates a [ComputerUse].
  const ComputerUse({this.environment, this.excludedPredefinedFunctions});

  /// Creates a [ComputerUse] from JSON.
  factory ComputerUse.fromJson(Map<String, dynamic> json) => ComputerUse(
    environment: json['environment'] != null
        ? computerUseEnvironmentFromString(json['environment'] as String)
        : null,
    excludedPredefinedFunctions:
        (json['excludedPredefinedFunctions'] as List<dynamic>?)?.cast<String>(),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (environment != null)
      'environment': computerUseEnvironmentToString(environment!),
    if (excludedPredefinedFunctions != null)
      'excludedPredefinedFunctions': excludedPredefinedFunctions,
  };

  /// Creates a copy with replaced values.
  ComputerUse copyWith({
    Object? environment = unsetCopyWithValue,
    Object? excludedPredefinedFunctions = unsetCopyWithValue,
  }) {
    return ComputerUse(
      environment: environment == unsetCopyWithValue
          ? this.environment
          : environment as ComputerUseEnvironment?,
      excludedPredefinedFunctions:
          excludedPredefinedFunctions == unsetCopyWithValue
          ? this.excludedPredefinedFunctions
          : excludedPredefinedFunctions as List<String>?,
    );
  }

  @override
  String toString() =>
      'ComputerUse('
      'environment: $environment, '
      'excludedPredefinedFunctions: $excludedPredefinedFunctions)';
}
