part of 'tools.dart';

/// A tool that allows the model to use Google Maps.
class GoogleMapsTool extends InteractionTool {
  @override
  String get type => 'google_maps';

  /// Whether to enable the widget.
  final bool? enableWidget;

  /// The latitude coordinate.
  final double? latitude;

  /// The longitude coordinate.
  final double? longitude;

  /// Creates a [GoogleMapsTool] instance.
  const GoogleMapsTool({this.enableWidget, this.latitude, this.longitude});

  /// Creates a [GoogleMapsTool] from JSON.
  factory GoogleMapsTool.fromJson(Map<String, dynamic> json) => GoogleMapsTool(
    enableWidget: json['enable_widget'] as bool?,
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
  );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (enableWidget != null) 'enable_widget': enableWidget,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
  };
}
