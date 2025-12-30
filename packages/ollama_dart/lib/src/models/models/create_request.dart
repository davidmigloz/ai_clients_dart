import 'package:meta/meta.dart';

import '../chat/chat_message.dart';
import '../common/copy_with_sentinel.dart';

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
      stream: stream == unsetCopyWithValue ? this.stream : stream as bool?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateRequest &&
          runtimeType == other.runtimeType &&
          model == other.model;

  @override
  int get hashCode => model.hashCode;

  @override
  String toString() => 'CreateRequest(model: $model, from: $from)';
}
