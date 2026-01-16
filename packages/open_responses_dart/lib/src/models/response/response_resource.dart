import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../items/output_item.dart';
import '../metadata/response_status.dart';
import '../metadata/service_tier.dart';
import 'error_payload.dart';
import 'incomplete_details.dart';
import 'usage.dart';

/// A response resource from the API.
@immutable
class ResponseResource {
  /// Unique identifier.
  final String id;

  /// Object type. Always "response".
  final String object;

  /// Unix timestamp of creation.
  final int? createdAt;

  /// The model that generated the response.
  final String? model;

  /// The response status.
  final ResponseStatus status;

  /// The output items.
  final List<OutputItem>? output;

  /// Token usage statistics.
  final Usage? usage;

  /// Error information (if failed).
  final ErrorPayload? error;

  /// Details about incompleteness.
  final IncompleteDetails? incompleteDetails;

  /// User-provided metadata.
  final Map<String, String>? metadata;

  /// The service tier used.
  final ServiceTier? serviceTier;

  /// The system fingerprint.
  final String? systemFingerprint;

  /// Temperature used for generation.
  final double? temperature;

  /// Top-p used for generation.
  final double? topP;

  /// Creates a [ResponseResource].
  const ResponseResource({
    required this.id,
    this.object = 'response',
    required this.createdAt,
    required this.model,
    required this.status,
    this.output,
    this.usage,
    this.error,
    this.incompleteDetails,
    this.metadata,
    this.serviceTier,
    this.systemFingerprint,
    this.temperature,
    this.topP,
  });

  /// Creates a [ResponseResource] from JSON.
  factory ResponseResource.fromJson(Map<String, dynamic> json) {
    return ResponseResource(
      id: json['id'] as String,
      object: json['object'] as String? ?? 'response',
      createdAt: json['created_at'] as int?,
      model: json['model'] as String?,
      status: ResponseStatus.fromJson(json['status'] as String),
      output: (json['output'] as List?)
          ?.map((e) => OutputItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      usage: json['usage'] != null
          ? Usage.fromJson(json['usage'] as Map<String, dynamic>)
          : null,
      error: json['error'] != null
          ? ErrorPayload.fromJson(json['error'] as Map<String, dynamic>)
          : null,
      incompleteDetails: json['incomplete_details'] != null
          ? IncompleteDetails.fromJson(
              json['incomplete_details'] as Map<String, dynamic>,
            )
          : null,
      metadata: (json['metadata'] as Map?)?.cast<String, String>(),
      serviceTier: json['service_tier'] != null
          ? ServiceTier.fromJson(json['service_tier'] as String)
          : null,
      systemFingerprint: json['system_fingerprint'] as String?,
      temperature: (json['temperature'] as num?)?.toDouble(),
      topP: (json['top_p'] as num?)?.toDouble(),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    if (createdAt != null) 'created_at': createdAt,
    if (model != null) 'model': model,
    'status': status.toJson(),
    if (output != null) 'output': output!.map((e) => e.toJson()).toList(),
    if (usage != null) 'usage': usage!.toJson(),
    if (error != null) 'error': error!.toJson(),
    if (incompleteDetails != null)
      'incomplete_details': incompleteDetails!.toJson(),
    if (metadata != null) 'metadata': metadata,
    if (serviceTier != null) 'service_tier': serviceTier!.toJson(),
    if (systemFingerprint != null) 'system_fingerprint': systemFingerprint,
    if (temperature != null) 'temperature': temperature,
    if (topP != null) 'top_p': topP,
  };

  /// Creates a copy with replaced values.
  ResponseResource copyWith({
    String? id,
    String? object,
    int? createdAt,
    String? model,
    ResponseStatus? status,
    Object? output = unsetCopyWithValue,
    Object? usage = unsetCopyWithValue,
    Object? error = unsetCopyWithValue,
    Object? incompleteDetails = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
    Object? serviceTier = unsetCopyWithValue,
    Object? systemFingerprint = unsetCopyWithValue,
    Object? temperature = unsetCopyWithValue,
    Object? topP = unsetCopyWithValue,
  }) {
    return ResponseResource(
      id: id ?? this.id,
      object: object ?? this.object,
      createdAt: createdAt ?? this.createdAt,
      model: model ?? this.model,
      status: status ?? this.status,
      output: output == unsetCopyWithValue
          ? this.output
          : output as List<OutputItem>?,
      usage: usage == unsetCopyWithValue ? this.usage : usage as Usage?,
      error: error == unsetCopyWithValue ? this.error : error as ErrorPayload?,
      incompleteDetails: incompleteDetails == unsetCopyWithValue
          ? this.incompleteDetails
          : incompleteDetails as IncompleteDetails?,
      metadata: metadata == unsetCopyWithValue
          ? this.metadata
          : metadata as Map<String, String>?,
      serviceTier: serviceTier == unsetCopyWithValue
          ? this.serviceTier
          : serviceTier as ServiceTier?,
      systemFingerprint: systemFingerprint == unsetCopyWithValue
          ? this.systemFingerprint
          : systemFingerprint as String?,
      temperature: temperature == unsetCopyWithValue
          ? this.temperature
          : temperature as double?,
      topP: topP == unsetCopyWithValue ? this.topP : topP as double?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseResource &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          object == other.object &&
          createdAt == other.createdAt &&
          model == other.model &&
          status == other.status &&
          usage == other.usage &&
          error == other.error &&
          incompleteDetails == other.incompleteDetails &&
          serviceTier == other.serviceTier &&
          systemFingerprint == other.systemFingerprint &&
          temperature == other.temperature &&
          topP == other.topP;

  @override
  int get hashCode => Object.hash(
    id,
    object,
    createdAt,
    model,
    status,
    usage,
    error,
    incompleteDetails,
    serviceTier,
    systemFingerprint,
    temperature,
    topP,
  );

  @override
  String toString() =>
      'ResponseResource(id: $id, model: $model, status: $status, ...)';
}
