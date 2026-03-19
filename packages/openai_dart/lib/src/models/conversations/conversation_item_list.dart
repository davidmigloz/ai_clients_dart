import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import 'conversation_item.dart';

/// A paginated list of conversation items.
///
/// This class is returned when listing items in a conversation.
///
/// ## Example
///
/// ```dart
/// final items = await client.conversations.items.list(
///   conversationId,
///   limit: 10,
/// );
///
/// print('Got ${items.data.length} items');
/// print('Has more: ${items.hasMore}');
///
/// if (items.hasMore) {
///   // Fetch next page
///   final moreItems = await client.conversations.items.list(
///     conversationId,
///     after: items.lastId,
///   );
/// }
/// ```
@immutable
class ConversationItemList {
  /// The list of items.
  final List<ConversationItem> data;

  /// The object type, always "list".
  final String object;

  /// Whether there are more items to fetch.
  final bool hasMore;

  /// The ID of the first item in the list.
  final String? firstId;

  /// The ID of the last item in the list.
  final String? lastId;

  /// Creates a [ConversationItemList].
  const ConversationItemList({
    required this.data,
    this.object = 'list',
    required this.hasMore,
    this.firstId,
    this.lastId,
  });

  /// Creates a [ConversationItemList] from JSON.
  factory ConversationItemList.fromJson(Map<String, dynamic> json) {
    return ConversationItemList(
      data: (json['data'] as List)
          .map((e) => ConversationItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      object: json['object'] as String? ?? 'list',
      hasMore: json['has_more'] as bool,
      firstId: json['first_id'] as String?,
      lastId: json['last_id'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'data': data.map((e) => e.toJson()).toList(),
    'object': object,
    'has_more': hasMore,
    if (firstId != null) 'first_id': firstId,
    if (lastId != null) 'last_id': lastId,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationItemList &&
          runtimeType == other.runtimeType &&
          listsEqual(data, other.data) &&
          object == other.object &&
          hasMore == other.hasMore &&
          firstId == other.firstId &&
          lastId == other.lastId;

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(data), object, hasMore, firstId, lastId);

  @override
  String toString() =>
      'ConversationItemList(data: ${data.length} items, hasMore: $hasMore)';
}
