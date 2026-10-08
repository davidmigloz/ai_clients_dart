import 'dart:collection';
import 'dart:convert';

import 'package:openai_dart/src/errors/exceptions.dart';
import 'package:openai_dart/src/models/webhooks/webhook_event.dart';
import 'package:openai_dart/src/resources/webhooks/webhook_verifier.dart';
import 'package:openai_dart/src/utils/webhooks/webhook_verification_test_hooks.dart';
import 'package:test/test.dart';

import 'webhook_verifier_vectors.dart';

const _nowSeconds = 1750861210;
const _secret = 'x';
const _verifier = WebhookVerifier(secret: _secret);
final _now = DateTime.fromMillisecondsSinceEpoch(
  _nowSeconds * 1000,
  isUtc: true,
);

void main() {
  group('official and independent webhook HMAC receipts', () {
    _test('official shared Python/Node golden string and bytes', () {
      final vector = _vector('official');
      final verifier =
          const WebhookVerifier(
              secret: 'whsec_RdvaYFYUXuIFuEbvZHwMfYFhUf7aMYjYcmM24+Aj40c=',
            )
            ..verifySignature(_body(vector), _headers(vector))
            ..verifySignatureBytes(
              utf8.encode(_body(vector)),
              _headers(vector),
            );
      final event = verifier.unwrap(_body(vector), _headers(vector));
      expect(event.toJson(), jsonDecode(_body(vector)));
      expect(
        verifier
            .unwrapBytes(utf8.encode(_body(vector)), _headers(vector))
            .toJson(),
        event.toJson(),
      );
    });

    for (final name in ['unicode', 'bom', 'dotsId', 'spaceId', 'leadingZero']) {
      _test('independent exact bytes receipt: $name', () {
        final vector = _vector(name);
        _verifier
          ..verifySignature(_body(vector), _headers(vector))
          ..verifySignatureBytes(utf8.encode(_body(vector)), _headers(vector));
      });
    }

    _test('Unicode literal and encoded secrets are the same key', () {
      final vector = _vector('unicodeKey');
      const literal = WebhookVerifier(secret: 'clé 🦉');
      final encoded = WebhookVerifier(
        secret: 'whsec_${base64.encode(utf8.encode('clé 🦉'))}',
      );
      literal.verifySignature(_body(vector), _headers(vector));
      encoded.verifySignature(_body(vector), _headers(vector));
    });

    _test('raw x and whsec_eA== keys are equivalent, bare eA== is literal', () {
      final vector = _vector('dotsId');
      _verifier.verifySignature(_body(vector), _headers(vector));
      const WebhookVerifier(
        secret: 'whsec_eA==',
      ).verifySignature(_body(vector), _headers(vector));
      expect(
        () => const WebhookVerifier(
          secret: 'eA==',
        ).verifySignature(_body(vector), _headers(vector)),
        throwsA(isA<InvalidWebhookSignatureException>()),
      );
      final literal = _vector('literalBase64Key');
      const WebhookVerifier(
        secret: 'eA==',
      ).verifySignature(_body(literal), _headers(literal));
      expect(
        () => _verifier.verifySignature(_body(literal), _headers(literal)),
        throwsA(isA<InvalidWebhookSignatureException>()),
      );
    });

    for (final mutation in [
      'trailing space',
      'newline deletion',
      'Unicode normalization',
      'JSON reserialization',
    ]) {
      _test('original signed text rejects $mutation', () {
        final vector = _vector('unicode');
        final body = _body(vector);
        final changed = switch (mutation) {
          'trailing space' => '$body ',
          'newline deletion' => body.replaceAll('\r\n', ''),
          'Unicode normalization' => body.replaceAll('é', 'é'),
          _ => jsonEncode(jsonDecode(body)),
        };
        expect(changed, isNot(body));
        expect(
          () => _verifier.verifySignature(changed, _headers(vector)),
          throwsA(isA<InvalidWebhookSignatureException>()),
        );
      });
    }

    _test(
      'changed delivery ID is rejected without interpreting dot segments',
      () {
        final vector = _vector('dotsId');
        final headers = _headers(vector)..['webhook-id'] = 'other.delivery';
        expect(
          () => _verifier.verifySignature(_body(vector), headers),
          throwsA(isA<InvalidWebhookSignatureException>()),
        );
      },
    );

    _test(
      'removing BOM and leading whitespace invalidates the exact byte receipt',
      () {
        final vector = _vector('bom');
        final changed = _body(vector).substring(1).trim();
        expect(
          () => _verifier.verifySignature(changed, _headers(vector)),
          throwsA(isA<InvalidWebhookSignatureException>()),
        );
      },
    );

    _test('leading zero spelling is signed instead of normalized', () {
      final vector = _vector('leadingZero');
      final headers = _headers(vector)..['webhook-timestamp'] = '$_nowSeconds';
      expect(
        () => _verifier.verifySignature(_body(vector), headers),
        throwsA(isA<InvalidWebhookSignatureException>()),
      );
    });
  });

  group('secret configuration and diagnostics', () {
    _test('configured secret and null fallback; explicit override wins', () {
      final vector = _vector('dotsId');
      final headers = _headers(vector);
      _verifier.verifySignature(_body(vector), headers, secret: null);
      const WebhookVerifier(
        secret: 'other',
      ).verifySignature(_body(vector), headers, secret: _secret);
      const WebhookVerifier().verifySignature(
        _body(vector),
        headers,
        secret: _secret,
      );
    });

    _test(
      'explicit empty override fails instead of using configured secret',
      () {
        final vector = _vector('dotsId');
        expect(
          () => _verifier.verifySignature(
            _body(vector),
            _headers(vector),
            secret: '',
          ),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.invalidValue,
              'invalidValue',
              isNull,
            ),
          ),
        );
      },
    );

    for (final secret in <String?>[
      null,
      '',
      'whsec_',
      'whsec_eA',
      'whsec_eA=',
      'whsec_eA===',
      'whsec_eB==', // Nonzero discarded pad bits.
      'whsec_eA==garbage',
      'whsec_ eA==',
      'whsec_eA==\n',
      'whsec_eA==\r',
      'whsec_eA==\t',
      'whsec_====',
      'whsec_A===',
      'whsec__w==',
      'whsec_-w==',
      'whsec_SENSITIVE_SECRET',
    ]) {
      _test(
        'missing/malformed configured secret fails safely: ${secret ?? 'missing'}',
        () {
          final vector = _vector('dotsId');
          _expectSafeConfigurationError(
            () => WebhookVerifier(
              secret: secret,
            ).verifySignature(_body(vector), _headers(vector)),
            forbidden: [if (secret != null && secret.isNotEmpty) secret],
          );
        },
      );
    }

    _test(
      'nonprefixed secret is literal including whitespace and Base64-looking text',
      () {
        // This literal has no whsec_ prefix, so it is a nonempty valid key even
        // though it cannot verify a delivery signed with x.
        expect(
          () => const WebhookVerifier(
            secret: ' eA==\n',
          ).verifySignature('{}', _headers(_vector('dotsId'))),
          throwsA(isA<InvalidWebhookSignatureException>()),
        );
      },
    );

    _test('negative tolerance fails with no invalidValue disclosure', () {
      _expectSafeConfigurationError(
        () => _verifier.verifySignature(
          '{}',
          _headers(_vector('dotsId')),
          tolerance: const Duration(microseconds: -1),
        ),
      );
    });

    _test('verifier diagnostics redact configured and empty secrets', () {
      expect(
        const WebhookVerifier(secret: 'SENSITIVE_SECRET').toString(),
        isNot(contains('SENSITIVE_SECRET')),
      );
      expect(
        const WebhookVerifier(secret: '').toString(),
        contains('[REDACTED]'),
      );
      expect(const WebhookVerifier().toString(), contains('not configured'));
    });

    _test('dedicated safe exception stays outside OpenAIException', () {
      const error = InvalidWebhookSignatureException('A safe reason.');
      expect(error, isA<Exception>());
      expect(error, isNot(isA<OpenAIException>()));
      expect(error.message, 'A safe reason.');
      expect(
        error.toString(),
        'InvalidWebhookSignatureException: A safe reason.',
      );
    });
  });

  group('header normalization and exact timestamp policy', () {
    _test(
      'required headers are case-insensitive; unrelated headers are ignored',
      () {
        final vector = _vector('dotsId');
        final headers = {
          'Webhook-ID': vector['id']! as String,
          'WEBHOOK-TIMESTAMP': vector['timestamp']! as String,
          'WeBhOoK-SiGnAtUrE': 'v1,${vector['signature']}',
          'other': 'SENSITIVE_HEADER',
        };
        _verifier.verifySignature(_body(vector), headers);
      },
    );

    for (final name in [
      'webhook-id',
      'webhook-timestamp',
      'webhook-signature',
    ]) {
      for (final scenario in [
        'missing',
        'empty',
        'duplicate',
        'duplicate-empty',
      ]) {
        _test('$name rejects $scenario safely', () {
          final vector = _vector('dotsId');
          final headers = _headers(vector);
          switch (scenario) {
            case 'missing':
              headers.remove(name);
            case 'empty':
              headers[name] = '';
            case 'duplicate':
              headers[name.toUpperCase()] = headers[name]!;
            case 'duplicate-empty':
              headers[name.toUpperCase()] = '';
          }
          _expectSafeSignatureError(
            () => _verifier.verifySignature(_body(vector), headers),
            forbidden: [
              vector['id']! as String,
              vector['signature']! as String,
            ],
          );
        });
      }
    }

    for (final timestamp in [
      ' ',
      ' 1750861210',
      '1750861210 ',
      '+1750861210',
      '-0',
      '-1750861210',
      '1750861210.0',
      '1750861210e0',
      '1750861210suffix',
      '1750861210\n',
      '1750861210\r',
      '1750861210\t',
      '１７５０８６１２１０',
      '١٧٥٠٨٦١٢١٠',
      '9007199254740992',
      '09007199254740992',
      '999999999999999999999999999999',
    ]) {
      _test(
        'timestamp rejects unsupported syntax/range: ${jsonEncode(timestamp)}',
        () {
          final headers = _headers(_vector('dotsId'))
            ..['webhook-timestamp'] = timestamp;
          _expectSafeSignatureError(
            () => _verifier.verifySignature('{}', headers),
            forbidden: [if (timestamp.trim().isNotEmpty) timestamp],
          );
        },
      );
    }

    for (final name in ['pastBoundary', 'futureBoundary']) {
      _test('default five-minute tolerance includes $name', () {
        final vector = _vector(name);
        _verifier.verifySignature(_body(vector), _headers(vector));
      });
    }

    for (final offset in [-301, 301]) {
      _test('outside default boundary fails: $offset seconds', () {
        final headers = _headers(_vector('dotsId'))
          ..['webhook-timestamp'] = '${_nowSeconds + offset}';
        _expectSafeSignatureError(
          () => _verifier.verifySignature('{}', headers),
        );
      });
    }

    for (final name in ['pastSecond', 'futureSecond']) {
      for (final micros in [999999, 1000000, 1000001, 1999999]) {
        _test('exact fractional bound $name at $micros microseconds', () {
          final vector = _vector(name);
          void verify() => _verifier.verifySignature(
            _body(vector),
            _headers(vector),
            tolerance: Duration(microseconds: micros),
          );
          if (micros < 1000000) {
            expect(verify, throwsA(isA<InvalidWebhookSignatureException>()));
          } else {
            verify();
          }
        });
      }
    }

    _test(
      'zero tolerance accepts current integer second despite clock fractions',
      () {
        final vector = _vector('dotsId');
        runWithWebhookVerificationTestHooks(
          () => _verifier.verifySignature(
            _body(vector),
            _headers(vector),
            tolerance: Duration.zero,
          ),
          now: () => _now.add(const Duration(microseconds: 999999)),
        );
      },
    );

    _test('zero is a valid timestamp and clock uses UTC integer seconds', () {
      final vector = _vector('zero');
      runWithWebhookVerificationTestHooks(
        () => _verifier.verifySignature(
          _body(vector),
          _headers(vector),
          tolerance: Duration.zero,
        ),
        now: () =>
            DateTime.fromMillisecondsSinceEpoch(999, isUtc: true).toLocal(),
      );
    });

    for (final name in ['safeMaximum', 'safeMaximumLeading']) {
      _test(
        'safe maximum parses then rejects huge distance without overflow: $name',
        () {
          final vector = _vector(name);
          _expectSafeSignatureError(
            () => _verifier.verifySignature(_body(vector), _headers(vector)),
            reason: 'tolerance',
          );
        },
      );
    }

    _test(
      'large representable tolerance authenticates a distant valid timestamp',
      () {
        final vector = _vector('zero');
        _verifier.verifySignature(
          _body(vector),
          _headers(vector),
          tolerance: const Duration(microseconds: 9007199254740991),
        );
      },
    );
  });

  group('canonical Base64 candidates and rotation', () {
    for (final prefix in ['', 'v1,']) {
      _test(
        'accepts canonical ${prefix.isEmpty ? 'bare' : 'v1'} candidate',
        () {
          final vector = _vector('dotsId');
          final headers = _headers(vector)
            ..['webhook-signature'] = '$prefix${vector['signature']}';
          _verifier.verifySignature(_body(vector), headers);
        },
      );
    }

    for (final separator in [' ', '\t', '\n', '\r', '\v', '\f', '\r\n\t ']) {
      _test(
        'all ASCII whitespace separates candidates: ${jsonEncode(separator)}',
        () {
          final vector = _vector('dotsId');
          final headers = _headers(vector)
            ..['webhook-signature'] =
                '${separator}unknown,x${separator}v1,not-base64${separator}v1,${vector['signature']}$separator';
          _verifier.verifySignature(_body(vector), headers);
        },
      );
    }

    for (final slot in [0, 1, 31, 32, 64, 1599]) {
      _test('accepts matching rotation slot $slot including beyond 32', () {
        final vector = _vector('dotsId');
        final signatures = List<String>.filled(
          slot + 1,
          'v1,${base64.encode(List<int>.filled(32, 0))}',
        )..[slot] = 'v1,${vector['signature']}';
        final headers = _headers(vector)
          ..['webhook-signature'] = signatures.join(' ');
        _verifier.verifySignature(_body(vector), headers);
      });
    }

    final signature = _vector('dotsId')['signature']! as String;
    final badPadBits = '${signature.substring(0, signature.length - 2)}B=';
    for (final candidate in [
      'v2,$signature',
      'V1,$signature',
      'v01,$signature',
      'v1,',
      'v1,${signature.substring(0, signature.length - 1)}',
      'v1,${signature.replaceAll('+', '-').replaceAll('/', '_')}',
      'v1,$badPadBits',
      'v1,$signature=',
      'v1,$signature,',
      'v1,${base64.encode(List<int>.filled(31, 0))}',
      'v1,${base64.encode(List<int>.filled(33, 0))}',
      'v1,AA==',
      'v1,AQ==',
      'v1,====',
      'v1,A===',
      'v1,$signature\u00a0',
      'v1,$signature\u2003',
      'v1,garbage',
    ]) {
      _test(
        'malformed/unknown candidate cannot authenticate: ${jsonEncode(candidate)}',
        () {
          final vector = _vector('dotsId');
          final headers = _headers(vector)..['webhook-signature'] = candidate;
          _expectSafeSignatureError(
            () => _verifier.verifySignature(_body(vector), headers),
          );
        },
      );
      _test(
        'malformed/unknown candidate does not hide later valid candidate: ${jsonEncode(candidate)}',
        () {
          final vector = _vector('dotsId');
          final headers = _headers(vector)
            ..['webhook-signature'] = '$candidate v1,${vector['signature']}';
          _verifier.verifySignature(_body(vector), headers);
        },
      );
    }

    _test(
      'one HMAC with no valid-length candidates, including ASCII whitespace only',
      () {
        final vector = _vector('dotsId');
        for (final candidates in [' \t\r\n', 'v2,garbage v1,AA== invalid']) {
          final headers = _headers(vector)..['webhook-signature'] = candidates;
          var hmacs = 0;
          var comparisons = 0;
          runWithWebhookVerificationTestHooks(
            () => expect(
              () => _verifier.verifySignature(_body(vector), headers),
              throwsA(isA<InvalidWebhookSignatureException>()),
            ),
            onHmac: () => hmacs++,
            onComparisonByte: () => comparisons++,
          );
          expect(hmacs, 1);
          expect(comparisons, 0);
        }
      },
    );

    _test(
      '2 MiB body with 1600 candidates computes one HMAC and bounded body reads',
      () {
        final vector = _vector('largeBody');
        final body = _CountingByteList(
          vector['bytesLength']! as int,
          vector['byteValue']! as int,
        );
        final wrong = 'v1,${base64.encode(List<int>.filled(32, 0))}';
        final candidates = List<String>.filled(1600, wrong)
          ..[1599] = 'v1,${vector['signature']}';
        final headers = _headers(vector)
          ..['webhook-signature'] = candidates.join(' ');
        var hmacs = 0;
        var comparedBytes = 0;
        runWithWebhookVerificationTestHooks(
          () => _verifier.verifySignatureBytes(body, headers),
          onHmac: () => hmacs++,
          onComparisonByte: () => comparedBytes++,
        );
        expect(hmacs, 1);
        expect(comparedBytes, 1600 * 32);
        // The source list sees byte validation and the real crypto sink. Candidate
        // count cannot multiply body traversal or trigger 1600 body copies.
        expect(body.reads, greaterThanOrEqualTo(body.length));
        expect(body.reads, lessThanOrEqualTo(body.length * 4));
      },
    );

    for (final alteredPosition in [0, 1, 15, 30, 31]) {
      _test(
        'comparison visits all 32 positions after mismatch at $alteredPosition',
        () {
          final vector = _vector('dotsId');
          final changed = base64.decode(vector['signature']! as String)
            ..[alteredPosition] ^= 1;
          final headers = _headers(vector)
            ..['webhook-signature'] = 'v1,${base64.encode(changed)}';
          var comparedBytes = 0;
          var hmacs = 0;
          runWithWebhookVerificationTestHooks(
            () => expect(
              () => _verifier.verifySignature(_body(vector), headers),
              throwsA(isA<InvalidWebhookSignatureException>()),
            ),
            onHmac: () => hmacs++,
            onComparisonByte: () => comparedBytes++,
          );
          expect(hmacs, 1);
          expect(comparedBytes, 32);
        },
      );
    }

    _test(
      'matching candidate still compares following valid-length candidates',
      () {
        final vector = _vector('dotsId');
        final wrong = base64.encode(List<int>.filled(32, 0));
        final headers = _headers(vector)
          ..['webhook-signature'] = 'v1,${vector['signature']} $wrong $wrong';
        var comparedBytes = 0;
        runWithWebhookVerificationTestHooks(
          () => _verifier.verifySignature(_body(vector), headers),
          onComparisonByte: () => comparedBytes++,
        );
        expect(comparedBytes, 96);
      },
    );
  });

  group('authenticate before strict parsing', () {
    _test(
      'verify-only accepts independently signed non-JSON and invalid UTF-8',
      () {
        final text = _vector('invalidJson');
        _verifier.verifySignature(_body(text), _headers(text));
        final bytes = _vector('invalidUtf8');
        _verifier.verifySignatureBytes(
          List<int>.from(bytes['bytes']! as List),
          _headers(bytes),
        );
      },
    );

    for (final name in [
      'invalidJson',
      'malformedJson',
      'array',
      'knownMalformed',
      'nonfinite',
    ]) {
      _test('authenticated $name unwrap fails safely without source/cause', () {
        final vector = _vector(name);
        _expectSafeParseError(
          () => _verifier.unwrap(_body(vector), _headers(vector)),
          forbidden: [
            'SENSITIVE_BODY',
            vector['signature']! as String,
            _body(vector),
          ],
        );
      });
    }

    _test(
      'authenticated invalid UTF-8 unwrap fails safely without decoder cause',
      () {
        final vector = _vector('invalidUtf8');
        _expectSafeParseError(
          () => _verifier.unwrapBytes(
            List<int>.from(vector['bytes']! as List),
            _headers(vector),
          ),
          reason: 'UTF-8',
        );
      },
    );

    for (final name in [
      'invalidJson',
      'malformedJson',
      'array',
      'knownMalformed',
      'nonfinite',
      'invalidUtf8',
    ]) {
      _test('signature mismatch precedes $name parsing', () {
        final vector = _vector(name);
        final headers = _headers(vector)
          ..['webhook-signature'] =
              'v1,${base64.encode(List<int>.filled(32, 0))}';
        void unwrap() {
          if (vector.containsKey('bytes')) {
            _verifier.unwrapBytes(
              List<int>.from(vector['bytes']! as List),
              headers,
            );
          } else {
            _verifier.unwrap(_body(vector), headers);
          }
        }

        _expectSafeSignatureError(unwrap, forbidden: ['SENSITIVE_BODY']);
      });
    }

    _test(
      'valid future event unwrap stays typed unknown and preserves original JSON',
      () {
        final vector = _vector('unicode');
        final event = _verifier.unwrap(_body(vector), _headers(vector));
        expect(event, isA<UnknownWebhookEvent>());
        expect(event.toJson(), jsonDecode(_body(vector)));
      },
    );

    for (final invalidByte in [-1, 256]) {
      _test(
        'invalid byte list rejects $invalidByte safely as configuration',
        () {
          _expectSafeConfigurationError(
            () => _verifier.verifySignatureBytes([
              invalidByte,
            ], _headers(_vector('dotsId'))),
          );
        },
      );
    }
  });
}

