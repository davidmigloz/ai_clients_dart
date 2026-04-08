import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// Preview of a chat completion event.
@immutable
class ChatCompletionEventPreview {
  /// Unique event identifier.
  final String eventId;

  /// Correlation identifier.
  final String correlationId;

  /// When the event was created.
  final DateTime createdAt;

  /// Extra fields (free-form key-value pairs).
  final Map<String, dynamic> extraFields;

  /// Number of input tokens.
  final int nbInputTokens;

  /// Number of output tokens.
  final int nbOutputTokens;

  /// Creates a [ChatCompletionEventPreview].
  ChatCompletionEventPreview({
    required this.eventId,
    required this.correlationId,
    required this.createdAt,
    required Map<String, dynamic> extraFields,
    required this.nbInputTokens,
    required this.nbOutputTokens,
  }) : extraFields = Map.unmodifiable(extraFields);

  /// Creates a [ChatCompletionEventPreview] from JSON.
  factory ChatCompletionEventPreview.fromJson(Map<String, dynamic> json) =>
      ChatCompletionEventPreview(
        eventId: json['event_id'] as String? ?? '',
        correlationId: json['correlation_id'] as String? ?? '',
        createdAt:
            DateTime.tryParse(json['created_at'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        extraFields: Map<String, dynamic>.from(
          json['extra_fields'] as Map? ?? {},
        ),
        nbInputTokens: json['nb_input_tokens'] as int? ?? 0,
        nbOutputTokens: json['nb_output_tokens'] as int? ?? 0,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'event_id': eventId,
    'correlation_id': correlationId,
    'created_at': createdAt.toIso8601String(),
    'extra_fields': Map<String, dynamic>.from(extraFields),
    'nb_input_tokens': nbInputTokens,
    'nb_output_tokens': nbOutputTokens,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatCompletionEventPreview) return false;
    if (runtimeType != other.runtimeType) return false;
    return eventId == other.eventId &&
        correlationId == other.correlationId &&
        createdAt == other.createdAt &&
        mapsDeepEqual(extraFields, other.extraFields) &&
        nbInputTokens == other.nbInputTokens &&
        nbOutputTokens == other.nbOutputTokens;
  }

  @override
  int get hashCode => Object.hash(
    eventId,
    correlationId,
    createdAt,
    mapDeepHashCode(extraFields),
    nbInputTokens,
    nbOutputTokens,
  );

  @override
  String toString() =>
      'ChatCompletionEventPreview(eventId: $eventId, '
      'nbInputTokens: $nbInputTokens, nbOutputTokens: $nbOutputTokens)';
}
