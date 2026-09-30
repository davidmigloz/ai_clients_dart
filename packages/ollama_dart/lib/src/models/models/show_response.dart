import 'package:meta/meta.dart';

import '../chat/chat_message.dart';
import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'model_tensor.dart';
import 'model_thinking.dart';

/// Response containing model details.
///
/// [ShowResponse.fromJson] and [copyWith] copy and freeze [messages] and
/// [tensors], and recursively copy and freeze the JSON in [projectorInfo].
/// Existing collections within [ChatMessage] retain their historical behavior.
/// The const constructor retains supplied collection references, which callers
/// should keep immutable.
@immutable
class ShowResponse {
  /// Model parameter settings serialized as text.
  final String? parameters;

  /// The license of the model.
  final String? license;

  /// Last modified timestamp in ISO 8601 format.
  final String? modifiedAt;

  /// High-level model details.
  final Map<String, dynamic>? details;

  /// The template used by the model to render prompts.
  final String? template;

  /// List of supported features.
  final List<String>? capabilities;

  /// Additional model metadata.
  final Map<String, dynamic>? modelInfo;

  /// Generated Modelfile describing the model.
  final String? modelfile;

  /// System prompt stored in the model or overridden by the show request.
  final String? system;

  /// Prompt renderer name, when reported by the server.
  final String? renderer;

  /// Output parser name, when reported by the server.
  final String? parser;

  /// Upstream model name for a remote model.
  final String? remoteModel;

  /// Upstream Ollama host for a remote model.
  final String? remoteHost;

  /// Minimum Ollama version required by the model.
  final String? requires;

  /// Message history stored in the model.
  final List<ChatMessage>? messages;

  /// Metadata for the model's multimodal projector, when available.
  final Map<String, dynamic>? projectorInfo;

  /// Tensor information returned for verbose model inspection.
  final List<ModelTensor>? tensors;

  /// Supported thinking controls and the default used when think is omitted.
  final ModelThinking? thinking;

  /// Creates a [ShowResponse].
  const ShowResponse({
    this.parameters,
    this.license,
    this.modifiedAt,
    this.details,
    this.template,
    this.capabilities,
    this.modelInfo,
    this.modelfile,
    this.system,
    this.renderer,
    this.parser,
    this.remoteModel,
    this.remoteHost,
    this.requires,
    this.messages,
    this.projectorInfo,
    this.tensors,
    this.thinking,
  });

  /// Creates a [ShowResponse] from JSON.
  factory ShowResponse.fromJson(Map<String, dynamic> json) => ShowResponse(
    modelfile: json['modelfile'] as String?,
    system: json['system'] as String?,
    renderer: json['renderer'] as String?,
    parser: json['parser'] as String?,
    remoteModel: json['remote_model'] as String?,
    remoteHost: json['remote_host'] as String?,
    requires: json['requires'] as String?,
    messages: _freezeList(
      (json['messages'] as List?)?.map(
        (e) => ChatMessage.fromJson(e as Map<String, dynamic>),
      ),
    ),
    projectorInfo: _freezeProjectorInfo(
      json['projector_info'] as Map<String, dynamic>?,
    ),
    tensors: _freezeList(
      (json['tensors'] as List?)?.map(
        (e) => ModelTensor.fromJson(e as Map<String, dynamic>),
      ),
    ),
    thinking: json['thinking'] != null
        ? ModelThinking.fromJson(json['thinking'] as Map<String, dynamic>)
        : null,
    parameters: json['parameters'] as String?,
    license: json['license'] as String?,
    modifiedAt: json['modified_at'] as String?,
    details: json['details'] as Map<String, dynamic>?,
    template: json['template'] as String?,
    capabilities: (json['capabilities'] as List?)?.cast<String>(),
    modelInfo: json['model_info'] as Map<String, dynamic>?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (modelfile != null) 'modelfile': modelfile,
    if (system != null) 'system': system,
    if (renderer != null) 'renderer': renderer,
    if (parser != null) 'parser': parser,
    if (remoteModel != null) 'remote_model': remoteModel,
    if (remoteHost != null) 'remote_host': remoteHost,
    if (requires != null) 'requires': requires,
    if (messages != null) 'messages': messages!.map((e) => e.toJson()).toList(),
    if (projectorInfo != null) 'projector_info': projectorInfo,
    if (tensors != null) 'tensors': tensors!.map((e) => e.toJson()).toList(),
    if (thinking != null) 'thinking': thinking!.toJson(),
    if (parameters != null) 'parameters': parameters,
    if (license != null) 'license': license,
    if (modifiedAt != null) 'modified_at': modifiedAt,
    if (details != null) 'details': details,
    if (template != null) 'template': template,
    if (capabilities != null) 'capabilities': capabilities,
    if (modelInfo != null) 'model_info': modelInfo,
  };

