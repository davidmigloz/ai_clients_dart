part of 'steps.dart';

/// A Google Maps tool call step.
class GoogleMapsCallStep extends InteractionStep {
  @override
  String get type => 'google_maps_call';

  /// A unique ID for this specific tool call.
  final String id;

  /// The arguments to pass to the Google Maps tool.
  final GoogleMapsCallStepArguments? arguments;

  /// Signature hash for backend validation.
  final String? signature;

  /// Creates a [GoogleMapsCallStep] instance.
  const GoogleMapsCallStep({required this.id, this.arguments, this.signature});

  /// Creates a [GoogleMapsCallStep] from JSON.
  factory GoogleMapsCallStep.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'google_maps_call') {
      throw FormatException(
        'Expected type "google_maps_call" but got "${json['type']}"',
      );
    }
    final id = json['id'];
    if (id is! String) {
      throw const FormatException('GoogleMapsCallStep: missing required "id"');
    }
    return GoogleMapsCallStep(
      id: id,
      arguments: json['arguments'] != null
          ? GoogleMapsCallStepArguments.fromJson(
              json['arguments'] as Map<String, dynamic>,
            )
          : null,
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

  /// Creates a copy with replaced values.
  GoogleMapsCallStep copyWith({
    Object? id = unsetCopyWithValue,
    Object? arguments = unsetCopyWithValue,
    Object? signature = unsetCopyWithValue,
  }) {
    return GoogleMapsCallStep(
      id: id == unsetCopyWithValue ? this.id : id! as String,
      arguments: arguments == unsetCopyWithValue
          ? this.arguments
          : arguments as GoogleMapsCallStepArguments?,
      signature: signature == unsetCopyWithValue
          ? this.signature
          : signature as String?,
    );
  }
}

/// The arguments to pass to the Google Maps tool.
class GoogleMapsCallStepArguments {
  /// The queries to be executed.
  final List<String>? queries;

  /// Creates a [GoogleMapsCallStepArguments] instance.
  const GoogleMapsCallStepArguments({this.queries});

  /// Creates from JSON.
  factory GoogleMapsCallStepArguments.fromJson(Map<String, dynamic> json) =>
      GoogleMapsCallStepArguments(
        queries: (json['queries'] as List<dynamic>?)?.cast<String>(),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {if (queries != null) 'queries': queries};

  /// Creates a copy with replaced values.
  GoogleMapsCallStepArguments copyWith({Object? queries = unsetCopyWithValue}) {
    return GoogleMapsCallStepArguments(
      queries: queries == unsetCopyWithValue
          ? this.queries
          : queries as List<String>?,
    );
  }
}
