import 'content/content.dart';
import 'turn.dart';

/// The input for an interaction.
///
/// Can represent different input formats:
/// - [TextInput] — a simple text string
/// - [ContentListInput] — a list of [InteractionContent] items
/// - [SingleContentInput] — a single [InteractionContent] item
/// - [TurnsInput] — a list of [Turn]s for multi-turn conversations
sealed class InteractionInput {
  const InteractionInput();

  /// Creates a [TextInput] with the given [text].
  const factory InteractionInput.text(String text) = TextInput;

  /// Creates a [ContentListInput] with the given [content] list.
  const factory InteractionInput.contentList(List<InteractionContent> content) =
      ContentListInput;

  /// Creates a [SingleContentInput] with the given [content].
  const factory InteractionInput.singleContent(InteractionContent content) =
      SingleContentInput;

  /// Creates a [TurnsInput] with the given [turns].
  const factory InteractionInput.turns(List<Turn> turns) = TurnsInput;

  /// Creates an [InteractionInput] from a JSON value.
  ///
  /// - A [String] is parsed as [TextInput].
  /// - A [Map] with a `type` key is parsed as [SingleContentInput].
  /// - A [List] where the first element has a `type` key is parsed as
  ///   [ContentListInput] (since [InteractionContent] always requires `type`).
  /// - A [List] where elements lack a `type` key is parsed as [TurnsInput].
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
        return ContentListInput(
          json
              .map(
                (e) => InteractionContent.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
        );
      }
      return TurnsInput(
        json.map((e) => Turn.fromJson(e as Map<String, dynamic>)).toList(),
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

/// A list of [Turn]s for multi-turn conversation input.
class TurnsInput extends InteractionInput {
  /// The conversation turns.
  final List<Turn> turns;

  /// Creates a [TurnsInput].
  const TurnsInput(this.turns);

  @override
  Object toJson() => turns.map((t) => t.toJson()).toList();
}
