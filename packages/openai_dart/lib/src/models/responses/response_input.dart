import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import 'items/item.dart';

/// Input for a response request.
///
/// Response input can be either:
/// - [ResponseInputText]: Simple text input
/// - [ResponseInputItems]: A list of [Item] objects for multi-turn conversations
///
/// ## Example
///
/// ```dart
/// // Simple text
/// final text = ResponseInput.text('Hello!');
///
/// // Multi-turn conversation with items
/// final items = ResponseInput.items([
///   MessageItem.userText('What is 2+2?'),
///   MessageItem.assistantText('4'),
///   MessageItem.userText('What is 3+3?'),
/// ]);
/// ```
@immutable
sealed class ResponseInput {
  const ResponseInput();

  /// Creates [ResponseInput] from JSON.
  ///
  /// Accepts either a [String] for text input or a [List] for item input.
  factory ResponseInput.fromJson(Object json) {
    if (json is String) {
      return ResponseInputText(json);
    }
    if (json is List) {
      return ResponseInputItems(
        json.map((e) {
          if (e is! Map<String, dynamic>) {
            throw FormatException('Invalid response input list element: $e');
          }
          return Item.fromJson(e);
        }).toList(),
      );
    }
    throw FormatException('Invalid response input: $json');
  }

  /// Creates text input.
  const factory ResponseInput.text(String text) = ResponseInputText;

  /// Creates item input for multi-turn conversations.
  const factory ResponseInput.items(List<Item> items) = ResponseInputItems;

  /// Creates input from raw output item JSON maps.
  ///
  /// This is used by [ResponseCompaction.toInput] to convert compact output
  /// items directly to API input without needing typed [Item] wrappers, since
  /// compact output types (e.g. messages with `input_text` content) are valid
  /// API input at the JSON level.
  const factory ResponseInput.fromOutputItems(
    List<Map<String, dynamic>> items,
  ) = ResponseInputRawJson;

  /// Converts to JSON format expected by the API.
  Object toJson();
}

/// Simple text input for a response request.
@immutable
class ResponseInputText extends ResponseInput {
  /// Creates text input.
  const ResponseInputText(this.text);

  /// The text input.
  final String text;

  @override
  Object toJson() => text;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseInputText &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'ResponseInputText($text)';
}

/// A list of items input for multi-turn conversations.
@immutable
class ResponseInputItems extends ResponseInput {
  /// Creates item input.
  const ResponseInputItems(this.items);

  /// The input items.
  final List<Item> items;

  @override
  Object toJson() => items.map((e) => e.toJson()).toList();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseInputItems &&
          runtimeType == other.runtimeType &&
          listsEqual(items, other.items);

  @override
  int get hashCode => Object.hashAll(items);

  @override
  String toString() => 'ResponseInputItems(${items.length} items)';
}

/// Raw JSON input from output items (e.g. compact output).
///
/// This passes through a list of JSON maps directly as API input, avoiding
/// the need for typed [Item] wrappers. Compact output item JSON is valid
/// API input, so this enables `ResponseCompaction.toInput()` without
/// introducing new `Item` subtypes.
@immutable
class ResponseInputRawJson extends ResponseInput {
  /// Creates raw JSON input from a list of JSON maps.
  const ResponseInputRawJson(this.items);

  /// The raw JSON maps representing output items.
  final List<Map<String, dynamic>> items;

  @override
  Object toJson() => items;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseInputRawJson &&
          runtimeType == other.runtimeType &&
          _mapsListEqual(items, other.items);

  static bool _mapsListEqual(
    List<Map<String, dynamic>> a,
    List<Map<String, dynamic>> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!mapsEqual(a[i], b[i])) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(items.map(mapHash));

  @override
  String toString() => 'ResponseInputRawJson(${items.length} items)';
}
