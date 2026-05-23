part of 'steps.dart';

/// A URL context tool call step.
class UrlContextCallStep extends InteractionStep {
  @override
  String get type => 'url_context_call';

  /// A unique ID for this specific tool call.
  final String id;

  /// The arguments to pass to the URL context tool.
  final UrlContextCallStepArguments arguments;

  /// Signature hash for backend validation.
  final String? signature;

  /// Creates a [UrlContextCallStep] instance.
  const UrlContextCallStep({
    required this.id,
    required this.arguments,
    this.signature,
  });

  /// Creates a [UrlContextCallStep] from JSON.
  factory UrlContextCallStep.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'url_context_call') {
      throw FormatException(
        'Expected type "url_context_call" but got "${json['type']}"',
      );
    }
    final id = json['id'];
    if (id is! String) {
      throw const FormatException('UrlContextCallStep: missing required "id"');
    }
    // In streaming `step.start`, the step arrives as a partial skeleton and
    // `arguments` is populated later via `step.delta`; default to empty when
    // absent.
    final argumentsJson = json['arguments'];
    final arguments = argumentsJson is Map<String, dynamic>
        ? UrlContextCallStepArguments.fromJson(argumentsJson)
        : const UrlContextCallStepArguments();
    return UrlContextCallStep(
      id: id,
      arguments: arguments,
      signature: json['signature'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'arguments': arguments.toJson(),
    if (signature != null) 'signature': signature,
  };

  /// Creates a copy with replaced values.
  UrlContextCallStep copyWith({
    Object? id = unsetCopyWithValue,
    Object? arguments = unsetCopyWithValue,
    Object? signature = unsetCopyWithValue,
  }) {
    return UrlContextCallStep(
      id: id == unsetCopyWithValue ? this.id : id! as String,
      arguments: arguments == unsetCopyWithValue
          ? this.arguments
          : arguments! as UrlContextCallStepArguments,
      signature: signature == unsetCopyWithValue
          ? this.signature
          : signature as String?,
    );
  }
}

/// The arguments to pass to the URL context tool.
class UrlContextCallStepArguments {
  /// The URLs to fetch.
  final List<String>? urls;

  /// Creates a [UrlContextCallStepArguments] instance.
  const UrlContextCallStepArguments({this.urls});

  /// Creates a [UrlContextCallStepArguments] from JSON.
  factory UrlContextCallStepArguments.fromJson(Map<String, dynamic> json) =>
      UrlContextCallStepArguments(
        urls: (json['urls'] as List<dynamic>?)?.cast<String>(),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {if (urls != null) 'urls': urls};

  /// Creates a copy with replaced values.
  UrlContextCallStepArguments copyWith({Object? urls = unsetCopyWithValue}) {
    return UrlContextCallStepArguments(
      urls: urls == unsetCopyWithValue ? this.urls : urls as List<String>?,
    );
  }
}
