import 'package:meta/meta.dart';

import 'summary_status.dart';

/// Request body for setting the summary field of a RAG search index or
/// schema (beta).
///
/// The API only accepts [SummaryStatus.handwritten] or
/// [SummaryStatus.generatedConfirmed] for [status] on this endpoint (unlike
/// [SummaryFieldResponse], which can also report [SummaryStatus.generated]).
@immutable
class UpdateSummaryRequest {
  /// The summary content.
  final String content;

  /// The status of the summary.
  ///
  /// Must be [SummaryStatus.handwritten] or
  /// [SummaryStatus.generatedConfirmed].
  final SummaryStatus status;

  /// Whether the summary content has been translated.
  final bool translated;

  /// Creates an [UpdateSummaryRequest].
  const UpdateSummaryRequest({
    required this.content,
    required this.status,
    required this.translated,
  });

  /// Creates an [UpdateSummaryRequest] from JSON.
  factory UpdateSummaryRequest.fromJson(Map<String, dynamic> json) =>
      UpdateSummaryRequest(
        content: json['content'] as String,
        status: SummaryStatus.fromJson(json['status'] as String?),
        translated: json['translated'] as bool,
      );

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {
    'content': content,
    'status': status.toJson(),
    'translated': translated,
  };

  /// Creates a copy with the given fields replaced.
  UpdateSummaryRequest copyWith({
    String? content,
    SummaryStatus? status,
    bool? translated,
  }) => UpdateSummaryRequest(
    content: content ?? this.content,
    status: status ?? this.status,
    translated: translated ?? this.translated,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateSummaryRequest &&
          runtimeType == other.runtimeType &&
          content == other.content &&
          status == other.status &&
          translated == other.translated;

  @override
  int get hashCode => Object.hash(content, status, translated);

  @override
  String toString() =>
      'UpdateSummaryRequest('
      'content: $content, status: $status, translated: $translated)';
}
