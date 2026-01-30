import 'package:meta/meta.dart';

/// Data source configuration for an evaluation run.
///
/// Defines where the evaluation data comes from for a specific run.
/// Available types:
/// - [JsonlRunDataSource] - JSONL file-based data
/// - [CompletionsRunDataSource] - Data from completions
/// - [ResponsesRunDataSource] - Data from responses with model sampling
@immutable
sealed class EvalRunDataSource {
  const EvalRunDataSource();

  /// Creates an [EvalRunDataSource] from JSON.
  factory EvalRunDataSource.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'jsonl' => JsonlRunDataSource.fromJson(json),
      'completions' => CompletionsRunDataSource.fromJson(json),
      'responses' => ResponsesRunDataSource.fromJson(json),
      _ => throw FormatException('Unknown run data source type: $type'),
    };
  }

  /// Creates a JSONL run data source from a file ID.
  static JsonlRunDataSource jsonlFile(String fileId) {
    return JsonlRunDataSource(source: JsonlSource.file(fileId));
  }

  /// Creates a JSONL run data source from file content.
  static JsonlRunDataSource jsonlContent(List<Map<String, dynamic>> content) {
    return JsonlRunDataSource(source: JsonlSource.content(content));
  }

  /// Creates a completions run data source.
  static CompletionsRunDataSource completions({
    required CompletionsSource source,
    String? model,
    InputMessages? inputMessages,
    EvalSamplingParams? samplingParams,
  }) {
    return CompletionsRunDataSource(
      source: source,
      model: model,
      inputMessages: inputMessages,
      samplingParams: samplingParams,
    );
  }

  /// Creates a responses run data source.
  static ResponsesRunDataSource responses({
    required ResponsesSource source,
    String? model,
    InputMessages? inputMessages,
    EvalSamplingParams? samplingParams,
  }) {
    return ResponsesRunDataSource(
      source: source,
      model: model,
      inputMessages: inputMessages,
      samplingParams: samplingParams,
    );
  }

  /// The type of run data source.
  String get type;

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// JSONL file-based data source for evaluation runs.
@immutable
class JsonlRunDataSource extends EvalRunDataSource {
  /// Creates a [JsonlRunDataSource].
  const JsonlRunDataSource({required this.source});

  /// Creates a [JsonlRunDataSource] from JSON.
  factory JsonlRunDataSource.fromJson(Map<String, dynamic> json) {
    return JsonlRunDataSource(
      source: JsonlSource.fromJson(json['source'] as Map<String, dynamic>),
    );
  }

  /// The source of the JSONL data.
  final JsonlSource source;

  @override
  String get type => 'jsonl';

  @override
  Map<String, dynamic> toJson() => {'type': type, 'source': source.toJson()};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JsonlRunDataSource && runtimeType == other.runtimeType;

  @override
  int get hashCode => source.hashCode;

  @override
  String toString() => 'JsonlRunDataSource(source: $source)';
}

/// Source for JSONL data.
@immutable
sealed class JsonlSource {
  const JsonlSource();

  /// Creates a [JsonlSource] from JSON.
  factory JsonlSource.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'file_id' => JsonlFileSource.fromJson(json),
      'file_content' => JsonlContentSource.fromJson(json),
      _ => throw FormatException('Unknown JSONL source type: $type'),
    };
  }

  /// Creates a file-based JSONL source.
  static JsonlFileSource file(String fileId) => JsonlFileSource(fileId: fileId);

  /// Creates a content-based JSONL source.
  static JsonlContentSource content(List<Map<String, dynamic>> content) =>
      JsonlContentSource(content: content);

  /// The type of source.
  String get type;

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// JSONL source from a file ID.
@immutable
class JsonlFileSource extends JsonlSource {
  /// Creates a [JsonlFileSource].
  const JsonlFileSource({required this.fileId});

  /// Creates a [JsonlFileSource] from JSON.
  factory JsonlFileSource.fromJson(Map<String, dynamic> json) {
    return JsonlFileSource(fileId: json['file_id'] as String);
  }

  /// The ID of the uploaded JSONL file.
  final String fileId;

  @override
  String get type => 'file_id';

