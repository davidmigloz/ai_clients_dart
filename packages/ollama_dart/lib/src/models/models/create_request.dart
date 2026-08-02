import 'package:meta/meta.dart';

import '../chat/chat_message.dart';
import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Request to create a model.
@immutable
class CreateRequest {
  /// Name for the model to create.
  final String model;

  /// Existing model to create from.
  final String? from;

  /// Prompt template to use for the model.
  final String? template;

  /// License string or list of licenses for the model.
  ///
  /// Can be a [String] or [List<String>].
  final Object? license;

  /// System prompt to embed in the model.
  final String? system;

  /// Key-value parameters for the model.
  final Map<String, dynamic>? parameters;

  /// Message history to use for the model.
  final List<ChatMessage>? messages;

  /// Quantization level to apply (e.g., `q4_K_M`, `q8_0`).
  final String? quantize;

  /// Name of the renderer for the model (e.g., `qwen3.5`). Selects the
  /// tool-calling prompt renderer.
  final String? renderer;

  /// Name of the parser for the model (e.g., `harmony`). Selects the
  /// tool-calling/thinking output parser.
  final String? parser;

  /// Map of file names to SHA256 digests of blobs to create the model from.
  ///
  /// Sourced from Ollama `api/types.go` + `docs/api.md`; not yet in the
  /// upstream OpenAPI spec.
  final Map<String, String>? files;

  /// Map of LoRA adapter file names to SHA256 digests of blobs.
  ///
  /// Sourced from Ollama `api/types.go` + `docs/api.md`; not yet in the
  /// upstream OpenAPI spec.
  final Map<String, String>? adapters;

  /// Quantization format for the draft model (speculative decoding).
  ///
  /// Sourced from Ollama `api/types.go` + `docs/api.md`; not yet in the
  /// upstream OpenAPI spec.
  final String? draftQuantize;

  /// Map of file names to SHA256 digests for the draft model (speculative
  /// decoding).
  ///
  /// Sourced from Ollama `api/types.go` + `docs/api.md`; not yet in the
  /// upstream OpenAPI spec.
  final Map<String, String>? draftFiles;

  /// URL of the upstream Ollama API for the model, if any.
  ///
  /// Sourced from Ollama `api/types.go` + `docs/api.md`; not yet in the
  /// upstream OpenAPI spec.
  final String? remoteHost;

  /// Minimum version of Ollama required by the model.
  ///
  /// Sourced from Ollama `api/types.go` + `docs/api.md`; not yet in the
  /// upstream OpenAPI spec.
  final String? requires;

  /// Additional information for the model.
  ///
  /// Sourced from Ollama `api/types.go` + `docs/api.md`; not yet in the
  /// upstream OpenAPI spec.
  final Map<String, dynamic>? info;

  /// Stream status updates.
  final bool? stream;

  /// Creates a [CreateRequest].
  const CreateRequest({
    required this.model,
    this.from,
    this.template,
    this.license,
    this.system,
    this.parameters,
    this.messages,
    this.quantize,
    this.renderer,
    this.parser,
    this.files,
    this.adapters,
    this.draftQuantize,
    this.draftFiles,
    this.remoteHost,
    this.requires,
    this.info,
    this.stream,
  });

  /// Creates a [CreateRequest] from JSON.
  factory CreateRequest.fromJson(Map<String, dynamic> json) => CreateRequest(
    model: json['model'] as String,
    from: json['from'] as String?,
    template: json['template'] as String?,
    license: json['license'],
    system: json['system'] as String?,
    parameters: json['parameters'] as Map<String, dynamic>?,
    messages: (json['messages'] as List?)
        ?.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList(),
    quantize: json['quantize'] as String?,
    renderer: json['renderer'] as String?,
    parser: json['parser'] as String?,
    files: (json['files'] as Map?)?.cast<String, String>(),
    adapters: (json['adapters'] as Map?)?.cast<String, String>(),
    draftQuantize: json['draft_quantize'] as String?,
    draftFiles: (json['draft_files'] as Map?)?.cast<String, String>(),
    remoteHost: json['remote_host'] as String?,
    requires: json['requires'] as String?,
    info: json['info'] as Map<String, dynamic>?,
    stream: json['stream'] as bool?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'model': model,
    if (from != null) 'from': from,
    if (template != null) 'template': template,
    if (license != null) 'license': license,
    if (system != null) 'system': system,
    if (parameters != null) 'parameters': parameters,
    if (messages != null) 'messages': messages!.map((e) => e.toJson()).toList(),
    if (quantize != null) 'quantize': quantize,
    if (renderer != null) 'renderer': renderer,
    if (parser != null) 'parser': parser,
    if (files != null) 'files': files,
    if (adapters != null) 'adapters': adapters,
    if (draftQuantize != null) 'draft_quantize': draftQuantize,
    if (draftFiles != null) 'draft_files': draftFiles,
    if (remoteHost != null) 'remote_host': remoteHost,
    if (requires != null) 'requires': requires,
    if (info != null) 'info': info,
    if (stream != null) 'stream': stream,
  };

