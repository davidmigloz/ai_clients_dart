part of 'steps.dart';

/// A thought step.
///
/// Captures the model's reasoning summary plus a backend-validation signature.
class ThoughtStep extends InteractionStep {
  @override
  String get type => 'thought';

  /// A summary of the thought.
  final List<ThoughtSummaryContent>? summary;

  /// Signature hash for backend validation.
  final String? signature;

  /// Creates a [ThoughtStep] instance.
  const ThoughtStep({this.summary, this.signature});

  /// Creates a [ThoughtStep] from JSON.
  factory ThoughtStep.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'thought') {
      throw FormatException(
        'Expected type "thought" but got "${json['type']}"',
      );
    }
    return ThoughtStep(
      summary: (json['summary'] as List<dynamic>?)
          ?.map(
            (e) => ThoughtSummaryContent.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      signature: json['signature'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (summary != null) 'summary': summary!.map((e) => e.toJson()).toList(),
    if (signature != null) 'signature': signature,
  };

  /// Creates a copy with replaced values.
  ThoughtStep copyWith({
    Object? summary = unsetCopyWithValue,
    Object? signature = unsetCopyWithValue,
  }) {
    return ThoughtStep(
      summary: summary == unsetCopyWithValue
          ? this.summary
          : summary as List<ThoughtSummaryContent>?,
      signature: signature == unsetCopyWithValue
          ? this.signature
          : signature as String?,
    );
  }
}
