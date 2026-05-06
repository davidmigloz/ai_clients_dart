import 'package:googleai_dart/src/models/common/service_tier.dart';
import 'package:googleai_dart/src/models/metadata/modality_token_count.dart';
import 'package:googleai_dart/src/models/metadata/usage_metadata.dart';
import 'package:test/test.dart';

void main() {
  group('UsageMetadata', () {
    group('fromJson', () {
      test('parses every spec field', () {
        final json = {
          'promptTokenCount': 12,
          'candidatesTokenCount': 34,
          'totalTokenCount': 78,
          'cachedContentTokenCount': 4,
          'thoughtsTokenCount': 5,
          'toolUsePromptTokenCount': 6,
          'cacheTokensDetails': [
            {'modality': 'TEXT', 'tokenCount': 4},
          ],
          'candidatesTokensDetails': [
            {'modality': 'TEXT', 'tokenCount': 30},
            {'modality': 'IMAGE', 'tokenCount': 4},
          ],
          'promptTokensDetails': [
            {'modality': 'TEXT', 'tokenCount': 12},
          ],
          'toolUsePromptTokensDetails': [
            {'modality': 'TEXT', 'tokenCount': 6},
          ],
          'serviceTier': 'priority',
        };

        final usage = UsageMetadata.fromJson(json);

        expect(usage.promptTokenCount, 12);
        expect(usage.candidatesTokenCount, 34);
        expect(usage.totalTokenCount, 78);
        expect(usage.cachedContentTokenCount, 4);
        expect(usage.thoughtsTokenCount, 5);
        expect(usage.toolUsePromptTokenCount, 6);
        expect(usage.cacheTokensDetails, hasLength(1));
        expect(usage.candidatesTokensDetails, hasLength(2));
        expect(usage.promptTokensDetails, hasLength(1));
        expect(usage.toolUsePromptTokensDetails, hasLength(1));
        expect(usage.serviceTier, ServiceTier.priority);
      });

      test('returns null for absent serviceTier and lists', () {
        final usage = UsageMetadata.fromJson(const <String, dynamic>{});

        expect(usage.serviceTier, isNull);
        expect(usage.thoughtsTokenCount, isNull);
        expect(usage.toolUsePromptTokenCount, isNull);
        expect(usage.cacheTokensDetails, isNull);
        expect(usage.candidatesTokensDetails, isNull);
        expect(usage.promptTokensDetails, isNull);
        expect(usage.toolUsePromptTokensDetails, isNull);
      });
    });

    group('toJson', () {
      test('omits keys that are null', () {
        const usage = UsageMetadata(promptTokenCount: 1);

        final json = usage.toJson();

        expect(json['promptTokenCount'], 1);
        expect(json.containsKey('serviceTier'), false);
        expect(json.containsKey('thoughtsTokenCount'), false);
        expect(json.containsKey('cacheTokensDetails'), false);
      });

      test('omits serviceTier when set to ServiceTier.unspecified', () {
        const usage = UsageMetadata(serviceTier: ServiceTier.unspecified);

        final json = usage.toJson();

        expect(json.containsKey('serviceTier'), false);
      });

      test('emits serviceTier when set to a real tier', () {
        const usage = UsageMetadata(serviceTier: ServiceTier.flex);

        final json = usage.toJson();

        expect(json['serviceTier'], 'flex');
      });

      test('serializes list fields as JSON arrays', () {
        const usage = UsageMetadata(
          cacheTokensDetails: [
            ModalityTokenCount(modality: 'TEXT', tokenCount: 4),
          ],
          candidatesTokensDetails: [
            ModalityTokenCount(modality: 'TEXT', tokenCount: 30),
          ],
        );

        final json = usage.toJson();

        expect(json['cacheTokensDetails'], isA<List<dynamic>>());
        expect((json['cacheTokensDetails'] as List).first, {
          'modality': 'TEXT',
          'tokenCount': 4,
        });
        expect(json['candidatesTokensDetails'], isA<List<dynamic>>());
      });
    });

    test('round-trip preserves equality across all fields', () {
      const original = UsageMetadata(
        promptTokenCount: 12,
        candidatesTokenCount: 34,
        totalTokenCount: 78,
        cachedContentTokenCount: 4,
        thoughtsTokenCount: 5,
        toolUsePromptTokenCount: 6,
        cacheTokensDetails: [
          ModalityTokenCount(modality: 'TEXT', tokenCount: 4),
        ],
        candidatesTokensDetails: [
          ModalityTokenCount(modality: 'TEXT', tokenCount: 30),
          ModalityTokenCount(modality: 'IMAGE', tokenCount: 4),
        ],
        promptTokensDetails: [
          ModalityTokenCount(modality: 'TEXT', tokenCount: 12),
        ],
        toolUsePromptTokensDetails: [
          ModalityTokenCount(modality: 'TEXT', tokenCount: 6),
        ],
        serviceTier: ServiceTier.priority,
      );

      final restored = UsageMetadata.fromJson(original.toJson());

      expect(restored, original);
      expect(restored.hashCode, original.hashCode);
    });

    group('copyWith', () {
      test('updates a scalar field', () {
        const original = UsageMetadata(promptTokenCount: 1);

        final copy = original.copyWith(promptTokenCount: 99);

        expect(copy.promptTokenCount, 99);
      });

      test('clears a nullable scalar back to null', () {
        const original = UsageMetadata(thoughtsTokenCount: 5);

        final copy = original.copyWith(thoughtsTokenCount: null);

        expect(copy.thoughtsTokenCount, isNull);
      });

      test('clears a nullable list back to null', () {
        const original = UsageMetadata(
          cacheTokensDetails: [
            ModalityTokenCount(modality: 'TEXT', tokenCount: 1),
          ],
        );

        final copy = original.copyWith(cacheTokensDetails: null);

        expect(copy.cacheTokensDetails, isNull);
      });

      test('updates serviceTier', () {
        const original = UsageMetadata();

        final copy = original.copyWith(serviceTier: ServiceTier.standard);

        expect(copy.serviceTier, ServiceTier.standard);
      });
    });

    test('toString summarizes list lengths', () {
      const usage = UsageMetadata(
        promptTokenCount: 1,
        cacheTokensDetails: [
          ModalityTokenCount(modality: 'TEXT', tokenCount: 1),
          ModalityTokenCount(modality: 'IMAGE', tokenCount: 2),
        ],
        serviceTier: ServiceTier.flex,
      );

      final str = usage.toString();

      expect(str, contains('UsageMetadata('));
      expect(str, contains('promptTokenCount: 1'));
      expect(str, contains('cacheTokensDetails: 2 items'));
      expect(str, contains('serviceTier: ServiceTier.flex'));
    });

    test('toString renders absent lists as "null", not "null items"', () {
      const usage = UsageMetadata(promptTokenCount: 1);

      final str = usage.toString();

      expect(str, contains('cacheTokensDetails: null'));
      expect(str, isNot(contains('cacheTokensDetails: null items')));
      expect(str, contains('candidatesTokensDetails: null'));
      expect(str, contains('promptTokensDetails: null'));
      expect(str, contains('toolUsePromptTokensDetails: null'));
    });

    test('toString renders empty lists as "0 items"', () {
      const usage = UsageMetadata(cacheTokensDetails: []);

      final str = usage.toString();

      expect(str, contains('cacheTokensDetails: 0 items'));
    });

    group('equality', () {
      test('instances with identical lists are equal', () {
        const a = UsageMetadata(
          promptTokenCount: 5,
          cacheTokensDetails: [
            ModalityTokenCount(modality: 'TEXT', tokenCount: 4),
          ],
        );
        const b = UsageMetadata(
          promptTokenCount: 5,
          cacheTokensDetails: [
            ModalityTokenCount(modality: 'TEXT', tokenCount: 4),
          ],
        );

        expect(a, b);
        expect(a.hashCode, b.hashCode);
      });

      test('instances with different list contents are not equal', () {
        const a = UsageMetadata(
          cacheTokensDetails: [
            ModalityTokenCount(modality: 'TEXT', tokenCount: 4),
          ],
        );
        const b = UsageMetadata(
          cacheTokensDetails: [
            ModalityTokenCount(modality: 'TEXT', tokenCount: 5),
          ],
        );

        expect(a, isNot(b));
      });

      test('instances with different serviceTier are not equal', () {
        const a = UsageMetadata(serviceTier: ServiceTier.standard);
        const b = UsageMetadata(serviceTier: ServiceTier.priority);

        expect(a, isNot(b));
      });
    });
  });
}
