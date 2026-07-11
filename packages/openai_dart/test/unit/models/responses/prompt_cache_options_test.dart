import 'package:openai_dart/src/models/common/prompt_cache_breakpoint.dart';
import 'package:openai_dart/src/models/responses/config/prompt_cache_options.dart';
import 'package:test/test.dart';

void main() {
  group('PromptCacheMode', () {
    test('round-trip', () {
      for (final mode in [PromptCacheMode.implicit, PromptCacheMode.explicit]) {
        expect(PromptCacheMode.fromJson(mode.toJson()), mode);
      }
    });

    test('fromJson falls back to unknown', () {
      expect(PromptCacheMode.fromJson('turbo'), PromptCacheMode.unknown);
    });
  });

  group('PromptCacheTtl', () {
    test('round-trips the 30m wire value', () {
      expect(PromptCacheTtl.fromJson('30m'), PromptCacheTtl.minutes30);
      expect(PromptCacheTtl.minutes30.toJson(), '30m');
    });

    test('fromJson falls back to unknown', () {
      expect(PromptCacheTtl.fromJson('1h'), PromptCacheTtl.unknown);
    });
  });

  group('PromptCacheOptions', () {
    test('round-trip with both fields', () {
      const options = PromptCacheOptions(
        mode: PromptCacheMode.implicit,
        ttl: PromptCacheTtl.minutes30,
      );
      final json = options.toJson();

      expect(json, {'mode': 'implicit', 'ttl': '30m'});

      final restored = PromptCacheOptions.fromJson(json);
      expect(restored, equals(options));
    });

    test('equality and hashCode', () {
      const a = PromptCacheOptions(
        mode: PromptCacheMode.explicit,
        ttl: PromptCacheTtl.minutes30,
      );
      const b = PromptCacheOptions(
        mode: PromptCacheMode.explicit,
        ttl: PromptCacheTtl.minutes30,
      );
      const c = PromptCacheOptions(
        mode: PromptCacheMode.implicit,
        ttl: PromptCacheTtl.minutes30,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });

  group('PromptCacheOptionsParam', () {
    test('both fields are optional', () {
      const options = PromptCacheOptionsParam();
      expect(options.toJson(), isEmpty);

      final restored = PromptCacheOptionsParam.fromJson(const {});
      expect(restored, equals(options));
    });

    test('round-trip with both fields set', () {
      const options = PromptCacheOptionsParam(
        mode: PromptCacheMode.explicit,
        ttl: PromptCacheTtl.minutes30,
      );
      final json = options.toJson();

      expect(json, {'mode': 'explicit', 'ttl': '30m'});

      final restored = PromptCacheOptionsParam.fromJson(json);
      expect(restored, equals(options));
    });

    test('copyWith replaces fields', () {
      const original = PromptCacheOptionsParam(mode: PromptCacheMode.implicit);
      final copy = original.copyWith(ttl: PromptCacheTtl.minutes30);

      expect(copy.mode, PromptCacheMode.implicit);
      expect(copy.ttl, PromptCacheTtl.minutes30);
    });

    test('copyWith sets field to null', () {
      const original = PromptCacheOptionsParam(mode: PromptCacheMode.implicit);
      final copy = original.copyWith(mode: null);

      expect(copy.mode, isNull);
    });

    test('equality and hashCode', () {
      const a = PromptCacheOptionsParam(mode: PromptCacheMode.implicit);
      const b = PromptCacheOptionsParam(mode: PromptCacheMode.implicit);
      const c = PromptCacheOptionsParam(mode: PromptCacheMode.explicit);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });

  group('PromptCacheBreakpointConfig', () {
    test('mode is always explicit', () {
      const breakpoint = PromptCacheBreakpointConfig();
      expect(breakpoint.mode, 'explicit');
      expect(breakpoint.toJson(), {'mode': 'explicit'});
    });

    test('fromJson round-trip', () {
      final restored = PromptCacheBreakpointConfig.fromJson(const {
        'mode': 'explicit',
      });
      expect(restored, equals(const PromptCacheBreakpointConfig()));
    });

    test('equality and hashCode', () {
      expect(
        const PromptCacheBreakpointConfig(),
        equals(const PromptCacheBreakpointConfig()),
      );
      expect(
        const PromptCacheBreakpointConfig().hashCode,
        equals(const PromptCacheBreakpointConfig().hashCode),
      );
    });
  });
}
