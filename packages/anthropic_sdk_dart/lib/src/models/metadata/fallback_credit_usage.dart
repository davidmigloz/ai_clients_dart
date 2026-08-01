import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Why a fallback-credit reprice was not applied to a response's billing.
///
/// A closed enum; additions to the redemption-check vocabulary arrive as
/// deliberate schema updates.
enum FallbackCreditNotAppliedReason {
  /// The retry's request body did not match the refused request's body.
  bodyMismatch('body_mismatch'),

  /// The token was minted mid-server-tool-loop and its partial content was
  /// continuable, but the retry did not use the appended-assistant form.
  continuationExcluded('continuation_excluded'),

  /// The token may only be redeemed with the appended-assistant retry form.
  continuationOnly('continuation_only'),

  /// The token's five-minute redemption window had elapsed.
  expired('expired'),

  /// The retry model is not an eligible fallback target for this token.
  invalidTargetModel('invalid_target_model'),

  /// Fallback credit is not enabled for this organization or workspace.
  notEnabled('not_enabled'),

  /// A reprice could not be computed for this request.
  repriceUnavailable('reprice_unavailable'),

  /// The redemption check was temporarily unavailable; retrying later may
  /// succeed.
  temporarilyUnavailable('temporarily_unavailable'),

  /// The retry body includes fields from a variant sealed hash; see
  /// [FallbackCreditNotApplied.removeToRedeem] for which fields to remove.
  variantFieldsPresent('variant_fields_present'),

  /// The token was minted for a different organization.
  wrongOrganization('wrong_organization'),

  /// The token was minted on a different platform.
  wrongPlatform('wrong_platform'),

  /// The token was minted for a different workspace.
  wrongWorkspace('wrong_workspace'),

  /// Unrecognized reason — fallback for unrecognized values.
  unknown('unknown');

  const FallbackCreditNotAppliedReason(this.value);

  /// JSON value for this reason.
  final String value;

  /// Parses a [FallbackCreditNotAppliedReason] from JSON.
  static FallbackCreditNotAppliedReason fromJson(String value) =>
      switch (value) {
        'body_mismatch' => bodyMismatch,
        'continuation_excluded' => continuationExcluded,
        'continuation_only' => continuationOnly,
        'expired' => expired,
        'invalid_target_model' => invalidTargetModel,
        'not_enabled' => notEnabled,
        'reprice_unavailable' => repriceUnavailable,
        'temporarily_unavailable' => temporarilyUnavailable,
        'variant_fields_present' => variantFieldsPresent,
        'wrong_organization' => wrongOrganization,
        'wrong_platform' => wrongPlatform,
        'wrong_workspace' => wrongWorkspace,
        _ => unknown,
      };

  /// Converts this reason to JSON.
  String toJson() => value;
}

/// Whether the fallback-credit reprice was applied to a response's billing.
///
/// A union discriminated on `type`.
///
/// Variants:
/// - [FallbackCreditRedeemed] — `redeemed`: the retry is billed as if the
///   conversation had been on the retry model all along.
/// - [FallbackCreditNotApplied] — `not_applied`: no reprice was applied;
///   [FallbackCreditNotApplied.reason] says why.
/// - [UnknownFallbackCreditStatus] — unrecognized `type`, for forward
///   compatibility.
sealed class FallbackCreditStatus {
  const FallbackCreditStatus();

  /// Creates a [FallbackCreditRedeemed] status.
  const factory FallbackCreditStatus.redeemed() = FallbackCreditRedeemed;

  /// Creates a [FallbackCreditNotApplied] status.
  const factory FallbackCreditStatus.notApplied({
    required FallbackCreditNotAppliedReason reason,
    List<String>? removeToRedeem,
  }) = FallbackCreditNotApplied;

  /// Creates a [FallbackCreditStatus] from JSON.
  ///
  /// Dispatches on the `type` discriminator; unrecognized values fall back to
  /// [UnknownFallbackCreditStatus].
  factory FallbackCreditStatus.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'redeemed' => FallbackCreditRedeemed.fromJson(json),
      'not_applied' => FallbackCreditNotApplied.fromJson(json),
      _ => UnknownFallbackCreditStatus(rawJson: json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// The reprice was applied: the retry is billed as if the conversation had
/// been on the retry model all along — including when the resulting shift is
/// zero because there was nothing to move.
@immutable
class FallbackCreditRedeemed extends FallbackCreditStatus {
  /// Creates a [FallbackCreditRedeemed].
  const FallbackCreditRedeemed();

  /// Creates a [FallbackCreditRedeemed] from JSON.
  factory FallbackCreditRedeemed.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != 'redeemed') {
      throw FormatException(
        'FallbackCreditRedeemed: expected type "redeemed", got "$type"',
      );
    }
    return const FallbackCreditRedeemed();
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'redeemed'};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FallbackCreditRedeemed && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'FallbackCreditRedeemed()';
}

/// No reprice was applied; [reason] says why.
@immutable
class FallbackCreditNotApplied extends FallbackCreditStatus {
  /// Backing field for [reason] when constructed with a typed reason. Null
  /// when constructed via [FallbackCreditNotApplied.raw].
  final FallbackCreditNotAppliedReason? _reason;

