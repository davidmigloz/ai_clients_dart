import 'package:meta/meta.dart';

/// Annotation for output content (citations, etc.).
///
/// See [UrlCitation], [FileCitation], [ContainerFileCitation], and
/// [FilePathAnnotation].
sealed class Annotation {
  /// Creates an [Annotation].
  const Annotation();

  /// Creates an [Annotation] from JSON.
  factory Annotation.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'url_citation' => UrlCitation.fromJson(json),
      'file_citation' => FileCitation.fromJson(json),
      'container_file_citation' => ContainerFileCitation.fromJson(json),
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
@immutable
class FileCitation extends Annotation {
  /// The index in the text where the citation occurs.
  final int index;

  /// The cited file ID.
  final String fileId;

  /// The filename.
  final String filename;

  /// Creates a [FileCitation].
  const FileCitation({
    required this.index,
    required this.fileId,
    required this.filename,
  });

  /// Creates a [FileCitation] from JSON.
  factory FileCitation.fromJson(Map<String, dynamic> json) {
    return FileCitation(
      index: json['index'] as int,
      fileId: json['file_id'] as String,
      filename: json['filename'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'file_citation',
    'index': index,
    'file_id': fileId,
    'filename': filename,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileCitation &&
          runtimeType == other.runtimeType &&
          index == other.index &&
          fileId == other.fileId &&
          filename == other.filename;

  @override
  int get hashCode => Object.hash(index, fileId, filename);

  @override
  String toString() =>
      'FileCitation(index: $index, fileId: $fileId, filename: $filename)';
}

/// Container file citation annotation.
@immutable
class ContainerFileCitation extends Annotation {
  /// The container ID.
  final String containerId;

  /// The cited file ID.
  final String fileId;

  /// The start index in the text.
  final int startIndex;

  /// The end index in the text.
  final int endIndex;

  /// The filename.
  final String filename;

  /// Creates a [ContainerFileCitation].
  const ContainerFileCitation({
    required this.containerId,
    required this.fileId,
    required this.startIndex,
    required this.endIndex,
    required this.filename,
  });

  /// Creates a [ContainerFileCitation] from JSON.
  factory ContainerFileCitation.fromJson(Map<String, dynamic> json) {
    return ContainerFileCitation(
      containerId: json['container_id'] as String,
      fileId: json['file_id'] as String,
      startIndex: json['start_index'] as int,
      endIndex: json['end_index'] as int,
      filename: json['filename'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'container_file_citation',
    'container_id': containerId,
    'file_id': fileId,
    'start_index': startIndex,
    'end_index': endIndex,
    'filename': filename,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContainerFileCitation &&
          runtimeType == other.runtimeType &&
          containerId == other.containerId &&
          fileId == other.fileId &&
          startIndex == other.startIndex &&
          endIndex == other.endIndex &&
          filename == other.filename;

  @override
  int get hashCode =>
      Object.hash(containerId, fileId, startIndex, endIndex, filename);

  @override
  String toString() =>
      'ContainerFileCitation(containerId: $containerId, fileId: $fileId, startIndex: $startIndex, endIndex: $endIndex, filename: $filename)';
}

/// File path annotation.
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
