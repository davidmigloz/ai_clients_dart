part of 'agent_session_models.dart';

/// Initial input submitted when creating a session.
sealed class AgentSessionInitialInput extends AgentJsonModel {
  const AgentSessionInitialInput();

  /// Builds a textual wire value.
  factory AgentSessionInitialInput.text(String text) =
      AgentSessionInitialInputText;

  /// Builds a content/message array wire value.
  factory AgentSessionInitialInput.items(List<AgentSessionInputMessage> items) =
      AgentSessionInitialInputItems;

  /// Parses the canonical string or array shape.
  factory AgentSessionInitialInput.fromJson(Object? json) {
    if (json is String) return AgentSessionInitialInputText(json);
    return AgentSessionInitialInputItems(
      requireAgentList(json, 'AgentSessionInitialInput')
          .map(
            (value) => AgentSessionInputMessage.fromJson(
              requireAgentObject(value, 'AgentSessionInitialInput item'),
            ),
          )
          .toList(),
    );
  }
}

/// Textual form of [AgentSessionInitialInput].
final class AgentSessionInitialInputText extends AgentSessionInitialInput {
  /// Creates a validated text value.
  AgentSessionInitialInputText(this.text) {
    validate();
  }

  /// Exact text, never printed automatically.
  final String text;
  @override
  void validate() {
    validateAgentLength(
      text,
      'AgentSessionInitialInput.text',
      min: 1,
      max: 1048576,
    );
  }

  @override
  String toJson() => text;

  /// Copies text and checks source limits.
  AgentSessionInitialInputText copyWith({String? text}) =>
      AgentSessionInitialInputText(text ?? this.text);
}

/// Array form of [AgentSessionInitialInput], with detached immutable collection ownership.
final class AgentSessionInitialInputItems extends AgentSessionInitialInput {
  /// Creates a validated array value.
  AgentSessionInitialInputItems(List<AgentSessionInputMessage> items)
    : items = List.unmodifiable(items) {
    validate();
  }

  /// The immutable canonical array.
  final List<AgentSessionInputMessage> items;
  @override
  void validate() {
    validateAgentCount(
      items.length,
      'AgentSessionInitialInput.items',
      min: 0,
      max: 16384,
    );
    for (final item in items) {
      item.validate();
    }
  }

  @override
  List<Object> toJson() => items.map((item) => item.toJson()).toList();

  /// Replaces the array and owns the supplied values.
  AgentSessionInitialInputItems copyWith({
    List<AgentSessionInputMessage>? items,
  }) => AgentSessionInitialInputItems(items ?? this.items);
}

/// A function result represented as text or supported model-input content.
sealed class AgentSessionFunctionOutput extends AgentJsonModel {
  const AgentSessionFunctionOutput();

  /// Builds a textual wire value.
  factory AgentSessionFunctionOutput.text(String text) =
      AgentSessionFunctionOutputText;

  /// Builds a content/message array wire value.
  factory AgentSessionFunctionOutput.items(
    List<AgentSessionInputContent> items,
  ) = AgentSessionFunctionOutputItems;

  /// Parses the canonical string or array shape.
  factory AgentSessionFunctionOutput.fromJson(Object? json) {
    if (json is String) return AgentSessionFunctionOutputText(json);
    return AgentSessionFunctionOutputItems(
      requireAgentList(json, 'AgentSessionFunctionOutput')
          .map(
            (value) => AgentSessionInputContent.fromJson(
              requireAgentObject(value, 'AgentSessionFunctionOutput item'),
            ),
          )
          .toList(),
    );
  }
}

/// Textual form of [AgentSessionFunctionOutput].
final class AgentSessionFunctionOutputText extends AgentSessionFunctionOutput {
  /// Creates a validated text value.
  AgentSessionFunctionOutputText(this.text) {
    validate();
  }

  /// Exact text, never printed automatically.
  final String text;
  @override
  void validate() {
    validateAgentLength(
      text,
      'AgentSessionFunctionOutput.text',
      min: 0,
      max: 1048576,
    );
  }

  @override
  String toJson() => text;

  /// Copies text and checks source limits.
  AgentSessionFunctionOutputText copyWith({String? text}) =>
      AgentSessionFunctionOutputText(text ?? this.text);
}

