import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

Map<String, dynamic> _c2paJson({
  String outcome = 'detected',
  String validationState = 'trusted',
  String? model = 'gpt-image-2',
  String? issuer = 'OpenAI',
  String? generatedAt = '2026-07-30T12:00:00Z',
}) => {
  'type': 'c2pa',
  'outcome': outcome,
  'validation_state': validationState,
  'model': model,
  'issuer': issuer,
  'generated_at': generatedAt,
};

Map<String, dynamic> _synthIdJson({
  String outcome = 'detected',
  String? model = 'gpt-image-2',
  String? generatedAt = '2026-07-30T12:00:00Z',
}) => {
  'type': 'synthid',
  'outcome': outcome,
  'model': model,
  'generated_at': generatedAt,
};

void main() {
  group('ContentProvenanceCheck', () {
    test('round-trips through JSON with mixed results', () {
      final json = {
        'object': 'content_provenance_check',
        'created_at': 1234567890,
        'results': [_c2paJson(), _synthIdJson()],
      };
      final check = ContentProvenanceCheck.fromJson(json);
      expect(check.object, 'content_provenance_check');
      expect(check.createdAt, 1234567890);
      expect(check.results, hasLength(2));
      expect(check.results[0], isA<C2PAProvenanceResult>());
      expect(check.results[1], isA<SynthIDProvenanceResult>());
      expect(check.toJson(), json);
      expect(ContentProvenanceCheck.fromJson(check.toJson()), check);
    });

    test('equality and hashCode', () {
      final json = {
        'object': 'content_provenance_check',
        'created_at': 1,
        'results': [_c2paJson()],
      };
      final a = ContentProvenanceCheck.fromJson(json);
      final b = ContentProvenanceCheck.fromJson(json);
      final c = a.copyWith(createdAt: 2);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });
  });

  group('C2PAProvenanceResult', () {
    test('fromJson/toJson round-trip with all fields populated', () {
      final json = _c2paJson();
      final result = C2PAProvenanceResult.fromJson(json);
      expect(result.type, 'c2pa');
      expect(result.outcome, ProvenanceDetectionResult.detected);
      expect(result.validationState, C2PAValidationState.trusted);
      expect(result.model, 'gpt-image-2');
      expect(result.issuer, 'OpenAI');
      expect(result.generatedAt, '2026-07-30T12:00:00Z');
      expect(result.toJson(), json);
    });

    test('round-trips with model/issuer/generatedAt all null', () {
      final json = _c2paJson(model: null, issuer: null, generatedAt: null);
      final result = C2PAProvenanceResult.fromJson(json);
      expect(result.model, isNull);
      expect(result.issuer, isNull);
      expect(result.generatedAt, isNull);
      expect(result.toJson(), json);
    });

    test('fromJson throws FormatException on type mismatch', () {
      expect(
        () => C2PAProvenanceResult.fromJson(_synthIdJson()),
        throwsFormatException,
      );
    });

    test('full equality and hashCode', () {
      final a = C2PAProvenanceResult.fromJson(_c2paJson());
      final b = C2PAProvenanceResult.fromJson(_c2paJson());
      expect(a, b);
      expect(a.hashCode, b.hashCode);

      expect(
        a,
        isNot(
          C2PAProvenanceResult.fromJson(_c2paJson(outcome: 'not_detected')),
        ),
      );
      expect(
        a,
        isNot(
          C2PAProvenanceResult.fromJson(_c2paJson(validationState: 'invalid')),
        ),
      );
      expect(
        a,
        isNot(C2PAProvenanceResult.fromJson(_c2paJson(model: 'other'))),
      );
      expect(
        a,
        isNot(C2PAProvenanceResult.fromJson(_c2paJson(issuer: 'other'))),
      );
      expect(
        a,
        isNot(
          C2PAProvenanceResult.fromJson(
            _c2paJson(generatedAt: '2020-01-01T00:00:00Z'),
          ),
        ),
      );
    });

    test('copyWith can explicitly set nullable fields to null', () {
      final result = C2PAProvenanceResult.fromJson(_c2paJson());
      final cleared = result.copyWith(
        model: null,
        issuer: null,
        generatedAt: null,
      );
      expect(cleared.model, isNull);
      expect(cleared.issuer, isNull);
      expect(cleared.generatedAt, isNull);
      // Omitted params keep existing value.
      expect(result.copyWith().model, result.model);
    });
  });

  group('SynthIDProvenanceResult', () {
    test('fromJson/toJson round-trip with all fields populated', () {
      final json = _synthIdJson();
      final result = SynthIDProvenanceResult.fromJson(json);
      expect(result.type, 'synthid');
      expect(result.outcome, ProvenanceDetectionResult.detected);
      expect(result.model, 'gpt-image-2');
      expect(result.generatedAt, '2026-07-30T12:00:00Z');
      expect(result.toJson(), json);
    });

    test('round-trips with model/generatedAt all null', () {
      final json = _synthIdJson(model: null, generatedAt: null);
      final result = SynthIDProvenanceResult.fromJson(json);
      expect(result.model, isNull);
      expect(result.generatedAt, isNull);
      expect(result.toJson(), json);
    });

    test('fromJson throws FormatException on type mismatch', () {
      expect(
        () => SynthIDProvenanceResult.fromJson(_c2paJson()),
        throwsFormatException,
      );
    });

    test('full equality and hashCode', () {
      final a = SynthIDProvenanceResult.fromJson(_synthIdJson());
      final b = SynthIDProvenanceResult.fromJson(_synthIdJson());
      expect(a, b);
      expect(a.hashCode, b.hashCode);

      expect(
        a,
        isNot(
          SynthIDProvenanceResult.fromJson(
            _synthIdJson(outcome: 'not_detected'),
          ),
        ),
      );
      expect(
        a,
        isNot(SynthIDProvenanceResult.fromJson(_synthIdJson(model: 'other'))),
      );
      expect(
        a,
        isNot(
          SynthIDProvenanceResult.fromJson(
            _synthIdJson(generatedAt: '2020-01-01T00:00:00Z'),
          ),
        ),
      );
    });

    test('copyWith can explicitly set nullable fields to null', () {
      final result = SynthIDProvenanceResult.fromJson(_synthIdJson());
      final cleared = result.copyWith(model: null, generatedAt: null);
      expect(cleared.model, isNull);
      expect(cleared.generatedAt, isNull);
      expect(result.copyWith().model, result.model);
    });
  });

  group('ProvenanceResult dispatch', () {
    test('dispatches c2pa to C2PAProvenanceResult', () {
      expect(
        ProvenanceResult.fromJson(_c2paJson()),
        isA<C2PAProvenanceResult>(),
      );
    });

    test('dispatches synthid to SynthIDProvenanceResult', () {
      expect(
        ProvenanceResult.fromJson(_synthIdJson()),
        isA<SynthIDProvenanceResult>(),
      );
    });

    test('falls back to UnknownProvenanceResult for unrecognized types', () {
      final json = {
        'type': 'future_signal',
        'outcome': 'detected',
        'confidence': 0.9,
      };
      final result = ProvenanceResult.fromJson(json);
      expect(result, isA<UnknownProvenanceResult>());
      final unknown = result as UnknownProvenanceResult;
      expect(unknown.rawType, 'future_signal');
      expect(unknown.rawJson, json);
      expect(unknown.toJson(), json);
    });
  });

  group('ProvenanceDetectionResult', () {
    test('round-trips every spec value', () {
      for (final value in ['detected', 'not_detected']) {
        final parsed = ProvenanceDetectionResult.fromJson(value);
        expect(parsed.toJson(), value);
      }
      expect(
        ProvenanceDetectionResult.fromJson('detected'),
        ProvenanceDetectionResult.detected,
      );
      expect(
        ProvenanceDetectionResult.fromJson('not_detected'),
        ProvenanceDetectionResult.notDetected,
      );
    });

    test('unrecognized value maps to unknown, not a real member', () {
      final parsed = ProvenanceDetectionResult.fromJson('nonsense');
      expect(parsed, ProvenanceDetectionResult.unknown);
      expect(parsed, isNot(ProvenanceDetectionResult.detected));
      expect(parsed, isNot(ProvenanceDetectionResult.notDetected));
    });
  });

  group('C2PAValidationState', () {
    test('round-trips every spec value', () {
      const values = ['trusted', 'valid', 'invalid', 'not_present'];
      for (final value in values) {
        final parsed = C2PAValidationState.fromJson(value);
        expect(parsed.toJson(), value);
      }
      expect(
        C2PAValidationState.fromJson('trusted'),
        C2PAValidationState.trusted,
      );
      expect(C2PAValidationState.fromJson('valid'), C2PAValidationState.valid);
      expect(
        C2PAValidationState.fromJson('invalid'),
        C2PAValidationState.invalid,
      );
      expect(
        C2PAValidationState.fromJson('not_present'),
        C2PAValidationState.notPresent,
      );
    });

    test('unrecognized value maps to unknown, not a real member', () {
      final parsed = C2PAValidationState.fromJson('nonsense');
      expect(parsed, C2PAValidationState.unknown);
      expect(parsed, isNot(C2PAValidationState.trusted));
      expect(parsed, isNot(C2PAValidationState.valid));
      expect(parsed, isNot(C2PAValidationState.invalid));
      expect(parsed, isNot(C2PAValidationState.notPresent));
    });
  });
}
