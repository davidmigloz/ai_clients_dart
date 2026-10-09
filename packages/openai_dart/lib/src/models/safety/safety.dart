import 'dart:collection';

import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../common/json_helpers.dart';

part 'safety_json_helpers.dart';

/// The category reported by a project safety alert.
///
/// Unknown received strings return [unknown]. [SafetyAlert.rawErrorType]
/// retains their exact wire value; this enum alone does not retain that value.
enum SafetyAlertErrorType {
  /// A potentially unintended transfer of data.
  potentiallyUnintendedDataTransfer('potentially_unintended_data_transfer'),

  /// Potentially unintended access to data.
  potentiallyUnintendedDataAccess('potentially_unintended_data_access'),

  /// Potentially unintended destructive activity.
  potentiallyUnintendedDestructiveActivity(
    'potentially_unintended_destructive_activity',
  ),

  /// Another reported category.
  other('other'),

  /// A received value outside the current canonical choices.
  unknown('unknown');

  const SafetyAlertErrorType(this.value);

  /// The known wire value, or the unknown sentinel.
  final String value;

  /// Parses known values with an explicit receive-only unknown fallback.
  static SafetyAlertErrorType fromJson(String value) => switch (value) {
    'potentially_unintended_data_transfer' =>
      SafetyAlertErrorType.potentiallyUnintendedDataTransfer,
    'potentially_unintended_data_access' =>
      SafetyAlertErrorType.potentiallyUnintendedDataAccess,
    'potentially_unintended_destructive_activity' =>
      SafetyAlertErrorType.potentiallyUnintendedDestructiveActivity,
    'other' => SafetyAlertErrorType.other,
    _ => SafetyAlertErrorType.unknown,
  };

  /// Serializes this choice; unknown alert values use the alert's raw field.
  String toJson() => value;
}

/// The kind of notice associated with an organization safety case.
///
/// Unknown received strings return [unknown]. [SafetyCaseNotice.rawType]
/// retains their exact wire value; this enum alone does not retain that value.
enum SafetyCaseNoticeType {
  /// A warning notice.
  warning('warning'),

  /// A deactivation notice.
  deactivation('deactivation'),

  /// A received value outside the current canonical choices.
  unknown('unknown');

  const SafetyCaseNoticeType(this.value);

  /// The known wire value, or the unknown sentinel.
  final String value;

  /// Parses known values with an explicit receive-only unknown fallback.
  static SafetyCaseNoticeType fromJson(String value) => switch (value) {
    'warning' => SafetyCaseNoticeType.warning,
    'deactivation' => SafetyCaseNoticeType.deactivation,
    _ => SafetyCaseNoticeType.unknown,
  };

  /// Serializes this choice; unknown notice values use the notice's raw field.
  String toJson() => value;
}

/// Details of a project safety alert retrieved explicitly from its notice.
///
/// The required nullable [reason] is retained even when null. Future object
/// properties are preserved as finite, deeply immutable JSON. Unknown received
/// error strings use [errorType] equal to [SafetyAlertErrorType.unknown] and
/// preserve the wire value in [rawErrorType]. No retrieval or action occurs
/// during parsing. [hasDetailedExplanation] distinguishes an absent optional
/// explanation from an explicitly null explanation.
@immutable
class SafetyAlert with _SafetyValue {
  /// Creates a safety alert.
  ///
  /// [rawErrorType] is required only for [SafetyAlertErrorType.unknown] and
  /// must be absent for known choices.
  ///
  /// Omitting both [detailedExplanation] and [hasDetailedExplanation] adopts a
  /// valid explanation already in [rawJson], preserving earlier raw-only
  /// construction. Otherwise the explicit value or presence wins. An explicit
  /// null value retains its JSON key; `hasDetailedExplanation: false` omits it.
  /// A nonnull value cannot be combined with false presence. Explanation values
  /// accept only strings or null and are validated without disclosing content,
  /// including stale known values in [rawJson].
  SafetyAlert({
    required String id,
    required int createdAt,
    required String requestId,
    required String responseId,
    required String model,
    required bool requestPaused,
    required SafetyAlertErrorType errorType,
    String? rawErrorType,
    required String? reason,
    Object? detailedExplanation = unsetCopyWithValue,
    bool? hasDetailedExplanation,
    Map<String, dynamic> rawJson = const {},
  }) : this._(
         id: id,
         createdAt: createdAt,
         requestId: requestId,
         responseId: responseId,
         model: model,
         requestPaused: requestPaused,
         errorType: errorType,
         rawErrorType: rawErrorType,
         reason: reason,
         explanation: _safetyExplanation(
           detailedExplanation,
           hasDetailedExplanation,
           rawJson,
         ),
         rawJson: _safetySnapshot(rawJson, 'SafetyAlert.rawJson'),
       );

