import 'package:meta/meta.dart';

/// A thread item in a ChatKit thread.
///
/// Thread items represent messages, tool calls, and other content
/// within a conversation thread.
///
/// ## Example
///
/// ```dart
/// final items = await client.chatkit.threads.items.list('thread-abc123');
/// for (final item in items.data) {
///   print('${item.type}: ${item.id}');
/// }
/// ```
@immutable
class ThreadItem {
  /// Creates a [ThreadItem].
  const ThreadItem({required this.id, required this.type, required this.json});

  /// Creates a [ThreadItem] from JSON.
  factory ThreadItem.fromJson(Map<String, dynamic> json) {
    return ThreadItem(
      id: json['id'] as String,
      type: json['type'] as String,
      json: json,
    );
  }

  /// The item identifier.
  final String id;

  /// The type of item (user_message, assistant_message, widget_message,
  /// client_tool_call, task, task_group).
  final String type;

  /// The raw JSON data for the item.
  final Map<String, dynamic> json;

  /// Whether this is a user message.
  bool get isUserMessage => type == 'user_message';

  /// Whether this is an assistant message.
  bool get isAssistantMessage => type == 'assistant_message';

  /// Whether this is a widget message.
  bool get isWidgetMessage => type == 'widget_message';

  /// Whether this is a client tool call.
  bool get isClientToolCall => type == 'client_tool_call';

  /// Whether this is a task.
  bool get isTask => type == 'task';

  /// Whether this is a task group.
  bool get isTaskGroup => type == 'task_group';

  /// Converts to JSON.
  Map<String, dynamic> toJson() => json;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThreadItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ThreadItem(id: $id, type: $type)';
}

/// A list of thread items.
@immutable
class ThreadItemList {
  /// Creates a [ThreadItemList].
  const ThreadItemList({
    required this.object,
    required this.data,
    this.firstId,
    this.lastId,
    required this.hasMore,
  });

  /// Creates a [ThreadItemList] from JSON.
  factory ThreadItemList.fromJson(Map<String, dynamic> json) {
    return ThreadItemList(
      object: json['object'] as String? ?? 'list',
      data: (json['data'] as List<dynamic>)
          .map((e) => ThreadItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      firstId: json['first_id'] as String?,
      lastId: json['last_id'] as String?,
      hasMore: json['has_more'] as bool,
    );
  }

  /// The object type, which is always `list`.
  final String object;

  /// The list of thread items.
  final List<ThreadItem> data;

  /// The ID of the first item in the list.
  final String? firstId;

  /// The ID of the last item in the list.
  final String? lastId;

  /// Whether there are more items available.
  final bool hasMore;

  /// Whether the list is empty.
  bool get isEmpty => data.isEmpty;

  /// Whether the list is not empty.
  bool get isNotEmpty => data.isNotEmpty;

  /// The number of items.
  int get length => data.length;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'object': object,
    'data': data.map((i) => i.toJson()).toList(),
    'first_id': firstId,
    'last_id': lastId,
    'has_more': hasMore,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThreadItemList &&
          runtimeType == other.runtimeType &&
          object == other.object &&
          data.length == other.data.length;

  @override
  int get hashCode => Object.hash(object, data.length);

  @override
  String toString() => 'ThreadItemList(${data.length} items)';
}
