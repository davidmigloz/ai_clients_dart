import 'content/content.dart';
import 'steps/steps.dart';

/// Set of `type` discriminator values that identify a media-only
/// [InteractionContent] item (the trimmed `Content` family in the spec).
const _contentTypes = <String>{'text', 'image', 'audio', 'document', 'video'};

/// The input for an interaction.
///
/// Matches the spec's `InteractionsInput` union and can represent:
/// - [TextInput] — a simple text string
/// - [StepListInput] — a list of [InteractionStep]s (e.g. for passing
///   function results back via a [FunctionResultStep], or to provide
///   conversation history inline)
/// - [ContentListInput] — a list of media-only [InteractionContent] items
/// - [SingleContentInput] — a single [InteractionContent] item
sealed class InteractionInput {
  const InteractionInput();

  /// Creates a [TextInput] with the given [text].
  const factory InteractionInput.text(String text) = TextInput;

  /// Creates a [StepListInput] with the given [steps].
  const factory InteractionInput.steps(List<InteractionStep> steps) =
      StepListInput;

  /// Creates a [ContentListInput] with the given [content] list.
  const factory InteractionInput.contentList(List<InteractionContent> content) =
      ContentListInput;

  /// Creates a [SingleContentInput] with the given [content].
  const factory InteractionInput.singleContent(InteractionContent content) =
      SingleContentInput;

  /// Creates an [InteractionInput] from a JSON value.
  ///
  /// - A [String] is parsed as [TextInput].
  /// - A [Map] with a `type` key is parsed as [SingleContentInput].
  /// - A [List] where the first element's `type` is a media type
  ///   (`text`/`image`/`audio`/`document`/`video`) is parsed as
  ///   [ContentListInput].
  /// - A [List] where the first element has a `type` matching a step
  ///   discriminator is parsed as [StepListInput].
  factory InteractionInput.fromJson(Object json) {
    if (json is String) {
      return TextInput(json);
    }
    if (json is Map<String, dynamic>) {
      if (!json.containsKey('type')) {
        throw ArgumentError(
          'InteractionInput Map must contain a "type" key, '
          'got keys: ${json.keys.toList()}',
        );
      }
      return SingleContentInput(InteractionContent.fromJson(json));
    }
    if (json is List) {
      if (json.isEmpty) {
        return const ContentListInput([]);
      }
      final first = json.first;
      if (first is Map<String, dynamic> && first.containsKey('type')) {
        final type = first['type'] as String?;
        if (type != null && _contentTypes.contains(type)) {
          return ContentListInput(
            json
                .map(
                  (e) => InteractionContent.fromJson(e as Map<String, dynamic>),
                )
                .toList(),
          );
        }
        return StepListInput(
          json
              .map((e) => InteractionStep.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
      }
      throw ArgumentError(
        'Unknown InteractionInput list element: expected a Content or Step '
        'map with a "type" key, got: $first',
      );
    }
    throw ArgumentError('Unknown InteractionInput format: ${json.runtimeType}');
  }

  /// Converts this input to its JSON representation.
  Object toJson();
}

/// A simple text input.
class TextInput extends InteractionInput {
  /// The text value.
  final String text;

  /// Creates a [TextInput].
  const TextInput(this.text);

  @override
  Object toJson() => text;
}

/// A list of [InteractionStep] items as input.
///
/// Use this for passing function/tool result steps back to continue an
/// interaction that was paused with `InteractionStatus.requiresAction`.
class StepListInput extends InteractionInput {
  /// The step items.
  final List<InteractionStep> steps;

  /// Creates a [StepListInput].
  const StepListInput(this.steps);

  @override
  Object toJson() => steps.map((s) => s.toJson()).toList();
}

/// A list of [InteractionContent] items as input.
class ContentListInput extends InteractionInput {
  /// The content items.
  final List<InteractionContent> content;

  /// Creates a [ContentListInput].
  const ContentListInput(this.content);

  @override
  Object toJson() => content.map((c) => c.toJson()).toList();
}

/// A single [InteractionContent] item as input.
class SingleContentInput extends InteractionInput {
  /// The content item.
  final InteractionContent content;

  /// Creates a [SingleContentInput].
  const SingleContentInput(this.content);

  @override
  Object toJson() => content.toJson();
}