  SafetyAlert._({
    required this.id,
    required this.createdAt,
    required this.requestId,
    required this.responseId,
    required this.model,
    required this.requestPaused,
    required this.errorType,
    this.rawErrorType,
    required this.reason,
    required ({String? value, bool present}) explanation,
    required this.rawJson,
  }) : detailedExplanation = explanation.value,
       hasDetailedExplanation = explanation.present {
    _safetyRawChoice(
      errorType == SafetyAlertErrorType.unknown,
      rawErrorType,
      'SafetyAlert.rawErrorType',
      (value) =>
          SafetyAlertErrorType.fromJson(value) == SafetyAlertErrorType.unknown,
    );
  }

  /// The referenced alert ID, distinct from the webhook event ID.
  final String id;

  /// Unix timestamp when the alert was created.
  final int createdAt;

  /// The request that produced the alert.
  final String requestId;

  /// The response associated with the alert.
  final String responseId;

  /// The model associated with the alert.
  final String model;

  /// Whether block registration succeeded for this request.
  ///
  /// This does not confirm that response execution stopped or effects were
  /// reversed. A false value is retained without adopting a default.
  final bool requestPaused;

  /// The known category, or an explicit unknown received category.
  final SafetyAlertErrorType errorType;

  /// The exact received unknown category; null for known categories.
  final String? rawErrorType;

  /// A customer-safe description, or null for zero data retention requests.
  ///
  /// The JSON key remains required when its value is null.
  final String? reason;

  /// A generated explanation, temporarily available for eligible zero data
  /// retention alerts. Availability is determined by the service.
  ///
  /// This is null for either an absent key or an explicitly null value; use
  /// [hasDetailedExplanation] to distinguish those states. A null [reason] does
  /// not establish eligibility, and neither field proves execution stopped.
  final String? detailedExplanation;

  /// Whether the optional explanation key is present, including explicit null.
  final bool hasDetailedExplanation;

  /// The fixed canonical object value.
  String get object => 'safety.alert';

  /// Finite, deeply immutable received JSON, including future properties.
  final Map<String, dynamic> rawJson;

  /// Parses required fields with contextual errors that omit payload values.
  factory SafetyAlert.fromJson(Map<String, dynamic> json) {
    final snapshot = _safetySnapshot(json, 'SafetyAlert');
    _safetyObject(snapshot, 'safety.alert', 'SafetyAlert');
    final rawErrorType = requireJsonString(
      snapshot['error_type'],
      'SafetyAlert.error_type',
    );
    final errorType = SafetyAlertErrorType.fromJson(rawErrorType);
    return SafetyAlert(
      id: requireJsonString(snapshot['id'], 'SafetyAlert.id'),
      createdAt: requireJsonInt(
        snapshot['created_at'],
        'SafetyAlert.created_at',
      ),
      requestId: requireJsonString(
        snapshot['request_id'],
        'SafetyAlert.request_id',
      ),
      responseId: requireJsonString(
        snapshot['response_id'],
        'SafetyAlert.response_id',
      ),
      model: requireJsonString(snapshot['model'], 'SafetyAlert.model'),
      requestPaused: _safetyBool(
        snapshot['request_paused'],
        'SafetyAlert.request_paused',
      ),
      errorType: errorType,
      rawErrorType: errorType == SafetyAlertErrorType.unknown
          ? rawErrorType
          : null,
      reason: _safetyNullableString(snapshot, 'reason', 'SafetyAlert'),
      detailedExplanation: _safetyCopyString(
        snapshot['detailed_explanation'],
        'SafetyAlert.detailed_explanation',
      ),
      hasDetailedExplanation: snapshot.containsKey('detailed_explanation'),
      rawJson: snapshot,
    );
  }

