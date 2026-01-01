import 'package:meta/meta.dart';

/// Source for document content.
///
/// Documents can be provided as base64-encoded PDF data, plain text, or URLs.
sealed class DocumentSource {
  const DocumentSource();

  /// Creates a base64-encoded PDF source.
  factory DocumentSource.base64Pdf(String data) = Base64PdfSource;

  /// Creates a plain text source.
  factory DocumentSource.text(String data) = PlainTextSource;

  /// Creates a URL-based PDF source.
  factory DocumentSource.url(String url) = UrlPdfSource;

  /// Creates a [DocumentSource] from JSON.
  factory DocumentSource.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'base64' => Base64PdfSource.fromJson(json),
      'text' => PlainTextSource.fromJson(json),
      'url' => UrlPdfSource.fromJson(json),
      _ => throw FormatException('Unknown DocumentSource type: $type'),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Base64-encoded PDF document source.
@immutable
class Base64PdfSource extends DocumentSource {
  /// Base64-encoded PDF data.
  final String data;

  /// Creates a [Base64PdfSource].
  const Base64PdfSource(this.data);

  /// Creates a [Base64PdfSource] from JSON.
  factory Base64PdfSource.fromJson(Map<String, dynamic> json) {
    return Base64PdfSource(json['data'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'base64',
    'data': data,
    'media_type': 'application/pdf',
  };

  /// Creates a copy with replaced values.
  Base64PdfSource copyWith({String? data}) {
    return Base64PdfSource(data ?? this.data);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Base64PdfSource &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'Base64PdfSource(data: [${data.length} chars])';
}

/// Plain text document source.
@immutable
class PlainTextSource extends DocumentSource {
  /// Plain text data.
  final String data;

  /// Creates a [PlainTextSource].
  const PlainTextSource(this.data);

  /// Creates a [PlainTextSource] from JSON.
  factory PlainTextSource.fromJson(Map<String, dynamic> json) {
    return PlainTextSource(json['data'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'text',
    'data': data,
    'media_type': 'text/plain',
  };

  /// Creates a copy with replaced values.
  PlainTextSource copyWith({String? data}) {
    return PlainTextSource(data ?? this.data);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlainTextSource &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'PlainTextSource(data: [${data.length} chars])';
}

/// URL-based PDF document source.
@immutable
class UrlPdfSource extends DocumentSource {
  /// URL of the PDF document.
  final String url;

  /// Creates a [UrlPdfSource].
  const UrlPdfSource(this.url);

  /// Creates a [UrlPdfSource] from JSON.
  factory UrlPdfSource.fromJson(Map<String, dynamic> json) {
    return UrlPdfSource(json['url'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'url', 'url': url};

  /// Creates a copy with replaced values.
  UrlPdfSource copyWith({String? url}) {
    return UrlPdfSource(url ?? this.url);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UrlPdfSource &&
          runtimeType == other.runtimeType &&
          url == other.url;

  @override
  int get hashCode => url.hashCode;

  @override
  String toString() => 'UrlPdfSource(url: $url)';
}
