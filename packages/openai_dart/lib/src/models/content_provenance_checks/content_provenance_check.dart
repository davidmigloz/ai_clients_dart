import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// The result of checking an uploaded file for OpenAI content provenance
/// signals.
///
/// Returned by `POST /content_provenance_checks`. Access via
/// [OpenAIClient.contentProvenanceChecks].
@immutable
class ContentProvenanceCheck {
  /// The object type. Always `content_provenance_check`.
  final String object;

  /// Unix timestamp (in seconds) of when the check was created.
  final int createdAt;

  /// The provenance signals detected in the uploaded file.
  final List<ProvenanceResult> results;

  /// Creates a [ContentProvenanceCheck].
  const ContentProvenanceCheck({
    required this.object,
    required this.createdAt,
    required this.results,
  });

  /// Creates a [ContentProvenanceCheck] from JSON.
  factory ContentProvenanceCheck.fromJson(Map<String, dynamic> json) {
    return ContentProvenanceCheck(
      object: json['object'] as String,
      createdAt: json['created_at'] as int,
      results: (json['results'] as List)
          .map((e) => ProvenanceResult.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'object': object,
    'created_at': createdAt,
    'results': results.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  ContentProvenanceCheck copyWith({
    String? object,
    int? createdAt,
    List<ProvenanceResult>? results,
  }) {
    return ContentProvenanceCheck(
      object: object ?? this.object,
      createdAt: createdAt ?? this.createdAt,
      results: results ?? this.results,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentProvenanceCheck &&
          runtimeType == other.runtimeType &&
          object == other.object &&
          createdAt == other.createdAt &&
          listsEqual(results, other.results);

  @override
  int get hashCode => Object.hash(object, createdAt, listHash(results));

  @override
  String toString() =>
      'ContentProvenanceCheck(object: $object, createdAt: $createdAt, '
      'results: $results)';
}

/// A single provenance signal detected for an uploaded file.
///
/// Dispatches on the `type` discriminator to either [C2PAProvenanceResult]
/// or [SynthIDProvenanceResult]. Unrecognized types are surfaced as
/// [UnknownProvenanceResult] with the raw JSON preserved.
@immutable
sealed class ProvenanceResult {
  const ProvenanceResult();

  /// Creates a [ProvenanceResult] from JSON, dispatching on `type`.
  factory ProvenanceResult.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'c2pa' => C2PAProvenanceResult.fromJson(json),
      'synthid' => SynthIDProvenanceResult.fromJson(json),
      _ => UnknownProvenanceResult.fromJson(json),
    };
  }

  /// The discriminator value.
  String get type;

  /// Serializes the result.
  Map<String, dynamic> toJson();
}

/// A C2PA (Coalition for Content Provenance and Authenticity) provenance
/// signal detected for an uploaded file.
@immutable
class C2PAProvenanceResult extends ProvenanceResult {
  /// Creates a [C2PAProvenanceResult].
  const C2PAProvenanceResult({
    required this.outcome,
    required this.validationState,
    this.model,
    this.issuer,
    this.generatedAt,
  });

  /// Creates a [C2PAProvenanceResult] from JSON.
  factory C2PAProvenanceResult.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'c2pa') {
      throw FormatException('Expected type "c2pa", got "${json['type']}"');
    }
    return C2PAProvenanceResult(
      outcome: ProvenanceDetectionResult.fromJson(json['outcome'] as String),
      validationState: C2PAValidationState.fromJson(
        json['validation_state'] as String,
      ),
      model: json['model'] as String?,
      issuer: json['issuer'] as String?,
      generatedAt: json['generated_at'] as String?,
    );
  }

  /// Whether a C2PA manifest was detected.
  final ProvenanceDetectionResult outcome;

  /// The validation state of the detected C2PA manifest.
  final C2PAValidationState validationState;

  /// The model that generated the content, if declared in the manifest.
  final String? model;

  /// The issuer of the C2PA manifest's signing certificate, if present.
  final String? issuer;

  /// The timestamp the content was generated, if declared in the manifest.
  final String? generatedAt;

  @override
  String get type => 'c2pa';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'outcome': outcome.toJson(),
    'validation_state': validationState.toJson(),
    'model': model,
    'issuer': issuer,
    'generated_at': generatedAt,
  };

  /// Creates a copy with replaced values.
  C2PAProvenanceResult copyWith({
    ProvenanceDetectionResult? outcome,
    C2PAValidationState? validationState,
    Object? model = unsetCopyWithValue,
    Object? issuer = unsetCopyWithValue,
    Object? generatedAt = unsetCopyWithValue,
  }) {
    return C2PAProvenanceResult(
      outcome: outcome ?? this.outcome,
      validationState: validationState ?? this.validationState,
      model: model == unsetCopyWithValue ? this.model : model as String?,
      issuer: issuer == unsetCopyWithValue ? this.issuer : issuer as String?,
      generatedAt: generatedAt == unsetCopyWithValue
          ? this.generatedAt
          : generatedAt as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is C2PAProvenanceResult &&
          runtimeType == other.runtimeType &&
          outcome == other.outcome &&
          validationState == other.validationState &&
          model == other.model &&
          issuer == other.issuer &&
          generatedAt == other.generatedAt;

  @override
  int get hashCode =>
      Object.hash(outcome, validationState, model, issuer, generatedAt);

  @override
  String toString() =>
      'C2PAProvenanceResult(outcome: $outcome, '
      'validationState: $validationState, model: $model, issuer: $issuer, '
      'generatedAt: $generatedAt)';
}

/// A SynthID provenance signal detected for an uploaded file.
@immutable
class SynthIDProvenanceResult extends ProvenanceResult {
  /// Creates a [SynthIDProvenanceResult].
  const SynthIDProvenanceResult({
    required this.outcome,
    this.model,
    this.generatedAt,
  });

  /// Creates a [SynthIDProvenanceResult] from JSON.
  factory SynthIDProvenanceResult.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'synthid') {
      throw FormatException('Expected type "synthid", got "${json['type']}"');
    }
    return SynthIDProvenanceResult(
      outcome: ProvenanceDetectionResult.fromJson(json['outcome'] as String),
      model: json['model'] as String?,
      generatedAt: json['generated_at'] as String?,
    );
  }

