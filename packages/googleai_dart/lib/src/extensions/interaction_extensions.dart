import '../models/interactions/content/content.dart';
import '../models/interactions/interaction.dart';
import '../models/interactions/steps/steps.dart';

/// Convenience extensions for [Interaction].
extension InteractionExtensions on Interaction {
  /// Concatenated text from all `model_output` text content across all steps.
  ///
  /// Returns `null` if no text outputs exist.
  ///
  /// Example:
  /// ```dart
  /// final interaction = await client.interactions.create(...);
  /// print(interaction.text); // Prints the generated text
  /// ```
  String? get text {
    final buffer = StringBuffer();
    var hasText = false;
    for (final step in steps ?? <InteractionStep>[]) {
      if (step is! ModelOutputStep) continue;
      for (final content in step.content ?? const <InteractionContent>[]) {
        if (content is TextContent && content.text.isNotEmpty) {
          buffer.write(content.text);
          hasText = true;
        }
      }
    }
    return hasText ? buffer.toString() : null;
  }

  /// All [ModelOutputStep] entries.
  List<ModelOutputStep> get modelOutputSteps =>
      steps?.whereType<ModelOutputStep>().toList() ?? const [];

  /// All text content blocks emitted across [ModelOutputStep] entries.
  List<TextContent> get textOutputs => [
    for (final step in modelOutputSteps)
      ...?step.content?.whereType<TextContent>(),
  ];

  /// All function call steps.
  List<FunctionCallStep> get functionCallSteps =>
      steps?.whereType<FunctionCallStep>().toList() ?? const [];

  /// All thought steps (for reasoning models).
  List<ThoughtStep> get thoughtSteps =>
      steps?.whereType<ThoughtStep>().toList() ?? const [];

  /// All image content blocks emitted across [ModelOutputStep] entries.
  List<ImageContent> get imageOutputs => [
    for (final step in modelOutputSteps)
      ...?step.content?.whereType<ImageContent>(),
  ];

  /// All audio content blocks emitted across [ModelOutputStep] entries.
  List<AudioContent> get audioOutputs => [
    for (final step in modelOutputSteps)
      ...?step.content?.whereType<AudioContent>(),
  ];

  /// True if the interaction has any text output.
  bool get hasTextOutput => textOutputs.isNotEmpty;

  /// True if the interaction has any function call steps.
  bool get hasFunctionCalls => functionCallSteps.isNotEmpty;

  /// All Google Maps call steps.
  List<GoogleMapsCallStep> get googleMapsCallSteps =>
      steps?.whereType<GoogleMapsCallStep>().toList() ?? const [];

  /// All Google Maps result steps.
  List<GoogleMapsResultStep> get googleMapsResultSteps =>
      steps?.whereType<GoogleMapsResultStep>().toList() ?? const [];
}
