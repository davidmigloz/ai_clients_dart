import 'package:meta/meta.dart';

import '../../utils/equality_helpers.dart';
import 'conversation_entry.dart';

/// A conversation with an AI agent or model.
///
/// Conversations provide a more flexible and expressive way to interact with
/// AI models compared to the Chat Completion API. They allow for fine-grained
/// control over events and support complex multi-turn interactions.
@immutable
class Conversation {
  /// The unique identifier for this conversation.
  final String id;

  /// The object type, always "conversation".
  final String object;

  /// The model used for this conversation.
  final String? model;

  /// The agent ID if this conversation is with an agent.
  final String? agentId;

  /// When this conversation was created (Unix timestamp).
  final int? createdAt;

  /// When this conversation was last updated (Unix timestamp).
  final int? updatedAt;

  /// Optional metadata associated with the conversation.
  final Map<String, dynamic>? metadata;

  /// The entries in this conversation.
  final List<ConversationEntry>? entries;

  /// Creates a [Conversation].
  const Conversation({
    required this.id,
    this.object = 'conversation',
    this.model,
    this.agentId,
    this.createdAt,
    this.updatedAt,
    this.metadata,
    this.entries,
  });

  /// Creates a [Conversation] from JSON.
  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String? ?? '',
      object: json['object'] as String? ?? 'conversation',
      model: json['model'] as String?,
      agentId: json['agent_id'] as String?,
      createdAt: json['created_at'] as int?,
      updatedAt: json['updated_at'] as int?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      entries: (json['entries'] as List<dynamic>?)
          ?.map((e) => ConversationEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Converts this conversation to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'object': object,
      if (model != null) 'model': model,
      if (agentId != null) 'agent_id': agentId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (metadata != null) 'metadata': metadata,
      if (entries != null) 'entries': entries!.map((e) => e.toJson()).toList(),
    };
  }

  /// Creates a copy with the given fields replaced.
  Conversation copyWith({
    String? id,
    String? object,
    String? model,
    String? agentId,
    int? createdAt,
    int? updatedAt,
    Map<String, dynamic>? metadata,
    List<ConversationEntry>? entries,
  }) {
    return Conversation(
      id: id ?? this.id,
      object: object ?? this.object,
      model: model ?? this.model,
      agentId: agentId ?? this.agentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
      entries: entries ?? this.entries,
    );
  }

  /// The number of entries in this conversation.
  int get entryCount => entries?.length ?? 0;

  /// Whether this conversation has any entries.
  bool get hasEntries => entries != null && entries!.isNotEmpty;

  /// Whether this conversation uses an agent (vs a model).
  bool get isAgentConversation => agentId != null;

  /// Whether this conversation uses a model (vs an agent).
  bool get isModelConversation => model != null && agentId == null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Conversation &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Conversation(id: $id, entries: $entryCount)';
}

/// A list of conversations returned from the API.
@immutable
class ConversationList {
  /// The object type, always "list".
  final String object;

  /// The list of conversations.
  final List<Conversation> data;

  /// The total number of conversations available.
  final int? total;

  /// Whether there are more conversations to fetch.
  final bool? hasMore;

  /// Creates a [ConversationList].
  const ConversationList({
    this.object = 'list',
    required this.data,
    this.total,
    this.hasMore,
  });

  /// Creates a [ConversationList] from JSON.
  factory ConversationList.fromJson(Map<String, dynamic> json) {
    return ConversationList(
      object: json['object'] as String? ?? 'list',
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => Conversation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: json['total'] as int?,
      hasMore: json['has_more'] as bool?,
    );
  }

  /// Converts this list to JSON.
  Map<String, dynamic> toJson() {
    return {
      'object': object,
      'data': data.map((e) => e.toJson()).toList(),
      if (total != null) 'total': total,
      if (hasMore != null) 'has_more': hasMore,
    };
  }

  /// Whether the list is empty.
  bool get isEmpty => data.isEmpty;

  /// Whether the list is not empty.
  bool get isNotEmpty => data.isNotEmpty;

  /// The number of conversations in this page.
  int get length => data.length;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationList &&
          runtimeType == other.runtimeType &&
          object == other.object &&
          listEquals(data, other.data) &&
          total == other.total &&
          hasMore == other.hasMore;

  @override
  int get hashCode => Object.hash(object, Object.hashAll(data), total, hasMore);

  @override
  String toString() => 'ConversationList(count: $length, total: $total)';
}
