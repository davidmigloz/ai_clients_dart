part of 'content.dart';

/// A Google Maps call content block.
class GoogleMapsCallContent extends InteractionContent {
  @override
  String get type => 'google_maps_call';

  /// A unique ID for this specific tool call.
  final String? id;

  /// The queries for the Google Maps search.
  final List<String>? queries;

  /// The signature of the Google Maps call.
  final String? signature;

  /// Creates a [GoogleMapsCallContent] instance.
  const GoogleMapsCallContent({this.id, this.queries, this.signature});

  /// Creates a [GoogleMapsCallContent] from JSON.
  factory GoogleMapsCallContent.fromJson(Map<String, dynamic> json) {
    final arguments = json['arguments'] as Map<String, dynamic>?;
    return GoogleMapsCallContent(
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

  /// Creates a copy with replaced values.
  GoogleMapsCallContent copyWith({
    Object? id = unsetCopyWithValue,
    Object? queries = unsetCopyWithValue,
    Object? signature = unsetCopyWithValue,
  }) {
    return GoogleMapsCallContent(
      id: id == unsetCopyWithValue ? this.id : id as String?,
      queries: queries == unsetCopyWithValue
          ? this.queries
          : queries as List<String>?,
      signature: signature == unsetCopyWithValue
          ? this.signature
          : signature as String?,
    );
  }
}
