import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../common/keep_alive.dart';
import '../common/response_format.dart';
import '../common/think_value.dart';
import '../metadata/model_options.dart';

/// Request for text generation.
@immutable
class GenerateRequest {
  /// Model name.
  final String model;

  /// Text for the model to generate a response from.
  final String? prompt;

  /// Text that appears after the prompt (for fill-in-the-middle).
  final String? suffix;

  /// Base64-encoded images for multimodal models.
  final List<String>? images;

  /// Structured output format.
  ///
  /// Use [ResponseFormat.json] for JSON mode or [ResponseFormat.schema] for
  /// structured output with a specific JSON schema.
  final ResponseFormat? format;

  /// System prompt for the model.
  final String? system;

  /// Override the model's default prompt template.
  ///
  /// Use this to customize how the prompt is formatted before sending
  /// to the model.
  final String? template;

  /// Conversation context from a previous generate response.
  ///
  /// This enables multi-turn conversations by passing the context
  /// from a previous response into the next request.
  final List<int>? context;

  /// Whether to stream the response.
  final bool? stream;

  /// Enable thinking mode.
  ///
  /// Use [ThinkValue.enabled] for boolean or [ThinkValue.level] for levels.
  final ThinkValue? think;

  /// Whether to skip prompt templating.
  final bool? raw;

  /// Model keep-alive duration (e.g., `5m`, `0`).
  final KeepAlive? keepAlive;

  /// Runtime options for generation.
  final ModelOptions? options;

  /// Whether to return log probabilities.
  final bool? logprobs;

  /// Number of most likely tokens to return at each position.
  final int? topLogprobs;

  /// Width of the generated image in pixels.
  ///
  /// Experimental: only used by image generation models, and may change or be
  /// removed in a future Ollama release.
  final int? width;

  /// Height of the generated image in pixels.
  ///
  /// Experimental: only used by image generation models, and may change or be
  /// removed in a future Ollama release.
  final int? height;

  /// Number of diffusion steps for image generation.
  ///
  /// Experimental: only used by image generation models, and may change or be
  /// removed in a future Ollama release.
  final int? steps;

  /// Creates a [GenerateRequest].
  const GenerateRequest({
    required this.model,
    this.prompt,
    this.suffix,
    this.images,
    this.format,
    this.system,
    this.template,
    this.context,
    this.stream,
    this.think,
    this.raw,
    this.keepAlive,
    this.options,
    this.logprobs,
    this.topLogprobs,
    this.width,
    this.height,
    this.steps,
  });

  /// Creates a [GenerateRequest] from JSON.
  factory GenerateRequest.fromJson(Map<String, dynamic> json) =>
      GenerateRequest(
        model: json['model'] as String,
        prompt: json['prompt'] as String?,
        suffix: json['suffix'] as String?,
        images: (json['images'] as List?)?.cast<String>(),
        format: ResponseFormat.fromJson(json['format']),
        system: json['system'] as String?,
        template: json['template'] as String?,
        context: (json['context'] as List?)?.cast<int>(),
        stream: json['stream'] as bool?,
        think: ThinkValue.fromJson(json['think']),
        raw: json['raw'] as bool?,
        keepAlive: KeepAlive.fromJson(json['keep_alive']),
        options: json['options'] != null
            ? ModelOptions.fromJson(json['options'] as Map<String, dynamic>)
            : null,
        logprobs: json['logprobs'] as bool?,
        topLogprobs: json['top_logprobs'] as int?,
        width: json['width'] as int?,
        height: json['height'] as int?,
        steps: json['steps'] as int?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'model': model,
    if (prompt != null) 'prompt': prompt,
    if (suffix != null) 'suffix': suffix,
    if (images != null) 'images': images,
    if (format != null) 'format': format!.toJson(),
    if (system != null) 'system': system,
    if (template != null) 'template': template,
    if (context != null) 'context': context,
    if (stream != null) 'stream': stream,
    if (think != null) 'think': think!.toJson(),
    if (raw != null) 'raw': raw,
    if (keepAlive != null) 'keep_alive': keepAlive!.toJson(),
    if (options != null) 'options': options!.toJson(),
    if (logprobs != null) 'logprobs': logprobs,
    if (topLogprobs != null) 'top_logprobs': topLogprobs,
    if (width != null) 'width': width,
    if (height != null) 'height': height,
    if (steps != null) 'steps': steps,
  };

