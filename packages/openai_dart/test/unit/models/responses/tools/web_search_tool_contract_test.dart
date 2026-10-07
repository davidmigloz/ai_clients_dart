import 'dart:convert';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  Map<String, dynamic> fullJson() => {
    'type': 'web_search',
    'search_context_size': 'high',
    'user_location': {
      'type': 'approximate',
      'country': 'US',
      'region': 'California',
      'city': 'San Francisco',
      'timezone': 'America/Los_Angeles',
    },
    'search_content_types': ['text', 'image'],
    'external_web_access': false,
    'filters': {
      'allowed_domains': ['example.com'],
      'blocked_domains': ['private.example'],
    },
    'return_token_budget': 'unlimited',
    'image_settings': {'max_results': 2, 'caption': false},
  };

  Matcher formatError(String field) => throwsA(
    isA<FormatException>().having(
      (error) => error.message,
      'context',
      contains(field),
    ),
  );

  group('Web-search definition wire contracts', () {
    test('constructor and public convenience default to minimal GA', () {
      const tool = WebSearchTool();
      expect(tool.toJson(), {'type': 'web_search'});
      expect(ResponseTool.webSearch(), tool);
      expect(tool.copyWith(), tool);
      expect(tool.copyWith().hashCode, tool.hashCode);
    });

    for (final type in [
      'web_search',
      'web_search_2025_08_26',
      'web_search_preview',
      'web_search_preview_2025_03_11',
    ]) {
      test('$type parses and preserves its discriminator', () {
        final json = {
          'type': type,
          'search_context_size': 'medium',
          'user_location': {'type': 'approximate'},
          'search_content_types': ['image'],
        };
        final tool = ResponseTool.fromJson(json) as WebSearchTool;
        expect(tool.toJson(), json);
        expect(
          ResponseTool.webSearch(
            type: type,
            searchContextSize: 'medium',
            userLocation: const ApproximateLocation(),
            searchContentTypes: const [SearchContentType.image],
          ),
          tool,
        );
      });
    }

    test(
      'full guide-defined fixture round-trips and factory forwards fields',
      () {
        final json = fullJson();
        final tool = WebSearchTool.fromJson(json);
        final convenience = ResponseTool.webSearch(
          searchContextSize: 'high',
          userLocation: const ApproximateLocation(
            country: 'US',
            region: 'California',
            city: 'San Francisco',
            timezone: 'America/Los_Angeles',
          ),
          searchContentTypes: const [
            SearchContentType.text,
            SearchContentType.image,
          ],
          externalWebAccess: false,
          filters: WebSearchFilters(
            allowedDomains: const ['example.com'],
            blockedDomains: const ['private.example'],
          ),
          returnTokenBudget: WebSearchReturnTokenBudget.unlimited,
          imageSettings: WebSearchImageSettings(maxResults: 2, caption: false),
        );
        expect(tool.toJson(), json);
        expect(jsonDecode(jsonEncode(tool)), json);
        expect(convenience, tool);
        expect(convenience.hashCode, tool.hashCode);
      },
    );

    test('false and empty structures survive without default members', () {
      final json = {
        'type': 'web_search',
        'external_web_access': false,
        'filters': {
          'allowed_domains': <String>[],
          'blocked_domains': <String>[],
        },
        'user_location': {'type': 'approximate'},
        'search_content_types': <String>[],
        'image_settings': <String, dynamic>{},
      };
      expect(WebSearchTool.fromJson(json).toJson(), json);
    });

    test(
      'nullable filters/location and legacy content list normalize null',
      () {
        final tool = WebSearchTool.fromJson(const {
          'type': 'web_search',
          'filters': null,
          'user_location': null,
          'search_content_types': null,
        });
        expect(tool, const WebSearchTool());
        expect(tool.toJson(), {'type': 'web_search'});
      },
    );

    test('empty location and filters remain present', () {
      final tool = WebSearchTool.fromJson(const {
        'type': 'web_search',
        'filters': <String, dynamic>{},
        'user_location': <String, dynamic>{},
      });
      expect(tool.toJson(), {
        'type': 'web_search',
        'filters': <String, dynamic>{},
        'user_location': {'type': 'approximate'},
      });
    });

    test(
      'existing caller-owned content list and const construction survive',
      () {
        const constant = WebSearchTool(
          type: 'web_search_preview',
          searchContentTypes: [SearchContentType.image],
        );
        final values = [SearchContentType.text];
        final tool = WebSearchTool(searchContentTypes: values);
        expect(identical(tool.searchContentTypes, values), isTrue);
        expect(identical(tool.copyWith().searchContentTypes, values), isTrue);
        expect(constant.toJson(), {
          'type': 'web_search_preview',
          'search_content_types': ['image'],
        });
      },
    );

    test('existing future content-type fallback remains compatible', () {
      final tool = WebSearchTool.fromJson(const {
        'type': 'web_search',
        'search_content_types': ['future_content'],
      });
      expect(tool.searchContentTypes, [SearchContentType.unknown]);
      expect(tool.toJson()['search_content_types'], ['unknown']);
    });

    for (final value in <Object?>[null, 'other', 3, [], {}]) {
      test('rejects malformed or missing type $value', () {
        expect(
          () => WebSearchTool.fromJson({'type': value}),
          formatError('WebSearchTool.type'),
        );
      });
    }
    test('does not invent a missing parsed discriminator', () {
      expect(
        () => WebSearchTool.fromJson(const {}),
        formatError('WebSearchTool.type'),
      );
    });

    for (final field in [
      'external_web_access',
      'search_context_size',
      'return_token_budget',
      'image_settings',
    ]) {
      for (final value in <Object?>[null, 3, [], 'invalid']) {
        test('rejects supplied malformed $field $value', () {
          expect(
            () => WebSearchTool.fromJson({'type': 'web_search', field: value}),
            formatError('WebSearchTool.$field'),
          );
        });
      }
    }

    for (final value in ['low', 'medium', 'high']) {
      test('accepts context size $value without normalization', () {
        final tool = WebSearchTool.fromJson({
          'type': 'web_search',
          'search_context_size': value,
        });
        expect(tool.searchContextSize, value);
        expect(tool.toJson()['search_context_size'], value);
      });
    }
    for (final value in [false, true]) {
      test('preserves explicit external access $value', () {
        final tool = WebSearchTool.fromJson({
          'type': 'web_search',
          'external_web_access': value,
        });
        expect(tool.externalWebAccess, value);
        expect(tool.toJson()['external_web_access'], value);
      });
    }

    for (final field in ['filters', 'user_location', 'search_content_types']) {
      for (final value in <Object>[3, 'bad']) {
        test('rejects malformed $field container $value', () {
          expect(
            () => WebSearchTool.fromJson({'type': 'web_search', field: value}),
            formatError('WebSearchTool.$field'),
          );
        });
      }
    }
    for (final value in <Object?>[null, 3, false, {}]) {
      test('rejects malformed content type element $value', () {
        expect(
          () => WebSearchTool.fromJson({
            'type': 'web_search',
            'search_content_types': [value],
          }),
          formatError('WebSearchTool.search_content_types[0]'),
        );
      });
    }

    for (final type in [
      'web_search_preview',
      'web_search_preview_2025_03_11',
    ]) {
      for (final field in [
        'external_web_access',
        'filters',
        'return_token_budget',
        'image_settings',
      ]) {
        test('$type rejects GA-only $field while parsing and serializing', () {
          final json = <String, dynamic>{
            'type': type,
            field: fullJson()[field],
          };
          expect(
            () => WebSearchTool.fromJson(json),
            formatError('WebSearchTool.$field'),
          );
          final tool = WebSearchTool.fromJson({
            'type': 'web_search',
            field: json[field],
          });
          expect(() => tool.copyWith(type: type).toJson(), throwsArgumentError);
        });
      }
    }
    test(
      'constructed invalid type and context fail in release serialization',
      () {
        const badType = WebSearchTool(type: 'other');
        const badContext = WebSearchTool(searchContextSize: 'invalid');
        expect(badType.toJson, throwsArgumentError);
        expect(badContext.toJson, throwsArgumentError);
      },
    );
  });

  group('Web-search definition complete value contract', () {
    final replacements = <String, Object?>{
      'type': 'web_search_2025_08_26',
      'search_context_size': 'low',
      'user_location': {'type': 'approximate', 'city': 'Other'},
      'search_content_types': ['text'],
      'external_web_access': true,
      'filters': {
        'allowed_domains': ['other.example'],
      },
      'return_token_budget': 'default',
      'image_settings': {'max_results': 1, 'caption': true},
    };
    for (final entry in replacements.entries) {
      test(
        '${entry.key} participates in copy, equality, hash and diagnostics',
        () {
          final original = WebSearchTool.fromJson(fullJson());
          final changed = WebSearchTool.fromJson({
            ...fullJson(),
            entry.key: entry.value,
          });
          final copy = switch (entry.key) {
            'type' => original.copyWith(type: changed.type),
            'search_context_size' => original.copyWith(
              searchContextSize: changed.searchContextSize,
            ),
            'user_location' => original.copyWith(
              userLocation: changed.userLocation,
            ),
            'search_content_types' => original.copyWith(
              searchContentTypes: changed.searchContentTypes,
            ),
            'external_web_access' => original.copyWith(
              externalWebAccess: changed.externalWebAccess,
            ),
            'filters' => original.copyWith(filters: changed.filters),
            'return_token_budget' => original.copyWith(
              returnTokenBudget: changed.returnTokenBudget,
            ),
            'image_settings' => original.copyWith(
              imageSettings: changed.imageSettings,
            ),
            _ => throw StateError('Unexpected field'),
          };
          expect(copy, changed);
          expect(copy.hashCode, changed.hashCode);
          expect(copy, isNot(original));
          expect(copy.hashCode, isNot(original.hashCode));
          expect(original.copyWith(), original);
          expect(original.copyWith().hashCode, original.hashCode);
        },
      );
    }

    test('copy clears every optional field and retains original', () {
      final original = WebSearchTool.fromJson(fullJson());
      final cleared = original.copyWith(
        searchContextSize: null,
        userLocation: null,
        searchContentTypes: null,
        externalWebAccess: null,
        filters: null,
        returnTokenBudget: null,
        imageSettings: null,
      );
      expect(cleared, const WebSearchTool());
      expect(cleared.toJson(), {'type': 'web_search'});
      expect(original.toJson(), fullJson());
    });

    test(
      'diagnostics include all fields without leaking domains or location',
      () {
        final text = WebSearchTool.fromJson(fullJson()).toString();
        for (final name in [
          'type',
          'searchContextSize',
          'userLocation',
          'searchContentTypes',
          'externalWebAccess',
          'filters',
          'returnTokenBudget',
          'imageSettings',
        ]) {
          expect(text, contains('$name:'));
        }
        expect(text, isNot(contains('private.example')));
        expect(text, isNot(contains('San Francisco')));
        expect(const WebSearchTool().toString(), contains('filters: null'));
      },
    );
  });

  group('Approximate location', () {
    test(
      'optional type and nullable strings normalize to fixed empty location',
      () {
        const empty = ApproximateLocation();
        final parsed = ApproximateLocation.fromJson(const {
          'country': null,
          'region': null,
          'city': null,
          'timezone': null,
        });
        expect(parsed, empty);
        expect(parsed.type, 'approximate');
        expect(parsed.toJson(), {'type': 'approximate'});
        expect(ApproximateLocation.fromJson(const {}), empty);
      },
    );
    for (final value in <Object?>[null, 'precise', 3, []]) {
      test('rejects supplied invalid discriminator $value', () {
        expect(
          () => ApproximateLocation.fromJson({'type': value}),
          formatError('ApproximateLocation.type'),
        );
      });
    }
    for (final field in ['country', 'region', 'city', 'timezone']) {
      test(
        '$field validates type and participates in the complete contract',
        () {
          final original = ApproximateLocation.fromJson(
            fullJson()['user_location'] as Map<String, dynamic>,
          );
          final changed = ApproximateLocation.fromJson({
            ...original.toJson(),
            field: '',
          });
          final copy = switch (field) {
            'country' => original.copyWith(country: ''),
            'region' => original.copyWith(region: ''),
            'city' => original.copyWith(city: ''),
            _ => original.copyWith(timezone: ''),
          };
          expect(copy, changed);
          expect(copy.hashCode, changed.hashCode);
          expect(copy, isNot(original));
          expect(copy.toJson()[field], '');
          expect(copy.toString(), contains('$field: 0 chars'));
          expect(
            () => ApproximateLocation.fromJson({field: 3}),
            formatError('ApproximateLocation.$field'),
          );
        },
      );
    }
    test('copy preserves and clears every old field', () {
      final location = ApproximateLocation.fromJson(
        fullJson()['user_location'] as Map<String, dynamic>,
      );
      expect(location.copyWith(), location);
      expect(location.copyWith().hashCode, location.hashCode);
      expect(
        location.copyWith(
          country: null,
          region: null,
          city: null,
          timezone: null,
        ),
        const ApproximateLocation(),
      );
    });
  });

  group('Domain filters', () {
    test(
      'allow/block can coexist; nullable lists and empties stay distinct',
      () {
        final empty = WebSearchFilters.fromJson(const {
          'allowed_domains': <String>[],
          'blocked_domains': <String>[],
        });
        expect(empty.toJson(), {
          'allowed_domains': <String>[],
          'blocked_domains': <String>[],
        });
        expect(
          WebSearchFilters.fromJson(const {
            'allowed_domains': null,
            'blocked_domains': null,
          }).toJson(),
          isEmpty,
        );
        expect(empty.toString(), contains('allowedDomains: 0 items'));
        expect(WebSearchFilters().toString(), contains('allowedDomains: null'));
      },
    );
    for (final field in ['allowed_domains', 'blocked_domains']) {
      for (final value in <Object>[
        3,
        'example.com',
        [3],
        [null],
      ]) {
        test('$field rejects malformed containers or elements $value', () {
          expect(
            () => WebSearchFilters.fromJson({field: value}),
            formatError('WebSearchFilters.$field'),
          );
        });
      }
    }
    test(
      'constructor and parser snapshot both lists; copies can clear each',
      () {
        final allowed = ['example.com'];
        final blocked = ['private.example'];
        final filters = WebSearchFilters(
          allowedDomains: allowed,
          blockedDomains: blocked,
        );
        allowed.add('other.example');
        blocked.clear();
        expect(filters.allowedDomains, ['example.com']);
        expect(filters.blockedDomains, ['private.example']);
        expect(
          () => filters.allowedDomains!.add('other'),
          throwsUnsupportedError,
        );
        expect(() => filters.blockedDomains!.clear(), throwsUnsupportedError);
        final restored = WebSearchFilters.fromJson(filters.toJson());
        expect(restored, filters);
        expect(restored.hashCode, filters.hashCode);
        expect(filters.copyWith(), filters);
        expect(filters.copyWith().hashCode, filters.hashCode);
        expect(filters.copyWith(allowedDomains: null).toJson(), {
          'blocked_domains': ['private.example'],
        });
        expect(filters.copyWith(blockedDomains: null).toJson(), {
          'allowed_domains': ['example.com'],
        });
        expect(
          filters
              .copyWith(allowedDomains: <String>[], blockedDomains: <String>[])
              .toJson(),
          {'allowed_domains': <String>[], 'blocked_domains': <String>[]},
        );
        expect(filters.copyWith(allowedDomains: <String>[]), isNot(filters));
        expect(filters.copyWith(blockedDomains: <String>[]), isNot(filters));
        expect(filters.toString(), isNot(contains('private.example')));
      },
    );
  });

  group('Guide-defined image settings and budget', () {
    test(
      'image members independently optional; false survives; no defaults',
      () {
        expect(WebSearchImageSettings().toJson(), isEmpty);
        expect(WebSearchImageSettings(caption: false).toJson(), {
          'caption': false,
        });
        expect(WebSearchImageSettings(maxResults: 5000).toJson(), {
          'max_results': 5000,
        });
        final settings = WebSearchImageSettings(maxResults: 2, caption: true);
        final restored = WebSearchImageSettings.fromJson(settings.toJson());
        expect(restored, settings);
        expect(restored.hashCode, settings.hashCode);
        expect(settings.copyWith(), settings);
        expect(settings.copyWith(maxResults: null).toJson(), {'caption': true});
        expect(settings.copyWith(caption: null).toJson(), {'max_results': 2});
        expect(settings.copyWith(maxResults: 3), isNot(settings));
        expect(settings.copyWith(caption: false), isNot(settings));
        expect(settings.toString(), contains('maxResults: 2, caption: true'));
      },
    );
    for (final value in <Object?>[null, 0, -1, 1.5, '2', false]) {
      test('image max_results rejects $value', () {
        expect(
          () => WebSearchImageSettings.fromJson({'max_results': value}),
          formatError('WebSearchImageSettings.max_results'),
        );
      });
    }
    for (final value in <Object?>[null, 3, 'false', []]) {
      test('image caption rejects $value', () {
        expect(
          () => WebSearchImageSettings.fromJson({'caption': value}),
          formatError('WebSearchImageSettings.caption'),
        );
      });
    }
    test('constructed and copied counts enforce positivity', () {
      expect(() => WebSearchImageSettings(maxResults: 0), throwsArgumentError);
      expect(() => WebSearchImageSettings(maxResults: -1), throwsArgumentError);
      expect(
        () => WebSearchImageSettings(maxResults: 1).copyWith(maxResults: 0),
        throwsArgumentError,
      );
    });
    for (final budget in WebSearchReturnTokenBudget.values) {
      test('budget ${budget.value} serializes through the definition', () {
        final tool = WebSearchTool(returnTokenBudget: budget);
        expect(tool.toJson()['return_token_budget'], budget.value);
        expect(WebSearchReturnTokenBudget.fromJson(budget.value), budget);
        expect(WebSearchTool.fromJson(tool.toJson()), tool);
      });
    }
    test('unknown budget fails instead of silently selecting a default', () {
      expect(
        () => WebSearchReturnTokenBudget.fromJson('other'),
        formatError('WebSearchReturnTokenBudget'),
      );
    });
  });
}
