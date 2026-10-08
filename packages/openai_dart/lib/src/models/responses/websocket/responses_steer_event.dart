import 'package:meta/meta.dart';

import '../../common/equality_helpers.dart';
import '../../common/json_helpers.dart';
import '../config/message_role.dart';
import '../items/item.dart';
import 'responses_steer_content.dart';
import 'websocket_json_helpers.dart';

/// Queues user input for a running response on its existing WebSocket lane.
///
/// Exactly `type`, `previous_response_id` and `input` are sent. Acceptance queues
/// server-owned input; a successor's `response.created` commits it. This DTO does
/// not choose a lane, create a successor, cancel tools or replay lost messages.
@immutable
class ResponsesSteerEvent {
  /// Response targeted on this connection.
  final String previousResponseId;

  /// User-only text or a nonempty message list.
  final ResponsesSteerInput input;

  /// Creates a steering submission.
  const ResponsesSteerEvent({
    required this.previousResponseId,
    required this.input,
  });

  /// The fixed discriminator.
  String get type => 'response.steer';

  /// Parses the restrictive operational guide contract.
  factory ResponsesSteerEvent.fromJson(Map<String, dynamic> json) {
    requireJsonType(json, 'response.steer', 'ResponsesSteerEvent');
    _requireSteerOnlyKeys(json, const {
      'type',
      'previous_response_id',
      'input',
    }, 'ResponsesSteerEvent');
    final snapshot = snapshotResponsesJson(json, 'ResponsesSteerEvent');
    return ResponsesSteerEvent(
      previousResponseId: requireJsonString(
        snapshot['previous_response_id'],
        'ResponsesSteerEvent.previous_response_id',
      ),
      input: ResponsesSteerInput.fromJson(snapshot['input']),
    );
  }

  /// Serializes only the supported steering members.
  Map<String, dynamic> toJson() => {
    'type': type,
    'previous_response_id': previousResponseId,
    'input': input.toJson(),
  };

  /// Copies both required fields.
  ResponsesSteerEvent copyWith({
    String? previousResponseId,
    ResponsesSteerInput? input,
  }) => ResponsesSteerEvent(
    previousResponseId: previousResponseId ?? this.previousResponseId,
    input: input ?? this.input,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponsesSteerEvent &&
          runtimeType == other.runtimeType &&
          previousResponseId == other.previousResponseId &&
          input == other.input;
  @override
  int get hashCode => Object.hash(previousResponseId, input);
  @override
  String toString() =>
      'ResponsesSteerEvent(previousResponseId: [REDACTED], input: present)';
}

/// User-only steering input: [ResponsesSteerTextInput] or
/// [ResponsesSteerMessagesInput]. Only the outer message list must be nonempty;
/// empty text and empty content arrays retain their source-defined behavior.
@immutable
sealed class ResponsesSteerInput {
  /// Creates steering input.
  const ResponsesSteerInput();

  /// Creates a plain user text submission.
  const factory ResponsesSteerInput.text(String text) = ResponsesSteerTextInput;

  /// Creates user message input, validated as nonempty when serialized.
  const factory ResponsesSteerInput.messages(
    List<ResponsesSteerMessage> messages,
  ) = ResponsesSteerMessagesInput;

  /// Parses text or a nonempty list of restricted user messages.
  factory ResponsesSteerInput.fromJson(Object? json) {
    if (json is String) return ResponsesSteerTextInput(json);
    if (json is! List<dynamic> || json.isEmpty) {
      throw const FormatException(
        'ResponsesSteerInput: expected text or a nonempty user message list',
      );
    }
    final messages = <ResponsesSteerMessage>[];
    for (var index = 0; index < json.length; index++) {
      try {
        messages.add(
          ResponsesSteerMessage.fromJson(
            requireJsonObject(json[index], 'ResponsesSteerInput[$index]'),
          ),
        );
      } on FormatException catch (error) {
        throw FormatException('ResponsesSteerInput[$index]: ${error.message}');
      }
    }
    return ResponsesSteerMessagesInput(
      List<ResponsesSteerMessage>.unmodifiable(messages),
    );
  }

