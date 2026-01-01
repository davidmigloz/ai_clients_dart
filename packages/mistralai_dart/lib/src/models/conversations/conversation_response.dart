import 'package:meta/meta.dart';

import '../../utils/equality_helpers.dart';
import '../metadata/usage_info.dart';
import 'conversation_entry.dart';

/// Response from starting or appending to a conversation.
@immutable
class ConversationResponse {
  /// The ID of the conversation.
  final String conversationId;

  /// The entries created by this operation.
  final List<ConversationEntry> outputs;

  /// Usage information for this request.
  final UsageInfo? usage;

  /// Creates a [ConversationResponse].
  const ConversationResponse({
    required this.conversationId,
    required this.outputs,
    this.usage,
  });

  /// Creates a [ConversationResponse] from JSON.
  factory ConversationResponse.fromJson(Map<String, dynamic> json) {
    return ConversationResponse(
      conversationId: json['conversation_id'] as String? ?? '',
      outputs:
          (json['outputs'] as List<dynamic>?)
              ?.map(
                (e) => ConversationEntry.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      usage: json['usage'] != null
          ? UsageInfo.fromJson(json['usage'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Converts this response to JSON.
  Map<String, dynamic> toJson() {
    return {
      'conversation_id': conversationId,
      'outputs': outputs.map((e) => e.toJson()).toList(),
      if (usage != null) 'usage': usage!.toJson(),
    };
  }

  /// The number of outputs in this response.
  int get outputCount => outputs.length;

  /// Whether this response has any outputs.
  bool get hasOutputs => outputs.isNotEmpty;

  /// Gets the first output entry, or null if empty.
  ConversationEntry? get firstOutput =>
      outputs.isNotEmpty ? outputs.first : null;

  /// Gets the last output entry, or null if empty.
  ConversationEntry? get lastOutput => outputs.isNotEmpty ? outputs.last : null;

  /// Gets the text content from the first message output entry.
  String? get text {
    for (final output in outputs) {
      if (output is MessageOutputEntry) {
        return output.content;
      }
    }
    return null;
  }

  /// Gets all message output entries.
  List<MessageOutputEntry> get messageOutputs =>
      outputs.whereType<MessageOutputEntry>().toList();

  /// Gets all function call entries.
  List<FunctionCallEntry> get functionCalls =>
      outputs.whereType<FunctionCallEntry>().toList();

  /// Gets all tool execution entries.
  List<ToolExecutionEntry> get toolExecutions =>
      outputs.whereType<ToolExecutionEntry>().toList();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationResponse &&
          runtimeType == other.runtimeType &&
          conversationId == other.conversationId;

  @override
  int get hashCode => conversationId.hashCode;

  @override
  String toString() =>
      'ConversationResponse(conversationId: $conversationId, outputs: $outputCount)';
}

/// Response from retrieving conversation entries.
@immutable
class ConversationEntriesResponse {
  /// The object type, always "list".
  final String object;

  /// The entries in the conversation.
  final List<ConversationEntry> data;

  /// Creates a [ConversationEntriesResponse].
  const ConversationEntriesResponse({this.object = 'list', required this.data});

  /// Creates a [ConversationEntriesResponse] from JSON.
  factory ConversationEntriesResponse.fromJson(Map<String, dynamic> json) {
    return ConversationEntriesResponse(
      object: json['object'] as String? ?? 'list',
      data:
          (json['data'] as List<dynamic>?)
              ?.map(
                (e) => ConversationEntry.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  /// Converts this response to JSON.
  Map<String, dynamic> toJson() {
    return {'object': object, 'data': data.map((e) => e.toJson()).toList()};
  }

  /// Whether the list is empty.
  bool get isEmpty => data.isEmpty;

  /// Whether the list is not empty.
  bool get isNotEmpty => data.isNotEmpty;

  /// The number of entries.
  int get length => data.length;

  /// Gets all message input entries (user messages).
  List<MessageInputEntry> get userMessages =>
      data.whereType<MessageInputEntry>().toList();

  /// Gets all message output entries (assistant messages).
  List<MessageOutputEntry> get assistantMessages =>
      data.whereType<MessageOutputEntry>().toList();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationEntriesResponse &&
          runtimeType == other.runtimeType &&
          object == other.object &&
          listEquals(data, other.data);

  @override
  int get hashCode => Object.hash(object, Object.hashAll(data));

  @override
  String toString() => 'ConversationEntriesResponse(entries: $length)';
}