/// Array form of [AgentSessionFunctionOutput], with detached immutable collection ownership.
final class AgentSessionFunctionOutputItems extends AgentSessionFunctionOutput {
  /// Creates a validated array value.
  AgentSessionFunctionOutputItems(List<AgentSessionInputContent> items)
    : items = List.unmodifiable(items) {
    validate();
  }

  /// The immutable canonical array.
  final List<AgentSessionInputContent> items;
  @override
  void validate() {
    validateAgentCount(
      items.length,
      'AgentSessionFunctionOutput.items',
      min: 0,
      max: 16384,
    );
    for (final item in items) {
      item.validate();
    }
  }

  @override
  List<Object> toJson() => items.map((item) => item.toJson()).toList();

  /// Replaces the array and owns the supplied values.
  AgentSessionFunctionOutputItems copyWith({
    List<AgentSessionInputContent>? items,
  }) => AgentSessionFunctionOutputItems(items ?? this.items);
}

/// The text or model-input content supplied as a function result.
sealed class AgentSessionFunctionOutputResource extends AgentJsonModel {
  const AgentSessionFunctionOutputResource();

  /// Builds a textual wire value.
  factory AgentSessionFunctionOutputResource.text(String text) =
      AgentSessionFunctionOutputResourceText;

  /// Builds a content/message array wire value.
  factory AgentSessionFunctionOutputResource.items(
    List<AgentSessionInputContentResource> items,
  ) = AgentSessionFunctionOutputResourceItems;

  /// Parses the canonical string or array shape.
  factory AgentSessionFunctionOutputResource.fromJson(Object? json) {
    if (json is String) return AgentSessionFunctionOutputResourceText(json);
    return AgentSessionFunctionOutputResourceItems(
      requireAgentList(json, 'AgentSessionFunctionOutputResource')
          .map(
            (value) => AgentSessionInputContentResource.fromJson(
              requireAgentObject(
                value,
                'AgentSessionFunctionOutputResource item',
              ),
            ),
          )
          .toList(),
    );
  }
}

/// Textual form of [AgentSessionFunctionOutputResource].
final class AgentSessionFunctionOutputResourceText
    extends AgentSessionFunctionOutputResource {
  /// Creates a validated text value.
  AgentSessionFunctionOutputResourceText(this.text) {
    validate();
  }

  /// Exact text, never printed automatically.
  final String text;
  @override
  void validate() {
    validateAgentLength(
      text,
      'AgentSessionFunctionOutputResource.text',
      min: 0,
    );
  }

  @override
  String toJson() => text;

  /// Copies text and checks source limits.
  AgentSessionFunctionOutputResourceText copyWith({String? text}) =>
      AgentSessionFunctionOutputResourceText(text ?? this.text);
}

/// Array form of [AgentSessionFunctionOutputResource], with detached immutable collection ownership.
final class AgentSessionFunctionOutputResourceItems
    extends AgentSessionFunctionOutputResource {
  /// Creates a validated array value.
  AgentSessionFunctionOutputResourceItems(
    List<AgentSessionInputContentResource> items,
  ) : items = List.unmodifiable(items) {
    validate();
  }

  /// The immutable canonical array.
  final List<AgentSessionInputContentResource> items;
  @override
  void validate() {
    validateAgentCount(
      items.length,
      'AgentSessionFunctionOutputResource.items',
      min: 0,
      max: 2000,
    );
    for (final item in items) {
      item.validate();
    }
  }

  @override
  List<Object> toJson() => items.map((item) => item.toJson()).toList();

  /// Replaces the array and owns the supplied values.
  AgentSessionFunctionOutputResourceItems copyWith({
    List<AgentSessionInputContentResource>? items,
  }) => AgentSessionFunctionOutputResourceItems(items ?? this.items);
}

/// Content included in an input message.
/// Private diagnostics; known variants are parsed strictly.
sealed class AgentSessionInputContent extends AgentJsonModel {
  const AgentSessionInputContent();

  /// Parses a known contract or detached future received value.
  factory AgentSessionInputContent.fromJson(Map<String, dynamic> json) {
    return switch (requireAgentString(
      json['type'],
      'AgentSessionInputContent.type',
    )) {
      'input_image' => AgentSessionInputContentConfigInputImage.fromJson(json),
      'input_text' => AgentSessionInputContentConfigInputText.fromJson(json),
      _ => UnknownAgentSessionInputContent.fromJson(json),
    };
  }

