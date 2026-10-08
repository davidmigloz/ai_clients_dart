import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:meta/meta.dart';

import '../../models/webhooks/webhook_event.dart';
import '../../platform/environment.dart';
import '../../utils/webhooks/webhook_verification_test_hooks.dart';

/// A webhook delivery failed signature or timestamp verification.
///
/// This local exception is separate from the sealed HTTP/client exception
/// hierarchy. Its diagnostic contains a reason, never delivery contents, header
/// values, signing keys or digests.
@immutable
class InvalidWebhookSignatureException implements Exception {
  /// Creates a signature failure with a safe diagnostic [message].
  const InvalidWebhookSignatureException(this.message);

  /// A description of the verification failure.
  final String message;

  @override
  String toString() => 'InvalidWebhookSignatureException: $message';
}

/// Verifies signed webhook deliveries locally before parsing their body.
///
/// No API key, HTTP client or network call is involved. Deploy signing secrets
/// only on trusted infrastructure. Parsing an event directly does not verify it.
///
/// A `whsec_` secret contains canonical padded standard Base64 key bytes. Other
/// secrets are literal UTF-8 keys. An explicit per-call secret takes precedence;
/// an empty override is a configuration error rather than a fallback.
class WebhookVerifier {
  /// Creates a local verifier with an optional configured signing [secret].
  // The public option name deliberately differs from the private storage.
  // ignore: prefer_initializing_formals
  const WebhookVerifier({String? secret}) : _secret = secret;

  /// Reads `OPENAI_WEBHOOK_SECRET` without requiring an API key.
  ///
  /// Missing or empty configuration fails safely when verification is requested.
  /// Environment access throws [UnsupportedError] on browser platforms; pass an
  /// explicit secret on trusted infrastructure instead.
  factory WebhookVerifier.fromEnvironment() =>
      WebhookVerifier(secret: getEnvironmentVariable('OPENAI_WEBHOOK_SECRET'));

  final String? _secret;

  /// Verifies the untouched UTF-8 encoding of [body].
  ///
  /// Required headers are case-insensitive and unambiguous. Timestamp text must
  /// contain ASCII digits in 0..2^53-1; its original spelling is signed. Bounds
  /// are inclusive around current UTC integer seconds. [tolerance] must be
  /// nonnegative; fractional durations are compared without rounding.
  ///
  /// `v1,<Base64>` and bare canonical Base64 signature candidates are supported.
  /// Unknown versions and malformed candidates are ignored while trying others.
  /// The body HMAC is computed once, including with large rotation lists.
  void verifySignature(
    String body,
    Map<String, String> headers, {
    String? secret,
    Duration tolerance = const Duration(minutes: 5),
  }) => verifySignatureBytes(
    utf8.encode(body),
    headers,
    secret: secret,
    tolerance: tolerance,
  );

