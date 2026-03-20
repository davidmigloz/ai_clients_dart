part of 'deltas.dart';

/// A Google Maps call delta update.
class GoogleMapsCallDelta extends InteractionDelta {
  @override
  String get type => 'google_maps_call';

  /// A unique ID for this specific tool call.
  final String? id;

  /// The queries for the Google Maps search.
  final List<String>? queries;

  /// The signature of the Google Maps call.
  final String? signature;

  /// Creates a [GoogleMapsCallDelta] instance.
  const GoogleMapsCallDelta({this.id, this.queries, this.signature});

  /// Creates a [GoogleMapsCallDelta] from JSON.
  factory GoogleMapsCallDelta.fromJson(Map<String, dynamic> json) {
    final arguments = json['arguments'] as Map<String, dynamic>?;
    return GoogleMapsCallDelta(
      id: json['id'] as String?,
      queries: (arguments?['queries'] as List<dynamic>?)?.cast<String>(),
      signature: json['signature'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (id != null) 'id': id,
    if (queries != null) 'arguments': {'queries': queries},
    if (signature != null) 'signature': signature,
  };
}