  /// Creates a copy with replaced values.
  GenerateRequest copyWith({
    String? model,
    Object? prompt = unsetCopyWithValue,
    Object? suffix = unsetCopyWithValue,
    Object? images = unsetCopyWithValue,
    Object? format = unsetCopyWithValue,
    Object? system = unsetCopyWithValue,
    Object? template = unsetCopyWithValue,
    Object? context = unsetCopyWithValue,
    Object? stream = unsetCopyWithValue,
    Object? think = unsetCopyWithValue,
    Object? raw = unsetCopyWithValue,
    Object? keepAlive = unsetCopyWithValue,
    Object? options = unsetCopyWithValue,
    Object? logprobs = unsetCopyWithValue,
    Object? topLogprobs = unsetCopyWithValue,
    Object? width = unsetCopyWithValue,
    Object? height = unsetCopyWithValue,
    Object? steps = unsetCopyWithValue,
  }) {
    return GenerateRequest(
      model: model ?? this.model,
      prompt: prompt == unsetCopyWithValue ? this.prompt : prompt as String?,
      suffix: suffix == unsetCopyWithValue ? this.suffix : suffix as String?,
      images: images == unsetCopyWithValue
          ? this.images
          : images as List<String>?,
      format: format == unsetCopyWithValue
          ? this.format
          : format as ResponseFormat?,
      system: system == unsetCopyWithValue ? this.system : system as String?,
      template: template == unsetCopyWithValue
          ? this.template
          : template as String?,
      context: context == unsetCopyWithValue
          ? this.context
          : context as List<int>?,
      stream: stream == unsetCopyWithValue ? this.stream : stream as bool?,
      think: think == unsetCopyWithValue ? this.think : think as ThinkValue?,
      raw: raw == unsetCopyWithValue ? this.raw : raw as bool?,
      keepAlive: keepAlive == unsetCopyWithValue
          ? this.keepAlive
          : keepAlive as KeepAlive?,
      options: options == unsetCopyWithValue
          ? this.options
          : options as ModelOptions?,
      logprobs: logprobs == unsetCopyWithValue
          ? this.logprobs
          : logprobs as bool?,
      topLogprobs: topLogprobs == unsetCopyWithValue
          ? this.topLogprobs
          : topLogprobs as int?,
      width: width == unsetCopyWithValue ? this.width : width as int?,
      height: height == unsetCopyWithValue ? this.height : height as int?,
      steps: steps == unsetCopyWithValue ? this.steps : steps as int?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenerateRequest &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          prompt == other.prompt &&
          suffix == other.suffix &&
          listsEqual(images, other.images) &&
          format == other.format &&
          system == other.system &&
          template == other.template &&
          listsEqual(context, other.context) &&
          stream == other.stream &&
          think == other.think &&
          raw == other.raw &&
          keepAlive == other.keepAlive &&
          options == other.options &&
          logprobs == other.logprobs &&
          topLogprobs == other.topLogprobs &&
          width == other.width &&
          height == other.height &&
          steps == other.steps;

  @override
  int get hashCode => Object.hashAll([
    model,
    prompt,
    suffix,
    listHash(images),
    format,
    system,
    template,
    listHash(context),
    stream,
    think,
    raw,
    keepAlive,
    options,
    logprobs,
    topLogprobs,
    width,
    height,
    steps,
  ]);

  @override
  String toString() =>
      'GenerateRequest('
      'model: $model, '
      'prompt: $prompt, '
      'suffix: $suffix, '
      'images: $images, '
      'format: $format, '
      'system: $system, '
      'template: $template, '
      'context: $context, '
      'stream: $stream, '
      'think: $think, '
      'raw: $raw, '
      'keepAlive: $keepAlive, '
      'options: $options, '
      'logprobs: $logprobs, '
      'topLogprobs: $topLogprobs, '
      'width: $width, '
      'height: $height, '
      'steps: $steps)';
}
