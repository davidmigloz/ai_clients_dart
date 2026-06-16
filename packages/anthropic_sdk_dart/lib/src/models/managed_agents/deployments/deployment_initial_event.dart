import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import '../outcomes/rubric.dart';

/// An event sent to a session immediately after it is created (response side).
///
/// Supports `user.message`, `user.define_outcome`, and `system.message`.
///
/// Variants:
/// - [DeploymentUserMessageEvent] — A user message (type: "user.message")
/// - [DeploymentUserDefineOutcomeEvent] — An outcome the agent works toward
///   (type: "user.define_outcome")
/// - [DeploymentSystemMessageEvent] — A mid-conversation system message
///   (type: "system.message")
/// - [UnknownDeploymentInitialEvent] — Unrecognized type (preserves raw JSON)
sealed class DeploymentInitialEvent {
  const DeploymentInitialEvent();

  /// Creates a [DeploymentInitialEvent] from JSON.
  factory DeploymentInitialEvent.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'user.message' => DeploymentUserMessageEvent.fromJson(json),
      'user.define_outcome' => DeploymentUserDefineOutcomeEvent.fromJson(json),
      'system.message' => DeploymentSystemMessageEvent.fromJson(json),
      _ => UnknownDeploymentInitialEvent(rawJson: json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A user message sent to the session.
@immutable
class DeploymentUserMessageEvent extends DeploymentInitialEvent {
  /// The event type, always 'user.message'.
  String get type => 'user.message';

  /// Array of content blocks for the user message.
  final List<Map<String, dynamic>> content;

  /// Creates a [DeploymentUserMessageEvent].
  const DeploymentUserMessageEvent({required this.content});

  /// Creates a [DeploymentUserMessageEvent] from JSON.
  factory DeploymentUserMessageEvent.fromJson(Map<String, dynamic> json) {
    return DeploymentUserMessageEvent(
      content: (json['content'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'content': content};

  /// Creates a copy with replaced values.
  DeploymentUserMessageEvent copyWith({List<Map<String, dynamic>>? content}) {
    return DeploymentUserMessageEvent(content: content ?? this.content);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeploymentUserMessageEvent &&
          runtimeType == other.runtimeType &&
          listOfMapsDeepEqual(content, other.content);

  @override
  int get hashCode => listOfMapsHashCode(content);

  @override
  String toString() => 'DeploymentUserMessageEvent(content: $content)';
}

/// An outcome the agent should work toward. The agent begins work on receipt.
@immutable
class DeploymentUserDefineOutcomeEvent extends DeploymentInitialEvent {
  /// The event type, always 'user.define_outcome'.
  String get type => 'user.define_outcome';

  /// What the agent should produce. This is the task specification.
  final String description;

  /// How to grade the outcome. Text or file reference.
  final Rubric rubric;

  /// Eval→revision cycles before giving up. Default 3, max 20.
  final int? maxIterations;

  /// Creates a [DeploymentUserDefineOutcomeEvent].
  const DeploymentUserDefineOutcomeEvent({
    required this.description,
    required this.rubric,
    this.maxIterations,
  });

  /// Creates a [DeploymentUserDefineOutcomeEvent] from JSON.
  factory DeploymentUserDefineOutcomeEvent.fromJson(Map<String, dynamic> json) {
    return DeploymentUserDefineOutcomeEvent(
      description: json['description'] as String,
      rubric: Rubric.fromJson(json['rubric'] as Map<String, dynamic>),
      maxIterations: json['max_iterations'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'description': description,
    'rubric': rubric.toJson(),
    if (maxIterations != null) 'max_iterations': maxIterations,
  };

  /// Creates a copy with replaced values.
  DeploymentUserDefineOutcomeEvent copyWith({
    String? description,
    Rubric? rubric,
    Object? maxIterations = unsetCopyWithValue,
  }) {
    return DeploymentUserDefineOutcomeEvent(
      description: description ?? this.description,
      rubric: rubric ?? this.rubric,
      maxIterations: maxIterations == unsetCopyWithValue
          ? this.maxIterations
          : maxIterations as int?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeploymentUserDefineOutcomeEvent &&
          runtimeType == other.runtimeType &&
          description == other.description &&
          rubric == other.rubric &&
          maxIterations == other.maxIterations;

  @override
  int get hashCode => Object.hash(description, rubric, maxIterations);

  @override
  String toString() =>
      'DeploymentUserDefineOutcomeEvent(description: $description, '
      'rubric: $rubric, maxIterations: $maxIterations)';
}

/// A mid-conversation system message.
///
/// Privileged context for the accompanying turn and all subsequent turns,
/// appended to the session's system context as a `role: "system"` turn rather
/// than replacing the top-level system prompt.
@immutable
class DeploymentSystemMessageEvent extends DeploymentInitialEvent {
  /// The event type, always 'system.message'.
  String get type => 'system.message';

  /// System content blocks to append. Text-only.
  final List<Map<String, dynamic>> content;

  /// Creates a [DeploymentSystemMessageEvent].
  const DeploymentSystemMessageEvent({required this.content});

  /// Creates a [DeploymentSystemMessageEvent] from JSON.
  factory DeploymentSystemMessageEvent.fromJson(Map<String, dynamic> json) {
    return DeploymentSystemMessageEvent(
      content: (json['content'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'content': content};

  /// Creates a copy with replaced values.
  DeploymentSystemMessageEvent copyWith({List<Map<String, dynamic>>? content}) {
    return DeploymentSystemMessageEvent(content: content ?? this.content);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeploymentSystemMessageEvent &&
          runtimeType == other.runtimeType &&
          listOfMapsDeepEqual(content, other.content);

  @override
  int get hashCode => listOfMapsHashCode(content);

  @override
  String toString() => 'DeploymentSystemMessageEvent(content: $content)';
}

/// Unrecognized deployment initial event type (preserves raw JSON).
@immutable
class UnknownDeploymentInitialEvent extends DeploymentInitialEvent {
  /// The raw JSON data.
  final Map<String, dynamic> rawJson;

  /// Creates an [UnknownDeploymentInitialEvent].
  const UnknownDeploymentInitialEvent({required this.rawJson});

  /// Creates an [UnknownDeploymentInitialEvent] from JSON.
  factory UnknownDeploymentInitialEvent.fromJson(Map<String, dynamic> json) {
    return UnknownDeploymentInitialEvent(rawJson: json);
  }

  @override
  Map<String, dynamic> toJson() => rawJson;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownDeploymentInitialEvent &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownDeploymentInitialEvent(rawJson: $rawJson)';
}
