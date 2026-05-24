part of 'deltas.dart';

/// A streamed delta for a Google Maps tool call.
class GoogleMapsCallDelta extends StepDeltaData {
  @override
  String get type => 'google_maps_call';

  /// The arguments for the Google Maps call.
  final GoogleMapsCallStepArguments? arguments;

  /// Signature hash for backend validation.
  final String? signature;

  /// Creates a [GoogleMapsCallDelta] instance.
  const GoogleMapsCallDelta({this.arguments, this.signature});

  /// Creates a [GoogleMapsCallDelta] from JSON.
  factory GoogleMapsCallDelta.fromJson(Map<String, dynamic> json) =>
      GoogleMapsCallDelta(
        arguments: json['arguments'] is Map<String, dynamic>
            ? GoogleMapsCallStepArguments.fromJson(
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