  /// Whether a SynthID watermark was detected.
  final ProvenanceDetectionResult outcome;

  /// The model that generated the content, if declared in the watermark.
  final String? model;

  /// The timestamp the content was generated, if declared in the watermark.
  final String? generatedAt;

  @override
  String get type => 'synthid';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'outcome': outcome.toJson(),
    'model': model,
    'generated_at': generatedAt,
  };

  /// Creates a copy with replaced values.
  SynthIDProvenanceResult copyWith({
    ProvenanceDetectionResult? outcome,
    Object? model = unsetCopyWithValue,
    Object? generatedAt = unsetCopyWithValue,
  }) {
    return SynthIDProvenanceResult(
      outcome: outcome ?? this.outcome,
      model: model == unsetCopyWithValue ? this.model : model as String?,
      generatedAt: generatedAt == unsetCopyWithValue
          ? this.generatedAt
          : generatedAt as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SynthIDProvenanceResult &&
          runtimeType == other.runtimeType &&
          outcome == other.outcome &&
          model == other.model &&
          generatedAt == other.generatedAt;

  @override
  int get hashCode => Object.hash(outcome, model, generatedAt);

  @override
  String toString() =>
      'SynthIDProvenanceResult(outcome: $outcome, model: $model, '
      'generatedAt: $generatedAt)';
}

/// Forward-compatibility fallback for unrecognized provenance result types.
/// Preserves the raw JSON so re-serialization does not drop forward-compatible
/// fields.
@immutable
class UnknownProvenanceResult extends ProvenanceResult {
  /// Creates an [UnknownProvenanceResult].
  const UnknownProvenanceResult({required this.rawType, required this.rawJson});

  /// Creates an [UnknownProvenanceResult] from JSON.
  factory UnknownProvenanceResult.fromJson(Map<String, dynamic> json) {
    return UnknownProvenanceResult(
      rawType: json['type'] as String? ?? '',
      rawJson: Map<String, dynamic>.from(json),
    );
  }

  /// The unrecognized `type` value from the server.
  final String rawType;

  /// The original JSON payload (preserved verbatim).
  final Map<String, dynamic> rawJson;

  @override
  String get type => rawType;

  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(rawJson);

  /// Creates a copy with replaced values.
  UnknownProvenanceResult copyWith({
    String? rawType,
    Map<String, dynamic>? rawJson,
  }) {
    return UnknownProvenanceResult(
      rawType: rawType ?? this.rawType,
      rawJson: rawJson ?? this.rawJson,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownProvenanceResult &&
          runtimeType == other.runtimeType &&
          rawType == other.rawType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => Object.hash(rawType, mapDeepHashCode(rawJson));

  @override
  String toString() => 'UnknownProvenanceResult(type: $rawType)';
}

/// Whether a provenance signal was detected in an uploaded file.
enum ProvenanceDetectionResult {
  /// Unknown outcome (fallback for unrecognized values).
  unknown('unknown'),

  /// The signal was detected.
  detected('detected'),

  /// The signal was not detected.
  notDetected('not_detected');

  /// The JSON value for this outcome.
  final String value;

  const ProvenanceDetectionResult(this.value);

  /// Creates a [ProvenanceDetectionResult] from a JSON value.
  factory ProvenanceDetectionResult.fromJson(String json) {
    return ProvenanceDetectionResult.values.firstWhere(
      (e) => e.value == json,
      orElse: () => ProvenanceDetectionResult.unknown,
    );
  }

  /// Converts to JSON value.
  String toJson() => value;
}

/// The validation state of a detected C2PA manifest.
enum C2PAValidationState {
  /// Unknown validation state (fallback for unrecognized values).
  unknown('unknown'),

  /// The manifest is signed by a trusted issuer.
  trusted('trusted'),

  /// The manifest is valid but not signed by a trusted issuer.
  valid('valid'),

  /// The manifest failed validation.
  invalid('invalid'),

  /// No C2PA manifest was present.
  notPresent('not_present');

  /// The JSON value for this validation state.
  final String value;

  const C2PAValidationState(this.value);

  /// Creates a [C2PAValidationState] from a JSON value.
  factory C2PAValidationState.fromJson(String json) {
    return C2PAValidationState.values.firstWhere(
      (e) => e.value == json,
      orElse: () => C2PAValidationState.unknown,
    );
  }

  /// Converts to JSON value.
  String toJson() => value;
}
