import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

const _reservedReasoningDetailKeys = {
  'type',
  'id',
  'format',
  'index',
  'summary',
  'text',
  'data',
  'signature',
};

/// Details about model reasoning, returned by some providers.
///
/// **OpenRouter only.** Not part of the official OpenAI API.
///
/// This is returned by OpenRouter when using models that support reasoning.
/// Different types indicate different content:
///
/// - `reasoning.summary`: A summary of the reasoning process
/// - `reasoning.text`: The full reasoning text
/// - `reasoning.encrypted`: Encrypted reasoning data (base64 encoded)
///
/// ## Example
///
/// ```dart
/// final message = response.firstChoice?.message;
/// if (message?.reasoningDetails != null) {
///   for (final detail in message!.reasoningDetails!) {
///     if (detail.isSummary) {
///       print('Summary: ${detail.summary}');
///     }
///   }
/// }
/// ```
@immutable
class ReasoningDetail {
  /// Creates a [ReasoningDetail].
  const ReasoningDetail({
    required this.type,
    this.id,
    this.format,
    this.index,
    this.summary,
    this.text,
    this.data,
    this.signature,
  }) : _additionalProperties = const {},
       _rawJson = null;

  const ReasoningDetail._({
    required this.type,
    required this.id,
    required this.format,
    required this.index,
    required this.summary,
    required this.text,
    required this.data,
    required this.signature,
    required Map<String, dynamic> additionalProperties,
    required Map<String, dynamic>? rawJson,
  }) : _additionalProperties = additionalProperties,
       _rawJson = rawJson;

  /// Creates a programmatic [ReasoningDetail] with future provider fields.
  ///
  /// Recognized fields must be passed through their typed parameters. A
  /// reserved-key collision in [additionalProperties] throws an
  /// [ArgumentError].
  factory ReasoningDetail.withAdditionalProperties({
    required String type,
    String? id,
    String? format,
    int? index,
    String? summary,
    String? text,
    String? data,
    String? signature,
    required Map<String, dynamic> additionalProperties,
  }) {
    final collisions = additionalProperties.keys
        .where(_reservedReasoningDetailKeys.contains)
        .toList(growable: false);
    if (collisions.isNotEmpty) {
      throw ArgumentError.value(
        additionalProperties,
        'additionalProperties',
        'Contains reserved keys: ${collisions.join(', ')}',
      );
    }
    return ReasoningDetail._(
      type: type,
      id: id,
      format: format,
      index: index,
      summary: summary,
      text: text,
      data: data,
      signature: signature,
      additionalProperties: _freezeJsonMap(additionalProperties),
      rawJson: null,
    );
  }

  /// Creates a [ReasoningDetail] from JSON.
  factory ReasoningDetail.fromJson(Map<String, dynamic> json) {
    final additionalProperties = {
      for (final entry in json.entries)
        if (!_reservedReasoningDetailKeys.contains(entry.key))
          entry.key: entry.value,
    };
    return ReasoningDetail._(
      type: json['type'] as String,
      id: json['id'] as String?,
      format: json['format'] as String?,
      index: json['index'] as int?,
      summary: json['summary'] as String?,
      text: json['text'] as String?,
      data: json['data'] as String?,
      signature: json['signature'] as String?,
      additionalProperties: _freezeJsonMap(additionalProperties),
      rawJson: _freezeJsonMap(json),
    );
  }

  /// The type of reasoning detail.
  ///
  /// Common values:
  /// - `reasoning.summary`: A summary of the reasoning process
  /// - `reasoning.text`: The full reasoning text
  /// - `reasoning.encrypted`: Encrypted reasoning data (base64 encoded)
  final String type;

  /// Unique provider identifier for this reasoning detail.
  final String? id;

  /// Provider-specific reasoning format.
  final String? format;

  /// Sequential position of this detail in the reasoning sequence.
  final int? index;

  /// Summary content for `reasoning.summary` details.
  final String? summary;

  /// Text content for `reasoning.text` details.
  final String? text;

  /// Encrypted data for `reasoning.encrypted` details.
  final String? data;

  /// Optional verification signature for text reasoning.
  final String? signature;

  final Map<String, dynamic> _additionalProperties;
  final Map<String, dynamic>? _rawJson;

  /// Future provider fields not currently modeled by this client.
  ///
  /// The returned map and its nested collections are immutable.
  Map<String, dynamic> get additionalProperties => _additionalProperties;

  /// Whether this is a summary detail.
  bool get isSummary => type == 'reasoning.summary';

  /// Whether this is a text detail.
  bool get isText => type == 'reasoning.text';

  /// Whether this is encrypted data.
  bool get isEncrypted => type == 'reasoning.encrypted';

  /// Converts to JSON.
  ///
  /// Parsed instances reproduce the original payload exactly, including
  /// explicit nulls and future fields.
  Map<String, dynamic> toJson() {
    final rawJson = _rawJson;
    if (rawJson != null) return _copyJsonMap(rawJson);
    return {
      ..._copyJsonMap(_additionalProperties),
      'type': type,
      if (id != null) 'id': id,
      if (format != null) 'format': format,
      if (index != null) 'index': index,
      if (summary != null) 'summary': summary,
      if (text != null) 'text': text,
      if (data != null) 'data': data,
      if (signature != null) 'signature': signature,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReasoningDetail &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(toJson(), other.toJson());

  @override
  int get hashCode => mapDeepHashCode(toJson());

  @override
  String toString() {
    if (isSummary) {
      return 'ReasoningDetail(type: $type, summary: ${summary?.length ?? text?.length ?? 0} chars)';
    }
    if (isText) {
      return 'ReasoningDetail(type: $type, text: ${text?.length ?? 0} chars)';
    }
    return 'ReasoningDetail(type: $type)';
  }
}

Map<String, dynamic> _freezeJsonMap(Map<String, dynamic> value) =>
    Map.unmodifiable(
      value.map((key, nested) => MapEntry(key, _freezeJsonValue(nested))),
    );

Object? _freezeJsonValue(Object? value) => switch (value) {
  final Map<String, dynamic> map => _freezeJsonMap(map),
  final List<dynamic> list => List<Object?>.unmodifiable(
    list.map(_freezeJsonValue),
  ),
  _ => value,
};

Map<String, dynamic> _copyJsonMap(Map<String, dynamic> value) =>
    value.map((key, nested) => MapEntry(key, _copyJsonValue(nested)));

Object? _copyJsonValue(Object? value) => switch (value) {
  final Map<String, dynamic> map => _copyJsonMap(map),
  final List<dynamic> list => list.map(_copyJsonValue).toList(),
  _ => value,
};
