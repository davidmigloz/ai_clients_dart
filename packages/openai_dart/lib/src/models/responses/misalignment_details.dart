import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../common/json_helpers.dart';
import 'websocket/websocket_json_helpers.dart';

/// Optional public explanation, open classification and continuation metadata.
@immutable
class ResponsesMisalignmentDetails {
  /// The public explanation for the block.
  final String? detailedExplanation;

  /// Open classification string; unknown values are preserved.
  final String? errorType;

  /// Opaque review target; sensitive and nullable when present.
  final String? reviewTarget;

  /// Distinguishes an absent review target from explicit null.
  final bool hasReviewTarget;

  /// Opaque public instruction; clients must not interpret or execute it automatically.
  final ResponsesMisalignmentSteer? steer;

  /// Original immutable JSON, including future details.
  final Map<String, dynamic> rawJson;

  /// Creates review details, preserving const caller-owned collection construction.
  /// Parsed JSON instead takes a deeply immutable, finite snapshot.
  const ResponsesMisalignmentDetails({
    this.detailedExplanation,
    this.errorType,
    this.reviewTarget,
    bool hasReviewTarget = false,
    this.steer,
    this.rawJson = const {},
  }) : hasReviewTarget = hasReviewTarget || reviewTarget != null;

  /// Parses every canonical member with contextual validation.
  factory ResponsesMisalignmentDetails.fromJson(Map<String, dynamic> json) {
    final snapshot = snapshotResponsesJson(
      json,
      'ResponsesMisalignmentDetails',
    );
    final target = optionalJsonString(
      snapshot,
      'review_target',
      'ResponsesMisalignmentDetails',
      nullable: true,
    );
    _validateReviewTarget(target);
    return ResponsesMisalignmentDetails(
      detailedExplanation: optionalJsonString(
        snapshot,
        'detailed_explanation',
        'ResponsesMisalignmentDetails',
      ),
      errorType: optionalJsonString(
        snapshot,
        'error_type',
        'ResponsesMisalignmentDetails',
      ),
      reviewTarget: target,
      hasReviewTarget: snapshot.containsKey('review_target'),
      steer: snapshot.containsKey('steer')
          ? ResponsesMisalignmentSteer.fromJson(
              requireJsonObject(
                snapshot['steer'],
                'ResponsesMisalignmentDetails.steer',
              ),
            )
          : null,
      rawJson: snapshot,
    );
  }

  /// Converts to JSON with exact nullable target presence.
  Map<String, dynamic> toJson() {
    _validate();
    return _valueJson();
  }

  void _validate() {
    _validateReviewTarget(reviewTarget);
    snapshotResponsesJson(rawJson, 'ResponsesMisalignmentDetails');
  }

  Map<String, dynamic> _valueJson() => mergeResponsesJson(
    rawJson,
    const {'detailed_explanation', 'error_type', 'review_target', 'steer'},
    {
      if (detailedExplanation != null)
        'detailed_explanation': detailedExplanation,
      if (errorType != null) 'error_type': errorType,
      if (reviewTarget != null || hasReviewTarget)
        'review_target': reviewTarget,
      if (steer != null)
        'steer': mergeResponsesModelJson(
          rawJson['steer'],
          steer!.toJson(),
          const {'message'},
        ),
    },
  );

