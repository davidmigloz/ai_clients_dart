import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// Which binding check removed a dropped thinking block.
///
/// A block that would fail several checks reports one reason, in this
/// order of precedence: [organizationBindingMismatch],
/// [endUserBindingMismatch], [modelBindingMismatch], [prefixBindingMismatch].
enum InputTransformationReason {
  /// It was created by a model whose reasoning the requested model may not
  /// read.
  modelBindingMismatch('model_binding_mismatch'),

  /// The conversation before it differs from the conversation it was
  /// created in (the rest of that turn's consecutive thinking blocks are
  /// removed with it, each with this reason).
  prefixBindingMismatch('prefix_binding_mismatch'),

  /// It was created under a different organization (an Anthropic
  /// organization, AWS account or Google Cloud project) and this
  /// organization is not one of its additional organizations.
  organizationBindingMismatch('organization_binding_mismatch'),

  /// It was created for a different end user, or was removed by the
  /// consumer-organization binding.
  endUserBindingMismatch('end_user_binding_mismatch'),

  /// An unrecognized reason value. Forward-compatible fallback.
  unknown('unknown');

  const InputTransformationReason(this.value);

  /// The wire value for this reason.
  final String value;

  /// Creates an [InputTransformationReason] from a JSON string.
  ///
  /// Unrecognized values map to [unknown] (response-side enum).
  static InputTransformationReason fromJson(String json) => switch (json) {
    'model_binding_mismatch' => InputTransformationReason.modelBindingMismatch,
    'prefix_binding_mismatch' =>
      InputTransformationReason.prefixBindingMismatch,
    'organization_binding_mismatch' =>
      InputTransformationReason.organizationBindingMismatch,
    'end_user_binding_mismatch' =>
      InputTransformationReason.endUserBindingMismatch,
    _ => InputTransformationReason.unknown,
  };

  /// Converts to a JSON string.
  String toJson() => value;
}

/// A change the API made to a request's input before showing it to the
/// model.
///
/// One entry per change, in request order. Present only with
/// `anthropic-beta: thinking-binding-controls-2026-08-01`. Ignore types you
/// do not recognize — more entry types may be added over time.
sealed class InputTransformation {
  const InputTransformation();

  /// Creates an [InputTransformation] from JSON, dispatching on `type`.
  factory InputTransformation.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'thinking_dropped' => ThinkingDroppedInputTransformation.fromJson(json),
      _ => UnknownInputTransformation.fromJson(json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A `thinking`, `redacted_thinking` or `connector_text` block that was
/// removed from the prompt instead of being shown to the model because it
/// failed a binding check.
///
/// Dropped blocks are not billed: they contribute nothing to
/// `usage.input_tokens`.
@immutable
class ThinkingDroppedInputTransformation extends InputTransformation {
  /// Always `thinking_dropped` for this entry type.
  static const String type = 'thinking_dropped';

  /// Where the removed block was in the request, as
  /// `messages.{i}.content.{j}`: `i` indexes the `messages` array sent and
  /// `j` that message's `content` array — the same form error messages use.
  final String path;

  /// Which binding check removed the block.
  final InputTransformationReason reason;

  /// Creates a [ThinkingDroppedInputTransformation].
  const ThinkingDroppedInputTransformation({
    required this.path,
    required this.reason,
  });

  /// Creates a [ThinkingDroppedInputTransformation] from JSON.
  factory ThinkingDroppedInputTransformation.fromJson(
    Map<String, dynamic> json,
  ) {
    final path = json['path'];
    if (path == null) {
      throw const FormatException(
        'ThinkingDroppedInputTransformation: missing required "path"',
      );
    }
    final reason = json['reason'];
    if (reason == null) {
      throw const FormatException(
        'ThinkingDroppedInputTransformation: missing required "reason"',
      );
    }
    return ThinkingDroppedInputTransformation(
      path: path as String,
      reason: InputTransformationReason.fromJson(reason as String),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'path': path,
    'reason': reason.toJson(),
  };

  /// Creates a copy with replaced values.
  ThinkingDroppedInputTransformation copyWith({
    String? path,
    InputTransformationReason? reason,
  }) {
    return ThinkingDroppedInputTransformation(
      path: path ?? this.path,
      reason: reason ?? this.reason,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThinkingDroppedInputTransformation &&
          runtimeType == other.runtimeType &&
          path == other.path &&
          reason == other.reason;

  @override
  int get hashCode => Object.hash(path, reason);

  @override
  String toString() =>
      'ThinkingDroppedInputTransformation(path: $path, reason: $reason)';
}

/// An unrecognized input transformation entry.
///
/// Preserves the raw JSON so it can round-trip unchanged. Per the spec,
/// unrecognized transformation types should be ignored rather than treated
/// as errors.
@immutable
class UnknownInputTransformation extends InputTransformation {
  /// The raw JSON for this unknown input transformation.
  ///
  /// Stored deeply unmodifiable (nested maps and lists are frozen too) so
  /// this instance's [hashCode] and serialized output cannot change after
  /// construction.
  final Map<String, dynamic> raw;

  /// Creates an [UnknownInputTransformation].
  UnknownInputTransformation({required Map<String, dynamic> raw})
    : raw = deepUnmodifiableMap(raw);

  /// Creates an [UnknownInputTransformation] from JSON.
  factory UnknownInputTransformation.fromJson(Map<String, dynamic> json) {
    return UnknownInputTransformation(raw: json);
  }

  /// The `type` discriminator of the unrecognized entry.
  String get type => raw['type'] as String? ?? 'unknown';

  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownInputTransformation &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => mapDeepHashCode(raw);

  @override
  String toString() => 'UnknownInputTransformation(raw: ${raw.length} entries)';
}
