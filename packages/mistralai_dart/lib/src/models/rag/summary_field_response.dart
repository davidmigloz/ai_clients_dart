import 'package:meta/meta.dart';

import 'summary_status.dart';

/// The summary field of a RAG search index or schema (beta).
@immutable
class SummaryFieldResponse {
  /// The summary content.
  final String content;

  /// The status of the summary.
  final SummaryStatus status;

  /// Whether the summary content has been translated.
  final bool translated;

  /// Creates a [SummaryFieldResponse].
  const SummaryFieldResponse({
    required this.content,
    required this.status,
    required this.translated,
  });

  /// Creates a [SummaryFieldResponse] from JSON.
  factory SummaryFieldResponse.fromJson(Map<String, dynamic> json) =>
      SummaryFieldResponse(
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
  SummaryFieldResponse copyWith({
    String? content,
    SummaryStatus? status,
    bool? translated,
  }) => SummaryFieldResponse(
    content: content ?? this.content,
    status: status ?? this.status,
    translated: translated ?? this.translated,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SummaryFieldResponse &&
          runtimeType == other.runtimeType &&
          content == other.content &&
          status == other.status &&
          translated == other.translated;

  @override
  int get hashCode => Object.hash(content, status, translated);

  @override
  String toString() =>
      'SummaryFieldResponse('
      'content: $content, status: $status, translated: $translated)';
}
