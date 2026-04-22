import '../content/content.dart';
import '../copy_with_sentinel.dart';
import 'embed_content_config.dart';
import 'task_type.dart';

/// Request to embed content.
///
/// Prefer [embedContentConfig] over the deprecated top-level [taskType],
/// [title], and [outputDimensionality] fields. If both are provided the server
/// treats [embedContentConfig] as authoritative, per the upstream deprecation
/// notes on the legacy fields.
class EmbedContentRequest {
  /// The content to embed. Only the `parts.text` fields will be counted.
  final Content content;

  /// Configuration for the `EmbedContent` request.
  final EmbedContentConfig? embedContentConfig;

  /// Optional task type hint.
  @Deprecated('Use EmbedContentConfig.taskType instead.')
  final TaskType? taskType;

  /// Optional title (only valid with taskType RETRIEVAL_DOCUMENT).
  @Deprecated('Use EmbedContentConfig.title instead.')
  final String? title;

  /// Optional reduced dimension for the output embedding.
  ///
  /// If set, excessive values in the output embedding are truncated from the end.
  /// Supported by newer models since 2024 only. You cannot set this value if
  /// using the earlier model (models/embedding-001).
  @Deprecated('Use EmbedContentConfig.outputDimensionality instead.')
  final int? outputDimensionality;

  /// Creates an [EmbedContentRequest].
  const EmbedContentRequest({
    required this.content,
    this.embedContentConfig,
    @Deprecated('Use EmbedContentConfig.taskType instead.') this.taskType,
    @Deprecated('Use EmbedContentConfig.title instead.') this.title,
    @Deprecated('Use EmbedContentConfig.outputDimensionality instead.')
    this.outputDimensionality,
  });

  /// Creates an [EmbedContentRequest] from JSON.
  factory EmbedContentRequest.fromJson(Map<String, dynamic> json) =>
      EmbedContentRequest(
        content: Content.fromJson(json['content'] as Map<String, dynamic>),
        embedContentConfig: json['embedContentConfig'] != null
            ? EmbedContentConfig.fromJson(
                json['embedContentConfig'] as Map<String, dynamic>,
              )
            : null,
        taskType: json['taskType'] != null
            ? taskTypeFromString(json['taskType'] as String?)
            : null,
        title: json['title'] as String?,
        outputDimensionality: json['outputDimensionality'] as int?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'content': content.toJson(),
    if (embedContentConfig != null)
      'embedContentConfig': embedContentConfig!.toJson(),
    if (taskType != null) 'taskType': taskTypeToString(taskType!),
    if (title != null) 'title': title,
    if (outputDimensionality != null)
      'outputDimensionality': outputDimensionality,
  };

  /// Creates a copy with replaced values.
  EmbedContentRequest copyWith({
    Object? content = unsetCopyWithValue,
    Object? embedContentConfig = unsetCopyWithValue,
    Object? taskType = unsetCopyWithValue,
    Object? title = unsetCopyWithValue,
    Object? outputDimensionality = unsetCopyWithValue,
  }) {
    return EmbedContentRequest(
      content: content == unsetCopyWithValue
          ? this.content
          : content! as Content,
      embedContentConfig: embedContentConfig == unsetCopyWithValue
          ? this.embedContentConfig
          : embedContentConfig as EmbedContentConfig?,
      taskType: taskType == unsetCopyWithValue
          ? this.taskType
          : taskType as TaskType?,
      title: title == unsetCopyWithValue ? this.title : title as String?,
      outputDimensionality: outputDimensionality == unsetCopyWithValue
          ? this.outputDimensionality
          : outputDimensionality as int?,
    );
  }
}
