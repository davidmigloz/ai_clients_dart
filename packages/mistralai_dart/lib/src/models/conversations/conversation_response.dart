import 'package:meta/meta.dart';

import '../common/deep_unmodifiable_json.dart';
import '../common/equality_helpers.dart';
import '../metadata/usage_info.dart';
import '../moderations/guardrail_config.dart';
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

  /// Legacy view of response values shaped like a guardrail configuration.
  /// Use [guardrailResults] for the open JSON result from the API.
  final List<GuardrailConfig>? guardrails;

  /// The object tag returned by the API, when present.
  final String? object;

  /// Guardrail results returned by the service, preserving open JSON fields.
  final List<Map<String, dynamic>>? guardrailResults;

  /// Creates a [ConversationResponse].
  const ConversationResponse({
    required this.conversationId,
    required this.outputs,
    this.usage,
    this.guardrails,
    this.object,
    this.guardrailResults,
  });

  /// Creates a [ConversationResponse] from JSON.
  factory ConversationResponse.fromJson(Map<String, dynamic> json) {
    final rawGuardrails = (json['guardrails'] as List?)
        ?.cast<Map<String, dynamic>>();
    final results = rawGuardrails == null
        ? null
        : List<Map<String, dynamic>>.unmodifiable(
            rawGuardrails.map(
              (entry) => deepUnmodifiableJson(entry)! as Map<String, dynamic>,
            ),
          );
    return ConversationResponse(
      object: json['object'] as String?,
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
      guardrailResults: results,
      guardrails: results?.map(_legacyGuardrail).nonNulls.toList(),
    );
  }

  /// Converts this response to JSON.
  Map<String, dynamic> toJson() {
    return {
      'conversation_id': conversationId,
      'object': ?object,
      'outputs': outputs.map((e) => e.toJson()).toList(),
      if (usage != null) 'usage': usage!.toJson(),
      'guardrails':
          ?(guardrailResults ?? guardrails?.map((e) => e.toJson()).toList()),
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

GuardrailConfig? _legacyGuardrail(Map<String, dynamic> value) {
  if (!value.keys.any(
    const {'block_on_error', 'moderation_llm_v1', 'moderation_llm_v2'}.contains,
  )) {
    return null;
  }
  try {
    return GuardrailConfig.fromJson(value);
  } on FormatException {
    return null;
  } on TypeError {
    return null;
  }
}

/// Response from retrieving conversation entries.
@immutable
class ConversationEntriesResponse {
  /// Object tag from the API. Current history uses `conversation.history`.
  final String object;

  /// The entries in the conversation.
  final List<ConversationEntry> data;

  /// Creates a [ConversationEntriesResponse].
  const ConversationEntriesResponse({
    this.object = 'list',
    required this.data,
    this.conversationId,
  });

  /// ID of the conversation returned by the history endpoint.
  final String? conversationId;

  /// Entries in chronological order.
  List<ConversationEntry> get entries => data;

  /// Creates a [ConversationEntriesResponse] from JSON.
  factory ConversationEntriesResponse.fromJson(Map<String, dynamic> json) {
    return ConversationEntriesResponse(
      object:
          json['object'] as String? ??
          (json.containsKey('entries') ? 'conversation.history' : 'list'),
      conversationId: json['conversation_id'] as String?,
      data:
          ((json['entries'] ?? json['data']) as List<dynamic>?)
              ?.map(
                (e) => ConversationEntry.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  /// Converts this response to JSON.
  Map<String, dynamic> toJson() {
    return {
      'object': object,
      'conversation_id': ?conversationId,
      if (object == 'conversation.history' || conversationId != null)
        'entries': data.map((e) => e.toJson()).toList()
      else
        'data': data.map((e) => e.toJson()).toList(),
    };
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
          conversationId == other.conversationId &&
          listsEqual(data, other.data);

  @override
  int get hashCode => Object.hash(object, conversationId, listHash(data));

  @override
  String toString() => 'ConversationEntriesResponse(entries: $length)';
}

/// Messages returned by the conversation messages endpoint.
@immutable
class ConversationMessagesResponse {
  /// Creates a response containing the messages of a conversation.
  const ConversationMessagesResponse({
    required this.conversationId,
    required this.messages,
  });

  /// ID of the conversation.
  final String conversationId;

  /// Input and output messages in chronological order.
  final List<ConversationEntry> messages;

  /// Reads the conversation messages response.
  factory ConversationMessagesResponse.fromJson(Map<String, dynamic> json) {
    if (json['object'] case final value?
        when value != 'conversation.messages') {
      throw FormatException('Unexpected conversation messages object: $value.');
    }
    final id = json['conversation_id'];
    final messages = json['messages'];
    if (id is! String || messages is! List) {
      throw const FormatException('Expected conversation_id and messages.');
    }

    return ConversationMessagesResponse(
      conversationId: id,
      messages: messages
          .cast<Map<String, dynamic>>()
          .map(ConversationEntry.fromJson)
          .toList(),
    );
  }

  /// Creates a copy with the given fields replaced.
  ConversationMessagesResponse copyWith({
    String? conversationId,
    List<ConversationEntry>? messages,
  }) => ConversationMessagesResponse(
    conversationId: conversationId ?? this.conversationId,
    messages: messages ?? this.messages,
  );

  /// The object tag for this response.
  String get object => 'conversation.messages';

  /// Converts back to JSON.
  Map<String, dynamic> toJson() => {
    'object': object,
    'conversation_id': conversationId,
    'messages': [for (final message in messages) message.toJson()],
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationMessagesResponse &&
          conversationId == other.conversationId &&
          listsEqual(messages, other.messages);

  @override
  int get hashCode => Object.hash(conversationId, listHash(messages));

  @override
  String toString() =>
      'ConversationMessagesResponse(conversationId: $conversationId, messages: ${messages.length})';
}
