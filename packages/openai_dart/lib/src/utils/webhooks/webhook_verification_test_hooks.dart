import 'dart:async';

import 'package:meta/meta.dart';

final Object _clockKey = Object();
final Object _hmacObserverKey = Object();
final Object _comparisonObserverKey = Object();

/// Runs deterministic verification tests without changing signature computation.
///
/// This internal helper is deliberately absent from the package exports. The
/// observers receive no payload, key, headers or digest and cannot replace HMAC
/// or comparison results. Zone scoping keeps concurrent tests isolated.
@visibleForTesting
T runWithWebhookVerificationTestHooks<T>(
  T Function() body, {
  DateTime Function()? now,
  void Function()? onHmac,
  void Function()? onComparisonByte,
}) => runZoned(
  body,
  zoneValues: {
    _clockKey: now ?? Zone.current[_clockKey],
    _hmacObserverKey: onHmac ?? Zone.current[_hmacObserverKey],
    _comparisonObserverKey:
        onComparisonByte ?? Zone.current[_comparisonObserverKey],
  },
);

/// Reads the production clock or the zone-scoped internal test clock.
DateTime webhookVerificationNow() =>
    (Zone.current[_clockKey] as DateTime Function()?)?.call() ?? DateTime.now();

/// Observes a real HMAC computation in deterministic tests.
void observeWebhookHmac() =>
    (Zone.current[_hmacObserverKey] as void Function()?)?.call();

/// Observes one real comparison iteration in deterministic tests.
void observeWebhookComparisonByte() =>
    (Zone.current[_comparisonObserverKey] as void Function()?)?.call();