  /// Converts to the ordinary string/list wire shape.
  Object toJson();
}

/// A user text steering submission.
@immutable
class ResponsesSteerTextInput extends ResponsesSteerInput {
  /// User text, including a valid empty string.
  final String text;

  /// Creates text input.
  const ResponsesSteerTextInput(this.text);
  @override
  String toJson() => text;

  /// Copies the required text.
  ResponsesSteerTextInput copyWith({String? text}) =>
      ResponsesSteerTextInput(text ?? this.text);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponsesSteerTextInput &&
          runtimeType == other.runtimeType &&
          text == other.text;
  @override
  int get hashCode => text.hashCode;
  @override
  String toString() => 'ResponsesSteerTextInput(text: ${text.length} chars)';
}

/// A nonempty list of restricted user messages.
@immutable
class ResponsesSteerMessagesInput extends ResponsesSteerInput {
  /// Messages in submission order. Parsed lists are immutable snapshots.
  final List<ResponsesSteerMessage> messages;

  /// Creates input, preserving const caller-owned list semantics.
  const ResponsesSteerMessagesInput(this.messages);
  @override
  List<Map<String, dynamic>> toJson() {
    if (messages.isEmpty) {
      throw const FormatException(
        'ResponsesSteerMessagesInput.messages: expected a nonempty list',
      );
    }
    return messages.map((message) => message.toJson()).toList();
  }

  /// Copies the entire message list.
  ResponsesSteerMessagesInput copyWith({
    List<ResponsesSteerMessage>? messages,
  }) => ResponsesSteerMessagesInput(messages ?? this.messages);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponsesSteerMessagesInput &&
          runtimeType == other.runtimeType &&
          listsEqual(messages, other.messages);
  @override
  int get hashCode => listHash(messages);
  @override
  String toString() =>
      'ResponsesSteerMessagesInput(messages: ${messages.length} items)';
}

/// A user steering message containing only type, role and content.
@immutable
class ResponsesSteerMessage {
  /// User text or supported request content parts.
  ResponsesSteerMessageContent get content =>
      _content ??
      (_parts == null
          ? ResponsesSteerTextContent(_text!)
          : ResponsesSteerPartsContent(_parts));

  final ResponsesSteerMessageContent? _content;
  final String? _text;
  final List<ResponsesSteerContentPart>? _parts;

  /// Creates a message with typed content.
  const ResponsesSteerMessage({
    required ResponsesSteerMessageContent this._content,
  }) : _text = null,
       _parts = null;

  /// Creates a plain user message.
  const ResponsesSteerMessage.text(String text)
    : _content = null,
      _text = text,
      _parts = null;

  /// Creates a user message with text/image/file parts.
  const ResponsesSteerMessage.parts(List<ResponsesSteerContentPart> parts)
    : _content = null,
      _text = null,
      _parts = parts;

  /// The fixed message type.
  String get type => 'message';

  /// The fixed user role.
  String get role => 'user';

  /// Projects an existing user item, explicitly dropping item identity/status/
  /// agent/phase metadata. Other roles or content types are rejected.
  factory ResponsesSteerMessage.fromMessageItem(MessageItem message) {
    if (message.role != MessageRole.user) {
      throw const FormatException('ResponsesSteerMessage.role: expected user');
    }
    return ResponsesSteerMessage.parts(
      List<ResponsesSteerContentPart>.unmodifiable(
        message.content.map(ResponsesSteerContentPart.fromInputContent),
      ),
    );
  }

  /// Parses only guide-supported fields. An omitted type normalizes to message;
  /// a supplied type must be message. User role/content are required.
  factory ResponsesSteerMessage.fromJson(Map<String, dynamic> json) {
    _requireSteerOnlyKeys(json, const {
      'type',
      'role',
      'content',
    }, 'ResponsesSteerMessage');
    if (json.containsKey('type')) {
      requireJsonType(json, 'message', 'ResponsesSteerMessage');
    }
    if (json['role'] != 'user') {
      throw const FormatException('ResponsesSteerMessage.role: expected user');
    }
    return ResponsesSteerMessage(
      content: ResponsesSteerMessageContent.fromJson(json['content']),
    );
  }

