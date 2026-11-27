part of 'steps.dart';

/// A function tool call step.
class FunctionCallStep extends InteractionStep {
  @override
  String get type => 'function_call';

  /// A unique ID for this specific tool call.
  final String id;

  /// The name of the tool to call.
  final String name;

  final Object? _arguments;

  /// The decoded arguments. Empty until available for a streamed step.
  Map<String, dynamic> get arguments => switch (_arguments) {
    final Map<String, dynamic> arguments => arguments,
    _ => const {},
  };

  /// The initial JSON argument fragment, when sent with a streamed step.
  /// Combine it with the subsequent argument deltas for the same step.
  String? get argumentsFragment => switch (_arguments) {
    final String fragment => fragment,
    _ => null,
  };

  /// Opaque signature to preserve when replaying a stateless tool call.
  final String? signature;

  /// Creates a [FunctionCallStep] instance.
  const FunctionCallStep({
    required this.id,
    required this.name,
    required Map<String, dynamic> this._arguments,
    this.signature,
  });

  const FunctionCallStep._({
    required this.id,
    required this.name,
    required this._arguments,
    this.signature,
  });

  /// Creates a [FunctionCallStep] from JSON.
  ///
  /// Set [partial] for a `step.start` event, which may carry an argument
  /// fragment or omit arguments until later deltas.
  factory FunctionCallStep.fromJson(
    Map<String, dynamic> json, {
    bool partial = false,
  }) {
    if (json['type'] != 'function_call') {
      throw FormatException(
        'Expected type "function_call" but got "${json['type']}"',
      );
    }
    final id = json['id'];
    if (id is! String) {
      throw const FormatException('FunctionCallStep: missing required "id"');
    }
    final name = json['name'];
    if (name is! String) {
      throw const FormatException('FunctionCallStep: missing required "name"');
    }
    final arguments = json['arguments'];
    if (arguments is! Map<String, dynamic> &&
        !(partial && (arguments == null || arguments is String))) {
      throw const FormatException(
        'FunctionCallStep: missing required "arguments"',
      );
    }
    return FunctionCallStep._(
      id: id,
      name: name,
      arguments: arguments,
      signature: json['signature'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'name': name,
    if (_arguments != null) 'arguments': _arguments,
    if (signature != null) 'signature': signature,
  };

  /// Creates a copy with replaced values.
  FunctionCallStep copyWith({
    Object? id = unsetCopyWithValue,
    Object? name = unsetCopyWithValue,
    Object? arguments = unsetCopyWithValue,
    Object? signature = unsetCopyWithValue,
  }) {
    return FunctionCallStep._(
      id: id == unsetCopyWithValue ? this.id : id! as String,
      name: name == unsetCopyWithValue ? this.name : name! as String,
      arguments: arguments == unsetCopyWithValue
          ? _arguments
          : arguments! as Map<String, dynamic>,
      signature: signature == unsetCopyWithValue
          ? this.signature
          : signature as String?,
    );
  }
}