  /// Verifies the original [body] bytes without decoding or reserializing them.
  ///
  /// Signed non-JSON and invalid UTF-8 bytes are valid for verification-only use.
  /// Elements outside the byte range are configuration errors. See
  /// [verifySignature] for header, secret and tolerance policy.
  void verifySignatureBytes(
    List<int> body,
    Map<String, String> headers, {
    String? secret,
    Duration tolerance = const Duration(minutes: 5),
  }) {
    final key = _secretBytes(secret ?? _secret);
    final toleranceMicros = tolerance.inMicroseconds;
    if (!toleranceMicros.isFinite || toleranceMicros < 0) {
      throw ArgumentError(
        'WebhookVerifier: tolerance must be nonnegative and finite.',
      );
    }
    for (final byte in body) {
      if (byte < 0 || byte > 255) {
        throw ArgumentError('WebhookVerifier: body must contain only bytes.');
      }
    }

    final delivery = _requiredHeaders(headers);
    final timestamp = _timestamp(delivery.timestamp);
    final milliseconds = webhookVerificationNow()
        .toUtc()
        .millisecondsSinceEpoch;
    var nowSeconds = milliseconds ~/ Duration.millisecondsPerSecond;
    if (milliseconds < 0 &&
        milliseconds % Duration.millisecondsPerSecond != 0) {
      nowSeconds--;
    }
    final distanceMicros =
        (BigInt.from(timestamp) - BigInt.from(nowSeconds)).abs() *
        BigInt.from(Duration.microsecondsPerSecond);
    if (distanceMicros > BigInt.from(toleranceMicros)) {
      throw const InvalidWebhookSignatureException(
        'Webhook timestamp is outside the allowed tolerance.',
      );
    }

    // Add the prefix and original body separately to avoid copying a large body
    // into a new list or recomputing it for each rotation candidate.
    final result = _DigestSink();
    observeWebhookHmac();
    Hmac(sha256, key).startChunkedConversion(result)
      ..add(utf8.encode('${delivery.id}.${delivery.timestamp}.'))
      ..add(body)
      ..close();
    // The sink closes synchronously; retain no body or signing-key references.
    final expected = result.digest!.bytes;
    var matched = false;
    for (final candidate in _signatureCandidates(delivery.signature)) {
      final decoded = _canonicalBase64(candidate);
      if (decoded == null || decoded.length != expected.length) {
        continue;
      }
      var difference = 0;
      for (var index = 0; index < expected.length; index++) {
        difference |= expected[index] ^ decoded[index];
        observeWebhookComparisonByte();
      }
      if (difference == 0) matched = true;
    }
    if (!matched) {
      throw const InvalidWebhookSignatureException(
        'Webhook signature does not match any supported candidate.',
      );
    }
  }

  /// Verifies [body], then parses the authenticated UTF-8 JSON event.
  ///
  /// Verification failure takes precedence over JSON or model failure. Parse
  /// diagnostics omit body text and underlying decoder exceptions. Applications
  /// own acknowledgment, deduplication and all later workflow actions.
  WebhookEvent unwrap(
    String body,
    Map<String, String> headers, {
    String? secret,
    Duration tolerance = const Duration(minutes: 5),
  }) => unwrapBytes(
    utf8.encode(body),
    headers,
    secret: secret,
    tolerance: tolerance,
  );

  /// Verifies original bytes, then strictly decodes UTF-8/JSON and the event.
  ///
  /// Unlike [verifySignatureBytes], invalid UTF-8 or non-JSON authenticated bodies
  /// fail with a safe [FormatException] whose source is absent.
  WebhookEvent unwrapBytes(
    List<int> body,
    Map<String, String> headers, {
    String? secret,
    Duration tolerance = const Duration(minutes: 5),
  }) {
    verifySignatureBytes(body, headers, secret: secret, tolerance: tolerance);
    final String text;
    try {
      text = utf8.decode(body);
    } on FormatException {
      throw const FormatException(
        'WebhookVerifier.unwrapBytes: signed body is not valid UTF-8.',
      );
    }
    final Object? decoded;
    try {
      decoded = jsonDecode(text);
    } on FormatException {
      throw const FormatException(
        'WebhookVerifier.unwrapBytes: signed body is not valid JSON.',
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'WebhookVerifier.unwrapBytes: signed body must be a JSON object.',
      );
    }
    try {
      return WebhookEvent.fromJson(decoded);
    } on FormatException {
      throw const FormatException(
        'WebhookVerifier.unwrapBytes: signed body is not a valid webhook event.',
      );
    }
  }

  @override
  String toString() =>
      'WebhookVerifier(secret: ${_secret == null ? 'not configured' : '[REDACTED]'})';
}

List<int> _secretBytes(String? secret) {
  if (secret == null || secret.isEmpty) {
    throw ArgumentError(
      'WebhookVerifier: a nonempty webhook secret is required.',
    );
  }
  if (!secret.startsWith('whsec_')) return utf8.encode(secret);
  final decoded = _canonicalBase64(secret.substring(6));
  if (decoded == null || decoded.isEmpty) {
    throw ArgumentError(
      'WebhookVerifier: prefixed secret must contain canonical padded standard Base64.',
    );
  }
  return decoded;
}