  /// Serializes the narrow message projection.
  Map<String, dynamic> toJson() => {
    'type': type,
    'role': role,
    'content': content.toJson(),
  };

  /// Copies the required content.
  ResponsesSteerMessage copyWith({ResponsesSteerMessageContent? content}) =>
      ResponsesSteerMessage(content: content ?? this.content);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponsesSteerMessage &&
          runtimeType == other.runtimeType &&
          content == other.content;
  @override
  int get hashCode => content.hashCode;
  @override
  String toString() => 'ResponsesSteerMessage(content: present)';
}

/// User message content: [ResponsesSteerTextContent] or
/// [ResponsesSteerPartsContent].
@immutable
sealed class ResponsesSteerMessageContent {
  /// Creates user content.
  const ResponsesSteerMessageContent();

  /// Parses a string or text/image/file part list (which may be empty).
  factory ResponsesSteerMessageContent.fromJson(Object? json) {
    if (json is String) return ResponsesSteerTextContent(json);
    if (json is! List<dynamic>) {
      throw const FormatException(
        'ResponsesSteerMessage.content: expected text or supported content parts',
      );
    }
    final parts = <ResponsesSteerContentPart>[];
    for (var index = 0; index < json.length; index++) {
      try {
        parts.add(
          ResponsesSteerContentPart.fromJson(
            requireJsonObject(
              json[index],
              'ResponsesSteerMessage.content[$index]',
            ),
          ),
        );
      } on FormatException catch (error) {
        throw FormatException(
          'ResponsesSteerMessage.content[$index]: ${error.message}',
        );
      }
    }
    return ResponsesSteerPartsContent(
      List<ResponsesSteerContentPart>.unmodifiable(parts),
    );
  }

  /// Converts to message content JSON.
  Object toJson();
}

/// Plain user message text.
@immutable
class ResponsesSteerTextContent extends ResponsesSteerMessageContent {
  /// Message text.
  final String text;

  /// Creates text content.
  const ResponsesSteerTextContent(this.text);
  @override
  String toJson() => text;

  /// Copies the text.
  ResponsesSteerTextContent copyWith({String? text}) =>
      ResponsesSteerTextContent(text ?? this.text);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponsesSteerTextContent &&
          runtimeType == other.runtimeType &&
          text == other.text;
  @override
  int get hashCode => text.hashCode;
  @override
  String toString() => 'ResponsesSteerTextContent(text: ${text.length} chars)';
}

/// Supported user request content parts.
@immutable
class ResponsesSteerPartsContent extends ResponsesSteerMessageContent {
  /// Content parts in their original order. Parsed lists are immutable.
  final List<ResponsesSteerContentPart> parts;

  /// Creates content while preserving const caller-owned list construction.
  const ResponsesSteerPartsContent(this.parts);
  @override
  List<Map<String, dynamic>> toJson() =>
      parts.map((part) => part.toJson()).toList();

  /// Copies the list.
  ResponsesSteerPartsContent copyWith({
    List<ResponsesSteerContentPart>? parts,
  }) => ResponsesSteerPartsContent(parts ?? this.parts);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponsesSteerPartsContent &&
          runtimeType == other.runtimeType &&
          listsEqual(parts, other.parts);
  @override
  int get hashCode => listHash(parts);
  @override
  String toString() =>
      'ResponsesSteerPartsContent(parts: ${parts.length} items)';
}

/// Validates closed operational shapes without exposing unknown member names.
void _requireSteerOnlyKeys(
  Map<String, dynamic> json,
  Set<String> keys,
  String context,
) {
  if (json.keys.any((key) => !keys.contains(key))) {
    throw FormatException('$context: unsupported member');
  }
}
