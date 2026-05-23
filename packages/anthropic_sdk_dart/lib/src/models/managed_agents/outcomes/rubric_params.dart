import 'package:meta/meta.dart';

import '../../common/equality_helpers.dart';

/// Rubric for grading the quality of an outcome, for create requests.
///
/// Variants:
/// - [FileRubricParams] — a rubric referenced by an uploaded file.
/// - [TextRubricParams] — rubric content provided inline as text.
/// - [UnknownRubricParams] — unrecognized rubric type, for forward
///   compatibility.
sealed class RubricParams {
  const RubricParams();

  /// Creates a [RubricParams] from JSON.
  ///
  /// Dispatches on the `type` discriminator; unrecognized values fall back to
  /// [UnknownRubricParams].
  factory RubricParams.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'file' => FileRubricParams.fromJson(json),
      'text' => TextRubricParams.fromJson(json),
      _ => UnknownRubricParams(rawJson: json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Rubric referenced by a file uploaded via the Files API.
@immutable
class FileRubricParams extends RubricParams {
  /// The rubric type, always 'file'.
  String get type => 'file';

  /// ID of the rubric file.
  final String fileId;

  /// Creates a [FileRubricParams].
  const FileRubricParams({required this.fileId});

  /// Creates a [FileRubricParams] from JSON.
  factory FileRubricParams.fromJson(Map<String, dynamic> json) {
    return FileRubricParams(fileId: json['file_id'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'file_id': fileId};

  /// Creates a copy with replaced values.
  FileRubricParams copyWith({String? fileId}) {
    return FileRubricParams(fileId: fileId ?? this.fileId);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileRubricParams &&
          runtimeType == other.runtimeType &&
          fileId == other.fileId;

  @override
  int get hashCode => fileId.hashCode;

  @override
  String toString() => 'FileRubricParams(fileId: $fileId)';
}

/// Rubric content provided inline as text.
@immutable
class TextRubricParams extends RubricParams {
  /// The rubric type, always 'text'.
  String get type => 'text';

  /// Rubric content. Plain text or markdown — the grader treats it as freeform
  /// text. Maximum 262144 characters.
  final String content;

  /// Creates a [TextRubricParams].
  const TextRubricParams({required this.content});

  /// Creates a [TextRubricParams] from JSON.
  factory TextRubricParams.fromJson(Map<String, dynamic> json) {
    return TextRubricParams(content: json['content'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'content': content};

  /// Creates a copy with replaced values.
  TextRubricParams copyWith({String? content}) {
    return TextRubricParams(content: content ?? this.content);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextRubricParams &&
          runtimeType == other.runtimeType &&
          content == other.content;

  @override
  int get hashCode => content.hashCode;

  @override
  String toString() => 'TextRubricParams(content: $content)';
}

/// Unrecognized rubric type — preserves raw JSON for forward compatibility.
@immutable
class UnknownRubricParams extends RubricParams {
  /// The raw JSON.
  final Map<String, dynamic> rawJson;

  /// Creates an [UnknownRubricParams].
  const UnknownRubricParams({required this.rawJson});

  @override
  Map<String, dynamic> toJson() => rawJson;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownRubricParams &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownRubricParams(rawJson: $rawJson)';
}
