import 'dart:convert';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

const _private = 'PRIVATE_LIVE_INPUT_PAYLOAD';
Object? _clone(Object? value) => jsonDecode(jsonEncode(value));
Object? _wire(Object? value) {
  if (value is LiveInputValue) return value.toJson();
  if (value is List) return value.map(_wire).toList();
  if (value is Map) {
    return value.map((key, value) => MapEntry(key, _wire(value)));
  }
  return value;
}

Matcher _safe(String context) => isA<FormatException>()
    .having((error) => error.message, 'context', contains(context))
    .having((error) => error.source, 'source', isNull)
    .having((error) => error.offset, 'offset', isNull)
    .having((error) => error.toString(), 'privacy', isNot(contains(_private)));
void main() {
  group('LiveEasyInputMessageContentValueBranch0', () {
    const wire = 'PRIVATE_LIVE_INPUT_PAYLOAD';
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveEasyInputMessageContentValueBranch0.fromJson(
          _clone(wire),
        );
        final peer = LiveEasyInputMessageContentValueBranch0.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveEasyInputMessageContentValue.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveEasyInputMessageContentValueBranch0.fromJson(
        _clone(wire),
      );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveEasyInputMessageContentValueBranch0.fromJson(value),
        throwsA(_safe('LiveEasyInputMessageContentValueBranch0')),
      );
      expect(
        () => LiveEasyInputMessageContentValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveEasyInputMessageContentValue')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveEasyInputMessageContentValueBranch0.fromJson(value),
        throwsA(_safe('LiveEasyInputMessageContentValueBranch0')),
      );
      expect(
        () => LiveEasyInputMessageContentValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveEasyInputMessageContentValue')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveEasyInputMessageContentValueBranch0.fromJson(value),
        throwsA(_safe('LiveEasyInputMessageContentValueBranch0')),
      );
      expect(
        () => LiveEasyInputMessageContentValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveEasyInputMessageContentValue')),
      );
    });
  });
  group('LiveEasyInputMessageContentValueBranch1', () {
    final wire = [
      {
        'prompt_cache_breakpoint': {'mode': 'explicit'},
        'text': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        'type': 'input_text',
      },
    ];
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveEasyInputMessageContentValueBranch1.fromJson(
          _clone(wire),
        );
        final peer = LiveEasyInputMessageContentValueBranch1.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveEasyInputMessageContentValue.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveEasyInputMessageContentValueBranch1.fromJson(
        _clone(wire),
      );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveEasyInputMessageContentValueBranch1.fromJson(value),
        throwsA(_safe('LiveEasyInputMessageContentValueBranch1')),
      );
      expect(
        () => LiveEasyInputMessageContentValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveEasyInputMessageContentValue')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveEasyInputMessageContentValueBranch1.fromJson(value),
        throwsA(_safe('LiveEasyInputMessageContentValueBranch1')),
      );
      expect(
        () => LiveEasyInputMessageContentValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveEasyInputMessageContentValue')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveEasyInputMessageContentValueBranch1.fromJson(value),
        throwsA(_safe('LiveEasyInputMessageContentValueBranch1')),
      );
      expect(
        () => LiveEasyInputMessageContentValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveEasyInputMessageContentValue')),
      );
    });
  });
  group('LiveInputAnnotationBranch0', () {
    final wire = {
      'file_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'filename': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'index': 0,
      'type': 'file_citation',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputAnnotationBranch0.fromJson(_clone(wire));
        final peer = LiveInputAnnotationBranch0.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputAnnotation.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputAnnotationBranch0.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputAnnotationBranch0.fromJson(value),
        throwsA(_safe('LiveInputAnnotationBranch0')),
      );
      expect(
        () => LiveInputAnnotationBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputAnnotation')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputAnnotationBranch0.fromJson(value),
        throwsA(_safe('LiveInputAnnotationBranch0')),
      );
      expect(
        () => LiveInputAnnotationBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputAnnotation')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputAnnotationBranch0.fromJson(value),
        throwsA(_safe('LiveInputAnnotationBranch0')),
      );
      expect(
        () => LiveInputAnnotationBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputAnnotation')),
      );
    });
  });
  group('LiveInputAnnotationBranch1', () {
    final wire = {
      'end_index': 0,
      'start_index': 0,
      'title': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'url_citation',
      'url': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputAnnotationBranch1.fromJson(_clone(wire));
        final peer = LiveInputAnnotationBranch1.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputAnnotation.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputAnnotationBranch1.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputAnnotationBranch1.fromJson(value),
        throwsA(_safe('LiveInputAnnotationBranch1')),
      );
      expect(
        () => LiveInputAnnotationBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputAnnotation')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputAnnotationBranch1.fromJson(value),
        throwsA(_safe('LiveInputAnnotationBranch1')),
      );
      expect(
        () => LiveInputAnnotationBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputAnnotation')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputAnnotationBranch1.fromJson(value),
        throwsA(_safe('LiveInputAnnotationBranch1')),
      );
      expect(
        () => LiveInputAnnotationBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputAnnotation')),
      );
    });
  });
  group('LiveInputAnnotationBranch2', () {
    final wire = {
      'container_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'end_index': 0,
      'file_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'filename': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'start_index': 0,
      'type': 'container_file_citation',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputAnnotationBranch2.fromJson(_clone(wire));
        final peer = LiveInputAnnotationBranch2.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputAnnotation.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputAnnotationBranch2.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputAnnotationBranch2.fromJson(value),
        throwsA(_safe('LiveInputAnnotationBranch2')),
      );
      expect(
        () => LiveInputAnnotationBranch2.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputAnnotation')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputAnnotationBranch2.fromJson(value),
        throwsA(_safe('LiveInputAnnotationBranch2')),
      );
      expect(
        () => LiveInputAnnotationBranch2.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputAnnotation')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputAnnotationBranch2.fromJson(value),
        throwsA(_safe('LiveInputAnnotationBranch2')),
      );
      expect(
        () => LiveInputAnnotationBranch2.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputAnnotation')),
      );
    });
  });
  group('LiveInputAnnotationBranch3', () {
    final wire = {
      'file_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'index': 0,
      'type': 'file_path',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputAnnotationBranch3.fromJson(_clone(wire));
        final peer = LiveInputAnnotationBranch3.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputAnnotation.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputAnnotationBranch3.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputAnnotationBranch3.fromJson(value),
        throwsA(_safe('LiveInputAnnotationBranch3')),
      );
      expect(
        () => LiveInputAnnotationBranch3.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputAnnotation')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputAnnotationBranch3.fromJson(value),
        throwsA(_safe('LiveInputAnnotationBranch3')),
      );
      expect(
        () => LiveInputAnnotationBranch3.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputAnnotation')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputAnnotationBranch3.fromJson(value),
        throwsA(_safe('LiveInputAnnotationBranch3')),
      );
      expect(
        () => LiveInputAnnotationBranch3.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputAnnotation')),
      );
    });
  });
  group('LiveInputApplyPatchCallOutputStatusParam', () {
    const wire = 'completed';
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputApplyPatchCallOutputStatusParam.fromJson(
          _clone(wire),
        );
        final peer = LiveInputApplyPatchCallOutputStatusParam.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputApplyPatchCallOutputStatusParam.fromJson(
            _clone(wire),
          ).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputApplyPatchCallOutputStatusParam.fromJson(
        _clone(wire),
      );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputApplyPatchCallOutputStatusParam.fromJson(value),
        throwsA(_safe('LiveInputApplyPatchCallOutputStatusParam')),
      );
      expect(
        () => LiveInputApplyPatchCallOutputStatusParam.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputApplyPatchCallOutputStatusParam')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputApplyPatchCallOutputStatusParam.fromJson(value),
        throwsA(_safe('LiveInputApplyPatchCallOutputStatusParam')),
      );
      expect(
        () => LiveInputApplyPatchCallOutputStatusParam.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputApplyPatchCallOutputStatusParam')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputApplyPatchCallOutputStatusParam.fromJson(value),
        throwsA(_safe('LiveInputApplyPatchCallOutputStatusParam')),
      );
      expect(
        () => LiveInputApplyPatchCallOutputStatusParam.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputApplyPatchCallOutputStatusParam')),
      );
    });
  });
  group('LiveInputApplyPatchCallStatusParam', () {
    const wire = 'in_progress';
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputApplyPatchCallStatusParam.fromJson(_clone(wire));
        final peer = LiveInputApplyPatchCallStatusParam.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputApplyPatchCallStatusParam.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputApplyPatchCallStatusParam.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputApplyPatchCallStatusParam.fromJson(value),
        throwsA(_safe('LiveInputApplyPatchCallStatusParam')),
      );
      expect(
        () => LiveInputApplyPatchCallStatusParam.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputApplyPatchCallStatusParam')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputApplyPatchCallStatusParam.fromJson(value),
        throwsA(_safe('LiveInputApplyPatchCallStatusParam')),
      );
      expect(
        () => LiveInputApplyPatchCallStatusParam.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputApplyPatchCallStatusParam')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputApplyPatchCallStatusParam.fromJson(value),
        throwsA(_safe('LiveInputApplyPatchCallStatusParam')),
      );
      expect(
        () => LiveInputApplyPatchCallStatusParam.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputApplyPatchCallStatusParam')),
      );
    });
  });
  group('LiveInputApplyPatchOperationParamBranch0', () {
    final wire = {
      'diff': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'path': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'create_file',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputApplyPatchOperationParamBranch0.fromJson(
          _clone(wire),
        );
        final peer = LiveInputApplyPatchOperationParamBranch0.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputApplyPatchOperationParam.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputApplyPatchOperationParamBranch0.fromJson(
        _clone(wire),
      );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputApplyPatchOperationParamBranch0.fromJson(value),
        throwsA(_safe('LiveInputApplyPatchOperationParamBranch0')),
      );
      expect(
        () => LiveInputApplyPatchOperationParamBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputApplyPatchOperationParam')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputApplyPatchOperationParamBranch0.fromJson(value),
        throwsA(_safe('LiveInputApplyPatchOperationParamBranch0')),
      );
      expect(
        () => LiveInputApplyPatchOperationParamBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputApplyPatchOperationParam')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputApplyPatchOperationParamBranch0.fromJson(value),
        throwsA(_safe('LiveInputApplyPatchOperationParamBranch0')),
      );
      expect(
        () => LiveInputApplyPatchOperationParamBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputApplyPatchOperationParam')),
      );
    });
  });
  group('LiveInputApplyPatchOperationParamBranch1', () {
    final wire = {'path': 'PRIVATE_LIVE_INPUT_PAYLOAD', 'type': 'delete_file'};
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputApplyPatchOperationParamBranch1.fromJson(
          _clone(wire),
        );
        final peer = LiveInputApplyPatchOperationParamBranch1.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputApplyPatchOperationParam.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputApplyPatchOperationParamBranch1.fromJson(
        _clone(wire),
      );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputApplyPatchOperationParamBranch1.fromJson(value),
        throwsA(_safe('LiveInputApplyPatchOperationParamBranch1')),
      );
      expect(
        () => LiveInputApplyPatchOperationParamBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputApplyPatchOperationParam')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputApplyPatchOperationParamBranch1.fromJson(value),
        throwsA(_safe('LiveInputApplyPatchOperationParamBranch1')),
      );
      expect(
        () => LiveInputApplyPatchOperationParamBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputApplyPatchOperationParam')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputApplyPatchOperationParamBranch1.fromJson(value),
        throwsA(_safe('LiveInputApplyPatchOperationParamBranch1')),
      );
      expect(
        () => LiveInputApplyPatchOperationParamBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputApplyPatchOperationParam')),
      );
    });
  });
  group('LiveInputApplyPatchOperationParamBranch2', () {
    final wire = {
      'diff': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'path': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'update_file',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputApplyPatchOperationParamBranch2.fromJson(
          _clone(wire),
        );
        final peer = LiveInputApplyPatchOperationParamBranch2.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputApplyPatchOperationParam.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputApplyPatchOperationParamBranch2.fromJson(
        _clone(wire),
      );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputApplyPatchOperationParamBranch2.fromJson(value),
        throwsA(_safe('LiveInputApplyPatchOperationParamBranch2')),
      );
      expect(
        () => LiveInputApplyPatchOperationParamBranch2.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputApplyPatchOperationParam')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputApplyPatchOperationParamBranch2.fromJson(value),
        throwsA(_safe('LiveInputApplyPatchOperationParamBranch2')),
      );
      expect(
        () => LiveInputApplyPatchOperationParamBranch2.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputApplyPatchOperationParam')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputApplyPatchOperationParamBranch2.fromJson(value),
        throwsA(_safe('LiveInputApplyPatchOperationParamBranch2')),
      );
      expect(
        () => LiveInputApplyPatchOperationParamBranch2.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputApplyPatchOperationParam')),
      );
    });
  });
  group('LiveInputAutoCodeInterpreterToolParamNetworkPolicyValueBranch0', () {
    final wire = {'type': 'disabled'};
    test('direct factory typed value/wire/copy/value/hash/private contracts', () {
      final model =
          LiveInputAutoCodeInterpreterToolParamNetworkPolicyValueBranch0.fromJson(
            _clone(wire),
          );
      final peer =
          LiveInputAutoCodeInterpreterToolParamNetworkPolicyValueBranch0.fromJson(
            _clone(wire),
          );
      expect(model.toJson(), wire);
      expect(_wire(model.value), wire);
      expect(model, peer);
      expect(model.hashCode, peer.hashCode);
      expect(model.copyWith(), model);
      expect(model.copyWith(value: _clone(wire)), model);
      expect(model.toString(), isNot(contains(_private)));
      expect(
        LiveInputAutoCodeInterpreterToolParamNetworkPolicyValue.fromJson(
          _clone(wire),
        ).toJson(),
        wire,
      );
    });
    test('parsed wire and typed collection access stay immutable', () {
      final model =
          LiveInputAutoCodeInterpreterToolParamNetworkPolicyValueBranch0.fromJson(
            _clone(wire),
          );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () =>
            LiveInputAutoCodeInterpreterToolParamNetworkPolicyValueBranch0.fromJson(
              value,
            ),
        throwsA(
          _safe(
            'LiveInputAutoCodeInterpreterToolParamNetworkPolicyValueBranch0',
          ),
        ),
      );
      expect(
        () =>
            LiveInputAutoCodeInterpreterToolParamNetworkPolicyValueBranch0.fromJson(
              _clone(wire),
            ).copyWith(value: value),
        throwsA(
          _safe('LiveInputAutoCodeInterpreterToolParamNetworkPolicyValue'),
        ),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () =>
            LiveInputAutoCodeInterpreterToolParamNetworkPolicyValueBranch0.fromJson(
              value,
            ),
        throwsA(
          _safe(
            'LiveInputAutoCodeInterpreterToolParamNetworkPolicyValueBranch0',
          ),
        ),
      );
      expect(
        () =>
            LiveInputAutoCodeInterpreterToolParamNetworkPolicyValueBranch0.fromJson(
              _clone(wire),
            ).copyWith(value: value),
        throwsA(
          _safe('LiveInputAutoCodeInterpreterToolParamNetworkPolicyValue'),
        ),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () =>
            LiveInputAutoCodeInterpreterToolParamNetworkPolicyValueBranch0.fromJson(
              value,
            ),
        throwsA(
          _safe(
            'LiveInputAutoCodeInterpreterToolParamNetworkPolicyValueBranch0',
          ),
        ),
      );
      expect(
        () =>
            LiveInputAutoCodeInterpreterToolParamNetworkPolicyValueBranch0.fromJson(
              _clone(wire),
            ).copyWith(value: value),
        throwsA(
          _safe('LiveInputAutoCodeInterpreterToolParamNetworkPolicyValue'),
        ),
      );
    });
  });
  group('LiveInputAutoCodeInterpreterToolParamNetworkPolicyValueBranch1', () {
    final wire = {
      'allowed_domains': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
      'domain_secrets': [
        {
          'domain': 'PRIVATE_LIVE_INPUT_PAYLOAD',
          'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
          'value': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        },
      ],
      'type': 'allowlist',
    };
    test('direct factory typed value/wire/copy/value/hash/private contracts', () {
      final model =
          LiveInputAutoCodeInterpreterToolParamNetworkPolicyValueBranch1.fromJson(
            _clone(wire),
          );
      final peer =
          LiveInputAutoCodeInterpreterToolParamNetworkPolicyValueBranch1.fromJson(
            _clone(wire),
          );
      expect(model.toJson(), wire);
      expect(_wire(model.value), wire);
      expect(model, peer);
      expect(model.hashCode, peer.hashCode);
      expect(model.copyWith(), model);
      expect(model.copyWith(value: _clone(wire)), model);
      expect(model.toString(), isNot(contains(_private)));
      expect(
        LiveInputAutoCodeInterpreterToolParamNetworkPolicyValue.fromJson(
          _clone(wire),
        ).toJson(),
        wire,
      );
    });
    test('parsed wire and typed collection access stay immutable', () {
      final model =
          LiveInputAutoCodeInterpreterToolParamNetworkPolicyValueBranch1.fromJson(
            _clone(wire),
          );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () =>
            LiveInputAutoCodeInterpreterToolParamNetworkPolicyValueBranch1.fromJson(
              value,
            ),
        throwsA(
          _safe(
            'LiveInputAutoCodeInterpreterToolParamNetworkPolicyValueBranch1',
          ),
        ),
      );
      expect(
        () =>
            LiveInputAutoCodeInterpreterToolParamNetworkPolicyValueBranch1.fromJson(
              _clone(wire),
            ).copyWith(value: value),
        throwsA(
          _safe('LiveInputAutoCodeInterpreterToolParamNetworkPolicyValue'),
        ),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () =>
            LiveInputAutoCodeInterpreterToolParamNetworkPolicyValueBranch1.fromJson(
              value,
            ),
        throwsA(
          _safe(
            'LiveInputAutoCodeInterpreterToolParamNetworkPolicyValueBranch1',
          ),
        ),
      );
      expect(
        () =>
            LiveInputAutoCodeInterpreterToolParamNetworkPolicyValueBranch1.fromJson(
              _clone(wire),
            ).copyWith(value: value),
        throwsA(
          _safe('LiveInputAutoCodeInterpreterToolParamNetworkPolicyValue'),
        ),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () =>
            LiveInputAutoCodeInterpreterToolParamNetworkPolicyValueBranch1.fromJson(
              value,
            ),
        throwsA(
          _safe(
            'LiveInputAutoCodeInterpreterToolParamNetworkPolicyValueBranch1',
          ),
        ),
      );
      expect(
        () =>
            LiveInputAutoCodeInterpreterToolParamNetworkPolicyValueBranch1.fromJson(
              _clone(wire),
            ).copyWith(value: value),
        throwsA(
          _safe('LiveInputAutoCodeInterpreterToolParamNetworkPolicyValue'),
        ),
      );
    });
  });
  group('LiveInputCallableToolAllowedCaller', () {
    const wire = 'direct';
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputCallableToolAllowedCaller.fromJson(_clone(wire));
        final peer = LiveInputCallableToolAllowedCaller.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputCallableToolAllowedCaller.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputCallableToolAllowedCaller.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputCallableToolAllowedCaller.fromJson(value),
        throwsA(_safe('LiveInputCallableToolAllowedCaller')),
      );
      expect(
        () => LiveInputCallableToolAllowedCaller.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputCallableToolAllowedCaller')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputCallableToolAllowedCaller.fromJson(value),
        throwsA(_safe('LiveInputCallableToolAllowedCaller')),
      );
      expect(
        () => LiveInputCallableToolAllowedCaller.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputCallableToolAllowedCaller')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputCallableToolAllowedCaller.fromJson(value),
        throwsA(_safe('LiveInputCallableToolAllowedCaller')),
      );
      expect(
        () => LiveInputCallableToolAllowedCaller.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputCallableToolAllowedCaller')),
      );
    });
  });
  group('LiveInputClickButtonType', () {
    const wire = 'left';
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputClickButtonType.fromJson(_clone(wire));
        final peer = LiveInputClickButtonType.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputClickButtonType.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputClickButtonType.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputClickButtonType.fromJson(value),
        throwsA(_safe('LiveInputClickButtonType')),
      );
      expect(
        () => LiveInputClickButtonType.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputClickButtonType')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputClickButtonType.fromJson(value),
        throwsA(_safe('LiveInputClickButtonType')),
      );
      expect(
        () => LiveInputClickButtonType.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputClickButtonType')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputClickButtonType.fromJson(value),
        throwsA(_safe('LiveInputClickButtonType')),
      );
      expect(
        () => LiveInputClickButtonType.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputClickButtonType')),
      );
    });
  });
  group('LiveInputCodeInterpreterToolCallOutputsItemValueBranch0', () {
    final wire = {'logs': 'PRIVATE_LIVE_INPUT_PAYLOAD', 'type': 'logs'};
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model =
            LiveInputCodeInterpreterToolCallOutputsItemValueBranch0.fromJson(
              _clone(wire),
            );
        final peer =
            LiveInputCodeInterpreterToolCallOutputsItemValueBranch0.fromJson(
              _clone(wire),
            );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputCodeInterpreterToolCallOutputsItemValue.fromJson(
            _clone(wire),
          ).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model =
          LiveInputCodeInterpreterToolCallOutputsItemValueBranch0.fromJson(
            _clone(wire),
          );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputCodeInterpreterToolCallOutputsItemValueBranch0.fromJson(
          value,
        ),
        throwsA(
          _safe('LiveInputCodeInterpreterToolCallOutputsItemValueBranch0'),
        ),
      );
      expect(
        () => LiveInputCodeInterpreterToolCallOutputsItemValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputCodeInterpreterToolCallOutputsItemValue')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputCodeInterpreterToolCallOutputsItemValueBranch0.fromJson(
          value,
        ),
        throwsA(
          _safe('LiveInputCodeInterpreterToolCallOutputsItemValueBranch0'),
        ),
      );
      expect(
        () => LiveInputCodeInterpreterToolCallOutputsItemValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputCodeInterpreterToolCallOutputsItemValue')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputCodeInterpreterToolCallOutputsItemValueBranch0.fromJson(
          value,
        ),
        throwsA(
          _safe('LiveInputCodeInterpreterToolCallOutputsItemValueBranch0'),
        ),
      );
      expect(
        () => LiveInputCodeInterpreterToolCallOutputsItemValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputCodeInterpreterToolCallOutputsItemValue')),
      );
    });
  });
  group('LiveInputCodeInterpreterToolCallOutputsItemValueBranch1', () {
    final wire = {'type': 'image', 'url': 'PRIVATE_LIVE_INPUT_PAYLOAD'};
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model =
            LiveInputCodeInterpreterToolCallOutputsItemValueBranch1.fromJson(
              _clone(wire),
            );
        final peer =
            LiveInputCodeInterpreterToolCallOutputsItemValueBranch1.fromJson(
              _clone(wire),
            );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputCodeInterpreterToolCallOutputsItemValue.fromJson(
            _clone(wire),
          ).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model =
          LiveInputCodeInterpreterToolCallOutputsItemValueBranch1.fromJson(
            _clone(wire),
          );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputCodeInterpreterToolCallOutputsItemValueBranch1.fromJson(
          value,
        ),
        throwsA(
          _safe('LiveInputCodeInterpreterToolCallOutputsItemValueBranch1'),
        ),
      );
      expect(
        () => LiveInputCodeInterpreterToolCallOutputsItemValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputCodeInterpreterToolCallOutputsItemValue')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputCodeInterpreterToolCallOutputsItemValueBranch1.fromJson(
          value,
        ),
        throwsA(
          _safe('LiveInputCodeInterpreterToolCallOutputsItemValueBranch1'),
        ),
      );
      expect(
        () => LiveInputCodeInterpreterToolCallOutputsItemValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputCodeInterpreterToolCallOutputsItemValue')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputCodeInterpreterToolCallOutputsItemValueBranch1.fromJson(
          value,
        ),
        throwsA(
          _safe('LiveInputCodeInterpreterToolCallOutputsItemValueBranch1'),
        ),
      );
      expect(
        () => LiveInputCodeInterpreterToolCallOutputsItemValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputCodeInterpreterToolCallOutputsItemValue')),
      );
    });
  });
  group('LiveInputCodeInterpreterToolContainerValueBranch0', () {
    const wire = 'PRIVATE_LIVE_INPUT_PAYLOAD';
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model =
            LiveInputCodeInterpreterToolContainerValueBranch0.fromJson(
              _clone(wire),
            );
        final peer = LiveInputCodeInterpreterToolContainerValueBranch0.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputCodeInterpreterToolContainerValue.fromJson(
            _clone(wire),
          ).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputCodeInterpreterToolContainerValueBranch0.fromJson(
        _clone(wire),
      );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputCodeInterpreterToolContainerValueBranch0.fromJson(value),
        throwsA(_safe('LiveInputCodeInterpreterToolContainerValueBranch0')),
      );
      expect(
        () => LiveInputCodeInterpreterToolContainerValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputCodeInterpreterToolContainerValue')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputCodeInterpreterToolContainerValueBranch0.fromJson(value),
        throwsA(_safe('LiveInputCodeInterpreterToolContainerValueBranch0')),
      );
      expect(
        () => LiveInputCodeInterpreterToolContainerValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputCodeInterpreterToolContainerValue')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputCodeInterpreterToolContainerValueBranch0.fromJson(value),
        throwsA(_safe('LiveInputCodeInterpreterToolContainerValueBranch0')),
      );
      expect(
        () => LiveInputCodeInterpreterToolContainerValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputCodeInterpreterToolContainerValue')),
      );
    });
  });
  group('LiveInputCodeInterpreterToolContainerValueBranch1', () {
    final wire = {
      'file_ids': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
      'memory_limit': '1g',
      'network_policy': {'type': 'disabled'},
      'type': 'auto',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model =
            LiveInputCodeInterpreterToolContainerValueBranch1.fromJson(
              _clone(wire),
            );
        final peer = LiveInputCodeInterpreterToolContainerValueBranch1.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputCodeInterpreterToolContainerValue.fromJson(
            _clone(wire),
          ).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputCodeInterpreterToolContainerValueBranch1.fromJson(
        _clone(wire),
      );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputCodeInterpreterToolContainerValueBranch1.fromJson(value),
        throwsA(_safe('LiveInputCodeInterpreterToolContainerValueBranch1')),
      );
      expect(
        () => LiveInputCodeInterpreterToolContainerValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputCodeInterpreterToolContainerValue')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputCodeInterpreterToolContainerValueBranch1.fromJson(value),
        throwsA(_safe('LiveInputCodeInterpreterToolContainerValueBranch1')),
      );
      expect(
        () => LiveInputCodeInterpreterToolContainerValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputCodeInterpreterToolContainerValue')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputCodeInterpreterToolContainerValueBranch1.fromJson(value),
        throwsA(_safe('LiveInputCodeInterpreterToolContainerValueBranch1')),
      );
      expect(
        () => LiveInputCodeInterpreterToolContainerValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputCodeInterpreterToolContainerValue')),
      );
    });
  });
  group('LiveInputComparisonFilterValueValueBranch0', () {
    const wire = 'PRIVATE_LIVE_INPUT_PAYLOAD';
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputComparisonFilterValueValueBranch0.fromJson(
          _clone(wire),
        );
        final peer = LiveInputComparisonFilterValueValueBranch0.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputComparisonFilterValueValue.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputComparisonFilterValueValueBranch0.fromJson(
        _clone(wire),
      );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputComparisonFilterValueValueBranch0.fromJson(value),
        throwsA(_safe('LiveInputComparisonFilterValueValueBranch0')),
      );
      expect(
        () => LiveInputComparisonFilterValueValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputComparisonFilterValueValue')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputComparisonFilterValueValueBranch0.fromJson(value),
        throwsA(_safe('LiveInputComparisonFilterValueValueBranch0')),
      );
      expect(
        () => LiveInputComparisonFilterValueValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputComparisonFilterValueValue')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputComparisonFilterValueValueBranch0.fromJson(value),
        throwsA(_safe('LiveInputComparisonFilterValueValueBranch0')),
      );
      expect(
        () => LiveInputComparisonFilterValueValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputComparisonFilterValueValue')),
      );
    });
  });
  group('LiveInputComparisonFilterValueValueBranch1', () {
    const wire = 0;
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputComparisonFilterValueValueBranch1.fromJson(
          _clone(wire),
        );
        final peer = LiveInputComparisonFilterValueValueBranch1.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputComparisonFilterValueValue.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputComparisonFilterValueValueBranch1.fromJson(
        _clone(wire),
      );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputComparisonFilterValueValueBranch1.fromJson(value),
        throwsA(_safe('LiveInputComparisonFilterValueValueBranch1')),
      );
      expect(
        () => LiveInputComparisonFilterValueValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputComparisonFilterValueValue')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputComparisonFilterValueValueBranch1.fromJson(value),
        throwsA(_safe('LiveInputComparisonFilterValueValueBranch1')),
      );
      expect(
        () => LiveInputComparisonFilterValueValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputComparisonFilterValueValue')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputComparisonFilterValueValueBranch1.fromJson(value),
        throwsA(_safe('LiveInputComparisonFilterValueValueBranch1')),
      );
      expect(
        () => LiveInputComparisonFilterValueValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputComparisonFilterValueValue')),
      );
    });
  });
  group('LiveInputComparisonFilterValueValueBranch2', () {
    const wire = false;
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputComparisonFilterValueValueBranch2.fromJson(
          _clone(wire),
        );
        final peer = LiveInputComparisonFilterValueValueBranch2.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputComparisonFilterValueValue.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputComparisonFilterValueValueBranch2.fromJson(
        _clone(wire),
      );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputComparisonFilterValueValueBranch2.fromJson(value),
        throwsA(_safe('LiveInputComparisonFilterValueValueBranch2')),
      );
      expect(
        () => LiveInputComparisonFilterValueValueBranch2.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputComparisonFilterValueValue')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputComparisonFilterValueValueBranch2.fromJson(value),
        throwsA(_safe('LiveInputComparisonFilterValueValueBranch2')),
      );
      expect(
        () => LiveInputComparisonFilterValueValueBranch2.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputComparisonFilterValueValue')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputComparisonFilterValueValueBranch2.fromJson(value),
        throwsA(_safe('LiveInputComparisonFilterValueValueBranch2')),
      );
      expect(
        () => LiveInputComparisonFilterValueValueBranch2.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputComparisonFilterValueValue')),
      );
    });
  });
  group('LiveInputComparisonFilterValueValueBranch3', () {
    final wire = ['PRIVATE_LIVE_INPUT_PAYLOAD'];
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputComparisonFilterValueValueBranch3.fromJson(
          _clone(wire),
        );
        final peer = LiveInputComparisonFilterValueValueBranch3.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputComparisonFilterValueValue.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputComparisonFilterValueValueBranch3.fromJson(
        _clone(wire),
      );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputComparisonFilterValueValueBranch3.fromJson(value),
        throwsA(_safe('LiveInputComparisonFilterValueValueBranch3')),
      );
      expect(
        () => LiveInputComparisonFilterValueValueBranch3.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputComparisonFilterValueValue')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputComparisonFilterValueValueBranch3.fromJson(value),
        throwsA(_safe('LiveInputComparisonFilterValueValueBranch3')),
      );
      expect(
        () => LiveInputComparisonFilterValueValueBranch3.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputComparisonFilterValueValue')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputComparisonFilterValueValueBranch3.fromJson(value),
        throwsA(_safe('LiveInputComparisonFilterValueValueBranch3')),
      );
      expect(
        () => LiveInputComparisonFilterValueValueBranch3.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputComparisonFilterValueValue')),
      );
    });
  });
  group('LiveInputComparisonFilterValueValueBranch3ItemValueBranch0', () {
    const wire = 'PRIVATE_LIVE_INPUT_PAYLOAD';
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model =
            LiveInputComparisonFilterValueValueBranch3ItemValueBranch0.fromJson(
              _clone(wire),
            );
        final peer =
            LiveInputComparisonFilterValueValueBranch3ItemValueBranch0.fromJson(
              _clone(wire),
            );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputComparisonFilterValueValueBranch3ItemValue.fromJson(
            _clone(wire),
          ).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model =
          LiveInputComparisonFilterValueValueBranch3ItemValueBranch0.fromJson(
            _clone(wire),
          );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () =>
            LiveInputComparisonFilterValueValueBranch3ItemValueBranch0.fromJson(
              value,
            ),
        throwsA(
          _safe('LiveInputComparisonFilterValueValueBranch3ItemValueBranch0'),
        ),
      );
      expect(
        () =>
            LiveInputComparisonFilterValueValueBranch3ItemValueBranch0.fromJson(
              _clone(wire),
            ).copyWith(value: value),
        throwsA(_safe('LiveInputComparisonFilterValueValueBranch3ItemValue')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () =>
            LiveInputComparisonFilterValueValueBranch3ItemValueBranch0.fromJson(
              value,
            ),
        throwsA(
          _safe('LiveInputComparisonFilterValueValueBranch3ItemValueBranch0'),
        ),
      );
      expect(
        () =>
            LiveInputComparisonFilterValueValueBranch3ItemValueBranch0.fromJson(
              _clone(wire),
            ).copyWith(value: value),
        throwsA(_safe('LiveInputComparisonFilterValueValueBranch3ItemValue')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () =>
            LiveInputComparisonFilterValueValueBranch3ItemValueBranch0.fromJson(
              value,
            ),
        throwsA(
          _safe('LiveInputComparisonFilterValueValueBranch3ItemValueBranch0'),
        ),
      );
      expect(
        () =>
            LiveInputComparisonFilterValueValueBranch3ItemValueBranch0.fromJson(
              _clone(wire),
            ).copyWith(value: value),
        throwsA(_safe('LiveInputComparisonFilterValueValueBranch3ItemValue')),
      );
    });
  });
  group('LiveInputComparisonFilterValueValueBranch3ItemValueBranch1', () {
    const wire = 0;
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model =
            LiveInputComparisonFilterValueValueBranch3ItemValueBranch1.fromJson(
              _clone(wire),
            );
        final peer =
            LiveInputComparisonFilterValueValueBranch3ItemValueBranch1.fromJson(
              _clone(wire),
            );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputComparisonFilterValueValueBranch3ItemValue.fromJson(
            _clone(wire),
          ).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model =
          LiveInputComparisonFilterValueValueBranch3ItemValueBranch1.fromJson(
            _clone(wire),
          );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () =>
            LiveInputComparisonFilterValueValueBranch3ItemValueBranch1.fromJson(
              value,
            ),
        throwsA(
          _safe('LiveInputComparisonFilterValueValueBranch3ItemValueBranch1'),
        ),
      );
      expect(
        () =>
            LiveInputComparisonFilterValueValueBranch3ItemValueBranch1.fromJson(
              _clone(wire),
            ).copyWith(value: value),
        throwsA(_safe('LiveInputComparisonFilterValueValueBranch3ItemValue')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () =>
            LiveInputComparisonFilterValueValueBranch3ItemValueBranch1.fromJson(
              value,
            ),
        throwsA(
          _safe('LiveInputComparisonFilterValueValueBranch3ItemValueBranch1'),
        ),
      );
      expect(
        () =>
            LiveInputComparisonFilterValueValueBranch3ItemValueBranch1.fromJson(
              _clone(wire),
            ).copyWith(value: value),
        throwsA(_safe('LiveInputComparisonFilterValueValueBranch3ItemValue')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () =>
            LiveInputComparisonFilterValueValueBranch3ItemValueBranch1.fromJson(
              value,
            ),
        throwsA(
          _safe('LiveInputComparisonFilterValueValueBranch3ItemValueBranch1'),
        ),
      );
      expect(
        () =>
            LiveInputComparisonFilterValueValueBranch3ItemValueBranch1.fromJson(
              _clone(wire),
            ).copyWith(value: value),
        throwsA(_safe('LiveInputComparisonFilterValueValueBranch3ItemValue')),
      );
    });
  });
  group('LiveInputCompoundFilterFiltersItemValueBranch0', () {
    final wire = {
      'key': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'eq',
      'value': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputCompoundFilterFiltersItemValueBranch0.fromJson(
          _clone(wire),
        );
        final peer = LiveInputCompoundFilterFiltersItemValueBranch0.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputCompoundFilterFiltersItemValue.fromJson(
            _clone(wire),
          ).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputCompoundFilterFiltersItemValueBranch0.fromJson(
        _clone(wire),
      );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputCompoundFilterFiltersItemValueBranch0.fromJson(value),
        throwsA(_safe('LiveInputCompoundFilterFiltersItemValueBranch0')),
      );
      expect(
        () => LiveInputCompoundFilterFiltersItemValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputCompoundFilterFiltersItemValue')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputCompoundFilterFiltersItemValueBranch0.fromJson(value),
        throwsA(_safe('LiveInputCompoundFilterFiltersItemValueBranch0')),
      );
      expect(
        () => LiveInputCompoundFilterFiltersItemValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputCompoundFilterFiltersItemValue')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputCompoundFilterFiltersItemValueBranch0.fromJson(value),
        throwsA(_safe('LiveInputCompoundFilterFiltersItemValueBranch0')),
      );
      expect(
        () => LiveInputCompoundFilterFiltersItemValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputCompoundFilterFiltersItemValue')),
      );
    });
  });
  group('LiveInputCompoundFilterFiltersItemValueBranch1', () {
    final wire = {
      'filters': [
        {
          'key': 'PRIVATE_LIVE_INPUT_PAYLOAD',
          'type': 'eq',
          'value': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        },
      ],
      'type': 'and',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputCompoundFilterFiltersItemValueBranch1.fromJson(
          _clone(wire),
        );
        final peer = LiveInputCompoundFilterFiltersItemValueBranch1.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputCompoundFilterFiltersItemValue.fromJson(
            _clone(wire),
          ).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputCompoundFilterFiltersItemValueBranch1.fromJson(
        _clone(wire),
      );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputCompoundFilterFiltersItemValueBranch1.fromJson(value),
        throwsA(_safe('LiveInputCompoundFilterFiltersItemValueBranch1')),
      );
      expect(
        () => LiveInputCompoundFilterFiltersItemValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputCompoundFilterFiltersItemValue')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputCompoundFilterFiltersItemValueBranch1.fromJson(value),
        throwsA(_safe('LiveInputCompoundFilterFiltersItemValueBranch1')),
      );
      expect(
        () => LiveInputCompoundFilterFiltersItemValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputCompoundFilterFiltersItemValue')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputCompoundFilterFiltersItemValueBranch1.fromJson(value),
        throwsA(_safe('LiveInputCompoundFilterFiltersItemValueBranch1')),
      );
      expect(
        () => LiveInputCompoundFilterFiltersItemValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputCompoundFilterFiltersItemValue')),
      );
    });
  });
  group('LiveInputComputerActionBranch0', () {
    final wire = {
      'button': 'left',
      'keys': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
      'type': 'click',
      'x': 0,
      'y': 0,
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputComputerActionBranch0.fromJson(_clone(wire));
        final peer = LiveInputComputerActionBranch0.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputComputerAction.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputComputerActionBranch0.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputComputerActionBranch0.fromJson(value),
        throwsA(_safe('LiveInputComputerActionBranch0')),
      );
      expect(
        () => LiveInputComputerActionBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputComputerAction')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputComputerActionBranch0.fromJson(value),
        throwsA(_safe('LiveInputComputerActionBranch0')),
      );
      expect(
        () => LiveInputComputerActionBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputComputerAction')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputComputerActionBranch0.fromJson(value),
        throwsA(_safe('LiveInputComputerActionBranch0')),
      );
      expect(
        () => LiveInputComputerActionBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputComputerAction')),
      );
    });
  });
  group('LiveInputComputerActionBranch1', () {
    final wire = {
      'keys': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
      'type': 'double_click',
      'x': 0,
      'y': 0,
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputComputerActionBranch1.fromJson(_clone(wire));
        final peer = LiveInputComputerActionBranch1.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputComputerAction.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputComputerActionBranch1.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputComputerActionBranch1.fromJson(value),
        throwsA(_safe('LiveInputComputerActionBranch1')),
      );
      expect(
        () => LiveInputComputerActionBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputComputerAction')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputComputerActionBranch1.fromJson(value),
        throwsA(_safe('LiveInputComputerActionBranch1')),
      );
      expect(
        () => LiveInputComputerActionBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputComputerAction')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputComputerActionBranch1.fromJson(value),
        throwsA(_safe('LiveInputComputerActionBranch1')),
      );
      expect(
        () => LiveInputComputerActionBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputComputerAction')),
      );
    });
  });
  group('LiveInputComputerActionBranch2', () {
    final wire = {
      'keys': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
      'path': [
        {'x': 0, 'y': 0},
      ],
      'type': 'drag',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputComputerActionBranch2.fromJson(_clone(wire));
        final peer = LiveInputComputerActionBranch2.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputComputerAction.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputComputerActionBranch2.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputComputerActionBranch2.fromJson(value),
        throwsA(_safe('LiveInputComputerActionBranch2')),
      );
      expect(
        () => LiveInputComputerActionBranch2.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputComputerAction')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputComputerActionBranch2.fromJson(value),
        throwsA(_safe('LiveInputComputerActionBranch2')),
      );
      expect(
        () => LiveInputComputerActionBranch2.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputComputerAction')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputComputerActionBranch2.fromJson(value),
        throwsA(_safe('LiveInputComputerActionBranch2')),
      );
      expect(
        () => LiveInputComputerActionBranch2.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputComputerAction')),
      );
    });
  });
  group('LiveInputComputerActionBranch3', () {
    final wire = {
      'keys': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
      'type': 'keypress',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputComputerActionBranch3.fromJson(_clone(wire));
        final peer = LiveInputComputerActionBranch3.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputComputerAction.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputComputerActionBranch3.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputComputerActionBranch3.fromJson(value),
        throwsA(_safe('LiveInputComputerActionBranch3')),
      );
      expect(
        () => LiveInputComputerActionBranch3.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputComputerAction')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputComputerActionBranch3.fromJson(value),
        throwsA(_safe('LiveInputComputerActionBranch3')),
      );
      expect(
        () => LiveInputComputerActionBranch3.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputComputerAction')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputComputerActionBranch3.fromJson(value),
        throwsA(_safe('LiveInputComputerActionBranch3')),
      );
      expect(
        () => LiveInputComputerActionBranch3.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputComputerAction')),
      );
    });
  });
  group('LiveInputComputerActionBranch4', () {
    final wire = {
      'keys': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
      'type': 'move',
      'x': 0,
      'y': 0,
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputComputerActionBranch4.fromJson(_clone(wire));
        final peer = LiveInputComputerActionBranch4.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputComputerAction.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputComputerActionBranch4.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputComputerActionBranch4.fromJson(value),
        throwsA(_safe('LiveInputComputerActionBranch4')),
      );
      expect(
        () => LiveInputComputerActionBranch4.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputComputerAction')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputComputerActionBranch4.fromJson(value),
        throwsA(_safe('LiveInputComputerActionBranch4')),
      );
      expect(
        () => LiveInputComputerActionBranch4.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputComputerAction')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputComputerActionBranch4.fromJson(value),
        throwsA(_safe('LiveInputComputerActionBranch4')),
      );
      expect(
        () => LiveInputComputerActionBranch4.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputComputerAction')),
      );
    });
  });
  group('LiveInputComputerActionBranch5', () {
    final wire = {'type': 'screenshot'};
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputComputerActionBranch5.fromJson(_clone(wire));
        final peer = LiveInputComputerActionBranch5.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputComputerAction.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputComputerActionBranch5.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputComputerActionBranch5.fromJson(value),
        throwsA(_safe('LiveInputComputerActionBranch5')),
      );
      expect(
        () => LiveInputComputerActionBranch5.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputComputerAction')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputComputerActionBranch5.fromJson(value),
        throwsA(_safe('LiveInputComputerActionBranch5')),
      );
      expect(
        () => LiveInputComputerActionBranch5.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputComputerAction')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputComputerActionBranch5.fromJson(value),
        throwsA(_safe('LiveInputComputerActionBranch5')),
      );
      expect(
        () => LiveInputComputerActionBranch5.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputComputerAction')),
      );
    });
  });
  group('LiveInputComputerActionBranch6', () {
    final wire = {
      'keys': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
      'scroll_x': 0,
      'scroll_y': 0,
      'type': 'scroll',
      'x': 0,
      'y': 0,
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputComputerActionBranch6.fromJson(_clone(wire));
        final peer = LiveInputComputerActionBranch6.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputComputerAction.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputComputerActionBranch6.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputComputerActionBranch6.fromJson(value),
        throwsA(_safe('LiveInputComputerActionBranch6')),
      );
      expect(
        () => LiveInputComputerActionBranch6.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputComputerAction')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputComputerActionBranch6.fromJson(value),
        throwsA(_safe('LiveInputComputerActionBranch6')),
      );
      expect(
        () => LiveInputComputerActionBranch6.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputComputerAction')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputComputerActionBranch6.fromJson(value),
        throwsA(_safe('LiveInputComputerActionBranch6')),
      );
      expect(
        () => LiveInputComputerActionBranch6.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputComputerAction')),
      );
    });
  });
  group('LiveInputComputerActionBranch7', () {
    final wire = {'text': 'PRIVATE_LIVE_INPUT_PAYLOAD', 'type': 'type'};
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputComputerActionBranch7.fromJson(_clone(wire));
        final peer = LiveInputComputerActionBranch7.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputComputerAction.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputComputerActionBranch7.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputComputerActionBranch7.fromJson(value),
        throwsA(_safe('LiveInputComputerActionBranch7')),
      );
      expect(
        () => LiveInputComputerActionBranch7.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputComputerAction')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputComputerActionBranch7.fromJson(value),
        throwsA(_safe('LiveInputComputerActionBranch7')),
      );
      expect(
        () => LiveInputComputerActionBranch7.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputComputerAction')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputComputerActionBranch7.fromJson(value),
        throwsA(_safe('LiveInputComputerActionBranch7')),
      );
      expect(
        () => LiveInputComputerActionBranch7.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputComputerAction')),
      );
    });
  });
  group('LiveInputComputerActionBranch8', () {
    final wire = {'type': 'wait'};
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputComputerActionBranch8.fromJson(_clone(wire));
        final peer = LiveInputComputerActionBranch8.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputComputerAction.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputComputerActionBranch8.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputComputerActionBranch8.fromJson(value),
        throwsA(_safe('LiveInputComputerActionBranch8')),
      );
      expect(
        () => LiveInputComputerActionBranch8.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputComputerAction')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputComputerActionBranch8.fromJson(value),
        throwsA(_safe('LiveInputComputerActionBranch8')),
      );
      expect(
        () => LiveInputComputerActionBranch8.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputComputerAction')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputComputerActionBranch8.fromJson(value),
        throwsA(_safe('LiveInputComputerActionBranch8')),
      );
      expect(
        () => LiveInputComputerActionBranch8.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputComputerAction')),
      );
    });
  });
  group('LiveInputComputerActionList', () {
    final wire = [
      {
        'button': 'left',
        'keys': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
        'type': 'click',
        'x': 0,
        'y': 0,
      },
    ];
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputComputerActionList.fromJson(_clone(wire));
        final peer = LiveInputComputerActionList.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputComputerActionList.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputComputerActionList.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputComputerActionList.fromJson(value),
        throwsA(_safe('LiveInputComputerActionList')),
      );
      expect(
        () => LiveInputComputerActionList.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputComputerActionList')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputComputerActionList.fromJson(value),
        throwsA(_safe('LiveInputComputerActionList')),
      );
      expect(
        () => LiveInputComputerActionList.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputComputerActionList')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputComputerActionList.fromJson(value),
        throwsA(_safe('LiveInputComputerActionList')),
      );
      expect(
        () => LiveInputComputerActionList.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputComputerActionList')),
      );
    });
  });
  group('LiveInputComputerEnvironment', () {
    const wire = 'windows';
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputComputerEnvironment.fromJson(_clone(wire));
        final peer = LiveInputComputerEnvironment.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputComputerEnvironment.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputComputerEnvironment.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputComputerEnvironment.fromJson(value),
        throwsA(_safe('LiveInputComputerEnvironment')),
      );
      expect(
        () => LiveInputComputerEnvironment.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputComputerEnvironment')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputComputerEnvironment.fromJson(value),
        throwsA(_safe('LiveInputComputerEnvironment')),
      );
      expect(
        () => LiveInputComputerEnvironment.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputComputerEnvironment')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputComputerEnvironment.fromJson(value),
        throwsA(_safe('LiveInputComputerEnvironment')),
      );
      expect(
        () => LiveInputComputerEnvironment.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputComputerEnvironment')),
      );
    });
  });
  group('LiveInputContainerAutoParamNetworkPolicyValueBranch0', () {
    final wire = {'type': 'disabled'};
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model =
            LiveInputContainerAutoParamNetworkPolicyValueBranch0.fromJson(
              _clone(wire),
            );
        final peer =
            LiveInputContainerAutoParamNetworkPolicyValueBranch0.fromJson(
              _clone(wire),
            );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputContainerAutoParamNetworkPolicyValue.fromJson(
            _clone(wire),
          ).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model =
          LiveInputContainerAutoParamNetworkPolicyValueBranch0.fromJson(
            _clone(wire),
          );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputContainerAutoParamNetworkPolicyValueBranch0.fromJson(
          value,
        ),
        throwsA(_safe('LiveInputContainerAutoParamNetworkPolicyValueBranch0')),
      );
      expect(
        () => LiveInputContainerAutoParamNetworkPolicyValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputContainerAutoParamNetworkPolicyValue')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputContainerAutoParamNetworkPolicyValueBranch0.fromJson(
          value,
        ),
        throwsA(_safe('LiveInputContainerAutoParamNetworkPolicyValueBranch0')),
      );
      expect(
        () => LiveInputContainerAutoParamNetworkPolicyValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputContainerAutoParamNetworkPolicyValue')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputContainerAutoParamNetworkPolicyValueBranch0.fromJson(
          value,
        ),
        throwsA(_safe('LiveInputContainerAutoParamNetworkPolicyValueBranch0')),
      );
      expect(
        () => LiveInputContainerAutoParamNetworkPolicyValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputContainerAutoParamNetworkPolicyValue')),
      );
    });
  });
  group('LiveInputContainerAutoParamNetworkPolicyValueBranch1', () {
    final wire = {
      'allowed_domains': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
      'domain_secrets': [
        {
          'domain': 'PRIVATE_LIVE_INPUT_PAYLOAD',
          'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
          'value': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        },
      ],
      'type': 'allowlist',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model =
            LiveInputContainerAutoParamNetworkPolicyValueBranch1.fromJson(
              _clone(wire),
            );
        final peer =
            LiveInputContainerAutoParamNetworkPolicyValueBranch1.fromJson(
              _clone(wire),
            );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputContainerAutoParamNetworkPolicyValue.fromJson(
            _clone(wire),
          ).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model =
          LiveInputContainerAutoParamNetworkPolicyValueBranch1.fromJson(
            _clone(wire),
          );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputContainerAutoParamNetworkPolicyValueBranch1.fromJson(
          value,
        ),
        throwsA(_safe('LiveInputContainerAutoParamNetworkPolicyValueBranch1')),
      );
      expect(
        () => LiveInputContainerAutoParamNetworkPolicyValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputContainerAutoParamNetworkPolicyValue')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputContainerAutoParamNetworkPolicyValueBranch1.fromJson(
          value,
        ),
        throwsA(_safe('LiveInputContainerAutoParamNetworkPolicyValueBranch1')),
      );
      expect(
        () => LiveInputContainerAutoParamNetworkPolicyValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputContainerAutoParamNetworkPolicyValue')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputContainerAutoParamNetworkPolicyValueBranch1.fromJson(
          value,
        ),
        throwsA(_safe('LiveInputContainerAutoParamNetworkPolicyValueBranch1')),
      );
      expect(
        () => LiveInputContainerAutoParamNetworkPolicyValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputContainerAutoParamNetworkPolicyValue')),
      );
    });
  });
  group('LiveInputContainerAutoParamSkillsItemValueBranch0', () {
    final wire = {
      'skill_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'skill_reference',
      'version': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model =
            LiveInputContainerAutoParamSkillsItemValueBranch0.fromJson(
              _clone(wire),
            );
        final peer = LiveInputContainerAutoParamSkillsItemValueBranch0.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputContainerAutoParamSkillsItemValue.fromJson(
            _clone(wire),
          ).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputContainerAutoParamSkillsItemValueBranch0.fromJson(
        _clone(wire),
      );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputContainerAutoParamSkillsItemValueBranch0.fromJson(value),
        throwsA(_safe('LiveInputContainerAutoParamSkillsItemValueBranch0')),
      );
      expect(
        () => LiveInputContainerAutoParamSkillsItemValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputContainerAutoParamSkillsItemValue')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputContainerAutoParamSkillsItemValueBranch0.fromJson(value),
        throwsA(_safe('LiveInputContainerAutoParamSkillsItemValueBranch0')),
      );
      expect(
        () => LiveInputContainerAutoParamSkillsItemValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputContainerAutoParamSkillsItemValue')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputContainerAutoParamSkillsItemValueBranch0.fromJson(value),
        throwsA(_safe('LiveInputContainerAutoParamSkillsItemValueBranch0')),
      );
      expect(
        () => LiveInputContainerAutoParamSkillsItemValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputContainerAutoParamSkillsItemValue')),
      );
    });
  });
  group('LiveInputContainerAutoParamSkillsItemValueBranch1', () {
    final wire = {
      'description': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'source': {
        'data': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        'media_type': 'application/zip',
        'type': 'base64',
      },
      'type': 'inline',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model =
            LiveInputContainerAutoParamSkillsItemValueBranch1.fromJson(
              _clone(wire),
            );
        final peer = LiveInputContainerAutoParamSkillsItemValueBranch1.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputContainerAutoParamSkillsItemValue.fromJson(
            _clone(wire),
          ).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputContainerAutoParamSkillsItemValueBranch1.fromJson(
        _clone(wire),
      );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputContainerAutoParamSkillsItemValueBranch1.fromJson(value),
        throwsA(_safe('LiveInputContainerAutoParamSkillsItemValueBranch1')),
      );
      expect(
        () => LiveInputContainerAutoParamSkillsItemValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputContainerAutoParamSkillsItemValue')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputContainerAutoParamSkillsItemValueBranch1.fromJson(value),
        throwsA(_safe('LiveInputContainerAutoParamSkillsItemValueBranch1')),
      );
      expect(
        () => LiveInputContainerAutoParamSkillsItemValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputContainerAutoParamSkillsItemValue')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputContainerAutoParamSkillsItemValueBranch1.fromJson(value),
        throwsA(_safe('LiveInputContainerAutoParamSkillsItemValueBranch1')),
      );
      expect(
        () => LiveInputContainerAutoParamSkillsItemValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputContainerAutoParamSkillsItemValue')),
      );
    });
  });
  group('LiveInputContainerMemoryLimit', () {
    const wire = '1g';
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputContainerMemoryLimit.fromJson(_clone(wire));
        final peer = LiveInputContainerMemoryLimit.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputContainerMemoryLimit.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputContainerMemoryLimit.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputContainerMemoryLimit.fromJson(value),
        throwsA(_safe('LiveInputContainerMemoryLimit')),
      );
      expect(
        () => LiveInputContainerMemoryLimit.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputContainerMemoryLimit')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputContainerMemoryLimit.fromJson(value),
        throwsA(_safe('LiveInputContainerMemoryLimit')),
      );
      expect(
        () => LiveInputContainerMemoryLimit.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputContainerMemoryLimit')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputContainerMemoryLimit.fromJson(value),
        throwsA(_safe('LiveInputContainerMemoryLimit')),
      );
      expect(
        () => LiveInputContainerMemoryLimit.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputContainerMemoryLimit')),
      );
    });
  });
  group('LiveInputContentBranch0', () {
    final wire = {
      'prompt_cache_breakpoint': {'mode': 'explicit'},
      'text': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'input_text',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputContentBranch0.fromJson(_clone(wire));
        final peer = LiveInputContentBranch0.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputContent.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputContentBranch0.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputContentBranch0.fromJson(value),
        throwsA(_safe('LiveInputContentBranch0')),
      );
      expect(
        () => LiveInputContentBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputContent')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputContentBranch0.fromJson(value),
        throwsA(_safe('LiveInputContentBranch0')),
      );
      expect(
        () => LiveInputContentBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputContent')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputContentBranch0.fromJson(value),
        throwsA(_safe('LiveInputContentBranch0')),
      );
      expect(
        () => LiveInputContentBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputContent')),
      );
    });
  });
  group('LiveInputContentBranch1', () {
    final wire = {
      'detail': 'low',
      'file_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'image_url': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'prompt_cache_breakpoint': {'mode': 'explicit'},
      'type': 'input_image',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputContentBranch1.fromJson(_clone(wire));
        final peer = LiveInputContentBranch1.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputContent.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputContentBranch1.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputContentBranch1.fromJson(value),
        throwsA(_safe('LiveInputContentBranch1')),
      );
      expect(
        () => LiveInputContentBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputContent')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputContentBranch1.fromJson(value),
        throwsA(_safe('LiveInputContentBranch1')),
      );
      expect(
        () => LiveInputContentBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputContent')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputContentBranch1.fromJson(value),
        throwsA(_safe('LiveInputContentBranch1')),
      );
      expect(
        () => LiveInputContentBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputContent')),
      );
    });
  });
  group('LiveInputContentBranch2', () {
    final wire = {
      'detail': 'auto',
      'file_data': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'file_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'file_url': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'filename': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'prompt_cache_breakpoint': {'mode': 'explicit'},
      'type': 'input_file',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputContentBranch2.fromJson(_clone(wire));
        final peer = LiveInputContentBranch2.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputContent.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputContentBranch2.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputContentBranch2.fromJson(value),
        throwsA(_safe('LiveInputContentBranch2')),
      );
      expect(
        () => LiveInputContentBranch2.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputContent')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputContentBranch2.fromJson(value),
        throwsA(_safe('LiveInputContentBranch2')),
      );
      expect(
        () => LiveInputContentBranch2.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputContent')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputContentBranch2.fromJson(value),
        throwsA(_safe('LiveInputContentBranch2')),
      );
      expect(
        () => LiveInputContentBranch2.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputContent')),
      );
    });
  });
  group('LiveInputCustomToolCallOutputOutputValueBranch0', () {
    const wire = 'PRIVATE_LIVE_INPUT_PAYLOAD';
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputCustomToolCallOutputOutputValueBranch0.fromJson(
          _clone(wire),
        );
        final peer = LiveInputCustomToolCallOutputOutputValueBranch0.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputCustomToolCallOutputOutputValue.fromJson(
            _clone(wire),
          ).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputCustomToolCallOutputOutputValueBranch0.fromJson(
        _clone(wire),
      );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputCustomToolCallOutputOutputValueBranch0.fromJson(value),
        throwsA(_safe('LiveInputCustomToolCallOutputOutputValueBranch0')),
      );
      expect(
        () => LiveInputCustomToolCallOutputOutputValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputCustomToolCallOutputOutputValue')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputCustomToolCallOutputOutputValueBranch0.fromJson(value),
        throwsA(_safe('LiveInputCustomToolCallOutputOutputValueBranch0')),
      );
      expect(
        () => LiveInputCustomToolCallOutputOutputValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputCustomToolCallOutputOutputValue')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputCustomToolCallOutputOutputValueBranch0.fromJson(value),
        throwsA(_safe('LiveInputCustomToolCallOutputOutputValueBranch0')),
      );
      expect(
        () => LiveInputCustomToolCallOutputOutputValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputCustomToolCallOutputOutputValue')),
      );
    });
  });
  group('LiveInputCustomToolCallOutputOutputValueBranch1', () {
    final wire = [
      {
        'prompt_cache_breakpoint': {'mode': 'explicit'},
        'text': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        'type': 'input_text',
      },
    ];
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputCustomToolCallOutputOutputValueBranch1.fromJson(
          _clone(wire),
        );
        final peer = LiveInputCustomToolCallOutputOutputValueBranch1.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputCustomToolCallOutputOutputValue.fromJson(
            _clone(wire),
          ).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputCustomToolCallOutputOutputValueBranch1.fromJson(
        _clone(wire),
      );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputCustomToolCallOutputOutputValueBranch1.fromJson(value),
        throwsA(_safe('LiveInputCustomToolCallOutputOutputValueBranch1')),
      );
      expect(
        () => LiveInputCustomToolCallOutputOutputValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputCustomToolCallOutputOutputValue')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputCustomToolCallOutputOutputValueBranch1.fromJson(value),
        throwsA(_safe('LiveInputCustomToolCallOutputOutputValueBranch1')),
      );
      expect(
        () => LiveInputCustomToolCallOutputOutputValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputCustomToolCallOutputOutputValue')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputCustomToolCallOutputOutputValueBranch1.fromJson(value),
        throwsA(_safe('LiveInputCustomToolCallOutputOutputValueBranch1')),
      );
      expect(
        () => LiveInputCustomToolCallOutputOutputValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputCustomToolCallOutputOutputValue')),
      );
    });
  });
  group('LiveInputCustomToolParamFormatValueBranch0', () {
    final wire = {'type': 'text'};
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputCustomToolParamFormatValueBranch0.fromJson(
          _clone(wire),
        );
        final peer = LiveInputCustomToolParamFormatValueBranch0.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputCustomToolParamFormatValue.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputCustomToolParamFormatValueBranch0.fromJson(
        _clone(wire),
      );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputCustomToolParamFormatValueBranch0.fromJson(value),
        throwsA(_safe('LiveInputCustomToolParamFormatValueBranch0')),
      );
      expect(
        () => LiveInputCustomToolParamFormatValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputCustomToolParamFormatValue')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputCustomToolParamFormatValueBranch0.fromJson(value),
        throwsA(_safe('LiveInputCustomToolParamFormatValueBranch0')),
      );
      expect(
        () => LiveInputCustomToolParamFormatValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputCustomToolParamFormatValue')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputCustomToolParamFormatValueBranch0.fromJson(value),
        throwsA(_safe('LiveInputCustomToolParamFormatValueBranch0')),
      );
      expect(
        () => LiveInputCustomToolParamFormatValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputCustomToolParamFormatValue')),
      );
    });
  });
  group('LiveInputCustomToolParamFormatValueBranch1', () {
    final wire = {
      'definition': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'syntax': 'lark',
      'type': 'grammar',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputCustomToolParamFormatValueBranch1.fromJson(
          _clone(wire),
        );
        final peer = LiveInputCustomToolParamFormatValueBranch1.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputCustomToolParamFormatValue.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputCustomToolParamFormatValueBranch1.fromJson(
        _clone(wire),
      );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputCustomToolParamFormatValueBranch1.fromJson(value),
        throwsA(_safe('LiveInputCustomToolParamFormatValueBranch1')),
      );
      expect(
        () => LiveInputCustomToolParamFormatValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputCustomToolParamFormatValue')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputCustomToolParamFormatValueBranch1.fromJson(value),
        throwsA(_safe('LiveInputCustomToolParamFormatValueBranch1')),
      );
      expect(
        () => LiveInputCustomToolParamFormatValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputCustomToolParamFormatValue')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputCustomToolParamFormatValueBranch1.fromJson(value),
        throwsA(_safe('LiveInputCustomToolParamFormatValueBranch1')),
      );
      expect(
        () => LiveInputCustomToolParamFormatValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputCustomToolParamFormatValue')),
      );
    });
  });
  group('LiveInputDetailEnum', () {
    const wire = 'low';
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputDetailEnum.fromJson(_clone(wire));
        final peer = LiveInputDetailEnum.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputDetailEnum.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputDetailEnum.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputDetailEnum.fromJson(value),
        throwsA(_safe('LiveInputDetailEnum')),
      );
      expect(
        () => LiveInputDetailEnum.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputDetailEnum')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputDetailEnum.fromJson(value),
        throwsA(_safe('LiveInputDetailEnum')),
      );
      expect(
        () => LiveInputDetailEnum.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputDetailEnum')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputDetailEnum.fromJson(value),
        throwsA(_safe('LiveInputDetailEnum')),
      );
      expect(
        () => LiveInputDetailEnum.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputDetailEnum')),
      );
    });
  });
  group('LiveInputFidelity', () {
    const wire = 'high';
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputFidelity.fromJson(_clone(wire));
        final peer = LiveInputFidelity.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputFidelity.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputFidelity.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputFidelity.fromJson(value),
        throwsA(_safe('LiveInputFidelity')),
      );
      expect(
        () => LiveInputFidelity.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputFidelity')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputFidelity.fromJson(value),
        throwsA(_safe('LiveInputFidelity')),
      );
      expect(
        () => LiveInputFidelity.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputFidelity')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputFidelity.fromJson(value),
        throwsA(_safe('LiveInputFidelity')),
      );
      expect(
        () => LiveInputFidelity.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputFidelity')),
      );
    });
  });
  group('LiveInputFileDetailEnum', () {
    const wire = 'auto';
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputFileDetailEnum.fromJson(_clone(wire));
        final peer = LiveInputFileDetailEnum.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputFileDetailEnum.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputFileDetailEnum.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputFileDetailEnum.fromJson(value),
        throwsA(_safe('LiveInputFileDetailEnum')),
      );
      expect(
        () => LiveInputFileDetailEnum.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFileDetailEnum')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputFileDetailEnum.fromJson(value),
        throwsA(_safe('LiveInputFileDetailEnum')),
      );
      expect(
        () => LiveInputFileDetailEnum.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFileDetailEnum')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputFileDetailEnum.fromJson(value),
        throwsA(_safe('LiveInputFileDetailEnum')),
      );
      expect(
        () => LiveInputFileDetailEnum.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFileDetailEnum')),
      );
    });
  });
  group('LiveInputFileInputDetail', () {
    const wire = 'auto';
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputFileInputDetail.fromJson(_clone(wire));
        final peer = LiveInputFileInputDetail.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputFileInputDetail.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputFileInputDetail.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputFileInputDetail.fromJson(value),
        throwsA(_safe('LiveInputFileInputDetail')),
      );
      expect(
        () => LiveInputFileInputDetail.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFileInputDetail')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputFileInputDetail.fromJson(value),
        throwsA(_safe('LiveInputFileInputDetail')),
      );
      expect(
        () => LiveInputFileInputDetail.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFileInputDetail')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputFileInputDetail.fromJson(value),
        throwsA(_safe('LiveInputFileInputDetail')),
      );
      expect(
        () => LiveInputFileInputDetail.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFileInputDetail')),
      );
    });
  });
  group('LiveInputFiltersBranch0', () {
    final wire = {
      'key': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'eq',
      'value': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputFiltersBranch0.fromJson(_clone(wire));
        final peer = LiveInputFiltersBranch0.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputFilters.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputFiltersBranch0.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputFiltersBranch0.fromJson(value),
        throwsA(_safe('LiveInputFiltersBranch0')),
      );
      expect(
        () => LiveInputFiltersBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFilters')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputFiltersBranch0.fromJson(value),
        throwsA(_safe('LiveInputFiltersBranch0')),
      );
      expect(
        () => LiveInputFiltersBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFilters')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputFiltersBranch0.fromJson(value),
        throwsA(_safe('LiveInputFiltersBranch0')),
      );
      expect(
        () => LiveInputFiltersBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFilters')),
      );
    });
  });
  group('LiveInputFiltersBranch1', () {
    final wire = {
      'filters': [
        {
          'key': 'PRIVATE_LIVE_INPUT_PAYLOAD',
          'type': 'eq',
          'value': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        },
      ],
      'type': 'and',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputFiltersBranch1.fromJson(_clone(wire));
        final peer = LiveInputFiltersBranch1.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputFilters.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputFiltersBranch1.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputFiltersBranch1.fromJson(value),
        throwsA(_safe('LiveInputFiltersBranch1')),
      );
      expect(
        () => LiveInputFiltersBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFilters')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputFiltersBranch1.fromJson(value),
        throwsA(_safe('LiveInputFiltersBranch1')),
      );
      expect(
        () => LiveInputFiltersBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFilters')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputFiltersBranch1.fromJson(value),
        throwsA(_safe('LiveInputFiltersBranch1')),
      );
      expect(
        () => LiveInputFiltersBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFilters')),
      );
    });
  });
  group('LiveInputFunctionAndCustomToolCallOutputBranch0', () {
    final wire = {
      'prompt_cache_breakpoint': {'mode': 'explicit'},
      'text': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'input_text',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputFunctionAndCustomToolCallOutputBranch0.fromJson(
          _clone(wire),
        );
        final peer = LiveInputFunctionAndCustomToolCallOutputBranch0.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputFunctionAndCustomToolCallOutput.fromJson(
            _clone(wire),
          ).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputFunctionAndCustomToolCallOutputBranch0.fromJson(
        _clone(wire),
      );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputFunctionAndCustomToolCallOutputBranch0.fromJson(value),
        throwsA(_safe('LiveInputFunctionAndCustomToolCallOutputBranch0')),
      );
      expect(
        () => LiveInputFunctionAndCustomToolCallOutputBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFunctionAndCustomToolCallOutput')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputFunctionAndCustomToolCallOutputBranch0.fromJson(value),
        throwsA(_safe('LiveInputFunctionAndCustomToolCallOutputBranch0')),
      );
      expect(
        () => LiveInputFunctionAndCustomToolCallOutputBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFunctionAndCustomToolCallOutput')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputFunctionAndCustomToolCallOutputBranch0.fromJson(value),
        throwsA(_safe('LiveInputFunctionAndCustomToolCallOutputBranch0')),
      );
      expect(
        () => LiveInputFunctionAndCustomToolCallOutputBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFunctionAndCustomToolCallOutput')),
      );
    });
  });
  group('LiveInputFunctionAndCustomToolCallOutputBranch1', () {
    final wire = {
      'detail': 'low',
      'file_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'image_url': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'prompt_cache_breakpoint': {'mode': 'explicit'},
      'type': 'input_image',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputFunctionAndCustomToolCallOutputBranch1.fromJson(
          _clone(wire),
        );
        final peer = LiveInputFunctionAndCustomToolCallOutputBranch1.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputFunctionAndCustomToolCallOutput.fromJson(
            _clone(wire),
          ).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputFunctionAndCustomToolCallOutputBranch1.fromJson(
        _clone(wire),
      );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputFunctionAndCustomToolCallOutputBranch1.fromJson(value),
        throwsA(_safe('LiveInputFunctionAndCustomToolCallOutputBranch1')),
      );
      expect(
        () => LiveInputFunctionAndCustomToolCallOutputBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFunctionAndCustomToolCallOutput')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputFunctionAndCustomToolCallOutputBranch1.fromJson(value),
        throwsA(_safe('LiveInputFunctionAndCustomToolCallOutputBranch1')),
      );
      expect(
        () => LiveInputFunctionAndCustomToolCallOutputBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFunctionAndCustomToolCallOutput')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputFunctionAndCustomToolCallOutputBranch1.fromJson(value),
        throwsA(_safe('LiveInputFunctionAndCustomToolCallOutputBranch1')),
      );
      expect(
        () => LiveInputFunctionAndCustomToolCallOutputBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFunctionAndCustomToolCallOutput')),
      );
    });
  });
  group('LiveInputFunctionAndCustomToolCallOutputBranch2', () {
    final wire = {
      'detail': 'auto',
      'file_data': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'file_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'file_url': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'filename': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'prompt_cache_breakpoint': {'mode': 'explicit'},
      'type': 'input_file',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputFunctionAndCustomToolCallOutputBranch2.fromJson(
          _clone(wire),
        );
        final peer = LiveInputFunctionAndCustomToolCallOutputBranch2.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputFunctionAndCustomToolCallOutput.fromJson(
            _clone(wire),
          ).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputFunctionAndCustomToolCallOutputBranch2.fromJson(
        _clone(wire),
      );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputFunctionAndCustomToolCallOutputBranch2.fromJson(value),
        throwsA(_safe('LiveInputFunctionAndCustomToolCallOutputBranch2')),
      );
      expect(
        () => LiveInputFunctionAndCustomToolCallOutputBranch2.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFunctionAndCustomToolCallOutput')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputFunctionAndCustomToolCallOutputBranch2.fromJson(value),
        throwsA(_safe('LiveInputFunctionAndCustomToolCallOutputBranch2')),
      );
      expect(
        () => LiveInputFunctionAndCustomToolCallOutputBranch2.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFunctionAndCustomToolCallOutput')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputFunctionAndCustomToolCallOutputBranch2.fromJson(value),
        throwsA(_safe('LiveInputFunctionAndCustomToolCallOutputBranch2')),
      );
      expect(
        () => LiveInputFunctionAndCustomToolCallOutputBranch2.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFunctionAndCustomToolCallOutput')),
      );
    });
  });
  group('LiveInputFunctionCallItemStatus', () {
    const wire = 'in_progress';
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputFunctionCallItemStatus.fromJson(_clone(wire));
        final peer = LiveInputFunctionCallItemStatus.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputFunctionCallItemStatus.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputFunctionCallItemStatus.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputFunctionCallItemStatus.fromJson(value),
        throwsA(_safe('LiveInputFunctionCallItemStatus')),
      );
      expect(
        () => LiveInputFunctionCallItemStatus.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFunctionCallItemStatus')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputFunctionCallItemStatus.fromJson(value),
        throwsA(_safe('LiveInputFunctionCallItemStatus')),
      );
      expect(
        () => LiveInputFunctionCallItemStatus.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFunctionCallItemStatus')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputFunctionCallItemStatus.fromJson(value),
        throwsA(_safe('LiveInputFunctionCallItemStatus')),
      );
      expect(
        () => LiveInputFunctionCallItemStatus.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFunctionCallItemStatus')),
      );
    });
  });
  group('LiveInputFunctionCallOutputItemParamOutputValueBranch0', () {
    const wire = 'PRIVATE_LIVE_INPUT_PAYLOAD';
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model =
            LiveInputFunctionCallOutputItemParamOutputValueBranch0.fromJson(
              _clone(wire),
            );
        final peer =
            LiveInputFunctionCallOutputItemParamOutputValueBranch0.fromJson(
              _clone(wire),
            );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputFunctionCallOutputItemParamOutputValue.fromJson(
            _clone(wire),
          ).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model =
          LiveInputFunctionCallOutputItemParamOutputValueBranch0.fromJson(
            _clone(wire),
          );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputFunctionCallOutputItemParamOutputValueBranch0.fromJson(
          value,
        ),
        throwsA(
          _safe('LiveInputFunctionCallOutputItemParamOutputValueBranch0'),
        ),
      );
      expect(
        () => LiveInputFunctionCallOutputItemParamOutputValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFunctionCallOutputItemParamOutputValue')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputFunctionCallOutputItemParamOutputValueBranch0.fromJson(
          value,
        ),
        throwsA(
          _safe('LiveInputFunctionCallOutputItemParamOutputValueBranch0'),
        ),
      );
      expect(
        () => LiveInputFunctionCallOutputItemParamOutputValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFunctionCallOutputItemParamOutputValue')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputFunctionCallOutputItemParamOutputValueBranch0.fromJson(
          value,
        ),
        throwsA(
          _safe('LiveInputFunctionCallOutputItemParamOutputValueBranch0'),
        ),
      );
      expect(
        () => LiveInputFunctionCallOutputItemParamOutputValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFunctionCallOutputItemParamOutputValue')),
      );
    });
  });
  group('LiveInputFunctionCallOutputItemParamOutputValueBranch1', () {
    final wire = [
      {
        'prompt_cache_breakpoint': {'mode': 'explicit'},
        'text': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        'type': 'input_text',
      },
    ];
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model =
            LiveInputFunctionCallOutputItemParamOutputValueBranch1.fromJson(
              _clone(wire),
            );
        final peer =
            LiveInputFunctionCallOutputItemParamOutputValueBranch1.fromJson(
              _clone(wire),
            );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputFunctionCallOutputItemParamOutputValue.fromJson(
            _clone(wire),
          ).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model =
          LiveInputFunctionCallOutputItemParamOutputValueBranch1.fromJson(
            _clone(wire),
          );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputFunctionCallOutputItemParamOutputValueBranch1.fromJson(
          value,
        ),
        throwsA(
          _safe('LiveInputFunctionCallOutputItemParamOutputValueBranch1'),
        ),
      );
      expect(
        () => LiveInputFunctionCallOutputItemParamOutputValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFunctionCallOutputItemParamOutputValue')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputFunctionCallOutputItemParamOutputValueBranch1.fromJson(
          value,
        ),
        throwsA(
          _safe('LiveInputFunctionCallOutputItemParamOutputValueBranch1'),
        ),
      );
      expect(
        () => LiveInputFunctionCallOutputItemParamOutputValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFunctionCallOutputItemParamOutputValue')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputFunctionCallOutputItemParamOutputValueBranch1.fromJson(
          value,
        ),
        throwsA(
          _safe('LiveInputFunctionCallOutputItemParamOutputValueBranch1'),
        ),
      );
      expect(
        () => LiveInputFunctionCallOutputItemParamOutputValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFunctionCallOutputItemParamOutputValue')),
      );
    });
  });
  group('LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch0', () {
    final wire = {
      'prompt_cache_breakpoint': {'mode': 'explicit'},
      'text': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'input_text',
    };
    test('direct factory typed value/wire/copy/value/hash/private contracts', () {
      final model =
          LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch0.fromJson(
            _clone(wire),
          );
      final peer =
          LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch0.fromJson(
            _clone(wire),
          );
      expect(model.toJson(), wire);
      expect(_wire(model.value), wire);
      expect(model, peer);
      expect(model.hashCode, peer.hashCode);
      expect(model.copyWith(), model);
      expect(model.copyWith(value: _clone(wire)), model);
      expect(model.toString(), isNot(contains(_private)));
      expect(
        LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValue.fromJson(
          _clone(wire),
        ).toJson(),
        wire,
      );
    });
    test('parsed wire and typed collection access stay immutable', () {
      final model =
          LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch0.fromJson(
            _clone(wire),
          );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () =>
            LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch0.fromJson(
              value,
            ),
        throwsA(
          _safe(
            'LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch0',
          ),
        ),
      );
      expect(
        () =>
            LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch0.fromJson(
              _clone(wire),
            ).copyWith(value: value),
        throwsA(
          _safe(
            'LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValue',
          ),
        ),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () =>
            LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch0.fromJson(
              value,
            ),
        throwsA(
          _safe(
            'LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch0',
          ),
        ),
      );
      expect(
        () =>
            LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch0.fromJson(
              _clone(wire),
            ).copyWith(value: value),
        throwsA(
          _safe(
            'LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValue',
          ),
        ),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () =>
            LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch0.fromJson(
              value,
            ),
        throwsA(
          _safe(
            'LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch0',
          ),
        ),
      );
      expect(
        () =>
            LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch0.fromJson(
              _clone(wire),
            ).copyWith(value: value),
        throwsA(
          _safe(
            'LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValue',
          ),
        ),
      );
    });
  });
  group('LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch1', () {
    final wire = {
      'detail': 'low',
      'file_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'image_url': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'prompt_cache_breakpoint': {'mode': 'explicit'},
      'type': 'input_image',
    };
    test('direct factory typed value/wire/copy/value/hash/private contracts', () {
      final model =
          LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch1.fromJson(
            _clone(wire),
          );
      final peer =
          LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch1.fromJson(
            _clone(wire),
          );
      expect(model.toJson(), wire);
      expect(_wire(model.value), wire);
      expect(model, peer);
      expect(model.hashCode, peer.hashCode);
      expect(model.copyWith(), model);
      expect(model.copyWith(value: _clone(wire)), model);
      expect(model.toString(), isNot(contains(_private)));
      expect(
        LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValue.fromJson(
          _clone(wire),
        ).toJson(),
        wire,
      );
    });
    test('parsed wire and typed collection access stay immutable', () {
      final model =
          LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch1.fromJson(
            _clone(wire),
          );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () =>
            LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch1.fromJson(
              value,
            ),
        throwsA(
          _safe(
            'LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch1',
          ),
        ),
      );
      expect(
        () =>
            LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch1.fromJson(
              _clone(wire),
            ).copyWith(value: value),
        throwsA(
          _safe(
            'LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValue',
          ),
        ),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () =>
            LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch1.fromJson(
              value,
            ),
        throwsA(
          _safe(
            'LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch1',
          ),
        ),
      );
      expect(
        () =>
            LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch1.fromJson(
              _clone(wire),
            ).copyWith(value: value),
        throwsA(
          _safe(
            'LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValue',
          ),
        ),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () =>
            LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch1.fromJson(
              value,
            ),
        throwsA(
          _safe(
            'LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch1',
          ),
        ),
      );
      expect(
        () =>
            LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch1.fromJson(
              _clone(wire),
            ).copyWith(value: value),
        throwsA(
          _safe(
            'LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValue',
          ),
        ),
      );
    });
  });
  group('LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch2', () {
    final wire = {
      'detail': 'auto',
      'file_data': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'file_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'file_url': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'filename': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'prompt_cache_breakpoint': {'mode': 'explicit'},
      'type': 'input_file',
    };
    test('direct factory typed value/wire/copy/value/hash/private contracts', () {
      final model =
          LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch2.fromJson(
            _clone(wire),
          );
      final peer =
          LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch2.fromJson(
            _clone(wire),
          );
      expect(model.toJson(), wire);
      expect(_wire(model.value), wire);
      expect(model, peer);
      expect(model.hashCode, peer.hashCode);
      expect(model.copyWith(), model);
      expect(model.copyWith(value: _clone(wire)), model);
      expect(model.toString(), isNot(contains(_private)));
      expect(
        LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValue.fromJson(
          _clone(wire),
        ).toJson(),
        wire,
      );
    });
    test('parsed wire and typed collection access stay immutable', () {
      final model =
          LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch2.fromJson(
            _clone(wire),
          );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () =>
            LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch2.fromJson(
              value,
            ),
        throwsA(
          _safe(
            'LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch2',
          ),
        ),
      );
      expect(
        () =>
            LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch2.fromJson(
              _clone(wire),
            ).copyWith(value: value),
        throwsA(
          _safe(
            'LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValue',
          ),
        ),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () =>
            LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch2.fromJson(
              value,
            ),
        throwsA(
          _safe(
            'LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch2',
          ),
        ),
      );
      expect(
        () =>
            LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch2.fromJson(
              _clone(wire),
            ).copyWith(value: value),
        throwsA(
          _safe(
            'LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValue',
          ),
        ),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () =>
            LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch2.fromJson(
              value,
            ),
        throwsA(
          _safe(
            'LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch2',
          ),
        ),
      );
      expect(
        () =>
            LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch2.fromJson(
              _clone(wire),
            ).copyWith(value: value),
        throwsA(
          _safe(
            'LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValue',
          ),
        ),
      );
    });
  });
  group('LiveInputFunctionShellCallItemParamEnvironmentValueBranch0', () {
    final wire = {
      'skills': [
        {
          'description': 'PRIVATE_LIVE_INPUT_PAYLOAD',
          'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
          'path': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        },
      ],
      'type': 'local',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model =
            LiveInputFunctionShellCallItemParamEnvironmentValueBranch0.fromJson(
              _clone(wire),
            );
        final peer =
            LiveInputFunctionShellCallItemParamEnvironmentValueBranch0.fromJson(
              _clone(wire),
            );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputFunctionShellCallItemParamEnvironmentValue.fromJson(
            _clone(wire),
          ).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model =
          LiveInputFunctionShellCallItemParamEnvironmentValueBranch0.fromJson(
            _clone(wire),
          );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () =>
            LiveInputFunctionShellCallItemParamEnvironmentValueBranch0.fromJson(
              value,
            ),
        throwsA(
          _safe('LiveInputFunctionShellCallItemParamEnvironmentValueBranch0'),
        ),
      );
      expect(
        () =>
            LiveInputFunctionShellCallItemParamEnvironmentValueBranch0.fromJson(
              _clone(wire),
            ).copyWith(value: value),
        throwsA(_safe('LiveInputFunctionShellCallItemParamEnvironmentValue')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () =>
            LiveInputFunctionShellCallItemParamEnvironmentValueBranch0.fromJson(
              value,
            ),
        throwsA(
          _safe('LiveInputFunctionShellCallItemParamEnvironmentValueBranch0'),
        ),
      );
      expect(
        () =>
            LiveInputFunctionShellCallItemParamEnvironmentValueBranch0.fromJson(
              _clone(wire),
            ).copyWith(value: value),
        throwsA(_safe('LiveInputFunctionShellCallItemParamEnvironmentValue')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () =>
            LiveInputFunctionShellCallItemParamEnvironmentValueBranch0.fromJson(
              value,
            ),
        throwsA(
          _safe('LiveInputFunctionShellCallItemParamEnvironmentValueBranch0'),
        ),
      );
      expect(
        () =>
            LiveInputFunctionShellCallItemParamEnvironmentValueBranch0.fromJson(
              _clone(wire),
            ).copyWith(value: value),
        throwsA(_safe('LiveInputFunctionShellCallItemParamEnvironmentValue')),
      );
    });
  });
  group('LiveInputFunctionShellCallItemParamEnvironmentValueBranch1', () {
    final wire = {
      'container_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'container_reference',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model =
            LiveInputFunctionShellCallItemParamEnvironmentValueBranch1.fromJson(
              _clone(wire),
            );
        final peer =
            LiveInputFunctionShellCallItemParamEnvironmentValueBranch1.fromJson(
              _clone(wire),
            );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputFunctionShellCallItemParamEnvironmentValue.fromJson(
            _clone(wire),
          ).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model =
          LiveInputFunctionShellCallItemParamEnvironmentValueBranch1.fromJson(
            _clone(wire),
          );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () =>
            LiveInputFunctionShellCallItemParamEnvironmentValueBranch1.fromJson(
              value,
            ),
        throwsA(
          _safe('LiveInputFunctionShellCallItemParamEnvironmentValueBranch1'),
        ),
      );
      expect(
        () =>
            LiveInputFunctionShellCallItemParamEnvironmentValueBranch1.fromJson(
              _clone(wire),
            ).copyWith(value: value),
        throwsA(_safe('LiveInputFunctionShellCallItemParamEnvironmentValue')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () =>
            LiveInputFunctionShellCallItemParamEnvironmentValueBranch1.fromJson(
              value,
            ),
        throwsA(
          _safe('LiveInputFunctionShellCallItemParamEnvironmentValueBranch1'),
        ),
      );
      expect(
        () =>
            LiveInputFunctionShellCallItemParamEnvironmentValueBranch1.fromJson(
              _clone(wire),
            ).copyWith(value: value),
        throwsA(_safe('LiveInputFunctionShellCallItemParamEnvironmentValue')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () =>
            LiveInputFunctionShellCallItemParamEnvironmentValueBranch1.fromJson(
              value,
            ),
        throwsA(
          _safe('LiveInputFunctionShellCallItemParamEnvironmentValueBranch1'),
        ),
      );
      expect(
        () =>
            LiveInputFunctionShellCallItemParamEnvironmentValueBranch1.fromJson(
              _clone(wire),
            ).copyWith(value: value),
        throwsA(_safe('LiveInputFunctionShellCallItemParamEnvironmentValue')),
      );
    });
  });
  group('LiveInputFunctionShellCallItemStatus', () {
    const wire = 'in_progress';
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputFunctionShellCallItemStatus.fromJson(
          _clone(wire),
        );
        final peer = LiveInputFunctionShellCallItemStatus.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputFunctionShellCallItemStatus.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputFunctionShellCallItemStatus.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputFunctionShellCallItemStatus.fromJson(value),
        throwsA(_safe('LiveInputFunctionShellCallItemStatus')),
      );
      expect(
        () => LiveInputFunctionShellCallItemStatus.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFunctionShellCallItemStatus')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputFunctionShellCallItemStatus.fromJson(value),
        throwsA(_safe('LiveInputFunctionShellCallItemStatus')),
      );
      expect(
        () => LiveInputFunctionShellCallItemStatus.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFunctionShellCallItemStatus')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputFunctionShellCallItemStatus.fromJson(value),
        throwsA(_safe('LiveInputFunctionShellCallItemStatus')),
      );
      expect(
        () => LiveInputFunctionShellCallItemStatus.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFunctionShellCallItemStatus')),
      );
    });
  });
  group('LiveInputFunctionShellCallOutputOutcomeParamBranch0', () {
    final wire = {'type': 'timeout'};
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model =
            LiveInputFunctionShellCallOutputOutcomeParamBranch0.fromJson(
              _clone(wire),
            );
        final peer =
            LiveInputFunctionShellCallOutputOutcomeParamBranch0.fromJson(
              _clone(wire),
            );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputFunctionShellCallOutputOutcomeParam.fromJson(
            _clone(wire),
          ).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model =
          LiveInputFunctionShellCallOutputOutcomeParamBranch0.fromJson(
            _clone(wire),
          );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () =>
            LiveInputFunctionShellCallOutputOutcomeParamBranch0.fromJson(value),
        throwsA(_safe('LiveInputFunctionShellCallOutputOutcomeParamBranch0')),
      );
      expect(
        () => LiveInputFunctionShellCallOutputOutcomeParamBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFunctionShellCallOutputOutcomeParam')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () =>
            LiveInputFunctionShellCallOutputOutcomeParamBranch0.fromJson(value),
        throwsA(_safe('LiveInputFunctionShellCallOutputOutcomeParamBranch0')),
      );
      expect(
        () => LiveInputFunctionShellCallOutputOutcomeParamBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFunctionShellCallOutputOutcomeParam')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () =>
            LiveInputFunctionShellCallOutputOutcomeParamBranch0.fromJson(value),
        throwsA(_safe('LiveInputFunctionShellCallOutputOutcomeParamBranch0')),
      );
      expect(
        () => LiveInputFunctionShellCallOutputOutcomeParamBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFunctionShellCallOutputOutcomeParam')),
      );
    });
  });
  group('LiveInputFunctionShellCallOutputOutcomeParamBranch1', () {
    final wire = {'exit_code': 0, 'type': 'exit'};
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model =
            LiveInputFunctionShellCallOutputOutcomeParamBranch1.fromJson(
              _clone(wire),
            );
        final peer =
            LiveInputFunctionShellCallOutputOutcomeParamBranch1.fromJson(
              _clone(wire),
            );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputFunctionShellCallOutputOutcomeParam.fromJson(
            _clone(wire),
          ).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model =
          LiveInputFunctionShellCallOutputOutcomeParamBranch1.fromJson(
            _clone(wire),
          );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () =>
            LiveInputFunctionShellCallOutputOutcomeParamBranch1.fromJson(value),
        throwsA(_safe('LiveInputFunctionShellCallOutputOutcomeParamBranch1')),
      );
      expect(
        () => LiveInputFunctionShellCallOutputOutcomeParamBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFunctionShellCallOutputOutcomeParam')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () =>
            LiveInputFunctionShellCallOutputOutcomeParamBranch1.fromJson(value),
        throwsA(_safe('LiveInputFunctionShellCallOutputOutcomeParamBranch1')),
      );
      expect(
        () => LiveInputFunctionShellCallOutputOutcomeParamBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFunctionShellCallOutputOutcomeParam')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () =>
            LiveInputFunctionShellCallOutputOutcomeParamBranch1.fromJson(value),
        throwsA(_safe('LiveInputFunctionShellCallOutputOutcomeParamBranch1')),
      );
      expect(
        () => LiveInputFunctionShellCallOutputOutcomeParamBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFunctionShellCallOutputOutcomeParam')),
      );
    });
  });
  group('LiveInputFunctionShellToolParamEnvironmentValueBranch0', () {
    final wire = {
      'file_ids': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
      'memory_limit': '1g',
      'network_policy': {'type': 'disabled'},
      'skills': [
        {
          'skill_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
          'type': 'skill_reference',
          'version': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        },
      ],
      'type': 'container_auto',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model =
            LiveInputFunctionShellToolParamEnvironmentValueBranch0.fromJson(
              _clone(wire),
            );
        final peer =
            LiveInputFunctionShellToolParamEnvironmentValueBranch0.fromJson(
              _clone(wire),
            );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputFunctionShellToolParamEnvironmentValue.fromJson(
            _clone(wire),
          ).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model =
          LiveInputFunctionShellToolParamEnvironmentValueBranch0.fromJson(
            _clone(wire),
          );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputFunctionShellToolParamEnvironmentValueBranch0.fromJson(
          value,
        ),
        throwsA(
          _safe('LiveInputFunctionShellToolParamEnvironmentValueBranch0'),
        ),
      );
      expect(
        () => LiveInputFunctionShellToolParamEnvironmentValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFunctionShellToolParamEnvironmentValue')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputFunctionShellToolParamEnvironmentValueBranch0.fromJson(
          value,
        ),
        throwsA(
          _safe('LiveInputFunctionShellToolParamEnvironmentValueBranch0'),
        ),
      );
      expect(
        () => LiveInputFunctionShellToolParamEnvironmentValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFunctionShellToolParamEnvironmentValue')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputFunctionShellToolParamEnvironmentValueBranch0.fromJson(
          value,
        ),
        throwsA(
          _safe('LiveInputFunctionShellToolParamEnvironmentValueBranch0'),
        ),
      );
      expect(
        () => LiveInputFunctionShellToolParamEnvironmentValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFunctionShellToolParamEnvironmentValue')),
      );
    });
  });
  group('LiveInputFunctionShellToolParamEnvironmentValueBranch1', () {
    final wire = {
      'skills': [
        {
          'description': 'PRIVATE_LIVE_INPUT_PAYLOAD',
          'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
          'path': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        },
      ],
      'type': 'local',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model =
            LiveInputFunctionShellToolParamEnvironmentValueBranch1.fromJson(
              _clone(wire),
            );
        final peer =
            LiveInputFunctionShellToolParamEnvironmentValueBranch1.fromJson(
              _clone(wire),
            );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputFunctionShellToolParamEnvironmentValue.fromJson(
            _clone(wire),
          ).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model =
          LiveInputFunctionShellToolParamEnvironmentValueBranch1.fromJson(
            _clone(wire),
          );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputFunctionShellToolParamEnvironmentValueBranch1.fromJson(
          value,
        ),
        throwsA(
          _safe('LiveInputFunctionShellToolParamEnvironmentValueBranch1'),
        ),
      );
      expect(
        () => LiveInputFunctionShellToolParamEnvironmentValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFunctionShellToolParamEnvironmentValue')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputFunctionShellToolParamEnvironmentValueBranch1.fromJson(
          value,
        ),
        throwsA(
          _safe('LiveInputFunctionShellToolParamEnvironmentValueBranch1'),
        ),
      );
      expect(
        () => LiveInputFunctionShellToolParamEnvironmentValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFunctionShellToolParamEnvironmentValue')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputFunctionShellToolParamEnvironmentValueBranch1.fromJson(
          value,
        ),
        throwsA(
          _safe('LiveInputFunctionShellToolParamEnvironmentValueBranch1'),
        ),
      );
      expect(
        () => LiveInputFunctionShellToolParamEnvironmentValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFunctionShellToolParamEnvironmentValue')),
      );
    });
  });
  group('LiveInputFunctionShellToolParamEnvironmentValueBranch2', () {
    final wire = {
      'container_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'container_reference',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model =
            LiveInputFunctionShellToolParamEnvironmentValueBranch2.fromJson(
              _clone(wire),
            );
        final peer =
            LiveInputFunctionShellToolParamEnvironmentValueBranch2.fromJson(
              _clone(wire),
            );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputFunctionShellToolParamEnvironmentValue.fromJson(
            _clone(wire),
          ).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model =
          LiveInputFunctionShellToolParamEnvironmentValueBranch2.fromJson(
            _clone(wire),
          );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputFunctionShellToolParamEnvironmentValueBranch2.fromJson(
          value,
        ),
        throwsA(
          _safe('LiveInputFunctionShellToolParamEnvironmentValueBranch2'),
        ),
      );
      expect(
        () => LiveInputFunctionShellToolParamEnvironmentValueBranch2.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFunctionShellToolParamEnvironmentValue')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputFunctionShellToolParamEnvironmentValueBranch2.fromJson(
          value,
        ),
        throwsA(
          _safe('LiveInputFunctionShellToolParamEnvironmentValueBranch2'),
        ),
      );
      expect(
        () => LiveInputFunctionShellToolParamEnvironmentValueBranch2.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFunctionShellToolParamEnvironmentValue')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputFunctionShellToolParamEnvironmentValueBranch2.fromJson(
          value,
        ),
        throwsA(
          _safe('LiveInputFunctionShellToolParamEnvironmentValueBranch2'),
        ),
      );
      expect(
        () => LiveInputFunctionShellToolParamEnvironmentValueBranch2.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputFunctionShellToolParamEnvironmentValue')),
      );
    });
  });
  group('LiveInputGrammarSyntax1', () {
    const wire = 'lark';
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputGrammarSyntax1.fromJson(_clone(wire));
        final peer = LiveInputGrammarSyntax1.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputGrammarSyntax1.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputGrammarSyntax1.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputGrammarSyntax1.fromJson(value),
        throwsA(_safe('LiveInputGrammarSyntax1')),
      );
      expect(
        () => LiveInputGrammarSyntax1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputGrammarSyntax1')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputGrammarSyntax1.fromJson(value),
        throwsA(_safe('LiveInputGrammarSyntax1')),
      );
      expect(
        () => LiveInputGrammarSyntax1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputGrammarSyntax1')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputGrammarSyntax1.fromJson(value),
        throwsA(_safe('LiveInputGrammarSyntax1')),
      );
      expect(
        () => LiveInputGrammarSyntax1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputGrammarSyntax1')),
      );
    });
  });
  group('LiveInputHistoryItemBranch0', () {
    final wire = {
      'content': [
        {
          'prompt_cache_breakpoint': {'mode': 'explicit'},
          'text': 'PRIVATE_LIVE_INPUT_PAYLOAD',
          'type': 'input_text',
        },
      ],
      'role': 'user',
      'status': 'in_progress',
      'type': 'message',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputHistoryItemBranch0.fromJson(_clone(wire));
        final peer = LiveInputHistoryItemBranch0.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputHistoryItem.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputHistoryItemBranch0.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputHistoryItemBranch0.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch0')),
      );
      expect(
        () => LiveInputHistoryItemBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputHistoryItemBranch0.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch0')),
      );
      expect(
        () => LiveInputHistoryItemBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputHistoryItemBranch0.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch0')),
      );
      expect(
        () => LiveInputHistoryItemBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
  });
  group('LiveInputHistoryItemBranch1', () {
    final wire = {
      'content': [
        {
          'annotations': [
            {
              'file_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
              'filename': 'PRIVATE_LIVE_INPUT_PAYLOAD',
              'index': 0,
              'type': 'file_citation',
            },
          ],
          'logprobs': [
            {
              'bytes': [0],
              'logprob': 0,
              'token': 'PRIVATE_LIVE_INPUT_PAYLOAD',
              'top_logprobs': [
                {
                  'bytes': [0],
                  'logprob': 0,
                  'token': 'PRIVATE_LIVE_INPUT_PAYLOAD',
                },
              ],
            },
          ],
          'text': 'PRIVATE_LIVE_INPUT_PAYLOAD',
          'type': 'output_text',
        },
      ],
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'phase': 'commentary',
      'role': 'assistant',
      'status': 'in_progress',
      'type': 'message',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputHistoryItemBranch1.fromJson(_clone(wire));
        final peer = LiveInputHistoryItemBranch1.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputHistoryItem.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputHistoryItemBranch1.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputHistoryItemBranch1.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch1')),
      );
      expect(
        () => LiveInputHistoryItemBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputHistoryItemBranch1.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch1')),
      );
      expect(
        () => LiveInputHistoryItemBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputHistoryItemBranch1.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch1')),
      );
      expect(
        () => LiveInputHistoryItemBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
  });
  group('LiveInputHistoryItemBranch2', () {
    final wire = {
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'queries': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
      'results': [
        {
          'attributes': <String, dynamic>{},
          'file_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
          'filename': 'PRIVATE_LIVE_INPUT_PAYLOAD',
          'score': 0,
          'text': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        },
      ],
      'status': 'in_progress',
      'type': 'file_search_call',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputHistoryItemBranch2.fromJson(_clone(wire));
        final peer = LiveInputHistoryItemBranch2.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputHistoryItem.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputHistoryItemBranch2.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputHistoryItemBranch2.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch2')),
      );
      expect(
        () => LiveInputHistoryItemBranch2.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputHistoryItemBranch2.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch2')),
      );
      expect(
        () => LiveInputHistoryItemBranch2.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputHistoryItemBranch2.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch2')),
      );
      expect(
        () => LiveInputHistoryItemBranch2.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
  });
  group('LiveInputHistoryItemBranch3', () {
    final wire = {
      'action': {
        'button': 'left',
        'keys': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
        'type': 'click',
        'x': 0,
        'y': 0,
      },
      'actions': [
        {
          'button': 'left',
          'keys': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
          'type': 'click',
          'x': 0,
          'y': 0,
        },
      ],
      'call_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'pending_safety_checks': [
        {
          'code': 'PRIVATE_LIVE_INPUT_PAYLOAD',
          'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
          'message': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        },
      ],
      'status': 'in_progress',
      'type': 'computer_call',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputHistoryItemBranch3.fromJson(_clone(wire));
        final peer = LiveInputHistoryItemBranch3.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputHistoryItem.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputHistoryItemBranch3.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputHistoryItemBranch3.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch3')),
      );
      expect(
        () => LiveInputHistoryItemBranch3.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputHistoryItemBranch3.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch3')),
      );
      expect(
        () => LiveInputHistoryItemBranch3.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputHistoryItemBranch3.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch3')),
      );
      expect(
        () => LiveInputHistoryItemBranch3.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
  });
  group('LiveInputHistoryItemBranch4', () {
    final wire = {
      'acknowledged_safety_checks': [
        {
          'code': 'PRIVATE_LIVE_INPUT_PAYLOAD',
          'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
          'message': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        },
      ],
      'call_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'output': {
        'file_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        'image_url': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        'type': 'computer_screenshot',
      },
      'status': 'in_progress',
      'type': 'computer_call_output',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputHistoryItemBranch4.fromJson(_clone(wire));
        final peer = LiveInputHistoryItemBranch4.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputHistoryItem.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputHistoryItemBranch4.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputHistoryItemBranch4.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch4')),
      );
      expect(
        () => LiveInputHistoryItemBranch4.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputHistoryItemBranch4.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch4')),
      );
      expect(
        () => LiveInputHistoryItemBranch4.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputHistoryItemBranch4.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch4')),
      );
      expect(
        () => LiveInputHistoryItemBranch4.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
  });
  group('LiveInputHistoryItemBranch5', () {
    final wire = {
      'action': {
        'queries': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
        'query': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        'sources': [
          {'type': 'url', 'url': 'PRIVATE_LIVE_INPUT_PAYLOAD'},
        ],
        'type': 'search',
      },
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'status': 'in_progress',
      'type': 'web_search_call',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputHistoryItemBranch5.fromJson(_clone(wire));
        final peer = LiveInputHistoryItemBranch5.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputHistoryItem.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputHistoryItemBranch5.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputHistoryItemBranch5.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch5')),
      );
      expect(
        () => LiveInputHistoryItemBranch5.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputHistoryItemBranch5.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch5')),
      );
      expect(
        () => LiveInputHistoryItemBranch5.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputHistoryItemBranch5.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch5')),
      );
      expect(
        () => LiveInputHistoryItemBranch5.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
  });
  group('LiveInputHistoryItemBranch6', () {
    final wire = {
      'arguments': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'async': false,
      'call_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'caller': {'type': 'direct'},
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'namespace': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'status': 'in_progress',
      'type': 'function_call',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputHistoryItemBranch6.fromJson(_clone(wire));
        final peer = LiveInputHistoryItemBranch6.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputHistoryItem.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputHistoryItemBranch6.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputHistoryItemBranch6.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch6')),
      );
      expect(
        () => LiveInputHistoryItemBranch6.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputHistoryItemBranch6.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch6')),
      );
      expect(
        () => LiveInputHistoryItemBranch6.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputHistoryItemBranch6.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch6')),
      );
      expect(
        () => LiveInputHistoryItemBranch6.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
  });
  group('LiveInputHistoryItemBranch7', () {
    final wire = {
      'call_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'caller': {'type': 'direct'},
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'namespace': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'output': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'status': 'in_progress',
      'type': 'function_call_output',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputHistoryItemBranch7.fromJson(_clone(wire));
        final peer = LiveInputHistoryItemBranch7.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputHistoryItem.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputHistoryItemBranch7.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputHistoryItemBranch7.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch7')),
      );
      expect(
        () => LiveInputHistoryItemBranch7.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputHistoryItemBranch7.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch7')),
      );
      expect(
        () => LiveInputHistoryItemBranch7.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputHistoryItemBranch7.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch7')),
      );
      expect(
        () => LiveInputHistoryItemBranch7.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
  });
  group('LiveInputHistoryItemBranch8', () {
    final wire = {
      'arguments': <String, dynamic>{},
      'call_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'execution': 'server',
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'status': 'in_progress',
      'type': 'tool_search_call',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputHistoryItemBranch8.fromJson(_clone(wire));
        final peer = LiveInputHistoryItemBranch8.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputHistoryItem.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputHistoryItemBranch8.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputHistoryItemBranch8.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch8')),
      );
      expect(
        () => LiveInputHistoryItemBranch8.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputHistoryItemBranch8.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch8')),
      );
      expect(
        () => LiveInputHistoryItemBranch8.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputHistoryItemBranch8.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch8')),
      );
      expect(
        () => LiveInputHistoryItemBranch8.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
  });
  group('LiveInputHistoryItemBranch9', () {
    final wire = {
      'call_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'execution': 'server',
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'status': 'in_progress',
      'tools': [
        {
          'allowed_callers': ['direct'],
          'async': false,
          'defer_loading': false,
          'description': 'PRIVATE_LIVE_INPUT_PAYLOAD',
          'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
          'output_schema': <String, dynamic>{},
          'parameters': <String, dynamic>{},
          'strict': false,
          'type': 'function',
        },
      ],
      'type': 'tool_search_output',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputHistoryItemBranch9.fromJson(_clone(wire));
        final peer = LiveInputHistoryItemBranch9.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputHistoryItem.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputHistoryItemBranch9.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputHistoryItemBranch9.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch9')),
      );
      expect(
        () => LiveInputHistoryItemBranch9.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputHistoryItemBranch9.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch9')),
      );
      expect(
        () => LiveInputHistoryItemBranch9.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputHistoryItemBranch9.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch9')),
      );
      expect(
        () => LiveInputHistoryItemBranch9.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
  });
  group('LiveInputHistoryItemBranch10', () {
    final wire = {
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'role': 'developer',
      'tools': [
        {
          'allowed_callers': ['direct'],
          'async': false,
          'defer_loading': false,
          'description': 'PRIVATE_LIVE_INPUT_PAYLOAD',
          'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
          'output_schema': <String, dynamic>{},
          'parameters': <String, dynamic>{},
          'strict': false,
          'type': 'function',
        },
      ],
      'type': 'additional_tools',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputHistoryItemBranch10.fromJson(_clone(wire));
        final peer = LiveInputHistoryItemBranch10.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputHistoryItem.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputHistoryItemBranch10.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputHistoryItemBranch10.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch10')),
      );
      expect(
        () => LiveInputHistoryItemBranch10.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputHistoryItemBranch10.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch10')),
      );
      expect(
        () => LiveInputHistoryItemBranch10.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputHistoryItemBranch10.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch10')),
      );
      expect(
        () => LiveInputHistoryItemBranch10.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
  });
  group('LiveInputHistoryItemBranch11', () {
    final wire = {
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'reasoning': {'effort': 'none'},
      'type': 'configuration_update',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputHistoryItemBranch11.fromJson(_clone(wire));
        final peer = LiveInputHistoryItemBranch11.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputHistoryItem.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputHistoryItemBranch11.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputHistoryItemBranch11.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch11')),
      );
      expect(
        () => LiveInputHistoryItemBranch11.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputHistoryItemBranch11.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch11')),
      );
      expect(
        () => LiveInputHistoryItemBranch11.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputHistoryItemBranch11.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch11')),
      );
      expect(
        () => LiveInputHistoryItemBranch11.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
  });
  group('LiveInputHistoryItemBranch12', () {
    final wire = {
      'content': [
        {'text': 'PRIVATE_LIVE_INPUT_PAYLOAD', 'type': 'reasoning_text'},
      ],
      'encrypted_content': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'status': 'in_progress',
      'summary': [
        {'text': 'PRIVATE_LIVE_INPUT_PAYLOAD', 'type': 'summary_text'},
      ],
      'type': 'reasoning',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputHistoryItemBranch12.fromJson(_clone(wire));
        final peer = LiveInputHistoryItemBranch12.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputHistoryItem.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputHistoryItemBranch12.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputHistoryItemBranch12.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch12')),
      );
      expect(
        () => LiveInputHistoryItemBranch12.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputHistoryItemBranch12.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch12')),
      );
      expect(
        () => LiveInputHistoryItemBranch12.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputHistoryItemBranch12.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch12')),
      );
      expect(
        () => LiveInputHistoryItemBranch12.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
  });
  group('LiveInputHistoryItemBranch13', () {
    final wire = {
      'encrypted_content': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'compaction',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputHistoryItemBranch13.fromJson(_clone(wire));
        final peer = LiveInputHistoryItemBranch13.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputHistoryItem.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputHistoryItemBranch13.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputHistoryItemBranch13.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch13')),
      );
      expect(
        () => LiveInputHistoryItemBranch13.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputHistoryItemBranch13.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch13')),
      );
      expect(
        () => LiveInputHistoryItemBranch13.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputHistoryItemBranch13.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch13')),
      );
      expect(
        () => LiveInputHistoryItemBranch13.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
  });
  group('LiveInputHistoryItemBranch14', () {
    final wire = {
      'action': 'generate',
      'background': 'transparent',
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'output_format': 'png',
      'quality': 'low',
      'result': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'revised_prompt': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'size': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'status': 'in_progress',
      'type': 'image_generation_call',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputHistoryItemBranch14.fromJson(_clone(wire));
        final peer = LiveInputHistoryItemBranch14.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputHistoryItem.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputHistoryItemBranch14.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputHistoryItemBranch14.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch14')),
      );
      expect(
        () => LiveInputHistoryItemBranch14.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputHistoryItemBranch14.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch14')),
      );
      expect(
        () => LiveInputHistoryItemBranch14.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputHistoryItemBranch14.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch14')),
      );
      expect(
        () => LiveInputHistoryItemBranch14.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
  });
  group('LiveInputHistoryItemBranch15', () {
    final wire = {
      'code': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'container_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'outputs': [
        {'logs': 'PRIVATE_LIVE_INPUT_PAYLOAD', 'type': 'logs'},
      ],
      'status': 'in_progress',
      'type': 'code_interpreter_call',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputHistoryItemBranch15.fromJson(_clone(wire));
        final peer = LiveInputHistoryItemBranch15.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputHistoryItem.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputHistoryItemBranch15.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputHistoryItemBranch15.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch15')),
      );
      expect(
        () => LiveInputHistoryItemBranch15.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputHistoryItemBranch15.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch15')),
      );
      expect(
        () => LiveInputHistoryItemBranch15.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputHistoryItemBranch15.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch15')),
      );
      expect(
        () => LiveInputHistoryItemBranch15.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
  });
  group('LiveInputHistoryItemBranch16', () {
    final wire = {
      'action': {
        'command': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
        'env': <String, dynamic>{},
        'timeout_ms': 0,
        'type': 'exec',
        'user': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        'working_directory': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      },
      'call_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'status': 'in_progress',
      'type': 'local_shell_call',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputHistoryItemBranch16.fromJson(_clone(wire));
        final peer = LiveInputHistoryItemBranch16.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputHistoryItem.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputHistoryItemBranch16.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputHistoryItemBranch16.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch16')),
      );
      expect(
        () => LiveInputHistoryItemBranch16.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputHistoryItemBranch16.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch16')),
      );
      expect(
        () => LiveInputHistoryItemBranch16.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputHistoryItemBranch16.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch16')),
      );
      expect(
        () => LiveInputHistoryItemBranch16.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
  });
  group('LiveInputHistoryItemBranch17', () {
    final wire = {
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'output': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'status': 'in_progress',
      'type': 'local_shell_call_output',
      'call_id': null,
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputHistoryItemBranch17.fromJson(_clone(wire));
        final peer = LiveInputHistoryItemBranch17.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputHistoryItem.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputHistoryItemBranch17.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputHistoryItemBranch17.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch17')),
      );
      expect(
        () => LiveInputHistoryItemBranch17.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputHistoryItemBranch17.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch17')),
      );
      expect(
        () => LiveInputHistoryItemBranch17.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputHistoryItemBranch17.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch17')),
      );
      expect(
        () => LiveInputHistoryItemBranch17.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
  });
  group('LiveInputHistoryItemBranch18', () {
    final wire = {
      'action': {
        'commands': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
        'max_output_length': 0,
        'timeout_ms': 0,
      },
      'call_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'caller': {'type': 'direct'},
      'environment': {
        'skills': [
          {
            'description': 'PRIVATE_LIVE_INPUT_PAYLOAD',
            'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
            'path': 'PRIVATE_LIVE_INPUT_PAYLOAD',
          },
        ],
        'type': 'local',
      },
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'status': 'in_progress',
      'type': 'shell_call',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputHistoryItemBranch18.fromJson(_clone(wire));
        final peer = LiveInputHistoryItemBranch18.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputHistoryItem.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputHistoryItemBranch18.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputHistoryItemBranch18.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch18')),
      );
      expect(
        () => LiveInputHistoryItemBranch18.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputHistoryItemBranch18.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch18')),
      );
      expect(
        () => LiveInputHistoryItemBranch18.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputHistoryItemBranch18.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch18')),
      );
      expect(
        () => LiveInputHistoryItemBranch18.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
  });
  group('LiveInputHistoryItemBranch19', () {
    final wire = {
      'call_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'caller': {'type': 'direct'},
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'max_output_length': 0,
      'output': [
        {
          'outcome': {'type': 'timeout'},
          'stderr': 'PRIVATE_LIVE_INPUT_PAYLOAD',
          'stdout': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        },
      ],
      'status': 'in_progress',
      'type': 'shell_call_output',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputHistoryItemBranch19.fromJson(_clone(wire));
        final peer = LiveInputHistoryItemBranch19.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputHistoryItem.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputHistoryItemBranch19.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputHistoryItemBranch19.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch19')),
      );
      expect(
        () => LiveInputHistoryItemBranch19.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputHistoryItemBranch19.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch19')),
      );
      expect(
        () => LiveInputHistoryItemBranch19.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputHistoryItemBranch19.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch19')),
      );
      expect(
        () => LiveInputHistoryItemBranch19.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
  });
  group('LiveInputHistoryItemBranch20', () {
    final wire = {
      'call_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'caller': {'type': 'direct'},
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'operation': {
        'diff': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        'path': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        'type': 'create_file',
      },
      'status': 'in_progress',
      'type': 'apply_patch_call',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputHistoryItemBranch20.fromJson(_clone(wire));
        final peer = LiveInputHistoryItemBranch20.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputHistoryItem.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputHistoryItemBranch20.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputHistoryItemBranch20.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch20')),
      );
      expect(
        () => LiveInputHistoryItemBranch20.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputHistoryItemBranch20.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch20')),
      );
      expect(
        () => LiveInputHistoryItemBranch20.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputHistoryItemBranch20.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch20')),
      );
      expect(
        () => LiveInputHistoryItemBranch20.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
  });
  group('LiveInputHistoryItemBranch21', () {
    final wire = {
      'call_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'caller': {'type': 'direct'},
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'output': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'status': 'completed',
      'type': 'apply_patch_call_output',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputHistoryItemBranch21.fromJson(_clone(wire));
        final peer = LiveInputHistoryItemBranch21.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputHistoryItem.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputHistoryItemBranch21.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputHistoryItemBranch21.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch21')),
      );
      expect(
        () => LiveInputHistoryItemBranch21.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputHistoryItemBranch21.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch21')),
      );
      expect(
        () => LiveInputHistoryItemBranch21.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputHistoryItemBranch21.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch21')),
      );
      expect(
        () => LiveInputHistoryItemBranch21.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
  });
  group('LiveInputHistoryItemBranch22', () {
    final wire = {
      'error': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'server_label': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'tools': [
        {
          'annotations': <String, dynamic>{},
          'description': 'PRIVATE_LIVE_INPUT_PAYLOAD',
          'input_schema': <String, dynamic>{},
          'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        },
      ],
      'type': 'mcp_list_tools',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputHistoryItemBranch22.fromJson(_clone(wire));
        final peer = LiveInputHistoryItemBranch22.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputHistoryItem.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputHistoryItemBranch22.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputHistoryItemBranch22.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch22')),
      );
      expect(
        () => LiveInputHistoryItemBranch22.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputHistoryItemBranch22.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch22')),
      );
      expect(
        () => LiveInputHistoryItemBranch22.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputHistoryItemBranch22.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch22')),
      );
      expect(
        () => LiveInputHistoryItemBranch22.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
  });
  group('LiveInputHistoryItemBranch23', () {
    final wire = {
      'arguments': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'server_label': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'mcp_approval_request',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputHistoryItemBranch23.fromJson(_clone(wire));
        final peer = LiveInputHistoryItemBranch23.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputHistoryItem.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputHistoryItemBranch23.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputHistoryItemBranch23.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch23')),
      );
      expect(
        () => LiveInputHistoryItemBranch23.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputHistoryItemBranch23.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch23')),
      );
      expect(
        () => LiveInputHistoryItemBranch23.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputHistoryItemBranch23.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch23')),
      );
      expect(
        () => LiveInputHistoryItemBranch23.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
  });
  group('LiveInputHistoryItemBranch24', () {
    final wire = {
      'approval_request_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'approve': false,
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'reason': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'mcp_approval_response',
      'request_id': null,
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputHistoryItemBranch24.fromJson(_clone(wire));
        final peer = LiveInputHistoryItemBranch24.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputHistoryItem.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputHistoryItemBranch24.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputHistoryItemBranch24.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch24')),
      );
      expect(
        () => LiveInputHistoryItemBranch24.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputHistoryItemBranch24.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch24')),
      );
      expect(
        () => LiveInputHistoryItemBranch24.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputHistoryItemBranch24.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch24')),
      );
      expect(
        () => LiveInputHistoryItemBranch24.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
  });
  group('LiveInputHistoryItemBranch25', () {
    final wire = {
      'approval_request_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'arguments': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'error': {
        'code': 0,
        'message': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        'type': 'mcp_protocol_error',
      },
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'output': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'server_label': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'status': 'in_progress',
      'type': 'mcp_call',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputHistoryItemBranch25.fromJson(_clone(wire));
        final peer = LiveInputHistoryItemBranch25.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputHistoryItem.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputHistoryItemBranch25.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputHistoryItemBranch25.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch25')),
      );
      expect(
        () => LiveInputHistoryItemBranch25.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputHistoryItemBranch25.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch25')),
      );
      expect(
        () => LiveInputHistoryItemBranch25.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputHistoryItemBranch25.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch25')),
      );
      expect(
        () => LiveInputHistoryItemBranch25.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
  });
  group('LiveInputHistoryItemBranch26', () {
    final wire = {
      'call_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'caller': {'type': 'direct'},
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'output': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'custom_tool_call_output',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputHistoryItemBranch26.fromJson(_clone(wire));
        final peer = LiveInputHistoryItemBranch26.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputHistoryItem.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputHistoryItemBranch26.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputHistoryItemBranch26.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch26')),
      );
      expect(
        () => LiveInputHistoryItemBranch26.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputHistoryItemBranch26.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch26')),
      );
      expect(
        () => LiveInputHistoryItemBranch26.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputHistoryItemBranch26.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch26')),
      );
      expect(
        () => LiveInputHistoryItemBranch26.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
  });
  group('LiveInputHistoryItemBranch27', () {
    final wire = {
      'async': false,
      'call_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'caller': {'type': 'direct'},
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'input': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'namespace': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'custom_tool_call',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputHistoryItemBranch27.fromJson(_clone(wire));
        final peer = LiveInputHistoryItemBranch27.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputHistoryItem.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputHistoryItemBranch27.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputHistoryItemBranch27.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch27')),
      );
      expect(
        () => LiveInputHistoryItemBranch27.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputHistoryItemBranch27.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch27')),
      );
      expect(
        () => LiveInputHistoryItemBranch27.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputHistoryItemBranch27.fromJson(value),
        throwsA(_safe('LiveInputHistoryItemBranch27')),
      );
      expect(
        () => LiveInputHistoryItemBranch27.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputHistoryItem')),
      );
    });
  });
  group('LiveInputImageBackground', () {
    const wire = 'transparent';
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputImageBackground.fromJson(_clone(wire));
        final peer = LiveInputImageBackground.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputImageBackground.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputImageBackground.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputImageBackground.fromJson(value),
        throwsA(_safe('LiveInputImageBackground')),
      );
      expect(
        () => LiveInputImageBackground.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputImageBackground')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputImageBackground.fromJson(value),
        throwsA(_safe('LiveInputImageBackground')),
      );
      expect(
        () => LiveInputImageBackground.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputImageBackground')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputImageBackground.fromJson(value),
        throwsA(_safe('LiveInputImageBackground')),
      );
      expect(
        () => LiveInputImageBackground.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputImageBackground')),
      );
    });
  });
  group('LiveInputImageDetail', () {
    const wire = 'low';
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputImageDetail.fromJson(_clone(wire));
        final peer = LiveInputImageDetail.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputImageDetail.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputImageDetail.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputImageDetail.fromJson(value),
        throwsA(_safe('LiveInputImageDetail')),
      );
      expect(
        () =>
            LiveInputImageDetail.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputImageDetail')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputImageDetail.fromJson(value),
        throwsA(_safe('LiveInputImageDetail')),
      );
      expect(
        () =>
            LiveInputImageDetail.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputImageDetail')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputImageDetail.fromJson(value),
        throwsA(_safe('LiveInputImageDetail')),
      );
      expect(
        () =>
            LiveInputImageDetail.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputImageDetail')),
      );
    });
  });
  group('LiveInputImageGenActionEnum', () {
    const wire = 'generate';
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputImageGenActionEnum.fromJson(_clone(wire));
        final peer = LiveInputImageGenActionEnum.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputImageGenActionEnum.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputImageGenActionEnum.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputImageGenActionEnum.fromJson(value),
        throwsA(_safe('LiveInputImageGenActionEnum')),
      );
      expect(
        () => LiveInputImageGenActionEnum.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputImageGenActionEnum')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputImageGenActionEnum.fromJson(value),
        throwsA(_safe('LiveInputImageGenActionEnum')),
      );
      expect(
        () => LiveInputImageGenActionEnum.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputImageGenActionEnum')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputImageGenActionEnum.fromJson(value),
        throwsA(_safe('LiveInputImageGenActionEnum')),
      );
      expect(
        () => LiveInputImageGenActionEnum.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputImageGenActionEnum')),
      );
    });
  });
  group('LiveInputImageGenToolCallSizeValueBranch0', () {
    const wire = 'PRIVATE_LIVE_INPUT_PAYLOAD';
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputImageGenToolCallSizeValueBranch0.fromJson(
          _clone(wire),
        );
        final peer = LiveInputImageGenToolCallSizeValueBranch0.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputImageGenToolCallSizeValue.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputImageGenToolCallSizeValueBranch0.fromJson(
        _clone(wire),
      );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputImageGenToolCallSizeValueBranch0.fromJson(value),
        throwsA(_safe('LiveInputImageGenToolCallSizeValueBranch0')),
      );
      expect(
        () => LiveInputImageGenToolCallSizeValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputImageGenToolCallSizeValue')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputImageGenToolCallSizeValueBranch0.fromJson(value),
        throwsA(_safe('LiveInputImageGenToolCallSizeValueBranch0')),
      );
      expect(
        () => LiveInputImageGenToolCallSizeValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputImageGenToolCallSizeValue')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputImageGenToolCallSizeValueBranch0.fromJson(value),
        throwsA(_safe('LiveInputImageGenToolCallSizeValueBranch0')),
      );
      expect(
        () => LiveInputImageGenToolCallSizeValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputImageGenToolCallSizeValue')),
      );
    });
  });
  group('LiveInputImageGenToolCallSizeValueBranch1', () {
    const wire = '1024x1024';
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputImageGenToolCallSizeValueBranch1.fromJson(
          _clone(wire),
        );
        final peer = LiveInputImageGenToolCallSizeValueBranch1.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputImageGenToolCallSizeValue.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputImageGenToolCallSizeValueBranch1.fromJson(
        _clone(wire),
      );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputImageGenToolCallSizeValueBranch1.fromJson(value),
        throwsA(_safe('LiveInputImageGenToolCallSizeValueBranch1')),
      );
      expect(
        () => LiveInputImageGenToolCallSizeValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputImageGenToolCallSizeValue')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputImageGenToolCallSizeValueBranch1.fromJson(value),
        throwsA(_safe('LiveInputImageGenToolCallSizeValueBranch1')),
      );
      expect(
        () => LiveInputImageGenToolCallSizeValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputImageGenToolCallSizeValue')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputImageGenToolCallSizeValueBranch1.fromJson(value),
        throwsA(_safe('LiveInputImageGenToolCallSizeValueBranch1')),
      );
      expect(
        () => LiveInputImageGenToolCallSizeValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputImageGenToolCallSizeValue')),
      );
    });
  });
  group('LiveInputImageGenToolModelValueBranch0', () {
    const wire = 'PRIVATE_LIVE_INPUT_PAYLOAD';
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputImageGenToolModelValueBranch0.fromJson(
          _clone(wire),
        );
        final peer = LiveInputImageGenToolModelValueBranch0.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputImageGenToolModelValue.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputImageGenToolModelValueBranch0.fromJson(
        _clone(wire),
      );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputImageGenToolModelValueBranch0.fromJson(value),
        throwsA(_safe('LiveInputImageGenToolModelValueBranch0')),
      );
      expect(
        () => LiveInputImageGenToolModelValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputImageGenToolModelValue')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputImageGenToolModelValueBranch0.fromJson(value),
        throwsA(_safe('LiveInputImageGenToolModelValueBranch0')),
      );
      expect(
        () => LiveInputImageGenToolModelValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputImageGenToolModelValue')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputImageGenToolModelValueBranch0.fromJson(value),
        throwsA(_safe('LiveInputImageGenToolModelValueBranch0')),
      );
      expect(
        () => LiveInputImageGenToolModelValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputImageGenToolModelValue')),
      );
    });
  });
  group('LiveInputImageGenToolModelValueBranch1', () {
    const wire = 'gpt-image-1';
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputImageGenToolModelValueBranch1.fromJson(
          _clone(wire),
        );
        final peer = LiveInputImageGenToolModelValueBranch1.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputImageGenToolModelValue.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputImageGenToolModelValueBranch1.fromJson(
        _clone(wire),
      );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputImageGenToolModelValueBranch1.fromJson(value),
        throwsA(_safe('LiveInputImageGenToolModelValueBranch1')),
      );
      expect(
        () => LiveInputImageGenToolModelValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputImageGenToolModelValue')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputImageGenToolModelValueBranch1.fromJson(value),
        throwsA(_safe('LiveInputImageGenToolModelValueBranch1')),
      );
      expect(
        () => LiveInputImageGenToolModelValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputImageGenToolModelValue')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputImageGenToolModelValueBranch1.fromJson(value),
        throwsA(_safe('LiveInputImageGenToolModelValueBranch1')),
      );
      expect(
        () => LiveInputImageGenToolModelValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputImageGenToolModelValue')),
      );
    });
  });
  group('LiveInputImageGenToolSizeValueBranch0', () {
    const wire = 'PRIVATE_LIVE_INPUT_PAYLOAD';
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputImageGenToolSizeValueBranch0.fromJson(
          _clone(wire),
        );
        final peer = LiveInputImageGenToolSizeValueBranch0.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputImageGenToolSizeValue.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputImageGenToolSizeValueBranch0.fromJson(
        _clone(wire),
      );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputImageGenToolSizeValueBranch0.fromJson(value),
        throwsA(_safe('LiveInputImageGenToolSizeValueBranch0')),
      );
      expect(
        () => LiveInputImageGenToolSizeValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputImageGenToolSizeValue')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputImageGenToolSizeValueBranch0.fromJson(value),
        throwsA(_safe('LiveInputImageGenToolSizeValueBranch0')),
      );
      expect(
        () => LiveInputImageGenToolSizeValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputImageGenToolSizeValue')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputImageGenToolSizeValueBranch0.fromJson(value),
        throwsA(_safe('LiveInputImageGenToolSizeValueBranch0')),
      );
      expect(
        () => LiveInputImageGenToolSizeValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputImageGenToolSizeValue')),
      );
    });
  });
  group('LiveInputImageGenToolSizeValueBranch1', () {
    const wire = '1024x1024';
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputImageGenToolSizeValueBranch1.fromJson(
          _clone(wire),
        );
        final peer = LiveInputImageGenToolSizeValueBranch1.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputImageGenToolSizeValue.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputImageGenToolSizeValueBranch1.fromJson(
        _clone(wire),
      );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputImageGenToolSizeValueBranch1.fromJson(value),
        throwsA(_safe('LiveInputImageGenToolSizeValueBranch1')),
      );
      expect(
        () => LiveInputImageGenToolSizeValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputImageGenToolSizeValue')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputImageGenToolSizeValueBranch1.fromJson(value),
        throwsA(_safe('LiveInputImageGenToolSizeValueBranch1')),
      );
      expect(
        () => LiveInputImageGenToolSizeValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputImageGenToolSizeValue')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputImageGenToolSizeValueBranch1.fromJson(value),
        throwsA(_safe('LiveInputImageGenToolSizeValueBranch1')),
      );
      expect(
        () => LiveInputImageGenToolSizeValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputImageGenToolSizeValue')),
      );
    });
  });
  group('LiveInputImageOutputFormat', () {
    const wire = 'png';
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputImageOutputFormat.fromJson(_clone(wire));
        final peer = LiveInputImageOutputFormat.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputImageOutputFormat.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputImageOutputFormat.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputImageOutputFormat.fromJson(value),
        throwsA(_safe('LiveInputImageOutputFormat')),
      );
      expect(
        () => LiveInputImageOutputFormat.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputImageOutputFormat')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputImageOutputFormat.fromJson(value),
        throwsA(_safe('LiveInputImageOutputFormat')),
      );
      expect(
        () => LiveInputImageOutputFormat.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputImageOutputFormat')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputImageOutputFormat.fromJson(value),
        throwsA(_safe('LiveInputImageOutputFormat')),
      );
      expect(
        () => LiveInputImageOutputFormat.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputImageOutputFormat')),
      );
    });
  });
  group('LiveInputMCPToolAllowedToolsValueBranch0', () {
    final wire = ['PRIVATE_LIVE_INPUT_PAYLOAD'];
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputMCPToolAllowedToolsValueBranch0.fromJson(
          _clone(wire),
        );
        final peer = LiveInputMCPToolAllowedToolsValueBranch0.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputMCPToolAllowedToolsValue.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputMCPToolAllowedToolsValueBranch0.fromJson(
        _clone(wire),
      );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputMCPToolAllowedToolsValueBranch0.fromJson(value),
        throwsA(_safe('LiveInputMCPToolAllowedToolsValueBranch0')),
      );
      expect(
        () => LiveInputMCPToolAllowedToolsValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputMCPToolAllowedToolsValue')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputMCPToolAllowedToolsValueBranch0.fromJson(value),
        throwsA(_safe('LiveInputMCPToolAllowedToolsValueBranch0')),
      );
      expect(
        () => LiveInputMCPToolAllowedToolsValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputMCPToolAllowedToolsValue')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputMCPToolAllowedToolsValueBranch0.fromJson(value),
        throwsA(_safe('LiveInputMCPToolAllowedToolsValueBranch0')),
      );
      expect(
        () => LiveInputMCPToolAllowedToolsValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputMCPToolAllowedToolsValue')),
      );
    });
  });
  group('LiveInputMCPToolAllowedToolsValueBranch1', () {
    final wire = {
      'read_only': false,
      'tool_names': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputMCPToolAllowedToolsValueBranch1.fromJson(
          _clone(wire),
        );
        final peer = LiveInputMCPToolAllowedToolsValueBranch1.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputMCPToolAllowedToolsValue.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputMCPToolAllowedToolsValueBranch1.fromJson(
        _clone(wire),
      );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputMCPToolAllowedToolsValueBranch1.fromJson(value),
        throwsA(_safe('LiveInputMCPToolAllowedToolsValueBranch1')),
      );
      expect(
        () => LiveInputMCPToolAllowedToolsValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputMCPToolAllowedToolsValue')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputMCPToolAllowedToolsValueBranch1.fromJson(value),
        throwsA(_safe('LiveInputMCPToolAllowedToolsValueBranch1')),
      );
      expect(
        () => LiveInputMCPToolAllowedToolsValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputMCPToolAllowedToolsValue')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputMCPToolAllowedToolsValueBranch1.fromJson(value),
        throwsA(_safe('LiveInputMCPToolAllowedToolsValueBranch1')),
      );
      expect(
        () => LiveInputMCPToolAllowedToolsValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputMCPToolAllowedToolsValue')),
      );
    });
  });
  group('LiveInputMCPToolCallErrorBranch0', () {
    final wire = {
      'code': 0,
      'message': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'mcp_protocol_error',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputMCPToolCallErrorBranch0.fromJson(_clone(wire));
        final peer = LiveInputMCPToolCallErrorBranch0.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputMCPToolCallError.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputMCPToolCallErrorBranch0.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputMCPToolCallErrorBranch0.fromJson(value),
        throwsA(_safe('LiveInputMCPToolCallErrorBranch0')),
      );
      expect(
        () => LiveInputMCPToolCallErrorBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputMCPToolCallError')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputMCPToolCallErrorBranch0.fromJson(value),
        throwsA(_safe('LiveInputMCPToolCallErrorBranch0')),
      );
      expect(
        () => LiveInputMCPToolCallErrorBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputMCPToolCallError')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputMCPToolCallErrorBranch0.fromJson(value),
        throwsA(_safe('LiveInputMCPToolCallErrorBranch0')),
      );
      expect(
        () => LiveInputMCPToolCallErrorBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputMCPToolCallError')),
      );
    });
  });
  group('LiveInputMCPToolCallErrorBranch1', () {
    final wire = {'content': null, 'type': 'mcp_tool_execution_error'};
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputMCPToolCallErrorBranch1.fromJson(_clone(wire));
        final peer = LiveInputMCPToolCallErrorBranch1.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputMCPToolCallError.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputMCPToolCallErrorBranch1.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputMCPToolCallErrorBranch1.fromJson(value),
        throwsA(_safe('LiveInputMCPToolCallErrorBranch1')),
      );
      expect(
        () => LiveInputMCPToolCallErrorBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputMCPToolCallError')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputMCPToolCallErrorBranch1.fromJson(value),
        throwsA(_safe('LiveInputMCPToolCallErrorBranch1')),
      );
      expect(
        () => LiveInputMCPToolCallErrorBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputMCPToolCallError')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputMCPToolCallErrorBranch1.fromJson(value),
        throwsA(_safe('LiveInputMCPToolCallErrorBranch1')),
      );
      expect(
        () => LiveInputMCPToolCallErrorBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputMCPToolCallError')),
      );
    });
  });
  group('LiveInputMCPToolCallErrorBranch2', () {
    final wire = {
      'code': 0,
      'message': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'http_error',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputMCPToolCallErrorBranch2.fromJson(_clone(wire));
        final peer = LiveInputMCPToolCallErrorBranch2.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputMCPToolCallError.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputMCPToolCallErrorBranch2.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputMCPToolCallErrorBranch2.fromJson(value),
        throwsA(_safe('LiveInputMCPToolCallErrorBranch2')),
      );
      expect(
        () => LiveInputMCPToolCallErrorBranch2.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputMCPToolCallError')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputMCPToolCallErrorBranch2.fromJson(value),
        throwsA(_safe('LiveInputMCPToolCallErrorBranch2')),
      );
      expect(
        () => LiveInputMCPToolCallErrorBranch2.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputMCPToolCallError')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputMCPToolCallErrorBranch2.fromJson(value),
        throwsA(_safe('LiveInputMCPToolCallErrorBranch2')),
      );
      expect(
        () => LiveInputMCPToolCallErrorBranch2.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputMCPToolCallError')),
      );
    });
  });
  group('LiveInputMCPToolCallStatus', () {
    const wire = 'in_progress';
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputMCPToolCallStatus.fromJson(_clone(wire));
        final peer = LiveInputMCPToolCallStatus.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputMCPToolCallStatus.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputMCPToolCallStatus.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputMCPToolCallStatus.fromJson(value),
        throwsA(_safe('LiveInputMCPToolCallStatus')),
      );
      expect(
        () => LiveInputMCPToolCallStatus.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputMCPToolCallStatus')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputMCPToolCallStatus.fromJson(value),
        throwsA(_safe('LiveInputMCPToolCallStatus')),
      );
      expect(
        () => LiveInputMCPToolCallStatus.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputMCPToolCallStatus')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputMCPToolCallStatus.fromJson(value),
        throwsA(_safe('LiveInputMCPToolCallStatus')),
      );
      expect(
        () => LiveInputMCPToolCallStatus.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputMCPToolCallStatus')),
      );
    });
  });
  group('LiveInputMCPToolRequireApprovalValueBranch0', () {
    final wire = {
      'always': {
        'read_only': false,
        'tool_names': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
      },
      'never': {
        'read_only': false,
        'tool_names': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
      },
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputMCPToolRequireApprovalValueBranch0.fromJson(
          _clone(wire),
        );
        final peer = LiveInputMCPToolRequireApprovalValueBranch0.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputMCPToolRequireApprovalValue.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputMCPToolRequireApprovalValueBranch0.fromJson(
        _clone(wire),
      );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputMCPToolRequireApprovalValueBranch0.fromJson(value),
        throwsA(_safe('LiveInputMCPToolRequireApprovalValueBranch0')),
      );
      expect(
        () => LiveInputMCPToolRequireApprovalValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputMCPToolRequireApprovalValue')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputMCPToolRequireApprovalValueBranch0.fromJson(value),
        throwsA(_safe('LiveInputMCPToolRequireApprovalValueBranch0')),
      );
      expect(
        () => LiveInputMCPToolRequireApprovalValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputMCPToolRequireApprovalValue')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputMCPToolRequireApprovalValueBranch0.fromJson(value),
        throwsA(_safe('LiveInputMCPToolRequireApprovalValueBranch0')),
      );
      expect(
        () => LiveInputMCPToolRequireApprovalValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputMCPToolRequireApprovalValue')),
      );
    });
  });
  group('LiveInputMCPToolRequireApprovalValueBranch1', () {
    const wire = 'always';
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputMCPToolRequireApprovalValueBranch1.fromJson(
          _clone(wire),
        );
        final peer = LiveInputMCPToolRequireApprovalValueBranch1.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputMCPToolRequireApprovalValue.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputMCPToolRequireApprovalValueBranch1.fromJson(
        _clone(wire),
      );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputMCPToolRequireApprovalValueBranch1.fromJson(value),
        throwsA(_safe('LiveInputMCPToolRequireApprovalValueBranch1')),
      );
      expect(
        () => LiveInputMCPToolRequireApprovalValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputMCPToolRequireApprovalValue')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputMCPToolRequireApprovalValueBranch1.fromJson(value),
        throwsA(_safe('LiveInputMCPToolRequireApprovalValueBranch1')),
      );
      expect(
        () => LiveInputMCPToolRequireApprovalValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputMCPToolRequireApprovalValue')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputMCPToolRequireApprovalValueBranch1.fromJson(value),
        throwsA(_safe('LiveInputMCPToolRequireApprovalValueBranch1')),
      );
      expect(
        () => LiveInputMCPToolRequireApprovalValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputMCPToolRequireApprovalValue')),
      );
    });
  });
  group('LiveInputMessageContentList', () {
    final wire = [
      {
        'prompt_cache_breakpoint': {'mode': 'explicit'},
        'text': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        'type': 'input_text',
      },
    ];
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputMessageContentList.fromJson(_clone(wire));
        final peer = LiveInputMessageContentList.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputMessageContentList.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputMessageContentList.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputMessageContentList.fromJson(value),
        throwsA(_safe('LiveInputMessageContentList')),
      );
      expect(
        () => LiveInputMessageContentList.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputMessageContentList')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputMessageContentList.fromJson(value),
        throwsA(_safe('LiveInputMessageContentList')),
      );
      expect(
        () => LiveInputMessageContentList.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputMessageContentList')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputMessageContentList.fromJson(value),
        throwsA(_safe('LiveInputMessageContentList')),
      );
      expect(
        () => LiveInputMessageContentList.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputMessageContentList')),
      );
    });
  });
  group('LiveInputMessagePhase', () {
    const wire = 'commentary';
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputMessagePhase.fromJson(_clone(wire));
        final peer = LiveInputMessagePhase.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputMessagePhase.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputMessagePhase.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputMessagePhase.fromJson(value),
        throwsA(_safe('LiveInputMessagePhase')),
      );
      expect(
        () =>
            LiveInputMessagePhase.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputMessagePhase')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputMessagePhase.fromJson(value),
        throwsA(_safe('LiveInputMessagePhase')),
      );
      expect(
        () =>
            LiveInputMessagePhase.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputMessagePhase')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputMessagePhase.fromJson(value),
        throwsA(_safe('LiveInputMessagePhase')),
      );
      expect(
        () =>
            LiveInputMessagePhase.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputMessagePhase')),
      );
    });
  });
  group('LiveInputNamespaceToolParamToolsItemValueBranch0', () {
    final wire = {
      'allowed_callers': ['direct'],
      'async': false,
      'defer_loading': false,
      'description': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'output_schema': <String, dynamic>{},
      'parameters': <String, dynamic>{},
      'strict': false,
      'type': 'function',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputNamespaceToolParamToolsItemValueBranch0.fromJson(
          _clone(wire),
        );
        final peer = LiveInputNamespaceToolParamToolsItemValueBranch0.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputNamespaceToolParamToolsItemValue.fromJson(
            _clone(wire),
          ).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputNamespaceToolParamToolsItemValueBranch0.fromJson(
        _clone(wire),
      );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputNamespaceToolParamToolsItemValueBranch0.fromJson(value),
        throwsA(_safe('LiveInputNamespaceToolParamToolsItemValueBranch0')),
      );
      expect(
        () => LiveInputNamespaceToolParamToolsItemValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputNamespaceToolParamToolsItemValue')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputNamespaceToolParamToolsItemValueBranch0.fromJson(value),
        throwsA(_safe('LiveInputNamespaceToolParamToolsItemValueBranch0')),
      );
      expect(
        () => LiveInputNamespaceToolParamToolsItemValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputNamespaceToolParamToolsItemValue')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputNamespaceToolParamToolsItemValueBranch0.fromJson(value),
        throwsA(_safe('LiveInputNamespaceToolParamToolsItemValueBranch0')),
      );
      expect(
        () => LiveInputNamespaceToolParamToolsItemValueBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputNamespaceToolParamToolsItemValue')),
      );
    });
  });
  group('LiveInputNamespaceToolParamToolsItemValueBranch1', () {
    final wire = {
      'allowed_callers': ['direct'],
      'async': false,
      'defer_loading': false,
      'description': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'format': {'type': 'text'},
      'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'custom',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputNamespaceToolParamToolsItemValueBranch1.fromJson(
          _clone(wire),
        );
        final peer = LiveInputNamespaceToolParamToolsItemValueBranch1.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputNamespaceToolParamToolsItemValue.fromJson(
            _clone(wire),
          ).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputNamespaceToolParamToolsItemValueBranch1.fromJson(
        _clone(wire),
      );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputNamespaceToolParamToolsItemValueBranch1.fromJson(value),
        throwsA(_safe('LiveInputNamespaceToolParamToolsItemValueBranch1')),
      );
      expect(
        () => LiveInputNamespaceToolParamToolsItemValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputNamespaceToolParamToolsItemValue')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputNamespaceToolParamToolsItemValueBranch1.fromJson(value),
        throwsA(_safe('LiveInputNamespaceToolParamToolsItemValueBranch1')),
      );
      expect(
        () => LiveInputNamespaceToolParamToolsItemValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputNamespaceToolParamToolsItemValue')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputNamespaceToolParamToolsItemValueBranch1.fromJson(value),
        throwsA(_safe('LiveInputNamespaceToolParamToolsItemValueBranch1')),
      );
      expect(
        () => LiveInputNamespaceToolParamToolsItemValueBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputNamespaceToolParamToolsItemValue')),
      );
    });
  });
  group('LiveInputOutputMessageContentBranch0', () {
    final wire = {
      'annotations': [
        {
          'file_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
          'filename': 'PRIVATE_LIVE_INPUT_PAYLOAD',
          'index': 0,
          'type': 'file_citation',
        },
      ],
      'logprobs': [
        {
          'bytes': [0],
          'logprob': 0,
          'token': 'PRIVATE_LIVE_INPUT_PAYLOAD',
          'top_logprobs': [
            {
              'bytes': [0],
              'logprob': 0,
              'token': 'PRIVATE_LIVE_INPUT_PAYLOAD',
            },
          ],
        },
      ],
      'text': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'output_text',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputOutputMessageContentBranch0.fromJson(
          _clone(wire),
        );
        final peer = LiveInputOutputMessageContentBranch0.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputOutputMessageContent.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputOutputMessageContentBranch0.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputOutputMessageContentBranch0.fromJson(value),
        throwsA(_safe('LiveInputOutputMessageContentBranch0')),
      );
      expect(
        () => LiveInputOutputMessageContentBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputOutputMessageContent')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputOutputMessageContentBranch0.fromJson(value),
        throwsA(_safe('LiveInputOutputMessageContentBranch0')),
      );
      expect(
        () => LiveInputOutputMessageContentBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputOutputMessageContent')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputOutputMessageContentBranch0.fromJson(value),
        throwsA(_safe('LiveInputOutputMessageContentBranch0')),
      );
      expect(
        () => LiveInputOutputMessageContentBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputOutputMessageContent')),
      );
    });
  });
  group('LiveInputOutputMessageContentBranch1', () {
    final wire = {'refusal': 'PRIVATE_LIVE_INPUT_PAYLOAD', 'type': 'refusal'};
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputOutputMessageContentBranch1.fromJson(
          _clone(wire),
        );
        final peer = LiveInputOutputMessageContentBranch1.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputOutputMessageContent.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputOutputMessageContentBranch1.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputOutputMessageContentBranch1.fromJson(value),
        throwsA(_safe('LiveInputOutputMessageContentBranch1')),
      );
      expect(
        () => LiveInputOutputMessageContentBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputOutputMessageContent')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputOutputMessageContentBranch1.fromJson(value),
        throwsA(_safe('LiveInputOutputMessageContentBranch1')),
      );
      expect(
        () => LiveInputOutputMessageContentBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputOutputMessageContent')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputOutputMessageContentBranch1.fromJson(value),
        throwsA(_safe('LiveInputOutputMessageContentBranch1')),
      );
      expect(
        () => LiveInputOutputMessageContentBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputOutputMessageContent')),
      );
    });
  });
  group('LiveInputProgramOutputItemStatus', () {
    const wire = 'completed';
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputProgramOutputItemStatus.fromJson(_clone(wire));
        final peer = LiveInputProgramOutputItemStatus.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputProgramOutputItemStatus.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputProgramOutputItemStatus.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputProgramOutputItemStatus.fromJson(value),
        throwsA(_safe('LiveInputProgramOutputItemStatus')),
      );
      expect(
        () => LiveInputProgramOutputItemStatus.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputProgramOutputItemStatus')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputProgramOutputItemStatus.fromJson(value),
        throwsA(_safe('LiveInputProgramOutputItemStatus')),
      );
      expect(
        () => LiveInputProgramOutputItemStatus.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputProgramOutputItemStatus')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputProgramOutputItemStatus.fromJson(value),
        throwsA(_safe('LiveInputProgramOutputItemStatus')),
      );
      expect(
        () => LiveInputProgramOutputItemStatus.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputProgramOutputItemStatus')),
      );
    });
  });
  group('LiveInputRankerVersionType', () {
    const wire = 'auto';
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputRankerVersionType.fromJson(_clone(wire));
        final peer = LiveInputRankerVersionType.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputRankerVersionType.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputRankerVersionType.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputRankerVersionType.fromJson(value),
        throwsA(_safe('LiveInputRankerVersionType')),
      );
      expect(
        () => LiveInputRankerVersionType.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputRankerVersionType')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputRankerVersionType.fromJson(value),
        throwsA(_safe('LiveInputRankerVersionType')),
      );
      expect(
        () => LiveInputRankerVersionType.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputRankerVersionType')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputRankerVersionType.fromJson(value),
        throwsA(_safe('LiveInputRankerVersionType')),
      );
      expect(
        () => LiveInputRankerVersionType.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputRankerVersionType')),
      );
    });
  });
  group('LiveInputReasoningEffortBranch0', () {
    const wire = 'none';
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputReasoningEffortBranch0.fromJson(_clone(wire));
        final peer = LiveInputReasoningEffortBranch0.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputReasoningEffort.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputReasoningEffortBranch0.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputReasoningEffortBranch0.fromJson(value),
        throwsA(_safe('LiveInputReasoningEffortBranch0')),
      );
      expect(
        () => LiveInputReasoningEffortBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputReasoningEffort')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputReasoningEffortBranch0.fromJson(value),
        throwsA(_safe('LiveInputReasoningEffortBranch0')),
      );
      expect(
        () => LiveInputReasoningEffortBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputReasoningEffort')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputReasoningEffortBranch0.fromJson(value),
        throwsA(_safe('LiveInputReasoningEffortBranch0')),
      );
      expect(
        () => LiveInputReasoningEffortBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputReasoningEffort')),
      );
    });
  });
  group('LiveInputReasoningEffortBranch1', () {
    const wire = null;
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputReasoningEffortBranch1.fromJson(_clone(wire));
        final peer = LiveInputReasoningEffortBranch1.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputReasoningEffort.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputReasoningEffortBranch1.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputReasoningEffortBranch1.fromJson(value),
        throwsA(_safe('LiveInputReasoningEffortBranch1')),
      );
      expect(
        () => LiveInputReasoningEffortBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputReasoningEffort')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputReasoningEffortBranch1.fromJson(value),
        throwsA(_safe('LiveInputReasoningEffortBranch1')),
      );
      expect(
        () => LiveInputReasoningEffortBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputReasoningEffort')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputReasoningEffortBranch1.fromJson(value),
        throwsA(_safe('LiveInputReasoningEffortBranch1')),
      );
      expect(
        () => LiveInputReasoningEffortBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputReasoningEffort')),
      );
    });
  });
  group('LiveInputSearchContentType', () {
    const wire = 'text';
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputSearchContentType.fromJson(_clone(wire));
        final peer = LiveInputSearchContentType.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputSearchContentType.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputSearchContentType.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputSearchContentType.fromJson(value),
        throwsA(_safe('LiveInputSearchContentType')),
      );
      expect(
        () => LiveInputSearchContentType.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputSearchContentType')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputSearchContentType.fromJson(value),
        throwsA(_safe('LiveInputSearchContentType')),
      );
      expect(
        () => LiveInputSearchContentType.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputSearchContentType')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputSearchContentType.fromJson(value),
        throwsA(_safe('LiveInputSearchContentType')),
      );
      expect(
        () => LiveInputSearchContentType.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputSearchContentType')),
      );
    });
  });
  group('LiveInputSearchContextSize', () {
    const wire = 'low';
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputSearchContextSize.fromJson(_clone(wire));
        final peer = LiveInputSearchContextSize.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputSearchContextSize.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputSearchContextSize.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputSearchContextSize.fromJson(value),
        throwsA(_safe('LiveInputSearchContextSize')),
      );
      expect(
        () => LiveInputSearchContextSize.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputSearchContextSize')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputSearchContextSize.fromJson(value),
        throwsA(_safe('LiveInputSearchContextSize')),
      );
      expect(
        () => LiveInputSearchContextSize.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputSearchContextSize')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputSearchContextSize.fromJson(value),
        throwsA(_safe('LiveInputSearchContextSize')),
      );
      expect(
        () => LiveInputSearchContextSize.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputSearchContextSize')),
      );
    });
  });
  group('LiveInputToolBranch0', () {
    final wire = {
      'allowed_callers': ['direct'],
      'async': false,
      'defer_loading': false,
      'description': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'output_schema': <String, dynamic>{},
      'parameters': <String, dynamic>{},
      'strict': false,
      'type': 'function',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputToolBranch0.fromJson(_clone(wire));
        final peer = LiveInputToolBranch0.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputTool.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputToolBranch0.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputToolBranch0.fromJson(value),
        throwsA(_safe('LiveInputToolBranch0')),
      );
      expect(
        () =>
            LiveInputToolBranch0.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputToolBranch0.fromJson(value),
        throwsA(_safe('LiveInputToolBranch0')),
      );
      expect(
        () =>
            LiveInputToolBranch0.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputToolBranch0.fromJson(value),
        throwsA(_safe('LiveInputToolBranch0')),
      );
      expect(
        () =>
            LiveInputToolBranch0.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
  });
  group('LiveInputToolBranch1', () {
    final wire = {
      'filters': {
        'key': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        'type': 'eq',
        'value': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      },
      'max_num_results': 0,
      'ranking_options': {
        'hybrid_search': {'embedding_weight': 0, 'text_weight': 0},
        'ranker': 'auto',
        'score_threshold': 0,
      },
      'type': 'file_search',
      'vector_store_ids': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputToolBranch1.fromJson(_clone(wire));
        final peer = LiveInputToolBranch1.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputTool.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputToolBranch1.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputToolBranch1.fromJson(value),
        throwsA(_safe('LiveInputToolBranch1')),
      );
      expect(
        () =>
            LiveInputToolBranch1.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputToolBranch1.fromJson(value),
        throwsA(_safe('LiveInputToolBranch1')),
      );
      expect(
        () =>
            LiveInputToolBranch1.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputToolBranch1.fromJson(value),
        throwsA(_safe('LiveInputToolBranch1')),
      );
      expect(
        () =>
            LiveInputToolBranch1.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
  });
  group('LiveInputToolBranch2', () {
    final wire = {'type': 'computer'};
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputToolBranch2.fromJson(_clone(wire));
        final peer = LiveInputToolBranch2.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputTool.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputToolBranch2.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputToolBranch2.fromJson(value),
        throwsA(_safe('LiveInputToolBranch2')),
      );
      expect(
        () =>
            LiveInputToolBranch2.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputToolBranch2.fromJson(value),
        throwsA(_safe('LiveInputToolBranch2')),
      );
      expect(
        () =>
            LiveInputToolBranch2.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputToolBranch2.fromJson(value),
        throwsA(_safe('LiveInputToolBranch2')),
      );
      expect(
        () =>
            LiveInputToolBranch2.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
  });
  group('LiveInputToolBranch3', () {
    final wire = {
      'display_height': 0,
      'display_width': 0,
      'environment': 'windows',
      'type': 'computer_use_preview',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputToolBranch3.fromJson(_clone(wire));
        final peer = LiveInputToolBranch3.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputTool.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputToolBranch3.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputToolBranch3.fromJson(value),
        throwsA(_safe('LiveInputToolBranch3')),
      );
      expect(
        () =>
            LiveInputToolBranch3.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputToolBranch3.fromJson(value),
        throwsA(_safe('LiveInputToolBranch3')),
      );
      expect(
        () =>
            LiveInputToolBranch3.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputToolBranch3.fromJson(value),
        throwsA(_safe('LiveInputToolBranch3')),
      );
      expect(
        () =>
            LiveInputToolBranch3.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
  });
  group('LiveInputToolBranch4', () {
    final wire = {
      'external_web_access': false,
      'filters': {
        'allowed_domains': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
      },
      'search_context_size': 'low',
      'type': 'web_search',
      'user_location': {
        'city': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        'country': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        'region': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        'timezone': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        'type': 'approximate',
      },
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputToolBranch4.fromJson(_clone(wire));
        final peer = LiveInputToolBranch4.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputTool.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputToolBranch4.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputToolBranch4.fromJson(value),
        throwsA(_safe('LiveInputToolBranch4')),
      );
      expect(
        () =>
            LiveInputToolBranch4.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputToolBranch4.fromJson(value),
        throwsA(_safe('LiveInputToolBranch4')),
      );
      expect(
        () =>
            LiveInputToolBranch4.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputToolBranch4.fromJson(value),
        throwsA(_safe('LiveInputToolBranch4')),
      );
      expect(
        () =>
            LiveInputToolBranch4.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
  });
  group('LiveInputToolBranch5', () {
    final wire = {
      'allowed_callers': ['direct'],
      'allowed_tools': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
      'authorization': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'connector_id': 'connector_dropbox',
      'defer_loading': false,
      'headers': <String, dynamic>{},
      'require_approval': {
        'always': {
          'read_only': false,
          'tool_names': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
        },
        'never': {
          'read_only': false,
          'tool_names': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
        },
      },
      'server_description': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'server_label': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'server_url': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'tunnel_id': 'tunnel_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      'type': 'mcp',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputToolBranch5.fromJson(_clone(wire));
        final peer = LiveInputToolBranch5.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputTool.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputToolBranch5.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputToolBranch5.fromJson(value),
        throwsA(_safe('LiveInputToolBranch5')),
      );
      expect(
        () =>
            LiveInputToolBranch5.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputToolBranch5.fromJson(value),
        throwsA(_safe('LiveInputToolBranch5')),
      );
      expect(
        () =>
            LiveInputToolBranch5.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputToolBranch5.fromJson(value),
        throwsA(_safe('LiveInputToolBranch5')),
      );
      expect(
        () =>
            LiveInputToolBranch5.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
  });
  group('LiveInputToolBranch6', () {
    final wire = {
      'allowed_callers': ['direct'],
      'container': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'code_interpreter',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputToolBranch6.fromJson(_clone(wire));
        final peer = LiveInputToolBranch6.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputTool.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputToolBranch6.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputToolBranch6.fromJson(value),
        throwsA(_safe('LiveInputToolBranch6')),
      );
      expect(
        () =>
            LiveInputToolBranch6.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputToolBranch6.fromJson(value),
        throwsA(_safe('LiveInputToolBranch6')),
      );
      expect(
        () =>
            LiveInputToolBranch6.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputToolBranch6.fromJson(value),
        throwsA(_safe('LiveInputToolBranch6')),
      );
      expect(
        () =>
            LiveInputToolBranch6.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
  });
  group('LiveInputToolBranch7', () {
    final wire = {'type': 'programmatic_tool_calling'};
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputToolBranch7.fromJson(_clone(wire));
        final peer = LiveInputToolBranch7.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputTool.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputToolBranch7.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputToolBranch7.fromJson(value),
        throwsA(_safe('LiveInputToolBranch7')),
      );
      expect(
        () =>
            LiveInputToolBranch7.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputToolBranch7.fromJson(value),
        throwsA(_safe('LiveInputToolBranch7')),
      );
      expect(
        () =>
            LiveInputToolBranch7.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputToolBranch7.fromJson(value),
        throwsA(_safe('LiveInputToolBranch7')),
      );
      expect(
        () =>
            LiveInputToolBranch7.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
  });
  group('LiveInputToolBranch8', () {
    final wire = {
      'action': 'generate',
      'background': 'transparent',
      'input_fidelity': 'high',
      'input_image_mask': {
        'file_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        'image_url': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      },
      'model': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'moderation': 'auto',
      'output_compression': 0,
      'output_format': 'png',
      'partial_images': 0,
      'quality': 'low',
      'size': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'image_generation',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputToolBranch8.fromJson(_clone(wire));
        final peer = LiveInputToolBranch8.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputTool.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputToolBranch8.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputToolBranch8.fromJson(value),
        throwsA(_safe('LiveInputToolBranch8')),
      );
      expect(
        () =>
            LiveInputToolBranch8.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputToolBranch8.fromJson(value),
        throwsA(_safe('LiveInputToolBranch8')),
      );
      expect(
        () =>
            LiveInputToolBranch8.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputToolBranch8.fromJson(value),
        throwsA(_safe('LiveInputToolBranch8')),
      );
      expect(
        () =>
            LiveInputToolBranch8.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
  });
  group('LiveInputToolBranch9', () {
    final wire = {'type': 'local_shell'};
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputToolBranch9.fromJson(_clone(wire));
        final peer = LiveInputToolBranch9.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputTool.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputToolBranch9.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputToolBranch9.fromJson(value),
        throwsA(_safe('LiveInputToolBranch9')),
      );
      expect(
        () =>
            LiveInputToolBranch9.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputToolBranch9.fromJson(value),
        throwsA(_safe('LiveInputToolBranch9')),
      );
      expect(
        () =>
            LiveInputToolBranch9.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputToolBranch9.fromJson(value),
        throwsA(_safe('LiveInputToolBranch9')),
      );
      expect(
        () =>
            LiveInputToolBranch9.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
  });
  group('LiveInputToolBranch10', () {
    final wire = {
      'allowed_callers': ['direct'],
      'environment': {
        'file_ids': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
        'memory_limit': '1g',
        'network_policy': {'type': 'disabled'},
        'skills': [
          {
            'skill_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
            'type': 'skill_reference',
            'version': 'PRIVATE_LIVE_INPUT_PAYLOAD',
          },
        ],
        'type': 'container_auto',
      },
      'type': 'shell',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputToolBranch10.fromJson(_clone(wire));
        final peer = LiveInputToolBranch10.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputTool.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputToolBranch10.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputToolBranch10.fromJson(value),
        throwsA(_safe('LiveInputToolBranch10')),
      );
      expect(
        () =>
            LiveInputToolBranch10.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputToolBranch10.fromJson(value),
        throwsA(_safe('LiveInputToolBranch10')),
      );
      expect(
        () =>
            LiveInputToolBranch10.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputToolBranch10.fromJson(value),
        throwsA(_safe('LiveInputToolBranch10')),
      );
      expect(
        () =>
            LiveInputToolBranch10.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
  });
  group('LiveInputToolBranch11', () {
    final wire = {
      'allowed_callers': ['direct'],
      'async': false,
      'defer_loading': false,
      'description': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'format': {'type': 'text'},
      'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'custom',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputToolBranch11.fromJson(_clone(wire));
        final peer = LiveInputToolBranch11.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputTool.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputToolBranch11.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputToolBranch11.fromJson(value),
        throwsA(_safe('LiveInputToolBranch11')),
      );
      expect(
        () =>
            LiveInputToolBranch11.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputToolBranch11.fromJson(value),
        throwsA(_safe('LiveInputToolBranch11')),
      );
      expect(
        () =>
            LiveInputToolBranch11.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputToolBranch11.fromJson(value),
        throwsA(_safe('LiveInputToolBranch11')),
      );
      expect(
        () =>
            LiveInputToolBranch11.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
  });
  group('LiveInputToolBranch12', () {
    final wire = {
      'description': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'tools': [
        {
          'allowed_callers': ['direct'],
          'async': false,
          'defer_loading': false,
          'description': 'PRIVATE_LIVE_INPUT_PAYLOAD',
          'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
          'output_schema': <String, dynamic>{},
          'parameters': <String, dynamic>{},
          'strict': false,
          'type': 'function',
        },
      ],
      'type': 'namespace',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputToolBranch12.fromJson(_clone(wire));
        final peer = LiveInputToolBranch12.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputTool.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputToolBranch12.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputToolBranch12.fromJson(value),
        throwsA(_safe('LiveInputToolBranch12')),
      );
      expect(
        () =>
            LiveInputToolBranch12.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputToolBranch12.fromJson(value),
        throwsA(_safe('LiveInputToolBranch12')),
      );
      expect(
        () =>
            LiveInputToolBranch12.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputToolBranch12.fromJson(value),
        throwsA(_safe('LiveInputToolBranch12')),
      );
      expect(
        () =>
            LiveInputToolBranch12.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
  });
  group('LiveInputToolBranch13', () {
    final wire = {
      'description': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'execution': 'server',
      'parameters': <String, dynamic>{},
      'type': 'tool_search',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputToolBranch13.fromJson(_clone(wire));
        final peer = LiveInputToolBranch13.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputTool.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputToolBranch13.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputToolBranch13.fromJson(value),
        throwsA(_safe('LiveInputToolBranch13')),
      );
      expect(
        () =>
            LiveInputToolBranch13.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputToolBranch13.fromJson(value),
        throwsA(_safe('LiveInputToolBranch13')),
      );
      expect(
        () =>
            LiveInputToolBranch13.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputToolBranch13.fromJson(value),
        throwsA(_safe('LiveInputToolBranch13')),
      );
      expect(
        () =>
            LiveInputToolBranch13.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
  });
  group('LiveInputToolBranch14', () {
    final wire = {
      'search_content_types': ['text'],
      'search_context_size': 'low',
      'type': 'web_search_preview',
      'user_location': {
        'city': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        'country': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        'region': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        'timezone': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        'type': 'approximate',
      },
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputToolBranch14.fromJson(_clone(wire));
        final peer = LiveInputToolBranch14.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputTool.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputToolBranch14.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputToolBranch14.fromJson(value),
        throwsA(_safe('LiveInputToolBranch14')),
      );
      expect(
        () =>
            LiveInputToolBranch14.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputToolBranch14.fromJson(value),
        throwsA(_safe('LiveInputToolBranch14')),
      );
      expect(
        () =>
            LiveInputToolBranch14.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputToolBranch14.fromJson(value),
        throwsA(_safe('LiveInputToolBranch14')),
      );
      expect(
        () =>
            LiveInputToolBranch14.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
  });
  group('LiveInputToolBranch15', () {
    final wire = {
      'allowed_callers': ['direct'],
      'type': 'apply_patch',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputToolBranch15.fromJson(_clone(wire));
        final peer = LiveInputToolBranch15.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputTool.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputToolBranch15.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputToolBranch15.fromJson(value),
        throwsA(_safe('LiveInputToolBranch15')),
      );
      expect(
        () =>
            LiveInputToolBranch15.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputToolBranch15.fromJson(value),
        throwsA(_safe('LiveInputToolBranch15')),
      );
      expect(
        () =>
            LiveInputToolBranch15.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputToolBranch15.fromJson(value),
        throwsA(_safe('LiveInputToolBranch15')),
      );
      expect(
        () =>
            LiveInputToolBranch15.fromJson(_clone(wire)).copyWith(value: value),
        throwsA(_safe('LiveInputTool')),
      );
    });
  });
  group('LiveInputToolCallCallerBranch0', () {
    final wire = {'type': 'direct'};
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputToolCallCallerBranch0.fromJson(_clone(wire));
        final peer = LiveInputToolCallCallerBranch0.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputToolCallCaller.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputToolCallCallerBranch0.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputToolCallCallerBranch0.fromJson(value),
        throwsA(_safe('LiveInputToolCallCallerBranch0')),
      );
      expect(
        () => LiveInputToolCallCallerBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolCallCaller')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputToolCallCallerBranch0.fromJson(value),
        throwsA(_safe('LiveInputToolCallCallerBranch0')),
      );
      expect(
        () => LiveInputToolCallCallerBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolCallCaller')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputToolCallCallerBranch0.fromJson(value),
        throwsA(_safe('LiveInputToolCallCallerBranch0')),
      );
      expect(
        () => LiveInputToolCallCallerBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolCallCaller')),
      );
    });
  });
  group('LiveInputToolCallCallerBranch1', () {
    final wire = {'caller_id': 'PRIVATE_LIVE_INPUT_PAYLOAD', 'type': 'program'};
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputToolCallCallerBranch1.fromJson(_clone(wire));
        final peer = LiveInputToolCallCallerBranch1.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(LiveInputToolCallCaller.fromJson(_clone(wire)).toJson(), wire);
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputToolCallCallerBranch1.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputToolCallCallerBranch1.fromJson(value),
        throwsA(_safe('LiveInputToolCallCallerBranch1')),
      );
      expect(
        () => LiveInputToolCallCallerBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolCallCaller')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputToolCallCallerBranch1.fromJson(value),
        throwsA(_safe('LiveInputToolCallCallerBranch1')),
      );
      expect(
        () => LiveInputToolCallCallerBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolCallCaller')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputToolCallCallerBranch1.fromJson(value),
        throwsA(_safe('LiveInputToolCallCallerBranch1')),
      );
      expect(
        () => LiveInputToolCallCallerBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolCallCaller')),
      );
    });
  });
  group('LiveInputToolCallCallerParamBranch0', () {
    final wire = {'type': 'direct'};
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputToolCallCallerParamBranch0.fromJson(
          _clone(wire),
        );
        final peer = LiveInputToolCallCallerParamBranch0.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputToolCallCallerParam.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputToolCallCallerParamBranch0.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputToolCallCallerParamBranch0.fromJson(value),
        throwsA(_safe('LiveInputToolCallCallerParamBranch0')),
      );
      expect(
        () => LiveInputToolCallCallerParamBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolCallCallerParam')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputToolCallCallerParamBranch0.fromJson(value),
        throwsA(_safe('LiveInputToolCallCallerParamBranch0')),
      );
      expect(
        () => LiveInputToolCallCallerParamBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolCallCallerParam')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputToolCallCallerParamBranch0.fromJson(value),
        throwsA(_safe('LiveInputToolCallCallerParamBranch0')),
      );
      expect(
        () => LiveInputToolCallCallerParamBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolCallCallerParam')),
      );
    });
  });
  group('LiveInputToolCallCallerParamBranch1', () {
    final wire = {'caller_id': 'PRIVATE_LIVE_INPUT_PAYLOAD', 'type': 'program'};
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputToolCallCallerParamBranch1.fromJson(
          _clone(wire),
        );
        final peer = LiveInputToolCallCallerParamBranch1.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputToolCallCallerParam.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputToolCallCallerParamBranch1.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputToolCallCallerParamBranch1.fromJson(value),
        throwsA(_safe('LiveInputToolCallCallerParamBranch1')),
      );
      expect(
        () => LiveInputToolCallCallerParamBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolCallCallerParam')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputToolCallCallerParamBranch1.fromJson(value),
        throwsA(_safe('LiveInputToolCallCallerParamBranch1')),
      );
      expect(
        () => LiveInputToolCallCallerParamBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolCallCallerParam')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputToolCallCallerParamBranch1.fromJson(value),
        throwsA(_safe('LiveInputToolCallCallerParamBranch1')),
      );
      expect(
        () => LiveInputToolCallCallerParamBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolCallCallerParam')),
      );
    });
  });
  group('LiveInputToolSearchExecutionType', () {
    const wire = 'server';
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputToolSearchExecutionType.fromJson(_clone(wire));
        final peer = LiveInputToolSearchExecutionType.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputToolSearchExecutionType.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputToolSearchExecutionType.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputToolSearchExecutionType.fromJson(value),
        throwsA(_safe('LiveInputToolSearchExecutionType')),
      );
      expect(
        () => LiveInputToolSearchExecutionType.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchExecutionType')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputToolSearchExecutionType.fromJson(value),
        throwsA(_safe('LiveInputToolSearchExecutionType')),
      );
      expect(
        () => LiveInputToolSearchExecutionType.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchExecutionType')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputToolSearchExecutionType.fromJson(value),
        throwsA(_safe('LiveInputToolSearchExecutionType')),
      );
      expect(
        () => LiveInputToolSearchExecutionType.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchExecutionType')),
      );
    });
  });
  group('LiveInputToolSearchOutputNamespaceToolParamToolsItemValueBranch0', () {
    final wire = {
      'allowed_callers': ['direct'],
      'async': false,
      'defer_loading': false,
      'description': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'output_schema': <String, dynamic>{},
      'parameters': <String, dynamic>{},
      'strict': false,
      'type': 'function',
    };
    test('direct factory typed value/wire/copy/value/hash/private contracts', () {
      final model =
          LiveInputToolSearchOutputNamespaceToolParamToolsItemValueBranch0.fromJson(
            _clone(wire),
          );
      final peer =
          LiveInputToolSearchOutputNamespaceToolParamToolsItemValueBranch0.fromJson(
            _clone(wire),
          );
      expect(model.toJson(), wire);
      expect(_wire(model.value), wire);
      expect(model, peer);
      expect(model.hashCode, peer.hashCode);
      expect(model.copyWith(), model);
      expect(model.copyWith(value: _clone(wire)), model);
      expect(model.toString(), isNot(contains(_private)));
      expect(
        LiveInputToolSearchOutputNamespaceToolParamToolsItemValue.fromJson(
          _clone(wire),
        ).toJson(),
        wire,
      );
    });
    test('parsed wire and typed collection access stay immutable', () {
      final model =
          LiveInputToolSearchOutputNamespaceToolParamToolsItemValueBranch0.fromJson(
            _clone(wire),
          );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () =>
            LiveInputToolSearchOutputNamespaceToolParamToolsItemValueBranch0.fromJson(
              value,
            ),
        throwsA(
          _safe(
            'LiveInputToolSearchOutputNamespaceToolParamToolsItemValueBranch0',
          ),
        ),
      );
      expect(
        () =>
            LiveInputToolSearchOutputNamespaceToolParamToolsItemValueBranch0.fromJson(
              _clone(wire),
            ).copyWith(value: value),
        throwsA(
          _safe('LiveInputToolSearchOutputNamespaceToolParamToolsItemValue'),
        ),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () =>
            LiveInputToolSearchOutputNamespaceToolParamToolsItemValueBranch0.fromJson(
              value,
            ),
        throwsA(
          _safe(
            'LiveInputToolSearchOutputNamespaceToolParamToolsItemValueBranch0',
          ),
        ),
      );
      expect(
        () =>
            LiveInputToolSearchOutputNamespaceToolParamToolsItemValueBranch0.fromJson(
              _clone(wire),
            ).copyWith(value: value),
        throwsA(
          _safe('LiveInputToolSearchOutputNamespaceToolParamToolsItemValue'),
        ),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () =>
            LiveInputToolSearchOutputNamespaceToolParamToolsItemValueBranch0.fromJson(
              value,
            ),
        throwsA(
          _safe(
            'LiveInputToolSearchOutputNamespaceToolParamToolsItemValueBranch0',
          ),
        ),
      );
      expect(
        () =>
            LiveInputToolSearchOutputNamespaceToolParamToolsItemValueBranch0.fromJson(
              _clone(wire),
            ).copyWith(value: value),
        throwsA(
          _safe('LiveInputToolSearchOutputNamespaceToolParamToolsItemValue'),
        ),
      );
    });
  });
  group('LiveInputToolSearchOutputNamespaceToolParamToolsItemValueBranch1', () {
    final wire = {
      'allowed_callers': ['direct'],
      'async': false,
      'defer_loading': false,
      'description': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'format': {'type': 'text'},
      'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'custom',
    };
    test('direct factory typed value/wire/copy/value/hash/private contracts', () {
      final model =
          LiveInputToolSearchOutputNamespaceToolParamToolsItemValueBranch1.fromJson(
            _clone(wire),
          );
      final peer =
          LiveInputToolSearchOutputNamespaceToolParamToolsItemValueBranch1.fromJson(
            _clone(wire),
          );
      expect(model.toJson(), wire);
      expect(_wire(model.value), wire);
      expect(model, peer);
      expect(model.hashCode, peer.hashCode);
      expect(model.copyWith(), model);
      expect(model.copyWith(value: _clone(wire)), model);
      expect(model.toString(), isNot(contains(_private)));
      expect(
        LiveInputToolSearchOutputNamespaceToolParamToolsItemValue.fromJson(
          _clone(wire),
        ).toJson(),
        wire,
      );
    });
    test('parsed wire and typed collection access stay immutable', () {
      final model =
          LiveInputToolSearchOutputNamespaceToolParamToolsItemValueBranch1.fromJson(
            _clone(wire),
          );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () =>
            LiveInputToolSearchOutputNamespaceToolParamToolsItemValueBranch1.fromJson(
              value,
            ),
        throwsA(
          _safe(
            'LiveInputToolSearchOutputNamespaceToolParamToolsItemValueBranch1',
          ),
        ),
      );
      expect(
        () =>
            LiveInputToolSearchOutputNamespaceToolParamToolsItemValueBranch1.fromJson(
              _clone(wire),
            ).copyWith(value: value),
        throwsA(
          _safe('LiveInputToolSearchOutputNamespaceToolParamToolsItemValue'),
        ),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () =>
            LiveInputToolSearchOutputNamespaceToolParamToolsItemValueBranch1.fromJson(
              value,
            ),
        throwsA(
          _safe(
            'LiveInputToolSearchOutputNamespaceToolParamToolsItemValueBranch1',
          ),
        ),
      );
      expect(
        () =>
            LiveInputToolSearchOutputNamespaceToolParamToolsItemValueBranch1.fromJson(
              _clone(wire),
            ).copyWith(value: value),
        throwsA(
          _safe('LiveInputToolSearchOutputNamespaceToolParamToolsItemValue'),
        ),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () =>
            LiveInputToolSearchOutputNamespaceToolParamToolsItemValueBranch1.fromJson(
              value,
            ),
        throwsA(
          _safe(
            'LiveInputToolSearchOutputNamespaceToolParamToolsItemValueBranch1',
          ),
        ),
      );
      expect(
        () =>
            LiveInputToolSearchOutputNamespaceToolParamToolsItemValueBranch1.fromJson(
              _clone(wire),
            ).copyWith(value: value),
        throwsA(
          _safe('LiveInputToolSearchOutputNamespaceToolParamToolsItemValue'),
        ),
      );
    });
  });
  group('LiveInputToolSearchOutputToolBranch0', () {
    final wire = {
      'allowed_callers': ['direct'],
      'async': false,
      'defer_loading': false,
      'description': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'output_schema': <String, dynamic>{},
      'parameters': <String, dynamic>{},
      'strict': false,
      'type': 'function',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputToolSearchOutputToolBranch0.fromJson(
          _clone(wire),
        );
        final peer = LiveInputToolSearchOutputToolBranch0.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputToolSearchOutputTool.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputToolSearchOutputToolBranch0.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputToolSearchOutputToolBranch0.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch0')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputToolSearchOutputToolBranch0.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch0')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputToolSearchOutputToolBranch0.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch0')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
  });
  group('LiveInputToolSearchOutputToolBranch1', () {
    final wire = {
      'filters': {
        'key': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        'type': 'eq',
        'value': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      },
      'max_num_results': 0,
      'ranking_options': {
        'hybrid_search': {'embedding_weight': 0, 'text_weight': 0},
        'ranker': 'auto',
        'score_threshold': 0,
      },
      'type': 'file_search',
      'vector_store_ids': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputToolSearchOutputToolBranch1.fromJson(
          _clone(wire),
        );
        final peer = LiveInputToolSearchOutputToolBranch1.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputToolSearchOutputTool.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputToolSearchOutputToolBranch1.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputToolSearchOutputToolBranch1.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch1')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputToolSearchOutputToolBranch1.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch1')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputToolSearchOutputToolBranch1.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch1')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
  });
  group('LiveInputToolSearchOutputToolBranch2', () {
    final wire = {'type': 'computer'};
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputToolSearchOutputToolBranch2.fromJson(
          _clone(wire),
        );
        final peer = LiveInputToolSearchOutputToolBranch2.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputToolSearchOutputTool.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputToolSearchOutputToolBranch2.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputToolSearchOutputToolBranch2.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch2')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch2.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputToolSearchOutputToolBranch2.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch2')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch2.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputToolSearchOutputToolBranch2.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch2')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch2.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
  });
  group('LiveInputToolSearchOutputToolBranch3', () {
    final wire = {
      'display_height': 0,
      'display_width': 0,
      'environment': 'windows',
      'type': 'computer_use_preview',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputToolSearchOutputToolBranch3.fromJson(
          _clone(wire),
        );
        final peer = LiveInputToolSearchOutputToolBranch3.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputToolSearchOutputTool.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputToolSearchOutputToolBranch3.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputToolSearchOutputToolBranch3.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch3')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch3.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputToolSearchOutputToolBranch3.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch3')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch3.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputToolSearchOutputToolBranch3.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch3')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch3.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
  });
  group('LiveInputToolSearchOutputToolBranch4', () {
    final wire = {
      'external_web_access': false,
      'filters': {
        'allowed_domains': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
      },
      'search_context_size': 'low',
      'type': 'web_search',
      'user_location': {
        'city': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        'country': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        'region': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        'timezone': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        'type': 'approximate',
      },
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputToolSearchOutputToolBranch4.fromJson(
          _clone(wire),
        );
        final peer = LiveInputToolSearchOutputToolBranch4.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputToolSearchOutputTool.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputToolSearchOutputToolBranch4.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputToolSearchOutputToolBranch4.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch4')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch4.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputToolSearchOutputToolBranch4.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch4')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch4.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputToolSearchOutputToolBranch4.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch4')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch4.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
  });
  group('LiveInputToolSearchOutputToolBranch5', () {
    final wire = {
      'allowed_callers': ['direct'],
      'allowed_tools': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
      'authorization': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'connector_id': 'connector_dropbox',
      'defer_loading': false,
      'headers': <String, dynamic>{},
      'require_approval': {
        'always': {
          'read_only': false,
          'tool_names': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
        },
        'never': {
          'read_only': false,
          'tool_names': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
        },
      },
      'server_description': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'server_label': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'server_url': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'tunnel_id': 'tunnel_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      'type': 'mcp',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputToolSearchOutputToolBranch5.fromJson(
          _clone(wire),
        );
        final peer = LiveInputToolSearchOutputToolBranch5.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputToolSearchOutputTool.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputToolSearchOutputToolBranch5.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputToolSearchOutputToolBranch5.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch5')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch5.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputToolSearchOutputToolBranch5.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch5')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch5.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputToolSearchOutputToolBranch5.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch5')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch5.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
  });
  group('LiveInputToolSearchOutputToolBranch6', () {
    final wire = {
      'allowed_callers': ['direct'],
      'container': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'code_interpreter',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputToolSearchOutputToolBranch6.fromJson(
          _clone(wire),
        );
        final peer = LiveInputToolSearchOutputToolBranch6.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputToolSearchOutputTool.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputToolSearchOutputToolBranch6.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputToolSearchOutputToolBranch6.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch6')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch6.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputToolSearchOutputToolBranch6.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch6')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch6.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputToolSearchOutputToolBranch6.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch6')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch6.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
  });
  group('LiveInputToolSearchOutputToolBranch7', () {
    final wire = {'type': 'programmatic_tool_calling'};
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputToolSearchOutputToolBranch7.fromJson(
          _clone(wire),
        );
        final peer = LiveInputToolSearchOutputToolBranch7.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputToolSearchOutputTool.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputToolSearchOutputToolBranch7.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputToolSearchOutputToolBranch7.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch7')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch7.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputToolSearchOutputToolBranch7.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch7')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch7.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputToolSearchOutputToolBranch7.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch7')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch7.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
  });
  group('LiveInputToolSearchOutputToolBranch8', () {
    final wire = {
      'action': 'generate',
      'background': 'transparent',
      'input_fidelity': 'high',
      'input_image_mask': {
        'file_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        'image_url': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      },
      'model': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'moderation': 'auto',
      'output_compression': 0,
      'output_format': 'png',
      'partial_images': 0,
      'quality': 'low',
      'size': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'image_generation',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputToolSearchOutputToolBranch8.fromJson(
          _clone(wire),
        );
        final peer = LiveInputToolSearchOutputToolBranch8.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputToolSearchOutputTool.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputToolSearchOutputToolBranch8.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputToolSearchOutputToolBranch8.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch8')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch8.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputToolSearchOutputToolBranch8.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch8')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch8.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputToolSearchOutputToolBranch8.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch8')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch8.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
  });
  group('LiveInputToolSearchOutputToolBranch9', () {
    final wire = {'type': 'local_shell'};
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputToolSearchOutputToolBranch9.fromJson(
          _clone(wire),
        );
        final peer = LiveInputToolSearchOutputToolBranch9.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputToolSearchOutputTool.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputToolSearchOutputToolBranch9.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputToolSearchOutputToolBranch9.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch9')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch9.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputToolSearchOutputToolBranch9.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch9')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch9.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputToolSearchOutputToolBranch9.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch9')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch9.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
  });
  group('LiveInputToolSearchOutputToolBranch10', () {
    final wire = {
      'allowed_callers': ['direct'],
      'environment': {
        'file_ids': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
        'memory_limit': '1g',
        'network_policy': {'type': 'disabled'},
        'skills': [
          {
            'skill_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
            'type': 'skill_reference',
            'version': 'PRIVATE_LIVE_INPUT_PAYLOAD',
          },
        ],
        'type': 'container_auto',
      },
      'type': 'shell',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputToolSearchOutputToolBranch10.fromJson(
          _clone(wire),
        );
        final peer = LiveInputToolSearchOutputToolBranch10.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputToolSearchOutputTool.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputToolSearchOutputToolBranch10.fromJson(
        _clone(wire),
      );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputToolSearchOutputToolBranch10.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch10')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch10.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputToolSearchOutputToolBranch10.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch10')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch10.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputToolSearchOutputToolBranch10.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch10')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch10.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
  });
  group('LiveInputToolSearchOutputToolBranch11', () {
    final wire = {
      'allowed_callers': ['direct'],
      'async': false,
      'defer_loading': false,
      'description': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'format': {'type': 'text'},
      'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'custom',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputToolSearchOutputToolBranch11.fromJson(
          _clone(wire),
        );
        final peer = LiveInputToolSearchOutputToolBranch11.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputToolSearchOutputTool.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputToolSearchOutputToolBranch11.fromJson(
        _clone(wire),
      );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputToolSearchOutputToolBranch11.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch11')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch11.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputToolSearchOutputToolBranch11.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch11')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch11.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputToolSearchOutputToolBranch11.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch11')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch11.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
  });
  group('LiveInputToolSearchOutputToolBranch12', () {
    final wire = {
      'description': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'tools': [
        {
          'allowed_callers': ['direct'],
          'async': false,
          'defer_loading': false,
          'description': 'PRIVATE_LIVE_INPUT_PAYLOAD',
          'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
          'output_schema': <String, dynamic>{},
          'parameters': <String, dynamic>{},
          'strict': false,
          'type': 'function',
        },
      ],
      'type': 'namespace',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputToolSearchOutputToolBranch12.fromJson(
          _clone(wire),
        );
        final peer = LiveInputToolSearchOutputToolBranch12.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputToolSearchOutputTool.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputToolSearchOutputToolBranch12.fromJson(
        _clone(wire),
      );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputToolSearchOutputToolBranch12.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch12')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch12.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputToolSearchOutputToolBranch12.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch12')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch12.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputToolSearchOutputToolBranch12.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch12')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch12.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
  });
  group('LiveInputToolSearchOutputToolBranch13', () {
    final wire = {
      'description': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'execution': 'server',
      'parameters': <String, dynamic>{},
      'type': 'tool_search',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputToolSearchOutputToolBranch13.fromJson(
          _clone(wire),
        );
        final peer = LiveInputToolSearchOutputToolBranch13.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputToolSearchOutputTool.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputToolSearchOutputToolBranch13.fromJson(
        _clone(wire),
      );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputToolSearchOutputToolBranch13.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch13')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch13.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputToolSearchOutputToolBranch13.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch13')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch13.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputToolSearchOutputToolBranch13.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch13')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch13.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
  });
  group('LiveInputToolSearchOutputToolBranch14', () {
    final wire = {
      'search_content_types': ['text'],
      'search_context_size': 'low',
      'type': 'web_search_preview',
      'user_location': {
        'city': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        'country': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        'region': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        'timezone': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        'type': 'approximate',
      },
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputToolSearchOutputToolBranch14.fromJson(
          _clone(wire),
        );
        final peer = LiveInputToolSearchOutputToolBranch14.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputToolSearchOutputTool.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputToolSearchOutputToolBranch14.fromJson(
        _clone(wire),
      );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputToolSearchOutputToolBranch14.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch14')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch14.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputToolSearchOutputToolBranch14.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch14')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch14.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputToolSearchOutputToolBranch14.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch14')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch14.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
  });
  group('LiveInputToolSearchOutputToolBranch15', () {
    final wire = {
      'allowed_callers': ['direct'],
      'type': 'apply_patch',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputToolSearchOutputToolBranch15.fromJson(
          _clone(wire),
        );
        final peer = LiveInputToolSearchOutputToolBranch15.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputToolSearchOutputTool.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputToolSearchOutputToolBranch15.fromJson(
        _clone(wire),
      );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputToolSearchOutputToolBranch15.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch15')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch15.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputToolSearchOutputToolBranch15.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch15')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch15.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputToolSearchOutputToolBranch15.fromJson(value),
        throwsA(_safe('LiveInputToolSearchOutputToolBranch15')),
      );
      expect(
        () => LiveInputToolSearchOutputToolBranch15.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputToolSearchOutputTool')),
      );
    });
  });
  group('LiveInputVectorStoreFileAttributesBranch0', () {
    final wire = <String, dynamic>{};
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputVectorStoreFileAttributesBranch0.fromJson(
          _clone(wire),
        );
        final peer = LiveInputVectorStoreFileAttributesBranch0.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputVectorStoreFileAttributes.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputVectorStoreFileAttributesBranch0.fromJson(
        _clone(wire),
      );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputVectorStoreFileAttributesBranch0.fromJson(value),
        throwsA(_safe('LiveInputVectorStoreFileAttributesBranch0')),
      );
      expect(
        () => LiveInputVectorStoreFileAttributesBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputVectorStoreFileAttributes')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputVectorStoreFileAttributesBranch0.fromJson(value),
        throwsA(_safe('LiveInputVectorStoreFileAttributesBranch0')),
      );
      expect(
        () => LiveInputVectorStoreFileAttributesBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputVectorStoreFileAttributes')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputVectorStoreFileAttributesBranch0.fromJson(value),
        throwsA(_safe('LiveInputVectorStoreFileAttributesBranch0')),
      );
      expect(
        () => LiveInputVectorStoreFileAttributesBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputVectorStoreFileAttributes')),
      );
    });
  });
  group('LiveInputVectorStoreFileAttributesBranch1', () {
    const wire = null;
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputVectorStoreFileAttributesBranch1.fromJson(
          _clone(wire),
        );
        final peer = LiveInputVectorStoreFileAttributesBranch1.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputVectorStoreFileAttributes.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputVectorStoreFileAttributesBranch1.fromJson(
        _clone(wire),
      );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputVectorStoreFileAttributesBranch1.fromJson(value),
        throwsA(_safe('LiveInputVectorStoreFileAttributesBranch1')),
      );
      expect(
        () => LiveInputVectorStoreFileAttributesBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputVectorStoreFileAttributes')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputVectorStoreFileAttributesBranch1.fromJson(value),
        throwsA(_safe('LiveInputVectorStoreFileAttributesBranch1')),
      );
      expect(
        () => LiveInputVectorStoreFileAttributesBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputVectorStoreFileAttributes')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputVectorStoreFileAttributesBranch1.fromJson(value),
        throwsA(_safe('LiveInputVectorStoreFileAttributesBranch1')),
      );
      expect(
        () => LiveInputVectorStoreFileAttributesBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputVectorStoreFileAttributes')),
      );
    });
  });
  group('LiveInputWebSearchApproximateLocationBranch0', () {
    final wire = {
      'city': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'country': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'region': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'timezone': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'approximate',
    };
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputWebSearchApproximateLocationBranch0.fromJson(
          _clone(wire),
        );
        final peer = LiveInputWebSearchApproximateLocationBranch0.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputWebSearchApproximateLocation.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputWebSearchApproximateLocationBranch0.fromJson(
        _clone(wire),
      );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputWebSearchApproximateLocationBranch0.fromJson(value),
        throwsA(_safe('LiveInputWebSearchApproximateLocationBranch0')),
      );
      expect(
        () => LiveInputWebSearchApproximateLocationBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputWebSearchApproximateLocation')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputWebSearchApproximateLocationBranch0.fromJson(value),
        throwsA(_safe('LiveInputWebSearchApproximateLocationBranch0')),
      );
      expect(
        () => LiveInputWebSearchApproximateLocationBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputWebSearchApproximateLocation')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputWebSearchApproximateLocationBranch0.fromJson(value),
        throwsA(_safe('LiveInputWebSearchApproximateLocationBranch0')),
      );
      expect(
        () => LiveInputWebSearchApproximateLocationBranch0.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputWebSearchApproximateLocation')),
      );
    });
  });
  group('LiveInputWebSearchApproximateLocationBranch1', () {
    const wire = null;
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputWebSearchApproximateLocationBranch1.fromJson(
          _clone(wire),
        );
        final peer = LiveInputWebSearchApproximateLocationBranch1.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputWebSearchApproximateLocation.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputWebSearchApproximateLocationBranch1.fromJson(
        _clone(wire),
      );
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputWebSearchApproximateLocationBranch1.fromJson(value),
        throwsA(_safe('LiveInputWebSearchApproximateLocationBranch1')),
      );
      expect(
        () => LiveInputWebSearchApproximateLocationBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputWebSearchApproximateLocation')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputWebSearchApproximateLocationBranch1.fromJson(value),
        throwsA(_safe('LiveInputWebSearchApproximateLocationBranch1')),
      );
      expect(
        () => LiveInputWebSearchApproximateLocationBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputWebSearchApproximateLocation')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputWebSearchApproximateLocationBranch1.fromJson(value),
        throwsA(_safe('LiveInputWebSearchApproximateLocationBranch1')),
      );
      expect(
        () => LiveInputWebSearchApproximateLocationBranch1.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputWebSearchApproximateLocation')),
      );
    });
  });
  group('LiveInputWebSearchCallStatus', () {
    const wire = 'in_progress';
    test(
      'direct factory typed value/wire/copy/value/hash/private contracts',
      () {
        final model = LiveInputWebSearchCallStatus.fromJson(_clone(wire));
        final peer = LiveInputWebSearchCallStatus.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(_wire(model.value), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.copyWith(), model);
        expect(model.copyWith(value: _clone(wire)), model);
        expect(model.toString(), isNot(contains(_private)));
        expect(
          LiveInputWebSearchCallStatus.fromJson(_clone(wire)).toJson(),
          wire,
        );
      },
    );
    test('parsed wire and typed collection access stay immutable', () {
      final model = LiveInputWebSearchCallStatus.fromJson(_clone(wire));
      final raw = model.rawValue;
      if (raw is Map) {
        expect(() => raw[_private] = true, throwsUnsupportedError);
      }
      if (raw is List) expect(() => raw.add(true), throwsUnsupportedError);
      final dynamic typed = model.value;
      if (typed is List) expect(typed.clear, throwsUnsupportedError);
      if (typed is Map) expect(typed.clear, throwsUnsupportedError);
      expect(model.toJson(), wire);
    });
    test('runtime Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputWebSearchCallStatus.fromJson(value),
        throwsA(_safe('LiveInputWebSearchCallStatus')),
      );
      expect(
        () => LiveInputWebSearchCallStatus.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputWebSearchCallStatus')),
      );
    });
    test('runtime -Infinity parser/copy admission stays finite', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputWebSearchCallStatus.fromJson(value),
        throwsA(_safe('LiveInputWebSearchCallStatus')),
      );
      expect(
        () => LiveInputWebSearchCallStatus.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputWebSearchCallStatus')),
      );
    });
    test('runtime NaN parser/copy admission stays finite', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputWebSearchCallStatus.fromJson(value),
        throwsA(_safe('LiveInputWebSearchCallStatus')),
      );
      expect(
        () => LiveInputWebSearchCallStatus.fromJson(
          _clone(wire),
        ).copyWith(value: value),
        throwsA(_safe('LiveInputWebSearchCallStatus')),
      );
    });
  });
  group('LiveInputFileSearchToolCallResultsItemValue', () {
    final wire = {
      'attributes': <String, dynamic>{},
      'file_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'filename': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'score': 0,
      'text': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    test('all typed inline fields and value copy/hash', () {
      final model = LiveInputFileSearchToolCallResultsItemValue.fromJson(
        _clone(wire),
      );
      final peer = LiveInputFileSearchToolCallResultsItemValue.fromJson(
        _clone(wire),
      );
      expect(model.toJson(), wire);
      expect(model, peer);
      expect(model.hashCode, peer.hashCode);
      expect(model.copyWith(), model);
      expect(model.toString(), isNot(contains(_private)));
      expect(_wire(model.attributes), (wire as Map)['attributes']);
      expect(_wire(model.fileId), (wire as Map)['file_id']);
      expect(_wire(model.filename), (wire as Map)['filename']);
      expect(_wire(model.score), (wire as Map)['score']);
      expect(_wire(model.text), (wire as Map)['text']);
    });
    test('inline attributes parser/copy malformed field context', () {
      final value = Map<String, dynamic>.from(_clone(wire)! as Map)
        ..['attributes'] = 5;
      expect(
        () => LiveInputFileSearchToolCallResultsItemValue.fromJson(value),
        throwsA(_safe('attributes')),
      );
      expect(
        () => LiveInputFileSearchToolCallResultsItemValue.fromJson(
          _clone(wire),
        ).copyWith(attributes: 5),
        throwsA(_safe('attributes')),
      );
    });
    test('inline attributes absence/null/clear', () {
      final model = LiveInputFileSearchToolCallResultsItemValue.fromJson(
        _clone(wire),
      );
      expect(model.copyWith(attributes: model.attributes), model);
      final removed = model.copyWith(clearAttributes: true);
      expect(removed.hasAttributes, isFalse);
      final nulled = model.copyWith(attributes: null);
      expect(nulled.hasAttributes, isTrue);
      expect(nulled.toJson()['attributes'], isNull);
    });
    test('inline file_id parser/copy malformed field context', () {
      final value = Map<String, dynamic>.from(_clone(wire)! as Map)
        ..['file_id'] = 5;
      expect(
        () => LiveInputFileSearchToolCallResultsItemValue.fromJson(value),
        throwsA(_safe('file_id')),
      );
      expect(
        () => LiveInputFileSearchToolCallResultsItemValue.fromJson(
          _clone(wire),
        ).copyWith(fileId: 5),
        throwsA(_safe('file_id')),
      );
    });
    test('inline file_id absence/null/clear', () {
      final model = LiveInputFileSearchToolCallResultsItemValue.fromJson(
        _clone(wire),
      );
      expect(model.copyWith(fileId: model.fileId), model);
      final removed = model.copyWith(clearFileId: true);
      expect(removed.hasFileId, isFalse);
      expect(() => model.copyWith(fileId: null), throwsA(_safe('file_id')));
    });
    test('inline filename parser/copy malformed field context', () {
      final value = Map<String, dynamic>.from(_clone(wire)! as Map)
        ..['filename'] = 5;
      expect(
        () => LiveInputFileSearchToolCallResultsItemValue.fromJson(value),
        throwsA(_safe('filename')),
      );
      expect(
        () => LiveInputFileSearchToolCallResultsItemValue.fromJson(
          _clone(wire),
        ).copyWith(filename: 5),
        throwsA(_safe('filename')),
      );
    });
    test('inline filename absence/null/clear', () {
      final model = LiveInputFileSearchToolCallResultsItemValue.fromJson(
        _clone(wire),
      );
      expect(model.copyWith(filename: model.filename), model);
      final removed = model.copyWith(clearFilename: true);
      expect(removed.hasFilename, isFalse);
      expect(() => model.copyWith(filename: null), throwsA(_safe('filename')));
    });
    test('inline score parser/copy malformed field context', () {
      final value = Map<String, dynamic>.from(_clone(wire)! as Map)
        ..['score'] = false;
      expect(
        () => LiveInputFileSearchToolCallResultsItemValue.fromJson(value),
        throwsA(_safe('score')),
      );
      expect(
        () => LiveInputFileSearchToolCallResultsItemValue.fromJson(
          _clone(wire),
        ).copyWith(score: false),
        throwsA(_safe('score')),
      );
    });
    test('inline score absence/null/clear', () {
      final model = LiveInputFileSearchToolCallResultsItemValue.fromJson(
        _clone(wire),
      );
      expect(model.copyWith(score: model.score), model);
      final removed = model.copyWith(clearScore: true);
      expect(removed.hasScore, isFalse);
      expect(() => model.copyWith(score: null), throwsA(_safe('score')));
    });
    test('inline text parser/copy malformed field context', () {
      final value = Map<String, dynamic>.from(_clone(wire)! as Map)
        ..['text'] = 5;
      expect(
        () => LiveInputFileSearchToolCallResultsItemValue.fromJson(value),
        throwsA(_safe('text')),
      );
      expect(
        () => LiveInputFileSearchToolCallResultsItemValue.fromJson(
          _clone(wire),
        ).copyWith(text: 5),
        throwsA(_safe('text')),
      );
    });
    test('inline text absence/null/clear', () {
      final model = LiveInputFileSearchToolCallResultsItemValue.fromJson(
        _clone(wire),
      );
      expect(model.copyWith(text: model.text), model);
      final removed = model.copyWith(clearText: true);
      expect(removed.hasText, isFalse);
      expect(() => model.copyWith(text: null), throwsA(_safe('text')));
    });
  });
  group('LiveInputImageGenToolInputImageMaskValue', () {
    final wire = {
      'file_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'image_url': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    test('all typed inline fields and value copy/hash', () {
      final model = LiveInputImageGenToolInputImageMaskValue.fromJson(
        _clone(wire),
      );
      final peer = LiveInputImageGenToolInputImageMaskValue.fromJson(
        _clone(wire),
      );
      expect(model.toJson(), wire);
      expect(model, peer);
      expect(model.hashCode, peer.hashCode);
      expect(model.copyWith(), model);
      expect(model.toString(), isNot(contains(_private)));
      expect(_wire(model.fileId), (wire as Map)['file_id']);
      expect(_wire(model.imageUrl), (wire as Map)['image_url']);
    });
    test('inline file_id parser/copy malformed field context', () {
      final value = Map<String, dynamic>.from(_clone(wire)! as Map)
        ..['file_id'] = 5;
      expect(
        () => LiveInputImageGenToolInputImageMaskValue.fromJson(value),
        throwsA(_safe('file_id')),
      );
      expect(
        () => LiveInputImageGenToolInputImageMaskValue.fromJson(
          _clone(wire),
        ).copyWith(fileId: 5),
        throwsA(_safe('file_id')),
      );
    });
    test('inline file_id absence/null/clear', () {
      final model = LiveInputImageGenToolInputImageMaskValue.fromJson(
        _clone(wire),
      );
      expect(model.copyWith(fileId: model.fileId), model);
      final removed = model.copyWith(clearFileId: true);
      expect(removed.hasFileId, isFalse);
      expect(() => model.copyWith(fileId: null), throwsA(_safe('file_id')));
    });
    test('inline image_url parser/copy malformed field context', () {
      final value = Map<String, dynamic>.from(_clone(wire)! as Map)
        ..['image_url'] = 5;
      expect(
        () => LiveInputImageGenToolInputImageMaskValue.fromJson(value),
        throwsA(_safe('image_url')),
      );
      expect(
        () => LiveInputImageGenToolInputImageMaskValue.fromJson(
          _clone(wire),
        ).copyWith(imageUrl: 5),
        throwsA(_safe('image_url')),
      );
    });
    test('inline image_url absence/null/clear', () {
      final model = LiveInputImageGenToolInputImageMaskValue.fromJson(
        _clone(wire),
      );
      expect(model.copyWith(imageUrl: model.imageUrl), model);
      final removed = model.copyWith(clearImageUrl: true);
      expect(removed.hasImageUrl, isFalse);
      expect(() => model.copyWith(imageUrl: null), throwsA(_safe('image_url')));
    });
  });
  group('LiveInputMCPToolRequireApprovalValueBranch0Value', () {
    final wire = {
      'always': {
        'read_only': false,
        'tool_names': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
      },
      'never': {
        'read_only': false,
        'tool_names': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
      },
    };
    test('all typed inline fields and value copy/hash', () {
      final model = LiveInputMCPToolRequireApprovalValueBranch0Value.fromJson(
        _clone(wire),
      );
      final peer = LiveInputMCPToolRequireApprovalValueBranch0Value.fromJson(
        _clone(wire),
      );
      expect(model.toJson(), wire);
      expect(model, peer);
      expect(model.hashCode, peer.hashCode);
      expect(model.copyWith(), model);
      expect(model.toString(), isNot(contains(_private)));
      expect(_wire(model.always), (wire as Map)['always']);
      expect(_wire(model.never), (wire as Map)['never']);
    });
    test('inline always parser/copy malformed field context', () {
      final value = Map<String, dynamic>.from(_clone(wire)! as Map)
        ..['always'] = 5;
      expect(
        () => LiveInputMCPToolRequireApprovalValueBranch0Value.fromJson(value),
        throwsA(_safe('always')),
      );
      expect(
        () => LiveInputMCPToolRequireApprovalValueBranch0Value.fromJson(
          _clone(wire),
        ).copyWith(always: 5),
        throwsA(_safe('always')),
      );
    });
    test('inline always absence/null/clear', () {
      final model = LiveInputMCPToolRequireApprovalValueBranch0Value.fromJson(
        _clone(wire),
      );
      expect(model.copyWith(always: model.always), model);
      final removed = model.copyWith(clearAlways: true);
      expect(removed.hasAlways, isFalse);
      expect(() => model.copyWith(always: null), throwsA(_safe('always')));
    });
    test('inline never parser/copy malformed field context', () {
      final value = Map<String, dynamic>.from(_clone(wire)! as Map)
        ..['never'] = 5;
      expect(
        () => LiveInputMCPToolRequireApprovalValueBranch0Value.fromJson(value),
        throwsA(_safe('never')),
      );
      expect(
        () => LiveInputMCPToolRequireApprovalValueBranch0Value.fromJson(
          _clone(wire),
        ).copyWith(never: 5),
        throwsA(_safe('never')),
      );
    });
    test('inline never absence/null/clear', () {
      final model = LiveInputMCPToolRequireApprovalValueBranch0Value.fromJson(
        _clone(wire),
      );
      expect(model.copyWith(never: model.never), model);
      final removed = model.copyWith(clearNever: true);
      expect(removed.hasNever, isFalse);
      expect(() => model.copyWith(never: null), throwsA(_safe('never')));
    });
  });
  group('LiveInputResponseConfigurationUpdateItemParamReasoningValue', () {
    final wire = {'effort': 'none'};
    test('all typed inline fields and value copy/hash', () {
      final model =
          LiveInputResponseConfigurationUpdateItemParamReasoningValue.fromJson(
            _clone(wire),
          );
      final peer =
          LiveInputResponseConfigurationUpdateItemParamReasoningValue.fromJson(
            _clone(wire),
          );
      expect(model.toJson(), wire);
      expect(model, peer);
      expect(model.hashCode, peer.hashCode);
      expect(model.copyWith(), model);
      expect(model.toString(), isNot(contains(_private)));
      expect(_wire(model.effort), (wire as Map)['effort']);
    });
    test('inline effort parser/copy malformed field context', () {
      final value = Map<String, dynamic>.from(_clone(wire)! as Map)
        ..['effort'] = 5;
      expect(
        () =>
            LiveInputResponseConfigurationUpdateItemParamReasoningValue.fromJson(
              value,
            ),
        throwsA(_safe('effort')),
      );
      expect(
        () =>
            LiveInputResponseConfigurationUpdateItemParamReasoningValue.fromJson(
              _clone(wire),
            ).copyWith(effort: 5),
        throwsA(_safe('effort')),
      );
    });
    test('inline effort absence/null/clear', () {
      final model =
          LiveInputResponseConfigurationUpdateItemParamReasoningValue.fromJson(
            _clone(wire),
          );
      expect(model.copyWith(effort: model.effort), model);
      final removed = model.copyWith(clearEffort: true);
      expect(removed.hasEffort, isFalse);
      final nulled = model.copyWith(effort: null);
      expect(nulled.hasEffort, isTrue);
      expect(nulled.toJson()['effort'], isNull);
    });
  });
  group('LiveInputWebSearchActionSearchSourcesItemValue', () {
    final wire = {'type': 'url', 'url': 'PRIVATE_LIVE_INPUT_PAYLOAD'};
    test('all typed inline fields and value copy/hash', () {
      final model = LiveInputWebSearchActionSearchSourcesItemValue.fromJson(
        _clone(wire),
      );
      final peer = LiveInputWebSearchActionSearchSourcesItemValue.fromJson(
        _clone(wire),
      );
      expect(model.toJson(), wire);
      expect(model, peer);
      expect(model.hashCode, peer.hashCode);
      expect(model.copyWith(), model);
      expect(model.toString(), isNot(contains(_private)));
      expect(_wire(model.type), (wire as Map)['type']);
      expect(_wire(model.url), (wire as Map)['url']);
    });
    test('inline type parser/copy malformed field context', () {
      final value = Map<String, dynamic>.from(_clone(wire)! as Map)
        ..['type'] = 5;
      expect(
        () => LiveInputWebSearchActionSearchSourcesItemValue.fromJson(value),
        throwsA(_safe('type')),
      );
    });
    test('inline url parser/copy malformed field context', () {
      final value = Map<String, dynamic>.from(_clone(wire)! as Map)
        ..['url'] = 5;
      expect(
        () => LiveInputWebSearchActionSearchSourcesItemValue.fromJson(value),
        throwsA(_safe('url')),
      );
      expect(
        () => LiveInputWebSearchActionSearchSourcesItemValue.fromJson(
          _clone(wire),
        ).copyWith(url: 5),
        throwsA(_safe('url')),
      );
    });
  });
  group('LiveInputWebSearchApproximateLocationBranch0Value', () {
    final wire = {
      'city': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'country': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'region': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'timezone': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'approximate',
    };
    test('all typed inline fields and value copy/hash', () {
      final model = LiveInputWebSearchApproximateLocationBranch0Value.fromJson(
        _clone(wire),
      );
      final peer = LiveInputWebSearchApproximateLocationBranch0Value.fromJson(
        _clone(wire),
      );
      expect(model.toJson(), wire);
      expect(model, peer);
      expect(model.hashCode, peer.hashCode);
      expect(model.copyWith(), model);
      expect(model.toString(), isNot(contains(_private)));
      expect(_wire(model.city), (wire as Map)['city']);
      expect(_wire(model.country), (wire as Map)['country']);
      expect(_wire(model.region), (wire as Map)['region']);
      expect(_wire(model.timezone), (wire as Map)['timezone']);
      expect(_wire(model.type), (wire as Map)['type']);
    });
    test('inline city parser/copy malformed field context', () {
      final value = Map<String, dynamic>.from(_clone(wire)! as Map)
        ..['city'] = 5;
      expect(
        () => LiveInputWebSearchApproximateLocationBranch0Value.fromJson(value),
        throwsA(_safe('city')),
      );
      expect(
        () => LiveInputWebSearchApproximateLocationBranch0Value.fromJson(
          _clone(wire),
        ).copyWith(city: 5),
        throwsA(_safe('city')),
      );
    });
    test('inline city absence/null/clear', () {
      final model = LiveInputWebSearchApproximateLocationBranch0Value.fromJson(
        _clone(wire),
      );
      expect(model.copyWith(city: model.city), model);
      final removed = model.copyWith(clearCity: true);
      expect(removed.hasCity, isFalse);
      final nulled = model.copyWith(city: null);
      expect(nulled.hasCity, isTrue);
      expect(nulled.toJson()['city'], isNull);
    });
    test('inline country parser/copy malformed field context', () {
      final value = Map<String, dynamic>.from(_clone(wire)! as Map)
        ..['country'] = 5;
      expect(
        () => LiveInputWebSearchApproximateLocationBranch0Value.fromJson(value),
        throwsA(_safe('country')),
      );
      expect(
        () => LiveInputWebSearchApproximateLocationBranch0Value.fromJson(
          _clone(wire),
        ).copyWith(country: 5),
        throwsA(_safe('country')),
      );
    });
    test('inline country absence/null/clear', () {
      final model = LiveInputWebSearchApproximateLocationBranch0Value.fromJson(
        _clone(wire),
      );
      expect(model.copyWith(country: model.country), model);
      final removed = model.copyWith(clearCountry: true);
      expect(removed.hasCountry, isFalse);
      final nulled = model.copyWith(country: null);
      expect(nulled.hasCountry, isTrue);
      expect(nulled.toJson()['country'], isNull);
    });
    test('inline region parser/copy malformed field context', () {
      final value = Map<String, dynamic>.from(_clone(wire)! as Map)
        ..['region'] = 5;
      expect(
        () => LiveInputWebSearchApproximateLocationBranch0Value.fromJson(value),
        throwsA(_safe('region')),
      );
      expect(
        () => LiveInputWebSearchApproximateLocationBranch0Value.fromJson(
          _clone(wire),
        ).copyWith(region: 5),
        throwsA(_safe('region')),
      );
    });
    test('inline region absence/null/clear', () {
      final model = LiveInputWebSearchApproximateLocationBranch0Value.fromJson(
        _clone(wire),
      );
      expect(model.copyWith(region: model.region), model);
      final removed = model.copyWith(clearRegion: true);
      expect(removed.hasRegion, isFalse);
      final nulled = model.copyWith(region: null);
      expect(nulled.hasRegion, isTrue);
      expect(nulled.toJson()['region'], isNull);
    });
    test('inline timezone parser/copy malformed field context', () {
      final value = Map<String, dynamic>.from(_clone(wire)! as Map)
        ..['timezone'] = 5;
      expect(
        () => LiveInputWebSearchApproximateLocationBranch0Value.fromJson(value),
        throwsA(_safe('timezone')),
      );
      expect(
        () => LiveInputWebSearchApproximateLocationBranch0Value.fromJson(
          _clone(wire),
        ).copyWith(timezone: 5),
        throwsA(_safe('timezone')),
      );
    });
    test('inline timezone absence/null/clear', () {
      final model = LiveInputWebSearchApproximateLocationBranch0Value.fromJson(
        _clone(wire),
      );
      expect(model.copyWith(timezone: model.timezone), model);
      final removed = model.copyWith(clearTimezone: true);
      expect(removed.hasTimezone, isFalse);
      final nulled = model.copyWith(timezone: null);
      expect(nulled.hasTimezone, isTrue);
      expect(nulled.toJson()['timezone'], isNull);
    });
    test('inline type parser/copy malformed field context', () {
      final value = Map<String, dynamic>.from(_clone(wire)! as Map)
        ..['type'] = 5;
      expect(
        () => LiveInputWebSearchApproximateLocationBranch0Value.fromJson(value),
        throwsA(_safe('type')),
      );
      expect(
        () => LiveInputWebSearchApproximateLocationBranch0Value.fromJson(
          _clone(wire),
        ).copyWith(type: 5),
        throwsA(_safe('type')),
      );
    });
    test('inline type absence/null/clear', () {
      final model = LiveInputWebSearchApproximateLocationBranch0Value.fromJson(
        _clone(wire),
      );
      expect(model.copyWith(type: model.type), model);
      final removed = model.copyWith(clearType: true);
      expect(removed.hasType, isFalse);
      expect(() => model.copyWith(type: null), throwsA(_safe('type')));
    });
  });
  group('LiveInputWebSearchToolFiltersValue', () {
    final wire = {
      'allowed_domains': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
    };
    test('all typed inline fields and value copy/hash', () {
      final model = LiveInputWebSearchToolFiltersValue.fromJson(_clone(wire));
      final peer = LiveInputWebSearchToolFiltersValue.fromJson(_clone(wire));
      expect(model.toJson(), wire);
      expect(model, peer);
      expect(model.hashCode, peer.hashCode);
      expect(model.copyWith(), model);
      expect(model.toString(), isNot(contains(_private)));
      expect(_wire(model.allowedDomains), (wire as Map)['allowed_domains']);
    });
    test('inline allowed_domains parser/copy malformed field context', () {
      final value = Map<String, dynamic>.from(_clone(wire)! as Map)
        ..['allowed_domains'] = 5;
      expect(
        () => LiveInputWebSearchToolFiltersValue.fromJson(value),
        throwsA(_safe('allowed_domains')),
      );
      expect(
        () => LiveInputWebSearchToolFiltersValue.fromJson(
          _clone(wire),
        ).copyWith(allowedDomains: 5),
        throwsA(_safe('allowed_domains')),
      );
    });
    test('inline allowed_domains absence/null/clear', () {
      final model = LiveInputWebSearchToolFiltersValue.fromJson(_clone(wire));
      expect(model.copyWith(allowedDomains: model.allowedDomains), model);
      final removed = model.copyWith(clearAllowedDomains: true);
      expect(removed.hasAllowedDomains, isFalse);
      final nulled = model.copyWith(allowedDomains: null);
      expect(nulled.hasAllowedDomains, isTrue);
      expect(nulled.toJson()['allowed_domains'], isNull);
    });
  });
}