  /// Canonical `type` discriminator.
  String get type;
  @override
  Map<String, dynamic> toJson();

  /// Builds the `input_image` contract.
  factory AgentSessionInputContent.inputImage({required String imageUrl}) =
      AgentSessionInputContentConfigInputImage;

  /// Builds the `input_text` contract.
  factory AgentSessionInputContent.inputText({required String text}) =
      AgentSessionInputContentConfigInputText;
}

/// Detached future `type` value with private diagnostics.
final class UnknownAgentSessionInputContent extends AgentSessionInputContent {
  const UnknownAgentSessionInputContent._(this.rawJson);

  /// Parses only unknown discriminators; known malformed values are rejected.
  factory UnknownAgentSessionInputContent.fromJson(Map<String, dynamic> json) {
    final tag = requireAgentString(
      json['type'],
      'UnknownAgentSessionInputContent.type',
    );
    if (const ['input_image', 'input_text'].contains(tag)) {
      throw const FormatException(
        'UnknownAgentSessionInputContent: expected a future discriminator',
      );
    }
    return UnknownAgentSessionInputContent._(
      snapshotAgentJson(json, 'UnknownAgentSessionInputContent'),
    );
  }

  /// Finite detached received snapshot; never an executable instruction.
  final Map<String, dynamic> rawJson;
  @override
  String get type => rawJson['type'] as String;
  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Replaces a received snapshot while retaining the unknown discriminator.
  UnknownAgentSessionInputContent copyWith({Map<String, dynamic>? rawJson}) =>
      UnknownAgentSessionInputContent.fromJson(rawJson ?? this.rawJson);
  @override
  void validate() => throw const FormatException(
    'UnknownAgentSessionInputContent: future input is not writable',
  );
}

/// Image input to the model.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentSessionInputContentConfigInputImage
    extends AgentSessionInputContent {
  /// Creates a validated [AgentSessionInputContentConfigInputImage].
  AgentSessionInputContentConfigInputImage({required this.imageUrl}) {
    validate();
  }

  /// The URL of the image sent to the model.
  final String imageUrl;

  /// The type of the object. Always `input_image`.
  @override
  String get type => 'input_image';

  /// Parses [AgentSessionInputContentConfigInputImage] with contextual, payload-free errors.
  factory AgentSessionInputContentConfigInputImage.fromJson(
    Map<String, dynamic> json,
  ) {
    requireClosedAgentJson(json, const [
      'image_url',
      'type',
    ], 'AgentSessionInputContentConfigInputImage');
    requireAgentTag(
      json,
      'type',
      'input_image',
      'AgentSessionInputContentConfigInputImage',
    );
    return AgentSessionInputContentConfigInputImage(
      imageUrl: requiredAgentValue(
        json,
        'image_url',
        'AgentSessionInputContentConfigInputImage.imageUrl',
        requireAgentString,
        nullable: false,
      )!,
    );
  }
  @override
  void validate() {
    validateAgentLength(
      imageUrl,
      'AgentSessionInputContentConfigInputImage.imageUrl',
      min: 0,
      max: 1048576,
    );
  }

  @override
  Map<String, dynamic> toJson() => {'image_url': imageUrl, 'type': type};

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionInputContentConfigInputImage copyWith({String? imageUrl}) =>
      AgentSessionInputContentConfigInputImage(
        imageUrl: imageUrl ?? this.imageUrl,
      );
}

/// Text input to the model.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentSessionInputContentConfigInputText
    extends AgentSessionInputContent {
  /// Creates a validated [AgentSessionInputContentConfigInputText].
  AgentSessionInputContentConfigInputText({required this.text}) {
    validate();
  }

  /// The text sent to the model.
  final String text;

  /// The type of the object. Always `input_text`.
  @override
  String get type => 'input_text';

  /// Parses [AgentSessionInputContentConfigInputText] with contextual, payload-free errors.
  factory AgentSessionInputContentConfigInputText.fromJson(
    Map<String, dynamic> json,
  ) {
    requireClosedAgentJson(json, const [
      'text',
      'type',
    ], 'AgentSessionInputContentConfigInputText');
    requireAgentTag(
      json,
      'type',
      'input_text',
      'AgentSessionInputContentConfigInputText',
    );
    return AgentSessionInputContentConfigInputText(
      text: requiredAgentValue(
        json,
        'text',
        'AgentSessionInputContentConfigInputText.text',
        requireAgentString,
        nullable: false,
      )!,
    );
  }
  @override
  void validate() {
    validateAgentLength(
      text,
      'AgentSessionInputContentConfigInputText.text',
      min: 0,
      max: 1048576,
    );
  }

  @override
  Map<String, dynamic> toJson() => {'text': text, 'type': type};

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionInputContentConfigInputText copyWith({String? text}) =>
      AgentSessionInputContentConfigInputText(text: text ?? this.text);
}