  @override
  Map<String, dynamic> toJson() => {'type': type, 'file_id': fileId};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JsonlFileSource &&
          runtimeType == other.runtimeType &&
          fileId == other.fileId;

  @override
  int get hashCode => fileId.hashCode;

  @override
  String toString() => 'JsonlFileSource(fileId: $fileId)';
}

/// JSONL source from inline content.
@immutable
class JsonlContentSource extends JsonlSource {
  /// Creates a [JsonlContentSource].
  const JsonlContentSource({required this.content});

  /// Creates a [JsonlContentSource] from JSON.
  factory JsonlContentSource.fromJson(Map<String, dynamic> json) {
    return JsonlContentSource(
      content: (json['content'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
    );
  }

  /// The inline JSONL content.
  final List<Map<String, dynamic>> content;

  @override
  String get type => 'file_content';

  @override
  Map<String, dynamic> toJson() => {'type': type, 'content': content};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JsonlContentSource && runtimeType == other.runtimeType;

  @override
  int get hashCode => content.length.hashCode;

  @override
  String toString() => 'JsonlContentSource(${content.length} items)';
}

/// Completions-based data source for evaluation runs.
@immutable
class CompletionsRunDataSource extends EvalRunDataSource {
  /// Creates a [CompletionsRunDataSource].
  const CompletionsRunDataSource({
    required this.source,
    this.model,
    this.inputMessages,
    this.samplingParams,
  });

  /// Creates a [CompletionsRunDataSource] from JSON.
  factory CompletionsRunDataSource.fromJson(Map<String, dynamic> json) {
    return CompletionsRunDataSource(
      source: CompletionsSource.fromJson(
        json['source'] as Map<String, dynamic>,
      ),
      model: json['model'] as String?,
      inputMessages: json['input_messages'] != null
          ? InputMessages.fromJson(
              json['input_messages'] as Map<String, dynamic>,
            )
          : null,
      samplingParams: json['sampling_params'] != null
          ? EvalSamplingParams.fromJson(
              json['sampling_params'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// The source for completions data.
  final CompletionsSource source;

  /// The model to use for generating completions.
  final String? model;

  /// Input messages configuration for model sampling.
  ///
  /// Use [InputMessages.template] to define messages with template variables,
  /// or [InputMessages.itemReference] for pre-built message trajectories.
  final InputMessages? inputMessages;

  /// Parameters for model sampling.
  final EvalSamplingParams? samplingParams;

  @override
  String get type => 'completions';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'source': source.toJson(),
    if (model != null) 'model': model,
    if (inputMessages != null) 'input_messages': inputMessages!.toJson(),
    if (samplingParams != null) 'sampling_params': samplingParams!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompletionsRunDataSource && runtimeType == other.runtimeType;

  @override
  int get hashCode => Object.hash(source, model);

  @override
  String toString() => 'CompletionsRunDataSource(model: $model)';
}

/// Source for completions data.
@immutable
sealed class CompletionsSource {
  const CompletionsSource();

  /// Creates a [CompletionsSource] from JSON.
  factory CompletionsSource.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'file_id' => CompletionsFileSource.fromJson(json),
      'file_content' => CompletionsContentSource.fromJson(json),
      'stored_completions' => StoredCompletionsSource.fromJson(json),
      _ => throw FormatException('Unknown completions source type: $type'),
    };
  }

  /// The type of source.
  String get type;

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Completions source from a file.
@immutable
class CompletionsFileSource extends CompletionsSource {
  /// Creates a [CompletionsFileSource].
  const CompletionsFileSource({required this.fileId});

  /// Creates a [CompletionsFileSource] from JSON.
  factory CompletionsFileSource.fromJson(Map<String, dynamic> json) {
    return CompletionsFileSource(fileId: json['file_id'] as String);
  }

  /// The file ID.
  final String fileId;

  @override
  String get type => 'file_id';

  @override
  Map<String, dynamic> toJson() => {'type': type, 'file_id': fileId};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompletionsFileSource &&
          runtimeType == other.runtimeType &&
          fileId == other.fileId;

  @override
  int get hashCode => fileId.hashCode;

  @override
  String toString() => 'CompletionsFileSource(fileId: $fileId)';
}

/// Completions source from inline content.
@immutable
class CompletionsContentSource extends CompletionsSource {
  /// Creates a [CompletionsContentSource].
  const CompletionsContentSource({required this.content});

  /// Creates a [CompletionsContentSource] from JSON.
  factory CompletionsContentSource.fromJson(Map<String, dynamic> json) {
    return CompletionsContentSource(
      content: (json['content'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
    );
  }

  /// The inline content.
  final List<Map<String, dynamic>> content;

  @override
  String get type => 'file_content';

  @override
  Map<String, dynamic> toJson() => {'type': type, 'content': content};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompletionsContentSource && runtimeType == other.runtimeType;

  @override
  int get hashCode => content.length.hashCode;

  @override
  String toString() => 'CompletionsContentSource(${content.length} items)';
}

/// Completions source from stored completions.
@immutable
class StoredCompletionsSource extends CompletionsSource {
  /// Creates a [StoredCompletionsSource].
  const StoredCompletionsSource({this.metadata});

  /// Creates a [StoredCompletionsSource] from JSON.
  factory StoredCompletionsSource.fromJson(Map<String, dynamic> json) {
    return StoredCompletionsSource(
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Metadata filters.
  final Map<String, dynamic>? metadata;

  @override
  String get type => 'stored_completions';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (metadata != null) 'metadata': metadata,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoredCompletionsSource && runtimeType == other.runtimeType;

  @override
  int get hashCode => metadata.hashCode;

  @override
  String toString() => 'StoredCompletionsSource(metadata: $metadata)';
}

/// Responses-based data source for evaluation runs.
///
/// This data source type allows running evaluations with model sampling,
/// where the model generates responses that are then evaluated.
@immutable
class ResponsesRunDataSource extends EvalRunDataSource {
  /// Creates a [ResponsesRunDataSource].
  const ResponsesRunDataSource({
    required this.source,
    this.model,
    this.inputMessages,
    this.samplingParams,
  });

  /// Creates a [ResponsesRunDataSource] from JSON.
  factory ResponsesRunDataSource.fromJson(Map<String, dynamic> json) {
    return ResponsesRunDataSource(
      source: ResponsesSource.fromJson(json['source'] as Map<String, dynamic>),
      model: json['model'] as String?,
      inputMessages: json['input_messages'] != null
          ? InputMessages.fromJson(
              json['input_messages'] as Map<String, dynamic>,
            )
          : null,
      samplingParams: json['sampling_params'] != null
          ? EvalSamplingParams.fromJson(
              json['sampling_params'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// The source for item data (populates the `item` namespace).
  final ResponsesSource source;

  /// The model to use for generating responses.
  final String? model;

  /// Input messages configuration for model sampling.
  ///
  /// Use [InputMessages.template] to define messages with template variables,
  /// or [InputMessages.itemReference] for pre-built message trajectories.
  final InputMessages? inputMessages;

  /// Parameters for model sampling.
  final EvalSamplingParams? samplingParams;

  @override
  String get type => 'responses';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'source': source.toJson(),
    if (model != null) 'model': model,
    if (inputMessages != null) 'input_messages': inputMessages!.toJson(),
    if (samplingParams != null) 'sampling_params': samplingParams!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponsesRunDataSource && runtimeType == other.runtimeType;

  @override
  int get hashCode => Object.hash(source, model);

  @override
  String toString() => 'ResponsesRunDataSource(model: $model)';
}

/// Source for responses data.
@immutable
sealed class ResponsesSource {
  const ResponsesSource();

  /// Creates a [ResponsesSource] from JSON.
  factory ResponsesSource.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'file_id' => ResponsesFileSource.fromJson(json),
      'file_content' => ResponsesContentSource.fromJson(json),
      'responses' => StoredResponsesSource.fromJson(json),
      _ => throw FormatException('Unknown responses source type: $type'),
    };
  }

  /// The type of source.
  String get type;

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Responses source from a file.
@immutable
class ResponsesFileSource extends ResponsesSource {
  /// Creates a [ResponsesFileSource].
  const ResponsesFileSource({required this.fileId});

  /// Creates a [ResponsesFileSource] from JSON.
  factory ResponsesFileSource.fromJson(Map<String, dynamic> json) {
    return ResponsesFileSource(fileId: json['file_id'] as String);
  }

  /// The file ID.
  final String fileId;

  @override
  String get type => 'file_id';

  @override
  Map<String, dynamic> toJson() => {'type': type, 'file_id': fileId};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponsesFileSource &&
          runtimeType == other.runtimeType &&
          fileId == other.fileId;

  @override
  int get hashCode => fileId.hashCode;

  @override
  String toString() => 'ResponsesFileSource(fileId: $fileId)';
}

/// Responses source from inline content.
@immutable
class ResponsesContentSource extends ResponsesSource {
  /// Creates a [ResponsesContentSource].
  const ResponsesContentSource({required this.content});

  /// Creates a [ResponsesContentSource] from JSON.
  factory ResponsesContentSource.fromJson(Map<String, dynamic> json) {
    return ResponsesContentSource(
      content: (json['content'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
    );
  }

  /// The inline content.
  final List<Map<String, dynamic>> content;

  @override
  String get type => 'file_content';

  @override
  Map<String, dynamic> toJson() => {'type': type, 'content': content};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponsesContentSource && runtimeType == other.runtimeType;

  @override
  int get hashCode => content.length.hashCode;

  @override
  String toString() => 'ResponsesContentSource(${content.length} items)';
}

/// Responses source from stored responses.
@immutable
class StoredResponsesSource extends ResponsesSource {
  /// Creates a [StoredResponsesSource].
  const StoredResponsesSource({this.metadata});

  /// Creates a [StoredResponsesSource] from JSON.
  factory StoredResponsesSource.fromJson(Map<String, dynamic> json) {
    return StoredResponsesSource(
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Metadata filters.
  final Map<String, dynamic>? metadata;

  @override
  String get type => 'responses';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (metadata != null) 'metadata': metadata,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoredResponsesSource && runtimeType == other.runtimeType;

  @override
  int get hashCode => metadata.hashCode;

  @override
  String toString() => 'StoredResponsesSource(metadata: $metadata)';
}

/// Input message for model sampling.
@immutable
class InputMessage {
  /// Creates an [InputMessage].
  const InputMessage({required this.role, required this.content});

  /// Creates an [InputMessage] from JSON.
  factory InputMessage.fromJson(Map<String, dynamic> json) {
    return InputMessage(
      role: json['role'] as String,
      content: json['content'] as String,
    );
  }

  /// Creates a system message.
  const InputMessage.system(String content)
    : this(role: 'system', content: content);

  /// Creates a user message.
  const InputMessage.user(String content)
    : this(role: 'user', content: content);

  /// Creates an assistant message.
  const InputMessage.assistant(String content)
    : this(role: 'assistant', content: content);

  /// The role of this message.
  final String role;

  /// The content (can include template variables like `{{item.prompt}}`).
  final String content;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'role': role, 'content': content};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InputMessage &&
          runtimeType == other.runtimeType &&
          role == other.role &&
          content == other.content;

  @override
  int get hashCode => Object.hash(role, content);

  @override
  String toString() => 'InputMessage(role: $role)';
}

/// Input messages configuration for model sampling.
///
/// Determines how messages are structured when calling the model.
/// Can be either a template with messages or a reference to item data.
@immutable
sealed class InputMessages {
  const InputMessages();

  /// Creates an [InputMessages] from JSON.
  factory InputMessages.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'template' => InputMessagesTemplate.fromJson(json),
      'item_reference' => InputMessagesItemReference.fromJson(json),
      _ => throw FormatException('Unknown input messages type: $type'),
    };
  }

  /// Creates a template-based input messages configuration.
  static InputMessagesTemplate template(List<InputMessage> messages) =>
      InputMessagesTemplate(template: messages);

  /// Creates an item reference-based input messages configuration.
  static InputMessagesItemReference itemReference(String reference) =>
      InputMessagesItemReference(itemReference: reference);

  /// The type of input messages configuration.
  String get type;

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Template-based input messages with variable substitution support.
///
/// Use this to define messages that may include template variables like
/// `{{item.input}}` which get substituted with values from each evaluation item.
@immutable
class InputMessagesTemplate extends InputMessages {
  /// Creates an [InputMessagesTemplate].
  const InputMessagesTemplate({required this.template});

  /// Creates an [InputMessagesTemplate] from JSON.
  factory InputMessagesTemplate.fromJson(Map<String, dynamic> json) {
    return InputMessagesTemplate(
      template: (json['template'] as List<dynamic>)
          .map((e) => InputMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// List of messages forming the prompt (may include `{{item.name}}` variables).
  final List<InputMessage> template;

  @override
  String get type => 'template';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'template': template.map((m) => m.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InputMessagesTemplate && runtimeType == other.runtimeType;

  @override
  int get hashCode => template.length.hashCode;

  @override
  String toString() => 'InputMessagesTemplate(${template.length} messages)';
}

/// Item reference-based input messages for pre-built trajectories.
///
/// Use this when your evaluation items already contain complete message
/// trajectories that should be used as-is.
@immutable
class InputMessagesItemReference extends InputMessages {
  /// Creates an [InputMessagesItemReference].
  const InputMessagesItemReference({required this.itemReference});

  /// Creates an [InputMessagesItemReference] from JSON.
  factory InputMessagesItemReference.fromJson(Map<String, dynamic> json) {
    return InputMessagesItemReference(
      itemReference: json['item_reference'] as String,
    );
  }

  /// Reference to a variable in the `item` namespace (e.g., "item.input_trajectory").
  final String itemReference;

  @override
  String get type => 'item_reference';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_reference': itemReference,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InputMessagesItemReference &&
          runtimeType == other.runtimeType &&
          itemReference == other.itemReference;

  @override
  int get hashCode => itemReference.hashCode;

  @override
  String toString() => 'InputMessagesItemReference($itemReference)';
}

/// Sampling parameters for model generation during evaluation.
@immutable
class EvalSamplingParams {
  /// Creates an [EvalSamplingParams].
  const EvalSamplingParams({
    this.maxCompletionsTokens,
    this.temperature,
    this.topP,
    this.seed,
    this.reasoningEffort,
    this.tools,
    this.responseFormat,
  });

  /// Creates an [EvalSamplingParams] from JSON.
  factory EvalSamplingParams.fromJson(Map<String, dynamic> json) {
    return EvalSamplingParams(
      maxCompletionsTokens: json['max_completions_tokens'] as int?,
      temperature: (json['temperature'] as num?)?.toDouble(),
      topP: (json['top_p'] as num?)?.toDouble(),
      seed: json['seed'] as int?,
      reasoningEffort: json['reasoning_effort'] as String?,
      tools: json['tools'] as List<dynamic>?,
      responseFormat: json['response_format'] as Map<String, dynamic>?,
    );
  }

  /// Maximum number of tokens to generate.
  ///
  /// Note: The OpenAI Evals API uses `max_completions_tokens` (with 's')
  /// rather than the standard `max_completion_tokens` parameter name.
  final int? maxCompletionsTokens;

  /// Sampling temperature (0-2).
  final double? temperature;

  /// Top-p (nucleus) sampling parameter.
  final double? topP;

  /// Random seed for reproducibility.
  final int? seed;

  /// Reasoning effort level for reasoning models.
  final String? reasoningEffort;

  /// Tools available to the model.
  final List<dynamic>? tools;

  /// Response format configuration.
  final Map<String, dynamic>? responseFormat;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (maxCompletionsTokens != null)
      'max_completions_tokens': maxCompletionsTokens,
    if (temperature != null) 'temperature': temperature,
    if (topP != null) 'top_p': topP,
    if (seed != null) 'seed': seed,
    if (reasoningEffort != null) 'reasoning_effort': reasoningEffort,
    if (tools != null) 'tools': tools,
    if (responseFormat != null) 'response_format': responseFormat,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvalSamplingParams && runtimeType == other.runtimeType;

  @override
  int get hashCode => Object.hash(maxCompletionsTokens, temperature);

  @override
  String toString() =>
      'EvalSamplingParams(temperature: $temperature, maxTokens: $maxCompletionsTokens)';
}
