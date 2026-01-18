import 'package:meta/meta.dart';

/// Annotation for output content (citations, etc.).
sealed class Annotation {
  /// Creates an [Annotation].
  const Annotation();

  /// Creates an [Annotation] from JSON.
  factory Annotation.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'url_citation' => UrlCitation.fromJson(json),
      'file_citation' => FileCitation.fromJson(json),
      'file_path' => FilePathAnnotation.fromJson(json),
      _ => throw FormatException('Unknown Annotation type: $type'),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// URL citation annotation.
@immutable
class UrlCitation extends Annotation {
  /// The start index in the text.
  final int startIndex;

  /// The end index in the text.
  final int endIndex;

  /// The cited URL.
  final String url;

  /// The title of the cited resource.
  final String title;

  /// Creates a [UrlCitation].
  const UrlCitation({
    required this.startIndex,
    required this.endIndex,
    required this.url,
    required this.title,
  });

  /// Creates a [UrlCitation] from JSON.
  factory UrlCitation.fromJson(Map<String, dynamic> json) {
    return UrlCitation(
      startIndex: json['start_index'] as int,
      endIndex: json['end_index'] as int,
      url: json['url'] as String,
      title: json['title'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'url_citation',
    'start_index': startIndex,
    'end_index': endIndex,
    'url': url,
    'title': title,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UrlCitation &&
          runtimeType == other.runtimeType &&
          startIndex == other.startIndex &&
          endIndex == other.endIndex &&
          url == other.url &&
          title == other.title;

  @override
  int get hashCode => Object.hash(startIndex, endIndex, url, title);

  @override
  String toString() =>
      'UrlCitation(startIndex: $startIndex, endIndex: $endIndex, url: $url, title: $title)';
}

/// File citation annotation.
///
/// **Note:** This is an extension annotation type not present in the official
/// OpenResponses spec. It is included for compatibility with providers that
/// support file citations.
@immutable
class FileCitation extends Annotation {
  /// The start index in the text.
  final int startIndex;

  /// The end index in the text.
  final int endIndex;

  /// The cited file ID.
  final String fileId;

  /// The filename.
  final String? filename;

  /// Creates a [FileCitation].
  const FileCitation({
    required this.startIndex,
    required this.endIndex,
    required this.fileId,
    this.filename,
  });

  /// Creates a [FileCitation] from JSON.
  factory FileCitation.fromJson(Map<String, dynamic> json) {
    return FileCitation(
      startIndex: json['start_index'] as int,
      endIndex: json['end_index'] as int,
      fileId: json['file_id'] as String,
      filename: json['filename'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'file_citation',
    'start_index': startIndex,
    'end_index': endIndex,
    'file_id': fileId,
    if (filename != null) 'filename': filename,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileCitation &&
          runtimeType == other.runtimeType &&
          startIndex == other.startIndex &&
          endIndex == other.endIndex &&
          fileId == other.fileId &&
          filename == other.filename;

  @override
  int get hashCode => Object.hash(startIndex, endIndex, fileId, filename);

  @override
  String toString() =>
      'FileCitation(startIndex: $startIndex, endIndex: $endIndex, fileId: $fileId, filename: $filename)';
}

/// File path annotation.
///
/// **Note:** This is an extension annotation type not present in the official
/// OpenResponses spec. It is included for compatibility with providers that
/// support file path annotations.
@immutable
class FilePathAnnotation extends Annotation {
  /// The start index in the text.
  final int startIndex;

  /// The end index in the text.
  final int endIndex;

  /// The file path.
  final String filePath;

  /// Creates a [FilePathAnnotation].
  const FilePathAnnotation({
    required this.startIndex,
    required this.endIndex,
    required this.filePath,
  });

  /// Creates a [FilePathAnnotation] from JSON.
  factory FilePathAnnotation.fromJson(Map<String, dynamic> json) {
    return FilePathAnnotation(
      startIndex: json['start_index'] as int,
      endIndex: json['end_index'] as int,
      filePath: json['file_path'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'file_path',
    'start_index': startIndex,
    'end_index': endIndex,
    'file_path': filePath,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilePathAnnotation &&
          runtimeType == other.runtimeType &&
          startIndex == other.startIndex &&
          endIndex == other.endIndex &&
          filePath == other.filePath;

  @override
  int get hashCode => Object.hash(startIndex, endIndex, filePath);

  @override
  String toString() =>
      'FilePathAnnotation(startIndex: $startIndex, endIndex: $endIndex, filePath: $filePath)';
}