  /// Creates a copy with replaced values.
  ShowResponse copyWith({
    Object? modelfile = unsetCopyWithValue,
    Object? system = unsetCopyWithValue,
    Object? renderer = unsetCopyWithValue,
    Object? parser = unsetCopyWithValue,
    Object? remoteModel = unsetCopyWithValue,
    Object? remoteHost = unsetCopyWithValue,
    Object? requires = unsetCopyWithValue,
    Object? messages = unsetCopyWithValue,
    Object? projectorInfo = unsetCopyWithValue,
    Object? tensors = unsetCopyWithValue,
    Object? thinking = unsetCopyWithValue,
    Object? parameters = unsetCopyWithValue,
    Object? license = unsetCopyWithValue,
    Object? modifiedAt = unsetCopyWithValue,
    Object? details = unsetCopyWithValue,
    Object? template = unsetCopyWithValue,
    Object? capabilities = unsetCopyWithValue,
    Object? modelInfo = unsetCopyWithValue,
  }) {
    return ShowResponse(
      modelfile: identical(modelfile, unsetCopyWithValue)
          ? this.modelfile
          : modelfile as String?,
      system: identical(system, unsetCopyWithValue)
          ? this.system
          : system as String?,
      renderer: identical(renderer, unsetCopyWithValue)
          ? this.renderer
          : renderer as String?,
      parser: identical(parser, unsetCopyWithValue)
          ? this.parser
          : parser as String?,
      remoteModel: identical(remoteModel, unsetCopyWithValue)
          ? this.remoteModel
          : remoteModel as String?,
      remoteHost: identical(remoteHost, unsetCopyWithValue)
          ? this.remoteHost
          : remoteHost as String?,
      requires: identical(requires, unsetCopyWithValue)
          ? this.requires
          : requires as String?,
      messages: _freezeList(
        identical(messages, unsetCopyWithValue)
            ? this.messages
            : messages as List<ChatMessage>?,
      ),
      projectorInfo: _freezeProjectorInfo(
        identical(projectorInfo, unsetCopyWithValue)
            ? this.projectorInfo
            : projectorInfo as Map<String, dynamic>?,
      ),
      tensors: _freezeList(
        identical(tensors, unsetCopyWithValue)
            ? this.tensors
            : tensors as List<ModelTensor>?,
      ),
      thinking: identical(thinking, unsetCopyWithValue)
          ? this.thinking
          : thinking as ModelThinking?,
      parameters: parameters == unsetCopyWithValue
          ? this.parameters
          : parameters as String?,
      license: license == unsetCopyWithValue
          ? this.license
          : license as String?,
      modifiedAt: modifiedAt == unsetCopyWithValue
          ? this.modifiedAt
          : modifiedAt as String?,
      details: details == unsetCopyWithValue
          ? this.details
          : details as Map<String, dynamic>?,
      template: template == unsetCopyWithValue
          ? this.template
          : template as String?,
      capabilities: capabilities == unsetCopyWithValue
          ? this.capabilities
          : capabilities as List<String>?,
      modelInfo: modelInfo == unsetCopyWithValue
          ? this.modelInfo
          : modelInfo as Map<String, dynamic>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShowResponse &&
          runtimeType == other.runtimeType &&
          parameters == other.parameters &&
          license == other.license &&
          modifiedAt == other.modifiedAt &&
          mapsDeepEqual(details, other.details) &&
          template == other.template &&
          listsEqual(capabilities, other.capabilities) &&
          mapsDeepEqual(modelInfo, other.modelInfo) &&
          modelfile == other.modelfile &&
          system == other.system &&
          renderer == other.renderer &&
          parser == other.parser &&
          remoteModel == other.remoteModel &&
          remoteHost == other.remoteHost &&
          requires == other.requires &&
          listsEqual(messages, other.messages) &&
          mapsDeepEqual(projectorInfo, other.projectorInfo) &&
          listsEqual(tensors, other.tensors) &&
          thinking == other.thinking;

  @override
  int get hashCode => Object.hashAll([
    parameters,
    license,
    modifiedAt,
    mapDeepHashCode(details),
    template,
    listHash(capabilities),
    mapDeepHashCode(modelInfo),
    modelfile,
    system,
    renderer,
    parser,
    remoteModel,
    remoteHost,
    requires,
    listHash(messages),
    mapDeepHashCode(projectorInfo),
    listHash(tensors),
    thinking,
  ]);

  @override
  String toString() =>
      'ShowResponse('
      'parameters: $parameters, '
      'license: $license, '
      'modifiedAt: $modifiedAt, '
      'details: $details, '
      'template: $template, '
      'capabilities: $capabilities, '
      'modelInfo: $modelInfo, '
      'modelfile: $modelfile, '
      'system: $system, '
      'renderer: $renderer, '
      'parser: $parser, '
      'remoteModel: $remoteModel, '
      'remoteHost: $remoteHost, '
      'requires: $requires, '
      'messages: $messages, '
      'projectorInfo: $projectorInfo, '
      'tensors: $tensors, '
      'thinking: $thinking)';
}

List<T>? _freezeList<T>(Iterable<T>? values) =>
    values == null ? null : List<T>.unmodifiable(values);

Map<String, dynamic>? _freezeProjectorInfo(Map<String, dynamic>? values) =>
    values == null
    ? null
    : Map<String, dynamic>.unmodifiable({
        for (final entry in values.entries)
          entry.key: _freezeJsonValue(entry.value),
      });

Object? _freezeJsonValue(Object? value) {
  if (value is Map<String, dynamic>) return _freezeProjectorInfo(value);
  if (value is List) {
    return List<Object?>.unmodifiable(value.map(_freezeJsonValue));
  }
  return value;
}