({String id, String timestamp, String signature}) _requiredHeaders(
  Map<String, String> headers,
) {
  String? id;
  String? timestamp;
  String? signature;
  for (final entry in headers.entries) {
    switch (entry.key.toLowerCase()) {
      case 'webhook-id':
        if (id != null) {
          throw const InvalidWebhookSignatureException(
            'Ambiguous webhook-id header.',
          );
        }
        id = entry.value;
      case 'webhook-timestamp':
        if (timestamp != null) {
          throw const InvalidWebhookSignatureException(
            'Ambiguous webhook-timestamp header.',
          );
        }
        timestamp = entry.value;
      case 'webhook-signature':
        if (signature != null) {
          throw const InvalidWebhookSignatureException(
            'Ambiguous webhook-signature header.',
          );
        }
        signature = entry.value;
    }
  }
  if (id == null || id.isEmpty) {
    throw const InvalidWebhookSignatureException(
      'A nonempty webhook-id header is required.',
    );
  }
  if (timestamp == null || timestamp.isEmpty) {
    throw const InvalidWebhookSignatureException(
      'A nonempty webhook-timestamp header is required.',
    );
  }
  if (signature == null || signature.isEmpty) {
    throw const InvalidWebhookSignatureException(
      'A nonempty webhook-signature header is required.',
    );
  }
  return (id: id, timestamp: timestamp, signature: signature);
}

int _timestamp(String value) {
  var firstNonzero = value.length;
  for (var index = 0; index < value.length; index++) {
    final code = value.codeUnitAt(index);
    if (code < 48 || code > 57) {
      throw const InvalidWebhookSignatureException(
        'Webhook timestamp must contain only ASCII decimal digits.',
      );
    }
    if (code != 48 && firstNonzero == value.length) firstNonzero = index;
  }
  final significant = value.substring(firstNonzero);
  const maximum = '9007199254740991';
  if (significant.length > maximum.length ||
      (significant.length == maximum.length &&
          significant.compareTo(maximum) > 0)) {
    throw const InvalidWebhookSignatureException(
      'Webhook timestamp exceeds the supported safe integer range.',
    );
  }
  return significant.isEmpty ? 0 : int.parse(significant);
}

List<int>? _canonicalBase64(String value) {
  if (value.isEmpty || value.length % 4 != 0) return null;
  var padding = 0;
  for (var index = 0; index < value.length; index++) {
    final code = value.codeUnitAt(index);
    if (code == 61) {
      padding++;
      if (padding > 2) return null;
    } else {
      if (padding != 0 ||
          !((code >= 65 && code <= 90) ||
              (code >= 97 && code <= 122) ||
              (code >= 48 && code <= 57) ||
              code == 43 ||
              code == 47)) {
        return null;
      }
    }
  }
  try {
    final decoded = base64.decode(value);
    return base64.encode(decoded) == value ? decoded : null;
  } on FormatException {
    return null;
  }
}

Iterable<String> _signatureCandidates(String header) sync* {
  var offset = 0;
  while (offset < header.length) {
    while (offset < header.length &&
        _isAsciiWhitespace(header.codeUnitAt(offset))) {
      offset++;
    }
    final start = offset;
    while (offset < header.length &&
        !_isAsciiWhitespace(header.codeUnitAt(offset))) {
      offset++;
    }
    if (start == offset) continue;
    final token = header.substring(start, offset);
    if (token.startsWith('v1,')) {
      yield token.substring(3);
    } else if (!token.contains(',')) {
      yield token;
    }
  }
}

bool _isAsciiWhitespace(int code) => code == 32 || (code >= 9 && code <= 13);

class _DigestSink implements Sink<Digest> {
  Digest? digest;

  @override
  void add(Digest data) => digest = data;

  @override
  void close() {}
}