  /// Copies all fields; explicit null clears [reason].
  ///
  /// Selecting a known [errorType] clears the previous unknown raw value.
  /// Unknown choices require an unknown [rawErrorType]. An empty [rawJson]
  /// removes future properties without changing typed fields.
  ///
  /// Omitting [detailedExplanation] preserves its current value and presence.
  /// Explicit null retains the serialized key; `hasDetailedExplanation: false`
  /// clears the effective typed value and omits that key from [toJson]. The
  /// immutable received [rawJson] snapshot remains available. Setting true
  /// without a value makes an absent key
  /// explicitly null. Unlike raw-only construction, replacing [rawJson] never
  /// adopts its explanation or resurrects a removed key. Known raw explanation
  /// values are still validated even when they would not be serialized.
  SafetyAlert copyWith({
    String? id,
    int? createdAt,
    String? requestId,
    String? responseId,
    String? model,
    bool? requestPaused,
    SafetyAlertErrorType? errorType,
    Object? rawErrorType = unsetCopyWithValue,
    Object? reason = unsetCopyWithValue,
    Object? detailedExplanation = unsetCopyWithValue,
    bool? hasDetailedExplanation,
    Map<String, dynamic>? rawJson,
  }) {
    final replacingExplanation = !identical(
      detailedExplanation,
      unsetCopyWithValue,
    );
    return SafetyAlert(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      requestId: requestId ?? this.requestId,
      responseId: responseId ?? this.responseId,
      model: model ?? this.model,
      requestPaused: requestPaused ?? this.requestPaused,
      errorType: errorType ?? this.errorType,
      rawErrorType: identical(rawErrorType, unsetCopyWithValue)
          ? errorType != null && errorType != SafetyAlertErrorType.unknown
                ? null
                : this.rawErrorType
          : _safetyCopyString(rawErrorType, 'SafetyAlert.rawErrorType'),
      reason: identical(reason, unsetCopyWithValue)
          ? this.reason
          : _safetyCopyString(reason, 'SafetyAlert.reason'),
      detailedExplanation: replacingExplanation
          ? detailedExplanation
          : hasDetailedExplanation == false
          ? null
          : this.detailedExplanation,
      hasDetailedExplanation:
          hasDetailedExplanation ??
          (replacingExplanation || this.hasDetailedExplanation),
      rawJson: rawJson ?? this.rawJson,
    );
  }

  @override
  Map<String, dynamic> _valueJson() => toJson();

  /// Serializes effective typed fields and preserves future received properties.
  Map<String, dynamic> toJson() => _safetySnapshot(
    _safetyMerge(
      rawJson,
      const {
        'id',
        'object',
        'created_at',
        'request_id',
        'response_id',
        'model',
        'request_paused',
        'error_type',
        'reason',
        'detailed_explanation',
      },
      {
        'id': id,
        'object': object,
        'created_at': createdAt,
        'request_id': requestId,
        'response_id': responseId,
        'model': model,
        'request_paused': requestPaused,
        'error_type': rawErrorType ?? errorType.toJson(),
        'reason': reason,
        if (hasDetailedExplanation) 'detailed_explanation': detailedExplanation,
      },
    ),
    'SafetyAlert JSON',
  );

  @override
  String toString() =>
      'SafetyAlert('
      'id: [redacted], createdAt: $createdAt, requestId: [redacted], '
      'responseId: [redacted], model: [redacted], requestPaused: $requestPaused, '
      'errorType: $errorType, rawErrorType: ${rawErrorType == null ? 'null' : '[redacted]'}, '
      'reason: ${reason == null ? 'null' : '[redacted]'}, '
      'detailedExplanation: ${!hasDetailedExplanation
          ? 'absent'
          : detailedExplanation == null
          ? 'null'
          : '[redacted]'}, '
      'hasDetailedExplanation: $hasDetailedExplanation, '
      'object: $object, rawJson: [redacted])';
}