void _test(String name, void Function() body) => test(
  name,
  () => runWithWebhookVerificationTestHooks(body, now: () => _now),
);

Map<String, Object> _vector(String name) => verifierVectors[name]!;
String _body(Map<String, Object> vector) => vector['body']! as String;
Map<String, String> _headers(Map<String, Object> vector) => {
  'webhook-id': vector['id']! as String,
  'webhook-timestamp': vector['timestamp']! as String,
  'webhook-signature': 'v1,${vector['signature']}',
};

void _expectSafeConfigurationError(
  void Function() call, {
  List<String> forbidden = const [],
}) {
  expect(
    call,
    throwsA(
      isA<ArgumentError>()
          .having((e) => e.invalidValue, 'invalidValue', isNull)
          .having(
            (e) => e.toString(),
            'redacted diagnostic',
            _safeText(forbidden),
          ),
    ),
  );
}

void _expectSafeSignatureError(
  void Function() call, {
  List<String> forbidden = const [],
  String? reason,
}) {
  expect(
    call,
    throwsA(
      isA<InvalidWebhookSignatureException>()
          .having((e) => e.message, 'safe reason', _safeText(forbidden))
          .having((e) => e.toString(), 'safe diagnostic', _safeText(forbidden))
          .having(
            (e) => e.message,
            'reason context',
            reason == null ? isNotEmpty : contains(reason),
          ),
    ),
  );
}

