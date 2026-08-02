import 'package:meta/meta.dart';

import 'summary_status.dart';

/// Sealed class for a single line of the newline-delimited JSON (NDJSON)
/// stream returned when generating a RAG search index or schema summary
/// (beta).
///
/// Unlike most sealed unions in this package, the API does not send a
/// discriminator field for this union; instead, dispatch on JSON key
/// presence:
/// - a `content` key means [SummaryStreamChunk]
/// - an `error` key means [SummaryStreamError]
/// - otherwise (a `status`/`translated` pair) means [SummaryStreamMetadata]
///
/// Subtypes:
/// - [SummaryStreamMetadata]: sent first, describing the existing summary.
/// - [SummaryStreamChunk]: a chunk of generated summary content.
/// - [SummaryStreamError]: an error encountered while streaming.
sealed class SummaryStreamEvent {
  const SummaryStreamEvent();

  /// Creates a [SummaryStreamEvent] from a single decoded NDJSON line.
  factory SummaryStreamEvent.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('content')) {
      return SummaryStreamChunk.fromJson(json);
    }
    if (json.containsKey('error')) {
      return SummaryStreamError.fromJson(json);
    }
    return SummaryStreamMetadata.fromJson(json);
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Metadata about the summary being (re)generated.
///
/// Expected to be the first value returned by the stream.
@immutable
class SummaryStreamMetadata extends SummaryStreamEvent {
  /// The status of the existing summary before regeneration.
  final SummaryStatus status;

  /// Whether the existing summary content has been translated.
  final bool translated;

  /// Creates a [SummaryStreamMetadata].
  const SummaryStreamMetadata({required this.status, required this.translated});

  /// Creates a [SummaryStreamMetadata] from JSON.
  factory SummaryStreamMetadata.fromJson(Map<String, dynamic> json) =>
      SummaryStreamMetadata(
        status: SummaryStatus.fromJson(json['status'] as String?),
        translated: json['translated'] as bool,
      );

  @override
  Map<String, dynamic> toJson() => {
    'status': status.toJson(),
    'translated': translated,
  };

  /// Creates a copy with the given fields replaced.
  SummaryStreamMetadata copyWith({SummaryStatus? status, bool? translated}) =>
      SummaryStreamMetadata(
        status: status ?? this.status,
        translated: translated ?? this.translated,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SummaryStreamMetadata &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          translated == other.translated;

  @override
  int get hashCode => Object.hash(status, translated);

  @override
  String toString() =>
      'SummaryStreamMetadata(status: $status, translated: $translated)';
}

/// A chunk of generated summary content.
@immutable
class SummaryStreamChunk extends SummaryStreamEvent {
  /// The chunk of content.
  final String content;

  /// Creates a [SummaryStreamChunk].
  const SummaryStreamChunk({required this.content});

  /// Creates a [SummaryStreamChunk] from JSON.
  factory SummaryStreamChunk.fromJson(Map<String, dynamic> json) =>
      SummaryStreamChunk(content: json['content'] as String);

  @override
  Map<String, dynamic> toJson() => {'content': content};

  /// Creates a copy with the given fields replaced.
  SummaryStreamChunk copyWith({String? content}) =>
      SummaryStreamChunk(content: content ?? this.content);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SummaryStreamChunk &&
          runtimeType == other.runtimeType &&
          content == other.content;

  @override
  int get hashCode => content.hashCode;

  @override
  String toString() => 'SummaryStreamChunk(content: $content)';
}

/// An error encountered while streaming a generated summary.
@immutable
class SummaryStreamError extends SummaryStreamEvent {
  /// The error message.
  final String error;

  /// Creates a [SummaryStreamError].
  const SummaryStreamError({required this.error});

  /// Creates a [SummaryStreamError] from JSON.
  factory SummaryStreamError.fromJson(Map<String, dynamic> json) =>
      SummaryStreamError(error: json['error'] as String);

  @override
  Map<String, dynamic> toJson() => {'error': error};

  /// Creates a copy with the given fields replaced.
  SummaryStreamError copyWith({String? error}) =>
      SummaryStreamError(error: error ?? this.error);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SummaryStreamError &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'SummaryStreamError(error: $error)';
}
