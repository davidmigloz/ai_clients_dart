import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('GenerateContentRequest', () {
    group('fromJson', () {
      test('creates request with required fields only', () {
        final json = {
          'contents': [
            {
              'parts': [
                {'text': 'Hello'},
              ],
              'role': 'user',
            },
          ],
        };

        final request = GenerateContentRequest.fromJson(json);

        expect(request.contents, hasLength(1));
        expect(request.tools, isNull);
        expect(request.toolConfig, isNull);
        expect(request.safetySettings, isNull);
        expect(request.systemInstruction, isNull);
        expect(request.generationConfig, isNull);
        expect(request.cachedContent, isNull);
        expect(request.store, isNull);
        expect(request.serviceTier, isNull);
      });

      test('parses serviceTier', () {
        final json = {
          'contents': <Map<String, dynamic>>[],
          'serviceTier': 'flex',
        };

        final request = GenerateContentRequest.fromJson(json);

        expect(request.serviceTier, ServiceTier.flex);
      });

      test('parses all serviceTier values', () {
        for (final tier in ServiceTier.values) {
          final json = {
            'contents': <Map<String, dynamic>>[],
            'serviceTier': serviceTierToString(tier),
          };
          final request = GenerateContentRequest.fromJson(json);
          expect(request.serviceTier, tier);
        }
      });

      test('parses unknown serviceTier as unspecified', () {
        final json = {
          'contents': <Map<String, dynamic>>[],
          'serviceTier': 'future_tier',
        };

        final request = GenerateContentRequest.fromJson(json);

        expect(request.serviceTier, ServiceTier.unspecified);
      });
    });

    group('toJson', () {
      test('omits serviceTier when null', () {
        final request = GenerateContentRequest(
          contents: [Content.text('Hello')],
        );

        final json = request.toJson();

        expect(json.containsKey('serviceTier'), isFalse);
      });

      test('includes serviceTier when set', () {
        final request = GenerateContentRequest(
          contents: [Content.text('Hello')],
          serviceTier: ServiceTier.priority,
        );

        final json = request.toJson();

        expect(json['serviceTier'], 'priority');
      });
    });

    group('copyWith', () {
      test('preserves serviceTier when not overridden', () {
        final request = GenerateContentRequest(
          contents: [Content.text('Hello')],
          serviceTier: ServiceTier.flex,
        );

        final copy = request.copyWith(store: true);

        expect(copy.serviceTier, ServiceTier.flex);
      });

      test('overrides serviceTier', () {
        final request = GenerateContentRequest(
          contents: [Content.text('Hello')],
          serviceTier: ServiceTier.flex,
        );

        final copy = request.copyWith(serviceTier: ServiceTier.priority);

        expect(copy.serviceTier, ServiceTier.priority);
      });

      test('clears serviceTier to null', () {
        final request = GenerateContentRequest(
          contents: [Content.text('Hello')],
          serviceTier: ServiceTier.flex,
        );

        final copy = request.copyWith(serviceTier: null);

        expect(copy.serviceTier, isNull);
      });
    });

    test('round-trip preserves serviceTier', () {
      final request = GenerateContentRequest(
        contents: [Content.text('Hello')],
        serviceTier: ServiceTier.standard,
        store: true,
      );

      final json = request.toJson();
      final restored = GenerateContentRequest.fromJson(json);

      expect(restored.serviceTier, ServiceTier.standard);
      expect(restored.store, true);
      expect(restored.contents, hasLength(1));
    });
  });
}
