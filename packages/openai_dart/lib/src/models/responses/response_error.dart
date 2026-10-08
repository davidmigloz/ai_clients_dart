import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../common/json_helpers.dart';
import 'misalignment_details.dart';
import 'websocket/websocket_json_helpers.dart';

export 'misalignment_details.dart';

/// Error details for a failed Responses API response.
///
/// The canonical shape requires `code` and `message`, and optionally supplies
/// [misalignment]. It does not declare `type`, `param`, or response headers.
/// For compatibility, parsing and const construction retain the older optional
/// `type`/`param` and omitted or nullable `code` behavior. Unknown code strings
/// also survive as receive-only tolerance for future provider classifications;
/// these legacy shapes are not claims of exact canonical admission.
///
/// Parsed JSON is finite and deeply immutable. Const construction retains
/// caller-owned collections. Equality and hashing compare effective wire values,
/// including presence and future metadata. Diagnostics redact sensitive content.
@immutable
class ResponseError {
  /// Legacy error type, defaulting to `'error'` when omitted or null on input.
  ///
  /// Serialized only when [hasType] is true. Canonical responses omit this key.
  final String type;

  /// Error code. Legacy input may omit it or return explicit null.
  final String? code;

  /// Human-readable error text, which can contain sensitive user data.
  final String message;

  /// Legacy nullable parameter associated with the error.
  final String? param;

  /// Whether the legacy `type` key is emitted.
  final bool hasType;

  /// Whether `code` is present, including explicit legacy null.
  final bool hasCode;

  /// Whether legacy `param` is present, including explicit null.
  final bool hasParam;

  /// Optional passive review/block metadata shared with HTTP and WebSocket errors.
  final ResponsesMisalignmentDetails? misalignment;

  /// Original deeply immutable JSON after parsing, including future fields.
  final Map<String, dynamic> rawJson;

  /// Creates an error, preserving old const constructor calls.
  ///
  /// Supply `code` and `message` alone for the canonical failed-response shape.
  /// Presence flags can explicitly distinguish omission from nullable legacy
  /// values. Collection ownership remains with the caller for const compatibility.
  const ResponseError({
    String? type,
    this.code,
    required this.message,
    this.param,
    bool? hasType,
    bool? hasCode,
    bool? hasParam,
    this.misalignment,
    this.rawJson = const {},
  }) : type = type ?? 'error',
       hasType = hasType ?? type != null,
       hasCode = (hasCode ?? false) || code != null,
       hasParam = (hasParam ?? false) || param != null;

  /// Parses canonical fields and explicitly documented legacy input.
  ///
  /// A supplied `misalignment` must be a valid nonnull object; best-effort HTTP
  /// metadata extraction is handled by the HTTP exception layer instead.
  factory ResponseError.fromJson(Map<String, dynamic> json) {
    final snapshot = snapshotResponsesJson(json, 'ResponseError');
    return ResponseError(
      type: optionalJsonString(
        snapshot,
        'type',
        'ResponseError',
        nullable: true,
      ),
      code: optionalJsonString(
        snapshot,
        'code',
        'ResponseError',
        nullable: true,
      ),
      message: requireJsonString(snapshot['message'], 'ResponseError.message'),
      param: optionalJsonString(
        snapshot,
        'param',
        'ResponseError',
        nullable: true,
      ),
      hasType: snapshot.containsKey('type'),
      hasCode: snapshot.containsKey('code'),
      hasParam: snapshot.containsKey('param'),
      misalignment: snapshot.containsKey('misalignment')
          ? ResponsesMisalignmentDetails.fromJson(
              requireJsonObject(
                snapshot['misalignment'],
                'ResponseError.misalignment',
              ),
            )
          : null,
      rawJson: snapshot,
    );
  }

  /// Serializes effective fields without inventing legacy keys.
  Map<String, dynamic> toJson() {
    snapshotResponsesJson(rawJson, 'ResponseError');
    return _valueJson();
  }

  Map<String, dynamic> _valueJson() => mergeResponsesJson(
    rawJson,
    const {'type', 'code', 'message', 'param', 'misalignment'},
    {
      if (hasType) 'type': type,
      if (hasCode) 'code': code,
      'message': message,
      if (hasParam) 'param': param,
      if (misalignment != null)
        'misalignment': mergeResponsesModelJson(
          rawJson['misalignment'],
          misalignment!.toJson(),
          const {
            'detailed_explanation',
            'error_type',
            'review_target',
            'steer',
          },
          childKeys: const {
            'steer': {'message'},
          },
        ),
    },
  );

  /// Copies all fields. Explicit null emits nullable legacy code/param; clear
  /// their presence flag too to restore omission. `misalignment: null` omits
  /// that nonnullable optional object. Fresh children replace their metadata;
  /// an explicit [rawJson] override keeps its caller-supplied future fields.
  ResponseError copyWith({
    String? type,
    Object? code = unsetCopyWithValue,
    String? message,
    Object? param = unsetCopyWithValue,
    bool? hasType,
    bool? hasCode,
    bool? hasParam,
    Object? misalignment = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) {
    final replacingDetails = !identical(misalignment, unsetCopyWithValue);
    final details = identical(misalignment, unsetCopyWithValue)
        ? this.misalignment
        : misalignment as ResponsesMisalignmentDetails?;
    final retainedRaw = rawJson ?? this.rawJson;
    final reconciledRaw = !replacingDetails || rawJson != null
        ? retainedRaw
        : replaceResponsesTypedJson(
            retainedRaw,
            {
              if (this.misalignment != null)
                'misalignment': _valueJson()['misalignment'],
            },
            {if (details != null) 'misalignment': details.toJson()},
          );
    return ResponseError(
      type: type ?? this.type,
      code: identical(code, unsetCopyWithValue) ? this.code : code as String?,
      message: message ?? this.message,
      param: identical(param, unsetCopyWithValue)
          ? this.param
          : param as String?,
      hasType: hasType ?? (type != null || this.hasType),
      hasCode:
          hasCode ?? (!identical(code, unsetCopyWithValue) || this.hasCode),
      hasParam:
          hasParam ?? (!identical(param, unsetCopyWithValue) || this.hasParam),
      misalignment: details,
      rawJson: replacingDetails && rawJson == null
          ? freezeJsonObject(reconciledRaw)
          : reconciledRaw,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseError &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(_valueJson(), other._valueJson());

  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(_valueJson()));

  @override
  String toString() =>
      'ResponseError(type: [REDACTED], code: ${responsesPresence(code)}, '
      'message: [REDACTED], param: ${responsesPresence(param)}, '
      'hasType: $hasType, hasCode: $hasCode, hasParam: $hasParam, '
      'misalignment: ${responsesPresence(misalignment)}, '
      'rawJson: ${rawJson.length} entries)';
}
