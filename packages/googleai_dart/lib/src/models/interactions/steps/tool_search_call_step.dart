part of 'steps.dart';

/// A server-side call to load deferred functions by name.
class ToolSearchCallStep extends InteractionStep {
  @override
  String get type => 'tool_search_call';

  /// The ID matched by [ToolSearchResultStep.callId].
  final String id;

  /// The requested functions. May be absent in a streamed step skeleton.
  final ToolSearchCallStepArguments? arguments;

  /// Opaque server signature to preserve when replaying step history.
  final String? signature;

  /// Creates a tool search call.
  const ToolSearchCallStep({
    required this.id,
    required ToolSearchCallStepArguments this.arguments,
    this.signature,
  });

  const ToolSearchCallStep._({required this.id, this.signature})
    : arguments = null;

  /// Parses a call. Set [partial] for a `step.start` event.
  factory ToolSearchCallStep.fromJson(
    Map<String, dynamic> json, {
    bool partial = false,
  }) {
    if (json['type'] != 'tool_search_call') {
      throw const FormatException(
        'ToolSearchCallStep: expected type "tool_search_call"',
      );
    }
    final id = json['id'];
    if (id is! String) {
      throw const FormatException('ToolSearchCallStep: missing required "id"');
    }
    final arguments = json['arguments'];
    if (arguments == null && partial) {
      return ToolSearchCallStep._(
        id: id,
        signature: json['signature'] as String?,
      );
    }
    if (arguments is! Map<String, dynamic>) {
      throw const FormatException(
        'ToolSearchCallStep: missing or invalid "arguments"',
      );
    }
    return ToolSearchCallStep(
      id: id,
      arguments: ToolSearchCallStepArguments.fromJson(arguments),
      signature: json['signature'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    if (arguments != null) 'arguments': arguments!.toJson(),
    if (signature != null) 'signature': signature,
  };
}

/// Arguments specifying which deferred functions to load.
class ToolSearchCallStepArguments {
  /// The function names to load explicitly.
  final List<String>? functionNames;

  /// Creates tool search call arguments.
  const ToolSearchCallStepArguments({this.functionNames});

  /// Parses tool search call arguments.
  factory ToolSearchCallStepArguments.fromJson(Map<String, dynamic> json) {
    final names = json['function_names'];
    if (names != null &&
        (names is! List || names.any((name) => name is! String))) {
      throw const FormatException(
        'ToolSearchCallStepArguments: invalid "function_names"',
      );
    }
    return ToolSearchCallStepArguments(
      functionNames: names == null ? null : List<String>.from(names as List),
    );
  }

  /// Converts the arguments to JSON.
  Map<String, dynamic> toJson() => {
    if (functionNames != null) 'function_names': functionNames,
  };
}
