import '../../copy_with_sentinel.dart';
import '../interaction_review_snippet.dart';
import '../media_resolution.dart';

part 'annotation.dart';
part 'audio_content.dart';
part 'document_content.dart';
part 'image_content.dart';
part 'text_content.dart';
part 'video_content.dart';

/// The media content of an interaction step.
///
/// This is a sealed class with 5 subtypes: [TextContent], [ImageContent],
/// [AudioContent], [DocumentContent], [VideoContent].
///
/// In the new step-based interactions API, [InteractionContent] only carries
/// media payloads — tool calls and results live as standalone
/// `InteractionStep` variants.
sealed class InteractionContent {
  /// The type discriminator for this content.
  String get type;

  const InteractionContent();

  /// Creates an [InteractionContent] from JSON.
  factory InteractionContent.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'text' => TextContent.fromJson(json),
      'image' => ImageContent.fromJson(json),
      'audio' => AudioContent.fromJson(json),
      'document' => DocumentContent.fromJson(json),
      'video' => VideoContent.fromJson(json),
      _ => throw ArgumentError('Unknown content type: $type'),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}
