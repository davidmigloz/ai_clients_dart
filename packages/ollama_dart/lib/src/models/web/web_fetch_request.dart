import 'package:meta/meta.dart';

/// Request to fetch a web page.
@immutable
class WebFetchRequest {
  /// The URL to fetch.
  final String url;

  /// Creates a [WebFetchRequest].
  const WebFetchRequest({required this.url});

  /// Creates a [WebFetchRequest] from JSON.
  factory WebFetchRequest.fromJson(Map<String, dynamic> json) =>
      WebFetchRequest(url: json['url'] as String);

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'url': url};

  /// Creates a copy with replaced values.
  WebFetchRequest copyWith({String? url}) {
    return WebFetchRequest(url: url ?? this.url);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebFetchRequest &&
          runtimeType == other.runtimeType &&
          url == other.url;

  @override
  int get hashCode => url.hashCode;

  @override
  String toString() => 'WebFetchRequest(url: $url)';
}
