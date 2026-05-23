part of 'steps.dart';

/// A user-input step.
///
/// Represents input provided by the user, typically containing media-only
/// [InteractionContent] items (text, image, audio, document, video).
class UserInputStep extends InteractionStep {
  @override
  String get type => 'user_input';

  /// The content of the user input.
  final List<InteractionContent>? content;

  /// Creates a [UserInputStep] instance.
  const UserInputStep({this.content});

  /// Creates a [UserInputStep] from JSON.
  factory UserInputStep.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'user_input') {
      throw FormatException(
        'Expected type "user_input" but got "${json['type']}"',
      );
    }
    return UserInputStep(
      content: (json['content'] as List<dynamic>?)
          ?.map((e) => InteractionContent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (content != null) 'content': content!.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  UserInputStep copyWith({Object? content = unsetCopyWithValue}) {
    return UserInputStep(
      content: content == unsetCopyWithValue
          ? this.content
          : content as List<InteractionContent>?,
    );
  }
}
