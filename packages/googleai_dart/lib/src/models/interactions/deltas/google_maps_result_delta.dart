part of 'deltas.dart';

/// A streamed delta for a Google Maps result.
class GoogleMapsResultDelta extends StepDeltaData {
  @override
  String get type => 'google_maps_result';

  /// The results of the Google Maps query.
  final List<GoogleMapsResultItem>? result;

  /// Signature hash for backend validation.
  final String? signature;

  /// Creates a [GoogleMapsResultDelta] instance.
  const GoogleMapsResultDelta({this.result, this.signature});

  /// Creates a [GoogleMapsResultDelta] from JSON.
  factory GoogleMapsResultDelta.fromJson(Map<String, dynamic> json) =>
      GoogleMapsResultDelta(
        result: (json['result'] as List<dynamic>?)
            ?.map(
              (e) => GoogleMapsResultItem.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
        signature: json['signature'] as String?,
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (result != null) 'result': result!.map((e) => e.toJson()).toList(),
    if (signature != null) 'signature': signature,
  };
}
