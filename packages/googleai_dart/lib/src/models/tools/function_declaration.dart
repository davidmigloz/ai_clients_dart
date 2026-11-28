import '../copy_with_sentinel.dart';
import '../generation/schema.dart';

/// Controls how a supported Live model waits for a function response.
enum FunctionDeclarationBehavior {
  /// Lets the model choose its default behavior.
  unspecified('UNSPECIFIED'),

  /// Waits for the function response before continuing the conversation.
  blocking('BLOCKING'),

  /// Continues the conversation while the function is running.
  nonBlocking('NON_BLOCKING');

  const FunctionDeclarationBehavior(this.value);

  /// The wire value for this behavior.
  final String value;

  /// Parses a wire value.
  static FunctionDeclarationBehavior fromJson(String value) =>
      switch (value.toUpperCase()) {
        'BLOCKING' => blocking,
        'NON_BLOCKING' => nonBlocking,
        _ => unspecified,
      };

  /// Returns the wire value for this behavior.
  String toJson() => value;
}

/// Structured representation of a function declaration.
class FunctionDeclaration {
  /// The name of the function.
  final String name;

  /// Description of what the function does.
  final String description;

  /// Parameters for the function (as a Schema object).
  final Schema? parameters;

  /// Function response behavior for a supported BidiGenerateContent model.
  final FunctionDeclarationBehavior? behavior;

  /// Creates a [FunctionDeclaration].
  const FunctionDeclaration({
    required this.name,
    required this.description,
    this.parameters,
    this.behavior,
  });

  /// Creates a [FunctionDeclaration] from JSON.
  factory FunctionDeclaration.fromJson(Map<String, dynamic> json) =>
      FunctionDeclaration(
        name: json['name'] as String,
        description: json['description'] as String,
        parameters: json['parameters'] != null
            ? Schema.fromJson(json['parameters'] as Map<String, dynamic>)
            : null,
        behavior: json['behavior'] == null
            ? null
            : FunctionDeclarationBehavior.fromJson(json['behavior'] as String),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'behavior': ?behavior?.toJson(),
    if (parameters != null) 'parameters': parameters!.toJson(),
  };

  /// Creates a copy with replaced values.
  FunctionDeclaration copyWith({
    Object? name = unsetCopyWithValue,
    Object? description = unsetCopyWithValue,
    Object? parameters = unsetCopyWithValue,
    Object? behavior = unsetCopyWithValue,
  }) {
    return FunctionDeclaration(
      name: name == unsetCopyWithValue ? this.name : name! as String,
      description: description == unsetCopyWithValue
          ? this.description
          : description! as String,
      parameters: parameters == unsetCopyWithValue
          ? this.parameters
          : parameters as Schema?,
      behavior: behavior == unsetCopyWithValue
          ? this.behavior
          : behavior as FunctionDeclarationBehavior?,
    );
  }
}