/// The notice associated with an organization safety case.
///
/// Unknown received strings are preserved through [rawType], and finite future
/// object properties are preserved without inventing enforcement semantics.
@immutable
class SafetyCaseNotice with _SafetyValue {
  /// Creates a case notice.
  ///
  /// [rawType] is required only for [SafetyCaseNoticeType.unknown] and must be
  /// absent for known choices.
  SafetyCaseNotice({
    required this.type,
    this.rawType,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _safetySnapshot(rawJson, 'SafetyCaseNotice.rawJson') {
    _safetyRawChoice(
      type == SafetyCaseNoticeType.unknown,
      rawType,
      'SafetyCaseNotice.rawType',
      (value) =>
          SafetyCaseNoticeType.fromJson(value) == SafetyCaseNoticeType.unknown,
    );
  }

  /// A known notice type, or an explicit unknown received type.
  final SafetyCaseNoticeType type;

  /// The exact received unknown notice type; null for known types.
  final String? rawType;

  /// Finite, deeply immutable received JSON, including future properties.
  final Map<String, dynamic> rawJson;

  /// Parses the required notice type without silently adopting a known default.
  factory SafetyCaseNotice.fromJson(Map<String, dynamic> json) {
    final snapshot = _safetySnapshot(json, 'SafetyCaseNotice');
    final rawType = requireJsonString(
      snapshot['type'],
      'SafetyCaseNotice.type',
    );
    final type = SafetyCaseNoticeType.fromJson(rawType);
    return SafetyCaseNotice(
      type: type,
      rawType: type == SafetyCaseNoticeType.unknown ? rawType : null,
      rawJson: snapshot,
    );
  }

  /// Copies all fields; a known [type] clears the previous unknown raw value.
  ///
  /// An empty [rawJson] removes future properties. A new unknown [type] requires
  /// its matching unknown [rawType].
  SafetyCaseNotice copyWith({
    SafetyCaseNoticeType? type,
    Object? rawType = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => SafetyCaseNotice(
    type: type ?? this.type,
    rawType: identical(rawType, unsetCopyWithValue)
        ? type != null && type != SafetyCaseNoticeType.unknown
              ? null
              : this.rawType
        : _safetyCopyString(rawType, 'SafetyCaseNotice.rawType'),
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  Map<String, dynamic> _valueJson() => toJson();

  /// Serializes effective type and preserves future received properties.
  Map<String, dynamic> toJson() => _safetySnapshot(
    _safetyMerge(rawJson, const {'type'}, {'type': rawType ?? type.toJson()}),
    'SafetyCaseNotice JSON',
  );

  @override
  String toString() =>
      'SafetyCaseNotice('
      'type: $type, rawType: ${rawType == null ? 'null' : '[redacted]'}, '
      'rawJson: [redacted])';
}

/// Details of an organization safety case retrieved explicitly from its notice.
///
/// [entityIdentifier] identifies the application entity associated with the case;
/// it differs from this case's [id] and the notification's event ID. The required
/// nullable [reason] and finite future object properties are preserved. Parsing
/// performs no retrieval and takes no enforcement-changing action.
@immutable
class SafetyCase with _SafetyValue {
  /// Creates a safety case.
  SafetyCase({
    required this.id,
    required this.createdAt,
    required this.entityIdentifier,
    required this.reason,
    required this.notice,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _safetySnapshot(rawJson, 'SafetyCase.rawJson');

  /// The referenced case ID, distinct from the webhook event ID.
  final String id;

  /// Unix timestamp when the case was created.
  final int createdAt;

  /// The application's safety identifier, distinct from the case and event IDs.
  final String entityIdentifier;

  /// The case reason; the JSON key remains required when null.
  final String? reason;

  /// The associated organization notice.
  final SafetyCaseNotice notice;

  /// The fixed canonical object value.
  String get object => 'safety.case';

  /// Finite, deeply immutable received JSON, including future properties.
  final Map<String, dynamic> rawJson;

  /// Parses required fields with contextual errors that omit payload values.
  factory SafetyCase.fromJson(Map<String, dynamic> json) {
    final snapshot = _safetySnapshot(json, 'SafetyCase');
    _safetyObject(snapshot, 'safety.case', 'SafetyCase');
    return SafetyCase(
      id: requireJsonString(snapshot['id'], 'SafetyCase.id'),
      createdAt: requireJsonInt(
        snapshot['created_at'],
        'SafetyCase.created_at',
      ),
      entityIdentifier: requireJsonString(
        snapshot['entity_identifier'],
        'SafetyCase.entity_identifier',
      ),
      reason: _safetyNullableString(snapshot, 'reason', 'SafetyCase'),
      notice: SafetyCaseNotice.fromJson(
        requireJsonObject(snapshot['notice'], 'SafetyCase.notice'),
      ),
      rawJson: snapshot,
    );
  }

  /// Copies all fields; explicit null clears [reason].
  ///
  /// A replacement [notice] serializes its complete JSON without retaining
  /// metadata from the old child. Empty [rawJson] removes future properties.
  SafetyCase copyWith({
    String? id,
    int? createdAt,
    String? entityIdentifier,
    Object? reason = unsetCopyWithValue,
    SafetyCaseNotice? notice,
    Map<String, dynamic>? rawJson,
  }) => SafetyCase(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    entityIdentifier: entityIdentifier ?? this.entityIdentifier,
    reason: identical(reason, unsetCopyWithValue)
        ? this.reason
        : _safetyCopyString(reason, 'SafetyCase.reason'),
    notice: notice ?? this.notice,
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  Map<String, dynamic> _valueJson() => toJson();

  /// Serializes effective typed fields and preserves future received properties.
  Map<String, dynamic> toJson() => _safetySnapshot(
    _safetyMerge(
      rawJson,
      const {
        'id',
        'object',
        'created_at',
        'entity_identifier',
        'reason',
        'notice',
      },
      {
        'id': id,
        'object': object,
        'created_at': createdAt,
        'entity_identifier': entityIdentifier,
        'reason': reason,
        'notice': notice.toJson(),
      },
    ),
    'SafetyCase JSON',
  );

  @override
  String toString() =>
      'SafetyCase('
      'id: [redacted], createdAt: $createdAt, entityIdentifier: [redacted], '
      'reason: ${reason == null ? 'null' : '[redacted]'}, notice: $notice, '
      'object: $object, rawJson: [redacted])';
}
