part of 'deltas.dart';

/// A streamed delta for a URL context tool call.
class UrlContextCallDelta extends StepDeltaData {
  @override
  String get type => 'url_context_call';

  /// The arguments for the URL context call.
  final UrlContextCallStepArguments? arguments;

  /// Signature hash for backend validation.
  final String? signature;

  /// Creates a [UrlContextCallDelta] instance.
  const UrlContextCallDelta({this.arguments, this.signature});

  /// Creates a [UrlContextCallDelta] from JSON.
  factory UrlContextCallDelta.fromJson(Map<String, dynamic> json) =>
      UrlContextCallDelta(
        arguments: json['arguments'] is Map<String, dynamic>
            ? UrlContextCallStepArguments.fromJson(
                json['arguments'] as Map<String, dynamic>,
              )
            : null,
        signature: json['signature'] as String?,
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (arguments != null) 'arguments': arguments!.toJson(),
    if (signature != null) 'signature': signature,
  };
}
