part of 'deltas.dart';

/// A Google Maps result delta update.
class GoogleMapsResultDelta extends InteractionDelta {
  @override
  String get type => 'google_maps_result';

  /// ID to match the ID from the Google Maps call.
  final String? callId;

  /// The results of the Google Maps search.
  final List<GoogleMapsResult>? result;

  /// The signature of the Google Maps result.
  final String? signature;

  /// Creates a [GoogleMapsResultDelta] instance.
  const GoogleMapsResultDelta({this.callId, this.result, this.signature});

  /// Creates a [GoogleMapsResultDelta] from JSON.
  factory GoogleMapsResultDelta.fromJson(Map<String, dynamic> json) =>
      GoogleMapsResultDelta(
        callId: json['call_id'] as String?,
        result: (json['result'] as List<dynamic>?)
            ?.map((e) => GoogleMapsResult.fromJson(e as Map<String, dynamic>))
            .toList(),
        signature: json['signature'] as String?,
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (callId != null) 'call_id': callId,
    if (result != null) 'result': result!.map((e) => e.toJson()).toList(),
    if (signature != null) 'signature': signature,
  };
}