/// User-provided content recorded in a session item.
/// Private diagnostics; known variants are parsed strictly.
sealed class AgentSessionInputContentResource extends AgentJsonModel {
  const AgentSessionInputContentResource();

  /// Parses a known contract or detached future received value.
  factory AgentSessionInputContentResource.fromJson(Map<String, dynamic> json) {
    return switch (requireAgentString(
      json['type'],
      'AgentSessionInputContentResource.type',
    )) {
      'input_image' => AgentSessionInputContentResourceInputImage.fromJson(
        json,
      ),
      'input_text' => AgentSessionInputContentResourceInputText.fromJson(json),
      _ => UnknownAgentSessionInputContentResource.fromJson(json),
    };
  }

  /// Canonical `type` discriminator.
  String get type;
  @override
  Map<String, dynamic> toJson();

  /// Builds the `input_image` contract.
  factory AgentSessionInputContentResource.inputImage({
    required String imageUrl,
    Map<String, dynamic> rawJson,
  }) = AgentSessionInputContentResourceInputImage;

  /// Builds the `input_text` contract.
  factory AgentSessionInputContentResource.inputText({
    required String text,
    Map<String, dynamic> rawJson,
  }) = AgentSessionInputContentResourceInputText;
}

/// Detached future `type` value with private diagnostics.
final class UnknownAgentSessionInputContentResource
    extends AgentSessionInputContentResource {
  const UnknownAgentSessionInputContentResource._(this.rawJson);

  /// Parses only unknown discriminators; known malformed values are rejected.
  factory UnknownAgentSessionInputContentResource.fromJson(
    Map<String, dynamic> json,
  ) {
    final tag = requireAgentString(
      json['type'],
      'UnknownAgentSessionInputContentResource.type',
    );
    if (const ['input_image', 'input_text'].contains(tag)) {
      throw const FormatException(
        'UnknownAgentSessionInputContentResource: expected a future discriminator',
      );
    }
    return UnknownAgentSessionInputContentResource._(
      snapshotAgentJson(json, 'UnknownAgentSessionInputContentResource'),
    );
  }

  /// Finite detached received snapshot; never an executable instruction.
  final Map<String, dynamic> rawJson;
  @override
  String get type => rawJson['type'] as String;
  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Replaces a received snapshot while retaining the unknown discriminator.
  UnknownAgentSessionInputContentResource copyWith({
    Map<String, dynamic>? rawJson,
  }) =>
      UnknownAgentSessionInputContentResource.fromJson(rawJson ?? this.rawJson);
}

