import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import '../moderations/completion_moderation.dart';

/// Moderation results or errors for the request input and generated output of
/// a Chat Completions response.
///
/// Present on `ChatCompletion.moderation` and `ChatStreamEvent.moderation`
/// when moderated completions were requested via [ModerationConfig].
@immutable
class ChatCompletionModeration {
  /// Creates a [ChatCompletionModeration].
  const ChatCompletionModeration({required this.input, required this.output});

  /// Creates a [ChatCompletionModeration] from JSON.
  factory ChatCompletionModeration.fromJson(Map<String, dynamic> json) {
    return ChatCompletionModeration(
      input: ChatCompletionModerationOutcome.fromJson(
        json['input'] as Map<String, dynamic>,
      ),
      output: ChatCompletionModerationOutcome.fromJson(
        json['output'] as Map<String, dynamic>,
      ),
    );
  }

  /// Moderation for the request input.
  final ChatCompletionModerationOutcome input;

  /// Moderation for the generated output.
  final ChatCompletionModerationOutcome output;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'input': input.toJson(),
    'output': output.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  ChatCompletionModeration copyWith({
    ChatCompletionModerationOutcome? input,
    ChatCompletionModerationOutcome? output,
  }) => ChatCompletionModeration(
    input: input ?? this.input,
    output: output ?? this.output,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatCompletionModeration &&
          runtimeType == other.runtimeType &&
          input == other.input &&
          output == other.output;

  @override
  int get hashCode => Object.hash(input, output);

  @override
  String toString() =>
      'ChatCompletionModeration(input: $input, output: $output)';
}

/// A Chat Completions moderation outcome for a single input or output.
///
/// Either successful [ChatCompletionModerationResults] or a
/// [ChatCompletionModerationError], discriminated by the `type` field.
@immutable
sealed class ChatCompletionModerationOutcome {
  /// Creates a [ChatCompletionModerationOutcome].
  const ChatCompletionModerationOutcome();

  /// Creates a [ChatCompletionModerationOutcome] from JSON, dispatching on
  /// `type`.
  factory ChatCompletionModerationOutcome.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'moderation_results' => ChatCompletionModerationResults.fromJson(json),
      'error' => ChatCompletionModerationError.fromJson(json),
      _ => throw FormatException(
        'Unknown chat completion moderation outcome type: $type',
      ),
    };
  }

  /// The discriminator type for this outcome.
  String get type;

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Successful moderation results for the request input or generated output.
@immutable
class ChatCompletionModerationResults extends ChatCompletionModerationOutcome {
  /// Creates a [ChatCompletionModerationResults].
  const ChatCompletionModerationResults({
    required this.model,
    required this.results,
  });

  /// Creates a [ChatCompletionModerationResults] from JSON.
  factory ChatCompletionModerationResults.fromJson(Map<String, dynamic> json) {
    return ChatCompletionModerationResults(
      model: json['model'] as String,
      results: (json['results'] as List)
          .map((e) => ModerationResultBody.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  String get type => 'moderation_results';

  /// The moderation model used to generate the results.
  final String model;

  /// A list of moderation results.
  final List<ModerationResultBody> results;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'model': model,
    'results': results.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  ChatCompletionModerationResults copyWith({
    String? model,
    List<ModerationResultBody>? results,
  }) => ChatCompletionModerationResults(
    model: model ?? this.model,
    results: results ?? this.results,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatCompletionModerationResults &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          listsEqual(results, other.results);

  @override
  int get hashCode => Object.hash(model, Object.hashAll(results));

  @override
  String toString() =>
      'ChatCompletionModerationResults(model: $model, results: $results)';
}

/// An error produced while attempting moderation for a Chat Completions input
/// or output.
@immutable
class ChatCompletionModerationError extends ChatCompletionModerationOutcome {
  /// Creates a [ChatCompletionModerationError].
  const ChatCompletionModerationError({
    required this.code,
    required this.message,
  });

  /// Creates a [ChatCompletionModerationError] from JSON.
  factory ChatCompletionModerationError.fromJson(Map<String, dynamic> json) {
    return ChatCompletionModerationError(
      code: json['code'] as String,
      message: json['message'] as String,
    );
  }

  @override
  String get type => 'error';

  /// The error code.
  final String code;

  /// The error message.
  final String message;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'code': code,
    'message': message,
  };

  /// Creates a copy with the given fields replaced.
  ChatCompletionModerationError copyWith({String? code, String? message}) =>
      ChatCompletionModerationError(
        code: code ?? this.code,
        message: message ?? this.message,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatCompletionModerationError &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          message == other.message;

  @override
  int get hashCode => Object.hash(code, message);

  @override
  String toString() =>
      'ChatCompletionModerationError(code: $code, message: $message)';
}