void _expectSafeParseError(
  void Function() call, {
  List<String> forbidden = const [],
  String? reason,
}) {
  expect(
    call,
    throwsA(
      isA<FormatException>()
          .having((e) => e.source, 'source', isNull)
          .having((e) => e.offset, 'offset', isNull)
          .having((e) => e.message, 'safe reason', _safeText(forbidden))
          .having((e) => e.toString(), 'safe diagnostic', _safeText(forbidden))
          .having(
            (e) => e.message,
            'reason context',
            reason == null
                ? contains('WebhookVerifier.unwrapBytes')
                : contains(reason),
          ),
    ),
  );
}

Matcher _safeText(List<String> forbidden) => predicate<String>(
  (text) => forbidden.every((value) => value.isEmpty || !text.contains(value)),
  'diagnostic without delivery, signing-key or digest contents',
);

class _CountingByteList extends ListBase<int> {
  _CountingByteList(this._length, this.value);

  final int _length;
  final int value;
  int reads = 0;

  @override
  int get length => _length;

  @override
  set length(int value) => throw UnsupportedError('Read-only fixture.');

  @override
  int operator [](int index) {
    RangeError.checkValidIndex(index, this);
    reads++;
    return value;
  }

  @override
  void operator []=(int index, int value) =>
      throw UnsupportedError('Read-only fixture.');
}
