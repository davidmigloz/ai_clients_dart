import 'package:meta/meta.dart';

/// Capabilities of a fine-tuned model.
@immutable
class FTModelCapabilitiesOut {
  /// Whether the model supports chat completions.
  final bool completionChat;

  /// Whether the model supports fill-in-the-middle completions.
  final bool completionFim;

  /// Whether the model supports function calling.
  final bool functionCalling;

  /// Whether the model can be further fine-tuned.
  final bool fineTuning;

  /// Whether the model supports classification.
  final bool classification;

  /// Creates [FTModelCapabilitiesOut].
  const FTModelCapabilitiesOut({
    this.completionChat = true,
    this.completionFim = false,
    this.functionCalling = false,
    this.fineTuning = false,
    this.classification = false,
  });

  /// Creates from JSON.
  factory FTModelCapabilitiesOut.fromJson(Map<String, dynamic> json) =>
      FTModelCapabilitiesOut(
        completionChat: json['completion_chat'] as bool? ?? true,
        completionFim: json['completion_fim'] as bool? ?? false,
        functionCalling: json['function_calling'] as bool? ?? false,
        fineTuning: json['fine_tuning'] as bool? ?? false,
        classification: json['classification'] as bool? ?? false,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'completion_chat': completionChat,
    'completion_fim': completionFim,
    'function_calling': functionCalling,
    'fine_tuning': fineTuning,
    'classification': classification,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FTModelCapabilitiesOut &&
          runtimeType == other.runtimeType &&
          completionChat == other.completionChat &&
          completionFim == other.completionFim &&
          functionCalling == other.functionCalling &&
          fineTuning == other.fineTuning &&
          classification == other.classification;

  @override
  int get hashCode => Object.hash(
    completionChat,
    completionFim,
    functionCalling,
    fineTuning,
    classification,
  );

  @override
  String toString() =>
      'FTModelCapabilitiesOut('
      'completionChat: $completionChat, completionFim: $completionFim, '
      'functionCalling: $functionCalling, fineTuning: $fineTuning, '
      'classification: $classification)';
}
