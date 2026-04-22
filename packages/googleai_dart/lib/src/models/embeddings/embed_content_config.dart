import '../copy_with_sentinel.dart';
import 'task_type.dart';

/// Configuration for the `EmbedContent` request.
class EmbedContentConfig {
  /// The task type of the embedding.
  final TaskType? taskType;

  /// The title for the text.
  final String? title;

  /// Reduced dimension for the output embedding.
  ///
  /// If set, excessive values in the output embedding are truncated from the
  /// end.
  final int? outputDimensionality;

  /// Whether to silently truncate the input content if it's longer than the
  /// maximum sequence length.
  final bool? autoTruncate;

  /// Whether to enable OCR for document content.
  final bool? documentOcr;

  /// Whether to extract audio from video content.
  final bool? audioTrackExtraction;

  /// Creates an [EmbedContentConfig].
  const EmbedContentConfig({
    this.taskType,
    this.title,
    this.outputDimensionality,
    this.autoTruncate,
    this.documentOcr,
    this.audioTrackExtraction,
  });

  /// Creates an [EmbedContentConfig] from JSON.
  factory EmbedContentConfig.fromJson(Map<String, dynamic> json) =>
      EmbedContentConfig(
        taskType: json['taskType'] != null
            ? taskTypeFromString(json['taskType'] as String?)
            : null,
        title: json['title'] as String?,
        outputDimensionality: json['outputDimensionality'] as int?,
        autoTruncate: json['autoTruncate'] as bool?,
        documentOcr: json['documentOcr'] as bool?,
        audioTrackExtraction: json['audioTrackExtraction'] as bool?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (taskType != null) 'taskType': taskTypeToString(taskType!),
    if (title != null) 'title': title,
    if (outputDimensionality != null)
      'outputDimensionality': outputDimensionality,
    if (autoTruncate != null) 'autoTruncate': autoTruncate,
    if (documentOcr != null) 'documentOcr': documentOcr,
    if (audioTrackExtraction != null)
      'audioTrackExtraction': audioTrackExtraction,
  };

  /// Creates a copy with replaced values.
  EmbedContentConfig copyWith({
    Object? taskType = unsetCopyWithValue,
    Object? title = unsetCopyWithValue,
    Object? outputDimensionality = unsetCopyWithValue,
    Object? autoTruncate = unsetCopyWithValue,
    Object? documentOcr = unsetCopyWithValue,
    Object? audioTrackExtraction = unsetCopyWithValue,
  }) {
    return EmbedContentConfig(
      taskType: taskType == unsetCopyWithValue
          ? this.taskType
          : taskType as TaskType?,
      title: title == unsetCopyWithValue ? this.title : title as String?,
      outputDimensionality: outputDimensionality == unsetCopyWithValue
          ? this.outputDimensionality
          : outputDimensionality as int?,
      autoTruncate: autoTruncate == unsetCopyWithValue
          ? this.autoTruncate
          : autoTruncate as bool?,
      documentOcr: documentOcr == unsetCopyWithValue
          ? this.documentOcr
          : documentOcr as bool?,
      audioTrackExtraction: audioTrackExtraction == unsetCopyWithValue
          ? this.audioTrackExtraction
          : audioTrackExtraction as bool?,
    );
  }
}