  /// Copies every field, allowing optional fields to be cleared. Explicit null
  /// target retains its key; also set `hasReviewTarget: false` to omit it.
  ResponsesMisalignmentDetails copyWith({
    Object? detailedExplanation = unsetCopyWithValue,
    Object? errorType = unsetCopyWithValue,
    Object? reviewTarget = unsetCopyWithValue,
    bool? hasReviewTarget,
    Object? steer = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) {
    final replacingSteer = !identical(steer, unsetCopyWithValue);
    final retainedRaw = rawJson ?? this.rawJson;
    final newSteer = identical(steer, unsetCopyWithValue)
        ? this.steer
        : steer as ResponsesMisalignmentSteer?;
    final reconciledRaw = !replacingSteer || rawJson != null
        ? retainedRaw
        : replaceResponsesTypedJson(
            retainedRaw,
            {if (this.steer != null) 'steer': _valueJson()['steer']},
            {if (newSteer != null) 'steer': newSteer.toJson()},
          );
    return ResponsesMisalignmentDetails(
      detailedExplanation: identical(detailedExplanation, unsetCopyWithValue)
          ? this.detailedExplanation
          : detailedExplanation as String?,
      errorType: identical(errorType, unsetCopyWithValue)
          ? this.errorType
          : errorType as String?,
      reviewTarget: identical(reviewTarget, unsetCopyWithValue)
          ? this.reviewTarget
          : reviewTarget as String?,
      hasReviewTarget:
          hasReviewTarget ??
          (!identical(reviewTarget, unsetCopyWithValue) ||
              this.hasReviewTarget),
      steer: identical(steer, unsetCopyWithValue)
          ? this.steer
          : steer as ResponsesMisalignmentSteer?,
      rawJson: replacingSteer && rawJson == null
          ? freezeJsonObject(reconciledRaw)
          : reconciledRaw,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponsesMisalignmentDetails &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(_valueJson(), other._valueJson());

  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(_valueJson()));

  @override
  String toString() =>
      'ResponsesMisalignmentDetails('
      'detailedExplanation: ${responsesPresence(detailedExplanation)}, '
      'errorType: ${responsesPresence(errorType)}, '
      'reviewTarget: ${responsesPresence(reviewTarget)}, '
      'hasReviewTarget: $hasReviewTarget, steer: ${responsesPresence(steer)}, '
      'rawJson: ${rawJson.length} entries)';
}

/// A public continuation instruction included with misalignment details.
@immutable
class ResponsesMisalignmentSteer {
  /// Human-readable opaque instruction, potentially sensitive.
  final String message;

  /// Original immutable JSON, including future fields.
  final Map<String, dynamic> rawJson;

  /// Creates an instruction.
  const ResponsesMisalignmentSteer({
    required this.message,
    this.rawJson = const {},
  });

  /// Parses its required message without discarding future keys.
  factory ResponsesMisalignmentSteer.fromJson(Map<String, dynamic> json) {
    final snapshot = snapshotResponsesJson(json, 'ResponsesMisalignmentSteer');
    return ResponsesMisalignmentSteer(
      message: requireJsonString(
        snapshot['message'],
        'ResponsesMisalignmentSteer.message',
      ),
      rawJson: snapshot,
    );
  }

  /// Converts to JSON; typed edits take precedence over original JSON.
  Map<String, dynamic> toJson() {
    snapshotResponsesJson(rawJson, 'ResponsesMisalignmentSteer');
    return mergeResponsesJson(rawJson, const {'message'}, {'message': message});
  }

  /// Copies both typed and raw metadata.
  ResponsesMisalignmentSteer copyWith({
    String? message,
    Map<String, dynamic>? rawJson,
  }) => ResponsesMisalignmentSteer(
    message: message ?? this.message,
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponsesMisalignmentSteer &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(toJson(), other.toJson());

  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(toJson()));

  @override
  String toString() =>
      'ResponsesMisalignmentSteer(message: [REDACTED], '
      'rawJson: ${rawJson.length} entries)';
}

final _reviewTargetPattern = RegExp(r'^[A-Za-z0-9._~:-]+$');

void _validateReviewTarget(String? target) {
  if (target != null &&
      (target.isEmpty ||
          target.length > 96 ||
          !_reviewTargetPattern.hasMatch(target) ||
          target.codeUnits.any(
            (unit) => unit > 127 || unit == 10 || unit == 13,
          ))) {
    throw const FormatException(
      'ResponsesMisalignmentDetails.review_target: expected 1–96 permitted '
      'ASCII characters',
    );
  }
}