  /// Backing field for [rawReason] when constructed via
  /// [FallbackCreditNotApplied.raw]. Null when constructed with a typed
  /// [reason].
  final String? _rawReason;

  /// Why the reprice was not applied.
  FallbackCreditNotAppliedReason get reason =>
      _reason ?? FallbackCreditNotAppliedReason.fromJson(_rawReason!);

  /// The raw wire value for [reason], preserved verbatim.
  ///
  /// Kept alongside the derived [reason] getter so an unrecognized reason
  /// round-trips through `fromJson`/`toJson` instead of being collapsed to
  /// the literal string `"unknown"`.
  String get rawReason => _rawReason ?? _reason!.value;

  /// Request fields to remove before retrying, so the retry can redeem this
  /// token.
  ///
  /// Present exactly when [reason] is
  /// [FallbackCreditNotAppliedReason.variantFieldsPresent] — never null, never
  /// an empty list; absent otherwise. Fields are named only from the caller's
  /// own request, and only after the sealed variant hash matched. A served
  /// best-effort retry has already been billed at normal price; nothing
  /// redeems retroactively, but a corrected re-send inside the token's
  /// five-minute window can still redeem.
  final List<String>? removeToRedeem;

  /// Creates a [FallbackCreditNotApplied].
  const FallbackCreditNotApplied({
    required FallbackCreditNotAppliedReason reason,
    this.removeToRedeem,
  }) : _reason = reason,
       _rawReason = null;

  /// Creates a [FallbackCreditNotApplied], preserving [rawReason] verbatim
  /// even when it does not match a known [FallbackCreditNotAppliedReason].
  const FallbackCreditNotApplied.raw({
    required String rawReason,
    this.removeToRedeem,
  }) : _rawReason = rawReason,
       _reason = null;

  /// Creates a [FallbackCreditNotApplied] from JSON.
  factory FallbackCreditNotApplied.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != 'not_applied') {
      throw FormatException(
        'FallbackCreditNotApplied: expected type "not_applied", got "$type"',
      );
    }
    final rawRemoveToRedeem = json['remove_to_redeem'] as List?;
    return FallbackCreditNotApplied.raw(
      rawReason: json['reason'] as String,
      removeToRedeem: rawRemoveToRedeem?.map((e) {
        if (e is! String) {
          throw FormatException(
            'remove_to_redeem: expected String, got ${e.runtimeType}',
          );
        }
        return e;
      }).toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'not_applied',
    'reason': rawReason,
    if (removeToRedeem != null) 'remove_to_redeem': removeToRedeem,
  };

  /// Creates a copy with replaced values.
  FallbackCreditNotApplied copyWith({
    FallbackCreditNotAppliedReason? reason,
    Object? removeToRedeem = unsetCopyWithValue,
  }) => FallbackCreditNotApplied.raw(
    rawReason: reason?.value ?? rawReason,
    removeToRedeem: removeToRedeem == unsetCopyWithValue
        ? this.removeToRedeem
        : removeToRedeem as List<String>?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FallbackCreditNotApplied &&
          runtimeType == other.runtimeType &&
          rawReason == other.rawReason &&
          listsEqual(removeToRedeem, other.removeToRedeem);

  @override
  int get hashCode => Object.hash(rawReason, listHash(removeToRedeem));

  @override
  String toString() =>
      'FallbackCreditNotApplied(reason: $reason, '
      'removeToRedeem: $removeToRedeem)';
}

/// Unrecognized fallback-credit status type — preserves raw JSON for forward
/// compatibility.
@immutable
class UnknownFallbackCreditStatus extends FallbackCreditStatus {
  /// The raw JSON.
  final Map<String, dynamic> rawJson;

  /// Creates an [UnknownFallbackCreditStatus].
  const UnknownFallbackCreditStatus({required this.rawJson});

  @override
  Map<String, dynamic> toJson() => rawJson;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownFallbackCreditStatus &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownFallbackCreditStatus(rawJson: $rawJson)';
}

/// Outcome of the `fallback_credit_token` presented on a request.
///
/// Present on every response to a non-batch request that carried a
/// `fallback_credit_token`, in either redemption mode; absent otherwise (batch
/// items accept and ignore the token and carry no outcome object).
@immutable
class FallbackCreditUsage {
  /// Whether the fallback-credit reprice was applied to this response's
  /// billing.
  final FallbackCreditStatus status;

  /// Creates a [FallbackCreditUsage].
  const FallbackCreditUsage({required this.status});

  /// Creates a [FallbackCreditUsage] from JSON.
  factory FallbackCreditUsage.fromJson(Map<String, dynamic> json) {
    return FallbackCreditUsage(
      status: FallbackCreditStatus.fromJson(
        json['status'] as Map<String, dynamic>,
      ),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'status': status.toJson()};

  /// Creates a copy with replaced values.
  FallbackCreditUsage copyWith({FallbackCreditStatus? status}) {
    return FallbackCreditUsage(status: status ?? this.status);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FallbackCreditUsage &&
          runtimeType == other.runtimeType &&
          status == other.status;

  @override
  int get hashCode => status.hashCode;

  @override
  String toString() => 'FallbackCreditUsage(status: $status)';
}
