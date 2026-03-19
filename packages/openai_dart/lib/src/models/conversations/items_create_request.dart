import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import '../responses/items/item.dart';

/// Request to add items to a conversation.
///
/// ## Example
///
/// ```dart
/// final result = await client.conversations.items.create(
///   conversationId,
///   ItemsCreateRequest(
///     items: [
///       MessageItem.userText('Hello!'),
///       MessageItem.assistantText('Hi there, how can I help?'),
///     ],
///   ),
/// );
/// ```
@immutable
class ItemsCreateRequest {
  /// The items to add to the conversation.
  ///
  /// Up to 20 items can be provided per request.
  final List<Item> items;

  /// Creates an [ItemsCreateRequest].
  const ItemsCreateRequest({required this.items});

  /// Creates an [ItemsCreateRequest] from JSON.
  factory ItemsCreateRequest.fromJson(Map<String, dynamic> json) {
    return ItemsCreateRequest(
      items: (json['items'] as List)
          .map((e) => Item.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Converts this request to JSON.
  Map<String, dynamic> toJson() => {
    'items': items.map((e) => e.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemsCreateRequest &&
          runtimeType == other.runtimeType &&
          listsEqual(items, other.items);

  @override
  int get hashCode => Object.hashAll(items);

  @override
  String toString() => 'ItemsCreateRequest(items: ${items.length} items)';
}
