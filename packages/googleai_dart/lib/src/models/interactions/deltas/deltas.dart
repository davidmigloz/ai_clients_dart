import '../../copy_with_sentinel.dart';
import '../content/content.dart';
import '../media_resolution.dart';
import '../thought_summary_content.dart';

part 'arguments_delta.dart';
part 'audio_delta.dart';
part 'document_delta.dart';
part 'image_delta.dart';
part 'text_annotation_delta.dart';
part 'text_delta.dart';
part 'thought_signature_delta.dart';
part 'thought_summary_delta.dart';
part 'unknown_step_delta.dart';
part 'video_delta.dart';

/// A delta update for an interaction step.
///
/// This is a sealed class with subtypes for the different kinds of partial
/// payloads that can stream as part of a `step.delta` event:
/// [TextDelta], [ImageDelta], [AudioDelta], [DocumentDelta], [VideoDelta],
/// [ThoughtSummaryDelta], [ThoughtSignatureDelta], [TextAnnotationDelta], and
/// [ArgumentsDelta], plus an [UnknownStepDelta] fallback for any `type` this
/// client does not yet model (e.g. the tool-call/result payloads the API also
/// streams as `step.delta` events).
sealed class StepDeltaData {
  /// The type discriminator for this delta.
  String get type;

  const StepDeltaData();

  /// Creates a [StepDeltaData] from JSON.
  ///
  /// Delta `type`s not in the published `StepDeltaData` schema (e.g. the
  /// tool-call/result payloads the API also streams as `step.delta` events)
  /// are surfaced as [UnknownStepDelta] rather than throwing, keeping streams
  /// resilient and forward-compatible.
  factory StepDeltaData.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'text' => TextDelta.fromJson(json),
      'image' => ImageDelta.fromJson(json),
      'audio' => AudioDelta.fromJson(json),
      'document' => DocumentDelta.fromJson(json),
      'video' => VideoDelta.fromJson(json),
      'thought_summary' => ThoughtSummaryDelta.fromJson(json),
      'thought_signature' => ThoughtSignatureDelta.fromJson(json),
      'text_annotation_delta' => TextAnnotationDelta.fromJson(json),
      'arguments_delta' => ArgumentsDelta.fromJson(json),
      _ => UnknownStepDelta.fromJson(json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}