  /// Creates a copy with replaced values.
  CreateRequest copyWith({
    String? model,
    Object? from = unsetCopyWithValue,
    Object? template = unsetCopyWithValue,
    Object? license = unsetCopyWithValue,
    Object? system = unsetCopyWithValue,
    Object? parameters = unsetCopyWithValue,
    Object? messages = unsetCopyWithValue,
    Object? quantize = unsetCopyWithValue,
    Object? renderer = unsetCopyWithValue,
    Object? parser = unsetCopyWithValue,
    Object? files = unsetCopyWithValue,
    Object? adapters = unsetCopyWithValue,
    Object? draftQuantize = unsetCopyWithValue,
    Object? draftFiles = unsetCopyWithValue,
    Object? remoteHost = unsetCopyWithValue,
    Object? requires = unsetCopyWithValue,
    Object? info = unsetCopyWithValue,
    Object? stream = unsetCopyWithValue,
  }) {
    return CreateRequest(
      model: model ?? this.model,
      from: from == unsetCopyWithValue ? this.from : from as String?,
      template: template == unsetCopyWithValue
          ? this.template
          : template as String?,
      license: license == unsetCopyWithValue ? this.license : license,
      system: system == unsetCopyWithValue ? this.system : system as String?,
      parameters: parameters == unsetCopyWithValue
          ? this.parameters
          : parameters as Map<String, dynamic>?,
      messages: messages == unsetCopyWithValue
          ? this.messages
          : messages as List<ChatMessage>?,
      quantize: quantize == unsetCopyWithValue
          ? this.quantize
          : quantize as String?,
      renderer: renderer == unsetCopyWithValue
          ? this.renderer
          : renderer as String?,
      parser: parser == unsetCopyWithValue ? this.parser : parser as String?,
      files: files == unsetCopyWithValue
          ? this.files
          : files as Map<String, String>?,
      adapters: adapters == unsetCopyWithValue
          ? this.adapters
          : adapters as Map<String, String>?,
      draftQuantize: draftQuantize == unsetCopyWithValue
          ? this.draftQuantize
          : draftQuantize as String?,
      draftFiles: draftFiles == unsetCopyWithValue
          ? this.draftFiles
          : draftFiles as Map<String, String>?,
      remoteHost: remoteHost == unsetCopyWithValue
          ? this.remoteHost
          : remoteHost as String?,
      requires: requires == unsetCopyWithValue
          ? this.requires
          : requires as String?,
      info: info == unsetCopyWithValue
          ? this.info
          : info as Map<String, dynamic>?,
      stream: stream == unsetCopyWithValue ? this.stream : stream as bool?,
    );
  }

  static bool _licenseEqual(Object? a, Object? b) =>
      (a is List && b is List) ? listsEqual(a as List?, b as List?) : a == b;

  static int _licenseHash(Object? license) =>
      license is List ? listHash(license as List?) : license.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateRequest &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          from == other.from &&
          template == other.template &&
          _licenseEqual(license, other.license) &&
          system == other.system &&
          mapsDeepEqual(parameters, other.parameters) &&
          listsEqual(messages, other.messages) &&
          quantize == other.quantize &&
          renderer == other.renderer &&
          parser == other.parser &&
          mapsEqual(files, other.files) &&
          mapsEqual(adapters, other.adapters) &&
          draftQuantize == other.draftQuantize &&
          mapsEqual(draftFiles, other.draftFiles) &&
          remoteHost == other.remoteHost &&
          requires == other.requires &&
          mapsDeepEqual(info, other.info) &&
          stream == other.stream;

  @override
  int get hashCode => Object.hashAll([
    model,
    from,
    template,
    _licenseHash(license),
    system,
    mapDeepHashCode(parameters),
    listHash(messages),
    quantize,
    renderer,
    parser,
    mapHash(files),
    mapHash(adapters),
    draftQuantize,
    mapHash(draftFiles),
    remoteHost,
    requires,
    mapDeepHashCode(info),
    stream,
  ]);

  @override
  String toString() =>
      'CreateRequest('
      'model: $model, '
      'from: $from, '
      'template: $template, '
      'license: $license, '
      'system: $system, '
      'parameters: $parameters, '
      'messages: $messages, '
      'quantize: $quantize, '
      'renderer: $renderer, '
      'parser: $parser, '
      'files: $files, '
      'adapters: $adapters, '
      'draftQuantize: $draftQuantize, '
      'draftFiles: $draftFiles, '
      'remoteHost: $remoteHost, '
      'requires: $requires, '
      'info: $info, '
      'stream: $stream)';
}
