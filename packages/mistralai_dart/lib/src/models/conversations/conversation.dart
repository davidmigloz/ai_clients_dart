import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../metadata/completion_args.dart';
import '../moderations/guardrail_config.dart';
import '../tools/tool.dart';
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
  int? get createdAt =>
      _createdAt is int ? _createdAt : _seconds(createdAtDateTime);

  /// When this conversation was created, with precise time.
  DateTime? get createdAtDateTime => _conversationTime(_createdAt);

  final Object? _createdAt;

  /// When this conversation was last updated (Unix timestamp).
  int? get updatedAt =>
      _updatedAt is int ? _updatedAt : _seconds(updatedAtDateTime);

  /// When this conversation was last updated, with precise time.
  DateTime? get updatedAtDateTime => _conversationTime(_updatedAt);

  final Object? _updatedAt;

  /// Optional metadata associated with the conversation.
  final Map<String, dynamic>? metadata;

  /// The entries in this conversation.
  final List<ConversationEntry>? entries;

  /// Agent version number or alias.
  final Object? agentVersion;

  /// Display name of the conversation.
  final String? name;

  /// Description of the conversation.
  final String? description;

  /// System instructions for a model conversation.
  final String? instructions;

  /// Tools available to the model.
  final List<Tool>? tools;

  /// Generation defaults for a model conversation.
  final CompletionArgs? completionArgs;

  /// Guardrail configuration for a model conversation.
  final List<GuardrailConfig>? guardrails;

  /// Creates a [Conversation].
  const Conversation({
    required this.id,
    this.object = 'conversation',
    this.model,
    this.agentId,
    int? createdAt,
    DateTime? createdAtDateTime,
    int? updatedAt,
    DateTime? updatedAtDateTime,
    this.metadata,
    this.entries,
    this.agentVersion,
    this.name,
    this.description,
    this.instructions,
    this.tools,
    this.completionArgs,
    this.guardrails,
  }) : _createdAt = createdAtDateTime ?? createdAt,
       _updatedAt = updatedAtDateTime ?? updatedAt;

  /// Creates a [Conversation] from JSON.
  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String? ?? '',
      object: json['object'] as String? ?? 'conversation',
      model: json['model'] as String?,
      agentId: json['agent_id'] as String?,
      createdAt: _legacySeconds(json['created_at']),
      createdAtDateTime: _parseIsoTime(json['created_at']),
      updatedAt: _legacySeconds(json['updated_at']),
      updatedAtDateTime: _parseIsoTime(json['updated_at']),
      metadata: json['metadata'] as Map<String, dynamic>?,
      entries: (json['entries'] as List<dynamic>?)
          ?.map((e) => ConversationEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      agentVersion: json['agent_version'] as Object?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      instructions: json['instructions'] as String?,
      tools: (json['tools'] as List?)
          ?.cast<Map<String, dynamic>>()
          .map(Tool.fromJson)
          .toList(),
      completionArgs: json['completion_args'] == null
          ? null
          : CompletionArgs.fromJson(
              json['completion_args'] as Map<String, dynamic>,
            ),
      guardrails: (json['guardrails'] as List?)
          ?.cast<Map<String, dynamic>>()
          .map(GuardrailConfig.fromJson)
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
      'created_at': ?_wireTime(_createdAt),
      'updated_at': ?_wireTime(_updatedAt),
      if (metadata != null) 'metadata': metadata,
      if (entries != null) 'entries': entries!.map((e) => e.toJson()).toList(),
      'agent_version': ?agentVersion,
      'name': ?name,
      'description': ?description,
      'instructions': ?instructions,
      'tools': ?tools?.map((entry) => entry.toJson()).toList(),
      'completion_args': ?completionArgs?.toJson(),
      'guardrails': ?guardrails?.map((entry) => entry.toJson()).toList(),
    };
  }

  /// Creates a copy with the given fields replaced.
  Conversation copyWith({
    String? id,
    String? object,
    String? model,
    String? agentId,
    int? createdAt,
    Object? createdAtDateTime = unsetCopyWithValue,
    int? updatedAt,
    Object? updatedAtDateTime = unsetCopyWithValue,
    Map<String, dynamic>? metadata,
    List<ConversationEntry>? entries,
    Object? agentVersion = unsetCopyWithValue,
    Object? name = unsetCopyWithValue,
    Object? description = unsetCopyWithValue,
    Object? instructions = unsetCopyWithValue,
    Object? tools = unsetCopyWithValue,
    Object? completionArgs = unsetCopyWithValue,
    Object? guardrails = unsetCopyWithValue,
  }) {
    return Conversation(
      id: id ?? this.id,
      object: object ?? this.object,
      model: model ?? this.model,
      agentId: agentId ?? this.agentId,
      createdAt:
          createdAt ??
          (createdAtDateTime == unsetCopyWithValue
              ? _legacySeconds(_createdAt)
              : null),
      createdAtDateTime: createdAtDateTime != unsetCopyWithValue
          ? createdAtDateTime as DateTime?
          : (createdAt == null && _createdAt is DateTime
                ? this.createdAtDateTime
                : null),
      updatedAt:
          updatedAt ??
          (updatedAtDateTime == unsetCopyWithValue
              ? _legacySeconds(_updatedAt)
              : null),
      updatedAtDateTime: updatedAtDateTime != unsetCopyWithValue
          ? updatedAtDateTime as DateTime?
          : (updatedAt == null && _updatedAt is DateTime
                ? this.updatedAtDateTime
                : null),
      metadata: metadata ?? this.metadata,
      entries: entries ?? this.entries,
      agentVersion: agentVersion == unsetCopyWithValue
          ? this.agentVersion
          : agentVersion,
      name: name == unsetCopyWithValue ? this.name : name as String?,
      description: description == unsetCopyWithValue
          ? this.description
          : description as String?,
      instructions: instructions == unsetCopyWithValue
          ? this.instructions
          : instructions as String?,
      tools: tools == unsetCopyWithValue
          ? this.tools
          : (tools as List?)?.cast<Tool>(),
      completionArgs: completionArgs == unsetCopyWithValue
          ? this.completionArgs
          : completionArgs as CompletionArgs?,
      guardrails: guardrails == unsetCopyWithValue
          ? this.guardrails
          : (guardrails as List?)?.cast<GuardrailConfig>(),
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
  factory ConversationList.fromJson(Object json) {
    if (json is List) {
      return ConversationList(
        data: json
            .cast<Map<String, dynamic>>()
            .map(Conversation.fromJson)
            .toList(),
      );
    }
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Expected a conversation list.');
    }
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
          listsEqual(data, other.data) &&
          total == other.total &&
          hasMore == other.hasMore;

  @override
  int get hashCode => Object.hash(object, Object.hashAll(data), total, hasMore);

  @override
  String toString() => 'ConversationList(count: $length, total: $total)';
}

int? _seconds(DateTime? value) =>
    value == null ? null : value.millisecondsSinceEpoch ~/ 1000;

DateTime? _conversationTime(Object? value) => switch (value) {
  final DateTime timestamp => timestamp,
  final String timestamp => DateTime.parse(timestamp),
  final int seconds => DateTime.fromMillisecondsSinceEpoch(
    seconds * 1000,
    isUtc: true,
  ),
  _ => null,
};

int? _legacySeconds(Object? value) => value is int ? value : null;

DateTime? _parseIsoTime(Object? value) =>
    value is String ? DateTime.parse(value) : null;

Object? _wireTime(Object? value) =>
    value is DateTime ? value.toUtc().toIso8601String() : value;
