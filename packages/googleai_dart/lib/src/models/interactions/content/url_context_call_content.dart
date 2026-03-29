part of 'content.dart';

/// A URL context call content block.
class UrlContextCallContent extends InteractionContent {
  @override
  String get type => 'url_context_call';

  /// A unique ID for this specific tool call.
  final String id;

  /// The URLs to fetch.
  final List<String>? urls;

  /// The signature of the URL context call.
  final String? signature;

  /// Creates a [UrlContextCallContent] instance.
  const UrlContextCallContent({required this.id, this.urls, this.signature});

  /// Creates a [UrlContextCallContent] from JSON.
  ///
  /// The [id] field defaults to `''` when absent (e.g. content.start events).
  factory UrlContextCallContent.fromJson(Map<String, dynamic> json) {
    final arguments = json['arguments'] as Map<String, dynamic>?;
    return UrlContextCallContent(
      id: json['id'] as String? ?? '',
      urls: (arguments?['urls'] as List<dynamic>?)?.cast<String>(),
      signature: json['signature'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'arguments': {if (urls != null) 'urls': urls},
    if (signature != null) 'signature': signature,
  };

  /// Creates a copy with replaced values.
  UrlContextCallContent copyWith({
    Object? id = unsetCopyWithValue,
    Object? urls = unsetCopyWithValue,
    Object? signature = unsetCopyWithValue,
  }) {
    return UrlContextCallContent(
      id: id == unsetCopyWithValue ? this.id : id! as String,
      urls: urls == unsetCopyWithValue ? this.urls : urls as List<String>?,
      signature: signature == unsetCopyWithValue
          ? this.signature
          : signature as String?,
    );
  }
}