/// Image input recorded in a session item.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionInputContentResourceInputImage
    extends AgentSessionInputContentResource {
  /// Creates a validated [AgentSessionInputContentResourceInputImage].
  AgentSessionInputContentResourceInputImage({
    required this.imageUrl,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'image_url',
         'type',
       ], 'AgentSessionInputContentResourceInputImage') {
    validate();
  }

  /// The URL of the image supplied to the agent, which may be a base64-encoded data URL.
  final String imageUrl;

  /// The type of the object. Always `input_image`.
  @override
  String get type => 'input_image';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionInputContentResourceInputImage] with contextual, payload-free errors.
  factory AgentSessionInputContentResourceInputImage.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'input_image',
      'AgentSessionInputContentResourceInputImage',
    );
    return AgentSessionInputContentResourceInputImage(
      imageUrl: requiredAgentValue(
        json,
        'image_url',
        'AgentSessionInputContentResourceInputImage.imageUrl',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['image_url', 'type'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(
      imageUrl,
      'AgentSessionInputContentResourceInputImage.imageUrl',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'image_url': imageUrl,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionInputContentResourceInputImage copyWith({
    String? imageUrl,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionInputContentResourceInputImage(
    imageUrl: imageUrl ?? this.imageUrl,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Text input recorded in a session item.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionInputContentResourceInputText
    extends AgentSessionInputContentResource {
  /// Creates a validated [AgentSessionInputContentResourceInputText].
  AgentSessionInputContentResourceInputText({
    required this.text,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'text',
         'type',
       ], 'AgentSessionInputContentResourceInputText') {
    validate();
  }

  /// The text supplied to the agent.
  final String text;

  /// The type of the object. Always `input_text`.
  @override
  String get type => 'input_text';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionInputContentResourceInputText] with contextual, payload-free errors.
  factory AgentSessionInputContentResourceInputText.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'input_text',
      'AgentSessionInputContentResourceInputText',
    );
    return AgentSessionInputContentResourceInputText(
      text: requiredAgentValue(
        json,
        'text',
        'AgentSessionInputContentResourceInputText.text',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['text', 'type'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(
      text,
      'AgentSessionInputContentResourceInputText.text',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {...rawJson, 'text': text, 'type': type};

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionInputContentResourceInputText copyWith({
    String? text,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionInputContentResourceInputText(
    text: text ?? this.text,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A user message submitted to a session.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentSessionInputMessage extends AgentJsonModel {
  /// Creates a validated [AgentSessionInputMessage].
  AgentSessionInputMessage({
    required List<AgentSessionInputContent> content,
    this.hasType = true,
  }) : content = List.unmodifiable(content) {
    validate();
  }

  /// The content of the message.
  final List<AgentSessionInputContent> content;

  /// The role of the message author. Always `user`.
  String get role => 'user';

  /// The type of the input item. Always `message`.
  String get type => 'message';

  /// Whether the optional canonical `type` key is present.
  final bool hasType;

  /// Parses [AgentSessionInputMessage] with contextual, payload-free errors.
  factory AgentSessionInputMessage.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'content',
      'role',
      'type',
    ], 'AgentSessionInputMessage');
    requireAgentTag(json, 'role', 'user', 'AgentSessionInputMessage');
    if (json.containsKey('type')) {
      requireAgentTag(json, 'type', 'message', 'AgentSessionInputMessage');
    }
    return AgentSessionInputMessage(
      hasType: json.containsKey('type'),
      content: requiredAgentValue(
        json,
        'content',
        'AgentSessionInputMessage.content',
        (value, context) => requireAgentList(value, context)
            .map(
              (value) => AgentSessionInputContent.fromJson(
                requireAgentObject(value, context),
              ),
            )
            .toList(),
        nullable: false,
      )!,
    );
  }
  @override
  void validate() {
    validateAgentCount(
      content.length,
      'AgentSessionInputMessage.content',
      min: 0,
      max: 16384,
    );
    for (final item in content) {
      item.validate();
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    'content': content.map((value) => value.toJson()).toList(),
    'role': role,
    if (hasType) 'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionInputMessage copyWith({
    bool? hasType,
    List<AgentSessionInputContent>? content,
  }) => AgentSessionInputMessage(
    hasType: hasType ?? this.hasType,
    content: content ?? this.content,
  );
}

/// Input submitted to an existing session.
/// Private diagnostics; known variants are parsed strictly.
sealed class AgentSessionInput extends AgentJsonModel {
  const AgentSessionInput();

  /// Parses a known contract or detached future received value.
  factory AgentSessionInput.fromJson(Map<String, dynamic> json) {
    return switch (requireAgentString(json['type'], 'AgentSessionInput.type')) {
      'agent.session.input.cancel' => AgentSessionCancelInput.fromJson(json),
      'agent.session.input.computer_use_approval_request_result' =>
        AgentSessionApprovalResultInput.fromJson(json),
      'agent.session.input.message' => AgentSessionMessageInput.fromJson(json),
      'agent.session.input.tool_result' => AgentSessionToolResultInput.fromJson(
        json,
      ),
      _ => UnknownAgentSessionInput.fromJson(json),
    };
  }

  /// Canonical `type` discriminator.
  String get type;
  @override
  Map<String, dynamic> toJson();

  /// Builds the `agent.session.input.cancel` contract.
  factory AgentSessionInput.cancel() = AgentSessionCancelInput;

  /// Builds the `agent.session.input.computer_use_approval_request_result` contract.
  factory AgentSessionInput.computerUseApprovalRequestResult({
    required String requestId,
    required AgentSessionComputerUseApprovalResponse response,
  }) = AgentSessionApprovalResultInput;

  /// Builds the `agent.session.input.message` contract.
  factory AgentSessionInput.message({
    required List<AgentSessionInputMessage> input,
  }) = AgentSessionMessageInput;

  /// Builds the `agent.session.input.tool_result` contract.
  factory AgentSessionInput.toolResult({
    required String callId,
    String? error,
    bool clearError,
    AgentSessionFunctionOutput? output,
    bool clearOutput,
    required bool success,
    required String turnId,
  }) = AgentSessionToolResultInput;
}

/// Detached future `type` value with private diagnostics.
final class UnknownAgentSessionInput extends AgentSessionInput {
  const UnknownAgentSessionInput._(this.rawJson);

  /// Parses only unknown discriminators; known malformed values are rejected.
  factory UnknownAgentSessionInput.fromJson(Map<String, dynamic> json) {
    final tag = requireAgentString(
      json['type'],
      'UnknownAgentSessionInput.type',
    );
    if (const [
      'agent.session.input.cancel',
      'agent.session.input.computer_use_approval_request_result',
      'agent.session.input.message',
      'agent.session.input.tool_result',
    ].contains(tag)) {
      throw const FormatException(
        'UnknownAgentSessionInput: expected a future discriminator',
      );
    }
    return UnknownAgentSessionInput._(
      snapshotAgentJson(json, 'UnknownAgentSessionInput'),
    );
  }

  /// Finite detached received snapshot; never an executable instruction.
  final Map<String, dynamic> rawJson;
  @override
  String get type => rawJson['type'] as String;
  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Replaces a received snapshot while retaining the unknown discriminator.
  UnknownAgentSessionInput copyWith({Map<String, dynamic>? rawJson}) =>
      UnknownAgentSessionInput.fromJson(rawJson ?? this.rawJson);
  @override
  void validate() => throw const FormatException(
    'UnknownAgentSessionInput: future input is not writable',
  );
}

/// Cancels the session's active turn.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentSessionCancelInput extends AgentSessionInput {
  /// Creates a validated [AgentSessionCancelInput].
  AgentSessionCancelInput() {
    validate();
  }

  /// The type of the object. Always `agent.session.input.cancel`.
  @override
  String get type => 'agent.session.input.cancel';

  /// Parses [AgentSessionCancelInput] with contextual, payload-free errors.
  factory AgentSessionCancelInput.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const ['type'], 'AgentSessionCancelInput');
    requireAgentTag(
      json,
      'type',
      'agent.session.input.cancel',
      'AgentSessionCancelInput',
    );
    return AgentSessionCancelInput();
  }
  @override
  void validate() {}
  @override
  Map<String, dynamic> toJson() => {'type': type};

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionCancelInput copyWith() => AgentSessionCancelInput();
}

/// Adds one or more user messages and starts a turn.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentSessionMessageInput extends AgentSessionInput {
  /// Creates a validated [AgentSessionMessageInput].
  AgentSessionMessageInput({required List<AgentSessionInputMessage> input})
    : input = List.unmodifiable(input) {
    validate();
  }

  /// The user messages to add to the session.
  final List<AgentSessionInputMessage> input;

  /// The type of the object. Always `agent.session.input.message`.
  @override
  String get type => 'agent.session.input.message';

  /// Parses [AgentSessionMessageInput] with contextual, payload-free errors.
  factory AgentSessionMessageInput.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'input',
      'type',
    ], 'AgentSessionMessageInput');
    requireAgentTag(
      json,
      'type',
      'agent.session.input.message',
      'AgentSessionMessageInput',
    );
    return AgentSessionMessageInput(
      input: requiredAgentValue(
        json,
        'input',
        'AgentSessionMessageInput.input',
        (value, context) => requireAgentList(value, context)
            .map(
              (value) => AgentSessionInputMessage.fromJson(
                requireAgentObject(value, context),
              ),
            )
            .toList(),
        nullable: false,
      )!,
    );
  }
  @override
  void validate() {
    validateAgentCount(
      input.length,
      'AgentSessionMessageInput.input',
      min: 0,
      max: 16384,
    );
    for (final item in input) {
      item.validate();
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    'input': input.map((value) => value.toJson()).toList(),
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionMessageInput copyWith({List<AgentSessionInputMessage>? input}) =>
      AgentSessionMessageInput(input: input ?? this.input);
}

/// Submits the result of a function call.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentSessionToolResultInput extends AgentSessionInput {
  /// Creates a validated [AgentSessionToolResultInput].
  AgentSessionToolResultInput({
    required this.callId,
    String? error,
    bool clearError = false,
    AgentSessionFunctionOutput? output,
    bool clearOutput = false,
    required this.success,
    required this.turnId,
  }) : clearError = clearError,
       error = clearError ? null : error,
       clearOutput = clearOutput,
       output = clearOutput ? null : output {
    validate();
  }

  /// The ID of the function call.
  final String callId;

  /// The error message when the call failed.
  final String? error;

  /// Sends `error: null`, rather than omitting it.
  final bool clearError;

  /// The function result when the call succeeded.
  final AgentSessionFunctionOutput? output;

  /// Sends `output: null`, rather than omitting it.
  final bool clearOutput;

  /// Whether the function call succeeded.
  final bool success;

  /// The ID of the turn that requested the function call.
  final String turnId;

  /// The type of the object. Always `agent.session.input.tool_result`.
  @override
  String get type => 'agent.session.input.tool_result';

  /// Parses [AgentSessionToolResultInput] with contextual, payload-free errors.
  factory AgentSessionToolResultInput.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'call_id',
      'error',
      'output',
      'success',
      'turn_id',
      'type',
    ], 'AgentSessionToolResultInput');
    requireAgentTag(
      json,
      'type',
      'agent.session.input.tool_result',
      'AgentSessionToolResultInput',
    );
    return AgentSessionToolResultInput(
      callId: requiredAgentValue(
        json,
        'call_id',
        'AgentSessionToolResultInput.callId',
        requireAgentString,
        nullable: false,
      )!,
      error: optionalAgentValue(
        json,
        'error',
        'AgentSessionToolResultInput.error',
        requireAgentString,
        nullable: true,
      ),
      clearError: json.containsKey('error') && json['error'] == null,
      output: optionalAgentValue(
        json,
        'output',
        'AgentSessionToolResultInput.output',
        (value, context) => AgentSessionFunctionOutput.fromJson(value),
        nullable: true,
      ),
      clearOutput: json.containsKey('output') && json['output'] == null,
      success: requiredAgentValue(
        json,
        'success',
        'AgentSessionToolResultInput.success',
        requireAgentBool,
        nullable: false,
      )!,
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionToolResultInput.turnId',
        requireAgentString,
        nullable: false,
      )!,
    );
  }
  @override
  void validate() {
    validateAgentLength(
      callId,
      'AgentSessionToolResultInput.callId',
      min: 0,
      max: 1048576,
    );
    if (error != null) {
      validateAgentLength(
        error!,
        'AgentSessionToolResultInput.error',
        min: 0,
        max: 1048576,
      );
    }
    if (output != null) {
      output!.validate();
    }
    validateAgentLength(
      turnId,
      'AgentSessionToolResultInput.turnId',
      min: 0,
      max: 1048576,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'call_id': callId,
    if (clearError) 'error': null else 'error': ?error,
    if (clearOutput)
      'output': null
    else if (output != null)
      'output': output!.toJson(),
    'success': success,
    'turn_id': turnId,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionToolResultInput copyWith({
    String? callId,
    Object? error = unsetCopyWithValue,
    bool? clearError,
    Object? output = unsetCopyWithValue,
    bool? clearOutput,
    bool? success,
    String? turnId,
  }) => AgentSessionToolResultInput(
    callId: callId ?? this.callId,
    error: copyAgentValue<String>(
      error,
      this.error,
      'AgentSessionToolResultInput.error',
    ),
    clearError:
        clearError ??
        (identical(error, unsetCopyWithValue)
            ? this.clearError
            : error == null),
    output: copyAgentValue<AgentSessionFunctionOutput>(
      output,
      this.output,
      'AgentSessionToolResultInput.output',
    ),
    clearOutput:
        clearOutput ??
        (identical(output, unsetCopyWithValue)
            ? this.clearOutput
            : output == null),
    success: success ?? this.success,
    turnId: turnId ?? this.turnId,
  );
}
