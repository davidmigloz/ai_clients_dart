import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../common/keep_alive.dart';
import '_system_one_helpers.dart';
import 'system_one_content.dart';
import 'system_one_question.dart';

/// Request for the System One decision API, available in Ollama v0.35.0+.
///
/// Each question is evaluated independently against the shared state and full
/// question schema. The server validates limits and never truncates input.
/// Cloud models can be used through a signed-in local server (v0.40.5+) with a
/// `:cloud` model name, or directly with a client configured for `ollama.com`.
@immutable
class SystemOneRequest {
  /// Creates a request and copies its ordered question map.
  SystemOneRequest({
    required this.model,
    required this.state,
    required Map<String, SystemOneQuestion> questions,
    this.runner,
    List<String>? images,
    this.keepAlive,
  }) : questions = Map.unmodifiable(questions),
       images = images == null ? null : List.unmodifiable(images);

  /// Compatible decision model, such as `nimble`, `clef`, or `clef:cloud`.
  final String model;

  /// Runner variant to select from a local model's manifest list.
  final String? runner;

  /// Shared text or structured JSON context.
  final SystemOneContent state;

  /// Base64-encoded images shared by all questions, in request order.
  ///
  /// Models with vision (such as Clef) accept PNG, JPEG, or WebP images.
  /// Models with audio input also accept WAV clips here. URLs and data URLs
  /// are not supported. Local image support requires Ollama v0.40.0+.
  /// Cloud image and request limits are validated by the server.
  final List<String>? images;

  /// Named questions in their supplied order; the server requires 1–64.
  ///
  /// Cloud names allow up to 100 ASCII letters, digits, `_`, `.`, or `-`.
  final Map<String, SystemOneQuestion> questions;

  /// How long to keep the model loaded after the request.
  final KeepAlive? keepAlive;

  /// Creates a request from JSON, validating field shapes.
  factory SystemOneRequest.fromJson(Map<String, dynamic> json) {
    final questions = systemOneObject(
      json['questions'],
      'SystemOneRequest.questions',
    );
    final keepAlive = json['keep_alive'];
    final images = json['images'];
    if (images != null && images is! List<Object?>) {
      throw const FormatException('SystemOneRequest.images must be an array');
    }
    if (keepAlive != null && keepAlive is! String && keepAlive is! num) {
      throw const FormatException(
        'SystemOneRequest.keep_alive must be a string or number',
      );
    }
    return SystemOneRequest(
      model: systemOneString(json['model'], 'SystemOneRequest.model'),
      runner: json['runner'] == null
          ? null
          : systemOneString(json['runner'], 'SystemOneRequest.runner'),
      state: SystemOneContent.fromJson(
        json['state'],
        context: 'SystemOneRequest.state',
      ),
      images: images == null
          ? null
          : [
              for (var i = 0; i < (images as List<Object?>).length; i++)
                systemOneString(images[i], 'SystemOneRequest.images[$i]'),
            ],
      questions: {
        for (final entry in questions.entries)
          entry.key: SystemOneQuestion.fromJson(
            systemOneObject(
              entry.value,
              'SystemOneRequest.questions.${entry.key}',
            ),
          ),
      },
      keepAlive: KeepAlive.fromJson(keepAlive),
    );
  }

  /// Converts to JSON without sorting question or choice keys.
  Map<String, dynamic> toJson() => {
    'model': model,
    if (runner != null) 'runner': runner,
    'state': state.toJson(),
    if (images != null) 'images': images,
    'questions': {
      for (final entry in questions.entries) entry.key: entry.value.toJson(),
    },
    if (keepAlive != null) 'keep_alive': keepAlive!.toJson(),
  };

  /// Creates a copy; passing null clears an optional setting.
  SystemOneRequest copyWith({
    String? model,
    SystemOneContent? state,
    Map<String, SystemOneQuestion>? questions,
    Object? runner = unsetCopyWithValue,
    Object? images = unsetCopyWithValue,
    Object? keepAlive = unsetCopyWithValue,
  }) => SystemOneRequest(
    model: model ?? this.model,
    runner: identical(runner, unsetCopyWithValue)
        ? this.runner
        : runner as String?,
    state: state ?? this.state,
    images: identical(images, unsetCopyWithValue)
        ? this.images
        : images as List<String>?,
    questions: questions ?? this.questions,
    keepAlive: keepAlive == unsetCopyWithValue
        ? this.keepAlive
        : keepAlive as KeepAlive?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemOneRequest &&
          model == other.model &&
          runner == other.runner &&
          state == other.state &&
          listsEqual(images, other.images) &&
          systemOneOrderedMapsEqual(questions, other.questions) &&
          keepAlive == other.keepAlive;

  @override
  int get hashCode => Object.hash(
    model,
    runner,
    state,
    listHash(images),
    systemOneOrderedMapHash(questions),
    keepAlive,
  );

  @override
  String toString() =>
      'SystemOneRequest(model: $model, runner: $runner, state: $state, '
      'images: ${images == null ? null : '${images!.length} items'}, '
      'questions: ${questions.length} entries, keepAlive: $keepAlive)';
}
