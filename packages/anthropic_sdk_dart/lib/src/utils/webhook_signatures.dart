import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Verifies a Standard Webhooks HMAC-SHA256 signature before parsing the body.
void verifyWebhookSignature(
  String payload,
  Map<String, String> headers,
  String signingSecret,
  DateTime receivedAt,
) {
  final normalized = headers.map(
    (name, value) => MapEntry(name.toLowerCase(), value),
  );
  final id = normalized['webhook-id'];
  final signature = normalized['webhook-signature'];
  final timestampHeader = normalized['webhook-timestamp'];
  if (id == null ||
      id.isEmpty ||
      signature == null ||
      signature.isEmpty ||
      timestampHeader == null) {
    throw const FormatException('Missing required webhook signature headers');
  }

  final timestamp = int.tryParse(timestampHeader, radix: 10);
  final receivedSeconds = receivedAt.millisecondsSinceEpoch ~/ 1000;
  const tolerance = 5 * 60;
  if (timestamp == null ||
      timestamp < receivedSeconds - tolerance ||
      timestamp > receivedSeconds + tolerance) {
    throw const FormatException(
      'Invalid or expired webhook delivery timestamp',
    );
  }

  const prefix = 'whsec_';
  final encoded = signingSecret.startsWith(prefix)
      ? signingSecret.substring(prefix.length)
      : signingSecret;
  final List<int> key;
  try {
    key = base64Decode(encoded);
  } on FormatException {
    throw const FormatException('Invalid webhook signing secret');
  }
  if (key.isEmpty) {
    throw const FormatException('Invalid webhook signing secret');
  }

  final expected = Hmac(
    sha256,
    key,
  ).convert(utf8.encode('$id.$timestamp.$payload'));
  for (final candidate in signature.split(RegExp(r'\s+'))) {
    if (!candidate.startsWith('v1,')) continue;
    try {
      if (Digest(base64Decode(candidate.substring(3))) == expected) return;
    } on FormatException {
      // Continue when another signature in the header may be valid.
    }
  }
  throw const FormatException('No matching webhook signature');
}
