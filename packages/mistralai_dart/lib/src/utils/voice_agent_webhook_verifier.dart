import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../models/audio_agents/voice_agent_webhook_event.dart';

/// A Voice Agent webhook did not have a valid signature.
final class VoiceAgentWebhookSignatureException implements Exception {
  /// Creates a signature error without including request or key data.
  const VoiceAgentWebhookSignatureException();

  @override
  String toString() =>
      'VoiceAgentWebhookSignatureException: Invalid webhook signature.';
}

/// Verifies Voice Agent deliveries locally using an endpoint's signing secret.
final class VoiceAgentWebhookVerifier {
  /// Configures the UTF-8 signing secret issued for this webhook endpoint.
  VoiceAgentWebhookVerifier({required String signingSecret})
    : _hmac = Hmac(sha256, utf8.encode(signingSecret)) {
    if (signingSecret.isEmpty) {
      throw ArgumentError('A webhook signing secret is required.');
    }
  }

  /// HTTP header carrying the delivery signature.
  static const signatureHeader = 'x-mistral-signature';

  static const _prefix = 'hmac-sha256=';
  static const _digestSize = 32;

  final Hmac _hmac;

  /// Checks [signature] against the original HTTP request bytes.
  bool verify({required List<int> rawBody, required String? signature}) {
    if (signature == null ||
        !signature.startsWith(_prefix) ||
        signature.length != _prefix.length + _digestSize * 2) {
      return false;
    }

    final received = List<int>.filled(_digestSize, 0);
    for (var i = 0; i < received.length; i++) {
      final offset = _prefix.length + i * 2;
      final high = _hexNibble(signature.codeUnitAt(offset));
      final low = _hexNibble(signature.codeUnitAt(offset + 1));
      if (high < 0 || low < 0) return false;
      received[i] = (high << 4) | low;
    }
    for (final byte in rawBody) {
      if (byte < 0 || byte > 255) {
        throw ArgumentError('The raw webhook body must contain bytes.');
      }
    }

    final expected = _hmac.convert(rawBody).bytes;
    // The received digest has the same fixed length. Compare every byte.
    var difference = 0;
    for (var i = 0; i < expected.length; i++) {
      difference |= expected[i] ^ received[i];
    }
    return difference == 0;
  }

  /// Verifies the signature and then parses the authenticated delivery.
  ///
  /// Throws [VoiceAgentWebhookSignatureException] on signature failure and
  /// [FormatException] when an authenticated body is malformed.
  VoiceAgentWebhookEvent verifyAndParse({
    required List<int> rawBody,
    required String? signature,
  }) {
    if (!verify(rawBody: rawBody, signature: signature)) {
      throw const VoiceAgentWebhookSignatureException();
    }
    try {
      return VoiceAgentWebhookEvent.fromJson(
        jsonDecode(utf8.decode(rawBody)) as Map<String, dynamic>,
      );
    } on FormatException {
      throw const FormatException('Malformed Voice Agent webhook body.');
    } on TypeError {
      throw const FormatException('Malformed Voice Agent webhook body.');
    }
  }

  static int _hexNibble(int code) {
    if (code >= 48 && code <= 57) return code - 48;
    final lower = code | 32;
    if (lower >= 97 && lower <= 102) return lower - 87;
    return -1;
  }
}
