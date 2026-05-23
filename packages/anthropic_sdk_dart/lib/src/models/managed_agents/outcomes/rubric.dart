import 'package:meta/meta.dart';

import '../../common/equality_helpers.dart';

/// Rubric for grading the quality of an outcome.
///
/// Variants:
/// - [FileRubric] — a rubric referenced by an uploaded file.
/// - [TextRubric] — rubric content provided inline as text.
/// - [UnknownRubric] — unrecognized rubric type, for forward compatibility.
sealed class Rubric {
  const Rubric();

  /// Creates a [Rubric] from JSON.
  ///
  /// Dispatches on the `type` discriminator; unrecognized values fall back to
  /// [UnknownRubric].
  factory Rubric.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'file' => FileRubric.fromJson(json),
      'text' => TextRubric.fromJson(json),
      _ => UnknownRubric(rawJson: json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Rubric referenced by a file uploaded via the Files API.
@immutable
class FileRubric extends Rubric {
  /// The rubric type, always 'file'.
  String get type => 'file';

  /// ID of the rubric file.
  final String fileId;

  /// Creates a [FileRubric].
  const FileRubric({required this.fileId});

  /// Creates a [FileRubric] from JSON.
  factory FileRubric.fromJson(Map<String, dynamic> json) {
    return FileRubric(fileId: json['file_id'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'file_id': fileId};

  /// Creates a copy with replaced values.
  FileRubric copyWith({String? fileId}) {
    return FileRubric(fileId: fileId ?? this.fileId);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileRubric &&
          runtimeType == other.runtimeType &&
          fileId == other.fileId;

  @override
  int get hashCode => fileId.hashCode;

  @override
  String toString() => 'FileRubric(fileId: $fileId)';
}

/// Rubric content provided inline as text.
@immutable
class TextRubric extends Rubric {
  /// The rubric type, always 'text'.
  String get type => 'text';

  /// Rubric content. Plain text or markdown — the grader treats it as freeform
  /// text.
  final String content;

  /// Creates a [TextRubric].
  const TextRubric({required this.content});

  /// Creates a [TextRubric] from JSON.
  factory TextRubric.fromJson(Map<String, dynamic> json) {
    return TextRubric(content: json['content'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'content': content};

  /// Creates a copy with replaced values.
  TextRubric copyWith({String? content}) {
    return TextRubric(content: content ?? this.content);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextRubric &&
          runtimeType == other.runtimeType &&
          content == other.content;

  @override
  int get hashCode => content.hashCode;

  @override
  String toString() => 'TextRubric(content: $content)';
}

/// Unrecognized rubric type — preserves raw JSON for forward compatibility.
@immutable
class UnknownRubric extends Rubric {
  /// The raw JSON.
  final Map<String, dynamic> rawJson;

  /// Creates an [UnknownRubric].
  const UnknownRubric({required this.rawJson});

  @override
  Map<String, dynamic> toJson() => rawJson;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownRubric &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownRubric(rawJson: $rawJson)';
}
