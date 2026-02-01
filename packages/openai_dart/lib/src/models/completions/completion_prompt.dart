import 'package:meta/meta.dart';

/// A prompt for completions.
///
/// Can be a string, list of strings, list of token IDs, or list of lists
/// of token IDs.
///
/// ## Example
///
/// ```dart
/// // Simple text prompt
/// final prompt = CompletionPrompt.text('Once upon a time');
///
/// // Multiple prompts
/// final prompt = CompletionPrompt.texts(['Hello', 'World']);
///
/// // Token IDs
/// final prompt = CompletionPrompt.tokens([1234, 5678]);
/// ```
sealed class CompletionPrompt {
  const CompletionPrompt();

  /// Creates a single text prompt.
  const factory CompletionPrompt.text(String text) = CompletionPromptText;

  /// Creates multiple text prompts.
  const factory CompletionPrompt.texts(List<String> texts) =
      CompletionPromptTexts;

  /// Creates a token ID prompt.
  const factory CompletionPrompt.tokens(List<int> tokens) =
      CompletionPromptTokens;

  /// Creates a list of token ID lists.
  const factory CompletionPrompt.tokenLists(List<List<int>> tokenLists) =
      CompletionPromptTokenLists;

  /// Creates from JSON.
  factory CompletionPrompt.fromJson(Object json) {
    if (json is String) {
      return CompletionPromptText(json);
    }
    if (json is List) {
      if (json.isEmpty) {
        return const CompletionPromptTexts([]);
      }
      // Check the first element to determine type
      final first = json.first;
      if (first is String) {
        return CompletionPromptTexts(json.cast<String>());
      }
      if (first is int) {
        return CompletionPromptTokens(json.cast<int>());
      }
      if (first is List) {
        return CompletionPromptTokenLists(
          json.map((e) => (e as List).cast<int>()).toList(),
        );
      }
    }
    throw FormatException('Invalid CompletionPrompt: $json');
  }

  /// Converts to JSON.
  Object toJson();
}

/// A single text prompt.
@immutable
class CompletionPromptText extends CompletionPrompt {
  /// Creates a [CompletionPromptText].
  const CompletionPromptText(this.text);

  /// The text prompt.
  final String text;

  @override
  Object toJson() => text;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompletionPromptText &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'CompletionPrompt.text($text)';
}

/// Multiple text prompts.
@immutable
class CompletionPromptTexts extends CompletionPrompt {
  /// Creates a [CompletionPromptTexts].
  const CompletionPromptTexts(this.texts);

  /// The list of text prompts.
  final List<String> texts;

  @override
  Object toJson() => texts;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompletionPromptTexts &&
          runtimeType == other.runtimeType &&
          _listEquals(texts, other.texts);

  @override
  int get hashCode => Object.hashAll(texts);

  @override
  String toString() => 'CompletionPrompt.texts($texts)';

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// A prompt as token IDs.
@immutable
class CompletionPromptTokens extends CompletionPrompt {
  /// Creates a [CompletionPromptTokens].
  const CompletionPromptTokens(this.tokens);

  /// The list of token IDs.
  final List<int> tokens;

  @override
  Object toJson() => tokens;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompletionPromptTokens &&
          runtimeType == other.runtimeType &&
          _listEquals(tokens, other.tokens);

  @override
  int get hashCode => Object.hashAll(tokens);

  @override
  String toString() => 'CompletionPrompt.tokens(${tokens.length} tokens)';

  bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Multiple prompts as lists of token IDs.
@immutable
class CompletionPromptTokenLists extends CompletionPrompt {
  /// Creates a [CompletionPromptTokenLists].
  const CompletionPromptTokenLists(this.tokenLists);

  /// The list of token ID lists.
  final List<List<int>> tokenLists;

  @override
  Object toJson() => tokenLists;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompletionPromptTokenLists &&
          runtimeType == other.runtimeType &&
          tokenLists.length == other.tokenLists.length;

  @override
  int get hashCode => tokenLists.length.hashCode;

  @override
  String toString() =>
      'CompletionPrompt.tokenLists(${tokenLists.length} lists)';
}
