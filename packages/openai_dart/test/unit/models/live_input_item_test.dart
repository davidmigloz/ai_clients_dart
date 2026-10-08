import 'dart:convert';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

const _private = 'PRIVATE_LIVE_INPUT_PAYLOAD';
Object? _wire(Object? value) {
  if (value is LiveInputValue) return value.toJson();
  if (value is List) return value.map(_wire).toList();
  if (value is Map) {
    return value.map((key, value) => MapEntry(key, _wire(value)));
  }
  return value;
}

Object? _clone(Object? value) => jsonDecode(jsonEncode(value));
Matcher _safe(String field) => isA<FormatException>()
    .having((error) => error.message, 'context', contains(field))
    .having((error) => error.source, 'source', isNull)
    .having((error) => error.offset, 'offset', isNull)
    .having((error) => error.toString(), 'privacy', isNot(contains(_private)));

void main() {
  group('AdditionalToolsItemParam', () {
    final minimal = {
      'type': 'additional_tools',
      'role': 'developer',
      'tools': <dynamic>[],
    };
    final full = {
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
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputAdditionalToolsItemParam.fromJson(_clone(wire));
        final peer = LiveInputAdditionalToolsItemParam.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputAdditionalToolsItemParam.fromJson(_clone(full));
      expect(_wire(model.id), (full as Map)['id'], reason: 'id');
      expect(model.hasId, isTrue);
      expect(_wire(model.role), (full as Map)['role'], reason: 'role');
      expect(_wire(model.tools), (full as Map)['tools'], reason: 'tools');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputAdditionalToolsItemParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('optional id omit/null/clear and copy ownership', () {
      final model = LiveInputAdditionalToolsItemParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearId: true);
      expect(omitted.rawJson.containsKey('id'), isFalse);
      expect(omitted.hasId, isFalse);
      expect(model.copyWith(id: model.id), model);
      final cleared = model.copyWith(id: null);
      expect(cleared.rawJson.containsKey('id'), isTrue);
      expect(cleared.toJson()['id'], isNull);
      expect(cleared.hasId, isTrue);
    });
    test('known id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['id'] = 5;
      expect(
        () => LiveInputAdditionalToolsItemParam.fromJson(wire),
        throwsA(_safe('id')),
      );
      expect(
        () => LiveInputAdditionalToolsItemParam.fromJson(
          _clone(full),
        ).copyWith(id: 5),
        throwsA(_safe('id')),
      );
    });
    test('required role absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('role');
      expect(
        () => LiveInputAdditionalToolsItemParam.fromJson(wire),
        throwsA(_safe('role')),
      );
    });
    test('known role wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['role'] = 5;
      expect(
        () => LiveInputAdditionalToolsItemParam.fromJson(wire),
        throwsA(_safe('role')),
      );
    });
    test('required tools absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('tools');
      expect(
        () => LiveInputAdditionalToolsItemParam.fromJson(wire),
        throwsA(_safe('tools')),
      );
    });
    test('known tools wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['tools'] = 5;
      expect(
        () => LiveInputAdditionalToolsItemParam.fromJson(wire),
        throwsA(_safe('tools')),
      );
      expect(
        () => LiveInputAdditionalToolsItemParam.fromJson(
          _clone(full),
        ).copyWith(tools: 5),
        throwsA(_safe('tools')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputAdditionalToolsItemParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputAdditionalToolsItemParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputAdditionalToolsItemParam.fromJson(wire),
        throwsA(_safe('LiveInputAdditionalToolsItemParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputAdditionalToolsItemParam.fromJson(wire),
        throwsA(_safe('LiveInputAdditionalToolsItemParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputAdditionalToolsItemParam.fromJson(wire),
        throwsA(_safe('LiveInputAdditionalToolsItemParam')),
      );
    });
  });
  group('Annotation', () {
    final minimal = {
      'type': 'file_citation',
      'file_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'index': 0,
      'filename': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    final full = {
      'file_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'filename': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'index': 0,
      'type': 'file_citation',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputAnnotation.fromJson(_clone(wire));
        final peer = LiveInputAnnotation.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
  });
  group('ApplyPatchCallOutputStatusParam', () {
    const minimal = 'completed';
    const full = 'completed';
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputApplyPatchCallOutputStatusParam.fromJson(
          _clone(wire),
        );
        final peer = LiveInputApplyPatchCallOutputStatusParam.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('value copy and JSON ownership', () {
      final model = LiveInputApplyPatchCallOutputStatusParam.fromJson(
        _clone(full),
      );
      expect(_wire(model.value), full);
      expect(model.copyWith(value: _clone(full)), model);
    });
  });
  group('ApplyPatchCallStatusParam', () {
    const minimal = 'in_progress';
    const full = 'in_progress';
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputApplyPatchCallStatusParam.fromJson(_clone(wire));
        final peer = LiveInputApplyPatchCallStatusParam.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('value copy and JSON ownership', () {
      final model = LiveInputApplyPatchCallStatusParam.fromJson(_clone(full));
      expect(_wire(model.value), full);
      expect(model.copyWith(value: _clone(full)), model);
    });
  });
  group('ApplyPatchCreateFileOperationParam', () {
    final minimal = {
      'type': 'create_file',
      'path': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'diff': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    final full = {
      'diff': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'path': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'create_file',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputApplyPatchCreateFileOperationParam.fromJson(
          _clone(wire),
        );
        final peer = LiveInputApplyPatchCreateFileOperationParam.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputApplyPatchCreateFileOperationParam.fromJson(
        _clone(full),
      );
      expect(_wire(model.diff), (full as Map)['diff'], reason: 'diff');
      expect(_wire(model.path), (full as Map)['path'], reason: 'path');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputApplyPatchCreateFileOperationParam.fromJson(
        source,
      );
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required diff absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('diff');
      expect(
        () => LiveInputApplyPatchCreateFileOperationParam.fromJson(wire),
        throwsA(_safe('diff')),
      );
    });
    test('known diff wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['diff'] = 5;
      expect(
        () => LiveInputApplyPatchCreateFileOperationParam.fromJson(wire),
        throwsA(_safe('diff')),
      );
      expect(
        () => LiveInputApplyPatchCreateFileOperationParam.fromJson(
          _clone(full),
        ).copyWith(diff: 5),
        throwsA(_safe('diff')),
      );
    });
    test('required path absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('path');
      expect(
        () => LiveInputApplyPatchCreateFileOperationParam.fromJson(wire),
        throwsA(_safe('path')),
      );
    });
    test('known path wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['path'] = 5;
      expect(
        () => LiveInputApplyPatchCreateFileOperationParam.fromJson(wire),
        throwsA(_safe('path')),
      );
      expect(
        () => LiveInputApplyPatchCreateFileOperationParam.fromJson(
          _clone(full),
        ).copyWith(path: 5),
        throwsA(_safe('path')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputApplyPatchCreateFileOperationParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputApplyPatchCreateFileOperationParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputApplyPatchCreateFileOperationParam.fromJson(wire),
        throwsA(_safe('LiveInputApplyPatchCreateFileOperationParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputApplyPatchCreateFileOperationParam.fromJson(wire),
        throwsA(_safe('LiveInputApplyPatchCreateFileOperationParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputApplyPatchCreateFileOperationParam.fromJson(wire),
        throwsA(_safe('LiveInputApplyPatchCreateFileOperationParam')),
      );
    });
  });
  group('ApplyPatchDeleteFileOperationParam', () {
    final minimal = {
      'type': 'delete_file',
      'path': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    final full = {'path': 'PRIVATE_LIVE_INPUT_PAYLOAD', 'type': 'delete_file'};
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputApplyPatchDeleteFileOperationParam.fromJson(
          _clone(wire),
        );
        final peer = LiveInputApplyPatchDeleteFileOperationParam.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputApplyPatchDeleteFileOperationParam.fromJson(
        _clone(full),
      );
      expect(_wire(model.path), (full as Map)['path'], reason: 'path');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputApplyPatchDeleteFileOperationParam.fromJson(
        source,
      );
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required path absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('path');
      expect(
        () => LiveInputApplyPatchDeleteFileOperationParam.fromJson(wire),
        throwsA(_safe('path')),
      );
    });
    test('known path wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['path'] = 5;
      expect(
        () => LiveInputApplyPatchDeleteFileOperationParam.fromJson(wire),
        throwsA(_safe('path')),
      );
      expect(
        () => LiveInputApplyPatchDeleteFileOperationParam.fromJson(
          _clone(full),
        ).copyWith(path: 5),
        throwsA(_safe('path')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputApplyPatchDeleteFileOperationParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputApplyPatchDeleteFileOperationParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputApplyPatchDeleteFileOperationParam.fromJson(wire),
        throwsA(_safe('LiveInputApplyPatchDeleteFileOperationParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputApplyPatchDeleteFileOperationParam.fromJson(wire),
        throwsA(_safe('LiveInputApplyPatchDeleteFileOperationParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputApplyPatchDeleteFileOperationParam.fromJson(wire),
        throwsA(_safe('LiveInputApplyPatchDeleteFileOperationParam')),
      );
    });
  });
  group('ApplyPatchOperationParam', () {
    final minimal = {
      'type': 'create_file',
      'path': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'diff': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    final full = {
      'diff': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'path': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'create_file',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputApplyPatchOperationParam.fromJson(_clone(wire));
        final peer = LiveInputApplyPatchOperationParam.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
  });
  group('ApplyPatchToolCallItemParam', () {
    final minimal = {
      'type': 'apply_patch_call',
      'call_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'status': 'in_progress',
      'operation': {
        'type': 'create_file',
        'path': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        'diff': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      },
    };
    final full = {
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
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputApplyPatchToolCallItemParam.fromJson(
          _clone(wire),
        );
        final peer = LiveInputApplyPatchToolCallItemParam.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputApplyPatchToolCallItemParam.fromJson(_clone(full));
      expect(_wire(model.callId), (full as Map)['call_id'], reason: 'call_id');
      expect(_wire(model.caller), (full as Map)['caller'], reason: 'caller');
      expect(model.hasCaller, isTrue);
      expect(_wire(model.id), (full as Map)['id'], reason: 'id');
      expect(model.hasId, isTrue);
      expect(
        _wire(model.operation),
        (full as Map)['operation'],
        reason: 'operation',
      );
      expect(_wire(model.status), (full as Map)['status'], reason: 'status');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputApplyPatchToolCallItemParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required call_id absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('call_id');
      expect(
        () => LiveInputApplyPatchToolCallItemParam.fromJson(wire),
        throwsA(_safe('call_id')),
      );
    });
    test('known call_id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['call_id'] = 5;
      expect(
        () => LiveInputApplyPatchToolCallItemParam.fromJson(wire),
        throwsA(_safe('call_id')),
      );
      expect(
        () => LiveInputApplyPatchToolCallItemParam.fromJson(
          _clone(full),
        ).copyWith(callId: 5),
        throwsA(_safe('call_id')),
      );
    });
    test('optional caller omit/null/clear and copy ownership', () {
      final model = LiveInputApplyPatchToolCallItemParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearCaller: true);
      expect(omitted.rawJson.containsKey('caller'), isFalse);
      expect(omitted.hasCaller, isFalse);
      expect(model.copyWith(caller: model.caller), model);
      final cleared = model.copyWith(caller: null);
      expect(cleared.rawJson.containsKey('caller'), isTrue);
      expect(cleared.toJson()['caller'], isNull);
      expect(cleared.hasCaller, isTrue);
    });
    test('known caller wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['caller'] = 5;
      expect(
        () => LiveInputApplyPatchToolCallItemParam.fromJson(wire),
        throwsA(_safe('caller')),
      );
      expect(
        () => LiveInputApplyPatchToolCallItemParam.fromJson(
          _clone(full),
        ).copyWith(caller: 5),
        throwsA(_safe('caller')),
      );
    });
    test('optional id omit/null/clear and copy ownership', () {
      final model = LiveInputApplyPatchToolCallItemParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearId: true);
      expect(omitted.rawJson.containsKey('id'), isFalse);
      expect(omitted.hasId, isFalse);
      expect(model.copyWith(id: model.id), model);
      final cleared = model.copyWith(id: null);
      expect(cleared.rawJson.containsKey('id'), isTrue);
      expect(cleared.toJson()['id'], isNull);
      expect(cleared.hasId, isTrue);
    });
    test('known id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['id'] = 5;
      expect(
        () => LiveInputApplyPatchToolCallItemParam.fromJson(wire),
        throwsA(_safe('id')),
      );
      expect(
        () => LiveInputApplyPatchToolCallItemParam.fromJson(
          _clone(full),
        ).copyWith(id: 5),
        throwsA(_safe('id')),
      );
    });
    test('required operation absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('operation');
      expect(
        () => LiveInputApplyPatchToolCallItemParam.fromJson(wire),
        throwsA(_safe('operation')),
      );
    });
    test('known operation wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['operation'] = 5;
      expect(
        () => LiveInputApplyPatchToolCallItemParam.fromJson(wire),
        throwsA(_safe('operation')),
      );
      expect(
        () => LiveInputApplyPatchToolCallItemParam.fromJson(
          _clone(full),
        ).copyWith(operation: 5),
        throwsA(_safe('operation')),
      );
    });
    test('required status absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('status');
      expect(
        () => LiveInputApplyPatchToolCallItemParam.fromJson(wire),
        throwsA(_safe('status')),
      );
    });
    test('known status wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['status'] = 5;
      expect(
        () => LiveInputApplyPatchToolCallItemParam.fromJson(wire),
        throwsA(_safe('status')),
      );
      expect(
        () => LiveInputApplyPatchToolCallItemParam.fromJson(
          _clone(full),
        ).copyWith(status: 5),
        throwsA(_safe('status')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputApplyPatchToolCallItemParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputApplyPatchToolCallItemParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputApplyPatchToolCallItemParam.fromJson(wire),
        throwsA(_safe('LiveInputApplyPatchToolCallItemParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputApplyPatchToolCallItemParam.fromJson(wire),
        throwsA(_safe('LiveInputApplyPatchToolCallItemParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputApplyPatchToolCallItemParam.fromJson(wire),
        throwsA(_safe('LiveInputApplyPatchToolCallItemParam')),
      );
    });
  });
  group('ApplyPatchToolCallOutputItemParam', () {
    final minimal = {
      'type': 'apply_patch_call_output',
      'call_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'status': 'completed',
    };
    final full = {
      'call_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'caller': {'type': 'direct'},
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'output': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'status': 'completed',
      'type': 'apply_patch_call_output',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputApplyPatchToolCallOutputItemParam.fromJson(
          _clone(wire),
        );
        final peer = LiveInputApplyPatchToolCallOutputItemParam.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputApplyPatchToolCallOutputItemParam.fromJson(
        _clone(full),
      );
      expect(_wire(model.callId), (full as Map)['call_id'], reason: 'call_id');
      expect(_wire(model.caller), (full as Map)['caller'], reason: 'caller');
      expect(model.hasCaller, isTrue);
      expect(_wire(model.id), (full as Map)['id'], reason: 'id');
      expect(model.hasId, isTrue);
      expect(_wire(model.output), (full as Map)['output'], reason: 'output');
      expect(model.hasOutput, isTrue);
      expect(_wire(model.status), (full as Map)['status'], reason: 'status');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputApplyPatchToolCallOutputItemParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required call_id absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('call_id');
      expect(
        () => LiveInputApplyPatchToolCallOutputItemParam.fromJson(wire),
        throwsA(_safe('call_id')),
      );
    });
    test('known call_id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['call_id'] = 5;
      expect(
        () => LiveInputApplyPatchToolCallOutputItemParam.fromJson(wire),
        throwsA(_safe('call_id')),
      );
      expect(
        () => LiveInputApplyPatchToolCallOutputItemParam.fromJson(
          _clone(full),
        ).copyWith(callId: 5),
        throwsA(_safe('call_id')),
      );
    });
    test('optional caller omit/null/clear and copy ownership', () {
      final model = LiveInputApplyPatchToolCallOutputItemParam.fromJson(
        _clone(full),
      );
      final omitted = model.copyWith(clearCaller: true);
      expect(omitted.rawJson.containsKey('caller'), isFalse);
      expect(omitted.hasCaller, isFalse);
      expect(model.copyWith(caller: model.caller), model);
      final cleared = model.copyWith(caller: null);
      expect(cleared.rawJson.containsKey('caller'), isTrue);
      expect(cleared.toJson()['caller'], isNull);
      expect(cleared.hasCaller, isTrue);
    });
    test('known caller wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['caller'] = 5;
      expect(
        () => LiveInputApplyPatchToolCallOutputItemParam.fromJson(wire),
        throwsA(_safe('caller')),
      );
      expect(
        () => LiveInputApplyPatchToolCallOutputItemParam.fromJson(
          _clone(full),
        ).copyWith(caller: 5),
        throwsA(_safe('caller')),
      );
    });
    test('optional id omit/null/clear and copy ownership', () {
      final model = LiveInputApplyPatchToolCallOutputItemParam.fromJson(
        _clone(full),
      );
      final omitted = model.copyWith(clearId: true);
      expect(omitted.rawJson.containsKey('id'), isFalse);
      expect(omitted.hasId, isFalse);
      expect(model.copyWith(id: model.id), model);
      final cleared = model.copyWith(id: null);
      expect(cleared.rawJson.containsKey('id'), isTrue);
      expect(cleared.toJson()['id'], isNull);
      expect(cleared.hasId, isTrue);
    });
    test('known id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['id'] = 5;
      expect(
        () => LiveInputApplyPatchToolCallOutputItemParam.fromJson(wire),
        throwsA(_safe('id')),
      );
      expect(
        () => LiveInputApplyPatchToolCallOutputItemParam.fromJson(
          _clone(full),
        ).copyWith(id: 5),
        throwsA(_safe('id')),
      );
    });
    test('optional output omit/null/clear and copy ownership', () {
      final model = LiveInputApplyPatchToolCallOutputItemParam.fromJson(
        _clone(full),
      );
      final omitted = model.copyWith(clearOutput: true);
      expect(omitted.rawJson.containsKey('output'), isFalse);
      expect(omitted.hasOutput, isFalse);
      expect(model.copyWith(output: model.output), model);
      final cleared = model.copyWith(output: null);
      expect(cleared.rawJson.containsKey('output'), isTrue);
      expect(cleared.toJson()['output'], isNull);
      expect(cleared.hasOutput, isTrue);
    });
    test('known output wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['output'] = 5;
      expect(
        () => LiveInputApplyPatchToolCallOutputItemParam.fromJson(wire),
        throwsA(_safe('output')),
      );
      expect(
        () => LiveInputApplyPatchToolCallOutputItemParam.fromJson(
          _clone(full),
        ).copyWith(output: 5),
        throwsA(_safe('output')),
      );
    });
    test('required status absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('status');
      expect(
        () => LiveInputApplyPatchToolCallOutputItemParam.fromJson(wire),
        throwsA(_safe('status')),
      );
    });
    test('known status wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['status'] = 5;
      expect(
        () => LiveInputApplyPatchToolCallOutputItemParam.fromJson(wire),
        throwsA(_safe('status')),
      );
      expect(
        () => LiveInputApplyPatchToolCallOutputItemParam.fromJson(
          _clone(full),
        ).copyWith(status: 5),
        throwsA(_safe('status')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputApplyPatchToolCallOutputItemParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputApplyPatchToolCallOutputItemParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputApplyPatchToolCallOutputItemParam.fromJson(wire),
        throwsA(_safe('LiveInputApplyPatchToolCallOutputItemParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputApplyPatchToolCallOutputItemParam.fromJson(wire),
        throwsA(_safe('LiveInputApplyPatchToolCallOutputItemParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputApplyPatchToolCallOutputItemParam.fromJson(wire),
        throwsA(_safe('LiveInputApplyPatchToolCallOutputItemParam')),
      );
    });
  });
  group('ApplyPatchToolParam', () {
    final minimal = {'type': 'apply_patch'};
    final full = {
      'allowed_callers': ['direct'],
      'type': 'apply_patch',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputApplyPatchToolParam.fromJson(_clone(wire));
        final peer = LiveInputApplyPatchToolParam.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputApplyPatchToolParam.fromJson(_clone(full));
      expect(
        _wire(model.allowedCallers),
        (full as Map)['allowed_callers'],
        reason: 'allowed_callers',
      );
      expect(model.hasAllowedCallers, isTrue);
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputApplyPatchToolParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('optional allowed_callers omit/null/clear and copy ownership', () {
      final model = LiveInputApplyPatchToolParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearAllowedCallers: true);
      expect(omitted.rawJson.containsKey('allowed_callers'), isFalse);
      expect(omitted.hasAllowedCallers, isFalse);
      expect(model.copyWith(allowedCallers: model.allowedCallers), model);
      final cleared = model.copyWith(allowedCallers: null);
      expect(cleared.rawJson.containsKey('allowed_callers'), isTrue);
      expect(cleared.toJson()['allowed_callers'], isNull);
      expect(cleared.hasAllowedCallers, isTrue);
    });
    test('known allowed_callers wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['allowed_callers'] = 5;
      expect(
        () => LiveInputApplyPatchToolParam.fromJson(wire),
        throwsA(_safe('allowed_callers')),
      );
      expect(
        () => LiveInputApplyPatchToolParam.fromJson(
          _clone(full),
        ).copyWith(allowedCallers: 5),
        throwsA(_safe('allowed_callers')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputApplyPatchToolParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputApplyPatchToolParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputApplyPatchToolParam.fromJson(wire),
        throwsA(_safe('LiveInputApplyPatchToolParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputApplyPatchToolParam.fromJson(wire),
        throwsA(_safe('LiveInputApplyPatchToolParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputApplyPatchToolParam.fromJson(wire),
        throwsA(_safe('LiveInputApplyPatchToolParam')),
      );
    });
  });
  group('ApplyPatchUpdateFileOperationParam', () {
    final minimal = {
      'type': 'update_file',
      'path': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'diff': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    final full = {
      'diff': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'path': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'update_file',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputApplyPatchUpdateFileOperationParam.fromJson(
          _clone(wire),
        );
        final peer = LiveInputApplyPatchUpdateFileOperationParam.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputApplyPatchUpdateFileOperationParam.fromJson(
        _clone(full),
      );
      expect(_wire(model.diff), (full as Map)['diff'], reason: 'diff');
      expect(_wire(model.path), (full as Map)['path'], reason: 'path');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputApplyPatchUpdateFileOperationParam.fromJson(
        source,
      );
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required diff absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('diff');
      expect(
        () => LiveInputApplyPatchUpdateFileOperationParam.fromJson(wire),
        throwsA(_safe('diff')),
      );
    });
    test('known diff wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['diff'] = 5;
      expect(
        () => LiveInputApplyPatchUpdateFileOperationParam.fromJson(wire),
        throwsA(_safe('diff')),
      );
      expect(
        () => LiveInputApplyPatchUpdateFileOperationParam.fromJson(
          _clone(full),
        ).copyWith(diff: 5),
        throwsA(_safe('diff')),
      );
    });
    test('required path absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('path');
      expect(
        () => LiveInputApplyPatchUpdateFileOperationParam.fromJson(wire),
        throwsA(_safe('path')),
      );
    });
    test('known path wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['path'] = 5;
      expect(
        () => LiveInputApplyPatchUpdateFileOperationParam.fromJson(wire),
        throwsA(_safe('path')),
      );
      expect(
        () => LiveInputApplyPatchUpdateFileOperationParam.fromJson(
          _clone(full),
        ).copyWith(path: 5),
        throwsA(_safe('path')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputApplyPatchUpdateFileOperationParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputApplyPatchUpdateFileOperationParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputApplyPatchUpdateFileOperationParam.fromJson(wire),
        throwsA(_safe('LiveInputApplyPatchUpdateFileOperationParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputApplyPatchUpdateFileOperationParam.fromJson(wire),
        throwsA(_safe('LiveInputApplyPatchUpdateFileOperationParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputApplyPatchUpdateFileOperationParam.fromJson(wire),
        throwsA(_safe('LiveInputApplyPatchUpdateFileOperationParam')),
      );
    });
  });
  group('ApproximateLocation', () {
    final minimal = {'type': 'approximate'};
    final full = {
      'city': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'country': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'region': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'timezone': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'approximate',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputApproximateLocation.fromJson(_clone(wire));
        final peer = LiveInputApproximateLocation.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputApproximateLocation.fromJson(_clone(full));
      expect(_wire(model.city), (full as Map)['city'], reason: 'city');
      expect(model.hasCity, isTrue);
      expect(_wire(model.country), (full as Map)['country'], reason: 'country');
      expect(model.hasCountry, isTrue);
      expect(_wire(model.region), (full as Map)['region'], reason: 'region');
      expect(model.hasRegion, isTrue);
      expect(
        _wire(model.timezone),
        (full as Map)['timezone'],
        reason: 'timezone',
      );
      expect(model.hasTimezone, isTrue);
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputApproximateLocation.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('optional city omit/null/clear and copy ownership', () {
      final model = LiveInputApproximateLocation.fromJson(_clone(full));
      final omitted = model.copyWith(clearCity: true);
      expect(omitted.rawJson.containsKey('city'), isFalse);
      expect(omitted.hasCity, isFalse);
      expect(model.copyWith(city: model.city), model);
      final cleared = model.copyWith(city: null);
      expect(cleared.rawJson.containsKey('city'), isTrue);
      expect(cleared.toJson()['city'], isNull);
      expect(cleared.hasCity, isTrue);
    });
    test('known city wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['city'] = 5;
      expect(
        () => LiveInputApproximateLocation.fromJson(wire),
        throwsA(_safe('city')),
      );
      expect(
        () => LiveInputApproximateLocation.fromJson(
          _clone(full),
        ).copyWith(city: 5),
        throwsA(_safe('city')),
      );
    });
    test('optional country omit/null/clear and copy ownership', () {
      final model = LiveInputApproximateLocation.fromJson(_clone(full));
      final omitted = model.copyWith(clearCountry: true);
      expect(omitted.rawJson.containsKey('country'), isFalse);
      expect(omitted.hasCountry, isFalse);
      expect(model.copyWith(country: model.country), model);
      final cleared = model.copyWith(country: null);
      expect(cleared.rawJson.containsKey('country'), isTrue);
      expect(cleared.toJson()['country'], isNull);
      expect(cleared.hasCountry, isTrue);
    });
    test('known country wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['country'] = 5;
      expect(
        () => LiveInputApproximateLocation.fromJson(wire),
        throwsA(_safe('country')),
      );
      expect(
        () => LiveInputApproximateLocation.fromJson(
          _clone(full),
        ).copyWith(country: 5),
        throwsA(_safe('country')),
      );
    });
    test('optional region omit/null/clear and copy ownership', () {
      final model = LiveInputApproximateLocation.fromJson(_clone(full));
      final omitted = model.copyWith(clearRegion: true);
      expect(omitted.rawJson.containsKey('region'), isFalse);
      expect(omitted.hasRegion, isFalse);
      expect(model.copyWith(region: model.region), model);
      final cleared = model.copyWith(region: null);
      expect(cleared.rawJson.containsKey('region'), isTrue);
      expect(cleared.toJson()['region'], isNull);
      expect(cleared.hasRegion, isTrue);
    });
    test('known region wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['region'] = 5;
      expect(
        () => LiveInputApproximateLocation.fromJson(wire),
        throwsA(_safe('region')),
      );
      expect(
        () => LiveInputApproximateLocation.fromJson(
          _clone(full),
        ).copyWith(region: 5),
        throwsA(_safe('region')),
      );
    });
    test('optional timezone omit/null/clear and copy ownership', () {
      final model = LiveInputApproximateLocation.fromJson(_clone(full));
      final omitted = model.copyWith(clearTimezone: true);
      expect(omitted.rawJson.containsKey('timezone'), isFalse);
      expect(omitted.hasTimezone, isFalse);
      expect(model.copyWith(timezone: model.timezone), model);
      final cleared = model.copyWith(timezone: null);
      expect(cleared.rawJson.containsKey('timezone'), isTrue);
      expect(cleared.toJson()['timezone'], isNull);
      expect(cleared.hasTimezone, isTrue);
    });
    test('known timezone wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['timezone'] = 5;
      expect(
        () => LiveInputApproximateLocation.fromJson(wire),
        throwsA(_safe('timezone')),
      );
      expect(
        () => LiveInputApproximateLocation.fromJson(
          _clone(full),
        ).copyWith(timezone: 5),
        throwsA(_safe('timezone')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputApproximateLocation.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputApproximateLocation.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputApproximateLocation.fromJson(wire),
        throwsA(_safe('LiveInputApproximateLocation')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputApproximateLocation.fromJson(wire),
        throwsA(_safe('LiveInputApproximateLocation')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputApproximateLocation.fromJson(wire),
        throwsA(_safe('LiveInputApproximateLocation')),
      );
    });
  });
  group('AutoCodeInterpreterToolParam', () {
    final minimal = {'type': 'auto'};
    final full = {
      'file_ids': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
      'memory_limit': '1g',
      'network_policy': {'type': 'disabled'},
      'type': 'auto',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputAutoCodeInterpreterToolParam.fromJson(
          _clone(wire),
        );
        final peer = LiveInputAutoCodeInterpreterToolParam.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputAutoCodeInterpreterToolParam.fromJson(
        _clone(full),
      );
      expect(
        _wire(model.fileIds),
        (full as Map)['file_ids'],
        reason: 'file_ids',
      );
      expect(model.hasFileIds, isTrue);
      expect(
        _wire(model.memoryLimit),
        (full as Map)['memory_limit'],
        reason: 'memory_limit',
      );
      expect(model.hasMemoryLimit, isTrue);
      expect(
        _wire(model.networkPolicy),
        (full as Map)['network_policy'],
        reason: 'network_policy',
      );
      expect(model.hasNetworkPolicy, isTrue);
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputAutoCodeInterpreterToolParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('optional file_ids omit/null/clear and copy ownership', () {
      final model = LiveInputAutoCodeInterpreterToolParam.fromJson(
        _clone(full),
      );
      final omitted = model.copyWith(clearFileIds: true);
      expect(omitted.rawJson.containsKey('file_ids'), isFalse);
      expect(omitted.hasFileIds, isFalse);
      expect(model.copyWith(fileIds: model.fileIds), model);
      expect(() => model.copyWith(fileIds: null), throwsA(_safe('file_ids')));
    });
    test('known file_ids wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['file_ids'] = 5;
      expect(
        () => LiveInputAutoCodeInterpreterToolParam.fromJson(wire),
        throwsA(_safe('file_ids')),
      );
      expect(
        () => LiveInputAutoCodeInterpreterToolParam.fromJson(
          _clone(full),
        ).copyWith(fileIds: 5),
        throwsA(_safe('file_ids')),
      );
    });
    test('optional memory_limit omit/null/clear and copy ownership', () {
      final model = LiveInputAutoCodeInterpreterToolParam.fromJson(
        _clone(full),
      );
      final omitted = model.copyWith(clearMemoryLimit: true);
      expect(omitted.rawJson.containsKey('memory_limit'), isFalse);
      expect(omitted.hasMemoryLimit, isFalse);
      expect(model.copyWith(memoryLimit: model.memoryLimit), model);
      final cleared = model.copyWith(memoryLimit: null);
      expect(cleared.rawJson.containsKey('memory_limit'), isTrue);
      expect(cleared.toJson()['memory_limit'], isNull);
      expect(cleared.hasMemoryLimit, isTrue);
    });
    test('known memory_limit wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['memory_limit'] = 5;
      expect(
        () => LiveInputAutoCodeInterpreterToolParam.fromJson(wire),
        throwsA(_safe('memory_limit')),
      );
      expect(
        () => LiveInputAutoCodeInterpreterToolParam.fromJson(
          _clone(full),
        ).copyWith(memoryLimit: 5),
        throwsA(_safe('memory_limit')),
      );
    });
    test('optional network_policy omit/null/clear and copy ownership', () {
      final model = LiveInputAutoCodeInterpreterToolParam.fromJson(
        _clone(full),
      );
      final omitted = model.copyWith(clearNetworkPolicy: true);
      expect(omitted.rawJson.containsKey('network_policy'), isFalse);
      expect(omitted.hasNetworkPolicy, isFalse);
      expect(model.copyWith(networkPolicy: model.networkPolicy), model);
      expect(
        () => model.copyWith(networkPolicy: null),
        throwsA(_safe('network_policy')),
      );
    });
    test('known network_policy wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['network_policy'] = 5;
      expect(
        () => LiveInputAutoCodeInterpreterToolParam.fromJson(wire),
        throwsA(_safe('network_policy')),
      );
      expect(
        () => LiveInputAutoCodeInterpreterToolParam.fromJson(
          _clone(full),
        ).copyWith(networkPolicy: 5),
        throwsA(_safe('network_policy')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputAutoCodeInterpreterToolParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputAutoCodeInterpreterToolParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputAutoCodeInterpreterToolParam.fromJson(wire),
        throwsA(_safe('LiveInputAutoCodeInterpreterToolParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputAutoCodeInterpreterToolParam.fromJson(wire),
        throwsA(_safe('LiveInputAutoCodeInterpreterToolParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputAutoCodeInterpreterToolParam.fromJson(wire),
        throwsA(_safe('LiveInputAutoCodeInterpreterToolParam')),
      );
    });
  });
  group('CallableToolAllowedCaller', () {
    const minimal = 'direct';
    const full = 'direct';
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputCallableToolAllowedCaller.fromJson(_clone(wire));
        final peer = LiveInputCallableToolAllowedCaller.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('value copy and JSON ownership', () {
      final model = LiveInputCallableToolAllowedCaller.fromJson(_clone(full));
      expect(_wire(model.value), full);
      expect(model.copyWith(value: _clone(full)), model);
    });
  });
  group('ClickButtonType', () {
    const minimal = 'left';
    const full = 'left';
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputClickButtonType.fromJson(_clone(wire));
        final peer = LiveInputClickButtonType.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('value copy and JSON ownership', () {
      final model = LiveInputClickButtonType.fromJson(_clone(full));
      expect(_wire(model.value), full);
      expect(model.copyWith(value: _clone(full)), model);
    });
  });
  group('ClickParam', () {
    final minimal = {'type': 'click', 'button': 'left', 'x': 0, 'y': 0};
    final full = {
      'button': 'left',
      'keys': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
      'type': 'click',
      'x': 0,
      'y': 0,
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputClickParam.fromJson(_clone(wire));
        final peer = LiveInputClickParam.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputClickParam.fromJson(_clone(full));
      expect(_wire(model.button), (full as Map)['button'], reason: 'button');
      expect(_wire(model.keys), (full as Map)['keys'], reason: 'keys');
      expect(model.hasKeys, isTrue);
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
      expect(_wire(model.x), (full as Map)['x'], reason: 'x');
      expect(_wire(model.y), (full as Map)['y'], reason: 'y');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputClickParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required button absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('button');
      expect(
        () => LiveInputClickParam.fromJson(wire),
        throwsA(_safe('button')),
      );
    });
    test('known button wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['button'] = 5;
      expect(
        () => LiveInputClickParam.fromJson(wire),
        throwsA(_safe('button')),
      );
      expect(
        () => LiveInputClickParam.fromJson(_clone(full)).copyWith(button: 5),
        throwsA(_safe('button')),
      );
    });
    test('optional keys omit/null/clear and copy ownership', () {
      final model = LiveInputClickParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearKeys: true);
      expect(omitted.rawJson.containsKey('keys'), isFalse);
      expect(omitted.hasKeys, isFalse);
      expect(model.copyWith(keys: model.keys), model);
      final cleared = model.copyWith(keys: null);
      expect(cleared.rawJson.containsKey('keys'), isTrue);
      expect(cleared.toJson()['keys'], isNull);
      expect(cleared.hasKeys, isTrue);
    });
    test('known keys wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['keys'] = 5;
      expect(() => LiveInputClickParam.fromJson(wire), throwsA(_safe('keys')));
      expect(
        () => LiveInputClickParam.fromJson(_clone(full)).copyWith(keys: 5),
        throwsA(_safe('keys')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(() => LiveInputClickParam.fromJson(wire), throwsA(_safe('type')));
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(() => LiveInputClickParam.fromJson(wire), throwsA(_safe('type')));
    });
    test('required x absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)..remove('x');
      expect(() => LiveInputClickParam.fromJson(wire), throwsA(_safe('x')));
    });
    test('known x wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['x'] = false;
      expect(() => LiveInputClickParam.fromJson(wire), throwsA(_safe('x')));
      expect(
        () => LiveInputClickParam.fromJson(_clone(full)).copyWith(x: false),
        throwsA(_safe('x')),
      );
    });
    test('required y absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)..remove('y');
      expect(() => LiveInputClickParam.fromJson(wire), throwsA(_safe('y')));
    });
    test('known y wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['y'] = false;
      expect(() => LiveInputClickParam.fromJson(wire), throwsA(_safe('y')));
      expect(
        () => LiveInputClickParam.fromJson(_clone(full)).copyWith(y: false),
        throwsA(_safe('y')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputClickParam.fromJson(wire),
        throwsA(_safe('LiveInputClickParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputClickParam.fromJson(wire),
        throwsA(_safe('LiveInputClickParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputClickParam.fromJson(wire),
        throwsA(_safe('LiveInputClickParam')),
      );
    });
  });
  group('CodeInterpreterOutputImage', () {
    final minimal = {'type': 'image', 'url': 'PRIVATE_LIVE_INPUT_PAYLOAD'};
    final full = {'type': 'image', 'url': 'PRIVATE_LIVE_INPUT_PAYLOAD'};
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputCodeInterpreterOutputImage.fromJson(
          _clone(wire),
        );
        final peer = LiveInputCodeInterpreterOutputImage.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputCodeInterpreterOutputImage.fromJson(_clone(full));
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
      expect(_wire(model.url), (full as Map)['url'], reason: 'url');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputCodeInterpreterOutputImage.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputCodeInterpreterOutputImage.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputCodeInterpreterOutputImage.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('required url absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('url');
      expect(
        () => LiveInputCodeInterpreterOutputImage.fromJson(wire),
        throwsA(_safe('url')),
      );
    });
    test('known url wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['url'] = 5;
      expect(
        () => LiveInputCodeInterpreterOutputImage.fromJson(wire),
        throwsA(_safe('url')),
      );
      expect(
        () => LiveInputCodeInterpreterOutputImage.fromJson(
          _clone(full),
        ).copyWith(url: 5),
        throwsA(_safe('url')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputCodeInterpreterOutputImage.fromJson(wire),
        throwsA(_safe('LiveInputCodeInterpreterOutputImage')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputCodeInterpreterOutputImage.fromJson(wire),
        throwsA(_safe('LiveInputCodeInterpreterOutputImage')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputCodeInterpreterOutputImage.fromJson(wire),
        throwsA(_safe('LiveInputCodeInterpreterOutputImage')),
      );
    });
  });
  group('CodeInterpreterOutputLogs', () {
    final minimal = {'type': 'logs', 'logs': 'PRIVATE_LIVE_INPUT_PAYLOAD'};
    final full = {'logs': 'PRIVATE_LIVE_INPUT_PAYLOAD', 'type': 'logs'};
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputCodeInterpreterOutputLogs.fromJson(_clone(wire));
        final peer = LiveInputCodeInterpreterOutputLogs.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputCodeInterpreterOutputLogs.fromJson(_clone(full));
      expect(_wire(model.logs), (full as Map)['logs'], reason: 'logs');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputCodeInterpreterOutputLogs.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required logs absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('logs');
      expect(
        () => LiveInputCodeInterpreterOutputLogs.fromJson(wire),
        throwsA(_safe('logs')),
      );
    });
    test('known logs wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['logs'] = 5;
      expect(
        () => LiveInputCodeInterpreterOutputLogs.fromJson(wire),
        throwsA(_safe('logs')),
      );
      expect(
        () => LiveInputCodeInterpreterOutputLogs.fromJson(
          _clone(full),
        ).copyWith(logs: 5),
        throwsA(_safe('logs')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputCodeInterpreterOutputLogs.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputCodeInterpreterOutputLogs.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputCodeInterpreterOutputLogs.fromJson(wire),
        throwsA(_safe('LiveInputCodeInterpreterOutputLogs')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputCodeInterpreterOutputLogs.fromJson(wire),
        throwsA(_safe('LiveInputCodeInterpreterOutputLogs')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputCodeInterpreterOutputLogs.fromJson(wire),
        throwsA(_safe('LiveInputCodeInterpreterOutputLogs')),
      );
    });
  });
  group('CodeInterpreterTool', () {
    final minimal = {
      'type': 'code_interpreter',
      'container': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    final full = {
      'allowed_callers': ['direct'],
      'container': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'code_interpreter',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputCodeInterpreterTool.fromJson(_clone(wire));
        final peer = LiveInputCodeInterpreterTool.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputCodeInterpreterTool.fromJson(_clone(full));
      expect(
        _wire(model.allowedCallers),
        (full as Map)['allowed_callers'],
        reason: 'allowed_callers',
      );
      expect(model.hasAllowedCallers, isTrue);
      expect(
        _wire(model.container),
        (full as Map)['container'],
        reason: 'container',
      );
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputCodeInterpreterTool.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('optional allowed_callers omit/null/clear and copy ownership', () {
      final model = LiveInputCodeInterpreterTool.fromJson(_clone(full));
      final omitted = model.copyWith(clearAllowedCallers: true);
      expect(omitted.rawJson.containsKey('allowed_callers'), isFalse);
      expect(omitted.hasAllowedCallers, isFalse);
      expect(model.copyWith(allowedCallers: model.allowedCallers), model);
      final cleared = model.copyWith(allowedCallers: null);
      expect(cleared.rawJson.containsKey('allowed_callers'), isTrue);
      expect(cleared.toJson()['allowed_callers'], isNull);
      expect(cleared.hasAllowedCallers, isTrue);
    });
    test('known allowed_callers wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['allowed_callers'] = 5;
      expect(
        () => LiveInputCodeInterpreterTool.fromJson(wire),
        throwsA(_safe('allowed_callers')),
      );
      expect(
        () => LiveInputCodeInterpreterTool.fromJson(
          _clone(full),
        ).copyWith(allowedCallers: 5),
        throwsA(_safe('allowed_callers')),
      );
    });
    test('required container absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('container');
      expect(
        () => LiveInputCodeInterpreterTool.fromJson(wire),
        throwsA(_safe('container')),
      );
    });
    test('known container wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['container'] = 5;
      expect(
        () => LiveInputCodeInterpreterTool.fromJson(wire),
        throwsA(_safe('container')),
      );
      expect(
        () => LiveInputCodeInterpreterTool.fromJson(
          _clone(full),
        ).copyWith(container: 5),
        throwsA(_safe('container')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputCodeInterpreterTool.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputCodeInterpreterTool.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputCodeInterpreterTool.fromJson(wire),
        throwsA(_safe('LiveInputCodeInterpreterTool')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputCodeInterpreterTool.fromJson(wire),
        throwsA(_safe('LiveInputCodeInterpreterTool')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputCodeInterpreterTool.fromJson(wire),
        throwsA(_safe('LiveInputCodeInterpreterTool')),
      );
    });
  });
  group('CodeInterpreterToolCall', () {
    final minimal = {
      'type': 'code_interpreter_call',
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'status': 'in_progress',
      'container_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'code': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'outputs': <dynamic>[],
    };
    final full = {
      'code': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'container_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'outputs': [
        {'logs': 'PRIVATE_LIVE_INPUT_PAYLOAD', 'type': 'logs'},
      ],
      'status': 'in_progress',
      'type': 'code_interpreter_call',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputCodeInterpreterToolCall.fromJson(_clone(wire));
        final peer = LiveInputCodeInterpreterToolCall.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputCodeInterpreterToolCall.fromJson(_clone(full));
      expect(_wire(model.code), (full as Map)['code'], reason: 'code');
      expect(
        _wire(model.containerId),
        (full as Map)['container_id'],
        reason: 'container_id',
      );
      expect(_wire(model.id), (full as Map)['id'], reason: 'id');
      expect(_wire(model.outputs), (full as Map)['outputs'], reason: 'outputs');
      expect(_wire(model.status), (full as Map)['status'], reason: 'status');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputCodeInterpreterToolCall.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required code absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('code');
      expect(
        () => LiveInputCodeInterpreterToolCall.fromJson(wire),
        throwsA(_safe('code')),
      );
    });
    test('known code wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['code'] = 5;
      expect(
        () => LiveInputCodeInterpreterToolCall.fromJson(wire),
        throwsA(_safe('code')),
      );
      expect(
        () => LiveInputCodeInterpreterToolCall.fromJson(
          _clone(full),
        ).copyWith(code: 5),
        throwsA(_safe('code')),
      );
    });
    test('required container_id absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('container_id');
      expect(
        () => LiveInputCodeInterpreterToolCall.fromJson(wire),
        throwsA(_safe('container_id')),
      );
    });
    test('known container_id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['container_id'] = 5;
      expect(
        () => LiveInputCodeInterpreterToolCall.fromJson(wire),
        throwsA(_safe('container_id')),
      );
      expect(
        () => LiveInputCodeInterpreterToolCall.fromJson(
          _clone(full),
        ).copyWith(containerId: 5),
        throwsA(_safe('container_id')),
      );
    });
    test('required id absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('id');
      expect(
        () => LiveInputCodeInterpreterToolCall.fromJson(wire),
        throwsA(_safe('id')),
      );
    });
    test('known id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['id'] = 5;
      expect(
        () => LiveInputCodeInterpreterToolCall.fromJson(wire),
        throwsA(_safe('id')),
      );
      expect(
        () => LiveInputCodeInterpreterToolCall.fromJson(
          _clone(full),
        ).copyWith(id: 5),
        throwsA(_safe('id')),
      );
    });
    test('required outputs absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('outputs');
      expect(
        () => LiveInputCodeInterpreterToolCall.fromJson(wire),
        throwsA(_safe('outputs')),
      );
    });
    test('known outputs wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['outputs'] = 5;
      expect(
        () => LiveInputCodeInterpreterToolCall.fromJson(wire),
        throwsA(_safe('outputs')),
      );
      expect(
        () => LiveInputCodeInterpreterToolCall.fromJson(
          _clone(full),
        ).copyWith(outputs: 5),
        throwsA(_safe('outputs')),
      );
    });
    test('required status absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('status');
      expect(
        () => LiveInputCodeInterpreterToolCall.fromJson(wire),
        throwsA(_safe('status')),
      );
    });
    test('known status wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['status'] = 5;
      expect(
        () => LiveInputCodeInterpreterToolCall.fromJson(wire),
        throwsA(_safe('status')),
      );
      expect(
        () => LiveInputCodeInterpreterToolCall.fromJson(
          _clone(full),
        ).copyWith(status: 5),
        throwsA(_safe('status')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputCodeInterpreterToolCall.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputCodeInterpreterToolCall.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputCodeInterpreterToolCall.fromJson(wire),
        throwsA(_safe('LiveInputCodeInterpreterToolCall')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputCodeInterpreterToolCall.fromJson(wire),
        throwsA(_safe('LiveInputCodeInterpreterToolCall')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputCodeInterpreterToolCall.fromJson(wire),
        throwsA(_safe('LiveInputCodeInterpreterToolCall')),
      );
    });
  });
  group('CompactionSummaryItemParam', () {
    final minimal = {
      'type': 'compaction',
      'encrypted_content': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    final full = {
      'encrypted_content': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'compaction',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputCompactionSummaryItemParam.fromJson(
          _clone(wire),
        );
        final peer = LiveInputCompactionSummaryItemParam.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputCompactionSummaryItemParam.fromJson(_clone(full));
      expect(
        _wire(model.encryptedContent),
        (full as Map)['encrypted_content'],
        reason: 'encrypted_content',
      );
      expect(_wire(model.id), (full as Map)['id'], reason: 'id');
      expect(model.hasId, isTrue);
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputCompactionSummaryItemParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required encrypted_content absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('encrypted_content');
      expect(
        () => LiveInputCompactionSummaryItemParam.fromJson(wire),
        throwsA(_safe('encrypted_content')),
      );
    });
    test('known encrypted_content wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['encrypted_content'] = 5;
      expect(
        () => LiveInputCompactionSummaryItemParam.fromJson(wire),
        throwsA(_safe('encrypted_content')),
      );
      expect(
        () => LiveInputCompactionSummaryItemParam.fromJson(
          _clone(full),
        ).copyWith(encryptedContent: 5),
        throwsA(_safe('encrypted_content')),
      );
    });
    test('optional id omit/null/clear and copy ownership', () {
      final model = LiveInputCompactionSummaryItemParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearId: true);
      expect(omitted.rawJson.containsKey('id'), isFalse);
      expect(omitted.hasId, isFalse);
      expect(model.copyWith(id: model.id), model);
      final cleared = model.copyWith(id: null);
      expect(cleared.rawJson.containsKey('id'), isTrue);
      expect(cleared.toJson()['id'], isNull);
      expect(cleared.hasId, isTrue);
    });
    test('known id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['id'] = 5;
      expect(
        () => LiveInputCompactionSummaryItemParam.fromJson(wire),
        throwsA(_safe('id')),
      );
      expect(
        () => LiveInputCompactionSummaryItemParam.fromJson(
          _clone(full),
        ).copyWith(id: 5),
        throwsA(_safe('id')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputCompactionSummaryItemParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputCompactionSummaryItemParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputCompactionSummaryItemParam.fromJson(wire),
        throwsA(_safe('LiveInputCompactionSummaryItemParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputCompactionSummaryItemParam.fromJson(wire),
        throwsA(_safe('LiveInputCompactionSummaryItemParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputCompactionSummaryItemParam.fromJson(wire),
        throwsA(_safe('LiveInputCompactionSummaryItemParam')),
      );
    });
  });
  group('CompactionTriggerItemParam', () {
    final minimal = {'type': 'compaction_trigger'};
    final full = {
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'compaction_trigger',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputCompactionTriggerItemParam.fromJson(
          _clone(wire),
        );
        final peer = LiveInputCompactionTriggerItemParam.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputCompactionTriggerItemParam.fromJson(_clone(full));
      expect(_wire(model.id), (full as Map)['id'], reason: 'id');
      expect(model.hasId, isTrue);
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputCompactionTriggerItemParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('optional id omit/null/clear and copy ownership', () {
      final model = LiveInputCompactionTriggerItemParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearId: true);
      expect(omitted.rawJson.containsKey('id'), isFalse);
      expect(omitted.hasId, isFalse);
      expect(model.copyWith(id: model.id), model);
      final cleared = model.copyWith(id: null);
      expect(cleared.rawJson.containsKey('id'), isTrue);
      expect(cleared.toJson()['id'], isNull);
      expect(cleared.hasId, isTrue);
    });
    test('known id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['id'] = 5;
      expect(
        () => LiveInputCompactionTriggerItemParam.fromJson(wire),
        throwsA(_safe('id')),
      );
      expect(
        () => LiveInputCompactionTriggerItemParam.fromJson(
          _clone(full),
        ).copyWith(id: 5),
        throwsA(_safe('id')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputCompactionTriggerItemParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputCompactionTriggerItemParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputCompactionTriggerItemParam.fromJson(wire),
        throwsA(_safe('LiveInputCompactionTriggerItemParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputCompactionTriggerItemParam.fromJson(wire),
        throwsA(_safe('LiveInputCompactionTriggerItemParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputCompactionTriggerItemParam.fromJson(wire),
        throwsA(_safe('LiveInputCompactionTriggerItemParam')),
      );
    });
  });
  group('ComparisonFilter', () {
    final minimal = {
      'type': 'eq',
      'key': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'value': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    final full = {
      'key': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'eq',
      'value': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputComparisonFilter.fromJson(_clone(wire));
        final peer = LiveInputComparisonFilter.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputComparisonFilter.fromJson(_clone(full));
      expect(_wire(model.key), (full as Map)['key'], reason: 'key');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
      expect(_wire(model.value), (full as Map)['value'], reason: 'value');
    });
    test('closed canonical metadata and immutable snapshot', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      final model = LiveInputComparisonFilter.fromJson(source);
      source.clear();
      expect(model.toJson(), full);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => LiveInputComparisonFilter.fromJson({
          ...(full as Map),
          _private: true,
        }),
        throwsA(_safe('LiveInputComparisonFilter')),
      );
    });
    test('required key absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('key');
      expect(
        () => LiveInputComparisonFilter.fromJson(wire),
        throwsA(_safe('key')),
      );
    });
    test('known key wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['key'] = 5;
      expect(
        () => LiveInputComparisonFilter.fromJson(wire),
        throwsA(_safe('key')),
      );
      expect(
        () => LiveInputComparisonFilter.fromJson(_clone(full)).copyWith(key: 5),
        throwsA(_safe('key')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputComparisonFilter.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputComparisonFilter.fromJson(wire),
        throwsA(_safe('type')),
      );
      expect(
        () =>
            LiveInputComparisonFilter.fromJson(_clone(full)).copyWith(type: 5),
        throwsA(_safe('type')),
      );
    });
    test('required value absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('value');
      expect(
        () => LiveInputComparisonFilter.fromJson(wire),
        throwsA(_safe('value')),
      );
    });
    test('known value wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['value'] = <String, dynamic>{};
      expect(
        () => LiveInputComparisonFilter.fromJson(wire),
        throwsA(_safe('value')),
      );
      expect(
        () => LiveInputComparisonFilter.fromJson(
          _clone(full),
        ).copyWith(value: {}),
        throwsA(_safe('value')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputComparisonFilter.fromJson(wire),
        throwsA(_safe('LiveInputComparisonFilter')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputComparisonFilter.fromJson(wire),
        throwsA(_safe('LiveInputComparisonFilter')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputComparisonFilter.fromJson(wire),
        throwsA(_safe('LiveInputComparisonFilter')),
      );
    });
  });
  group('CompoundFilter', () {
    final minimal = {'type': 'and', 'filters': <dynamic>[]};
    final full = {
      'filters': [
        {
          'key': 'PRIVATE_LIVE_INPUT_PAYLOAD',
          'type': 'eq',
          'value': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        },
      ],
      'type': 'and',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputCompoundFilter.fromJson(_clone(wire));
        final peer = LiveInputCompoundFilter.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputCompoundFilter.fromJson(_clone(full));
      expect(_wire(model.filters), (full as Map)['filters'], reason: 'filters');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('closed canonical metadata and immutable snapshot', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      final model = LiveInputCompoundFilter.fromJson(source);
      source.clear();
      expect(model.toJson(), full);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => LiveInputCompoundFilter.fromJson({
          ...(full as Map),
          _private: true,
        }),
        throwsA(_safe('LiveInputCompoundFilter')),
      );
    });
    test('required filters absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('filters');
      expect(
        () => LiveInputCompoundFilter.fromJson(wire),
        throwsA(_safe('filters')),
      );
    });
    test('known filters wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['filters'] = 5;
      expect(
        () => LiveInputCompoundFilter.fromJson(wire),
        throwsA(_safe('filters')),
      );
      expect(
        () =>
            LiveInputCompoundFilter.fromJson(_clone(full)).copyWith(filters: 5),
        throwsA(_safe('filters')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputCompoundFilter.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputCompoundFilter.fromJson(wire),
        throwsA(_safe('type')),
      );
      expect(
        () => LiveInputCompoundFilter.fromJson(_clone(full)).copyWith(type: 5),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputCompoundFilter.fromJson(wire),
        throwsA(_safe('LiveInputCompoundFilter')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputCompoundFilter.fromJson(wire),
        throwsA(_safe('LiveInputCompoundFilter')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputCompoundFilter.fromJson(wire),
        throwsA(_safe('LiveInputCompoundFilter')),
      );
    });
  });
  group('ComputerAction', () {
    final minimal = {'type': 'click', 'button': 'left', 'x': 0, 'y': 0};
    final full = {
      'button': 'left',
      'keys': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
      'type': 'click',
      'x': 0,
      'y': 0,
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputComputerAction.fromJson(_clone(wire));
        final peer = LiveInputComputerAction.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
  });
  group('ComputerActionList', () {
    final minimal = <dynamic>[];
    final full = [
      {
        'button': 'left',
        'keys': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
        'type': 'click',
        'x': 0,
        'y': 0,
      },
    ];
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputComputerActionList.fromJson(_clone(wire));
        final peer = LiveInputComputerActionList.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('value copy and JSON ownership', () {
      final model = LiveInputComputerActionList.fromJson(_clone(full));
      expect(_wire(model.value), full);
      expect(model.copyWith(value: _clone(full)), model);
    });
  });
  group('ComputerCallOutputItemParam', () {
    final minimal = {
      'call_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'computer_call_output',
      'output': {'type': 'computer_screenshot'},
    };
    final full = {
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
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputComputerCallOutputItemParam.fromJson(
          _clone(wire),
        );
        final peer = LiveInputComputerCallOutputItemParam.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputComputerCallOutputItemParam.fromJson(_clone(full));
      expect(
        _wire(model.acknowledgedSafetyChecks),
        (full as Map)['acknowledged_safety_checks'],
        reason: 'acknowledged_safety_checks',
      );
      expect(model.hasAcknowledgedSafetyChecks, isTrue);
      expect(_wire(model.callId), (full as Map)['call_id'], reason: 'call_id');
      expect(_wire(model.id), (full as Map)['id'], reason: 'id');
      expect(model.hasId, isTrue);
      expect(_wire(model.output), (full as Map)['output'], reason: 'output');
      expect(_wire(model.status), (full as Map)['status'], reason: 'status');
      expect(model.hasStatus, isTrue);
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputComputerCallOutputItemParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test(
      'optional acknowledged_safety_checks omit/null/clear and copy ownership',
      () {
        final model = LiveInputComputerCallOutputItemParam.fromJson(
          _clone(full),
        );
        final omitted = model.copyWith(clearAcknowledgedSafetyChecks: true);
        expect(
          omitted.rawJson.containsKey('acknowledged_safety_checks'),
          isFalse,
        );
        expect(omitted.hasAcknowledgedSafetyChecks, isFalse);
        expect(
          model.copyWith(
            acknowledgedSafetyChecks: model.acknowledgedSafetyChecks,
          ),
          model,
        );
        final cleared = model.copyWith(acknowledgedSafetyChecks: null);
        expect(
          cleared.rawJson.containsKey('acknowledged_safety_checks'),
          isTrue,
        );
        expect(cleared.toJson()['acknowledged_safety_checks'], isNull);
        expect(cleared.hasAcknowledgedSafetyChecks, isTrue);
      },
    );
    test(
      'known acknowledged_safety_checks wrong value cannot become overflow',
      () {
        final wire = Map<String, dynamic>.from(_clone(full)! as Map);
        wire['acknowledged_safety_checks'] = 5;
        expect(
          () => LiveInputComputerCallOutputItemParam.fromJson(wire),
          throwsA(_safe('acknowledged_safety_checks')),
        );
        expect(
          () => LiveInputComputerCallOutputItemParam.fromJson(
            _clone(full),
          ).copyWith(acknowledgedSafetyChecks: 5),
          throwsA(_safe('acknowledged_safety_checks')),
        );
      },
    );
    test('required call_id absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('call_id');
      expect(
        () => LiveInputComputerCallOutputItemParam.fromJson(wire),
        throwsA(_safe('call_id')),
      );
    });
    test('known call_id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['call_id'] = 5;
      expect(
        () => LiveInputComputerCallOutputItemParam.fromJson(wire),
        throwsA(_safe('call_id')),
      );
      expect(
        () => LiveInputComputerCallOutputItemParam.fromJson(
          _clone(full),
        ).copyWith(callId: 5),
        throwsA(_safe('call_id')),
      );
    });
    test('optional id omit/null/clear and copy ownership', () {
      final model = LiveInputComputerCallOutputItemParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearId: true);
      expect(omitted.rawJson.containsKey('id'), isFalse);
      expect(omitted.hasId, isFalse);
      expect(model.copyWith(id: model.id), model);
      final cleared = model.copyWith(id: null);
      expect(cleared.rawJson.containsKey('id'), isTrue);
      expect(cleared.toJson()['id'], isNull);
      expect(cleared.hasId, isTrue);
    });
    test('known id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['id'] = 5;
      expect(
        () => LiveInputComputerCallOutputItemParam.fromJson(wire),
        throwsA(_safe('id')),
      );
      expect(
        () => LiveInputComputerCallOutputItemParam.fromJson(
          _clone(full),
        ).copyWith(id: 5),
        throwsA(_safe('id')),
      );
    });
    test('required output absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('output');
      expect(
        () => LiveInputComputerCallOutputItemParam.fromJson(wire),
        throwsA(_safe('output')),
      );
    });
    test('known output wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['output'] = 5;
      expect(
        () => LiveInputComputerCallOutputItemParam.fromJson(wire),
        throwsA(_safe('output')),
      );
      expect(
        () => LiveInputComputerCallOutputItemParam.fromJson(
          _clone(full),
        ).copyWith(output: 5),
        throwsA(_safe('output')),
      );
    });
    test('optional status omit/null/clear and copy ownership', () {
      final model = LiveInputComputerCallOutputItemParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearStatus: true);
      expect(omitted.rawJson.containsKey('status'), isFalse);
      expect(omitted.hasStatus, isFalse);
      expect(model.copyWith(status: model.status), model);
      final cleared = model.copyWith(status: null);
      expect(cleared.rawJson.containsKey('status'), isTrue);
      expect(cleared.toJson()['status'], isNull);
      expect(cleared.hasStatus, isTrue);
    });
    test('known status wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['status'] = 5;
      expect(
        () => LiveInputComputerCallOutputItemParam.fromJson(wire),
        throwsA(_safe('status')),
      );
      expect(
        () => LiveInputComputerCallOutputItemParam.fromJson(
          _clone(full),
        ).copyWith(status: 5),
        throwsA(_safe('status')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputComputerCallOutputItemParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputComputerCallOutputItemParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputComputerCallOutputItemParam.fromJson(wire),
        throwsA(_safe('LiveInputComputerCallOutputItemParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputComputerCallOutputItemParam.fromJson(wire),
        throwsA(_safe('LiveInputComputerCallOutputItemParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputComputerCallOutputItemParam.fromJson(wire),
        throwsA(_safe('LiveInputComputerCallOutputItemParam')),
      );
    });
  });
  group('ComputerCallSafetyCheckParam', () {
    final minimal = {'id': 'PRIVATE_LIVE_INPUT_PAYLOAD'};
    final full = {
      'code': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'message': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputComputerCallSafetyCheckParam.fromJson(
          _clone(wire),
        );
        final peer = LiveInputComputerCallSafetyCheckParam.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputComputerCallSafetyCheckParam.fromJson(
        _clone(full),
      );
      expect(_wire(model.code), (full as Map)['code'], reason: 'code');
      expect(model.hasCode, isTrue);
      expect(_wire(model.id), (full as Map)['id'], reason: 'id');
      expect(_wire(model.message), (full as Map)['message'], reason: 'message');
      expect(model.hasMessage, isTrue);
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputComputerCallSafetyCheckParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('optional code omit/null/clear and copy ownership', () {
      final model = LiveInputComputerCallSafetyCheckParam.fromJson(
        _clone(full),
      );
      final omitted = model.copyWith(clearCode: true);
      expect(omitted.rawJson.containsKey('code'), isFalse);
      expect(omitted.hasCode, isFalse);
      expect(model.copyWith(code: model.code), model);
      final cleared = model.copyWith(code: null);
      expect(cleared.rawJson.containsKey('code'), isTrue);
      expect(cleared.toJson()['code'], isNull);
      expect(cleared.hasCode, isTrue);
    });
    test('known code wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['code'] = 5;
      expect(
        () => LiveInputComputerCallSafetyCheckParam.fromJson(wire),
        throwsA(_safe('code')),
      );
      expect(
        () => LiveInputComputerCallSafetyCheckParam.fromJson(
          _clone(full),
        ).copyWith(code: 5),
        throwsA(_safe('code')),
      );
    });
    test('required id absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('id');
      expect(
        () => LiveInputComputerCallSafetyCheckParam.fromJson(wire),
        throwsA(_safe('id')),
      );
    });
    test('known id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['id'] = 5;
      expect(
        () => LiveInputComputerCallSafetyCheckParam.fromJson(wire),
        throwsA(_safe('id')),
      );
      expect(
        () => LiveInputComputerCallSafetyCheckParam.fromJson(
          _clone(full),
        ).copyWith(id: 5),
        throwsA(_safe('id')),
      );
    });
    test('optional message omit/null/clear and copy ownership', () {
      final model = LiveInputComputerCallSafetyCheckParam.fromJson(
        _clone(full),
      );
      final omitted = model.copyWith(clearMessage: true);
      expect(omitted.rawJson.containsKey('message'), isFalse);
      expect(omitted.hasMessage, isFalse);
      expect(model.copyWith(message: model.message), model);
      final cleared = model.copyWith(message: null);
      expect(cleared.rawJson.containsKey('message'), isTrue);
      expect(cleared.toJson()['message'], isNull);
      expect(cleared.hasMessage, isTrue);
    });
    test('known message wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['message'] = 5;
      expect(
        () => LiveInputComputerCallSafetyCheckParam.fromJson(wire),
        throwsA(_safe('message')),
      );
      expect(
        () => LiveInputComputerCallSafetyCheckParam.fromJson(
          _clone(full),
        ).copyWith(message: 5),
        throwsA(_safe('message')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputComputerCallSafetyCheckParam.fromJson(wire),
        throwsA(_safe('LiveInputComputerCallSafetyCheckParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputComputerCallSafetyCheckParam.fromJson(wire),
        throwsA(_safe('LiveInputComputerCallSafetyCheckParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputComputerCallSafetyCheckParam.fromJson(wire),
        throwsA(_safe('LiveInputComputerCallSafetyCheckParam')),
      );
    });
  });
  group('ComputerEnvironment', () {
    const minimal = 'windows';
    const full = 'windows';
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputComputerEnvironment.fromJson(_clone(wire));
        final peer = LiveInputComputerEnvironment.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('value copy and JSON ownership', () {
      final model = LiveInputComputerEnvironment.fromJson(_clone(full));
      expect(_wire(model.value), full);
      expect(model.copyWith(value: _clone(full)), model);
    });
  });
  group('ComputerScreenshotImage', () {
    final minimal = {'type': 'computer_screenshot'};
    final full = {
      'file_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'image_url': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'computer_screenshot',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputComputerScreenshotImage.fromJson(_clone(wire));
        final peer = LiveInputComputerScreenshotImage.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputComputerScreenshotImage.fromJson(_clone(full));
      expect(_wire(model.fileId), (full as Map)['file_id'], reason: 'file_id');
      expect(model.hasFileId, isTrue);
      expect(
        _wire(model.imageUrl),
        (full as Map)['image_url'],
        reason: 'image_url',
      );
      expect(model.hasImageUrl, isTrue);
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputComputerScreenshotImage.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('optional file_id omit/null/clear and copy ownership', () {
      final model = LiveInputComputerScreenshotImage.fromJson(_clone(full));
      final omitted = model.copyWith(clearFileId: true);
      expect(omitted.rawJson.containsKey('file_id'), isFalse);
      expect(omitted.hasFileId, isFalse);
      expect(model.copyWith(fileId: model.fileId), model);
      expect(() => model.copyWith(fileId: null), throwsA(_safe('file_id')));
    });
    test('known file_id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['file_id'] = 5;
      expect(
        () => LiveInputComputerScreenshotImage.fromJson(wire),
        throwsA(_safe('file_id')),
      );
      expect(
        () => LiveInputComputerScreenshotImage.fromJson(
          _clone(full),
        ).copyWith(fileId: 5),
        throwsA(_safe('file_id')),
      );
    });
    test('optional image_url omit/null/clear and copy ownership', () {
      final model = LiveInputComputerScreenshotImage.fromJson(_clone(full));
      final omitted = model.copyWith(clearImageUrl: true);
      expect(omitted.rawJson.containsKey('image_url'), isFalse);
      expect(omitted.hasImageUrl, isFalse);
      expect(model.copyWith(imageUrl: model.imageUrl), model);
      expect(() => model.copyWith(imageUrl: null), throwsA(_safe('image_url')));
    });
    test('known image_url wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['image_url'] = 5;
      expect(
        () => LiveInputComputerScreenshotImage.fromJson(wire),
        throwsA(_safe('image_url')),
      );
      expect(
        () => LiveInputComputerScreenshotImage.fromJson(
          _clone(full),
        ).copyWith(imageUrl: 5),
        throwsA(_safe('image_url')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputComputerScreenshotImage.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputComputerScreenshotImage.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputComputerScreenshotImage.fromJson(wire),
        throwsA(_safe('LiveInputComputerScreenshotImage')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputComputerScreenshotImage.fromJson(wire),
        throwsA(_safe('LiveInputComputerScreenshotImage')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputComputerScreenshotImage.fromJson(wire),
        throwsA(_safe('LiveInputComputerScreenshotImage')),
      );
    });
  });
  group('ComputerTool', () {
    final minimal = {'type': 'computer'};
    final full = {'type': 'computer'};
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputComputerTool.fromJson(_clone(wire));
        final peer = LiveInputComputerTool.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputComputerTool.fromJson(_clone(full));
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputComputerTool.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputComputerTool.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputComputerTool.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputComputerTool.fromJson(wire),
        throwsA(_safe('LiveInputComputerTool')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputComputerTool.fromJson(wire),
        throwsA(_safe('LiveInputComputerTool')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputComputerTool.fromJson(wire),
        throwsA(_safe('LiveInputComputerTool')),
      );
    });
  });
  group('ComputerToolCall', () {
    final minimal = {
      'type': 'computer_call',
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'call_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'pending_safety_checks': <dynamic>[],
      'status': 'in_progress',
    };
    final full = {
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
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputComputerToolCall.fromJson(_clone(wire));
        final peer = LiveInputComputerToolCall.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputComputerToolCall.fromJson(_clone(full));
      expect(_wire(model.action), (full as Map)['action'], reason: 'action');
      expect(model.hasAction, isTrue);
      expect(_wire(model.actions), (full as Map)['actions'], reason: 'actions');
      expect(model.hasActions, isTrue);
      expect(_wire(model.callId), (full as Map)['call_id'], reason: 'call_id');
      expect(_wire(model.id), (full as Map)['id'], reason: 'id');
      expect(
        _wire(model.pendingSafetyChecks),
        (full as Map)['pending_safety_checks'],
        reason: 'pending_safety_checks',
      );
      expect(_wire(model.status), (full as Map)['status'], reason: 'status');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputComputerToolCall.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('optional action omit/null/clear and copy ownership', () {
      final model = LiveInputComputerToolCall.fromJson(_clone(full));
      final omitted = model.copyWith(clearAction: true);
      expect(omitted.rawJson.containsKey('action'), isFalse);
      expect(omitted.hasAction, isFalse);
      expect(model.copyWith(action: model.action), model);
      expect(() => model.copyWith(action: null), throwsA(_safe('action')));
    });
    test('known action wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['action'] = 5;
      expect(
        () => LiveInputComputerToolCall.fromJson(wire),
        throwsA(_safe('action')),
      );
      expect(
        () => LiveInputComputerToolCall.fromJson(
          _clone(full),
        ).copyWith(action: 5),
        throwsA(_safe('action')),
      );
    });
    test('optional actions omit/null/clear and copy ownership', () {
      final model = LiveInputComputerToolCall.fromJson(_clone(full));
      final omitted = model.copyWith(clearActions: true);
      expect(omitted.rawJson.containsKey('actions'), isFalse);
      expect(omitted.hasActions, isFalse);
      expect(model.copyWith(actions: model.actions), model);
      expect(() => model.copyWith(actions: null), throwsA(_safe('actions')));
    });
    test('known actions wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['actions'] = 5;
      expect(
        () => LiveInputComputerToolCall.fromJson(wire),
        throwsA(_safe('actions')),
      );
      expect(
        () => LiveInputComputerToolCall.fromJson(
          _clone(full),
        ).copyWith(actions: 5),
        throwsA(_safe('actions')),
      );
    });
    test('required call_id absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('call_id');
      expect(
        () => LiveInputComputerToolCall.fromJson(wire),
        throwsA(_safe('call_id')),
      );
    });
    test('known call_id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['call_id'] = 5;
      expect(
        () => LiveInputComputerToolCall.fromJson(wire),
        throwsA(_safe('call_id')),
      );
      expect(
        () => LiveInputComputerToolCall.fromJson(
          _clone(full),
        ).copyWith(callId: 5),
        throwsA(_safe('call_id')),
      );
    });
    test('required id absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('id');
      expect(
        () => LiveInputComputerToolCall.fromJson(wire),
        throwsA(_safe('id')),
      );
    });
    test('known id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['id'] = 5;
      expect(
        () => LiveInputComputerToolCall.fromJson(wire),
        throwsA(_safe('id')),
      );
      expect(
        () => LiveInputComputerToolCall.fromJson(_clone(full)).copyWith(id: 5),
        throwsA(_safe('id')),
      );
    });
    test('required pending_safety_checks absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('pending_safety_checks');
      expect(
        () => LiveInputComputerToolCall.fromJson(wire),
        throwsA(_safe('pending_safety_checks')),
      );
    });
    test('known pending_safety_checks wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['pending_safety_checks'] = 5;
      expect(
        () => LiveInputComputerToolCall.fromJson(wire),
        throwsA(_safe('pending_safety_checks')),
      );
      expect(
        () => LiveInputComputerToolCall.fromJson(
          _clone(full),
        ).copyWith(pendingSafetyChecks: 5),
        throwsA(_safe('pending_safety_checks')),
      );
    });
    test('required status absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('status');
      expect(
        () => LiveInputComputerToolCall.fromJson(wire),
        throwsA(_safe('status')),
      );
    });
    test('known status wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['status'] = 5;
      expect(
        () => LiveInputComputerToolCall.fromJson(wire),
        throwsA(_safe('status')),
      );
      expect(
        () => LiveInputComputerToolCall.fromJson(
          _clone(full),
        ).copyWith(status: 5),
        throwsA(_safe('status')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputComputerToolCall.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputComputerToolCall.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputComputerToolCall.fromJson(wire),
        throwsA(_safe('LiveInputComputerToolCall')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputComputerToolCall.fromJson(wire),
        throwsA(_safe('LiveInputComputerToolCall')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputComputerToolCall.fromJson(wire),
        throwsA(_safe('LiveInputComputerToolCall')),
      );
    });
  });
  group('ComputerUsePreviewTool', () {
    final minimal = {
      'type': 'computer_use_preview',
      'environment': 'windows',
      'display_width': 0,
      'display_height': 0,
    };
    final full = {
      'display_height': 0,
      'display_width': 0,
      'environment': 'windows',
      'type': 'computer_use_preview',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputComputerUsePreviewTool.fromJson(_clone(wire));
        final peer = LiveInputComputerUsePreviewTool.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputComputerUsePreviewTool.fromJson(_clone(full));
      expect(
        _wire(model.displayHeight),
        (full as Map)['display_height'],
        reason: 'display_height',
      );
      expect(
        _wire(model.displayWidth),
        (full as Map)['display_width'],
        reason: 'display_width',
      );
      expect(
        _wire(model.environment),
        (full as Map)['environment'],
        reason: 'environment',
      );
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputComputerUsePreviewTool.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required display_height absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('display_height');
      expect(
        () => LiveInputComputerUsePreviewTool.fromJson(wire),
        throwsA(_safe('display_height')),
      );
    });
    test('known display_height wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['display_height'] = false;
      expect(
        () => LiveInputComputerUsePreviewTool.fromJson(wire),
        throwsA(_safe('display_height')),
      );
      expect(
        () => LiveInputComputerUsePreviewTool.fromJson(
          _clone(full),
        ).copyWith(displayHeight: false),
        throwsA(_safe('display_height')),
      );
    });
    test('required display_width absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('display_width');
      expect(
        () => LiveInputComputerUsePreviewTool.fromJson(wire),
        throwsA(_safe('display_width')),
      );
    });
    test('known display_width wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['display_width'] = false;
      expect(
        () => LiveInputComputerUsePreviewTool.fromJson(wire),
        throwsA(_safe('display_width')),
      );
      expect(
        () => LiveInputComputerUsePreviewTool.fromJson(
          _clone(full),
        ).copyWith(displayWidth: false),
        throwsA(_safe('display_width')),
      );
    });
    test('required environment absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('environment');
      expect(
        () => LiveInputComputerUsePreviewTool.fromJson(wire),
        throwsA(_safe('environment')),
      );
    });
    test('known environment wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['environment'] = 5;
      expect(
        () => LiveInputComputerUsePreviewTool.fromJson(wire),
        throwsA(_safe('environment')),
      );
      expect(
        () => LiveInputComputerUsePreviewTool.fromJson(
          _clone(full),
        ).copyWith(environment: 5),
        throwsA(_safe('environment')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputComputerUsePreviewTool.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputComputerUsePreviewTool.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputComputerUsePreviewTool.fromJson(wire),
        throwsA(_safe('LiveInputComputerUsePreviewTool')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputComputerUsePreviewTool.fromJson(wire),
        throwsA(_safe('LiveInputComputerUsePreviewTool')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputComputerUsePreviewTool.fromJson(wire),
        throwsA(_safe('LiveInputComputerUsePreviewTool')),
      );
    });
  });
  group('ContainerAutoParam', () {
    final minimal = {'type': 'container_auto'};
    final full = {
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
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputContainerAutoParam.fromJson(_clone(wire));
        final peer = LiveInputContainerAutoParam.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputContainerAutoParam.fromJson(_clone(full));
      expect(
        _wire(model.fileIds),
        (full as Map)['file_ids'],
        reason: 'file_ids',
      );
      expect(model.hasFileIds, isTrue);
      expect(
        _wire(model.memoryLimit),
        (full as Map)['memory_limit'],
        reason: 'memory_limit',
      );
      expect(model.hasMemoryLimit, isTrue);
      expect(
        _wire(model.networkPolicy),
        (full as Map)['network_policy'],
        reason: 'network_policy',
      );
      expect(model.hasNetworkPolicy, isTrue);
      expect(_wire(model.skills), (full as Map)['skills'], reason: 'skills');
      expect(model.hasSkills, isTrue);
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputContainerAutoParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('optional file_ids omit/null/clear and copy ownership', () {
      final model = LiveInputContainerAutoParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearFileIds: true);
      expect(omitted.rawJson.containsKey('file_ids'), isFalse);
      expect(omitted.hasFileIds, isFalse);
      expect(model.copyWith(fileIds: model.fileIds), model);
      expect(() => model.copyWith(fileIds: null), throwsA(_safe('file_ids')));
    });
    test('known file_ids wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['file_ids'] = 5;
      expect(
        () => LiveInputContainerAutoParam.fromJson(wire),
        throwsA(_safe('file_ids')),
      );
      expect(
        () => LiveInputContainerAutoParam.fromJson(
          _clone(full),
        ).copyWith(fileIds: 5),
        throwsA(_safe('file_ids')),
      );
    });
    test('optional memory_limit omit/null/clear and copy ownership', () {
      final model = LiveInputContainerAutoParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearMemoryLimit: true);
      expect(omitted.rawJson.containsKey('memory_limit'), isFalse);
      expect(omitted.hasMemoryLimit, isFalse);
      expect(model.copyWith(memoryLimit: model.memoryLimit), model);
      final cleared = model.copyWith(memoryLimit: null);
      expect(cleared.rawJson.containsKey('memory_limit'), isTrue);
      expect(cleared.toJson()['memory_limit'], isNull);
      expect(cleared.hasMemoryLimit, isTrue);
    });
    test('known memory_limit wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['memory_limit'] = 5;
      expect(
        () => LiveInputContainerAutoParam.fromJson(wire),
        throwsA(_safe('memory_limit')),
      );
      expect(
        () => LiveInputContainerAutoParam.fromJson(
          _clone(full),
        ).copyWith(memoryLimit: 5),
        throwsA(_safe('memory_limit')),
      );
    });
    test('optional network_policy omit/null/clear and copy ownership', () {
      final model = LiveInputContainerAutoParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearNetworkPolicy: true);
      expect(omitted.rawJson.containsKey('network_policy'), isFalse);
      expect(omitted.hasNetworkPolicy, isFalse);
      expect(model.copyWith(networkPolicy: model.networkPolicy), model);
      expect(
        () => model.copyWith(networkPolicy: null),
        throwsA(_safe('network_policy')),
      );
    });
    test('known network_policy wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['network_policy'] = 5;
      expect(
        () => LiveInputContainerAutoParam.fromJson(wire),
        throwsA(_safe('network_policy')),
      );
      expect(
        () => LiveInputContainerAutoParam.fromJson(
          _clone(full),
        ).copyWith(networkPolicy: 5),
        throwsA(_safe('network_policy')),
      );
    });
    test('optional skills omit/null/clear and copy ownership', () {
      final model = LiveInputContainerAutoParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearSkills: true);
      expect(omitted.rawJson.containsKey('skills'), isFalse);
      expect(omitted.hasSkills, isFalse);
      expect(model.copyWith(skills: model.skills), model);
      expect(() => model.copyWith(skills: null), throwsA(_safe('skills')));
    });
    test('known skills wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['skills'] = 5;
      expect(
        () => LiveInputContainerAutoParam.fromJson(wire),
        throwsA(_safe('skills')),
      );
      expect(
        () => LiveInputContainerAutoParam.fromJson(
          _clone(full),
        ).copyWith(skills: 5),
        throwsA(_safe('skills')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputContainerAutoParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputContainerAutoParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputContainerAutoParam.fromJson(wire),
        throwsA(_safe('LiveInputContainerAutoParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputContainerAutoParam.fromJson(wire),
        throwsA(_safe('LiveInputContainerAutoParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputContainerAutoParam.fromJson(wire),
        throwsA(_safe('LiveInputContainerAutoParam')),
      );
    });
  });
  group('ContainerFileCitationBody', () {
    final minimal = {
      'type': 'container_file_citation',
      'container_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'file_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'start_index': 0,
      'end_index': 0,
      'filename': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    final full = {
      'container_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'end_index': 0,
      'file_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'filename': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'start_index': 0,
      'type': 'container_file_citation',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputContainerFileCitationBody.fromJson(_clone(wire));
        final peer = LiveInputContainerFileCitationBody.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputContainerFileCitationBody.fromJson(_clone(full));
      expect(
        _wire(model.containerId),
        (full as Map)['container_id'],
        reason: 'container_id',
      );
      expect(
        _wire(model.endIndex),
        (full as Map)['end_index'],
        reason: 'end_index',
      );
      expect(_wire(model.fileId), (full as Map)['file_id'], reason: 'file_id');
      expect(
        _wire(model.filename),
        (full as Map)['filename'],
        reason: 'filename',
      );
      expect(
        _wire(model.startIndex),
        (full as Map)['start_index'],
        reason: 'start_index',
      );
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputContainerFileCitationBody.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required container_id absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('container_id');
      expect(
        () => LiveInputContainerFileCitationBody.fromJson(wire),
        throwsA(_safe('container_id')),
      );
    });
    test('known container_id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['container_id'] = 5;
      expect(
        () => LiveInputContainerFileCitationBody.fromJson(wire),
        throwsA(_safe('container_id')),
      );
      expect(
        () => LiveInputContainerFileCitationBody.fromJson(
          _clone(full),
        ).copyWith(containerId: 5),
        throwsA(_safe('container_id')),
      );
    });
    test('required end_index absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('end_index');
      expect(
        () => LiveInputContainerFileCitationBody.fromJson(wire),
        throwsA(_safe('end_index')),
      );
    });
    test('known end_index wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['end_index'] = false;
      expect(
        () => LiveInputContainerFileCitationBody.fromJson(wire),
        throwsA(_safe('end_index')),
      );
      expect(
        () => LiveInputContainerFileCitationBody.fromJson(
          _clone(full),
        ).copyWith(endIndex: false),
        throwsA(_safe('end_index')),
      );
    });
    test('required file_id absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('file_id');
      expect(
        () => LiveInputContainerFileCitationBody.fromJson(wire),
        throwsA(_safe('file_id')),
      );
    });
    test('known file_id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['file_id'] = 5;
      expect(
        () => LiveInputContainerFileCitationBody.fromJson(wire),
        throwsA(_safe('file_id')),
      );
      expect(
        () => LiveInputContainerFileCitationBody.fromJson(
          _clone(full),
        ).copyWith(fileId: 5),
        throwsA(_safe('file_id')),
      );
    });
    test('required filename absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('filename');
      expect(
        () => LiveInputContainerFileCitationBody.fromJson(wire),
        throwsA(_safe('filename')),
      );
    });
    test('known filename wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['filename'] = 5;
      expect(
        () => LiveInputContainerFileCitationBody.fromJson(wire),
        throwsA(_safe('filename')),
      );
      expect(
        () => LiveInputContainerFileCitationBody.fromJson(
          _clone(full),
        ).copyWith(filename: 5),
        throwsA(_safe('filename')),
      );
    });
    test('required start_index absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('start_index');
      expect(
        () => LiveInputContainerFileCitationBody.fromJson(wire),
        throwsA(_safe('start_index')),
      );
    });
    test('known start_index wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['start_index'] = false;
      expect(
        () => LiveInputContainerFileCitationBody.fromJson(wire),
        throwsA(_safe('start_index')),
      );
      expect(
        () => LiveInputContainerFileCitationBody.fromJson(
          _clone(full),
        ).copyWith(startIndex: false),
        throwsA(_safe('start_index')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputContainerFileCitationBody.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputContainerFileCitationBody.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputContainerFileCitationBody.fromJson(wire),
        throwsA(_safe('LiveInputContainerFileCitationBody')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputContainerFileCitationBody.fromJson(wire),
        throwsA(_safe('LiveInputContainerFileCitationBody')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputContainerFileCitationBody.fromJson(wire),
        throwsA(_safe('LiveInputContainerFileCitationBody')),
      );
    });
  });
  group('ContainerMemoryLimit', () {
    const minimal = '1g';
    const full = '1g';
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputContainerMemoryLimit.fromJson(_clone(wire));
        final peer = LiveInputContainerMemoryLimit.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('value copy and JSON ownership', () {
      final model = LiveInputContainerMemoryLimit.fromJson(_clone(full));
      expect(_wire(model.value), full);
      expect(model.copyWith(value: _clone(full)), model);
    });
  });
  group('ContainerNetworkPolicyAllowlistParam', () {
    final minimal = {
      'type': 'allowlist',
      'allowed_domains': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
    };
    final full = {
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
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputContainerNetworkPolicyAllowlistParam.fromJson(
          _clone(wire),
        );
        final peer = LiveInputContainerNetworkPolicyAllowlistParam.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputContainerNetworkPolicyAllowlistParam.fromJson(
        _clone(full),
      );
      expect(
        _wire(model.allowedDomains),
        (full as Map)['allowed_domains'],
        reason: 'allowed_domains',
      );
      expect(
        _wire(model.domainSecrets),
        (full as Map)['domain_secrets'],
        reason: 'domain_secrets',
      );
      expect(model.hasDomainSecrets, isTrue);
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputContainerNetworkPolicyAllowlistParam.fromJson(
        source,
      );
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required allowed_domains absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('allowed_domains');
      expect(
        () => LiveInputContainerNetworkPolicyAllowlistParam.fromJson(wire),
        throwsA(_safe('allowed_domains')),
      );
    });
    test('known allowed_domains wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['allowed_domains'] = 5;
      expect(
        () => LiveInputContainerNetworkPolicyAllowlistParam.fromJson(wire),
        throwsA(_safe('allowed_domains')),
      );
      expect(
        () => LiveInputContainerNetworkPolicyAllowlistParam.fromJson(
          _clone(full),
        ).copyWith(allowedDomains: 5),
        throwsA(_safe('allowed_domains')),
      );
    });
    test('optional domain_secrets omit/null/clear and copy ownership', () {
      final model = LiveInputContainerNetworkPolicyAllowlistParam.fromJson(
        _clone(full),
      );
      final omitted = model.copyWith(clearDomainSecrets: true);
      expect(omitted.rawJson.containsKey('domain_secrets'), isFalse);
      expect(omitted.hasDomainSecrets, isFalse);
      expect(model.copyWith(domainSecrets: model.domainSecrets), model);
      expect(
        () => model.copyWith(domainSecrets: null),
        throwsA(_safe('domain_secrets')),
      );
    });
    test('known domain_secrets wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['domain_secrets'] = 5;
      expect(
        () => LiveInputContainerNetworkPolicyAllowlistParam.fromJson(wire),
        throwsA(_safe('domain_secrets')),
      );
      expect(
        () => LiveInputContainerNetworkPolicyAllowlistParam.fromJson(
          _clone(full),
        ).copyWith(domainSecrets: 5),
        throwsA(_safe('domain_secrets')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputContainerNetworkPolicyAllowlistParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputContainerNetworkPolicyAllowlistParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputContainerNetworkPolicyAllowlistParam.fromJson(wire),
        throwsA(_safe('LiveInputContainerNetworkPolicyAllowlistParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputContainerNetworkPolicyAllowlistParam.fromJson(wire),
        throwsA(_safe('LiveInputContainerNetworkPolicyAllowlistParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputContainerNetworkPolicyAllowlistParam.fromJson(wire),
        throwsA(_safe('LiveInputContainerNetworkPolicyAllowlistParam')),
      );
    });
  });
  group('ContainerNetworkPolicyDisabledParam', () {
    final minimal = {'type': 'disabled'};
    final full = {'type': 'disabled'};
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputContainerNetworkPolicyDisabledParam.fromJson(
          _clone(wire),
        );
        final peer = LiveInputContainerNetworkPolicyDisabledParam.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputContainerNetworkPolicyDisabledParam.fromJson(
        _clone(full),
      );
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputContainerNetworkPolicyDisabledParam.fromJson(
        source,
      );
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputContainerNetworkPolicyDisabledParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputContainerNetworkPolicyDisabledParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputContainerNetworkPolicyDisabledParam.fromJson(wire),
        throwsA(_safe('LiveInputContainerNetworkPolicyDisabledParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputContainerNetworkPolicyDisabledParam.fromJson(wire),
        throwsA(_safe('LiveInputContainerNetworkPolicyDisabledParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputContainerNetworkPolicyDisabledParam.fromJson(wire),
        throwsA(_safe('LiveInputContainerNetworkPolicyDisabledParam')),
      );
    });
  });
  group('ContainerNetworkPolicyDomainSecretParam', () {
    final minimal = {
      'domain': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'value': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    final full = {
      'domain': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'value': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputContainerNetworkPolicyDomainSecretParam.fromJson(
          _clone(wire),
        );
        final peer = LiveInputContainerNetworkPolicyDomainSecretParam.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputContainerNetworkPolicyDomainSecretParam.fromJson(
        _clone(full),
      );
      expect(_wire(model.domain), (full as Map)['domain'], reason: 'domain');
      expect(_wire(model.name), (full as Map)['name'], reason: 'name');
      expect(_wire(model.value), (full as Map)['value'], reason: 'value');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputContainerNetworkPolicyDomainSecretParam.fromJson(
        source,
      );
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required domain absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('domain');
      expect(
        () => LiveInputContainerNetworkPolicyDomainSecretParam.fromJson(wire),
        throwsA(_safe('domain')),
      );
    });
    test('known domain wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['domain'] = 5;
      expect(
        () => LiveInputContainerNetworkPolicyDomainSecretParam.fromJson(wire),
        throwsA(_safe('domain')),
      );
      expect(
        () => LiveInputContainerNetworkPolicyDomainSecretParam.fromJson(
          _clone(full),
        ).copyWith(domain: 5),
        throwsA(_safe('domain')),
      );
    });
    test('required name absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('name');
      expect(
        () => LiveInputContainerNetworkPolicyDomainSecretParam.fromJson(wire),
        throwsA(_safe('name')),
      );
    });
    test('known name wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['name'] = 5;
      expect(
        () => LiveInputContainerNetworkPolicyDomainSecretParam.fromJson(wire),
        throwsA(_safe('name')),
      );
      expect(
        () => LiveInputContainerNetworkPolicyDomainSecretParam.fromJson(
          _clone(full),
        ).copyWith(name: 5),
        throwsA(_safe('name')),
      );
    });
    test('required value absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('value');
      expect(
        () => LiveInputContainerNetworkPolicyDomainSecretParam.fromJson(wire),
        throwsA(_safe('value')),
      );
    });
    test('known value wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['value'] = 5;
      expect(
        () => LiveInputContainerNetworkPolicyDomainSecretParam.fromJson(wire),
        throwsA(_safe('value')),
      );
      expect(
        () => LiveInputContainerNetworkPolicyDomainSecretParam.fromJson(
          _clone(full),
        ).copyWith(value: 5),
        throwsA(_safe('value')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputContainerNetworkPolicyDomainSecretParam.fromJson(wire),
        throwsA(_safe('LiveInputContainerNetworkPolicyDomainSecretParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputContainerNetworkPolicyDomainSecretParam.fromJson(wire),
        throwsA(_safe('LiveInputContainerNetworkPolicyDomainSecretParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputContainerNetworkPolicyDomainSecretParam.fromJson(wire),
        throwsA(_safe('LiveInputContainerNetworkPolicyDomainSecretParam')),
      );
    });
  });
  group('ContainerReferenceParam', () {
    final minimal = {
      'type': 'container_reference',
      'container_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    final full = {
      'container_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'container_reference',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputContainerReferenceParam.fromJson(_clone(wire));
        final peer = LiveInputContainerReferenceParam.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputContainerReferenceParam.fromJson(_clone(full));
      expect(
        _wire(model.containerId),
        (full as Map)['container_id'],
        reason: 'container_id',
      );
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputContainerReferenceParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required container_id absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('container_id');
      expect(
        () => LiveInputContainerReferenceParam.fromJson(wire),
        throwsA(_safe('container_id')),
      );
    });
    test('known container_id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['container_id'] = 5;
      expect(
        () => LiveInputContainerReferenceParam.fromJson(wire),
        throwsA(_safe('container_id')),
      );
      expect(
        () => LiveInputContainerReferenceParam.fromJson(
          _clone(full),
        ).copyWith(containerId: 5),
        throwsA(_safe('container_id')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputContainerReferenceParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputContainerReferenceParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputContainerReferenceParam.fromJson(wire),
        throwsA(_safe('LiveInputContainerReferenceParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputContainerReferenceParam.fromJson(wire),
        throwsA(_safe('LiveInputContainerReferenceParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputContainerReferenceParam.fromJson(wire),
        throwsA(_safe('LiveInputContainerReferenceParam')),
      );
    });
  });
  group('CoordParam', () {
    final minimal = {'x': 0, 'y': 0};
    final full = {'x': 0, 'y': 0};
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputCoordParam.fromJson(_clone(wire));
        final peer = LiveInputCoordParam.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputCoordParam.fromJson(_clone(full));
      expect(_wire(model.x), (full as Map)['x'], reason: 'x');
      expect(_wire(model.y), (full as Map)['y'], reason: 'y');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputCoordParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required x absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)..remove('x');
      expect(() => LiveInputCoordParam.fromJson(wire), throwsA(_safe('x')));
    });
    test('known x wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['x'] = false;
      expect(() => LiveInputCoordParam.fromJson(wire), throwsA(_safe('x')));
      expect(
        () => LiveInputCoordParam.fromJson(_clone(full)).copyWith(x: false),
        throwsA(_safe('x')),
      );
    });
    test('required y absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)..remove('y');
      expect(() => LiveInputCoordParam.fromJson(wire), throwsA(_safe('y')));
    });
    test('known y wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['y'] = false;
      expect(() => LiveInputCoordParam.fromJson(wire), throwsA(_safe('y')));
      expect(
        () => LiveInputCoordParam.fromJson(_clone(full)).copyWith(y: false),
        throwsA(_safe('y')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputCoordParam.fromJson(wire),
        throwsA(_safe('LiveInputCoordParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputCoordParam.fromJson(wire),
        throwsA(_safe('LiveInputCoordParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputCoordParam.fromJson(wire),
        throwsA(_safe('LiveInputCoordParam')),
      );
    });
  });
  group('CustomGrammarFormatParam', () {
    final minimal = {
      'type': 'grammar',
      'syntax': 'lark',
      'definition': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    final full = {
      'definition': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'syntax': 'lark',
      'type': 'grammar',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputCustomGrammarFormatParam.fromJson(_clone(wire));
        final peer = LiveInputCustomGrammarFormatParam.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputCustomGrammarFormatParam.fromJson(_clone(full));
      expect(
        _wire(model.definition),
        (full as Map)['definition'],
        reason: 'definition',
      );
      expect(_wire(model.syntax), (full as Map)['syntax'], reason: 'syntax');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputCustomGrammarFormatParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required definition absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('definition');
      expect(
        () => LiveInputCustomGrammarFormatParam.fromJson(wire),
        throwsA(_safe('definition')),
      );
    });
    test('known definition wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['definition'] = 5;
      expect(
        () => LiveInputCustomGrammarFormatParam.fromJson(wire),
        throwsA(_safe('definition')),
      );
      expect(
        () => LiveInputCustomGrammarFormatParam.fromJson(
          _clone(full),
        ).copyWith(definition: 5),
        throwsA(_safe('definition')),
      );
    });
    test('required syntax absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('syntax');
      expect(
        () => LiveInputCustomGrammarFormatParam.fromJson(wire),
        throwsA(_safe('syntax')),
      );
    });
    test('known syntax wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['syntax'] = 5;
      expect(
        () => LiveInputCustomGrammarFormatParam.fromJson(wire),
        throwsA(_safe('syntax')),
      );
      expect(
        () => LiveInputCustomGrammarFormatParam.fromJson(
          _clone(full),
        ).copyWith(syntax: 5),
        throwsA(_safe('syntax')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputCustomGrammarFormatParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputCustomGrammarFormatParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputCustomGrammarFormatParam.fromJson(wire),
        throwsA(_safe('LiveInputCustomGrammarFormatParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputCustomGrammarFormatParam.fromJson(wire),
        throwsA(_safe('LiveInputCustomGrammarFormatParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputCustomGrammarFormatParam.fromJson(wire),
        throwsA(_safe('LiveInputCustomGrammarFormatParam')),
      );
    });
  });
  group('CustomTextFormatParam', () {
    final minimal = {'type': 'text'};
    final full = {'type': 'text'};
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputCustomTextFormatParam.fromJson(_clone(wire));
        final peer = LiveInputCustomTextFormatParam.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputCustomTextFormatParam.fromJson(_clone(full));
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputCustomTextFormatParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputCustomTextFormatParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputCustomTextFormatParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputCustomTextFormatParam.fromJson(wire),
        throwsA(_safe('LiveInputCustomTextFormatParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputCustomTextFormatParam.fromJson(wire),
        throwsA(_safe('LiveInputCustomTextFormatParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputCustomTextFormatParam.fromJson(wire),
        throwsA(_safe('LiveInputCustomTextFormatParam')),
      );
    });
  });
  group('CustomToolCall', () {
    final minimal = {
      'type': 'custom_tool_call',
      'call_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'input': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    final full = {
      'async': false,
      'call_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'caller': {'type': 'direct'},
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'input': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'namespace': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'custom_tool_call',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputCustomToolCall.fromJson(_clone(wire));
        final peer = LiveInputCustomToolCall.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputCustomToolCall.fromJson(_clone(full));
      expect(_wire(model.async), (full as Map)['async'], reason: 'async');
      expect(model.hasAsync, isTrue);
      expect(_wire(model.callId), (full as Map)['call_id'], reason: 'call_id');
      expect(_wire(model.caller), (full as Map)['caller'], reason: 'caller');
      expect(model.hasCaller, isTrue);
      expect(_wire(model.id), (full as Map)['id'], reason: 'id');
      expect(model.hasId, isTrue);
      expect(_wire(model.input), (full as Map)['input'], reason: 'input');
      expect(_wire(model.name), (full as Map)['name'], reason: 'name');
      expect(
        _wire(model.namespace),
        (full as Map)['namespace'],
        reason: 'namespace',
      );
      expect(model.hasNamespace, isTrue);
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputCustomToolCall.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('optional async omit/null/clear and copy ownership', () {
      final model = LiveInputCustomToolCall.fromJson(_clone(full));
      final omitted = model.copyWith(clearAsync: true);
      expect(omitted.rawJson.containsKey('async'), isFalse);
      expect(omitted.hasAsync, isFalse);
      expect(model.copyWith(async: model.async), model);
      expect(() => model.copyWith(async: null), throwsA(_safe('async')));
    });
    test('known async wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['async'] = 5;
      expect(
        () => LiveInputCustomToolCall.fromJson(wire),
        throwsA(_safe('async')),
      );
      expect(
        () => LiveInputCustomToolCall.fromJson(_clone(full)).copyWith(async: 5),
        throwsA(_safe('async')),
      );
    });
    test('required call_id absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('call_id');
      expect(
        () => LiveInputCustomToolCall.fromJson(wire),
        throwsA(_safe('call_id')),
      );
    });
    test('known call_id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['call_id'] = 5;
      expect(
        () => LiveInputCustomToolCall.fromJson(wire),
        throwsA(_safe('call_id')),
      );
      expect(
        () =>
            LiveInputCustomToolCall.fromJson(_clone(full)).copyWith(callId: 5),
        throwsA(_safe('call_id')),
      );
    });
    test('optional caller omit/null/clear and copy ownership', () {
      final model = LiveInputCustomToolCall.fromJson(_clone(full));
      final omitted = model.copyWith(clearCaller: true);
      expect(omitted.rawJson.containsKey('caller'), isFalse);
      expect(omitted.hasCaller, isFalse);
      expect(model.copyWith(caller: model.caller), model);
      final cleared = model.copyWith(caller: null);
      expect(cleared.rawJson.containsKey('caller'), isTrue);
      expect(cleared.toJson()['caller'], isNull);
      expect(cleared.hasCaller, isTrue);
    });
    test('known caller wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['caller'] = 5;
      expect(
        () => LiveInputCustomToolCall.fromJson(wire),
        throwsA(_safe('caller')),
      );
      expect(
        () =>
            LiveInputCustomToolCall.fromJson(_clone(full)).copyWith(caller: 5),
        throwsA(_safe('caller')),
      );
    });
    test('optional id omit/null/clear and copy ownership', () {
      final model = LiveInputCustomToolCall.fromJson(_clone(full));
      final omitted = model.copyWith(clearId: true);
      expect(omitted.rawJson.containsKey('id'), isFalse);
      expect(omitted.hasId, isFalse);
      expect(model.copyWith(id: model.id), model);
      expect(() => model.copyWith(id: null), throwsA(_safe('id')));
    });
    test('known id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['id'] = 5;
      expect(
        () => LiveInputCustomToolCall.fromJson(wire),
        throwsA(_safe('id')),
      );
      expect(
        () => LiveInputCustomToolCall.fromJson(_clone(full)).copyWith(id: 5),
        throwsA(_safe('id')),
      );
    });
    test('required input absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('input');
      expect(
        () => LiveInputCustomToolCall.fromJson(wire),
        throwsA(_safe('input')),
      );
    });
    test('known input wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['input'] = 5;
      expect(
        () => LiveInputCustomToolCall.fromJson(wire),
        throwsA(_safe('input')),
      );
      expect(
        () => LiveInputCustomToolCall.fromJson(_clone(full)).copyWith(input: 5),
        throwsA(_safe('input')),
      );
    });
    test('required name absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('name');
      expect(
        () => LiveInputCustomToolCall.fromJson(wire),
        throwsA(_safe('name')),
      );
    });
    test('known name wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['name'] = 5;
      expect(
        () => LiveInputCustomToolCall.fromJson(wire),
        throwsA(_safe('name')),
      );
      expect(
        () => LiveInputCustomToolCall.fromJson(_clone(full)).copyWith(name: 5),
        throwsA(_safe('name')),
      );
    });
    test('optional namespace omit/null/clear and copy ownership', () {
      final model = LiveInputCustomToolCall.fromJson(_clone(full));
      final omitted = model.copyWith(clearNamespace: true);
      expect(omitted.rawJson.containsKey('namespace'), isFalse);
      expect(omitted.hasNamespace, isFalse);
      expect(model.copyWith(namespace: model.namespace), model);
      expect(
        () => model.copyWith(namespace: null),
        throwsA(_safe('namespace')),
      );
    });
    test('known namespace wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['namespace'] = 5;
      expect(
        () => LiveInputCustomToolCall.fromJson(wire),
        throwsA(_safe('namespace')),
      );
      expect(
        () => LiveInputCustomToolCall.fromJson(
          _clone(full),
        ).copyWith(namespace: 5),
        throwsA(_safe('namespace')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputCustomToolCall.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputCustomToolCall.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputCustomToolCall.fromJson(wire),
        throwsA(_safe('LiveInputCustomToolCall')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputCustomToolCall.fromJson(wire),
        throwsA(_safe('LiveInputCustomToolCall')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputCustomToolCall.fromJson(wire),
        throwsA(_safe('LiveInputCustomToolCall')),
      );
    });
  });
  group('CustomToolCallOutput', () {
    final minimal = {
      'type': 'custom_tool_call_output',
      'call_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'output': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    final full = {
      'call_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'caller': {'type': 'direct'},
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'output': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'custom_tool_call_output',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputCustomToolCallOutput.fromJson(_clone(wire));
        final peer = LiveInputCustomToolCallOutput.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputCustomToolCallOutput.fromJson(_clone(full));
      expect(_wire(model.callId), (full as Map)['call_id'], reason: 'call_id');
      expect(_wire(model.caller), (full as Map)['caller'], reason: 'caller');
      expect(model.hasCaller, isTrue);
      expect(_wire(model.id), (full as Map)['id'], reason: 'id');
      expect(model.hasId, isTrue);
      expect(_wire(model.output), (full as Map)['output'], reason: 'output');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputCustomToolCallOutput.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required call_id absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('call_id');
      expect(
        () => LiveInputCustomToolCallOutput.fromJson(wire),
        throwsA(_safe('call_id')),
      );
    });
    test('known call_id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['call_id'] = 5;
      expect(
        () => LiveInputCustomToolCallOutput.fromJson(wire),
        throwsA(_safe('call_id')),
      );
      expect(
        () => LiveInputCustomToolCallOutput.fromJson(
          _clone(full),
        ).copyWith(callId: 5),
        throwsA(_safe('call_id')),
      );
    });
    test('optional caller omit/null/clear and copy ownership', () {
      final model = LiveInputCustomToolCallOutput.fromJson(_clone(full));
      final omitted = model.copyWith(clearCaller: true);
      expect(omitted.rawJson.containsKey('caller'), isFalse);
      expect(omitted.hasCaller, isFalse);
      expect(model.copyWith(caller: model.caller), model);
      final cleared = model.copyWith(caller: null);
      expect(cleared.rawJson.containsKey('caller'), isTrue);
      expect(cleared.toJson()['caller'], isNull);
      expect(cleared.hasCaller, isTrue);
    });
    test('known caller wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['caller'] = 5;
      expect(
        () => LiveInputCustomToolCallOutput.fromJson(wire),
        throwsA(_safe('caller')),
      );
      expect(
        () => LiveInputCustomToolCallOutput.fromJson(
          _clone(full),
        ).copyWith(caller: 5),
        throwsA(_safe('caller')),
      );
    });
    test('optional id omit/null/clear and copy ownership', () {
      final model = LiveInputCustomToolCallOutput.fromJson(_clone(full));
      final omitted = model.copyWith(clearId: true);
      expect(omitted.rawJson.containsKey('id'), isFalse);
      expect(omitted.hasId, isFalse);
      expect(model.copyWith(id: model.id), model);
      expect(() => model.copyWith(id: null), throwsA(_safe('id')));
    });
    test('known id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['id'] = 5;
      expect(
        () => LiveInputCustomToolCallOutput.fromJson(wire),
        throwsA(_safe('id')),
      );
      expect(
        () => LiveInputCustomToolCallOutput.fromJson(
          _clone(full),
        ).copyWith(id: 5),
        throwsA(_safe('id')),
      );
    });
    test('required output absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('output');
      expect(
        () => LiveInputCustomToolCallOutput.fromJson(wire),
        throwsA(_safe('output')),
      );
    });
    test('known output wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['output'] = 5;
      expect(
        () => LiveInputCustomToolCallOutput.fromJson(wire),
        throwsA(_safe('output')),
      );
      expect(
        () => LiveInputCustomToolCallOutput.fromJson(
          _clone(full),
        ).copyWith(output: 5),
        throwsA(_safe('output')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputCustomToolCallOutput.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputCustomToolCallOutput.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputCustomToolCallOutput.fromJson(wire),
        throwsA(_safe('LiveInputCustomToolCallOutput')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputCustomToolCallOutput.fromJson(wire),
        throwsA(_safe('LiveInputCustomToolCallOutput')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputCustomToolCallOutput.fromJson(wire),
        throwsA(_safe('LiveInputCustomToolCallOutput')),
      );
    });
  });
  group('CustomToolParam', () {
    final minimal = {'type': 'custom', 'name': 'PRIVATE_LIVE_INPUT_PAYLOAD'};
    final full = {
      'allowed_callers': ['direct'],
      'async': false,
      'defer_loading': false,
      'description': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'format': {'type': 'text'},
      'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'custom',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputCustomToolParam.fromJson(_clone(wire));
        final peer = LiveInputCustomToolParam.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputCustomToolParam.fromJson(_clone(full));
      expect(
        _wire(model.allowedCallers),
        (full as Map)['allowed_callers'],
        reason: 'allowed_callers',
      );
      expect(model.hasAllowedCallers, isTrue);
      expect(_wire(model.async), (full as Map)['async'], reason: 'async');
      expect(model.hasAsync, isTrue);
      expect(
        _wire(model.deferLoading),
        (full as Map)['defer_loading'],
        reason: 'defer_loading',
      );
      expect(model.hasDeferLoading, isTrue);
      expect(
        _wire(model.description),
        (full as Map)['description'],
        reason: 'description',
      );
      expect(model.hasDescription, isTrue);
      expect(_wire(model.format), (full as Map)['format'], reason: 'format');
      expect(model.hasFormat, isTrue);
      expect(_wire(model.name), (full as Map)['name'], reason: 'name');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputCustomToolParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('optional allowed_callers omit/null/clear and copy ownership', () {
      final model = LiveInputCustomToolParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearAllowedCallers: true);
      expect(omitted.rawJson.containsKey('allowed_callers'), isFalse);
      expect(omitted.hasAllowedCallers, isFalse);
      expect(model.copyWith(allowedCallers: model.allowedCallers), model);
      final cleared = model.copyWith(allowedCallers: null);
      expect(cleared.rawJson.containsKey('allowed_callers'), isTrue);
      expect(cleared.toJson()['allowed_callers'], isNull);
      expect(cleared.hasAllowedCallers, isTrue);
    });
    test('known allowed_callers wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['allowed_callers'] = 5;
      expect(
        () => LiveInputCustomToolParam.fromJson(wire),
        throwsA(_safe('allowed_callers')),
      );
      expect(
        () => LiveInputCustomToolParam.fromJson(
          _clone(full),
        ).copyWith(allowedCallers: 5),
        throwsA(_safe('allowed_callers')),
      );
    });
    test('optional async omit/null/clear and copy ownership', () {
      final model = LiveInputCustomToolParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearAsync: true);
      expect(omitted.rawJson.containsKey('async'), isFalse);
      expect(omitted.hasAsync, isFalse);
      expect(model.copyWith(async: model.async), model);
      expect(() => model.copyWith(async: null), throwsA(_safe('async')));
    });
    test('known async wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['async'] = 5;
      expect(
        () => LiveInputCustomToolParam.fromJson(wire),
        throwsA(_safe('async')),
      );
      expect(
        () =>
            LiveInputCustomToolParam.fromJson(_clone(full)).copyWith(async: 5),
        throwsA(_safe('async')),
      );
    });
    test('optional defer_loading omit/null/clear and copy ownership', () {
      final model = LiveInputCustomToolParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearDeferLoading: true);
      expect(omitted.rawJson.containsKey('defer_loading'), isFalse);
      expect(omitted.hasDeferLoading, isFalse);
      expect(model.copyWith(deferLoading: model.deferLoading), model);
      expect(
        () => model.copyWith(deferLoading: null),
        throwsA(_safe('defer_loading')),
      );
    });
    test('known defer_loading wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['defer_loading'] = 5;
      expect(
        () => LiveInputCustomToolParam.fromJson(wire),
        throwsA(_safe('defer_loading')),
      );
      expect(
        () => LiveInputCustomToolParam.fromJson(
          _clone(full),
        ).copyWith(deferLoading: 5),
        throwsA(_safe('defer_loading')),
      );
    });
    test('optional description omit/null/clear and copy ownership', () {
      final model = LiveInputCustomToolParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearDescription: true);
      expect(omitted.rawJson.containsKey('description'), isFalse);
      expect(omitted.hasDescription, isFalse);
      expect(model.copyWith(description: model.description), model);
      expect(
        () => model.copyWith(description: null),
        throwsA(_safe('description')),
      );
    });
    test('known description wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['description'] = 5;
      expect(
        () => LiveInputCustomToolParam.fromJson(wire),
        throwsA(_safe('description')),
      );
      expect(
        () => LiveInputCustomToolParam.fromJson(
          _clone(full),
        ).copyWith(description: 5),
        throwsA(_safe('description')),
      );
    });
    test('optional format omit/null/clear and copy ownership', () {
      final model = LiveInputCustomToolParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearFormat: true);
      expect(omitted.rawJson.containsKey('format'), isFalse);
      expect(omitted.hasFormat, isFalse);
      expect(model.copyWith(format: model.format), model);
      expect(() => model.copyWith(format: null), throwsA(_safe('format')));
    });
    test('known format wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['format'] = 5;
      expect(
        () => LiveInputCustomToolParam.fromJson(wire),
        throwsA(_safe('format')),
      );
      expect(
        () =>
            LiveInputCustomToolParam.fromJson(_clone(full)).copyWith(format: 5),
        throwsA(_safe('format')),
      );
    });
    test('required name absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('name');
      expect(
        () => LiveInputCustomToolParam.fromJson(wire),
        throwsA(_safe('name')),
      );
    });
    test('known name wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['name'] = 5;
      expect(
        () => LiveInputCustomToolParam.fromJson(wire),
        throwsA(_safe('name')),
      );
      expect(
        () => LiveInputCustomToolParam.fromJson(_clone(full)).copyWith(name: 5),
        throwsA(_safe('name')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputCustomToolParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputCustomToolParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputCustomToolParam.fromJson(wire),
        throwsA(_safe('LiveInputCustomToolParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputCustomToolParam.fromJson(wire),
        throwsA(_safe('LiveInputCustomToolParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputCustomToolParam.fromJson(wire),
        throwsA(_safe('LiveInputCustomToolParam')),
      );
    });
  });
  group('DetailEnum', () {
    const minimal = 'low';
    const full = 'low';
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputDetailEnum.fromJson(_clone(wire));
        final peer = LiveInputDetailEnum.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('value copy and JSON ownership', () {
      final model = LiveInputDetailEnum.fromJson(_clone(full));
      expect(_wire(model.value), full);
      expect(model.copyWith(value: _clone(full)), model);
    });
  });
  group('DirectToolCallCaller', () {
    final minimal = {'type': 'direct'};
    final full = {'type': 'direct'};
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputDirectToolCallCaller.fromJson(_clone(wire));
        final peer = LiveInputDirectToolCallCaller.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputDirectToolCallCaller.fromJson(_clone(full));
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputDirectToolCallCaller.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputDirectToolCallCaller.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputDirectToolCallCaller.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputDirectToolCallCaller.fromJson(wire),
        throwsA(_safe('LiveInputDirectToolCallCaller')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputDirectToolCallCaller.fromJson(wire),
        throwsA(_safe('LiveInputDirectToolCallCaller')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputDirectToolCallCaller.fromJson(wire),
        throwsA(_safe('LiveInputDirectToolCallCaller')),
      );
    });
  });
  group('DirectToolCallCallerParam', () {
    final minimal = {'type': 'direct'};
    final full = {'type': 'direct'};
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputDirectToolCallCallerParam.fromJson(_clone(wire));
        final peer = LiveInputDirectToolCallCallerParam.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputDirectToolCallCallerParam.fromJson(_clone(full));
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputDirectToolCallCallerParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputDirectToolCallCallerParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputDirectToolCallCallerParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputDirectToolCallCallerParam.fromJson(wire),
        throwsA(_safe('LiveInputDirectToolCallCallerParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputDirectToolCallCallerParam.fromJson(wire),
        throwsA(_safe('LiveInputDirectToolCallCallerParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputDirectToolCallCallerParam.fromJson(wire),
        throwsA(_safe('LiveInputDirectToolCallCallerParam')),
      );
    });
  });
  group('DoubleClickAction', () {
    final minimal = {
      'type': 'double_click',
      'x': 0,
      'y': 0,
      'keys': <dynamic>[],
    };
    final full = {
      'keys': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
      'type': 'double_click',
      'x': 0,
      'y': 0,
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputDoubleClickAction.fromJson(_clone(wire));
        final peer = LiveInputDoubleClickAction.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputDoubleClickAction.fromJson(_clone(full));
      expect(_wire(model.keys), (full as Map)['keys'], reason: 'keys');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
      expect(_wire(model.x), (full as Map)['x'], reason: 'x');
      expect(_wire(model.y), (full as Map)['y'], reason: 'y');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputDoubleClickAction.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required keys absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('keys');
      expect(
        () => LiveInputDoubleClickAction.fromJson(wire),
        throwsA(_safe('keys')),
      );
    });
    test('known keys wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['keys'] = 5;
      expect(
        () => LiveInputDoubleClickAction.fromJson(wire),
        throwsA(_safe('keys')),
      );
      expect(
        () =>
            LiveInputDoubleClickAction.fromJson(_clone(full)).copyWith(keys: 5),
        throwsA(_safe('keys')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputDoubleClickAction.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputDoubleClickAction.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('required x absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)..remove('x');
      expect(
        () => LiveInputDoubleClickAction.fromJson(wire),
        throwsA(_safe('x')),
      );
    });
    test('known x wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['x'] = false;
      expect(
        () => LiveInputDoubleClickAction.fromJson(wire),
        throwsA(_safe('x')),
      );
      expect(
        () => LiveInputDoubleClickAction.fromJson(
          _clone(full),
        ).copyWith(x: false),
        throwsA(_safe('x')),
      );
    });
    test('required y absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)..remove('y');
      expect(
        () => LiveInputDoubleClickAction.fromJson(wire),
        throwsA(_safe('y')),
      );
    });
    test('known y wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['y'] = false;
      expect(
        () => LiveInputDoubleClickAction.fromJson(wire),
        throwsA(_safe('y')),
      );
      expect(
        () => LiveInputDoubleClickAction.fromJson(
          _clone(full),
        ).copyWith(y: false),
        throwsA(_safe('y')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputDoubleClickAction.fromJson(wire),
        throwsA(_safe('LiveInputDoubleClickAction')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputDoubleClickAction.fromJson(wire),
        throwsA(_safe('LiveInputDoubleClickAction')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputDoubleClickAction.fromJson(wire),
        throwsA(_safe('LiveInputDoubleClickAction')),
      );
    });
  });
  group('DragParam', () {
    final minimal = {'type': 'drag', 'path': <dynamic>[]};
    final full = {
      'keys': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
      'path': [
        {'x': 0, 'y': 0},
      ],
      'type': 'drag',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputDragParam.fromJson(_clone(wire));
        final peer = LiveInputDragParam.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputDragParam.fromJson(_clone(full));
      expect(_wire(model.keys), (full as Map)['keys'], reason: 'keys');
      expect(model.hasKeys, isTrue);
      expect(_wire(model.path), (full as Map)['path'], reason: 'path');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputDragParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('optional keys omit/null/clear and copy ownership', () {
      final model = LiveInputDragParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearKeys: true);
      expect(omitted.rawJson.containsKey('keys'), isFalse);
      expect(omitted.hasKeys, isFalse);
      expect(model.copyWith(keys: model.keys), model);
      final cleared = model.copyWith(keys: null);
      expect(cleared.rawJson.containsKey('keys'), isTrue);
      expect(cleared.toJson()['keys'], isNull);
      expect(cleared.hasKeys, isTrue);
    });
    test('known keys wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['keys'] = 5;
      expect(() => LiveInputDragParam.fromJson(wire), throwsA(_safe('keys')));
      expect(
        () => LiveInputDragParam.fromJson(_clone(full)).copyWith(keys: 5),
        throwsA(_safe('keys')),
      );
    });
    test('required path absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('path');
      expect(() => LiveInputDragParam.fromJson(wire), throwsA(_safe('path')));
    });
    test('known path wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['path'] = 5;
      expect(() => LiveInputDragParam.fromJson(wire), throwsA(_safe('path')));
      expect(
        () => LiveInputDragParam.fromJson(_clone(full)).copyWith(path: 5),
        throwsA(_safe('path')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(() => LiveInputDragParam.fromJson(wire), throwsA(_safe('type')));
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(() => LiveInputDragParam.fromJson(wire), throwsA(_safe('type')));
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputDragParam.fromJson(wire),
        throwsA(_safe('LiveInputDragParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputDragParam.fromJson(wire),
        throwsA(_safe('LiveInputDragParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputDragParam.fromJson(wire),
        throwsA(_safe('LiveInputDragParam')),
      );
    });
  });
  group('EasyInputMessage', () {
    final minimal = {'role': 'user', 'content': 'PRIVATE_LIVE_INPUT_PAYLOAD'};
    final full = {
      'content': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'phase': 'commentary',
      'role': 'user',
      'type': 'message',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveEasyInputMessage.fromJson(_clone(wire));
        final peer = LiveEasyInputMessage.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveEasyInputMessage.fromJson(_clone(full));
      expect(_wire(model.content), (full as Map)['content'], reason: 'content');
      expect(_wire(model.phase), (full as Map)['phase'], reason: 'phase');
      expect(model.hasPhase, isTrue);
      expect(_wire(model.role), (full as Map)['role'], reason: 'role');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
      expect(model.hasType, isTrue);
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveEasyInputMessage.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required content absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('content');
      expect(
        () => LiveEasyInputMessage.fromJson(wire),
        throwsA(_safe('content')),
      );
    });
    test('known content wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['content'] = 5;
      expect(
        () => LiveEasyInputMessage.fromJson(wire),
        throwsA(_safe('content')),
      );
      expect(
        () => LiveEasyInputMessage.fromJson(_clone(full)).copyWith(content: 5),
        throwsA(_safe('content')),
      );
    });
    test('optional phase omit/null/clear and copy ownership', () {
      final model = LiveEasyInputMessage.fromJson(_clone(full));
      final omitted = model.copyWith(clearPhase: true);
      expect(omitted.rawJson.containsKey('phase'), isFalse);
      expect(omitted.hasPhase, isFalse);
      expect(model.copyWith(phase: model.phase), model);
      final cleared = model.copyWith(phase: null);
      expect(cleared.rawJson.containsKey('phase'), isTrue);
      expect(cleared.toJson()['phase'], isNull);
      expect(cleared.hasPhase, isTrue);
    });
    test('known phase wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['phase'] = 5;
      expect(
        () => LiveEasyInputMessage.fromJson(wire),
        throwsA(_safe('phase')),
      );
      expect(
        () => LiveEasyInputMessage.fromJson(_clone(full)).copyWith(phase: 5),
        throwsA(_safe('phase')),
      );
    });
    test('required role absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('role');
      expect(() => LiveEasyInputMessage.fromJson(wire), throwsA(_safe('role')));
    });
    test('known role wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['role'] = 5;
      expect(() => LiveEasyInputMessage.fromJson(wire), throwsA(_safe('role')));
      expect(
        () => LiveEasyInputMessage.fromJson(_clone(full)).copyWith(role: 5),
        throwsA(_safe('role')),
      );
    });
    test('optional type omit/null/clear and copy ownership', () {
      final model = LiveEasyInputMessage.fromJson(_clone(full));
      final omitted = model.copyWith(clearType: true);
      expect(omitted.rawJson.containsKey('type'), isFalse);
      expect(omitted.hasType, isFalse);
      expect(model.copyWith(type: model.type), model);
      expect(() => model.copyWith(type: null), throwsA(_safe('type')));
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(() => LiveEasyInputMessage.fromJson(wire), throwsA(_safe('type')));
      expect(
        () => LiveEasyInputMessage.fromJson(_clone(full)).copyWith(type: 5),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveEasyInputMessage.fromJson(wire),
        throwsA(_safe('LiveEasyInputMessage')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveEasyInputMessage.fromJson(wire),
        throwsA(_safe('LiveEasyInputMessage')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveEasyInputMessage.fromJson(wire),
        throwsA(_safe('LiveEasyInputMessage')),
      );
    });
  });
  group('EmptyModelParam', () {
    final minimal = <String, dynamic>{};
    final full = <String, dynamic>{};
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputEmptyModelParam.fromJson(_clone(wire));
        final peer = LiveInputEmptyModelParam.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputEmptyModelParam.fromJson(_clone(full));
      expect(model.rawJson, isEmpty);
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputEmptyModelParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...full,
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputEmptyModelParam.fromJson(wire),
        throwsA(_safe('LiveInputEmptyModelParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputEmptyModelParam.fromJson(wire),
        throwsA(_safe('LiveInputEmptyModelParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputEmptyModelParam.fromJson(wire),
        throwsA(_safe('LiveInputEmptyModelParam')),
      );
    });
  });
  group('FileCitationBody', () {
    final minimal = {
      'type': 'file_citation',
      'file_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'index': 0,
      'filename': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    final full = {
      'file_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'filename': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'index': 0,
      'type': 'file_citation',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputFileCitationBody.fromJson(_clone(wire));
        final peer = LiveInputFileCitationBody.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputFileCitationBody.fromJson(_clone(full));
      expect(_wire(model.fileId), (full as Map)['file_id'], reason: 'file_id');
      expect(
        _wire(model.filename),
        (full as Map)['filename'],
        reason: 'filename',
      );
      expect(_wire(model.index), (full as Map)['index'], reason: 'index');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputFileCitationBody.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required file_id absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('file_id');
      expect(
        () => LiveInputFileCitationBody.fromJson(wire),
        throwsA(_safe('file_id')),
      );
    });
    test('known file_id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['file_id'] = 5;
      expect(
        () => LiveInputFileCitationBody.fromJson(wire),
        throwsA(_safe('file_id')),
      );
      expect(
        () => LiveInputFileCitationBody.fromJson(
          _clone(full),
        ).copyWith(fileId: 5),
        throwsA(_safe('file_id')),
      );
    });
    test('required filename absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('filename');
      expect(
        () => LiveInputFileCitationBody.fromJson(wire),
        throwsA(_safe('filename')),
      );
    });
    test('known filename wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['filename'] = 5;
      expect(
        () => LiveInputFileCitationBody.fromJson(wire),
        throwsA(_safe('filename')),
      );
      expect(
        () => LiveInputFileCitationBody.fromJson(
          _clone(full),
        ).copyWith(filename: 5),
        throwsA(_safe('filename')),
      );
    });
    test('required index absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('index');
      expect(
        () => LiveInputFileCitationBody.fromJson(wire),
        throwsA(_safe('index')),
      );
    });
    test('known index wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['index'] = false;
      expect(
        () => LiveInputFileCitationBody.fromJson(wire),
        throwsA(_safe('index')),
      );
      expect(
        () => LiveInputFileCitationBody.fromJson(
          _clone(full),
        ).copyWith(index: false),
        throwsA(_safe('index')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputFileCitationBody.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputFileCitationBody.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputFileCitationBody.fromJson(wire),
        throwsA(_safe('LiveInputFileCitationBody')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputFileCitationBody.fromJson(wire),
        throwsA(_safe('LiveInputFileCitationBody')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputFileCitationBody.fromJson(wire),
        throwsA(_safe('LiveInputFileCitationBody')),
      );
    });
  });
  group('FileDetailEnum', () {
    const minimal = 'auto';
    const full = 'auto';
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputFileDetailEnum.fromJson(_clone(wire));
        final peer = LiveInputFileDetailEnum.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('value copy and JSON ownership', () {
      final model = LiveInputFileDetailEnum.fromJson(_clone(full));
      expect(_wire(model.value), full);
      expect(model.copyWith(value: _clone(full)), model);
    });
  });
  group('FileInputDetail', () {
    const minimal = 'auto';
    const full = 'auto';
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputFileInputDetail.fromJson(_clone(wire));
        final peer = LiveInputFileInputDetail.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('value copy and JSON ownership', () {
      final model = LiveInputFileInputDetail.fromJson(_clone(full));
      expect(_wire(model.value), full);
      expect(model.copyWith(value: _clone(full)), model);
    });
  });
  group('FilePath', () {
    final minimal = {
      'type': 'file_path',
      'file_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'index': 0,
    };
    final full = {
      'file_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'index': 0,
      'type': 'file_path',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputFilePath.fromJson(_clone(wire));
        final peer = LiveInputFilePath.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputFilePath.fromJson(_clone(full));
      expect(_wire(model.fileId), (full as Map)['file_id'], reason: 'file_id');
      expect(_wire(model.index), (full as Map)['index'], reason: 'index');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputFilePath.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required file_id absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('file_id');
      expect(() => LiveInputFilePath.fromJson(wire), throwsA(_safe('file_id')));
    });
    test('known file_id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['file_id'] = 5;
      expect(() => LiveInputFilePath.fromJson(wire), throwsA(_safe('file_id')));
      expect(
        () => LiveInputFilePath.fromJson(_clone(full)).copyWith(fileId: 5),
        throwsA(_safe('file_id')),
      );
    });
    test('required index absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('index');
      expect(() => LiveInputFilePath.fromJson(wire), throwsA(_safe('index')));
    });
    test('known index wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['index'] = false;
      expect(() => LiveInputFilePath.fromJson(wire), throwsA(_safe('index')));
      expect(
        () => LiveInputFilePath.fromJson(_clone(full)).copyWith(index: false),
        throwsA(_safe('index')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(() => LiveInputFilePath.fromJson(wire), throwsA(_safe('type')));
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(() => LiveInputFilePath.fromJson(wire), throwsA(_safe('type')));
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputFilePath.fromJson(wire),
        throwsA(_safe('LiveInputFilePath')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputFilePath.fromJson(wire),
        throwsA(_safe('LiveInputFilePath')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputFilePath.fromJson(wire),
        throwsA(_safe('LiveInputFilePath')),
      );
    });
  });
  group('FileSearchTool', () {
    final minimal = {'type': 'file_search', 'vector_store_ids': <dynamic>[]};
    final full = {
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
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputFileSearchTool.fromJson(_clone(wire));
        final peer = LiveInputFileSearchTool.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputFileSearchTool.fromJson(_clone(full));
      expect(_wire(model.filters), (full as Map)['filters'], reason: 'filters');
      expect(model.hasFilters, isTrue);
      expect(
        _wire(model.maxNumResults),
        (full as Map)['max_num_results'],
        reason: 'max_num_results',
      );
      expect(model.hasMaxNumResults, isTrue);
      expect(
        _wire(model.rankingOptions),
        (full as Map)['ranking_options'],
        reason: 'ranking_options',
      );
      expect(model.hasRankingOptions, isTrue);
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
      expect(
        _wire(model.vectorStoreIds),
        (full as Map)['vector_store_ids'],
        reason: 'vector_store_ids',
      );
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputFileSearchTool.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('optional filters omit/null/clear and copy ownership', () {
      final model = LiveInputFileSearchTool.fromJson(_clone(full));
      final omitted = model.copyWith(clearFilters: true);
      expect(omitted.rawJson.containsKey('filters'), isFalse);
      expect(omitted.hasFilters, isFalse);
      expect(model.copyWith(filters: model.filters), model);
      final cleared = model.copyWith(filters: null);
      expect(cleared.rawJson.containsKey('filters'), isTrue);
      expect(cleared.toJson()['filters'], isNull);
      expect(cleared.hasFilters, isTrue);
    });
    test('known filters wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['filters'] = 5;
      expect(
        () => LiveInputFileSearchTool.fromJson(wire),
        throwsA(_safe('filters')),
      );
      expect(
        () =>
            LiveInputFileSearchTool.fromJson(_clone(full)).copyWith(filters: 5),
        throwsA(_safe('filters')),
      );
    });
    test('optional max_num_results omit/null/clear and copy ownership', () {
      final model = LiveInputFileSearchTool.fromJson(_clone(full));
      final omitted = model.copyWith(clearMaxNumResults: true);
      expect(omitted.rawJson.containsKey('max_num_results'), isFalse);
      expect(omitted.hasMaxNumResults, isFalse);
      expect(model.copyWith(maxNumResults: model.maxNumResults), model);
      expect(
        () => model.copyWith(maxNumResults: null),
        throwsA(_safe('max_num_results')),
      );
    });
    test('known max_num_results wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['max_num_results'] = false;
      expect(
        () => LiveInputFileSearchTool.fromJson(wire),
        throwsA(_safe('max_num_results')),
      );
      expect(
        () => LiveInputFileSearchTool.fromJson(
          _clone(full),
        ).copyWith(maxNumResults: false),
        throwsA(_safe('max_num_results')),
      );
    });
    test('optional ranking_options omit/null/clear and copy ownership', () {
      final model = LiveInputFileSearchTool.fromJson(_clone(full));
      final omitted = model.copyWith(clearRankingOptions: true);
      expect(omitted.rawJson.containsKey('ranking_options'), isFalse);
      expect(omitted.hasRankingOptions, isFalse);
      expect(model.copyWith(rankingOptions: model.rankingOptions), model);
      expect(
        () => model.copyWith(rankingOptions: null),
        throwsA(_safe('ranking_options')),
      );
    });
    test('known ranking_options wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['ranking_options'] = 5;
      expect(
        () => LiveInputFileSearchTool.fromJson(wire),
        throwsA(_safe('ranking_options')),
      );
      expect(
        () => LiveInputFileSearchTool.fromJson(
          _clone(full),
        ).copyWith(rankingOptions: 5),
        throwsA(_safe('ranking_options')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputFileSearchTool.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputFileSearchTool.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('required vector_store_ids absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('vector_store_ids');
      expect(
        () => LiveInputFileSearchTool.fromJson(wire),
        throwsA(_safe('vector_store_ids')),
      );
    });
    test('known vector_store_ids wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['vector_store_ids'] = 5;
      expect(
        () => LiveInputFileSearchTool.fromJson(wire),
        throwsA(_safe('vector_store_ids')),
      );
      expect(
        () => LiveInputFileSearchTool.fromJson(
          _clone(full),
        ).copyWith(vectorStoreIds: 5),
        throwsA(_safe('vector_store_ids')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputFileSearchTool.fromJson(wire),
        throwsA(_safe('LiveInputFileSearchTool')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputFileSearchTool.fromJson(wire),
        throwsA(_safe('LiveInputFileSearchTool')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputFileSearchTool.fromJson(wire),
        throwsA(_safe('LiveInputFileSearchTool')),
      );
    });
  });
  group('FileSearchToolCall', () {
    final minimal = {
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'file_search_call',
      'status': 'in_progress',
      'queries': <dynamic>[],
    };
    final full = {
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
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputFileSearchToolCall.fromJson(_clone(wire));
        final peer = LiveInputFileSearchToolCall.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputFileSearchToolCall.fromJson(_clone(full));
      expect(_wire(model.id), (full as Map)['id'], reason: 'id');
      expect(_wire(model.queries), (full as Map)['queries'], reason: 'queries');
      expect(_wire(model.results), (full as Map)['results'], reason: 'results');
      expect(model.hasResults, isTrue);
      expect(_wire(model.status), (full as Map)['status'], reason: 'status');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputFileSearchToolCall.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required id absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('id');
      expect(
        () => LiveInputFileSearchToolCall.fromJson(wire),
        throwsA(_safe('id')),
      );
    });
    test('known id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['id'] = 5;
      expect(
        () => LiveInputFileSearchToolCall.fromJson(wire),
        throwsA(_safe('id')),
      );
      expect(
        () =>
            LiveInputFileSearchToolCall.fromJson(_clone(full)).copyWith(id: 5),
        throwsA(_safe('id')),
      );
    });
    test('required queries absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('queries');
      expect(
        () => LiveInputFileSearchToolCall.fromJson(wire),
        throwsA(_safe('queries')),
      );
    });
    test('known queries wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['queries'] = 5;
      expect(
        () => LiveInputFileSearchToolCall.fromJson(wire),
        throwsA(_safe('queries')),
      );
      expect(
        () => LiveInputFileSearchToolCall.fromJson(
          _clone(full),
        ).copyWith(queries: 5),
        throwsA(_safe('queries')),
      );
    });
    test('optional results omit/null/clear and copy ownership', () {
      final model = LiveInputFileSearchToolCall.fromJson(_clone(full));
      final omitted = model.copyWith(clearResults: true);
      expect(omitted.rawJson.containsKey('results'), isFalse);
      expect(omitted.hasResults, isFalse);
      expect(model.copyWith(results: model.results), model);
      final cleared = model.copyWith(results: null);
      expect(cleared.rawJson.containsKey('results'), isTrue);
      expect(cleared.toJson()['results'], isNull);
      expect(cleared.hasResults, isTrue);
    });
    test('known results wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['results'] = 5;
      expect(
        () => LiveInputFileSearchToolCall.fromJson(wire),
        throwsA(_safe('results')),
      );
      expect(
        () => LiveInputFileSearchToolCall.fromJson(
          _clone(full),
        ).copyWith(results: 5),
        throwsA(_safe('results')),
      );
    });
    test('required status absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('status');
      expect(
        () => LiveInputFileSearchToolCall.fromJson(wire),
        throwsA(_safe('status')),
      );
    });
    test('known status wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['status'] = 5;
      expect(
        () => LiveInputFileSearchToolCall.fromJson(wire),
        throwsA(_safe('status')),
      );
      expect(
        () => LiveInputFileSearchToolCall.fromJson(
          _clone(full),
        ).copyWith(status: 5),
        throwsA(_safe('status')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputFileSearchToolCall.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputFileSearchToolCall.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputFileSearchToolCall.fromJson(wire),
        throwsA(_safe('LiveInputFileSearchToolCall')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputFileSearchToolCall.fromJson(wire),
        throwsA(_safe('LiveInputFileSearchToolCall')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputFileSearchToolCall.fromJson(wire),
        throwsA(_safe('LiveInputFileSearchToolCall')),
      );
    });
  });
  group('Filters', () {
    final minimal = {
      'type': 'eq',
      'key': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'value': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    final full = {
      'key': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'eq',
      'value': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputFilters.fromJson(_clone(wire));
        final peer = LiveInputFilters.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
  });
  group('FunctionAndCustomToolCallOutput', () {
    final minimal = {
      'type': 'input_text',
      'text': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    final full = {
      'prompt_cache_breakpoint': {'mode': 'explicit'},
      'text': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'input_text',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputFunctionAndCustomToolCallOutput.fromJson(
          _clone(wire),
        );
        final peer = LiveInputFunctionAndCustomToolCallOutput.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
  });
  group('FunctionCallItemStatus', () {
    const minimal = 'in_progress';
    const full = 'in_progress';
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputFunctionCallItemStatus.fromJson(_clone(wire));
        final peer = LiveInputFunctionCallItemStatus.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('value copy and JSON ownership', () {
      final model = LiveInputFunctionCallItemStatus.fromJson(_clone(full));
      expect(_wire(model.value), full);
      expect(model.copyWith(value: _clone(full)), model);
    });
  });
  group('FunctionCallOutputItemParam', () {
    final minimal = {
      'type': 'function_call_output',
      'output': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    final full = {
      'call_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'caller': {'type': 'direct'},
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'namespace': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'output': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'status': 'in_progress',
      'type': 'function_call_output',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputFunctionCallOutputItemParam.fromJson(
          _clone(wire),
        );
        final peer = LiveInputFunctionCallOutputItemParam.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputFunctionCallOutputItemParam.fromJson(_clone(full));
      expect(_wire(model.callId), (full as Map)['call_id'], reason: 'call_id');
      expect(model.hasCallId, isTrue);
      expect(_wire(model.caller), (full as Map)['caller'], reason: 'caller');
      expect(model.hasCaller, isTrue);
      expect(_wire(model.id), (full as Map)['id'], reason: 'id');
      expect(model.hasId, isTrue);
      expect(_wire(model.name), (full as Map)['name'], reason: 'name');
      expect(model.hasName, isTrue);
      expect(
        _wire(model.namespace),
        (full as Map)['namespace'],
        reason: 'namespace',
      );
      expect(model.hasNamespace, isTrue);
      expect(_wire(model.output), (full as Map)['output'], reason: 'output');
      expect(_wire(model.status), (full as Map)['status'], reason: 'status');
      expect(model.hasStatus, isTrue);
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputFunctionCallOutputItemParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('optional call_id omit/null/clear and copy ownership', () {
      final model = LiveInputFunctionCallOutputItemParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearCallId: true);
      expect(omitted.rawJson.containsKey('call_id'), isFalse);
      expect(omitted.hasCallId, isFalse);
      expect(model.copyWith(callId: model.callId), model);
      final cleared = model.copyWith(callId: null);
      expect(cleared.rawJson.containsKey('call_id'), isTrue);
      expect(cleared.toJson()['call_id'], isNull);
      expect(cleared.hasCallId, isTrue);
    });
    test('known call_id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['call_id'] = 5;
      expect(
        () => LiveInputFunctionCallOutputItemParam.fromJson(wire),
        throwsA(_safe('call_id')),
      );
      expect(
        () => LiveInputFunctionCallOutputItemParam.fromJson(
          _clone(full),
        ).copyWith(callId: 5),
        throwsA(_safe('call_id')),
      );
    });
    test('optional caller omit/null/clear and copy ownership', () {
      final model = LiveInputFunctionCallOutputItemParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearCaller: true);
      expect(omitted.rawJson.containsKey('caller'), isFalse);
      expect(omitted.hasCaller, isFalse);
      expect(model.copyWith(caller: model.caller), model);
      final cleared = model.copyWith(caller: null);
      expect(cleared.rawJson.containsKey('caller'), isTrue);
      expect(cleared.toJson()['caller'], isNull);
      expect(cleared.hasCaller, isTrue);
    });
    test('known caller wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['caller'] = 5;
      expect(
        () => LiveInputFunctionCallOutputItemParam.fromJson(wire),
        throwsA(_safe('caller')),
      );
      expect(
        () => LiveInputFunctionCallOutputItemParam.fromJson(
          _clone(full),
        ).copyWith(caller: 5),
        throwsA(_safe('caller')),
      );
    });
    test('optional id omit/null/clear and copy ownership', () {
      final model = LiveInputFunctionCallOutputItemParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearId: true);
      expect(omitted.rawJson.containsKey('id'), isFalse);
      expect(omitted.hasId, isFalse);
      expect(model.copyWith(id: model.id), model);
      final cleared = model.copyWith(id: null);
      expect(cleared.rawJson.containsKey('id'), isTrue);
      expect(cleared.toJson()['id'], isNull);
      expect(cleared.hasId, isTrue);
    });
    test('known id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['id'] = 5;
      expect(
        () => LiveInputFunctionCallOutputItemParam.fromJson(wire),
        throwsA(_safe('id')),
      );
      expect(
        () => LiveInputFunctionCallOutputItemParam.fromJson(
          _clone(full),
        ).copyWith(id: 5),
        throwsA(_safe('id')),
      );
    });
    test('optional name omit/null/clear and copy ownership', () {
      final model = LiveInputFunctionCallOutputItemParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearName: true);
      expect(omitted.rawJson.containsKey('name'), isFalse);
      expect(omitted.hasName, isFalse);
      expect(model.copyWith(name: model.name), model);
      final cleared = model.copyWith(name: null);
      expect(cleared.rawJson.containsKey('name'), isTrue);
      expect(cleared.toJson()['name'], isNull);
      expect(cleared.hasName, isTrue);
    });
    test('known name wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['name'] = 5;
      expect(
        () => LiveInputFunctionCallOutputItemParam.fromJson(wire),
        throwsA(_safe('name')),
      );
      expect(
        () => LiveInputFunctionCallOutputItemParam.fromJson(
          _clone(full),
        ).copyWith(name: 5),
        throwsA(_safe('name')),
      );
    });
    test('optional namespace omit/null/clear and copy ownership', () {
      final model = LiveInputFunctionCallOutputItemParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearNamespace: true);
      expect(omitted.rawJson.containsKey('namespace'), isFalse);
      expect(omitted.hasNamespace, isFalse);
      expect(model.copyWith(namespace: model.namespace), model);
      final cleared = model.copyWith(namespace: null);
      expect(cleared.rawJson.containsKey('namespace'), isTrue);
      expect(cleared.toJson()['namespace'], isNull);
      expect(cleared.hasNamespace, isTrue);
    });
    test('known namespace wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['namespace'] = 5;
      expect(
        () => LiveInputFunctionCallOutputItemParam.fromJson(wire),
        throwsA(_safe('namespace')),
      );
      expect(
        () => LiveInputFunctionCallOutputItemParam.fromJson(
          _clone(full),
        ).copyWith(namespace: 5),
        throwsA(_safe('namespace')),
      );
    });
    test('required output absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('output');
      expect(
        () => LiveInputFunctionCallOutputItemParam.fromJson(wire),
        throwsA(_safe('output')),
      );
    });
    test('known output wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['output'] = 5;
      expect(
        () => LiveInputFunctionCallOutputItemParam.fromJson(wire),
        throwsA(_safe('output')),
      );
      expect(
        () => LiveInputFunctionCallOutputItemParam.fromJson(
          _clone(full),
        ).copyWith(output: 5),
        throwsA(_safe('output')),
      );
    });
    test('optional status omit/null/clear and copy ownership', () {
      final model = LiveInputFunctionCallOutputItemParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearStatus: true);
      expect(omitted.rawJson.containsKey('status'), isFalse);
      expect(omitted.hasStatus, isFalse);
      expect(model.copyWith(status: model.status), model);
      final cleared = model.copyWith(status: null);
      expect(cleared.rawJson.containsKey('status'), isTrue);
      expect(cleared.toJson()['status'], isNull);
      expect(cleared.hasStatus, isTrue);
    });
    test('known status wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['status'] = 5;
      expect(
        () => LiveInputFunctionCallOutputItemParam.fromJson(wire),
        throwsA(_safe('status')),
      );
      expect(
        () => LiveInputFunctionCallOutputItemParam.fromJson(
          _clone(full),
        ).copyWith(status: 5),
        throwsA(_safe('status')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputFunctionCallOutputItemParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputFunctionCallOutputItemParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputFunctionCallOutputItemParam.fromJson(wire),
        throwsA(_safe('LiveInputFunctionCallOutputItemParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputFunctionCallOutputItemParam.fromJson(wire),
        throwsA(_safe('LiveInputFunctionCallOutputItemParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputFunctionCallOutputItemParam.fromJson(wire),
        throwsA(_safe('LiveInputFunctionCallOutputItemParam')),
      );
    });
  });
  group('FunctionShellActionParam', () {
    final minimal = {'commands': <dynamic>[]};
    final full = {
      'commands': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
      'max_output_length': 0,
      'timeout_ms': 0,
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputFunctionShellActionParam.fromJson(_clone(wire));
        final peer = LiveInputFunctionShellActionParam.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputFunctionShellActionParam.fromJson(_clone(full));
      expect(
        _wire(model.commands),
        (full as Map)['commands'],
        reason: 'commands',
      );
      expect(
        _wire(model.maxOutputLength),
        (full as Map)['max_output_length'],
        reason: 'max_output_length',
      );
      expect(model.hasMaxOutputLength, isTrue);
      expect(
        _wire(model.timeoutMs),
        (full as Map)['timeout_ms'],
        reason: 'timeout_ms',
      );
      expect(model.hasTimeoutMs, isTrue);
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputFunctionShellActionParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required commands absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('commands');
      expect(
        () => LiveInputFunctionShellActionParam.fromJson(wire),
        throwsA(_safe('commands')),
      );
    });
    test('known commands wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['commands'] = 5;
      expect(
        () => LiveInputFunctionShellActionParam.fromJson(wire),
        throwsA(_safe('commands')),
      );
      expect(
        () => LiveInputFunctionShellActionParam.fromJson(
          _clone(full),
        ).copyWith(commands: 5),
        throwsA(_safe('commands')),
      );
    });
    test('optional max_output_length omit/null/clear and copy ownership', () {
      final model = LiveInputFunctionShellActionParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearMaxOutputLength: true);
      expect(omitted.rawJson.containsKey('max_output_length'), isFalse);
      expect(omitted.hasMaxOutputLength, isFalse);
      expect(model.copyWith(maxOutputLength: model.maxOutputLength), model);
      final cleared = model.copyWith(maxOutputLength: null);
      expect(cleared.rawJson.containsKey('max_output_length'), isTrue);
      expect(cleared.toJson()['max_output_length'], isNull);
      expect(cleared.hasMaxOutputLength, isTrue);
    });
    test('known max_output_length wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['max_output_length'] = false;
      expect(
        () => LiveInputFunctionShellActionParam.fromJson(wire),
        throwsA(_safe('max_output_length')),
      );
      expect(
        () => LiveInputFunctionShellActionParam.fromJson(
          _clone(full),
        ).copyWith(maxOutputLength: false),
        throwsA(_safe('max_output_length')),
      );
    });
    test('optional timeout_ms omit/null/clear and copy ownership', () {
      final model = LiveInputFunctionShellActionParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearTimeoutMs: true);
      expect(omitted.rawJson.containsKey('timeout_ms'), isFalse);
      expect(omitted.hasTimeoutMs, isFalse);
      expect(model.copyWith(timeoutMs: model.timeoutMs), model);
      final cleared = model.copyWith(timeoutMs: null);
      expect(cleared.rawJson.containsKey('timeout_ms'), isTrue);
      expect(cleared.toJson()['timeout_ms'], isNull);
      expect(cleared.hasTimeoutMs, isTrue);
    });
    test('known timeout_ms wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['timeout_ms'] = false;
      expect(
        () => LiveInputFunctionShellActionParam.fromJson(wire),
        throwsA(_safe('timeout_ms')),
      );
      expect(
        () => LiveInputFunctionShellActionParam.fromJson(
          _clone(full),
        ).copyWith(timeoutMs: false),
        throwsA(_safe('timeout_ms')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputFunctionShellActionParam.fromJson(wire),
        throwsA(_safe('LiveInputFunctionShellActionParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputFunctionShellActionParam.fromJson(wire),
        throwsA(_safe('LiveInputFunctionShellActionParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputFunctionShellActionParam.fromJson(wire),
        throwsA(_safe('LiveInputFunctionShellActionParam')),
      );
    });
  });
  group('FunctionShellCallItemParam', () {
    final minimal = {
      'call_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'shell_call',
      'action': {'commands': <dynamic>[]},
    };
    final full = {
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
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputFunctionShellCallItemParam.fromJson(
          _clone(wire),
        );
        final peer = LiveInputFunctionShellCallItemParam.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputFunctionShellCallItemParam.fromJson(_clone(full));
      expect(_wire(model.action), (full as Map)['action'], reason: 'action');
      expect(_wire(model.callId), (full as Map)['call_id'], reason: 'call_id');
      expect(_wire(model.caller), (full as Map)['caller'], reason: 'caller');
      expect(model.hasCaller, isTrue);
      expect(
        _wire(model.environment),
        (full as Map)['environment'],
        reason: 'environment',
      );
      expect(model.hasEnvironment, isTrue);
      expect(_wire(model.id), (full as Map)['id'], reason: 'id');
      expect(model.hasId, isTrue);
      expect(_wire(model.status), (full as Map)['status'], reason: 'status');
      expect(model.hasStatus, isTrue);
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputFunctionShellCallItemParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required action absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('action');
      expect(
        () => LiveInputFunctionShellCallItemParam.fromJson(wire),
        throwsA(_safe('action')),
      );
    });
    test('known action wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['action'] = 5;
      expect(
        () => LiveInputFunctionShellCallItemParam.fromJson(wire),
        throwsA(_safe('action')),
      );
      expect(
        () => LiveInputFunctionShellCallItemParam.fromJson(
          _clone(full),
        ).copyWith(action: 5),
        throwsA(_safe('action')),
      );
    });
    test('required call_id absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('call_id');
      expect(
        () => LiveInputFunctionShellCallItemParam.fromJson(wire),
        throwsA(_safe('call_id')),
      );
    });
    test('known call_id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['call_id'] = 5;
      expect(
        () => LiveInputFunctionShellCallItemParam.fromJson(wire),
        throwsA(_safe('call_id')),
      );
      expect(
        () => LiveInputFunctionShellCallItemParam.fromJson(
          _clone(full),
        ).copyWith(callId: 5),
        throwsA(_safe('call_id')),
      );
    });
    test('optional caller omit/null/clear and copy ownership', () {
      final model = LiveInputFunctionShellCallItemParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearCaller: true);
      expect(omitted.rawJson.containsKey('caller'), isFalse);
      expect(omitted.hasCaller, isFalse);
      expect(model.copyWith(caller: model.caller), model);
      final cleared = model.copyWith(caller: null);
      expect(cleared.rawJson.containsKey('caller'), isTrue);
      expect(cleared.toJson()['caller'], isNull);
      expect(cleared.hasCaller, isTrue);
    });
    test('known caller wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['caller'] = 5;
      expect(
        () => LiveInputFunctionShellCallItemParam.fromJson(wire),
        throwsA(_safe('caller')),
      );
      expect(
        () => LiveInputFunctionShellCallItemParam.fromJson(
          _clone(full),
        ).copyWith(caller: 5),
        throwsA(_safe('caller')),
      );
    });
    test('optional environment omit/null/clear and copy ownership', () {
      final model = LiveInputFunctionShellCallItemParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearEnvironment: true);
      expect(omitted.rawJson.containsKey('environment'), isFalse);
      expect(omitted.hasEnvironment, isFalse);
      expect(model.copyWith(environment: model.environment), model);
      final cleared = model.copyWith(environment: null);
      expect(cleared.rawJson.containsKey('environment'), isTrue);
      expect(cleared.toJson()['environment'], isNull);
      expect(cleared.hasEnvironment, isTrue);
    });
    test('known environment wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['environment'] = 5;
      expect(
        () => LiveInputFunctionShellCallItemParam.fromJson(wire),
        throwsA(_safe('environment')),
      );
      expect(
        () => LiveInputFunctionShellCallItemParam.fromJson(
          _clone(full),
        ).copyWith(environment: 5),
        throwsA(_safe('environment')),
      );
    });
    test('optional id omit/null/clear and copy ownership', () {
      final model = LiveInputFunctionShellCallItemParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearId: true);
      expect(omitted.rawJson.containsKey('id'), isFalse);
      expect(omitted.hasId, isFalse);
      expect(model.copyWith(id: model.id), model);
      final cleared = model.copyWith(id: null);
      expect(cleared.rawJson.containsKey('id'), isTrue);
      expect(cleared.toJson()['id'], isNull);
      expect(cleared.hasId, isTrue);
    });
    test('known id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['id'] = 5;
      expect(
        () => LiveInputFunctionShellCallItemParam.fromJson(wire),
        throwsA(_safe('id')),
      );
      expect(
        () => LiveInputFunctionShellCallItemParam.fromJson(
          _clone(full),
        ).copyWith(id: 5),
        throwsA(_safe('id')),
      );
    });
    test('optional status omit/null/clear and copy ownership', () {
      final model = LiveInputFunctionShellCallItemParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearStatus: true);
      expect(omitted.rawJson.containsKey('status'), isFalse);
      expect(omitted.hasStatus, isFalse);
      expect(model.copyWith(status: model.status), model);
      final cleared = model.copyWith(status: null);
      expect(cleared.rawJson.containsKey('status'), isTrue);
      expect(cleared.toJson()['status'], isNull);
      expect(cleared.hasStatus, isTrue);
    });
    test('known status wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['status'] = 5;
      expect(
        () => LiveInputFunctionShellCallItemParam.fromJson(wire),
        throwsA(_safe('status')),
      );
      expect(
        () => LiveInputFunctionShellCallItemParam.fromJson(
          _clone(full),
        ).copyWith(status: 5),
        throwsA(_safe('status')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputFunctionShellCallItemParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputFunctionShellCallItemParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputFunctionShellCallItemParam.fromJson(wire),
        throwsA(_safe('LiveInputFunctionShellCallItemParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputFunctionShellCallItemParam.fromJson(wire),
        throwsA(_safe('LiveInputFunctionShellCallItemParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputFunctionShellCallItemParam.fromJson(wire),
        throwsA(_safe('LiveInputFunctionShellCallItemParam')),
      );
    });
  });
  group('FunctionShellCallItemStatus', () {
    const minimal = 'in_progress';
    const full = 'in_progress';
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputFunctionShellCallItemStatus.fromJson(
          _clone(wire),
        );
        final peer = LiveInputFunctionShellCallItemStatus.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('value copy and JSON ownership', () {
      final model = LiveInputFunctionShellCallItemStatus.fromJson(_clone(full));
      expect(_wire(model.value), full);
      expect(model.copyWith(value: _clone(full)), model);
    });
  });
  group('FunctionShellCallOutputContentParam', () {
    final minimal = {
      'stdout': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'stderr': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'outcome': {'type': 'timeout'},
    };
    final full = {
      'outcome': {'type': 'timeout'},
      'stderr': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'stdout': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputFunctionShellCallOutputContentParam.fromJson(
          _clone(wire),
        );
        final peer = LiveInputFunctionShellCallOutputContentParam.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputFunctionShellCallOutputContentParam.fromJson(
        _clone(full),
      );
      expect(_wire(model.outcome), (full as Map)['outcome'], reason: 'outcome');
      expect(_wire(model.stderr), (full as Map)['stderr'], reason: 'stderr');
      expect(_wire(model.stdout), (full as Map)['stdout'], reason: 'stdout');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputFunctionShellCallOutputContentParam.fromJson(
        source,
      );
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required outcome absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('outcome');
      expect(
        () => LiveInputFunctionShellCallOutputContentParam.fromJson(wire),
        throwsA(_safe('outcome')),
      );
    });
    test('known outcome wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['outcome'] = 5;
      expect(
        () => LiveInputFunctionShellCallOutputContentParam.fromJson(wire),
        throwsA(_safe('outcome')),
      );
      expect(
        () => LiveInputFunctionShellCallOutputContentParam.fromJson(
          _clone(full),
        ).copyWith(outcome: 5),
        throwsA(_safe('outcome')),
      );
    });
    test('required stderr absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('stderr');
      expect(
        () => LiveInputFunctionShellCallOutputContentParam.fromJson(wire),
        throwsA(_safe('stderr')),
      );
    });
    test('known stderr wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['stderr'] = 5;
      expect(
        () => LiveInputFunctionShellCallOutputContentParam.fromJson(wire),
        throwsA(_safe('stderr')),
      );
      expect(
        () => LiveInputFunctionShellCallOutputContentParam.fromJson(
          _clone(full),
        ).copyWith(stderr: 5),
        throwsA(_safe('stderr')),
      );
    });
    test('required stdout absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('stdout');
      expect(
        () => LiveInputFunctionShellCallOutputContentParam.fromJson(wire),
        throwsA(_safe('stdout')),
      );
    });
    test('known stdout wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['stdout'] = 5;
      expect(
        () => LiveInputFunctionShellCallOutputContentParam.fromJson(wire),
        throwsA(_safe('stdout')),
      );
      expect(
        () => LiveInputFunctionShellCallOutputContentParam.fromJson(
          _clone(full),
        ).copyWith(stdout: 5),
        throwsA(_safe('stdout')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputFunctionShellCallOutputContentParam.fromJson(wire),
        throwsA(_safe('LiveInputFunctionShellCallOutputContentParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputFunctionShellCallOutputContentParam.fromJson(wire),
        throwsA(_safe('LiveInputFunctionShellCallOutputContentParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputFunctionShellCallOutputContentParam.fromJson(wire),
        throwsA(_safe('LiveInputFunctionShellCallOutputContentParam')),
      );
    });
  });
  group('FunctionShellCallOutputExitOutcomeParam', () {
    final minimal = {'type': 'exit', 'exit_code': 0};
    final full = {'exit_code': 0, 'type': 'exit'};
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputFunctionShellCallOutputExitOutcomeParam.fromJson(
          _clone(wire),
        );
        final peer = LiveInputFunctionShellCallOutputExitOutcomeParam.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputFunctionShellCallOutputExitOutcomeParam.fromJson(
        _clone(full),
      );
      expect(
        _wire(model.exitCode),
        (full as Map)['exit_code'],
        reason: 'exit_code',
      );
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputFunctionShellCallOutputExitOutcomeParam.fromJson(
        source,
      );
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required exit_code absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('exit_code');
      expect(
        () => LiveInputFunctionShellCallOutputExitOutcomeParam.fromJson(wire),
        throwsA(_safe('exit_code')),
      );
    });
    test('known exit_code wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['exit_code'] = false;
      expect(
        () => LiveInputFunctionShellCallOutputExitOutcomeParam.fromJson(wire),
        throwsA(_safe('exit_code')),
      );
      expect(
        () => LiveInputFunctionShellCallOutputExitOutcomeParam.fromJson(
          _clone(full),
        ).copyWith(exitCode: false),
        throwsA(_safe('exit_code')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputFunctionShellCallOutputExitOutcomeParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputFunctionShellCallOutputExitOutcomeParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputFunctionShellCallOutputExitOutcomeParam.fromJson(wire),
        throwsA(_safe('LiveInputFunctionShellCallOutputExitOutcomeParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputFunctionShellCallOutputExitOutcomeParam.fromJson(wire),
        throwsA(_safe('LiveInputFunctionShellCallOutputExitOutcomeParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputFunctionShellCallOutputExitOutcomeParam.fromJson(wire),
        throwsA(_safe('LiveInputFunctionShellCallOutputExitOutcomeParam')),
      );
    });
  });
  group('FunctionShellCallOutputItemParam', () {
    final minimal = {
      'call_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'shell_call_output',
      'output': <dynamic>[],
    };
    final full = {
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
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputFunctionShellCallOutputItemParam.fromJson(
          _clone(wire),
        );
        final peer = LiveInputFunctionShellCallOutputItemParam.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputFunctionShellCallOutputItemParam.fromJson(
        _clone(full),
      );
      expect(_wire(model.callId), (full as Map)['call_id'], reason: 'call_id');
      expect(_wire(model.caller), (full as Map)['caller'], reason: 'caller');
      expect(model.hasCaller, isTrue);
      expect(_wire(model.id), (full as Map)['id'], reason: 'id');
      expect(model.hasId, isTrue);
      expect(
        _wire(model.maxOutputLength),
        (full as Map)['max_output_length'],
        reason: 'max_output_length',
      );
      expect(model.hasMaxOutputLength, isTrue);
      expect(_wire(model.output), (full as Map)['output'], reason: 'output');
      expect(_wire(model.status), (full as Map)['status'], reason: 'status');
      expect(model.hasStatus, isTrue);
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputFunctionShellCallOutputItemParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required call_id absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('call_id');
      expect(
        () => LiveInputFunctionShellCallOutputItemParam.fromJson(wire),
        throwsA(_safe('call_id')),
      );
    });
    test('known call_id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['call_id'] = 5;
      expect(
        () => LiveInputFunctionShellCallOutputItemParam.fromJson(wire),
        throwsA(_safe('call_id')),
      );
      expect(
        () => LiveInputFunctionShellCallOutputItemParam.fromJson(
          _clone(full),
        ).copyWith(callId: 5),
        throwsA(_safe('call_id')),
      );
    });
    test('optional caller omit/null/clear and copy ownership', () {
      final model = LiveInputFunctionShellCallOutputItemParam.fromJson(
        _clone(full),
      );
      final omitted = model.copyWith(clearCaller: true);
      expect(omitted.rawJson.containsKey('caller'), isFalse);
      expect(omitted.hasCaller, isFalse);
      expect(model.copyWith(caller: model.caller), model);
      final cleared = model.copyWith(caller: null);
      expect(cleared.rawJson.containsKey('caller'), isTrue);
      expect(cleared.toJson()['caller'], isNull);
      expect(cleared.hasCaller, isTrue);
    });
    test('known caller wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['caller'] = 5;
      expect(
        () => LiveInputFunctionShellCallOutputItemParam.fromJson(wire),
        throwsA(_safe('caller')),
      );
      expect(
        () => LiveInputFunctionShellCallOutputItemParam.fromJson(
          _clone(full),
        ).copyWith(caller: 5),
        throwsA(_safe('caller')),
      );
    });
    test('optional id omit/null/clear and copy ownership', () {
      final model = LiveInputFunctionShellCallOutputItemParam.fromJson(
        _clone(full),
      );
      final omitted = model.copyWith(clearId: true);
      expect(omitted.rawJson.containsKey('id'), isFalse);
      expect(omitted.hasId, isFalse);
      expect(model.copyWith(id: model.id), model);
      final cleared = model.copyWith(id: null);
      expect(cleared.rawJson.containsKey('id'), isTrue);
      expect(cleared.toJson()['id'], isNull);
      expect(cleared.hasId, isTrue);
    });
    test('known id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['id'] = 5;
      expect(
        () => LiveInputFunctionShellCallOutputItemParam.fromJson(wire),
        throwsA(_safe('id')),
      );
      expect(
        () => LiveInputFunctionShellCallOutputItemParam.fromJson(
          _clone(full),
        ).copyWith(id: 5),
        throwsA(_safe('id')),
      );
    });
    test('optional max_output_length omit/null/clear and copy ownership', () {
      final model = LiveInputFunctionShellCallOutputItemParam.fromJson(
        _clone(full),
      );
      final omitted = model.copyWith(clearMaxOutputLength: true);
      expect(omitted.rawJson.containsKey('max_output_length'), isFalse);
      expect(omitted.hasMaxOutputLength, isFalse);
      expect(model.copyWith(maxOutputLength: model.maxOutputLength), model);
      final cleared = model.copyWith(maxOutputLength: null);
      expect(cleared.rawJson.containsKey('max_output_length'), isTrue);
      expect(cleared.toJson()['max_output_length'], isNull);
      expect(cleared.hasMaxOutputLength, isTrue);
    });
    test('known max_output_length wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['max_output_length'] = false;
      expect(
        () => LiveInputFunctionShellCallOutputItemParam.fromJson(wire),
        throwsA(_safe('max_output_length')),
      );
      expect(
        () => LiveInputFunctionShellCallOutputItemParam.fromJson(
          _clone(full),
        ).copyWith(maxOutputLength: false),
        throwsA(_safe('max_output_length')),
      );
    });
    test('required output absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('output');
      expect(
        () => LiveInputFunctionShellCallOutputItemParam.fromJson(wire),
        throwsA(_safe('output')),
      );
    });
    test('known output wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['output'] = 5;
      expect(
        () => LiveInputFunctionShellCallOutputItemParam.fromJson(wire),
        throwsA(_safe('output')),
      );
      expect(
        () => LiveInputFunctionShellCallOutputItemParam.fromJson(
          _clone(full),
        ).copyWith(output: 5),
        throwsA(_safe('output')),
      );
    });
    test('optional status omit/null/clear and copy ownership', () {
      final model = LiveInputFunctionShellCallOutputItemParam.fromJson(
        _clone(full),
      );
      final omitted = model.copyWith(clearStatus: true);
      expect(omitted.rawJson.containsKey('status'), isFalse);
      expect(omitted.hasStatus, isFalse);
      expect(model.copyWith(status: model.status), model);
      final cleared = model.copyWith(status: null);
      expect(cleared.rawJson.containsKey('status'), isTrue);
      expect(cleared.toJson()['status'], isNull);
      expect(cleared.hasStatus, isTrue);
    });
    test('known status wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['status'] = 5;
      expect(
        () => LiveInputFunctionShellCallOutputItemParam.fromJson(wire),
        throwsA(_safe('status')),
      );
      expect(
        () => LiveInputFunctionShellCallOutputItemParam.fromJson(
          _clone(full),
        ).copyWith(status: 5),
        throwsA(_safe('status')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputFunctionShellCallOutputItemParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputFunctionShellCallOutputItemParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputFunctionShellCallOutputItemParam.fromJson(wire),
        throwsA(_safe('LiveInputFunctionShellCallOutputItemParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputFunctionShellCallOutputItemParam.fromJson(wire),
        throwsA(_safe('LiveInputFunctionShellCallOutputItemParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputFunctionShellCallOutputItemParam.fromJson(wire),
        throwsA(_safe('LiveInputFunctionShellCallOutputItemParam')),
      );
    });
  });
  group('FunctionShellCallOutputOutcomeParam', () {
    final minimal = {'type': 'timeout'};
    final full = {'type': 'timeout'};
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputFunctionShellCallOutputOutcomeParam.fromJson(
          _clone(wire),
        );
        final peer = LiveInputFunctionShellCallOutputOutcomeParam.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
  });
  group('FunctionShellCallOutputTimeoutOutcomeParam', () {
    final minimal = {'type': 'timeout'};
    final full = {'type': 'timeout'};
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model =
            LiveInputFunctionShellCallOutputTimeoutOutcomeParam.fromJson(
              _clone(wire),
            );
        final peer =
            LiveInputFunctionShellCallOutputTimeoutOutcomeParam.fromJson(
              _clone(wire),
            );
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model =
          LiveInputFunctionShellCallOutputTimeoutOutcomeParam.fromJson(
            _clone(full),
          );
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model =
          LiveInputFunctionShellCallOutputTimeoutOutcomeParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () =>
            LiveInputFunctionShellCallOutputTimeoutOutcomeParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () =>
            LiveInputFunctionShellCallOutputTimeoutOutcomeParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () =>
            LiveInputFunctionShellCallOutputTimeoutOutcomeParam.fromJson(wire),
        throwsA(_safe('LiveInputFunctionShellCallOutputTimeoutOutcomeParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () =>
            LiveInputFunctionShellCallOutputTimeoutOutcomeParam.fromJson(wire),
        throwsA(_safe('LiveInputFunctionShellCallOutputTimeoutOutcomeParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () =>
            LiveInputFunctionShellCallOutputTimeoutOutcomeParam.fromJson(wire),
        throwsA(_safe('LiveInputFunctionShellCallOutputTimeoutOutcomeParam')),
      );
    });
  });
  group('FunctionShellToolParam', () {
    final minimal = {'type': 'shell'};
    final full = {
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
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputFunctionShellToolParam.fromJson(_clone(wire));
        final peer = LiveInputFunctionShellToolParam.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputFunctionShellToolParam.fromJson(_clone(full));
      expect(
        _wire(model.allowedCallers),
        (full as Map)['allowed_callers'],
        reason: 'allowed_callers',
      );
      expect(model.hasAllowedCallers, isTrue);
      expect(
        _wire(model.environment),
        (full as Map)['environment'],
        reason: 'environment',
      );
      expect(model.hasEnvironment, isTrue);
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputFunctionShellToolParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('optional allowed_callers omit/null/clear and copy ownership', () {
      final model = LiveInputFunctionShellToolParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearAllowedCallers: true);
      expect(omitted.rawJson.containsKey('allowed_callers'), isFalse);
      expect(omitted.hasAllowedCallers, isFalse);
      expect(model.copyWith(allowedCallers: model.allowedCallers), model);
      final cleared = model.copyWith(allowedCallers: null);
      expect(cleared.rawJson.containsKey('allowed_callers'), isTrue);
      expect(cleared.toJson()['allowed_callers'], isNull);
      expect(cleared.hasAllowedCallers, isTrue);
    });
    test('known allowed_callers wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['allowed_callers'] = 5;
      expect(
        () => LiveInputFunctionShellToolParam.fromJson(wire),
        throwsA(_safe('allowed_callers')),
      );
      expect(
        () => LiveInputFunctionShellToolParam.fromJson(
          _clone(full),
        ).copyWith(allowedCallers: 5),
        throwsA(_safe('allowed_callers')),
      );
    });
    test('optional environment omit/null/clear and copy ownership', () {
      final model = LiveInputFunctionShellToolParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearEnvironment: true);
      expect(omitted.rawJson.containsKey('environment'), isFalse);
      expect(omitted.hasEnvironment, isFalse);
      expect(model.copyWith(environment: model.environment), model);
      final cleared = model.copyWith(environment: null);
      expect(cleared.rawJson.containsKey('environment'), isTrue);
      expect(cleared.toJson()['environment'], isNull);
      expect(cleared.hasEnvironment, isTrue);
    });
    test('known environment wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['environment'] = 5;
      expect(
        () => LiveInputFunctionShellToolParam.fromJson(wire),
        throwsA(_safe('environment')),
      );
      expect(
        () => LiveInputFunctionShellToolParam.fromJson(
          _clone(full),
        ).copyWith(environment: 5),
        throwsA(_safe('environment')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputFunctionShellToolParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputFunctionShellToolParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputFunctionShellToolParam.fromJson(wire),
        throwsA(_safe('LiveInputFunctionShellToolParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputFunctionShellToolParam.fromJson(wire),
        throwsA(_safe('LiveInputFunctionShellToolParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputFunctionShellToolParam.fromJson(wire),
        throwsA(_safe('LiveInputFunctionShellToolParam')),
      );
    });
  });
  group('FunctionTool', () {
    final minimal = {
      'type': 'function',
      'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'strict': false,
      'parameters': <String, dynamic>{},
    };
    final full = {
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
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputFunctionTool.fromJson(_clone(wire));
        final peer = LiveInputFunctionTool.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputFunctionTool.fromJson(_clone(full));
      expect(
        _wire(model.allowedCallers),
        (full as Map)['allowed_callers'],
        reason: 'allowed_callers',
      );
      expect(model.hasAllowedCallers, isTrue);
      expect(_wire(model.async), (full as Map)['async'], reason: 'async');
      expect(model.hasAsync, isTrue);
      expect(
        _wire(model.deferLoading),
        (full as Map)['defer_loading'],
        reason: 'defer_loading',
      );
      expect(model.hasDeferLoading, isTrue);
      expect(
        _wire(model.description),
        (full as Map)['description'],
        reason: 'description',
      );
      expect(model.hasDescription, isTrue);
      expect(_wire(model.name), (full as Map)['name'], reason: 'name');
      expect(
        _wire(model.outputSchema),
        (full as Map)['output_schema'],
        reason: 'output_schema',
      );
      expect(model.hasOutputSchema, isTrue);
      expect(
        _wire(model.parameters),
        (full as Map)['parameters'],
        reason: 'parameters',
      );
      expect(_wire(model.strict), (full as Map)['strict'], reason: 'strict');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputFunctionTool.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('optional allowed_callers omit/null/clear and copy ownership', () {
      final model = LiveInputFunctionTool.fromJson(_clone(full));
      final omitted = model.copyWith(clearAllowedCallers: true);
      expect(omitted.rawJson.containsKey('allowed_callers'), isFalse);
      expect(omitted.hasAllowedCallers, isFalse);
      expect(model.copyWith(allowedCallers: model.allowedCallers), model);
      final cleared = model.copyWith(allowedCallers: null);
      expect(cleared.rawJson.containsKey('allowed_callers'), isTrue);
      expect(cleared.toJson()['allowed_callers'], isNull);
      expect(cleared.hasAllowedCallers, isTrue);
    });
    test('known allowed_callers wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['allowed_callers'] = 5;
      expect(
        () => LiveInputFunctionTool.fromJson(wire),
        throwsA(_safe('allowed_callers')),
      );
      expect(
        () => LiveInputFunctionTool.fromJson(
          _clone(full),
        ).copyWith(allowedCallers: 5),
        throwsA(_safe('allowed_callers')),
      );
    });
    test('optional async omit/null/clear and copy ownership', () {
      final model = LiveInputFunctionTool.fromJson(_clone(full));
      final omitted = model.copyWith(clearAsync: true);
      expect(omitted.rawJson.containsKey('async'), isFalse);
      expect(omitted.hasAsync, isFalse);
      expect(model.copyWith(async: model.async), model);
      expect(() => model.copyWith(async: null), throwsA(_safe('async')));
    });
    test('known async wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['async'] = 5;
      expect(
        () => LiveInputFunctionTool.fromJson(wire),
        throwsA(_safe('async')),
      );
      expect(
        () => LiveInputFunctionTool.fromJson(_clone(full)).copyWith(async: 5),
        throwsA(_safe('async')),
      );
    });
    test('optional defer_loading omit/null/clear and copy ownership', () {
      final model = LiveInputFunctionTool.fromJson(_clone(full));
      final omitted = model.copyWith(clearDeferLoading: true);
      expect(omitted.rawJson.containsKey('defer_loading'), isFalse);
      expect(omitted.hasDeferLoading, isFalse);
      expect(model.copyWith(deferLoading: model.deferLoading), model);
      expect(
        () => model.copyWith(deferLoading: null),
        throwsA(_safe('defer_loading')),
      );
    });
    test('known defer_loading wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['defer_loading'] = 5;
      expect(
        () => LiveInputFunctionTool.fromJson(wire),
        throwsA(_safe('defer_loading')),
      );
      expect(
        () => LiveInputFunctionTool.fromJson(
          _clone(full),
        ).copyWith(deferLoading: 5),
        throwsA(_safe('defer_loading')),
      );
    });
    test('optional description omit/null/clear and copy ownership', () {
      final model = LiveInputFunctionTool.fromJson(_clone(full));
      final omitted = model.copyWith(clearDescription: true);
      expect(omitted.rawJson.containsKey('description'), isFalse);
      expect(omitted.hasDescription, isFalse);
      expect(model.copyWith(description: model.description), model);
      final cleared = model.copyWith(description: null);
      expect(cleared.rawJson.containsKey('description'), isTrue);
      expect(cleared.toJson()['description'], isNull);
      expect(cleared.hasDescription, isTrue);
    });
    test('known description wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['description'] = 5;
      expect(
        () => LiveInputFunctionTool.fromJson(wire),
        throwsA(_safe('description')),
      );
      expect(
        () => LiveInputFunctionTool.fromJson(
          _clone(full),
        ).copyWith(description: 5),
        throwsA(_safe('description')),
      );
    });
    test('required name absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('name');
      expect(
        () => LiveInputFunctionTool.fromJson(wire),
        throwsA(_safe('name')),
      );
    });
    test('known name wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['name'] = 5;
      expect(
        () => LiveInputFunctionTool.fromJson(wire),
        throwsA(_safe('name')),
      );
      expect(
        () => LiveInputFunctionTool.fromJson(_clone(full)).copyWith(name: 5),
        throwsA(_safe('name')),
      );
    });
    test('optional output_schema omit/null/clear and copy ownership', () {
      final model = LiveInputFunctionTool.fromJson(_clone(full));
      final omitted = model.copyWith(clearOutputSchema: true);
      expect(omitted.rawJson.containsKey('output_schema'), isFalse);
      expect(omitted.hasOutputSchema, isFalse);
      expect(model.copyWith(outputSchema: model.outputSchema), model);
      final cleared = model.copyWith(outputSchema: null);
      expect(cleared.rawJson.containsKey('output_schema'), isTrue);
      expect(cleared.toJson()['output_schema'], isNull);
      expect(cleared.hasOutputSchema, isTrue);
    });
    test('known output_schema wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['output_schema'] = 5;
      expect(
        () => LiveInputFunctionTool.fromJson(wire),
        throwsA(_safe('output_schema')),
      );
      expect(
        () => LiveInputFunctionTool.fromJson(
          _clone(full),
        ).copyWith(outputSchema: 5),
        throwsA(_safe('output_schema')),
      );
    });
    test('required parameters absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('parameters');
      expect(
        () => LiveInputFunctionTool.fromJson(wire),
        throwsA(_safe('parameters')),
      );
    });
    test('known parameters wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['parameters'] = 5;
      expect(
        () => LiveInputFunctionTool.fromJson(wire),
        throwsA(_safe('parameters')),
      );
      expect(
        () => LiveInputFunctionTool.fromJson(
          _clone(full),
        ).copyWith(parameters: 5),
        throwsA(_safe('parameters')),
      );
    });
    test('required strict absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('strict');
      expect(
        () => LiveInputFunctionTool.fromJson(wire),
        throwsA(_safe('strict')),
      );
    });
    test('known strict wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['strict'] = 5;
      expect(
        () => LiveInputFunctionTool.fromJson(wire),
        throwsA(_safe('strict')),
      );
      expect(
        () => LiveInputFunctionTool.fromJson(_clone(full)).copyWith(strict: 5),
        throwsA(_safe('strict')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputFunctionTool.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputFunctionTool.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputFunctionTool.fromJson(wire),
        throwsA(_safe('LiveInputFunctionTool')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputFunctionTool.fromJson(wire),
        throwsA(_safe('LiveInputFunctionTool')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputFunctionTool.fromJson(wire),
        throwsA(_safe('LiveInputFunctionTool')),
      );
    });
  });
  group('FunctionToolCall', () {
    final minimal = {
      'type': 'function_call',
      'call_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'arguments': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    final full = {
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
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputFunctionToolCall.fromJson(_clone(wire));
        final peer = LiveInputFunctionToolCall.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputFunctionToolCall.fromJson(_clone(full));
      expect(
        _wire(model.arguments),
        (full as Map)['arguments'],
        reason: 'arguments',
      );
      expect(_wire(model.async), (full as Map)['async'], reason: 'async');
      expect(model.hasAsync, isTrue);
      expect(_wire(model.callId), (full as Map)['call_id'], reason: 'call_id');
      expect(_wire(model.caller), (full as Map)['caller'], reason: 'caller');
      expect(model.hasCaller, isTrue);
      expect(_wire(model.id), (full as Map)['id'], reason: 'id');
      expect(model.hasId, isTrue);
      expect(_wire(model.name), (full as Map)['name'], reason: 'name');
      expect(
        _wire(model.namespace),
        (full as Map)['namespace'],
        reason: 'namespace',
      );
      expect(model.hasNamespace, isTrue);
      expect(_wire(model.status), (full as Map)['status'], reason: 'status');
      expect(model.hasStatus, isTrue);
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputFunctionToolCall.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required arguments absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('arguments');
      expect(
        () => LiveInputFunctionToolCall.fromJson(wire),
        throwsA(_safe('arguments')),
      );
    });
    test('known arguments wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['arguments'] = 5;
      expect(
        () => LiveInputFunctionToolCall.fromJson(wire),
        throwsA(_safe('arguments')),
      );
      expect(
        () => LiveInputFunctionToolCall.fromJson(
          _clone(full),
        ).copyWith(arguments: 5),
        throwsA(_safe('arguments')),
      );
    });
    test('optional async omit/null/clear and copy ownership', () {
      final model = LiveInputFunctionToolCall.fromJson(_clone(full));
      final omitted = model.copyWith(clearAsync: true);
      expect(omitted.rawJson.containsKey('async'), isFalse);
      expect(omitted.hasAsync, isFalse);
      expect(model.copyWith(async: model.async), model);
      expect(() => model.copyWith(async: null), throwsA(_safe('async')));
    });
    test('known async wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['async'] = 5;
      expect(
        () => LiveInputFunctionToolCall.fromJson(wire),
        throwsA(_safe('async')),
      );
      expect(
        () =>
            LiveInputFunctionToolCall.fromJson(_clone(full)).copyWith(async: 5),
        throwsA(_safe('async')),
      );
    });
    test('required call_id absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('call_id');
      expect(
        () => LiveInputFunctionToolCall.fromJson(wire),
        throwsA(_safe('call_id')),
      );
    });
    test('known call_id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['call_id'] = 5;
      expect(
        () => LiveInputFunctionToolCall.fromJson(wire),
        throwsA(_safe('call_id')),
      );
      expect(
        () => LiveInputFunctionToolCall.fromJson(
          _clone(full),
        ).copyWith(callId: 5),
        throwsA(_safe('call_id')),
      );
    });
    test('optional caller omit/null/clear and copy ownership', () {
      final model = LiveInputFunctionToolCall.fromJson(_clone(full));
      final omitted = model.copyWith(clearCaller: true);
      expect(omitted.rawJson.containsKey('caller'), isFalse);
      expect(omitted.hasCaller, isFalse);
      expect(model.copyWith(caller: model.caller), model);
      final cleared = model.copyWith(caller: null);
      expect(cleared.rawJson.containsKey('caller'), isTrue);
      expect(cleared.toJson()['caller'], isNull);
      expect(cleared.hasCaller, isTrue);
    });
    test('known caller wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['caller'] = 5;
      expect(
        () => LiveInputFunctionToolCall.fromJson(wire),
        throwsA(_safe('caller')),
      );
      expect(
        () => LiveInputFunctionToolCall.fromJson(
          _clone(full),
        ).copyWith(caller: 5),
        throwsA(_safe('caller')),
      );
    });
    test('optional id omit/null/clear and copy ownership', () {
      final model = LiveInputFunctionToolCall.fromJson(_clone(full));
      final omitted = model.copyWith(clearId: true);
      expect(omitted.rawJson.containsKey('id'), isFalse);
      expect(omitted.hasId, isFalse);
      expect(model.copyWith(id: model.id), model);
      expect(() => model.copyWith(id: null), throwsA(_safe('id')));
    });
    test('known id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['id'] = 5;
      expect(
        () => LiveInputFunctionToolCall.fromJson(wire),
        throwsA(_safe('id')),
      );
      expect(
        () => LiveInputFunctionToolCall.fromJson(_clone(full)).copyWith(id: 5),
        throwsA(_safe('id')),
      );
    });
    test('required name absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('name');
      expect(
        () => LiveInputFunctionToolCall.fromJson(wire),
        throwsA(_safe('name')),
      );
    });
    test('known name wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['name'] = 5;
      expect(
        () => LiveInputFunctionToolCall.fromJson(wire),
        throwsA(_safe('name')),
      );
      expect(
        () =>
            LiveInputFunctionToolCall.fromJson(_clone(full)).copyWith(name: 5),
        throwsA(_safe('name')),
      );
    });
    test('optional namespace omit/null/clear and copy ownership', () {
      final model = LiveInputFunctionToolCall.fromJson(_clone(full));
      final omitted = model.copyWith(clearNamespace: true);
      expect(omitted.rawJson.containsKey('namespace'), isFalse);
      expect(omitted.hasNamespace, isFalse);
      expect(model.copyWith(namespace: model.namespace), model);
      expect(
        () => model.copyWith(namespace: null),
        throwsA(_safe('namespace')),
      );
    });
    test('known namespace wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['namespace'] = 5;
      expect(
        () => LiveInputFunctionToolCall.fromJson(wire),
        throwsA(_safe('namespace')),
      );
      expect(
        () => LiveInputFunctionToolCall.fromJson(
          _clone(full),
        ).copyWith(namespace: 5),
        throwsA(_safe('namespace')),
      );
    });
    test('optional status omit/null/clear and copy ownership', () {
      final model = LiveInputFunctionToolCall.fromJson(_clone(full));
      final omitted = model.copyWith(clearStatus: true);
      expect(omitted.rawJson.containsKey('status'), isFalse);
      expect(omitted.hasStatus, isFalse);
      expect(model.copyWith(status: model.status), model);
      expect(() => model.copyWith(status: null), throwsA(_safe('status')));
    });
    test('known status wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['status'] = 5;
      expect(
        () => LiveInputFunctionToolCall.fromJson(wire),
        throwsA(_safe('status')),
      );
      expect(
        () => LiveInputFunctionToolCall.fromJson(
          _clone(full),
        ).copyWith(status: 5),
        throwsA(_safe('status')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputFunctionToolCall.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputFunctionToolCall.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputFunctionToolCall.fromJson(wire),
        throwsA(_safe('LiveInputFunctionToolCall')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputFunctionToolCall.fromJson(wire),
        throwsA(_safe('LiveInputFunctionToolCall')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputFunctionToolCall.fromJson(wire),
        throwsA(_safe('LiveInputFunctionToolCall')),
      );
    });
  });
  group('FunctionToolParam', () {
    final minimal = {'name': 'PRIVATE_LIVE_INPUT_PAYLOAD', 'type': 'function'};
    final full = {
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
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputFunctionToolParam.fromJson(_clone(wire));
        final peer = LiveInputFunctionToolParam.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputFunctionToolParam.fromJson(_clone(full));
      expect(
        _wire(model.allowedCallers),
        (full as Map)['allowed_callers'],
        reason: 'allowed_callers',
      );
      expect(model.hasAllowedCallers, isTrue);
      expect(_wire(model.async), (full as Map)['async'], reason: 'async');
      expect(model.hasAsync, isTrue);
      expect(
        _wire(model.deferLoading),
        (full as Map)['defer_loading'],
        reason: 'defer_loading',
      );
      expect(model.hasDeferLoading, isTrue);
      expect(
        _wire(model.description),
        (full as Map)['description'],
        reason: 'description',
      );
      expect(model.hasDescription, isTrue);
      expect(_wire(model.name), (full as Map)['name'], reason: 'name');
      expect(
        _wire(model.outputSchema),
        (full as Map)['output_schema'],
        reason: 'output_schema',
      );
      expect(model.hasOutputSchema, isTrue);
      expect(
        _wire(model.parameters),
        (full as Map)['parameters'],
        reason: 'parameters',
      );
      expect(model.hasParameters, isTrue);
      expect(_wire(model.strict), (full as Map)['strict'], reason: 'strict');
      expect(model.hasStrict, isTrue);
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputFunctionToolParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('optional allowed_callers omit/null/clear and copy ownership', () {
      final model = LiveInputFunctionToolParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearAllowedCallers: true);
      expect(omitted.rawJson.containsKey('allowed_callers'), isFalse);
      expect(omitted.hasAllowedCallers, isFalse);
      expect(model.copyWith(allowedCallers: model.allowedCallers), model);
      final cleared = model.copyWith(allowedCallers: null);
      expect(cleared.rawJson.containsKey('allowed_callers'), isTrue);
      expect(cleared.toJson()['allowed_callers'], isNull);
      expect(cleared.hasAllowedCallers, isTrue);
    });
    test('known allowed_callers wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['allowed_callers'] = 5;
      expect(
        () => LiveInputFunctionToolParam.fromJson(wire),
        throwsA(_safe('allowed_callers')),
      );
      expect(
        () => LiveInputFunctionToolParam.fromJson(
          _clone(full),
        ).copyWith(allowedCallers: 5),
        throwsA(_safe('allowed_callers')),
      );
    });
    test('optional async omit/null/clear and copy ownership', () {
      final model = LiveInputFunctionToolParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearAsync: true);
      expect(omitted.rawJson.containsKey('async'), isFalse);
      expect(omitted.hasAsync, isFalse);
      expect(model.copyWith(async: model.async), model);
      expect(() => model.copyWith(async: null), throwsA(_safe('async')));
    });
    test('known async wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['async'] = 5;
      expect(
        () => LiveInputFunctionToolParam.fromJson(wire),
        throwsA(_safe('async')),
      );
      expect(
        () => LiveInputFunctionToolParam.fromJson(
          _clone(full),
        ).copyWith(async: 5),
        throwsA(_safe('async')),
      );
    });
    test('optional defer_loading omit/null/clear and copy ownership', () {
      final model = LiveInputFunctionToolParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearDeferLoading: true);
      expect(omitted.rawJson.containsKey('defer_loading'), isFalse);
      expect(omitted.hasDeferLoading, isFalse);
      expect(model.copyWith(deferLoading: model.deferLoading), model);
      expect(
        () => model.copyWith(deferLoading: null),
        throwsA(_safe('defer_loading')),
      );
    });
    test('known defer_loading wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['defer_loading'] = 5;
      expect(
        () => LiveInputFunctionToolParam.fromJson(wire),
        throwsA(_safe('defer_loading')),
      );
      expect(
        () => LiveInputFunctionToolParam.fromJson(
          _clone(full),
        ).copyWith(deferLoading: 5),
        throwsA(_safe('defer_loading')),
      );
    });
    test('optional description omit/null/clear and copy ownership', () {
      final model = LiveInputFunctionToolParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearDescription: true);
      expect(omitted.rawJson.containsKey('description'), isFalse);
      expect(omitted.hasDescription, isFalse);
      expect(model.copyWith(description: model.description), model);
      final cleared = model.copyWith(description: null);
      expect(cleared.rawJson.containsKey('description'), isTrue);
      expect(cleared.toJson()['description'], isNull);
      expect(cleared.hasDescription, isTrue);
    });
    test('known description wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['description'] = 5;
      expect(
        () => LiveInputFunctionToolParam.fromJson(wire),
        throwsA(_safe('description')),
      );
      expect(
        () => LiveInputFunctionToolParam.fromJson(
          _clone(full),
        ).copyWith(description: 5),
        throwsA(_safe('description')),
      );
    });
    test('required name absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('name');
      expect(
        () => LiveInputFunctionToolParam.fromJson(wire),
        throwsA(_safe('name')),
      );
    });
    test('known name wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['name'] = 5;
      expect(
        () => LiveInputFunctionToolParam.fromJson(wire),
        throwsA(_safe('name')),
      );
      expect(
        () =>
            LiveInputFunctionToolParam.fromJson(_clone(full)).copyWith(name: 5),
        throwsA(_safe('name')),
      );
    });
    test('optional output_schema omit/null/clear and copy ownership', () {
      final model = LiveInputFunctionToolParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearOutputSchema: true);
      expect(omitted.rawJson.containsKey('output_schema'), isFalse);
      expect(omitted.hasOutputSchema, isFalse);
      expect(model.copyWith(outputSchema: model.outputSchema), model);
      final cleared = model.copyWith(outputSchema: null);
      expect(cleared.rawJson.containsKey('output_schema'), isTrue);
      expect(cleared.toJson()['output_schema'], isNull);
      expect(cleared.hasOutputSchema, isTrue);
    });
    test('known output_schema wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['output_schema'] = 5;
      expect(
        () => LiveInputFunctionToolParam.fromJson(wire),
        throwsA(_safe('output_schema')),
      );
      expect(
        () => LiveInputFunctionToolParam.fromJson(
          _clone(full),
        ).copyWith(outputSchema: 5),
        throwsA(_safe('output_schema')),
      );
    });
    test('optional parameters omit/null/clear and copy ownership', () {
      final model = LiveInputFunctionToolParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearParameters: true);
      expect(omitted.rawJson.containsKey('parameters'), isFalse);
      expect(omitted.hasParameters, isFalse);
      expect(model.copyWith(parameters: model.parameters), model);
      final cleared = model.copyWith(parameters: null);
      expect(cleared.rawJson.containsKey('parameters'), isTrue);
      expect(cleared.toJson()['parameters'], isNull);
      expect(cleared.hasParameters, isTrue);
    });
    test('known parameters wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['parameters'] = 5;
      expect(
        () => LiveInputFunctionToolParam.fromJson(wire),
        throwsA(_safe('parameters')),
      );
      expect(
        () => LiveInputFunctionToolParam.fromJson(
          _clone(full),
        ).copyWith(parameters: 5),
        throwsA(_safe('parameters')),
      );
    });
    test('optional strict omit/null/clear and copy ownership', () {
      final model = LiveInputFunctionToolParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearStrict: true);
      expect(omitted.rawJson.containsKey('strict'), isFalse);
      expect(omitted.hasStrict, isFalse);
      expect(model.copyWith(strict: model.strict), model);
      final cleared = model.copyWith(strict: null);
      expect(cleared.rawJson.containsKey('strict'), isTrue);
      expect(cleared.toJson()['strict'], isNull);
      expect(cleared.hasStrict, isTrue);
    });
    test('known strict wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['strict'] = 5;
      expect(
        () => LiveInputFunctionToolParam.fromJson(wire),
        throwsA(_safe('strict')),
      );
      expect(
        () => LiveInputFunctionToolParam.fromJson(
          _clone(full),
        ).copyWith(strict: 5),
        throwsA(_safe('strict')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputFunctionToolParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputFunctionToolParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputFunctionToolParam.fromJson(wire),
        throwsA(_safe('LiveInputFunctionToolParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputFunctionToolParam.fromJson(wire),
        throwsA(_safe('LiveInputFunctionToolParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputFunctionToolParam.fromJson(wire),
        throwsA(_safe('LiveInputFunctionToolParam')),
      );
    });
  });
  group('GrammarSyntax1', () {
    const minimal = 'lark';
    const full = 'lark';
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputGrammarSyntax1.fromJson(_clone(wire));
        final peer = LiveInputGrammarSyntax1.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('value copy and JSON ownership', () {
      final model = LiveInputGrammarSyntax1.fromJson(_clone(full));
      expect(_wire(model.value), full);
      expect(model.copyWith(value: _clone(full)), model);
    });
  });
  group('HTTPError', () {
    final minimal = {
      'type': 'http_error',
      'code': 0,
      'message': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    final full = {
      'code': 0,
      'message': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'http_error',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputHTTPError.fromJson(_clone(wire));
        final peer = LiveInputHTTPError.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputHTTPError.fromJson(_clone(full));
      expect(_wire(model.code), (full as Map)['code'], reason: 'code');
      expect(_wire(model.message), (full as Map)['message'], reason: 'message');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputHTTPError.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required code absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('code');
      expect(() => LiveInputHTTPError.fromJson(wire), throwsA(_safe('code')));
    });
    test('known code wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['code'] = false;
      expect(() => LiveInputHTTPError.fromJson(wire), throwsA(_safe('code')));
      expect(
        () => LiveInputHTTPError.fromJson(_clone(full)).copyWith(code: false),
        throwsA(_safe('code')),
      );
    });
    test('required message absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('message');
      expect(
        () => LiveInputHTTPError.fromJson(wire),
        throwsA(_safe('message')),
      );
    });
    test('known message wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['message'] = 5;
      expect(
        () => LiveInputHTTPError.fromJson(wire),
        throwsA(_safe('message')),
      );
      expect(
        () => LiveInputHTTPError.fromJson(_clone(full)).copyWith(message: 5),
        throwsA(_safe('message')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(() => LiveInputHTTPError.fromJson(wire), throwsA(_safe('type')));
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(() => LiveInputHTTPError.fromJson(wire), throwsA(_safe('type')));
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputHTTPError.fromJson(wire),
        throwsA(_safe('LiveInputHTTPError')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputHTTPError.fromJson(wire),
        throwsA(_safe('LiveInputHTTPError')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputHTTPError.fromJson(wire),
        throwsA(_safe('LiveInputHTTPError')),
      );
    });
  });
  group('HybridSearchOptions', () {
    final minimal = {'embedding_weight': 0, 'text_weight': 0};
    final full = {'embedding_weight': 0, 'text_weight': 0};
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputHybridSearchOptions.fromJson(_clone(wire));
        final peer = LiveInputHybridSearchOptions.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputHybridSearchOptions.fromJson(_clone(full));
      expect(
        _wire(model.embeddingWeight),
        (full as Map)['embedding_weight'],
        reason: 'embedding_weight',
      );
      expect(
        _wire(model.textWeight),
        (full as Map)['text_weight'],
        reason: 'text_weight',
      );
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputHybridSearchOptions.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required embedding_weight absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('embedding_weight');
      expect(
        () => LiveInputHybridSearchOptions.fromJson(wire),
        throwsA(_safe('embedding_weight')),
      );
    });
    test('known embedding_weight wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['embedding_weight'] = false;
      expect(
        () => LiveInputHybridSearchOptions.fromJson(wire),
        throwsA(_safe('embedding_weight')),
      );
      expect(
        () => LiveInputHybridSearchOptions.fromJson(
          _clone(full),
        ).copyWith(embeddingWeight: false),
        throwsA(_safe('embedding_weight')),
      );
    });
    test('required text_weight absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('text_weight');
      expect(
        () => LiveInputHybridSearchOptions.fromJson(wire),
        throwsA(_safe('text_weight')),
      );
    });
    test('known text_weight wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['text_weight'] = false;
      expect(
        () => LiveInputHybridSearchOptions.fromJson(wire),
        throwsA(_safe('text_weight')),
      );
      expect(
        () => LiveInputHybridSearchOptions.fromJson(
          _clone(full),
        ).copyWith(textWeight: false),
        throwsA(_safe('text_weight')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputHybridSearchOptions.fromJson(wire),
        throwsA(_safe('LiveInputHybridSearchOptions')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputHybridSearchOptions.fromJson(wire),
        throwsA(_safe('LiveInputHybridSearchOptions')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputHybridSearchOptions.fromJson(wire),
        throwsA(_safe('LiveInputHybridSearchOptions')),
      );
    });
  });
  group('ImageBackground', () {
    const minimal = 'transparent';
    const full = 'transparent';
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputImageBackground.fromJson(_clone(wire));
        final peer = LiveInputImageBackground.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('value copy and JSON ownership', () {
      final model = LiveInputImageBackground.fromJson(_clone(full));
      expect(_wire(model.value), full);
      expect(model.copyWith(value: _clone(full)), model);
    });
  });
  group('ImageDetail', () {
    const minimal = 'low';
    const full = 'low';
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputImageDetail.fromJson(_clone(wire));
        final peer = LiveInputImageDetail.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('value copy and JSON ownership', () {
      final model = LiveInputImageDetail.fromJson(_clone(full));
      expect(_wire(model.value), full);
      expect(model.copyWith(value: _clone(full)), model);
    });
  });
  group('ImageGenActionEnum', () {
    const minimal = 'generate';
    const full = 'generate';
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputImageGenActionEnum.fromJson(_clone(wire));
        final peer = LiveInputImageGenActionEnum.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('value copy and JSON ownership', () {
      final model = LiveInputImageGenActionEnum.fromJson(_clone(full));
      expect(_wire(model.value), full);
      expect(model.copyWith(value: _clone(full)), model);
    });
  });
  group('ImageGenTool', () {
    final minimal = {'type': 'image_generation'};
    final full = {
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
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputImageGenTool.fromJson(_clone(wire));
        final peer = LiveInputImageGenTool.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputImageGenTool.fromJson(_clone(full));
      expect(_wire(model.action), (full as Map)['action'], reason: 'action');
      expect(model.hasAction, isTrue);
      expect(
        _wire(model.background),
        (full as Map)['background'],
        reason: 'background',
      );
      expect(model.hasBackground, isTrue);
      expect(
        _wire(model.inputFidelity),
        (full as Map)['input_fidelity'],
        reason: 'input_fidelity',
      );
      expect(model.hasInputFidelity, isTrue);
      expect(
        _wire(model.inputImageMask),
        (full as Map)['input_image_mask'],
        reason: 'input_image_mask',
      );
      expect(model.hasInputImageMask, isTrue);
      expect(_wire(model.model), (full as Map)['model'], reason: 'model');
      expect(model.hasModel, isTrue);
      expect(
        _wire(model.moderation),
        (full as Map)['moderation'],
        reason: 'moderation',
      );
      expect(model.hasModeration, isTrue);
      expect(
        _wire(model.outputCompression),
        (full as Map)['output_compression'],
        reason: 'output_compression',
      );
      expect(model.hasOutputCompression, isTrue);
      expect(
        _wire(model.outputFormat),
        (full as Map)['output_format'],
        reason: 'output_format',
      );
      expect(model.hasOutputFormat, isTrue);
      expect(
        _wire(model.partialImages),
        (full as Map)['partial_images'],
        reason: 'partial_images',
      );
      expect(model.hasPartialImages, isTrue);
      expect(_wire(model.quality), (full as Map)['quality'], reason: 'quality');
      expect(model.hasQuality, isTrue);
      expect(_wire(model.size), (full as Map)['size'], reason: 'size');
      expect(model.hasSize, isTrue);
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputImageGenTool.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('optional action omit/null/clear and copy ownership', () {
      final model = LiveInputImageGenTool.fromJson(_clone(full));
      final omitted = model.copyWith(clearAction: true);
      expect(omitted.rawJson.containsKey('action'), isFalse);
      expect(omitted.hasAction, isFalse);
      expect(model.copyWith(action: model.action), model);
      expect(() => model.copyWith(action: null), throwsA(_safe('action')));
    });
    test('known action wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['action'] = 5;
      expect(
        () => LiveInputImageGenTool.fromJson(wire),
        throwsA(_safe('action')),
      );
      expect(
        () => LiveInputImageGenTool.fromJson(_clone(full)).copyWith(action: 5),
        throwsA(_safe('action')),
      );
    });
    test('optional background omit/null/clear and copy ownership', () {
      final model = LiveInputImageGenTool.fromJson(_clone(full));
      final omitted = model.copyWith(clearBackground: true);
      expect(omitted.rawJson.containsKey('background'), isFalse);
      expect(omitted.hasBackground, isFalse);
      expect(model.copyWith(background: model.background), model);
      expect(
        () => model.copyWith(background: null),
        throwsA(_safe('background')),
      );
    });
    test('known background wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['background'] = 5;
      expect(
        () => LiveInputImageGenTool.fromJson(wire),
        throwsA(_safe('background')),
      );
      expect(
        () => LiveInputImageGenTool.fromJson(
          _clone(full),
        ).copyWith(background: 5),
        throwsA(_safe('background')),
      );
    });
    test('optional input_fidelity omit/null/clear and copy ownership', () {
      final model = LiveInputImageGenTool.fromJson(_clone(full));
      final omitted = model.copyWith(clearInputFidelity: true);
      expect(omitted.rawJson.containsKey('input_fidelity'), isFalse);
      expect(omitted.hasInputFidelity, isFalse);
      expect(model.copyWith(inputFidelity: model.inputFidelity), model);
      final cleared = model.copyWith(inputFidelity: null);
      expect(cleared.rawJson.containsKey('input_fidelity'), isTrue);
      expect(cleared.toJson()['input_fidelity'], isNull);
      expect(cleared.hasInputFidelity, isTrue);
    });
    test('known input_fidelity wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['input_fidelity'] = 5;
      expect(
        () => LiveInputImageGenTool.fromJson(wire),
        throwsA(_safe('input_fidelity')),
      );
      expect(
        () => LiveInputImageGenTool.fromJson(
          _clone(full),
        ).copyWith(inputFidelity: 5),
        throwsA(_safe('input_fidelity')),
      );
    });
    test('optional input_image_mask omit/null/clear and copy ownership', () {
      final model = LiveInputImageGenTool.fromJson(_clone(full));
      final omitted = model.copyWith(clearInputImageMask: true);
      expect(omitted.rawJson.containsKey('input_image_mask'), isFalse);
      expect(omitted.hasInputImageMask, isFalse);
      expect(model.copyWith(inputImageMask: model.inputImageMask), model);
      expect(
        () => model.copyWith(inputImageMask: null),
        throwsA(_safe('input_image_mask')),
      );
    });
    test('known input_image_mask wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['input_image_mask'] = 5;
      expect(
        () => LiveInputImageGenTool.fromJson(wire),
        throwsA(_safe('input_image_mask')),
      );
      expect(
        () => LiveInputImageGenTool.fromJson(
          _clone(full),
        ).copyWith(inputImageMask: 5),
        throwsA(_safe('input_image_mask')),
      );
    });
    test('optional model omit/null/clear and copy ownership', () {
      final model = LiveInputImageGenTool.fromJson(_clone(full));
      final omitted = model.copyWith(clearModel: true);
      expect(omitted.rawJson.containsKey('model'), isFalse);
      expect(omitted.hasModel, isFalse);
      expect(model.copyWith(model: model.model), model);
      expect(() => model.copyWith(model: null), throwsA(_safe('model')));
    });
    test('known model wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['model'] = 5;
      expect(
        () => LiveInputImageGenTool.fromJson(wire),
        throwsA(_safe('model')),
      );
      expect(
        () => LiveInputImageGenTool.fromJson(_clone(full)).copyWith(model: 5),
        throwsA(_safe('model')),
      );
    });
    test('optional moderation omit/null/clear and copy ownership', () {
      final model = LiveInputImageGenTool.fromJson(_clone(full));
      final omitted = model.copyWith(clearModeration: true);
      expect(omitted.rawJson.containsKey('moderation'), isFalse);
      expect(omitted.hasModeration, isFalse);
      expect(model.copyWith(moderation: model.moderation), model);
      expect(
        () => model.copyWith(moderation: null),
        throwsA(_safe('moderation')),
      );
    });
    test('known moderation wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['moderation'] = 5;
      expect(
        () => LiveInputImageGenTool.fromJson(wire),
        throwsA(_safe('moderation')),
      );
      expect(
        () => LiveInputImageGenTool.fromJson(
          _clone(full),
        ).copyWith(moderation: 5),
        throwsA(_safe('moderation')),
      );
    });
    test('optional output_compression omit/null/clear and copy ownership', () {
      final model = LiveInputImageGenTool.fromJson(_clone(full));
      final omitted = model.copyWith(clearOutputCompression: true);
      expect(omitted.rawJson.containsKey('output_compression'), isFalse);
      expect(omitted.hasOutputCompression, isFalse);
      expect(model.copyWith(outputCompression: model.outputCompression), model);
      expect(
        () => model.copyWith(outputCompression: null),
        throwsA(_safe('output_compression')),
      );
    });
    test('known output_compression wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['output_compression'] = false;
      expect(
        () => LiveInputImageGenTool.fromJson(wire),
        throwsA(_safe('output_compression')),
      );
      expect(
        () => LiveInputImageGenTool.fromJson(
          _clone(full),
        ).copyWith(outputCompression: false),
        throwsA(_safe('output_compression')),
      );
    });
    test('optional output_format omit/null/clear and copy ownership', () {
      final model = LiveInputImageGenTool.fromJson(_clone(full));
      final omitted = model.copyWith(clearOutputFormat: true);
      expect(omitted.rawJson.containsKey('output_format'), isFalse);
      expect(omitted.hasOutputFormat, isFalse);
      expect(model.copyWith(outputFormat: model.outputFormat), model);
      expect(
        () => model.copyWith(outputFormat: null),
        throwsA(_safe('output_format')),
      );
    });
    test('known output_format wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['output_format'] = 5;
      expect(
        () => LiveInputImageGenTool.fromJson(wire),
        throwsA(_safe('output_format')),
      );
      expect(
        () => LiveInputImageGenTool.fromJson(
          _clone(full),
        ).copyWith(outputFormat: 5),
        throwsA(_safe('output_format')),
      );
    });
    test('optional partial_images omit/null/clear and copy ownership', () {
      final model = LiveInputImageGenTool.fromJson(_clone(full));
      final omitted = model.copyWith(clearPartialImages: true);
      expect(omitted.rawJson.containsKey('partial_images'), isFalse);
      expect(omitted.hasPartialImages, isFalse);
      expect(model.copyWith(partialImages: model.partialImages), model);
      expect(
        () => model.copyWith(partialImages: null),
        throwsA(_safe('partial_images')),
      );
    });
    test('known partial_images wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['partial_images'] = 5;
      expect(
        () => LiveInputImageGenTool.fromJson(wire),
        throwsA(_safe('partial_images')),
      );
      expect(
        () => LiveInputImageGenTool.fromJson(
          _clone(full),
        ).copyWith(partialImages: 5),
        throwsA(_safe('partial_images')),
      );
    });
    test('optional quality omit/null/clear and copy ownership', () {
      final model = LiveInputImageGenTool.fromJson(_clone(full));
      final omitted = model.copyWith(clearQuality: true);
      expect(omitted.rawJson.containsKey('quality'), isFalse);
      expect(omitted.hasQuality, isFalse);
      expect(model.copyWith(quality: model.quality), model);
      expect(() => model.copyWith(quality: null), throwsA(_safe('quality')));
    });
    test('known quality wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['quality'] = 5;
      expect(
        () => LiveInputImageGenTool.fromJson(wire),
        throwsA(_safe('quality')),
      );
      expect(
        () => LiveInputImageGenTool.fromJson(_clone(full)).copyWith(quality: 5),
        throwsA(_safe('quality')),
      );
    });
    test('optional size omit/null/clear and copy ownership', () {
      final model = LiveInputImageGenTool.fromJson(_clone(full));
      final omitted = model.copyWith(clearSize: true);
      expect(omitted.rawJson.containsKey('size'), isFalse);
      expect(omitted.hasSize, isFalse);
      expect(model.copyWith(size: model.size), model);
      expect(() => model.copyWith(size: null), throwsA(_safe('size')));
    });
    test('known size wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['size'] = 5;
      expect(
        () => LiveInputImageGenTool.fromJson(wire),
        throwsA(_safe('size')),
      );
      expect(
        () => LiveInputImageGenTool.fromJson(_clone(full)).copyWith(size: 5),
        throwsA(_safe('size')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputImageGenTool.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputImageGenTool.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputImageGenTool.fromJson(wire),
        throwsA(_safe('LiveInputImageGenTool')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputImageGenTool.fromJson(wire),
        throwsA(_safe('LiveInputImageGenTool')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputImageGenTool.fromJson(wire),
        throwsA(_safe('LiveInputImageGenTool')),
      );
    });
  });
  group('ImageGenToolCall', () {
    final minimal = {
      'type': 'image_generation_call',
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'status': 'in_progress',
      'result': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    final full = {
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
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputImageGenToolCall.fromJson(_clone(wire));
        final peer = LiveInputImageGenToolCall.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputImageGenToolCall.fromJson(_clone(full));
      expect(_wire(model.action), (full as Map)['action'], reason: 'action');
      expect(model.hasAction, isTrue);
      expect(
        _wire(model.background),
        (full as Map)['background'],
        reason: 'background',
      );
      expect(model.hasBackground, isTrue);
      expect(_wire(model.id), (full as Map)['id'], reason: 'id');
      expect(
        _wire(model.outputFormat),
        (full as Map)['output_format'],
        reason: 'output_format',
      );
      expect(model.hasOutputFormat, isTrue);
      expect(_wire(model.quality), (full as Map)['quality'], reason: 'quality');
      expect(model.hasQuality, isTrue);
      expect(_wire(model.result), (full as Map)['result'], reason: 'result');
      expect(
        _wire(model.revisedPrompt),
        (full as Map)['revised_prompt'],
        reason: 'revised_prompt',
      );
      expect(model.hasRevisedPrompt, isTrue);
      expect(_wire(model.size), (full as Map)['size'], reason: 'size');
      expect(model.hasSize, isTrue);
      expect(_wire(model.status), (full as Map)['status'], reason: 'status');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputImageGenToolCall.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('optional action omit/null/clear and copy ownership', () {
      final model = LiveInputImageGenToolCall.fromJson(_clone(full));
      final omitted = model.copyWith(clearAction: true);
      expect(omitted.rawJson.containsKey('action'), isFalse);
      expect(omitted.hasAction, isFalse);
      expect(model.copyWith(action: model.action), model);
      final cleared = model.copyWith(action: null);
      expect(cleared.rawJson.containsKey('action'), isTrue);
      expect(cleared.toJson()['action'], isNull);
      expect(cleared.hasAction, isTrue);
    });
    test('known action wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['action'] = 5;
      expect(
        () => LiveInputImageGenToolCall.fromJson(wire),
        throwsA(_safe('action')),
      );
      expect(
        () => LiveInputImageGenToolCall.fromJson(
          _clone(full),
        ).copyWith(action: 5),
        throwsA(_safe('action')),
      );
    });
    test('optional background omit/null/clear and copy ownership', () {
      final model = LiveInputImageGenToolCall.fromJson(_clone(full));
      final omitted = model.copyWith(clearBackground: true);
      expect(omitted.rawJson.containsKey('background'), isFalse);
      expect(omitted.hasBackground, isFalse);
      expect(model.copyWith(background: model.background), model);
      final cleared = model.copyWith(background: null);
      expect(cleared.rawJson.containsKey('background'), isTrue);
      expect(cleared.toJson()['background'], isNull);
      expect(cleared.hasBackground, isTrue);
    });
    test('known background wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['background'] = 5;
      expect(
        () => LiveInputImageGenToolCall.fromJson(wire),
        throwsA(_safe('background')),
      );
      expect(
        () => LiveInputImageGenToolCall.fromJson(
          _clone(full),
        ).copyWith(background: 5),
        throwsA(_safe('background')),
      );
    });
    test('required id absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('id');
      expect(
        () => LiveInputImageGenToolCall.fromJson(wire),
        throwsA(_safe('id')),
      );
    });
    test('known id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['id'] = 5;
      expect(
        () => LiveInputImageGenToolCall.fromJson(wire),
        throwsA(_safe('id')),
      );
      expect(
        () => LiveInputImageGenToolCall.fromJson(_clone(full)).copyWith(id: 5),
        throwsA(_safe('id')),
      );
    });
    test('optional output_format omit/null/clear and copy ownership', () {
      final model = LiveInputImageGenToolCall.fromJson(_clone(full));
      final omitted = model.copyWith(clearOutputFormat: true);
      expect(omitted.rawJson.containsKey('output_format'), isFalse);
      expect(omitted.hasOutputFormat, isFalse);
      expect(model.copyWith(outputFormat: model.outputFormat), model);
      final cleared = model.copyWith(outputFormat: null);
      expect(cleared.rawJson.containsKey('output_format'), isTrue);
      expect(cleared.toJson()['output_format'], isNull);
      expect(cleared.hasOutputFormat, isTrue);
    });
    test('known output_format wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['output_format'] = 5;
      expect(
        () => LiveInputImageGenToolCall.fromJson(wire),
        throwsA(_safe('output_format')),
      );
      expect(
        () => LiveInputImageGenToolCall.fromJson(
          _clone(full),
        ).copyWith(outputFormat: 5),
        throwsA(_safe('output_format')),
      );
    });
    test('optional quality omit/null/clear and copy ownership', () {
      final model = LiveInputImageGenToolCall.fromJson(_clone(full));
      final omitted = model.copyWith(clearQuality: true);
      expect(omitted.rawJson.containsKey('quality'), isFalse);
      expect(omitted.hasQuality, isFalse);
      expect(model.copyWith(quality: model.quality), model);
      final cleared = model.copyWith(quality: null);
      expect(cleared.rawJson.containsKey('quality'), isTrue);
      expect(cleared.toJson()['quality'], isNull);
      expect(cleared.hasQuality, isTrue);
    });
    test('known quality wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['quality'] = 5;
      expect(
        () => LiveInputImageGenToolCall.fromJson(wire),
        throwsA(_safe('quality')),
      );
      expect(
        () => LiveInputImageGenToolCall.fromJson(
          _clone(full),
        ).copyWith(quality: 5),
        throwsA(_safe('quality')),
      );
    });
    test('required result absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('result');
      expect(
        () => LiveInputImageGenToolCall.fromJson(wire),
        throwsA(_safe('result')),
      );
    });
    test('known result wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['result'] = 5;
      expect(
        () => LiveInputImageGenToolCall.fromJson(wire),
        throwsA(_safe('result')),
      );
      expect(
        () => LiveInputImageGenToolCall.fromJson(
          _clone(full),
        ).copyWith(result: 5),
        throwsA(_safe('result')),
      );
    });
    test('optional revised_prompt omit/null/clear and copy ownership', () {
      final model = LiveInputImageGenToolCall.fromJson(_clone(full));
      final omitted = model.copyWith(clearRevisedPrompt: true);
      expect(omitted.rawJson.containsKey('revised_prompt'), isFalse);
      expect(omitted.hasRevisedPrompt, isFalse);
      expect(model.copyWith(revisedPrompt: model.revisedPrompt), model);
      final cleared = model.copyWith(revisedPrompt: null);
      expect(cleared.rawJson.containsKey('revised_prompt'), isTrue);
      expect(cleared.toJson()['revised_prompt'], isNull);
      expect(cleared.hasRevisedPrompt, isTrue);
    });
    test('known revised_prompt wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['revised_prompt'] = 5;
      expect(
        () => LiveInputImageGenToolCall.fromJson(wire),
        throwsA(_safe('revised_prompt')),
      );
      expect(
        () => LiveInputImageGenToolCall.fromJson(
          _clone(full),
        ).copyWith(revisedPrompt: 5),
        throwsA(_safe('revised_prompt')),
      );
    });
    test('optional size omit/null/clear and copy ownership', () {
      final model = LiveInputImageGenToolCall.fromJson(_clone(full));
      final omitted = model.copyWith(clearSize: true);
      expect(omitted.rawJson.containsKey('size'), isFalse);
      expect(omitted.hasSize, isFalse);
      expect(model.copyWith(size: model.size), model);
      final cleared = model.copyWith(size: null);
      expect(cleared.rawJson.containsKey('size'), isTrue);
      expect(cleared.toJson()['size'], isNull);
      expect(cleared.hasSize, isTrue);
    });
    test('known size wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['size'] = 5;
      expect(
        () => LiveInputImageGenToolCall.fromJson(wire),
        throwsA(_safe('size')),
      );
      expect(
        () =>
            LiveInputImageGenToolCall.fromJson(_clone(full)).copyWith(size: 5),
        throwsA(_safe('size')),
      );
    });
    test('required status absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('status');
      expect(
        () => LiveInputImageGenToolCall.fromJson(wire),
        throwsA(_safe('status')),
      );
    });
    test('known status wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['status'] = 5;
      expect(
        () => LiveInputImageGenToolCall.fromJson(wire),
        throwsA(_safe('status')),
      );
      expect(
        () => LiveInputImageGenToolCall.fromJson(
          _clone(full),
        ).copyWith(status: 5),
        throwsA(_safe('status')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputImageGenToolCall.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputImageGenToolCall.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputImageGenToolCall.fromJson(wire),
        throwsA(_safe('LiveInputImageGenToolCall')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputImageGenToolCall.fromJson(wire),
        throwsA(_safe('LiveInputImageGenToolCall')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputImageGenToolCall.fromJson(wire),
        throwsA(_safe('LiveInputImageGenToolCall')),
      );
    });
  });
  group('ImageOutputFormat', () {
    const minimal = 'png';
    const full = 'png';
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputImageOutputFormat.fromJson(_clone(wire));
        final peer = LiveInputImageOutputFormat.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('value copy and JSON ownership', () {
      final model = LiveInputImageOutputFormat.fromJson(_clone(full));
      expect(_wire(model.value), full);
      expect(model.copyWith(value: _clone(full)), model);
    });
  });
  group('InlineSkillParam', () {
    final minimal = {
      'type': 'inline',
      'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'description': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'source': {
        'type': 'base64',
        'media_type': 'application/zip',
        'data': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      },
    };
    final full = {
      'description': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'source': {
        'data': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        'media_type': 'application/zip',
        'type': 'base64',
      },
      'type': 'inline',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputInlineSkillParam.fromJson(_clone(wire));
        final peer = LiveInputInlineSkillParam.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputInlineSkillParam.fromJson(_clone(full));
      expect(
        _wire(model.description),
        (full as Map)['description'],
        reason: 'description',
      );
      expect(_wire(model.name), (full as Map)['name'], reason: 'name');
      expect(_wire(model.source), (full as Map)['source'], reason: 'source');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputInlineSkillParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required description absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('description');
      expect(
        () => LiveInputInlineSkillParam.fromJson(wire),
        throwsA(_safe('description')),
      );
    });
    test('known description wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['description'] = 5;
      expect(
        () => LiveInputInlineSkillParam.fromJson(wire),
        throwsA(_safe('description')),
      );
      expect(
        () => LiveInputInlineSkillParam.fromJson(
          _clone(full),
        ).copyWith(description: 5),
        throwsA(_safe('description')),
      );
    });
    test('required name absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('name');
      expect(
        () => LiveInputInlineSkillParam.fromJson(wire),
        throwsA(_safe('name')),
      );
    });
    test('known name wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['name'] = 5;
      expect(
        () => LiveInputInlineSkillParam.fromJson(wire),
        throwsA(_safe('name')),
      );
      expect(
        () =>
            LiveInputInlineSkillParam.fromJson(_clone(full)).copyWith(name: 5),
        throwsA(_safe('name')),
      );
    });
    test('required source absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('source');
      expect(
        () => LiveInputInlineSkillParam.fromJson(wire),
        throwsA(_safe('source')),
      );
    });
    test('known source wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['source'] = 5;
      expect(
        () => LiveInputInlineSkillParam.fromJson(wire),
        throwsA(_safe('source')),
      );
      expect(
        () => LiveInputInlineSkillParam.fromJson(
          _clone(full),
        ).copyWith(source: 5),
        throwsA(_safe('source')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputInlineSkillParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputInlineSkillParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputInlineSkillParam.fromJson(wire),
        throwsA(_safe('LiveInputInlineSkillParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputInlineSkillParam.fromJson(wire),
        throwsA(_safe('LiveInputInlineSkillParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputInlineSkillParam.fromJson(wire),
        throwsA(_safe('LiveInputInlineSkillParam')),
      );
    });
  });
  group('InlineSkillSourceParam', () {
    final minimal = {
      'type': 'base64',
      'media_type': 'application/zip',
      'data': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    final full = {
      'data': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'media_type': 'application/zip',
      'type': 'base64',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputInlineSkillSourceParam.fromJson(_clone(wire));
        final peer = LiveInputInlineSkillSourceParam.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputInlineSkillSourceParam.fromJson(_clone(full));
      expect(_wire(model.data), (full as Map)['data'], reason: 'data');
      expect(
        _wire(model.mediaType),
        (full as Map)['media_type'],
        reason: 'media_type',
      );
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputInlineSkillSourceParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required data absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('data');
      expect(
        () => LiveInputInlineSkillSourceParam.fromJson(wire),
        throwsA(_safe('data')),
      );
    });
    test('known data wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['data'] = 5;
      expect(
        () => LiveInputInlineSkillSourceParam.fromJson(wire),
        throwsA(_safe('data')),
      );
      expect(
        () => LiveInputInlineSkillSourceParam.fromJson(
          _clone(full),
        ).copyWith(data: 5),
        throwsA(_safe('data')),
      );
    });
    test('required media_type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('media_type');
      expect(
        () => LiveInputInlineSkillSourceParam.fromJson(wire),
        throwsA(_safe('media_type')),
      );
    });
    test('known media_type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['media_type'] = 5;
      expect(
        () => LiveInputInlineSkillSourceParam.fromJson(wire),
        throwsA(_safe('media_type')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputInlineSkillSourceParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputInlineSkillSourceParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputInlineSkillSourceParam.fromJson(wire),
        throwsA(_safe('LiveInputInlineSkillSourceParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputInlineSkillSourceParam.fromJson(wire),
        throwsA(_safe('LiveInputInlineSkillSourceParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputInlineSkillSourceParam.fromJson(wire),
        throwsA(_safe('LiveInputInlineSkillSourceParam')),
      );
    });
  });
  group('InputContent', () {
    final minimal = {
      'type': 'input_text',
      'text': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    final full = {
      'prompt_cache_breakpoint': {'mode': 'explicit'},
      'text': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'input_text',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputContent.fromJson(_clone(wire));
        final peer = LiveInputContent.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
  });
  group('InputFidelity', () {
    const minimal = 'high';
    const full = 'high';
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputFidelity.fromJson(_clone(wire));
        final peer = LiveInputFidelity.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('value copy and JSON ownership', () {
      final model = LiveInputFidelity.fromJson(_clone(full));
      expect(_wire(model.value), full);
      expect(model.copyWith(value: _clone(full)), model);
    });
  });
  group('InputFileContent', () {
    final minimal = {'type': 'input_file'};
    final full = {
      'detail': 'auto',
      'file_data': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'file_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'file_url': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'filename': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'prompt_cache_breakpoint': {'mode': 'explicit'},
      'type': 'input_file',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputFileContent.fromJson(_clone(wire));
        final peer = LiveInputFileContent.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputFileContent.fromJson(_clone(full));
      expect(_wire(model.detail), (full as Map)['detail'], reason: 'detail');
      expect(model.hasDetail, isTrue);
      expect(
        _wire(model.fileData),
        (full as Map)['file_data'],
        reason: 'file_data',
      );
      expect(model.hasFileData, isTrue);
      expect(_wire(model.fileId), (full as Map)['file_id'], reason: 'file_id');
      expect(model.hasFileId, isTrue);
      expect(
        _wire(model.fileUrl),
        (full as Map)['file_url'],
        reason: 'file_url',
      );
      expect(model.hasFileUrl, isTrue);
      expect(
        _wire(model.filename),
        (full as Map)['filename'],
        reason: 'filename',
      );
      expect(model.hasFilename, isTrue);
      expect(
        _wire(model.promptCacheBreakpoint),
        (full as Map)['prompt_cache_breakpoint'],
        reason: 'prompt_cache_breakpoint',
      );
      expect(model.hasPromptCacheBreakpoint, isTrue);
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputFileContent.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('optional detail omit/null/clear and copy ownership', () {
      final model = LiveInputFileContent.fromJson(_clone(full));
      final omitted = model.copyWith(clearDetail: true);
      expect(omitted.rawJson.containsKey('detail'), isFalse);
      expect(omitted.hasDetail, isFalse);
      expect(model.copyWith(detail: model.detail), model);
      expect(() => model.copyWith(detail: null), throwsA(_safe('detail')));
    });
    test('known detail wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['detail'] = 5;
      expect(
        () => LiveInputFileContent.fromJson(wire),
        throwsA(_safe('detail')),
      );
      expect(
        () => LiveInputFileContent.fromJson(_clone(full)).copyWith(detail: 5),
        throwsA(_safe('detail')),
      );
    });
    test('optional file_data omit/null/clear and copy ownership', () {
      final model = LiveInputFileContent.fromJson(_clone(full));
      final omitted = model.copyWith(clearFileData: true);
      expect(omitted.rawJson.containsKey('file_data'), isFalse);
      expect(omitted.hasFileData, isFalse);
      expect(model.copyWith(fileData: model.fileData), model);
      expect(() => model.copyWith(fileData: null), throwsA(_safe('file_data')));
    });
    test('known file_data wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['file_data'] = 5;
      expect(
        () => LiveInputFileContent.fromJson(wire),
        throwsA(_safe('file_data')),
      );
      expect(
        () => LiveInputFileContent.fromJson(_clone(full)).copyWith(fileData: 5),
        throwsA(_safe('file_data')),
      );
    });
    test('optional file_id omit/null/clear and copy ownership', () {
      final model = LiveInputFileContent.fromJson(_clone(full));
      final omitted = model.copyWith(clearFileId: true);
      expect(omitted.rawJson.containsKey('file_id'), isFalse);
      expect(omitted.hasFileId, isFalse);
      expect(model.copyWith(fileId: model.fileId), model);
      final cleared = model.copyWith(fileId: null);
      expect(cleared.rawJson.containsKey('file_id'), isTrue);
      expect(cleared.toJson()['file_id'], isNull);
      expect(cleared.hasFileId, isTrue);
    });
    test('known file_id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['file_id'] = 5;
      expect(
        () => LiveInputFileContent.fromJson(wire),
        throwsA(_safe('file_id')),
      );
      expect(
        () => LiveInputFileContent.fromJson(_clone(full)).copyWith(fileId: 5),
        throwsA(_safe('file_id')),
      );
    });
    test('optional file_url omit/null/clear and copy ownership', () {
      final model = LiveInputFileContent.fromJson(_clone(full));
      final omitted = model.copyWith(clearFileUrl: true);
      expect(omitted.rawJson.containsKey('file_url'), isFalse);
      expect(omitted.hasFileUrl, isFalse);
      expect(model.copyWith(fileUrl: model.fileUrl), model);
      expect(() => model.copyWith(fileUrl: null), throwsA(_safe('file_url')));
    });
    test('known file_url wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['file_url'] = 5;
      expect(
        () => LiveInputFileContent.fromJson(wire),
        throwsA(_safe('file_url')),
      );
      expect(
        () => LiveInputFileContent.fromJson(_clone(full)).copyWith(fileUrl: 5),
        throwsA(_safe('file_url')),
      );
    });
    test('optional filename omit/null/clear and copy ownership', () {
      final model = LiveInputFileContent.fromJson(_clone(full));
      final omitted = model.copyWith(clearFilename: true);
      expect(omitted.rawJson.containsKey('filename'), isFalse);
      expect(omitted.hasFilename, isFalse);
      expect(model.copyWith(filename: model.filename), model);
      expect(() => model.copyWith(filename: null), throwsA(_safe('filename')));
    });
    test('known filename wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['filename'] = 5;
      expect(
        () => LiveInputFileContent.fromJson(wire),
        throwsA(_safe('filename')),
      );
      expect(
        () => LiveInputFileContent.fromJson(_clone(full)).copyWith(filename: 5),
        throwsA(_safe('filename')),
      );
    });
    test(
      'optional prompt_cache_breakpoint omit/null/clear and copy ownership',
      () {
        final model = LiveInputFileContent.fromJson(_clone(full));
        final omitted = model.copyWith(clearPromptCacheBreakpoint: true);
        expect(omitted.rawJson.containsKey('prompt_cache_breakpoint'), isFalse);
        expect(omitted.hasPromptCacheBreakpoint, isFalse);
        expect(
          model.copyWith(promptCacheBreakpoint: model.promptCacheBreakpoint),
          model,
        );
        expect(
          () => model.copyWith(promptCacheBreakpoint: null),
          throwsA(_safe('prompt_cache_breakpoint')),
        );
      },
    );
    test(
      'known prompt_cache_breakpoint wrong value cannot become overflow',
      () {
        final wire = Map<String, dynamic>.from(_clone(full)! as Map);
        wire['prompt_cache_breakpoint'] = 5;
        expect(
          () => LiveInputFileContent.fromJson(wire),
          throwsA(_safe('prompt_cache_breakpoint')),
        );
        expect(
          () => LiveInputFileContent.fromJson(
            _clone(full),
          ).copyWith(promptCacheBreakpoint: 5),
          throwsA(_safe('prompt_cache_breakpoint')),
        );
      },
    );
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(() => LiveInputFileContent.fromJson(wire), throwsA(_safe('type')));
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(() => LiveInputFileContent.fromJson(wire), throwsA(_safe('type')));
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputFileContent.fromJson(wire),
        throwsA(_safe('LiveInputFileContent')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputFileContent.fromJson(wire),
        throwsA(_safe('LiveInputFileContent')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputFileContent.fromJson(wire),
        throwsA(_safe('LiveInputFileContent')),
      );
    });
  });
  group('InputFileContentParam', () {
    final minimal = {'type': 'input_file'};
    final full = {
      'detail': 'auto',
      'file_data': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'file_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'file_url': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'filename': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'prompt_cache_breakpoint': {'mode': 'explicit'},
      'type': 'input_file',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputFileContentParam.fromJson(_clone(wire));
        final peer = LiveInputFileContentParam.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputFileContentParam.fromJson(_clone(full));
      expect(_wire(model.detail), (full as Map)['detail'], reason: 'detail');
      expect(model.hasDetail, isTrue);
      expect(
        _wire(model.fileData),
        (full as Map)['file_data'],
        reason: 'file_data',
      );
      expect(model.hasFileData, isTrue);
      expect(_wire(model.fileId), (full as Map)['file_id'], reason: 'file_id');
      expect(model.hasFileId, isTrue);
      expect(
        _wire(model.fileUrl),
        (full as Map)['file_url'],
        reason: 'file_url',
      );
      expect(model.hasFileUrl, isTrue);
      expect(
        _wire(model.filename),
        (full as Map)['filename'],
        reason: 'filename',
      );
      expect(model.hasFilename, isTrue);
      expect(
        _wire(model.promptCacheBreakpoint),
        (full as Map)['prompt_cache_breakpoint'],
        reason: 'prompt_cache_breakpoint',
      );
      expect(model.hasPromptCacheBreakpoint, isTrue);
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputFileContentParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('optional detail omit/null/clear and copy ownership', () {
      final model = LiveInputFileContentParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearDetail: true);
      expect(omitted.rawJson.containsKey('detail'), isFalse);
      expect(omitted.hasDetail, isFalse);
      expect(model.copyWith(detail: model.detail), model);
      expect(() => model.copyWith(detail: null), throwsA(_safe('detail')));
    });
    test('known detail wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['detail'] = 5;
      expect(
        () => LiveInputFileContentParam.fromJson(wire),
        throwsA(_safe('detail')),
      );
      expect(
        () => LiveInputFileContentParam.fromJson(
          _clone(full),
        ).copyWith(detail: 5),
        throwsA(_safe('detail')),
      );
    });
    test('optional file_data omit/null/clear and copy ownership', () {
      final model = LiveInputFileContentParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearFileData: true);
      expect(omitted.rawJson.containsKey('file_data'), isFalse);
      expect(omitted.hasFileData, isFalse);
      expect(model.copyWith(fileData: model.fileData), model);
      final cleared = model.copyWith(fileData: null);
      expect(cleared.rawJson.containsKey('file_data'), isTrue);
      expect(cleared.toJson()['file_data'], isNull);
      expect(cleared.hasFileData, isTrue);
    });
    test('known file_data wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['file_data'] = 5;
      expect(
        () => LiveInputFileContentParam.fromJson(wire),
        throwsA(_safe('file_data')),
      );
      expect(
        () => LiveInputFileContentParam.fromJson(
          _clone(full),
        ).copyWith(fileData: 5),
        throwsA(_safe('file_data')),
      );
    });
    test('optional file_id omit/null/clear and copy ownership', () {
      final model = LiveInputFileContentParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearFileId: true);
      expect(omitted.rawJson.containsKey('file_id'), isFalse);
      expect(omitted.hasFileId, isFalse);
      expect(model.copyWith(fileId: model.fileId), model);
      final cleared = model.copyWith(fileId: null);
      expect(cleared.rawJson.containsKey('file_id'), isTrue);
      expect(cleared.toJson()['file_id'], isNull);
      expect(cleared.hasFileId, isTrue);
    });
    test('known file_id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['file_id'] = 5;
      expect(
        () => LiveInputFileContentParam.fromJson(wire),
        throwsA(_safe('file_id')),
      );
      expect(
        () => LiveInputFileContentParam.fromJson(
          _clone(full),
        ).copyWith(fileId: 5),
        throwsA(_safe('file_id')),
      );
    });
    test('optional file_url omit/null/clear and copy ownership', () {
      final model = LiveInputFileContentParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearFileUrl: true);
      expect(omitted.rawJson.containsKey('file_url'), isFalse);
      expect(omitted.hasFileUrl, isFalse);
      expect(model.copyWith(fileUrl: model.fileUrl), model);
      final cleared = model.copyWith(fileUrl: null);
      expect(cleared.rawJson.containsKey('file_url'), isTrue);
      expect(cleared.toJson()['file_url'], isNull);
      expect(cleared.hasFileUrl, isTrue);
    });
    test('known file_url wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['file_url'] = 5;
      expect(
        () => LiveInputFileContentParam.fromJson(wire),
        throwsA(_safe('file_url')),
      );
      expect(
        () => LiveInputFileContentParam.fromJson(
          _clone(full),
        ).copyWith(fileUrl: 5),
        throwsA(_safe('file_url')),
      );
    });
    test('optional filename omit/null/clear and copy ownership', () {
      final model = LiveInputFileContentParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearFilename: true);
      expect(omitted.rawJson.containsKey('filename'), isFalse);
      expect(omitted.hasFilename, isFalse);
      expect(model.copyWith(filename: model.filename), model);
      final cleared = model.copyWith(filename: null);
      expect(cleared.rawJson.containsKey('filename'), isTrue);
      expect(cleared.toJson()['filename'], isNull);
      expect(cleared.hasFilename, isTrue);
    });
    test('known filename wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['filename'] = 5;
      expect(
        () => LiveInputFileContentParam.fromJson(wire),
        throwsA(_safe('filename')),
      );
      expect(
        () => LiveInputFileContentParam.fromJson(
          _clone(full),
        ).copyWith(filename: 5),
        throwsA(_safe('filename')),
      );
    });
    test(
      'optional prompt_cache_breakpoint omit/null/clear and copy ownership',
      () {
        final model = LiveInputFileContentParam.fromJson(_clone(full));
        final omitted = model.copyWith(clearPromptCacheBreakpoint: true);
        expect(omitted.rawJson.containsKey('prompt_cache_breakpoint'), isFalse);
        expect(omitted.hasPromptCacheBreakpoint, isFalse);
        expect(
          model.copyWith(promptCacheBreakpoint: model.promptCacheBreakpoint),
          model,
        );
        final cleared = model.copyWith(promptCacheBreakpoint: null);
        expect(cleared.rawJson.containsKey('prompt_cache_breakpoint'), isTrue);
        expect(cleared.toJson()['prompt_cache_breakpoint'], isNull);
        expect(cleared.hasPromptCacheBreakpoint, isTrue);
      },
    );
    test(
      'known prompt_cache_breakpoint wrong value cannot become overflow',
      () {
        final wire = Map<String, dynamic>.from(_clone(full)! as Map);
        wire['prompt_cache_breakpoint'] = 5;
        expect(
          () => LiveInputFileContentParam.fromJson(wire),
          throwsA(_safe('prompt_cache_breakpoint')),
        );
        expect(
          () => LiveInputFileContentParam.fromJson(
            _clone(full),
          ).copyWith(promptCacheBreakpoint: 5),
          throwsA(_safe('prompt_cache_breakpoint')),
        );
      },
    );
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputFileContentParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputFileContentParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputFileContentParam.fromJson(wire),
        throwsA(_safe('LiveInputFileContentParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputFileContentParam.fromJson(wire),
        throwsA(_safe('LiveInputFileContentParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputFileContentParam.fromJson(wire),
        throwsA(_safe('LiveInputFileContentParam')),
      );
    });
  });
  group('InputImageContent', () {
    final minimal = {'type': 'input_image', 'detail': 'low'};
    final full = {
      'detail': 'low',
      'file_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'image_url': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'prompt_cache_breakpoint': {'mode': 'explicit'},
      'type': 'input_image',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputImageContent.fromJson(_clone(wire));
        final peer = LiveInputImageContent.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputImageContent.fromJson(_clone(full));
      expect(_wire(model.detail), (full as Map)['detail'], reason: 'detail');
      expect(_wire(model.fileId), (full as Map)['file_id'], reason: 'file_id');
      expect(model.hasFileId, isTrue);
      expect(
        _wire(model.imageUrl),
        (full as Map)['image_url'],
        reason: 'image_url',
      );
      expect(model.hasImageUrl, isTrue);
      expect(
        _wire(model.promptCacheBreakpoint),
        (full as Map)['prompt_cache_breakpoint'],
        reason: 'prompt_cache_breakpoint',
      );
      expect(model.hasPromptCacheBreakpoint, isTrue);
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputImageContent.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required detail absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('detail');
      expect(
        () => LiveInputImageContent.fromJson(wire),
        throwsA(_safe('detail')),
      );
    });
    test('known detail wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['detail'] = 5;
      expect(
        () => LiveInputImageContent.fromJson(wire),
        throwsA(_safe('detail')),
      );
      expect(
        () => LiveInputImageContent.fromJson(_clone(full)).copyWith(detail: 5),
        throwsA(_safe('detail')),
      );
    });
    test('optional file_id omit/null/clear and copy ownership', () {
      final model = LiveInputImageContent.fromJson(_clone(full));
      final omitted = model.copyWith(clearFileId: true);
      expect(omitted.rawJson.containsKey('file_id'), isFalse);
      expect(omitted.hasFileId, isFalse);
      expect(model.copyWith(fileId: model.fileId), model);
      final cleared = model.copyWith(fileId: null);
      expect(cleared.rawJson.containsKey('file_id'), isTrue);
      expect(cleared.toJson()['file_id'], isNull);
      expect(cleared.hasFileId, isTrue);
    });
    test('known file_id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['file_id'] = 5;
      expect(
        () => LiveInputImageContent.fromJson(wire),
        throwsA(_safe('file_id')),
      );
      expect(
        () => LiveInputImageContent.fromJson(_clone(full)).copyWith(fileId: 5),
        throwsA(_safe('file_id')),
      );
    });
    test('optional image_url omit/null/clear and copy ownership', () {
      final model = LiveInputImageContent.fromJson(_clone(full));
      final omitted = model.copyWith(clearImageUrl: true);
      expect(omitted.rawJson.containsKey('image_url'), isFalse);
      expect(omitted.hasImageUrl, isFalse);
      expect(model.copyWith(imageUrl: model.imageUrl), model);
      final cleared = model.copyWith(imageUrl: null);
      expect(cleared.rawJson.containsKey('image_url'), isTrue);
      expect(cleared.toJson()['image_url'], isNull);
      expect(cleared.hasImageUrl, isTrue);
    });
    test('known image_url wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['image_url'] = 5;
      expect(
        () => LiveInputImageContent.fromJson(wire),
        throwsA(_safe('image_url')),
      );
      expect(
        () =>
            LiveInputImageContent.fromJson(_clone(full)).copyWith(imageUrl: 5),
        throwsA(_safe('image_url')),
      );
    });
    test(
      'optional prompt_cache_breakpoint omit/null/clear and copy ownership',
      () {
        final model = LiveInputImageContent.fromJson(_clone(full));
        final omitted = model.copyWith(clearPromptCacheBreakpoint: true);
        expect(omitted.rawJson.containsKey('prompt_cache_breakpoint'), isFalse);
        expect(omitted.hasPromptCacheBreakpoint, isFalse);
        expect(
          model.copyWith(promptCacheBreakpoint: model.promptCacheBreakpoint),
          model,
        );
        expect(
          () => model.copyWith(promptCacheBreakpoint: null),
          throwsA(_safe('prompt_cache_breakpoint')),
        );
      },
    );
    test(
      'known prompt_cache_breakpoint wrong value cannot become overflow',
      () {
        final wire = Map<String, dynamic>.from(_clone(full)! as Map);
        wire['prompt_cache_breakpoint'] = 5;
        expect(
          () => LiveInputImageContent.fromJson(wire),
          throwsA(_safe('prompt_cache_breakpoint')),
        );
        expect(
          () => LiveInputImageContent.fromJson(
            _clone(full),
          ).copyWith(promptCacheBreakpoint: 5),
          throwsA(_safe('prompt_cache_breakpoint')),
        );
      },
    );
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputImageContent.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputImageContent.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputImageContent.fromJson(wire),
        throwsA(_safe('LiveInputImageContent')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputImageContent.fromJson(wire),
        throwsA(_safe('LiveInputImageContent')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputImageContent.fromJson(wire),
        throwsA(_safe('LiveInputImageContent')),
      );
    });
  });
  group('InputImageContentParamAutoParam', () {
    final minimal = {'type': 'input_image'};
    final full = {
      'detail': 'low',
      'file_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'image_url': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'prompt_cache_breakpoint': {'mode': 'explicit'},
      'type': 'input_image',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputImageContentParamAutoParam.fromJson(
          _clone(wire),
        );
        final peer = LiveInputImageContentParamAutoParam.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputImageContentParamAutoParam.fromJson(_clone(full));
      expect(_wire(model.detail), (full as Map)['detail'], reason: 'detail');
      expect(model.hasDetail, isTrue);
      expect(_wire(model.fileId), (full as Map)['file_id'], reason: 'file_id');
      expect(model.hasFileId, isTrue);
      expect(
        _wire(model.imageUrl),
        (full as Map)['image_url'],
        reason: 'image_url',
      );
      expect(model.hasImageUrl, isTrue);
      expect(
        _wire(model.promptCacheBreakpoint),
        (full as Map)['prompt_cache_breakpoint'],
        reason: 'prompt_cache_breakpoint',
      );
      expect(model.hasPromptCacheBreakpoint, isTrue);
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputImageContentParamAutoParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('optional detail omit/null/clear and copy ownership', () {
      final model = LiveInputImageContentParamAutoParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearDetail: true);
      expect(omitted.rawJson.containsKey('detail'), isFalse);
      expect(omitted.hasDetail, isFalse);
      expect(model.copyWith(detail: model.detail), model);
      final cleared = model.copyWith(detail: null);
      expect(cleared.rawJson.containsKey('detail'), isTrue);
      expect(cleared.toJson()['detail'], isNull);
      expect(cleared.hasDetail, isTrue);
    });
    test('known detail wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['detail'] = 5;
      expect(
        () => LiveInputImageContentParamAutoParam.fromJson(wire),
        throwsA(_safe('detail')),
      );
      expect(
        () => LiveInputImageContentParamAutoParam.fromJson(
          _clone(full),
        ).copyWith(detail: 5),
        throwsA(_safe('detail')),
      );
    });
    test('optional file_id omit/null/clear and copy ownership', () {
      final model = LiveInputImageContentParamAutoParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearFileId: true);
      expect(omitted.rawJson.containsKey('file_id'), isFalse);
      expect(omitted.hasFileId, isFalse);
      expect(model.copyWith(fileId: model.fileId), model);
      final cleared = model.copyWith(fileId: null);
      expect(cleared.rawJson.containsKey('file_id'), isTrue);
      expect(cleared.toJson()['file_id'], isNull);
      expect(cleared.hasFileId, isTrue);
    });
    test('known file_id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['file_id'] = 5;
      expect(
        () => LiveInputImageContentParamAutoParam.fromJson(wire),
        throwsA(_safe('file_id')),
      );
      expect(
        () => LiveInputImageContentParamAutoParam.fromJson(
          _clone(full),
        ).copyWith(fileId: 5),
        throwsA(_safe('file_id')),
      );
    });
    test('optional image_url omit/null/clear and copy ownership', () {
      final model = LiveInputImageContentParamAutoParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearImageUrl: true);
      expect(omitted.rawJson.containsKey('image_url'), isFalse);
      expect(omitted.hasImageUrl, isFalse);
      expect(model.copyWith(imageUrl: model.imageUrl), model);
      final cleared = model.copyWith(imageUrl: null);
      expect(cleared.rawJson.containsKey('image_url'), isTrue);
      expect(cleared.toJson()['image_url'], isNull);
      expect(cleared.hasImageUrl, isTrue);
    });
    test('known image_url wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['image_url'] = 5;
      expect(
        () => LiveInputImageContentParamAutoParam.fromJson(wire),
        throwsA(_safe('image_url')),
      );
      expect(
        () => LiveInputImageContentParamAutoParam.fromJson(
          _clone(full),
        ).copyWith(imageUrl: 5),
        throwsA(_safe('image_url')),
      );
    });
    test(
      'optional prompt_cache_breakpoint omit/null/clear and copy ownership',
      () {
        final model = LiveInputImageContentParamAutoParam.fromJson(
          _clone(full),
        );
        final omitted = model.copyWith(clearPromptCacheBreakpoint: true);
        expect(omitted.rawJson.containsKey('prompt_cache_breakpoint'), isFalse);
        expect(omitted.hasPromptCacheBreakpoint, isFalse);
        expect(
          model.copyWith(promptCacheBreakpoint: model.promptCacheBreakpoint),
          model,
        );
        final cleared = model.copyWith(promptCacheBreakpoint: null);
        expect(cleared.rawJson.containsKey('prompt_cache_breakpoint'), isTrue);
        expect(cleared.toJson()['prompt_cache_breakpoint'], isNull);
        expect(cleared.hasPromptCacheBreakpoint, isTrue);
      },
    );
    test(
      'known prompt_cache_breakpoint wrong value cannot become overflow',
      () {
        final wire = Map<String, dynamic>.from(_clone(full)! as Map);
        wire['prompt_cache_breakpoint'] = 5;
        expect(
          () => LiveInputImageContentParamAutoParam.fromJson(wire),
          throwsA(_safe('prompt_cache_breakpoint')),
        );
        expect(
          () => LiveInputImageContentParamAutoParam.fromJson(
            _clone(full),
          ).copyWith(promptCacheBreakpoint: 5),
          throwsA(_safe('prompt_cache_breakpoint')),
        );
      },
    );
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputImageContentParamAutoParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputImageContentParamAutoParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputImageContentParamAutoParam.fromJson(wire),
        throwsA(_safe('LiveInputImageContentParamAutoParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputImageContentParamAutoParam.fromJson(wire),
        throwsA(_safe('LiveInputImageContentParamAutoParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputImageContentParamAutoParam.fromJson(wire),
        throwsA(_safe('LiveInputImageContentParamAutoParam')),
      );
    });
  });
  group('InputMessage', () {
    final minimal = {'role': 'user', 'content': <dynamic>[]};
    final full = {
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
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputMessage.fromJson(_clone(wire));
        final peer = LiveInputMessage.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputMessage.fromJson(_clone(full));
      expect(_wire(model.content), (full as Map)['content'], reason: 'content');
      expect(_wire(model.role), (full as Map)['role'], reason: 'role');
      expect(_wire(model.status), (full as Map)['status'], reason: 'status');
      expect(model.hasStatus, isTrue);
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
      expect(model.hasType, isTrue);
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputMessage.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required content absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('content');
      expect(() => LiveInputMessage.fromJson(wire), throwsA(_safe('content')));
    });
    test('known content wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['content'] = 5;
      expect(() => LiveInputMessage.fromJson(wire), throwsA(_safe('content')));
      expect(
        () => LiveInputMessage.fromJson(_clone(full)).copyWith(content: 5),
        throwsA(_safe('content')),
      );
    });
    test('required role absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('role');
      expect(() => LiveInputMessage.fromJson(wire), throwsA(_safe('role')));
    });
    test('known role wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['role'] = 5;
      expect(() => LiveInputMessage.fromJson(wire), throwsA(_safe('role')));
      expect(
        () => LiveInputMessage.fromJson(_clone(full)).copyWith(role: 5),
        throwsA(_safe('role')),
      );
    });
    test('optional status omit/null/clear and copy ownership', () {
      final model = LiveInputMessage.fromJson(_clone(full));
      final omitted = model.copyWith(clearStatus: true);
      expect(omitted.rawJson.containsKey('status'), isFalse);
      expect(omitted.hasStatus, isFalse);
      expect(model.copyWith(status: model.status), model);
      expect(() => model.copyWith(status: null), throwsA(_safe('status')));
    });
    test('known status wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['status'] = 5;
      expect(() => LiveInputMessage.fromJson(wire), throwsA(_safe('status')));
      expect(
        () => LiveInputMessage.fromJson(_clone(full)).copyWith(status: 5),
        throwsA(_safe('status')),
      );
    });
    test('optional type omit/null/clear and copy ownership', () {
      final model = LiveInputMessage.fromJson(_clone(full));
      final omitted = model.copyWith(clearType: true);
      expect(omitted.rawJson.containsKey('type'), isFalse);
      expect(omitted.hasType, isFalse);
      expect(model.copyWith(type: model.type), model);
      expect(() => model.copyWith(type: null), throwsA(_safe('type')));
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(() => LiveInputMessage.fromJson(wire), throwsA(_safe('type')));
      expect(
        () => LiveInputMessage.fromJson(_clone(full)).copyWith(type: 5),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputMessage.fromJson(wire),
        throwsA(_safe('LiveInputMessage')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputMessage.fromJson(wire),
        throwsA(_safe('LiveInputMessage')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputMessage.fromJson(wire),
        throwsA(_safe('LiveInputMessage')),
      );
    });
  });
  group('InputMessageContentList', () {
    final minimal = <dynamic>[];
    final full = [
      {
        'prompt_cache_breakpoint': {'mode': 'explicit'},
        'text': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        'type': 'input_text',
      },
    ];
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputMessageContentList.fromJson(_clone(wire));
        final peer = LiveInputMessageContentList.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('value copy and JSON ownership', () {
      final model = LiveInputMessageContentList.fromJson(_clone(full));
      expect(_wire(model.value), full);
      expect(model.copyWith(value: _clone(full)), model);
    });
  });
  group('InputTextContent', () {
    final minimal = {
      'type': 'input_text',
      'text': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    final full = {
      'prompt_cache_breakpoint': {'mode': 'explicit'},
      'text': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'input_text',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputTextContent.fromJson(_clone(wire));
        final peer = LiveInputTextContent.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputTextContent.fromJson(_clone(full));
      expect(
        _wire(model.promptCacheBreakpoint),
        (full as Map)['prompt_cache_breakpoint'],
        reason: 'prompt_cache_breakpoint',
      );
      expect(model.hasPromptCacheBreakpoint, isTrue);
      expect(_wire(model.text), (full as Map)['text'], reason: 'text');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputTextContent.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test(
      'optional prompt_cache_breakpoint omit/null/clear and copy ownership',
      () {
        final model = LiveInputTextContent.fromJson(_clone(full));
        final omitted = model.copyWith(clearPromptCacheBreakpoint: true);
        expect(omitted.rawJson.containsKey('prompt_cache_breakpoint'), isFalse);
        expect(omitted.hasPromptCacheBreakpoint, isFalse);
        expect(
          model.copyWith(promptCacheBreakpoint: model.promptCacheBreakpoint),
          model,
        );
        expect(
          () => model.copyWith(promptCacheBreakpoint: null),
          throwsA(_safe('prompt_cache_breakpoint')),
        );
      },
    );
    test(
      'known prompt_cache_breakpoint wrong value cannot become overflow',
      () {
        final wire = Map<String, dynamic>.from(_clone(full)! as Map);
        wire['prompt_cache_breakpoint'] = 5;
        expect(
          () => LiveInputTextContent.fromJson(wire),
          throwsA(_safe('prompt_cache_breakpoint')),
        );
        expect(
          () => LiveInputTextContent.fromJson(
            _clone(full),
          ).copyWith(promptCacheBreakpoint: 5),
          throwsA(_safe('prompt_cache_breakpoint')),
        );
      },
    );
    test('required text absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('text');
      expect(() => LiveInputTextContent.fromJson(wire), throwsA(_safe('text')));
    });
    test('known text wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['text'] = 5;
      expect(() => LiveInputTextContent.fromJson(wire), throwsA(_safe('text')));
      expect(
        () => LiveInputTextContent.fromJson(_clone(full)).copyWith(text: 5),
        throwsA(_safe('text')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(() => LiveInputTextContent.fromJson(wire), throwsA(_safe('type')));
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(() => LiveInputTextContent.fromJson(wire), throwsA(_safe('type')));
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputTextContent.fromJson(wire),
        throwsA(_safe('LiveInputTextContent')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputTextContent.fromJson(wire),
        throwsA(_safe('LiveInputTextContent')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputTextContent.fromJson(wire),
        throwsA(_safe('LiveInputTextContent')),
      );
    });
  });
  group('InputTextContentParam', () {
    final minimal = {
      'type': 'input_text',
      'text': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    final full = {
      'prompt_cache_breakpoint': {'mode': 'explicit'},
      'text': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'input_text',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputTextContentParam.fromJson(_clone(wire));
        final peer = LiveInputTextContentParam.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputTextContentParam.fromJson(_clone(full));
      expect(
        _wire(model.promptCacheBreakpoint),
        (full as Map)['prompt_cache_breakpoint'],
        reason: 'prompt_cache_breakpoint',
      );
      expect(model.hasPromptCacheBreakpoint, isTrue);
      expect(_wire(model.text), (full as Map)['text'], reason: 'text');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputTextContentParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test(
      'optional prompt_cache_breakpoint omit/null/clear and copy ownership',
      () {
        final model = LiveInputTextContentParam.fromJson(_clone(full));
        final omitted = model.copyWith(clearPromptCacheBreakpoint: true);
        expect(omitted.rawJson.containsKey('prompt_cache_breakpoint'), isFalse);
        expect(omitted.hasPromptCacheBreakpoint, isFalse);
        expect(
          model.copyWith(promptCacheBreakpoint: model.promptCacheBreakpoint),
          model,
        );
        final cleared = model.copyWith(promptCacheBreakpoint: null);
        expect(cleared.rawJson.containsKey('prompt_cache_breakpoint'), isTrue);
        expect(cleared.toJson()['prompt_cache_breakpoint'], isNull);
        expect(cleared.hasPromptCacheBreakpoint, isTrue);
      },
    );
    test(
      'known prompt_cache_breakpoint wrong value cannot become overflow',
      () {
        final wire = Map<String, dynamic>.from(_clone(full)! as Map);
        wire['prompt_cache_breakpoint'] = 5;
        expect(
          () => LiveInputTextContentParam.fromJson(wire),
          throwsA(_safe('prompt_cache_breakpoint')),
        );
        expect(
          () => LiveInputTextContentParam.fromJson(
            _clone(full),
          ).copyWith(promptCacheBreakpoint: 5),
          throwsA(_safe('prompt_cache_breakpoint')),
        );
      },
    );
    test('required text absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('text');
      expect(
        () => LiveInputTextContentParam.fromJson(wire),
        throwsA(_safe('text')),
      );
    });
    test('known text wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['text'] = 5;
      expect(
        () => LiveInputTextContentParam.fromJson(wire),
        throwsA(_safe('text')),
      );
      expect(
        () =>
            LiveInputTextContentParam.fromJson(_clone(full)).copyWith(text: 5),
        throwsA(_safe('text')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputTextContentParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputTextContentParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputTextContentParam.fromJson(wire),
        throwsA(_safe('LiveInputTextContentParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputTextContentParam.fromJson(wire),
        throwsA(_safe('LiveInputTextContentParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputTextContentParam.fromJson(wire),
        throwsA(_safe('LiveInputTextContentParam')),
      );
    });
  });
  group('Item', () {
    final minimal = {'role': 'user', 'content': <dynamic>[]};
    final full = {
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
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputHistoryItem.fromJson(_clone(wire));
        final peer = LiveInputHistoryItem.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
  });
  group('ItemReferenceParam', () {
    final minimal = {'id': 'PRIVATE_LIVE_INPUT_PAYLOAD'};
    final full = {'id': 'PRIVATE_LIVE_INPUT_PAYLOAD', 'type': 'item_reference'};
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputItemReferenceParam.fromJson(_clone(wire));
        final peer = LiveInputItemReferenceParam.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputItemReferenceParam.fromJson(_clone(full));
      expect(_wire(model.id), (full as Map)['id'], reason: 'id');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
      expect(model.hasType, isTrue);
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputItemReferenceParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required id absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('id');
      expect(
        () => LiveInputItemReferenceParam.fromJson(wire),
        throwsA(_safe('id')),
      );
    });
    test('known id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['id'] = 5;
      expect(
        () => LiveInputItemReferenceParam.fromJson(wire),
        throwsA(_safe('id')),
      );
      expect(
        () =>
            LiveInputItemReferenceParam.fromJson(_clone(full)).copyWith(id: 5),
        throwsA(_safe('id')),
      );
    });
    test('optional type omit/null/clear and copy ownership', () {
      final model = LiveInputItemReferenceParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearType: true);
      expect(omitted.rawJson.containsKey('type'), isFalse);
      expect(omitted.hasType, isFalse);
      expect(model.copyWith(type: model.type), model);
      final cleared = model.copyWith(type: null);
      expect(cleared.rawJson.containsKey('type'), isTrue);
      expect(cleared.toJson()['type'], isNull);
      expect(cleared.hasType, isTrue);
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputItemReferenceParam.fromJson(wire),
        throwsA(_safe('type')),
      );
      expect(
        () => LiveInputItemReferenceParam.fromJson(
          _clone(full),
        ).copyWith(type: 5),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputItemReferenceParam.fromJson(wire),
        throwsA(_safe('LiveInputItemReferenceParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputItemReferenceParam.fromJson(wire),
        throwsA(_safe('LiveInputItemReferenceParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputItemReferenceParam.fromJson(wire),
        throwsA(_safe('LiveInputItemReferenceParam')),
      );
    });
  });
  group('KeyPressAction', () {
    final minimal = {'type': 'keypress', 'keys': <dynamic>[]};
    final full = {
      'keys': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
      'type': 'keypress',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputKeyPressAction.fromJson(_clone(wire));
        final peer = LiveInputKeyPressAction.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputKeyPressAction.fromJson(_clone(full));
      expect(_wire(model.keys), (full as Map)['keys'], reason: 'keys');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputKeyPressAction.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required keys absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('keys');
      expect(
        () => LiveInputKeyPressAction.fromJson(wire),
        throwsA(_safe('keys')),
      );
    });
    test('known keys wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['keys'] = 5;
      expect(
        () => LiveInputKeyPressAction.fromJson(wire),
        throwsA(_safe('keys')),
      );
      expect(
        () => LiveInputKeyPressAction.fromJson(_clone(full)).copyWith(keys: 5),
        throwsA(_safe('keys')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputKeyPressAction.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputKeyPressAction.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputKeyPressAction.fromJson(wire),
        throwsA(_safe('LiveInputKeyPressAction')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputKeyPressAction.fromJson(wire),
        throwsA(_safe('LiveInputKeyPressAction')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputKeyPressAction.fromJson(wire),
        throwsA(_safe('LiveInputKeyPressAction')),
      );
    });
  });
  group('LocalEnvironmentParam', () {
    final minimal = {'type': 'local'};
    final full = {
      'skills': [
        {
          'description': 'PRIVATE_LIVE_INPUT_PAYLOAD',
          'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
          'path': 'PRIVATE_LIVE_INPUT_PAYLOAD',
        },
      ],
      'type': 'local',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputLocalEnvironmentParam.fromJson(_clone(wire));
        final peer = LiveInputLocalEnvironmentParam.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputLocalEnvironmentParam.fromJson(_clone(full));
      expect(_wire(model.skills), (full as Map)['skills'], reason: 'skills');
      expect(model.hasSkills, isTrue);
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputLocalEnvironmentParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('optional skills omit/null/clear and copy ownership', () {
      final model = LiveInputLocalEnvironmentParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearSkills: true);
      expect(omitted.rawJson.containsKey('skills'), isFalse);
      expect(omitted.hasSkills, isFalse);
      expect(model.copyWith(skills: model.skills), model);
      expect(() => model.copyWith(skills: null), throwsA(_safe('skills')));
    });
    test('known skills wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['skills'] = 5;
      expect(
        () => LiveInputLocalEnvironmentParam.fromJson(wire),
        throwsA(_safe('skills')),
      );
      expect(
        () => LiveInputLocalEnvironmentParam.fromJson(
          _clone(full),
        ).copyWith(skills: 5),
        throwsA(_safe('skills')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputLocalEnvironmentParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputLocalEnvironmentParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputLocalEnvironmentParam.fromJson(wire),
        throwsA(_safe('LiveInputLocalEnvironmentParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputLocalEnvironmentParam.fromJson(wire),
        throwsA(_safe('LiveInputLocalEnvironmentParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputLocalEnvironmentParam.fromJson(wire),
        throwsA(_safe('LiveInputLocalEnvironmentParam')),
      );
    });
  });
  group('LocalShellExecAction', () {
    final minimal = {
      'type': 'exec',
      'command': <dynamic>[],
      'env': <String, dynamic>{},
    };
    final full = {
      'command': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
      'env': <String, dynamic>{},
      'timeout_ms': 0,
      'type': 'exec',
      'user': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'working_directory': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputLocalShellExecAction.fromJson(_clone(wire));
        final peer = LiveInputLocalShellExecAction.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputLocalShellExecAction.fromJson(_clone(full));
      expect(_wire(model.command), (full as Map)['command'], reason: 'command');
      expect(_wire(model.env), (full as Map)['env'], reason: 'env');
      expect(
        _wire(model.timeoutMs),
        (full as Map)['timeout_ms'],
        reason: 'timeout_ms',
      );
      expect(model.hasTimeoutMs, isTrue);
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
      expect(_wire(model.user), (full as Map)['user'], reason: 'user');
      expect(model.hasUser, isTrue);
      expect(
        _wire(model.workingDirectory),
        (full as Map)['working_directory'],
        reason: 'working_directory',
      );
      expect(model.hasWorkingDirectory, isTrue);
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputLocalShellExecAction.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required command absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('command');
      expect(
        () => LiveInputLocalShellExecAction.fromJson(wire),
        throwsA(_safe('command')),
      );
    });
    test('known command wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['command'] = 5;
      expect(
        () => LiveInputLocalShellExecAction.fromJson(wire),
        throwsA(_safe('command')),
      );
      expect(
        () => LiveInputLocalShellExecAction.fromJson(
          _clone(full),
        ).copyWith(command: 5),
        throwsA(_safe('command')),
      );
    });
    test('required env absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('env');
      expect(
        () => LiveInputLocalShellExecAction.fromJson(wire),
        throwsA(_safe('env')),
      );
    });
    test('known env wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['env'] = 5;
      expect(
        () => LiveInputLocalShellExecAction.fromJson(wire),
        throwsA(_safe('env')),
      );
      expect(
        () => LiveInputLocalShellExecAction.fromJson(
          _clone(full),
        ).copyWith(env: 5),
        throwsA(_safe('env')),
      );
    });
    test('optional timeout_ms omit/null/clear and copy ownership', () {
      final model = LiveInputLocalShellExecAction.fromJson(_clone(full));
      final omitted = model.copyWith(clearTimeoutMs: true);
      expect(omitted.rawJson.containsKey('timeout_ms'), isFalse);
      expect(omitted.hasTimeoutMs, isFalse);
      expect(model.copyWith(timeoutMs: model.timeoutMs), model);
      final cleared = model.copyWith(timeoutMs: null);
      expect(cleared.rawJson.containsKey('timeout_ms'), isTrue);
      expect(cleared.toJson()['timeout_ms'], isNull);
      expect(cleared.hasTimeoutMs, isTrue);
    });
    test('known timeout_ms wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['timeout_ms'] = false;
      expect(
        () => LiveInputLocalShellExecAction.fromJson(wire),
        throwsA(_safe('timeout_ms')),
      );
      expect(
        () => LiveInputLocalShellExecAction.fromJson(
          _clone(full),
        ).copyWith(timeoutMs: false),
        throwsA(_safe('timeout_ms')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputLocalShellExecAction.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputLocalShellExecAction.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('optional user omit/null/clear and copy ownership', () {
      final model = LiveInputLocalShellExecAction.fromJson(_clone(full));
      final omitted = model.copyWith(clearUser: true);
      expect(omitted.rawJson.containsKey('user'), isFalse);
      expect(omitted.hasUser, isFalse);
      expect(model.copyWith(user: model.user), model);
      final cleared = model.copyWith(user: null);
      expect(cleared.rawJson.containsKey('user'), isTrue);
      expect(cleared.toJson()['user'], isNull);
      expect(cleared.hasUser, isTrue);
    });
    test('known user wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['user'] = 5;
      expect(
        () => LiveInputLocalShellExecAction.fromJson(wire),
        throwsA(_safe('user')),
      );
      expect(
        () => LiveInputLocalShellExecAction.fromJson(
          _clone(full),
        ).copyWith(user: 5),
        throwsA(_safe('user')),
      );
    });
    test('optional working_directory omit/null/clear and copy ownership', () {
      final model = LiveInputLocalShellExecAction.fromJson(_clone(full));
      final omitted = model.copyWith(clearWorkingDirectory: true);
      expect(omitted.rawJson.containsKey('working_directory'), isFalse);
      expect(omitted.hasWorkingDirectory, isFalse);
      expect(model.copyWith(workingDirectory: model.workingDirectory), model);
      final cleared = model.copyWith(workingDirectory: null);
      expect(cleared.rawJson.containsKey('working_directory'), isTrue);
      expect(cleared.toJson()['working_directory'], isNull);
      expect(cleared.hasWorkingDirectory, isTrue);
    });
    test('known working_directory wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['working_directory'] = 5;
      expect(
        () => LiveInputLocalShellExecAction.fromJson(wire),
        throwsA(_safe('working_directory')),
      );
      expect(
        () => LiveInputLocalShellExecAction.fromJson(
          _clone(full),
        ).copyWith(workingDirectory: 5),
        throwsA(_safe('working_directory')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputLocalShellExecAction.fromJson(wire),
        throwsA(_safe('LiveInputLocalShellExecAction')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputLocalShellExecAction.fromJson(wire),
        throwsA(_safe('LiveInputLocalShellExecAction')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputLocalShellExecAction.fromJson(wire),
        throwsA(_safe('LiveInputLocalShellExecAction')),
      );
    });
  });
  group('LocalShellToolCall', () {
    final minimal = {
      'type': 'local_shell_call',
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'call_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'action': {
        'type': 'exec',
        'command': <dynamic>[],
        'env': <String, dynamic>{},
      },
      'status': 'in_progress',
    };
    final full = {
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
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputLocalShellToolCall.fromJson(_clone(wire));
        final peer = LiveInputLocalShellToolCall.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputLocalShellToolCall.fromJson(_clone(full));
      expect(_wire(model.action), (full as Map)['action'], reason: 'action');
      expect(_wire(model.callId), (full as Map)['call_id'], reason: 'call_id');
      expect(_wire(model.id), (full as Map)['id'], reason: 'id');
      expect(_wire(model.status), (full as Map)['status'], reason: 'status');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputLocalShellToolCall.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required action absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('action');
      expect(
        () => LiveInputLocalShellToolCall.fromJson(wire),
        throwsA(_safe('action')),
      );
    });
    test('known action wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['action'] = 5;
      expect(
        () => LiveInputLocalShellToolCall.fromJson(wire),
        throwsA(_safe('action')),
      );
      expect(
        () => LiveInputLocalShellToolCall.fromJson(
          _clone(full),
        ).copyWith(action: 5),
        throwsA(_safe('action')),
      );
    });
    test('required call_id absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('call_id');
      expect(
        () => LiveInputLocalShellToolCall.fromJson(wire),
        throwsA(_safe('call_id')),
      );
    });
    test('known call_id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['call_id'] = 5;
      expect(
        () => LiveInputLocalShellToolCall.fromJson(wire),
        throwsA(_safe('call_id')),
      );
      expect(
        () => LiveInputLocalShellToolCall.fromJson(
          _clone(full),
        ).copyWith(callId: 5),
        throwsA(_safe('call_id')),
      );
    });
    test('required id absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('id');
      expect(
        () => LiveInputLocalShellToolCall.fromJson(wire),
        throwsA(_safe('id')),
      );
    });
    test('known id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['id'] = 5;
      expect(
        () => LiveInputLocalShellToolCall.fromJson(wire),
        throwsA(_safe('id')),
      );
      expect(
        () =>
            LiveInputLocalShellToolCall.fromJson(_clone(full)).copyWith(id: 5),
        throwsA(_safe('id')),
      );
    });
    test('required status absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('status');
      expect(
        () => LiveInputLocalShellToolCall.fromJson(wire),
        throwsA(_safe('status')),
      );
    });
    test('known status wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['status'] = 5;
      expect(
        () => LiveInputLocalShellToolCall.fromJson(wire),
        throwsA(_safe('status')),
      );
      expect(
        () => LiveInputLocalShellToolCall.fromJson(
          _clone(full),
        ).copyWith(status: 5),
        throwsA(_safe('status')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputLocalShellToolCall.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputLocalShellToolCall.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputLocalShellToolCall.fromJson(wire),
        throwsA(_safe('LiveInputLocalShellToolCall')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputLocalShellToolCall.fromJson(wire),
        throwsA(_safe('LiveInputLocalShellToolCall')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputLocalShellToolCall.fromJson(wire),
        throwsA(_safe('LiveInputLocalShellToolCall')),
      );
    });
  });
  group('LocalShellToolCallOutput', () {
    final minimal = {
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'local_shell_call_output',
      'call_id': null,
      'output': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    final full = {
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'output': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'status': 'in_progress',
      'type': 'local_shell_call_output',
      'call_id': null,
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputLocalShellToolCallOutput.fromJson(_clone(wire));
        final peer = LiveInputLocalShellToolCallOutput.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputLocalShellToolCallOutput.fromJson(_clone(full));
      expect(_wire(model.id), (full as Map)['id'], reason: 'id');
      expect(_wire(model.output), (full as Map)['output'], reason: 'output');
      expect(_wire(model.status), (full as Map)['status'], reason: 'status');
      expect(model.hasStatus, isTrue);
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputLocalShellToolCallOutput.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required id absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('id');
      expect(
        () => LiveInputLocalShellToolCallOutput.fromJson(wire),
        throwsA(_safe('id')),
      );
    });
    test('known id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['id'] = 5;
      expect(
        () => LiveInputLocalShellToolCallOutput.fromJson(wire),
        throwsA(_safe('id')),
      );
      expect(
        () => LiveInputLocalShellToolCallOutput.fromJson(
          _clone(full),
        ).copyWith(id: 5),
        throwsA(_safe('id')),
      );
    });
    test('required output absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('output');
      expect(
        () => LiveInputLocalShellToolCallOutput.fromJson(wire),
        throwsA(_safe('output')),
      );
    });
    test('known output wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['output'] = 5;
      expect(
        () => LiveInputLocalShellToolCallOutput.fromJson(wire),
        throwsA(_safe('output')),
      );
      expect(
        () => LiveInputLocalShellToolCallOutput.fromJson(
          _clone(full),
        ).copyWith(output: 5),
        throwsA(_safe('output')),
      );
    });
    test('optional status omit/null/clear and copy ownership', () {
      final model = LiveInputLocalShellToolCallOutput.fromJson(_clone(full));
      final omitted = model.copyWith(clearStatus: true);
      expect(omitted.rawJson.containsKey('status'), isFalse);
      expect(omitted.hasStatus, isFalse);
      expect(model.copyWith(status: model.status), model);
      final cleared = model.copyWith(status: null);
      expect(cleared.rawJson.containsKey('status'), isTrue);
      expect(cleared.toJson()['status'], isNull);
      expect(cleared.hasStatus, isTrue);
    });
    test('known status wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['status'] = 5;
      expect(
        () => LiveInputLocalShellToolCallOutput.fromJson(wire),
        throwsA(_safe('status')),
      );
      expect(
        () => LiveInputLocalShellToolCallOutput.fromJson(
          _clone(full),
        ).copyWith(status: 5),
        throwsA(_safe('status')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputLocalShellToolCallOutput.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputLocalShellToolCallOutput.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputLocalShellToolCallOutput.fromJson(wire),
        throwsA(_safe('LiveInputLocalShellToolCallOutput')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputLocalShellToolCallOutput.fromJson(wire),
        throwsA(_safe('LiveInputLocalShellToolCallOutput')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputLocalShellToolCallOutput.fromJson(wire),
        throwsA(_safe('LiveInputLocalShellToolCallOutput')),
      );
    });
  });
  group('LocalShellToolParam', () {
    final minimal = {'type': 'local_shell'};
    final full = {'type': 'local_shell'};
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputLocalShellToolParam.fromJson(_clone(wire));
        final peer = LiveInputLocalShellToolParam.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputLocalShellToolParam.fromJson(_clone(full));
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputLocalShellToolParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputLocalShellToolParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputLocalShellToolParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputLocalShellToolParam.fromJson(wire),
        throwsA(_safe('LiveInputLocalShellToolParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputLocalShellToolParam.fromJson(wire),
        throwsA(_safe('LiveInputLocalShellToolParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputLocalShellToolParam.fromJson(wire),
        throwsA(_safe('LiveInputLocalShellToolParam')),
      );
    });
  });
  group('LocalSkillParam', () {
    final minimal = {
      'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'description': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'path': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    final full = {
      'description': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'path': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputLocalSkillParam.fromJson(_clone(wire));
        final peer = LiveInputLocalSkillParam.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputLocalSkillParam.fromJson(_clone(full));
      expect(
        _wire(model.description),
        (full as Map)['description'],
        reason: 'description',
      );
      expect(_wire(model.name), (full as Map)['name'], reason: 'name');
      expect(_wire(model.path), (full as Map)['path'], reason: 'path');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputLocalSkillParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required description absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('description');
      expect(
        () => LiveInputLocalSkillParam.fromJson(wire),
        throwsA(_safe('description')),
      );
    });
    test('known description wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['description'] = 5;
      expect(
        () => LiveInputLocalSkillParam.fromJson(wire),
        throwsA(_safe('description')),
      );
      expect(
        () => LiveInputLocalSkillParam.fromJson(
          _clone(full),
        ).copyWith(description: 5),
        throwsA(_safe('description')),
      );
    });
    test('required name absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('name');
      expect(
        () => LiveInputLocalSkillParam.fromJson(wire),
        throwsA(_safe('name')),
      );
    });
    test('known name wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['name'] = 5;
      expect(
        () => LiveInputLocalSkillParam.fromJson(wire),
        throwsA(_safe('name')),
      );
      expect(
        () => LiveInputLocalSkillParam.fromJson(_clone(full)).copyWith(name: 5),
        throwsA(_safe('name')),
      );
    });
    test('required path absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('path');
      expect(
        () => LiveInputLocalSkillParam.fromJson(wire),
        throwsA(_safe('path')),
      );
    });
    test('known path wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['path'] = 5;
      expect(
        () => LiveInputLocalSkillParam.fromJson(wire),
        throwsA(_safe('path')),
      );
      expect(
        () => LiveInputLocalSkillParam.fromJson(_clone(full)).copyWith(path: 5),
        throwsA(_safe('path')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputLocalSkillParam.fromJson(wire),
        throwsA(_safe('LiveInputLocalSkillParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputLocalSkillParam.fromJson(wire),
        throwsA(_safe('LiveInputLocalSkillParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputLocalSkillParam.fromJson(wire),
        throwsA(_safe('LiveInputLocalSkillParam')),
      );
    });
  });
  group('LogProb', () {
    final minimal = {
      'token': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'logprob': 0,
      'bytes': <dynamic>[],
      'top_logprobs': <dynamic>[],
    };
    final full = {
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
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputLogProb.fromJson(_clone(wire));
        final peer = LiveInputLogProb.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputLogProb.fromJson(_clone(full));
      expect(_wire(model.bytes), (full as Map)['bytes'], reason: 'bytes');
      expect(_wire(model.logprob), (full as Map)['logprob'], reason: 'logprob');
      expect(_wire(model.token), (full as Map)['token'], reason: 'token');
      expect(
        _wire(model.topLogprobs),
        (full as Map)['top_logprobs'],
        reason: 'top_logprobs',
      );
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputLogProb.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required bytes absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('bytes');
      expect(() => LiveInputLogProb.fromJson(wire), throwsA(_safe('bytes')));
    });
    test('known bytes wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['bytes'] = 5;
      expect(() => LiveInputLogProb.fromJson(wire), throwsA(_safe('bytes')));
      expect(
        () => LiveInputLogProb.fromJson(_clone(full)).copyWith(bytes: 5),
        throwsA(_safe('bytes')),
      );
    });
    test('required logprob absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('logprob');
      expect(() => LiveInputLogProb.fromJson(wire), throwsA(_safe('logprob')));
    });
    test('known logprob wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['logprob'] = false;
      expect(() => LiveInputLogProb.fromJson(wire), throwsA(_safe('logprob')));
      expect(
        () => LiveInputLogProb.fromJson(_clone(full)).copyWith(logprob: false),
        throwsA(_safe('logprob')),
      );
    });
    test('required token absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('token');
      expect(() => LiveInputLogProb.fromJson(wire), throwsA(_safe('token')));
    });
    test('known token wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['token'] = 5;
      expect(() => LiveInputLogProb.fromJson(wire), throwsA(_safe('token')));
      expect(
        () => LiveInputLogProb.fromJson(_clone(full)).copyWith(token: 5),
        throwsA(_safe('token')),
      );
    });
    test('required top_logprobs absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('top_logprobs');
      expect(
        () => LiveInputLogProb.fromJson(wire),
        throwsA(_safe('top_logprobs')),
      );
    });
    test('known top_logprobs wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['top_logprobs'] = 5;
      expect(
        () => LiveInputLogProb.fromJson(wire),
        throwsA(_safe('top_logprobs')),
      );
      expect(
        () => LiveInputLogProb.fromJson(_clone(full)).copyWith(topLogprobs: 5),
        throwsA(_safe('top_logprobs')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputLogProb.fromJson(wire),
        throwsA(_safe('LiveInputLogProb')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputLogProb.fromJson(wire),
        throwsA(_safe('LiveInputLogProb')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputLogProb.fromJson(wire),
        throwsA(_safe('LiveInputLogProb')),
      );
    });
  });
  group('MCPApprovalRequest', () {
    final minimal = {
      'type': 'mcp_approval_request',
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'server_label': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'arguments': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    final full = {
      'arguments': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'server_label': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'mcp_approval_request',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputMCPApprovalRequest.fromJson(_clone(wire));
        final peer = LiveInputMCPApprovalRequest.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputMCPApprovalRequest.fromJson(_clone(full));
      expect(
        _wire(model.arguments),
        (full as Map)['arguments'],
        reason: 'arguments',
      );
      expect(_wire(model.id), (full as Map)['id'], reason: 'id');
      expect(_wire(model.name), (full as Map)['name'], reason: 'name');
      expect(
        _wire(model.serverLabel),
        (full as Map)['server_label'],
        reason: 'server_label',
      );
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputMCPApprovalRequest.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required arguments absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('arguments');
      expect(
        () => LiveInputMCPApprovalRequest.fromJson(wire),
        throwsA(_safe('arguments')),
      );
    });
    test('known arguments wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['arguments'] = 5;
      expect(
        () => LiveInputMCPApprovalRequest.fromJson(wire),
        throwsA(_safe('arguments')),
      );
      expect(
        () => LiveInputMCPApprovalRequest.fromJson(
          _clone(full),
        ).copyWith(arguments: 5),
        throwsA(_safe('arguments')),
      );
    });
    test('required id absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('id');
      expect(
        () => LiveInputMCPApprovalRequest.fromJson(wire),
        throwsA(_safe('id')),
      );
    });
    test('known id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['id'] = 5;
      expect(
        () => LiveInputMCPApprovalRequest.fromJson(wire),
        throwsA(_safe('id')),
      );
      expect(
        () =>
            LiveInputMCPApprovalRequest.fromJson(_clone(full)).copyWith(id: 5),
        throwsA(_safe('id')),
      );
    });
    test('required name absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('name');
      expect(
        () => LiveInputMCPApprovalRequest.fromJson(wire),
        throwsA(_safe('name')),
      );
    });
    test('known name wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['name'] = 5;
      expect(
        () => LiveInputMCPApprovalRequest.fromJson(wire),
        throwsA(_safe('name')),
      );
      expect(
        () => LiveInputMCPApprovalRequest.fromJson(
          _clone(full),
        ).copyWith(name: 5),
        throwsA(_safe('name')),
      );
    });
    test('required server_label absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('server_label');
      expect(
        () => LiveInputMCPApprovalRequest.fromJson(wire),
        throwsA(_safe('server_label')),
      );
    });
    test('known server_label wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['server_label'] = 5;
      expect(
        () => LiveInputMCPApprovalRequest.fromJson(wire),
        throwsA(_safe('server_label')),
      );
      expect(
        () => LiveInputMCPApprovalRequest.fromJson(
          _clone(full),
        ).copyWith(serverLabel: 5),
        throwsA(_safe('server_label')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputMCPApprovalRequest.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputMCPApprovalRequest.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputMCPApprovalRequest.fromJson(wire),
        throwsA(_safe('LiveInputMCPApprovalRequest')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputMCPApprovalRequest.fromJson(wire),
        throwsA(_safe('LiveInputMCPApprovalRequest')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputMCPApprovalRequest.fromJson(wire),
        throwsA(_safe('LiveInputMCPApprovalRequest')),
      );
    });
  });
  group('MCPApprovalResponse', () {
    final minimal = {
      'type': 'mcp_approval_response',
      'request_id': null,
      'approve': false,
      'approval_request_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    final full = {
      'approval_request_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'approve': false,
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'reason': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'mcp_approval_response',
      'request_id': null,
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputMCPApprovalResponse.fromJson(_clone(wire));
        final peer = LiveInputMCPApprovalResponse.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputMCPApprovalResponse.fromJson(_clone(full));
      expect(
        _wire(model.approvalRequestId),
        (full as Map)['approval_request_id'],
        reason: 'approval_request_id',
      );
      expect(_wire(model.approve), (full as Map)['approve'], reason: 'approve');
      expect(_wire(model.id), (full as Map)['id'], reason: 'id');
      expect(model.hasId, isTrue);
      expect(_wire(model.reason), (full as Map)['reason'], reason: 'reason');
      expect(model.hasReason, isTrue);
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputMCPApprovalResponse.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required approval_request_id absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('approval_request_id');
      expect(
        () => LiveInputMCPApprovalResponse.fromJson(wire),
        throwsA(_safe('approval_request_id')),
      );
    });
    test('known approval_request_id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['approval_request_id'] = 5;
      expect(
        () => LiveInputMCPApprovalResponse.fromJson(wire),
        throwsA(_safe('approval_request_id')),
      );
      expect(
        () => LiveInputMCPApprovalResponse.fromJson(
          _clone(full),
        ).copyWith(approvalRequestId: 5),
        throwsA(_safe('approval_request_id')),
      );
    });
    test('required approve absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('approve');
      expect(
        () => LiveInputMCPApprovalResponse.fromJson(wire),
        throwsA(_safe('approve')),
      );
    });
    test('known approve wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['approve'] = 5;
      expect(
        () => LiveInputMCPApprovalResponse.fromJson(wire),
        throwsA(_safe('approve')),
      );
      expect(
        () => LiveInputMCPApprovalResponse.fromJson(
          _clone(full),
        ).copyWith(approve: 5),
        throwsA(_safe('approve')),
      );
    });
    test('optional id omit/null/clear and copy ownership', () {
      final model = LiveInputMCPApprovalResponse.fromJson(_clone(full));
      final omitted = model.copyWith(clearId: true);
      expect(omitted.rawJson.containsKey('id'), isFalse);
      expect(omitted.hasId, isFalse);
      expect(model.copyWith(id: model.id), model);
      final cleared = model.copyWith(id: null);
      expect(cleared.rawJson.containsKey('id'), isTrue);
      expect(cleared.toJson()['id'], isNull);
      expect(cleared.hasId, isTrue);
    });
    test('known id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['id'] = 5;
      expect(
        () => LiveInputMCPApprovalResponse.fromJson(wire),
        throwsA(_safe('id')),
      );
      expect(
        () =>
            LiveInputMCPApprovalResponse.fromJson(_clone(full)).copyWith(id: 5),
        throwsA(_safe('id')),
      );
    });
    test('optional reason omit/null/clear and copy ownership', () {
      final model = LiveInputMCPApprovalResponse.fromJson(_clone(full));
      final omitted = model.copyWith(clearReason: true);
      expect(omitted.rawJson.containsKey('reason'), isFalse);
      expect(omitted.hasReason, isFalse);
      expect(model.copyWith(reason: model.reason), model);
      final cleared = model.copyWith(reason: null);
      expect(cleared.rawJson.containsKey('reason'), isTrue);
      expect(cleared.toJson()['reason'], isNull);
      expect(cleared.hasReason, isTrue);
    });
    test('known reason wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['reason'] = 5;
      expect(
        () => LiveInputMCPApprovalResponse.fromJson(wire),
        throwsA(_safe('reason')),
      );
      expect(
        () => LiveInputMCPApprovalResponse.fromJson(
          _clone(full),
        ).copyWith(reason: 5),
        throwsA(_safe('reason')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputMCPApprovalResponse.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputMCPApprovalResponse.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputMCPApprovalResponse.fromJson(wire),
        throwsA(_safe('LiveInputMCPApprovalResponse')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputMCPApprovalResponse.fromJson(wire),
        throwsA(_safe('LiveInputMCPApprovalResponse')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputMCPApprovalResponse.fromJson(wire),
        throwsA(_safe('LiveInputMCPApprovalResponse')),
      );
    });
  });
  group('MCPListTools', () {
    final minimal = {
      'type': 'mcp_list_tools',
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'server_label': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'tools': <dynamic>[],
    };
    final full = {
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
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputMCPListTools.fromJson(_clone(wire));
        final peer = LiveInputMCPListTools.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputMCPListTools.fromJson(_clone(full));
      expect(_wire(model.error), (full as Map)['error'], reason: 'error');
      expect(model.hasError, isTrue);
      expect(_wire(model.id), (full as Map)['id'], reason: 'id');
      expect(
        _wire(model.serverLabel),
        (full as Map)['server_label'],
        reason: 'server_label',
      );
      expect(_wire(model.tools), (full as Map)['tools'], reason: 'tools');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputMCPListTools.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('optional error omit/null/clear and copy ownership', () {
      final model = LiveInputMCPListTools.fromJson(_clone(full));
      final omitted = model.copyWith(clearError: true);
      expect(omitted.rawJson.containsKey('error'), isFalse);
      expect(omitted.hasError, isFalse);
      expect(model.copyWith(error: model.error), model);
      final cleared = model.copyWith(error: null);
      expect(cleared.rawJson.containsKey('error'), isTrue);
      expect(cleared.toJson()['error'], isNull);
      expect(cleared.hasError, isTrue);
    });
    test('known error wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['error'] = 5;
      expect(
        () => LiveInputMCPListTools.fromJson(wire),
        throwsA(_safe('error')),
      );
      expect(
        () => LiveInputMCPListTools.fromJson(_clone(full)).copyWith(error: 5),
        throwsA(_safe('error')),
      );
    });
    test('required id absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('id');
      expect(() => LiveInputMCPListTools.fromJson(wire), throwsA(_safe('id')));
    });
    test('known id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['id'] = 5;
      expect(() => LiveInputMCPListTools.fromJson(wire), throwsA(_safe('id')));
      expect(
        () => LiveInputMCPListTools.fromJson(_clone(full)).copyWith(id: 5),
        throwsA(_safe('id')),
      );
    });
    test('required server_label absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('server_label');
      expect(
        () => LiveInputMCPListTools.fromJson(wire),
        throwsA(_safe('server_label')),
      );
    });
    test('known server_label wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['server_label'] = 5;
      expect(
        () => LiveInputMCPListTools.fromJson(wire),
        throwsA(_safe('server_label')),
      );
      expect(
        () => LiveInputMCPListTools.fromJson(
          _clone(full),
        ).copyWith(serverLabel: 5),
        throwsA(_safe('server_label')),
      );
    });
    test('required tools absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('tools');
      expect(
        () => LiveInputMCPListTools.fromJson(wire),
        throwsA(_safe('tools')),
      );
    });
    test('known tools wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['tools'] = 5;
      expect(
        () => LiveInputMCPListTools.fromJson(wire),
        throwsA(_safe('tools')),
      );
      expect(
        () => LiveInputMCPListTools.fromJson(_clone(full)).copyWith(tools: 5),
        throwsA(_safe('tools')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputMCPListTools.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputMCPListTools.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputMCPListTools.fromJson(wire),
        throwsA(_safe('LiveInputMCPListTools')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputMCPListTools.fromJson(wire),
        throwsA(_safe('LiveInputMCPListTools')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputMCPListTools.fromJson(wire),
        throwsA(_safe('LiveInputMCPListTools')),
      );
    });
  });
  group('MCPListToolsTool', () {
    final minimal = {
      'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'input_schema': <String, dynamic>{},
    };
    final full = {
      'annotations': <String, dynamic>{},
      'description': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'input_schema': <String, dynamic>{},
      'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputMCPListToolsTool.fromJson(_clone(wire));
        final peer = LiveInputMCPListToolsTool.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputMCPListToolsTool.fromJson(_clone(full));
      expect(
        _wire(model.annotations),
        (full as Map)['annotations'],
        reason: 'annotations',
      );
      expect(model.hasAnnotations, isTrue);
      expect(
        _wire(model.description),
        (full as Map)['description'],
        reason: 'description',
      );
      expect(model.hasDescription, isTrue);
      expect(
        _wire(model.inputSchema),
        (full as Map)['input_schema'],
        reason: 'input_schema',
      );
      expect(_wire(model.name), (full as Map)['name'], reason: 'name');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputMCPListToolsTool.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('optional annotations omit/null/clear and copy ownership', () {
      final model = LiveInputMCPListToolsTool.fromJson(_clone(full));
      final omitted = model.copyWith(clearAnnotations: true);
      expect(omitted.rawJson.containsKey('annotations'), isFalse);
      expect(omitted.hasAnnotations, isFalse);
      expect(model.copyWith(annotations: model.annotations), model);
      final cleared = model.copyWith(annotations: null);
      expect(cleared.rawJson.containsKey('annotations'), isTrue);
      expect(cleared.toJson()['annotations'], isNull);
      expect(cleared.hasAnnotations, isTrue);
    });
    test('known annotations wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['annotations'] = 5;
      expect(
        () => LiveInputMCPListToolsTool.fromJson(wire),
        throwsA(_safe('annotations')),
      );
      expect(
        () => LiveInputMCPListToolsTool.fromJson(
          _clone(full),
        ).copyWith(annotations: 5),
        throwsA(_safe('annotations')),
      );
    });
    test('optional description omit/null/clear and copy ownership', () {
      final model = LiveInputMCPListToolsTool.fromJson(_clone(full));
      final omitted = model.copyWith(clearDescription: true);
      expect(omitted.rawJson.containsKey('description'), isFalse);
      expect(omitted.hasDescription, isFalse);
      expect(model.copyWith(description: model.description), model);
      final cleared = model.copyWith(description: null);
      expect(cleared.rawJson.containsKey('description'), isTrue);
      expect(cleared.toJson()['description'], isNull);
      expect(cleared.hasDescription, isTrue);
    });
    test('known description wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['description'] = 5;
      expect(
        () => LiveInputMCPListToolsTool.fromJson(wire),
        throwsA(_safe('description')),
      );
      expect(
        () => LiveInputMCPListToolsTool.fromJson(
          _clone(full),
        ).copyWith(description: 5),
        throwsA(_safe('description')),
      );
    });
    test('required input_schema absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('input_schema');
      expect(
        () => LiveInputMCPListToolsTool.fromJson(wire),
        throwsA(_safe('input_schema')),
      );
    });
    test('known input_schema wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['input_schema'] = 5;
      expect(
        () => LiveInputMCPListToolsTool.fromJson(wire),
        throwsA(_safe('input_schema')),
      );
      expect(
        () => LiveInputMCPListToolsTool.fromJson(
          _clone(full),
        ).copyWith(inputSchema: 5),
        throwsA(_safe('input_schema')),
      );
    });
    test('required name absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('name');
      expect(
        () => LiveInputMCPListToolsTool.fromJson(wire),
        throwsA(_safe('name')),
      );
    });
    test('known name wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['name'] = 5;
      expect(
        () => LiveInputMCPListToolsTool.fromJson(wire),
        throwsA(_safe('name')),
      );
      expect(
        () =>
            LiveInputMCPListToolsTool.fromJson(_clone(full)).copyWith(name: 5),
        throwsA(_safe('name')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputMCPListToolsTool.fromJson(wire),
        throwsA(_safe('LiveInputMCPListToolsTool')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputMCPListToolsTool.fromJson(wire),
        throwsA(_safe('LiveInputMCPListToolsTool')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputMCPListToolsTool.fromJson(wire),
        throwsA(_safe('LiveInputMCPListToolsTool')),
      );
    });
  });
  group('MCPProtocolError', () {
    final minimal = {
      'type': 'mcp_protocol_error',
      'code': 0,
      'message': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    final full = {
      'code': 0,
      'message': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'mcp_protocol_error',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputMCPProtocolError.fromJson(_clone(wire));
        final peer = LiveInputMCPProtocolError.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputMCPProtocolError.fromJson(_clone(full));
      expect(_wire(model.code), (full as Map)['code'], reason: 'code');
      expect(_wire(model.message), (full as Map)['message'], reason: 'message');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputMCPProtocolError.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required code absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('code');
      expect(
        () => LiveInputMCPProtocolError.fromJson(wire),
        throwsA(_safe('code')),
      );
    });
    test('known code wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['code'] = false;
      expect(
        () => LiveInputMCPProtocolError.fromJson(wire),
        throwsA(_safe('code')),
      );
      expect(
        () => LiveInputMCPProtocolError.fromJson(
          _clone(full),
        ).copyWith(code: false),
        throwsA(_safe('code')),
      );
    });
    test('required message absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('message');
      expect(
        () => LiveInputMCPProtocolError.fromJson(wire),
        throwsA(_safe('message')),
      );
    });
    test('known message wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['message'] = 5;
      expect(
        () => LiveInputMCPProtocolError.fromJson(wire),
        throwsA(_safe('message')),
      );
      expect(
        () => LiveInputMCPProtocolError.fromJson(
          _clone(full),
        ).copyWith(message: 5),
        throwsA(_safe('message')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputMCPProtocolError.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputMCPProtocolError.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputMCPProtocolError.fromJson(wire),
        throwsA(_safe('LiveInputMCPProtocolError')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputMCPProtocolError.fromJson(wire),
        throwsA(_safe('LiveInputMCPProtocolError')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputMCPProtocolError.fromJson(wire),
        throwsA(_safe('LiveInputMCPProtocolError')),
      );
    });
  });
  group('MCPTool', () {
    final minimal = {
      'type': 'mcp',
      'server_label': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    final full = {
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
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputMCPTool.fromJson(_clone(wire));
        final peer = LiveInputMCPTool.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputMCPTool.fromJson(_clone(full));
      expect(
        _wire(model.allowedCallers),
        (full as Map)['allowed_callers'],
        reason: 'allowed_callers',
      );
      expect(model.hasAllowedCallers, isTrue);
      expect(
        _wire(model.allowedTools),
        (full as Map)['allowed_tools'],
        reason: 'allowed_tools',
      );
      expect(model.hasAllowedTools, isTrue);
      expect(
        _wire(model.authorization),
        (full as Map)['authorization'],
        reason: 'authorization',
      );
      expect(model.hasAuthorization, isTrue);
      expect(
        _wire(model.connectorId),
        (full as Map)['connector_id'],
        reason: 'connector_id',
      );
      expect(model.hasConnectorId, isTrue);
      expect(
        _wire(model.deferLoading),
        (full as Map)['defer_loading'],
        reason: 'defer_loading',
      );
      expect(model.hasDeferLoading, isTrue);
      expect(_wire(model.headers), (full as Map)['headers'], reason: 'headers');
      expect(model.hasHeaders, isTrue);
      expect(
        _wire(model.requireApproval),
        (full as Map)['require_approval'],
        reason: 'require_approval',
      );
      expect(model.hasRequireApproval, isTrue);
      expect(
        _wire(model.serverDescription),
        (full as Map)['server_description'],
        reason: 'server_description',
      );
      expect(model.hasServerDescription, isTrue);
      expect(
        _wire(model.serverLabel),
        (full as Map)['server_label'],
        reason: 'server_label',
      );
      expect(
        _wire(model.serverUrl),
        (full as Map)['server_url'],
        reason: 'server_url',
      );
      expect(model.hasServerUrl, isTrue);
      expect(
        _wire(model.tunnelId),
        (full as Map)['tunnel_id'],
        reason: 'tunnel_id',
      );
      expect(model.hasTunnelId, isTrue);
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputMCPTool.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('optional allowed_callers omit/null/clear and copy ownership', () {
      final model = LiveInputMCPTool.fromJson(_clone(full));
      final omitted = model.copyWith(clearAllowedCallers: true);
      expect(omitted.rawJson.containsKey('allowed_callers'), isFalse);
      expect(omitted.hasAllowedCallers, isFalse);
      expect(model.copyWith(allowedCallers: model.allowedCallers), model);
      final cleared = model.copyWith(allowedCallers: null);
      expect(cleared.rawJson.containsKey('allowed_callers'), isTrue);
      expect(cleared.toJson()['allowed_callers'], isNull);
      expect(cleared.hasAllowedCallers, isTrue);
    });
    test('known allowed_callers wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['allowed_callers'] = 5;
      expect(
        () => LiveInputMCPTool.fromJson(wire),
        throwsA(_safe('allowed_callers')),
      );
      expect(
        () =>
            LiveInputMCPTool.fromJson(_clone(full)).copyWith(allowedCallers: 5),
        throwsA(_safe('allowed_callers')),
      );
    });
    test('optional allowed_tools omit/null/clear and copy ownership', () {
      final model = LiveInputMCPTool.fromJson(_clone(full));
      final omitted = model.copyWith(clearAllowedTools: true);
      expect(omitted.rawJson.containsKey('allowed_tools'), isFalse);
      expect(omitted.hasAllowedTools, isFalse);
      expect(model.copyWith(allowedTools: model.allowedTools), model);
      final cleared = model.copyWith(allowedTools: null);
      expect(cleared.rawJson.containsKey('allowed_tools'), isTrue);
      expect(cleared.toJson()['allowed_tools'], isNull);
      expect(cleared.hasAllowedTools, isTrue);
    });
    test('known allowed_tools wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['allowed_tools'] = 5;
      expect(
        () => LiveInputMCPTool.fromJson(wire),
        throwsA(_safe('allowed_tools')),
      );
      expect(
        () => LiveInputMCPTool.fromJson(_clone(full)).copyWith(allowedTools: 5),
        throwsA(_safe('allowed_tools')),
      );
    });
    test('optional authorization omit/null/clear and copy ownership', () {
      final model = LiveInputMCPTool.fromJson(_clone(full));
      final omitted = model.copyWith(clearAuthorization: true);
      expect(omitted.rawJson.containsKey('authorization'), isFalse);
      expect(omitted.hasAuthorization, isFalse);
      expect(model.copyWith(authorization: model.authorization), model);
      expect(
        () => model.copyWith(authorization: null),
        throwsA(_safe('authorization')),
      );
    });
    test('known authorization wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['authorization'] = 5;
      expect(
        () => LiveInputMCPTool.fromJson(wire),
        throwsA(_safe('authorization')),
      );
      expect(
        () =>
            LiveInputMCPTool.fromJson(_clone(full)).copyWith(authorization: 5),
        throwsA(_safe('authorization')),
      );
    });
    test('optional connector_id omit/null/clear and copy ownership', () {
      final model = LiveInputMCPTool.fromJson(_clone(full));
      final omitted = model.copyWith(clearConnectorId: true);
      expect(omitted.rawJson.containsKey('connector_id'), isFalse);
      expect(omitted.hasConnectorId, isFalse);
      expect(model.copyWith(connectorId: model.connectorId), model);
      expect(
        () => model.copyWith(connectorId: null),
        throwsA(_safe('connector_id')),
      );
    });
    test('known connector_id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['connector_id'] = 5;
      expect(
        () => LiveInputMCPTool.fromJson(wire),
        throwsA(_safe('connector_id')),
      );
      expect(
        () => LiveInputMCPTool.fromJson(_clone(full)).copyWith(connectorId: 5),
        throwsA(_safe('connector_id')),
      );
    });
    test('optional defer_loading omit/null/clear and copy ownership', () {
      final model = LiveInputMCPTool.fromJson(_clone(full));
      final omitted = model.copyWith(clearDeferLoading: true);
      expect(omitted.rawJson.containsKey('defer_loading'), isFalse);
      expect(omitted.hasDeferLoading, isFalse);
      expect(model.copyWith(deferLoading: model.deferLoading), model);
      expect(
        () => model.copyWith(deferLoading: null),
        throwsA(_safe('defer_loading')),
      );
    });
    test('known defer_loading wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['defer_loading'] = 5;
      expect(
        () => LiveInputMCPTool.fromJson(wire),
        throwsA(_safe('defer_loading')),
      );
      expect(
        () => LiveInputMCPTool.fromJson(_clone(full)).copyWith(deferLoading: 5),
        throwsA(_safe('defer_loading')),
      );
    });
    test('optional headers omit/null/clear and copy ownership', () {
      final model = LiveInputMCPTool.fromJson(_clone(full));
      final omitted = model.copyWith(clearHeaders: true);
      expect(omitted.rawJson.containsKey('headers'), isFalse);
      expect(omitted.hasHeaders, isFalse);
      expect(model.copyWith(headers: model.headers), model);
      final cleared = model.copyWith(headers: null);
      expect(cleared.rawJson.containsKey('headers'), isTrue);
      expect(cleared.toJson()['headers'], isNull);
      expect(cleared.hasHeaders, isTrue);
    });
    test('known headers wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['headers'] = 5;
      expect(() => LiveInputMCPTool.fromJson(wire), throwsA(_safe('headers')));
      expect(
        () => LiveInputMCPTool.fromJson(_clone(full)).copyWith(headers: 5),
        throwsA(_safe('headers')),
      );
    });
    test('optional require_approval omit/null/clear and copy ownership', () {
      final model = LiveInputMCPTool.fromJson(_clone(full));
      final omitted = model.copyWith(clearRequireApproval: true);
      expect(omitted.rawJson.containsKey('require_approval'), isFalse);
      expect(omitted.hasRequireApproval, isFalse);
      expect(model.copyWith(requireApproval: model.requireApproval), model);
      final cleared = model.copyWith(requireApproval: null);
      expect(cleared.rawJson.containsKey('require_approval'), isTrue);
      expect(cleared.toJson()['require_approval'], isNull);
      expect(cleared.hasRequireApproval, isTrue);
    });
    test('known require_approval wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['require_approval'] = 5;
      expect(
        () => LiveInputMCPTool.fromJson(wire),
        throwsA(_safe('require_approval')),
      );
      expect(
        () => LiveInputMCPTool.fromJson(
          _clone(full),
        ).copyWith(requireApproval: 5),
        throwsA(_safe('require_approval')),
      );
    });
    test('optional server_description omit/null/clear and copy ownership', () {
      final model = LiveInputMCPTool.fromJson(_clone(full));
      final omitted = model.copyWith(clearServerDescription: true);
      expect(omitted.rawJson.containsKey('server_description'), isFalse);
      expect(omitted.hasServerDescription, isFalse);
      expect(model.copyWith(serverDescription: model.serverDescription), model);
      expect(
        () => model.copyWith(serverDescription: null),
        throwsA(_safe('server_description')),
      );
    });
    test('known server_description wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['server_description'] = 5;
      expect(
        () => LiveInputMCPTool.fromJson(wire),
        throwsA(_safe('server_description')),
      );
      expect(
        () => LiveInputMCPTool.fromJson(
          _clone(full),
        ).copyWith(serverDescription: 5),
        throwsA(_safe('server_description')),
      );
    });
    test('required server_label absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('server_label');
      expect(
        () => LiveInputMCPTool.fromJson(wire),
        throwsA(_safe('server_label')),
      );
    });
    test('known server_label wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['server_label'] = 5;
      expect(
        () => LiveInputMCPTool.fromJson(wire),
        throwsA(_safe('server_label')),
      );
      expect(
        () => LiveInputMCPTool.fromJson(_clone(full)).copyWith(serverLabel: 5),
        throwsA(_safe('server_label')),
      );
    });
    test('optional server_url omit/null/clear and copy ownership', () {
      final model = LiveInputMCPTool.fromJson(_clone(full));
      final omitted = model.copyWith(clearServerUrl: true);
      expect(omitted.rawJson.containsKey('server_url'), isFalse);
      expect(omitted.hasServerUrl, isFalse);
      expect(model.copyWith(serverUrl: model.serverUrl), model);
      expect(
        () => model.copyWith(serverUrl: null),
        throwsA(_safe('server_url')),
      );
    });
    test('known server_url wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['server_url'] = 5;
      expect(
        () => LiveInputMCPTool.fromJson(wire),
        throwsA(_safe('server_url')),
      );
      expect(
        () => LiveInputMCPTool.fromJson(_clone(full)).copyWith(serverUrl: 5),
        throwsA(_safe('server_url')),
      );
    });
    test('optional tunnel_id omit/null/clear and copy ownership', () {
      final model = LiveInputMCPTool.fromJson(_clone(full));
      final omitted = model.copyWith(clearTunnelId: true);
      expect(omitted.rawJson.containsKey('tunnel_id'), isFalse);
      expect(omitted.hasTunnelId, isFalse);
      expect(model.copyWith(tunnelId: model.tunnelId), model);
      expect(() => model.copyWith(tunnelId: null), throwsA(_safe('tunnel_id')));
    });
    test('known tunnel_id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['tunnel_id'] = 5;
      expect(
        () => LiveInputMCPTool.fromJson(wire),
        throwsA(_safe('tunnel_id')),
      );
      expect(
        () => LiveInputMCPTool.fromJson(_clone(full)).copyWith(tunnelId: 5),
        throwsA(_safe('tunnel_id')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(() => LiveInputMCPTool.fromJson(wire), throwsA(_safe('type')));
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(() => LiveInputMCPTool.fromJson(wire), throwsA(_safe('type')));
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputMCPTool.fromJson(wire),
        throwsA(_safe('LiveInputMCPTool')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputMCPTool.fromJson(wire),
        throwsA(_safe('LiveInputMCPTool')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputMCPTool.fromJson(wire),
        throwsA(_safe('LiveInputMCPTool')),
      );
    });
  });
  group('MCPToolCall', () {
    final minimal = {
      'type': 'mcp_call',
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'server_label': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'arguments': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    final full = {
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
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputMCPToolCall.fromJson(_clone(wire));
        final peer = LiveInputMCPToolCall.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputMCPToolCall.fromJson(_clone(full));
      expect(
        _wire(model.approvalRequestId),
        (full as Map)['approval_request_id'],
        reason: 'approval_request_id',
      );
      expect(model.hasApprovalRequestId, isTrue);
      expect(
        _wire(model.arguments),
        (full as Map)['arguments'],
        reason: 'arguments',
      );
      expect(_wire(model.error), (full as Map)['error'], reason: 'error');
      expect(model.hasError, isTrue);
      expect(_wire(model.id), (full as Map)['id'], reason: 'id');
      expect(_wire(model.name), (full as Map)['name'], reason: 'name');
      expect(_wire(model.output), (full as Map)['output'], reason: 'output');
      expect(model.hasOutput, isTrue);
      expect(
        _wire(model.serverLabel),
        (full as Map)['server_label'],
        reason: 'server_label',
      );
      expect(_wire(model.status), (full as Map)['status'], reason: 'status');
      expect(model.hasStatus, isTrue);
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputMCPToolCall.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('optional approval_request_id omit/null/clear and copy ownership', () {
      final model = LiveInputMCPToolCall.fromJson(_clone(full));
      final omitted = model.copyWith(clearApprovalRequestId: true);
      expect(omitted.rawJson.containsKey('approval_request_id'), isFalse);
      expect(omitted.hasApprovalRequestId, isFalse);
      expect(model.copyWith(approvalRequestId: model.approvalRequestId), model);
      final cleared = model.copyWith(approvalRequestId: null);
      expect(cleared.rawJson.containsKey('approval_request_id'), isTrue);
      expect(cleared.toJson()['approval_request_id'], isNull);
      expect(cleared.hasApprovalRequestId, isTrue);
    });
    test('known approval_request_id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['approval_request_id'] = 5;
      expect(
        () => LiveInputMCPToolCall.fromJson(wire),
        throwsA(_safe('approval_request_id')),
      );
      expect(
        () => LiveInputMCPToolCall.fromJson(
          _clone(full),
        ).copyWith(approvalRequestId: 5),
        throwsA(_safe('approval_request_id')),
      );
    });
    test('required arguments absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('arguments');
      expect(
        () => LiveInputMCPToolCall.fromJson(wire),
        throwsA(_safe('arguments')),
      );
    });
    test('known arguments wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['arguments'] = 5;
      expect(
        () => LiveInputMCPToolCall.fromJson(wire),
        throwsA(_safe('arguments')),
      );
      expect(
        () =>
            LiveInputMCPToolCall.fromJson(_clone(full)).copyWith(arguments: 5),
        throwsA(_safe('arguments')),
      );
    });
    test('optional error omit/null/clear and copy ownership', () {
      final model = LiveInputMCPToolCall.fromJson(_clone(full));
      final omitted = model.copyWith(clearError: true);
      expect(omitted.rawJson.containsKey('error'), isFalse);
      expect(omitted.hasError, isFalse);
      expect(model.copyWith(error: model.error), model);
      final cleared = model.copyWith(error: null);
      expect(cleared.rawJson.containsKey('error'), isTrue);
      expect(cleared.toJson()['error'], isNull);
      expect(cleared.hasError, isTrue);
    });
    test('known error wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['error'] = 5;
      expect(
        () => LiveInputMCPToolCall.fromJson(wire),
        throwsA(_safe('error')),
      );
      expect(
        () => LiveInputMCPToolCall.fromJson(_clone(full)).copyWith(error: 5),
        throwsA(_safe('error')),
      );
    });
    test('required id absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('id');
      expect(() => LiveInputMCPToolCall.fromJson(wire), throwsA(_safe('id')));
    });
    test('known id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['id'] = 5;
      expect(() => LiveInputMCPToolCall.fromJson(wire), throwsA(_safe('id')));
      expect(
        () => LiveInputMCPToolCall.fromJson(_clone(full)).copyWith(id: 5),
        throwsA(_safe('id')),
      );
    });
    test('required name absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('name');
      expect(() => LiveInputMCPToolCall.fromJson(wire), throwsA(_safe('name')));
    });
    test('known name wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['name'] = 5;
      expect(() => LiveInputMCPToolCall.fromJson(wire), throwsA(_safe('name')));
      expect(
        () => LiveInputMCPToolCall.fromJson(_clone(full)).copyWith(name: 5),
        throwsA(_safe('name')),
      );
    });
    test('optional output omit/null/clear and copy ownership', () {
      final model = LiveInputMCPToolCall.fromJson(_clone(full));
      final omitted = model.copyWith(clearOutput: true);
      expect(omitted.rawJson.containsKey('output'), isFalse);
      expect(omitted.hasOutput, isFalse);
      expect(model.copyWith(output: model.output), model);
      final cleared = model.copyWith(output: null);
      expect(cleared.rawJson.containsKey('output'), isTrue);
      expect(cleared.toJson()['output'], isNull);
      expect(cleared.hasOutput, isTrue);
    });
    test('known output wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['output'] = 5;
      expect(
        () => LiveInputMCPToolCall.fromJson(wire),
        throwsA(_safe('output')),
      );
      expect(
        () => LiveInputMCPToolCall.fromJson(_clone(full)).copyWith(output: 5),
        throwsA(_safe('output')),
      );
    });
    test('required server_label absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('server_label');
      expect(
        () => LiveInputMCPToolCall.fromJson(wire),
        throwsA(_safe('server_label')),
      );
    });
    test('known server_label wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['server_label'] = 5;
      expect(
        () => LiveInputMCPToolCall.fromJson(wire),
        throwsA(_safe('server_label')),
      );
      expect(
        () => LiveInputMCPToolCall.fromJson(
          _clone(full),
        ).copyWith(serverLabel: 5),
        throwsA(_safe('server_label')),
      );
    });
    test('optional status omit/null/clear and copy ownership', () {
      final model = LiveInputMCPToolCall.fromJson(_clone(full));
      final omitted = model.copyWith(clearStatus: true);
      expect(omitted.rawJson.containsKey('status'), isFalse);
      expect(omitted.hasStatus, isFalse);
      expect(model.copyWith(status: model.status), model);
      expect(() => model.copyWith(status: null), throwsA(_safe('status')));
    });
    test('known status wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['status'] = 5;
      expect(
        () => LiveInputMCPToolCall.fromJson(wire),
        throwsA(_safe('status')),
      );
      expect(
        () => LiveInputMCPToolCall.fromJson(_clone(full)).copyWith(status: 5),
        throwsA(_safe('status')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(() => LiveInputMCPToolCall.fromJson(wire), throwsA(_safe('type')));
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(() => LiveInputMCPToolCall.fromJson(wire), throwsA(_safe('type')));
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputMCPToolCall.fromJson(wire),
        throwsA(_safe('LiveInputMCPToolCall')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputMCPToolCall.fromJson(wire),
        throwsA(_safe('LiveInputMCPToolCall')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputMCPToolCall.fromJson(wire),
        throwsA(_safe('LiveInputMCPToolCall')),
      );
    });
  });
  group('MCPToolCallError', () {
    final minimal = {
      'type': 'mcp_protocol_error',
      'code': 0,
      'message': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    final full = {
      'code': 0,
      'message': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'mcp_protocol_error',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputMCPToolCallError.fromJson(_clone(wire));
        final peer = LiveInputMCPToolCallError.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
  });
  group('MCPToolCallStatus', () {
    const minimal = 'in_progress';
    const full = 'in_progress';
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputMCPToolCallStatus.fromJson(_clone(wire));
        final peer = LiveInputMCPToolCallStatus.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('value copy and JSON ownership', () {
      final model = LiveInputMCPToolCallStatus.fromJson(_clone(full));
      expect(_wire(model.value), full);
      expect(model.copyWith(value: _clone(full)), model);
    });
  });
  group('MCPToolExecutionError', () {
    final minimal = {'type': 'mcp_tool_execution_error', 'content': null};
    final full = {'content': null, 'type': 'mcp_tool_execution_error'};
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputMCPToolExecutionError.fromJson(_clone(wire));
        final peer = LiveInputMCPToolExecutionError.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputMCPToolExecutionError.fromJson(_clone(full));
      expect(_wire(model.content), (full as Map)['content'], reason: 'content');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputMCPToolExecutionError.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required content absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('content');
      expect(
        () => LiveInputMCPToolExecutionError.fromJson(wire),
        throwsA(_safe('content')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputMCPToolExecutionError.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputMCPToolExecutionError.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputMCPToolExecutionError.fromJson(wire),
        throwsA(_safe('LiveInputMCPToolExecutionError')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputMCPToolExecutionError.fromJson(wire),
        throwsA(_safe('LiveInputMCPToolExecutionError')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputMCPToolExecutionError.fromJson(wire),
        throwsA(_safe('LiveInputMCPToolExecutionError')),
      );
    });
  });
  group('MCPToolFilter', () {
    final minimal = <String, dynamic>{};
    final full = {
      'read_only': false,
      'tool_names': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputMCPToolFilter.fromJson(_clone(wire));
        final peer = LiveInputMCPToolFilter.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputMCPToolFilter.fromJson(_clone(full));
      expect(
        _wire(model.readOnly),
        (full as Map)['read_only'],
        reason: 'read_only',
      );
      expect(model.hasReadOnly, isTrue);
      expect(
        _wire(model.toolNames),
        (full as Map)['tool_names'],
        reason: 'tool_names',
      );
      expect(model.hasToolNames, isTrue);
    });
    test('closed canonical metadata and immutable snapshot', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      final model = LiveInputMCPToolFilter.fromJson(source);
      source.clear();
      expect(model.toJson(), full);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () =>
            LiveInputMCPToolFilter.fromJson({...(full as Map), _private: true}),
        throwsA(_safe('LiveInputMCPToolFilter')),
      );
    });
    test('optional read_only omit/null/clear and copy ownership', () {
      final model = LiveInputMCPToolFilter.fromJson(_clone(full));
      final omitted = model.copyWith(clearReadOnly: true);
      expect(omitted.rawJson.containsKey('read_only'), isFalse);
      expect(omitted.hasReadOnly, isFalse);
      expect(model.copyWith(readOnly: model.readOnly), model);
      expect(() => model.copyWith(readOnly: null), throwsA(_safe('read_only')));
    });
    test('known read_only wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['read_only'] = 5;
      expect(
        () => LiveInputMCPToolFilter.fromJson(wire),
        throwsA(_safe('read_only')),
      );
      expect(
        () =>
            LiveInputMCPToolFilter.fromJson(_clone(full)).copyWith(readOnly: 5),
        throwsA(_safe('read_only')),
      );
    });
    test('optional tool_names omit/null/clear and copy ownership', () {
      final model = LiveInputMCPToolFilter.fromJson(_clone(full));
      final omitted = model.copyWith(clearToolNames: true);
      expect(omitted.rawJson.containsKey('tool_names'), isFalse);
      expect(omitted.hasToolNames, isFalse);
      expect(model.copyWith(toolNames: model.toolNames), model);
      expect(
        () => model.copyWith(toolNames: null),
        throwsA(_safe('tool_names')),
      );
    });
    test('known tool_names wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['tool_names'] = 5;
      expect(
        () => LiveInputMCPToolFilter.fromJson(wire),
        throwsA(_safe('tool_names')),
      );
      expect(
        () => LiveInputMCPToolFilter.fromJson(
          _clone(full),
        ).copyWith(toolNames: 5),
        throwsA(_safe('tool_names')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputMCPToolFilter.fromJson(wire),
        throwsA(_safe('LiveInputMCPToolFilter')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputMCPToolFilter.fromJson(wire),
        throwsA(_safe('LiveInputMCPToolFilter')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputMCPToolFilter.fromJson(wire),
        throwsA(_safe('LiveInputMCPToolFilter')),
      );
    });
  });
  group('MessagePhase', () {
    const minimal = 'commentary';
    const full = 'commentary';
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputMessagePhase.fromJson(_clone(wire));
        final peer = LiveInputMessagePhase.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('value copy and JSON ownership', () {
      final model = LiveInputMessagePhase.fromJson(_clone(full));
      expect(_wire(model.value), full);
      expect(model.copyWith(value: _clone(full)), model);
    });
  });
  group('MoveParam', () {
    final minimal = {'type': 'move', 'x': 0, 'y': 0};
    final full = {
      'keys': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
      'type': 'move',
      'x': 0,
      'y': 0,
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputMoveParam.fromJson(_clone(wire));
        final peer = LiveInputMoveParam.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputMoveParam.fromJson(_clone(full));
      expect(_wire(model.keys), (full as Map)['keys'], reason: 'keys');
      expect(model.hasKeys, isTrue);
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
      expect(_wire(model.x), (full as Map)['x'], reason: 'x');
      expect(_wire(model.y), (full as Map)['y'], reason: 'y');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputMoveParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('optional keys omit/null/clear and copy ownership', () {
      final model = LiveInputMoveParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearKeys: true);
      expect(omitted.rawJson.containsKey('keys'), isFalse);
      expect(omitted.hasKeys, isFalse);
      expect(model.copyWith(keys: model.keys), model);
      final cleared = model.copyWith(keys: null);
      expect(cleared.rawJson.containsKey('keys'), isTrue);
      expect(cleared.toJson()['keys'], isNull);
      expect(cleared.hasKeys, isTrue);
    });
    test('known keys wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['keys'] = 5;
      expect(() => LiveInputMoveParam.fromJson(wire), throwsA(_safe('keys')));
      expect(
        () => LiveInputMoveParam.fromJson(_clone(full)).copyWith(keys: 5),
        throwsA(_safe('keys')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(() => LiveInputMoveParam.fromJson(wire), throwsA(_safe('type')));
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(() => LiveInputMoveParam.fromJson(wire), throwsA(_safe('type')));
    });
    test('required x absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)..remove('x');
      expect(() => LiveInputMoveParam.fromJson(wire), throwsA(_safe('x')));
    });
    test('known x wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['x'] = false;
      expect(() => LiveInputMoveParam.fromJson(wire), throwsA(_safe('x')));
      expect(
        () => LiveInputMoveParam.fromJson(_clone(full)).copyWith(x: false),
        throwsA(_safe('x')),
      );
    });
    test('required y absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)..remove('y');
      expect(() => LiveInputMoveParam.fromJson(wire), throwsA(_safe('y')));
    });
    test('known y wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['y'] = false;
      expect(() => LiveInputMoveParam.fromJson(wire), throwsA(_safe('y')));
      expect(
        () => LiveInputMoveParam.fromJson(_clone(full)).copyWith(y: false),
        throwsA(_safe('y')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputMoveParam.fromJson(wire),
        throwsA(_safe('LiveInputMoveParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputMoveParam.fromJson(wire),
        throwsA(_safe('LiveInputMoveParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputMoveParam.fromJson(wire),
        throwsA(_safe('LiveInputMoveParam')),
      );
    });
  });
  group('NamespaceToolParam', () {
    final minimal = {
      'type': 'namespace',
      'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'description': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'tools': [
        {'name': 'PRIVATE_LIVE_INPUT_PAYLOAD', 'type': 'function'},
      ],
    };
    final full = {
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
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputNamespaceToolParam.fromJson(_clone(wire));
        final peer = LiveInputNamespaceToolParam.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputNamespaceToolParam.fromJson(_clone(full));
      expect(
        _wire(model.description),
        (full as Map)['description'],
        reason: 'description',
      );
      expect(_wire(model.name), (full as Map)['name'], reason: 'name');
      expect(_wire(model.tools), (full as Map)['tools'], reason: 'tools');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputNamespaceToolParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required description absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('description');
      expect(
        () => LiveInputNamespaceToolParam.fromJson(wire),
        throwsA(_safe('description')),
      );
    });
    test('known description wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['description'] = 5;
      expect(
        () => LiveInputNamespaceToolParam.fromJson(wire),
        throwsA(_safe('description')),
      );
      expect(
        () => LiveInputNamespaceToolParam.fromJson(
          _clone(full),
        ).copyWith(description: 5),
        throwsA(_safe('description')),
      );
    });
    test('required name absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('name');
      expect(
        () => LiveInputNamespaceToolParam.fromJson(wire),
        throwsA(_safe('name')),
      );
    });
    test('known name wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['name'] = 5;
      expect(
        () => LiveInputNamespaceToolParam.fromJson(wire),
        throwsA(_safe('name')),
      );
      expect(
        () => LiveInputNamespaceToolParam.fromJson(
          _clone(full),
        ).copyWith(name: 5),
        throwsA(_safe('name')),
      );
    });
    test('required tools absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('tools');
      expect(
        () => LiveInputNamespaceToolParam.fromJson(wire),
        throwsA(_safe('tools')),
      );
    });
    test('known tools wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['tools'] = 5;
      expect(
        () => LiveInputNamespaceToolParam.fromJson(wire),
        throwsA(_safe('tools')),
      );
      expect(
        () => LiveInputNamespaceToolParam.fromJson(
          _clone(full),
        ).copyWith(tools: 5),
        throwsA(_safe('tools')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputNamespaceToolParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputNamespaceToolParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputNamespaceToolParam.fromJson(wire),
        throwsA(_safe('LiveInputNamespaceToolParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputNamespaceToolParam.fromJson(wire),
        throwsA(_safe('LiveInputNamespaceToolParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputNamespaceToolParam.fromJson(wire),
        throwsA(_safe('LiveInputNamespaceToolParam')),
      );
    });
  });
  group('OutputMessage', () {
    final minimal = {
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'message',
      'role': 'assistant',
      'content': <dynamic>[],
      'status': 'in_progress',
    };
    final full = {
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
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputOutputMessage.fromJson(_clone(wire));
        final peer = LiveInputOutputMessage.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputOutputMessage.fromJson(_clone(full));
      expect(_wire(model.content), (full as Map)['content'], reason: 'content');
      expect(_wire(model.id), (full as Map)['id'], reason: 'id');
      expect(_wire(model.phase), (full as Map)['phase'], reason: 'phase');
      expect(model.hasPhase, isTrue);
      expect(_wire(model.role), (full as Map)['role'], reason: 'role');
      expect(_wire(model.status), (full as Map)['status'], reason: 'status');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputOutputMessage.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required content absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('content');
      expect(
        () => LiveInputOutputMessage.fromJson(wire),
        throwsA(_safe('content')),
      );
    });
    test('known content wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['content'] = 5;
      expect(
        () => LiveInputOutputMessage.fromJson(wire),
        throwsA(_safe('content')),
      );
      expect(
        () =>
            LiveInputOutputMessage.fromJson(_clone(full)).copyWith(content: 5),
        throwsA(_safe('content')),
      );
    });
    test('required id absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('id');
      expect(() => LiveInputOutputMessage.fromJson(wire), throwsA(_safe('id')));
    });
    test('known id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['id'] = 5;
      expect(() => LiveInputOutputMessage.fromJson(wire), throwsA(_safe('id')));
      expect(
        () => LiveInputOutputMessage.fromJson(_clone(full)).copyWith(id: 5),
        throwsA(_safe('id')),
      );
    });
    test('optional phase omit/null/clear and copy ownership', () {
      final model = LiveInputOutputMessage.fromJson(_clone(full));
      final omitted = model.copyWith(clearPhase: true);
      expect(omitted.rawJson.containsKey('phase'), isFalse);
      expect(omitted.hasPhase, isFalse);
      expect(model.copyWith(phase: model.phase), model);
      final cleared = model.copyWith(phase: null);
      expect(cleared.rawJson.containsKey('phase'), isTrue);
      expect(cleared.toJson()['phase'], isNull);
      expect(cleared.hasPhase, isTrue);
    });
    test('known phase wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['phase'] = 5;
      expect(
        () => LiveInputOutputMessage.fromJson(wire),
        throwsA(_safe('phase')),
      );
      expect(
        () => LiveInputOutputMessage.fromJson(_clone(full)).copyWith(phase: 5),
        throwsA(_safe('phase')),
      );
    });
    test('required role absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('role');
      expect(
        () => LiveInputOutputMessage.fromJson(wire),
        throwsA(_safe('role')),
      );
    });
    test('known role wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['role'] = 5;
      expect(
        () => LiveInputOutputMessage.fromJson(wire),
        throwsA(_safe('role')),
      );
    });
    test('required status absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('status');
      expect(
        () => LiveInputOutputMessage.fromJson(wire),
        throwsA(_safe('status')),
      );
    });
    test('known status wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['status'] = 5;
      expect(
        () => LiveInputOutputMessage.fromJson(wire),
        throwsA(_safe('status')),
      );
      expect(
        () => LiveInputOutputMessage.fromJson(_clone(full)).copyWith(status: 5),
        throwsA(_safe('status')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputOutputMessage.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputOutputMessage.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputOutputMessage.fromJson(wire),
        throwsA(_safe('LiveInputOutputMessage')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputOutputMessage.fromJson(wire),
        throwsA(_safe('LiveInputOutputMessage')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputOutputMessage.fromJson(wire),
        throwsA(_safe('LiveInputOutputMessage')),
      );
    });
  });
  group('OutputMessageContent', () {
    final minimal = {
      'type': 'output_text',
      'text': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'annotations': <dynamic>[],
      'logprobs': <dynamic>[],
    };
    final full = {
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
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputOutputMessageContent.fromJson(_clone(wire));
        final peer = LiveInputOutputMessageContent.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
  });
  group('OutputTextContent', () {
    final minimal = {
      'type': 'output_text',
      'text': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'annotations': <dynamic>[],
      'logprobs': <dynamic>[],
    };
    final full = {
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
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputOutputTextContent.fromJson(_clone(wire));
        final peer = LiveInputOutputTextContent.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputOutputTextContent.fromJson(_clone(full));
      expect(
        _wire(model.annotations),
        (full as Map)['annotations'],
        reason: 'annotations',
      );
      expect(
        _wire(model.logprobs),
        (full as Map)['logprobs'],
        reason: 'logprobs',
      );
      expect(_wire(model.text), (full as Map)['text'], reason: 'text');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputOutputTextContent.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required annotations absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('annotations');
      expect(
        () => LiveInputOutputTextContent.fromJson(wire),
        throwsA(_safe('annotations')),
      );
    });
    test('known annotations wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['annotations'] = 5;
      expect(
        () => LiveInputOutputTextContent.fromJson(wire),
        throwsA(_safe('annotations')),
      );
      expect(
        () => LiveInputOutputTextContent.fromJson(
          _clone(full),
        ).copyWith(annotations: 5),
        throwsA(_safe('annotations')),
      );
    });
    test('required logprobs absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('logprobs');
      expect(
        () => LiveInputOutputTextContent.fromJson(wire),
        throwsA(_safe('logprobs')),
      );
    });
    test('known logprobs wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['logprobs'] = 5;
      expect(
        () => LiveInputOutputTextContent.fromJson(wire),
        throwsA(_safe('logprobs')),
      );
      expect(
        () => LiveInputOutputTextContent.fromJson(
          _clone(full),
        ).copyWith(logprobs: 5),
        throwsA(_safe('logprobs')),
      );
    });
    test('required text absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('text');
      expect(
        () => LiveInputOutputTextContent.fromJson(wire),
        throwsA(_safe('text')),
      );
    });
    test('known text wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['text'] = 5;
      expect(
        () => LiveInputOutputTextContent.fromJson(wire),
        throwsA(_safe('text')),
      );
      expect(
        () =>
            LiveInputOutputTextContent.fromJson(_clone(full)).copyWith(text: 5),
        throwsA(_safe('text')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputOutputTextContent.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputOutputTextContent.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputOutputTextContent.fromJson(wire),
        throwsA(_safe('LiveInputOutputTextContent')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputOutputTextContent.fromJson(wire),
        throwsA(_safe('LiveInputOutputTextContent')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputOutputTextContent.fromJson(wire),
        throwsA(_safe('LiveInputOutputTextContent')),
      );
    });
  });
  group('ProgramItemParam', () {
    final minimal = {
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'program',
      'call_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'code': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'fingerprint': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    final full = {
      'call_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'code': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'fingerprint': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'program',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputProgramItemParam.fromJson(_clone(wire));
        final peer = LiveInputProgramItemParam.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputProgramItemParam.fromJson(_clone(full));
      expect(_wire(model.callId), (full as Map)['call_id'], reason: 'call_id');
      expect(_wire(model.code), (full as Map)['code'], reason: 'code');
      expect(
        _wire(model.fingerprint),
        (full as Map)['fingerprint'],
        reason: 'fingerprint',
      );
      expect(_wire(model.id), (full as Map)['id'], reason: 'id');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputProgramItemParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required call_id absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('call_id');
      expect(
        () => LiveInputProgramItemParam.fromJson(wire),
        throwsA(_safe('call_id')),
      );
    });
    test('known call_id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['call_id'] = 5;
      expect(
        () => LiveInputProgramItemParam.fromJson(wire),
        throwsA(_safe('call_id')),
      );
      expect(
        () => LiveInputProgramItemParam.fromJson(
          _clone(full),
        ).copyWith(callId: 5),
        throwsA(_safe('call_id')),
      );
    });
    test('required code absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('code');
      expect(
        () => LiveInputProgramItemParam.fromJson(wire),
        throwsA(_safe('code')),
      );
    });
    test('known code wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['code'] = 5;
      expect(
        () => LiveInputProgramItemParam.fromJson(wire),
        throwsA(_safe('code')),
      );
      expect(
        () =>
            LiveInputProgramItemParam.fromJson(_clone(full)).copyWith(code: 5),
        throwsA(_safe('code')),
      );
    });
    test('required fingerprint absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('fingerprint');
      expect(
        () => LiveInputProgramItemParam.fromJson(wire),
        throwsA(_safe('fingerprint')),
      );
    });
    test('known fingerprint wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['fingerprint'] = 5;
      expect(
        () => LiveInputProgramItemParam.fromJson(wire),
        throwsA(_safe('fingerprint')),
      );
      expect(
        () => LiveInputProgramItemParam.fromJson(
          _clone(full),
        ).copyWith(fingerprint: 5),
        throwsA(_safe('fingerprint')),
      );
    });
    test('required id absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('id');
      expect(
        () => LiveInputProgramItemParam.fromJson(wire),
        throwsA(_safe('id')),
      );
    });
    test('known id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['id'] = 5;
      expect(
        () => LiveInputProgramItemParam.fromJson(wire),
        throwsA(_safe('id')),
      );
      expect(
        () => LiveInputProgramItemParam.fromJson(_clone(full)).copyWith(id: 5),
        throwsA(_safe('id')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputProgramItemParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputProgramItemParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputProgramItemParam.fromJson(wire),
        throwsA(_safe('LiveInputProgramItemParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputProgramItemParam.fromJson(wire),
        throwsA(_safe('LiveInputProgramItemParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputProgramItemParam.fromJson(wire),
        throwsA(_safe('LiveInputProgramItemParam')),
      );
    });
  });
  group('ProgramOutputItemParam', () {
    final minimal = {
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'program_output',
      'call_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'result': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'status': 'completed',
    };
    final full = {
      'call_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'result': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'status': 'completed',
      'type': 'program_output',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputProgramOutputItemParam.fromJson(_clone(wire));
        final peer = LiveInputProgramOutputItemParam.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputProgramOutputItemParam.fromJson(_clone(full));
      expect(_wire(model.callId), (full as Map)['call_id'], reason: 'call_id');
      expect(_wire(model.id), (full as Map)['id'], reason: 'id');
      expect(_wire(model.result), (full as Map)['result'], reason: 'result');
      expect(_wire(model.status), (full as Map)['status'], reason: 'status');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputProgramOutputItemParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required call_id absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('call_id');
      expect(
        () => LiveInputProgramOutputItemParam.fromJson(wire),
        throwsA(_safe('call_id')),
      );
    });
    test('known call_id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['call_id'] = 5;
      expect(
        () => LiveInputProgramOutputItemParam.fromJson(wire),
        throwsA(_safe('call_id')),
      );
      expect(
        () => LiveInputProgramOutputItemParam.fromJson(
          _clone(full),
        ).copyWith(callId: 5),
        throwsA(_safe('call_id')),
      );
    });
    test('required id absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('id');
      expect(
        () => LiveInputProgramOutputItemParam.fromJson(wire),
        throwsA(_safe('id')),
      );
    });
    test('known id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['id'] = 5;
      expect(
        () => LiveInputProgramOutputItemParam.fromJson(wire),
        throwsA(_safe('id')),
      );
      expect(
        () => LiveInputProgramOutputItemParam.fromJson(
          _clone(full),
        ).copyWith(id: 5),
        throwsA(_safe('id')),
      );
    });
    test('required result absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('result');
      expect(
        () => LiveInputProgramOutputItemParam.fromJson(wire),
        throwsA(_safe('result')),
      );
    });
    test('known result wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['result'] = 5;
      expect(
        () => LiveInputProgramOutputItemParam.fromJson(wire),
        throwsA(_safe('result')),
      );
      expect(
        () => LiveInputProgramOutputItemParam.fromJson(
          _clone(full),
        ).copyWith(result: 5),
        throwsA(_safe('result')),
      );
    });
    test('required status absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('status');
      expect(
        () => LiveInputProgramOutputItemParam.fromJson(wire),
        throwsA(_safe('status')),
      );
    });
    test('known status wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['status'] = 5;
      expect(
        () => LiveInputProgramOutputItemParam.fromJson(wire),
        throwsA(_safe('status')),
      );
      expect(
        () => LiveInputProgramOutputItemParam.fromJson(
          _clone(full),
        ).copyWith(status: 5),
        throwsA(_safe('status')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputProgramOutputItemParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputProgramOutputItemParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputProgramOutputItemParam.fromJson(wire),
        throwsA(_safe('LiveInputProgramOutputItemParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputProgramOutputItemParam.fromJson(wire),
        throwsA(_safe('LiveInputProgramOutputItemParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputProgramOutputItemParam.fromJson(wire),
        throwsA(_safe('LiveInputProgramOutputItemParam')),
      );
    });
  });
  group('ProgramOutputItemStatus', () {
    const minimal = 'completed';
    const full = 'completed';
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputProgramOutputItemStatus.fromJson(_clone(wire));
        final peer = LiveInputProgramOutputItemStatus.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('value copy and JSON ownership', () {
      final model = LiveInputProgramOutputItemStatus.fromJson(_clone(full));
      expect(_wire(model.value), full);
      expect(model.copyWith(value: _clone(full)), model);
    });
  });
  group('ProgramToolCallCaller', () {
    final minimal = {
      'type': 'program',
      'caller_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    final full = {'caller_id': 'PRIVATE_LIVE_INPUT_PAYLOAD', 'type': 'program'};
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputProgramToolCallCaller.fromJson(_clone(wire));
        final peer = LiveInputProgramToolCallCaller.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputProgramToolCallCaller.fromJson(_clone(full));
      expect(
        _wire(model.callerId),
        (full as Map)['caller_id'],
        reason: 'caller_id',
      );
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputProgramToolCallCaller.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required caller_id absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('caller_id');
      expect(
        () => LiveInputProgramToolCallCaller.fromJson(wire),
        throwsA(_safe('caller_id')),
      );
    });
    test('known caller_id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['caller_id'] = 5;
      expect(
        () => LiveInputProgramToolCallCaller.fromJson(wire),
        throwsA(_safe('caller_id')),
      );
      expect(
        () => LiveInputProgramToolCallCaller.fromJson(
          _clone(full),
        ).copyWith(callerId: 5),
        throwsA(_safe('caller_id')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputProgramToolCallCaller.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputProgramToolCallCaller.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputProgramToolCallCaller.fromJson(wire),
        throwsA(_safe('LiveInputProgramToolCallCaller')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputProgramToolCallCaller.fromJson(wire),
        throwsA(_safe('LiveInputProgramToolCallCaller')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputProgramToolCallCaller.fromJson(wire),
        throwsA(_safe('LiveInputProgramToolCallCaller')),
      );
    });
  });
  group('ProgramToolCallCallerParam', () {
    final minimal = {
      'type': 'program',
      'caller_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    final full = {'caller_id': 'PRIVATE_LIVE_INPUT_PAYLOAD', 'type': 'program'};
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputProgramToolCallCallerParam.fromJson(
          _clone(wire),
        );
        final peer = LiveInputProgramToolCallCallerParam.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputProgramToolCallCallerParam.fromJson(_clone(full));
      expect(
        _wire(model.callerId),
        (full as Map)['caller_id'],
        reason: 'caller_id',
      );
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputProgramToolCallCallerParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required caller_id absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('caller_id');
      expect(
        () => LiveInputProgramToolCallCallerParam.fromJson(wire),
        throwsA(_safe('caller_id')),
      );
    });
    test('known caller_id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['caller_id'] = 5;
      expect(
        () => LiveInputProgramToolCallCallerParam.fromJson(wire),
        throwsA(_safe('caller_id')),
      );
      expect(
        () => LiveInputProgramToolCallCallerParam.fromJson(
          _clone(full),
        ).copyWith(callerId: 5),
        throwsA(_safe('caller_id')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputProgramToolCallCallerParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputProgramToolCallCallerParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputProgramToolCallCallerParam.fromJson(wire),
        throwsA(_safe('LiveInputProgramToolCallCallerParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputProgramToolCallCallerParam.fromJson(wire),
        throwsA(_safe('LiveInputProgramToolCallCallerParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputProgramToolCallCallerParam.fromJson(wire),
        throwsA(_safe('LiveInputProgramToolCallCallerParam')),
      );
    });
  });
  group('ProgrammaticToolCallingParam', () {
    final minimal = {'type': 'programmatic_tool_calling'};
    final full = {'type': 'programmatic_tool_calling'};
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputProgrammaticToolCallingParam.fromJson(
          _clone(wire),
        );
        final peer = LiveInputProgrammaticToolCallingParam.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputProgrammaticToolCallingParam.fromJson(
        _clone(full),
      );
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputProgrammaticToolCallingParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputProgrammaticToolCallingParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputProgrammaticToolCallingParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputProgrammaticToolCallingParam.fromJson(wire),
        throwsA(_safe('LiveInputProgrammaticToolCallingParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputProgrammaticToolCallingParam.fromJson(wire),
        throwsA(_safe('LiveInputProgrammaticToolCallingParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputProgrammaticToolCallingParam.fromJson(wire),
        throwsA(_safe('LiveInputProgrammaticToolCallingParam')),
      );
    });
  });
  group('PromptCacheBreakpointConfig', () {
    final minimal = {'mode': 'explicit'};
    final full = {'mode': 'explicit'};
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputPromptCacheBreakpointConfig.fromJson(
          _clone(wire),
        );
        final peer = LiveInputPromptCacheBreakpointConfig.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputPromptCacheBreakpointConfig.fromJson(_clone(full));
      expect(_wire(model.mode), (full as Map)['mode'], reason: 'mode');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputPromptCacheBreakpointConfig.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required mode absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('mode');
      expect(
        () => LiveInputPromptCacheBreakpointConfig.fromJson(wire),
        throwsA(_safe('mode')),
      );
    });
    test('known mode wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['mode'] = 5;
      expect(
        () => LiveInputPromptCacheBreakpointConfig.fromJson(wire),
        throwsA(_safe('mode')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputPromptCacheBreakpointConfig.fromJson(wire),
        throwsA(_safe('LiveInputPromptCacheBreakpointConfig')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputPromptCacheBreakpointConfig.fromJson(wire),
        throwsA(_safe('LiveInputPromptCacheBreakpointConfig')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputPromptCacheBreakpointConfig.fromJson(wire),
        throwsA(_safe('LiveInputPromptCacheBreakpointConfig')),
      );
    });
  });
  group('PromptCacheBreakpointParam', () {
    final minimal = {'mode': 'explicit'};
    final full = {'mode': 'explicit'};
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputPromptCacheBreakpointParam.fromJson(
          _clone(wire),
        );
        final peer = LiveInputPromptCacheBreakpointParam.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputPromptCacheBreakpointParam.fromJson(_clone(full));
      expect(_wire(model.mode), (full as Map)['mode'], reason: 'mode');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputPromptCacheBreakpointParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required mode absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('mode');
      expect(
        () => LiveInputPromptCacheBreakpointParam.fromJson(wire),
        throwsA(_safe('mode')),
      );
    });
    test('known mode wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['mode'] = 5;
      expect(
        () => LiveInputPromptCacheBreakpointParam.fromJson(wire),
        throwsA(_safe('mode')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputPromptCacheBreakpointParam.fromJson(wire),
        throwsA(_safe('LiveInputPromptCacheBreakpointParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputPromptCacheBreakpointParam.fromJson(wire),
        throwsA(_safe('LiveInputPromptCacheBreakpointParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputPromptCacheBreakpointParam.fromJson(wire),
        throwsA(_safe('LiveInputPromptCacheBreakpointParam')),
      );
    });
  });
  group('RankerVersionType', () {
    const minimal = 'auto';
    const full = 'auto';
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputRankerVersionType.fromJson(_clone(wire));
        final peer = LiveInputRankerVersionType.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('value copy and JSON ownership', () {
      final model = LiveInputRankerVersionType.fromJson(_clone(full));
      expect(_wire(model.value), full);
      expect(model.copyWith(value: _clone(full)), model);
    });
  });
  group('RankingOptions', () {
    final minimal = <String, dynamic>{};
    final full = {
      'hybrid_search': {'embedding_weight': 0, 'text_weight': 0},
      'ranker': 'auto',
      'score_threshold': 0,
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputRankingOptions.fromJson(_clone(wire));
        final peer = LiveInputRankingOptions.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputRankingOptions.fromJson(_clone(full));
      expect(
        _wire(model.hybridSearch),
        (full as Map)['hybrid_search'],
        reason: 'hybrid_search',
      );
      expect(model.hasHybridSearch, isTrue);
      expect(_wire(model.ranker), (full as Map)['ranker'], reason: 'ranker');
      expect(model.hasRanker, isTrue);
      expect(
        _wire(model.scoreThreshold),
        (full as Map)['score_threshold'],
        reason: 'score_threshold',
      );
      expect(model.hasScoreThreshold, isTrue);
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputRankingOptions.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('optional hybrid_search omit/null/clear and copy ownership', () {
      final model = LiveInputRankingOptions.fromJson(_clone(full));
      final omitted = model.copyWith(clearHybridSearch: true);
      expect(omitted.rawJson.containsKey('hybrid_search'), isFalse);
      expect(omitted.hasHybridSearch, isFalse);
      expect(model.copyWith(hybridSearch: model.hybridSearch), model);
      expect(
        () => model.copyWith(hybridSearch: null),
        throwsA(_safe('hybrid_search')),
      );
    });
    test('known hybrid_search wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['hybrid_search'] = 5;
      expect(
        () => LiveInputRankingOptions.fromJson(wire),
        throwsA(_safe('hybrid_search')),
      );
      expect(
        () => LiveInputRankingOptions.fromJson(
          _clone(full),
        ).copyWith(hybridSearch: 5),
        throwsA(_safe('hybrid_search')),
      );
    });
    test('optional ranker omit/null/clear and copy ownership', () {
      final model = LiveInputRankingOptions.fromJson(_clone(full));
      final omitted = model.copyWith(clearRanker: true);
      expect(omitted.rawJson.containsKey('ranker'), isFalse);
      expect(omitted.hasRanker, isFalse);
      expect(model.copyWith(ranker: model.ranker), model);
      expect(() => model.copyWith(ranker: null), throwsA(_safe('ranker')));
    });
    test('known ranker wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['ranker'] = 5;
      expect(
        () => LiveInputRankingOptions.fromJson(wire),
        throwsA(_safe('ranker')),
      );
      expect(
        () =>
            LiveInputRankingOptions.fromJson(_clone(full)).copyWith(ranker: 5),
        throwsA(_safe('ranker')),
      );
    });
    test('optional score_threshold omit/null/clear and copy ownership', () {
      final model = LiveInputRankingOptions.fromJson(_clone(full));
      final omitted = model.copyWith(clearScoreThreshold: true);
      expect(omitted.rawJson.containsKey('score_threshold'), isFalse);
      expect(omitted.hasScoreThreshold, isFalse);
      expect(model.copyWith(scoreThreshold: model.scoreThreshold), model);
      expect(
        () => model.copyWith(scoreThreshold: null),
        throwsA(_safe('score_threshold')),
      );
    });
    test('known score_threshold wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['score_threshold'] = false;
      expect(
        () => LiveInputRankingOptions.fromJson(wire),
        throwsA(_safe('score_threshold')),
      );
      expect(
        () => LiveInputRankingOptions.fromJson(
          _clone(full),
        ).copyWith(scoreThreshold: false),
        throwsA(_safe('score_threshold')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputRankingOptions.fromJson(wire),
        throwsA(_safe('LiveInputRankingOptions')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputRankingOptions.fromJson(wire),
        throwsA(_safe('LiveInputRankingOptions')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputRankingOptions.fromJson(wire),
        throwsA(_safe('LiveInputRankingOptions')),
      );
    });
  });
  group('ReasoningEffort', () {
    const minimal = 'none';
    const full = 'none';
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputReasoningEffort.fromJson(_clone(wire));
        final peer = LiveInputReasoningEffort.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
  });
  group('ReasoningItem', () {
    final minimal = {
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'summary': <dynamic>[],
      'type': 'reasoning',
    };
    final full = {
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
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputReasoningItem.fromJson(_clone(wire));
        final peer = LiveInputReasoningItem.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputReasoningItem.fromJson(_clone(full));
      expect(_wire(model.content), (full as Map)['content'], reason: 'content');
      expect(model.hasContent, isTrue);
      expect(
        _wire(model.encryptedContent),
        (full as Map)['encrypted_content'],
        reason: 'encrypted_content',
      );
      expect(model.hasEncryptedContent, isTrue);
      expect(_wire(model.id), (full as Map)['id'], reason: 'id');
      expect(_wire(model.status), (full as Map)['status'], reason: 'status');
      expect(model.hasStatus, isTrue);
      expect(_wire(model.summary), (full as Map)['summary'], reason: 'summary');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputReasoningItem.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('optional content omit/null/clear and copy ownership', () {
      final model = LiveInputReasoningItem.fromJson(_clone(full));
      final omitted = model.copyWith(clearContent: true);
      expect(omitted.rawJson.containsKey('content'), isFalse);
      expect(omitted.hasContent, isFalse);
      expect(model.copyWith(content: model.content), model);
      expect(() => model.copyWith(content: null), throwsA(_safe('content')));
    });
    test('known content wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['content'] = 5;
      expect(
        () => LiveInputReasoningItem.fromJson(wire),
        throwsA(_safe('content')),
      );
      expect(
        () =>
            LiveInputReasoningItem.fromJson(_clone(full)).copyWith(content: 5),
        throwsA(_safe('content')),
      );
    });
    test('optional encrypted_content omit/null/clear and copy ownership', () {
      final model = LiveInputReasoningItem.fromJson(_clone(full));
      final omitted = model.copyWith(clearEncryptedContent: true);
      expect(omitted.rawJson.containsKey('encrypted_content'), isFalse);
      expect(omitted.hasEncryptedContent, isFalse);
      expect(model.copyWith(encryptedContent: model.encryptedContent), model);
      final cleared = model.copyWith(encryptedContent: null);
      expect(cleared.rawJson.containsKey('encrypted_content'), isTrue);
      expect(cleared.toJson()['encrypted_content'], isNull);
      expect(cleared.hasEncryptedContent, isTrue);
    });
    test('known encrypted_content wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['encrypted_content'] = 5;
      expect(
        () => LiveInputReasoningItem.fromJson(wire),
        throwsA(_safe('encrypted_content')),
      );
      expect(
        () => LiveInputReasoningItem.fromJson(
          _clone(full),
        ).copyWith(encryptedContent: 5),
        throwsA(_safe('encrypted_content')),
      );
    });
    test('required id absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('id');
      expect(() => LiveInputReasoningItem.fromJson(wire), throwsA(_safe('id')));
    });
    test('known id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['id'] = 5;
      expect(() => LiveInputReasoningItem.fromJson(wire), throwsA(_safe('id')));
      expect(
        () => LiveInputReasoningItem.fromJson(_clone(full)).copyWith(id: 5),
        throwsA(_safe('id')),
      );
    });
    test('optional status omit/null/clear and copy ownership', () {
      final model = LiveInputReasoningItem.fromJson(_clone(full));
      final omitted = model.copyWith(clearStatus: true);
      expect(omitted.rawJson.containsKey('status'), isFalse);
      expect(omitted.hasStatus, isFalse);
      expect(model.copyWith(status: model.status), model);
      expect(() => model.copyWith(status: null), throwsA(_safe('status')));
    });
    test('known status wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['status'] = 5;
      expect(
        () => LiveInputReasoningItem.fromJson(wire),
        throwsA(_safe('status')),
      );
      expect(
        () => LiveInputReasoningItem.fromJson(_clone(full)).copyWith(status: 5),
        throwsA(_safe('status')),
      );
    });
    test('required summary absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('summary');
      expect(
        () => LiveInputReasoningItem.fromJson(wire),
        throwsA(_safe('summary')),
      );
    });
    test('known summary wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['summary'] = 5;
      expect(
        () => LiveInputReasoningItem.fromJson(wire),
        throwsA(_safe('summary')),
      );
      expect(
        () =>
            LiveInputReasoningItem.fromJson(_clone(full)).copyWith(summary: 5),
        throwsA(_safe('summary')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputReasoningItem.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputReasoningItem.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputReasoningItem.fromJson(wire),
        throwsA(_safe('LiveInputReasoningItem')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputReasoningItem.fromJson(wire),
        throwsA(_safe('LiveInputReasoningItem')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputReasoningItem.fromJson(wire),
        throwsA(_safe('LiveInputReasoningItem')),
      );
    });
  });
  group('ReasoningTextContent', () {
    final minimal = {
      'type': 'reasoning_text',
      'text': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    final full = {
      'text': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'reasoning_text',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputReasoningTextContent.fromJson(_clone(wire));
        final peer = LiveInputReasoningTextContent.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputReasoningTextContent.fromJson(_clone(full));
      expect(_wire(model.text), (full as Map)['text'], reason: 'text');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputReasoningTextContent.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required text absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('text');
      expect(
        () => LiveInputReasoningTextContent.fromJson(wire),
        throwsA(_safe('text')),
      );
    });
    test('known text wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['text'] = 5;
      expect(
        () => LiveInputReasoningTextContent.fromJson(wire),
        throwsA(_safe('text')),
      );
      expect(
        () => LiveInputReasoningTextContent.fromJson(
          _clone(full),
        ).copyWith(text: 5),
        throwsA(_safe('text')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputReasoningTextContent.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputReasoningTextContent.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputReasoningTextContent.fromJson(wire),
        throwsA(_safe('LiveInputReasoningTextContent')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputReasoningTextContent.fromJson(wire),
        throwsA(_safe('LiveInputReasoningTextContent')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputReasoningTextContent.fromJson(wire),
        throwsA(_safe('LiveInputReasoningTextContent')),
      );
    });
  });
  group('RefusalContent', () {
    final minimal = {
      'type': 'refusal',
      'refusal': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    final full = {'refusal': 'PRIVATE_LIVE_INPUT_PAYLOAD', 'type': 'refusal'};
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputRefusalContent.fromJson(_clone(wire));
        final peer = LiveInputRefusalContent.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputRefusalContent.fromJson(_clone(full));
      expect(_wire(model.refusal), (full as Map)['refusal'], reason: 'refusal');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputRefusalContent.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required refusal absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('refusal');
      expect(
        () => LiveInputRefusalContent.fromJson(wire),
        throwsA(_safe('refusal')),
      );
    });
    test('known refusal wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['refusal'] = 5;
      expect(
        () => LiveInputRefusalContent.fromJson(wire),
        throwsA(_safe('refusal')),
      );
      expect(
        () =>
            LiveInputRefusalContent.fromJson(_clone(full)).copyWith(refusal: 5),
        throwsA(_safe('refusal')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputRefusalContent.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputRefusalContent.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputRefusalContent.fromJson(wire),
        throwsA(_safe('LiveInputRefusalContent')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputRefusalContent.fromJson(wire),
        throwsA(_safe('LiveInputRefusalContent')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputRefusalContent.fromJson(wire),
        throwsA(_safe('LiveInputRefusalContent')),
      );
    });
  });
  group('ResponseConfigurationUpdateItemParam', () {
    final minimal = {'type': 'configuration_update'};
    final full = {
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'reasoning': {'effort': 'none'},
      'type': 'configuration_update',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputResponseConfigurationUpdateItemParam.fromJson(
          _clone(wire),
        );
        final peer = LiveInputResponseConfigurationUpdateItemParam.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputResponseConfigurationUpdateItemParam.fromJson(
        _clone(full),
      );
      expect(_wire(model.id), (full as Map)['id'], reason: 'id');
      expect(model.hasId, isTrue);
      expect(
        _wire(model.reasoning),
        (full as Map)['reasoning'],
        reason: 'reasoning',
      );
      expect(model.hasReasoning, isTrue);
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputResponseConfigurationUpdateItemParam.fromJson(
        source,
      );
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('optional id omit/null/clear and copy ownership', () {
      final model = LiveInputResponseConfigurationUpdateItemParam.fromJson(
        _clone(full),
      );
      final omitted = model.copyWith(clearId: true);
      expect(omitted.rawJson.containsKey('id'), isFalse);
      expect(omitted.hasId, isFalse);
      expect(model.copyWith(id: model.id), model);
      final cleared = model.copyWith(id: null);
      expect(cleared.rawJson.containsKey('id'), isTrue);
      expect(cleared.toJson()['id'], isNull);
      expect(cleared.hasId, isTrue);
    });
    test('known id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['id'] = 5;
      expect(
        () => LiveInputResponseConfigurationUpdateItemParam.fromJson(wire),
        throwsA(_safe('id')),
      );
      expect(
        () => LiveInputResponseConfigurationUpdateItemParam.fromJson(
          _clone(full),
        ).copyWith(id: 5),
        throwsA(_safe('id')),
      );
    });
    test('optional reasoning omit/null/clear and copy ownership', () {
      final model = LiveInputResponseConfigurationUpdateItemParam.fromJson(
        _clone(full),
      );
      final omitted = model.copyWith(clearReasoning: true);
      expect(omitted.rawJson.containsKey('reasoning'), isFalse);
      expect(omitted.hasReasoning, isFalse);
      expect(model.copyWith(reasoning: model.reasoning), model);
      expect(
        () => model.copyWith(reasoning: null),
        throwsA(_safe('reasoning')),
      );
    });
    test('known reasoning wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['reasoning'] = 5;
      expect(
        () => LiveInputResponseConfigurationUpdateItemParam.fromJson(wire),
        throwsA(_safe('reasoning')),
      );
      expect(
        () => LiveInputResponseConfigurationUpdateItemParam.fromJson(
          _clone(full),
        ).copyWith(reasoning: 5),
        throwsA(_safe('reasoning')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputResponseConfigurationUpdateItemParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputResponseConfigurationUpdateItemParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputResponseConfigurationUpdateItemParam.fromJson(wire),
        throwsA(_safe('LiveInputResponseConfigurationUpdateItemParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputResponseConfigurationUpdateItemParam.fromJson(wire),
        throwsA(_safe('LiveInputResponseConfigurationUpdateItemParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputResponseConfigurationUpdateItemParam.fromJson(wire),
        throwsA(_safe('LiveInputResponseConfigurationUpdateItemParam')),
      );
    });
  });
  group('ScreenshotParam', () {
    final minimal = {'type': 'screenshot'};
    final full = {'type': 'screenshot'};
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputScreenshotParam.fromJson(_clone(wire));
        final peer = LiveInputScreenshotParam.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputScreenshotParam.fromJson(_clone(full));
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputScreenshotParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputScreenshotParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputScreenshotParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputScreenshotParam.fromJson(wire),
        throwsA(_safe('LiveInputScreenshotParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputScreenshotParam.fromJson(wire),
        throwsA(_safe('LiveInputScreenshotParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputScreenshotParam.fromJson(wire),
        throwsA(_safe('LiveInputScreenshotParam')),
      );
    });
  });
  group('ScrollParam', () {
    final minimal = {
      'type': 'scroll',
      'x': 0,
      'y': 0,
      'scroll_x': 0,
      'scroll_y': 0,
    };
    final full = {
      'keys': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
      'scroll_x': 0,
      'scroll_y': 0,
      'type': 'scroll',
      'x': 0,
      'y': 0,
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputScrollParam.fromJson(_clone(wire));
        final peer = LiveInputScrollParam.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputScrollParam.fromJson(_clone(full));
      expect(_wire(model.keys), (full as Map)['keys'], reason: 'keys');
      expect(model.hasKeys, isTrue);
      expect(
        _wire(model.scrollX),
        (full as Map)['scroll_x'],
        reason: 'scroll_x',
      );
      expect(
        _wire(model.scrollY),
        (full as Map)['scroll_y'],
        reason: 'scroll_y',
      );
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
      expect(_wire(model.x), (full as Map)['x'], reason: 'x');
      expect(_wire(model.y), (full as Map)['y'], reason: 'y');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputScrollParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('optional keys omit/null/clear and copy ownership', () {
      final model = LiveInputScrollParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearKeys: true);
      expect(omitted.rawJson.containsKey('keys'), isFalse);
      expect(omitted.hasKeys, isFalse);
      expect(model.copyWith(keys: model.keys), model);
      final cleared = model.copyWith(keys: null);
      expect(cleared.rawJson.containsKey('keys'), isTrue);
      expect(cleared.toJson()['keys'], isNull);
      expect(cleared.hasKeys, isTrue);
    });
    test('known keys wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['keys'] = 5;
      expect(() => LiveInputScrollParam.fromJson(wire), throwsA(_safe('keys')));
      expect(
        () => LiveInputScrollParam.fromJson(_clone(full)).copyWith(keys: 5),
        throwsA(_safe('keys')),
      );
    });
    test('required scroll_x absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('scroll_x');
      expect(
        () => LiveInputScrollParam.fromJson(wire),
        throwsA(_safe('scroll_x')),
      );
    });
    test('known scroll_x wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['scroll_x'] = false;
      expect(
        () => LiveInputScrollParam.fromJson(wire),
        throwsA(_safe('scroll_x')),
      );
      expect(
        () => LiveInputScrollParam.fromJson(
          _clone(full),
        ).copyWith(scrollX: false),
        throwsA(_safe('scroll_x')),
      );
    });
    test('required scroll_y absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('scroll_y');
      expect(
        () => LiveInputScrollParam.fromJson(wire),
        throwsA(_safe('scroll_y')),
      );
    });
    test('known scroll_y wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['scroll_y'] = false;
      expect(
        () => LiveInputScrollParam.fromJson(wire),
        throwsA(_safe('scroll_y')),
      );
      expect(
        () => LiveInputScrollParam.fromJson(
          _clone(full),
        ).copyWith(scrollY: false),
        throwsA(_safe('scroll_y')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(() => LiveInputScrollParam.fromJson(wire), throwsA(_safe('type')));
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(() => LiveInputScrollParam.fromJson(wire), throwsA(_safe('type')));
    });
    test('required x absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)..remove('x');
      expect(() => LiveInputScrollParam.fromJson(wire), throwsA(_safe('x')));
    });
    test('known x wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['x'] = false;
      expect(() => LiveInputScrollParam.fromJson(wire), throwsA(_safe('x')));
      expect(
        () => LiveInputScrollParam.fromJson(_clone(full)).copyWith(x: false),
        throwsA(_safe('x')),
      );
    });
    test('required y absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)..remove('y');
      expect(() => LiveInputScrollParam.fromJson(wire), throwsA(_safe('y')));
    });
    test('known y wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['y'] = false;
      expect(() => LiveInputScrollParam.fromJson(wire), throwsA(_safe('y')));
      expect(
        () => LiveInputScrollParam.fromJson(_clone(full)).copyWith(y: false),
        throwsA(_safe('y')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputScrollParam.fromJson(wire),
        throwsA(_safe('LiveInputScrollParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputScrollParam.fromJson(wire),
        throwsA(_safe('LiveInputScrollParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputScrollParam.fromJson(wire),
        throwsA(_safe('LiveInputScrollParam')),
      );
    });
  });
  group('SearchContentType', () {
    const minimal = 'text';
    const full = 'text';
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputSearchContentType.fromJson(_clone(wire));
        final peer = LiveInputSearchContentType.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('value copy and JSON ownership', () {
      final model = LiveInputSearchContentType.fromJson(_clone(full));
      expect(_wire(model.value), full);
      expect(model.copyWith(value: _clone(full)), model);
    });
  });
  group('SearchContextSize', () {
    const minimal = 'low';
    const full = 'low';
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputSearchContextSize.fromJson(_clone(wire));
        final peer = LiveInputSearchContextSize.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('value copy and JSON ownership', () {
      final model = LiveInputSearchContextSize.fromJson(_clone(full));
      expect(_wire(model.value), full);
      expect(model.copyWith(value: _clone(full)), model);
    });
  });
  group('SkillReferenceParam', () {
    final minimal = {
      'type': 'skill_reference',
      'skill_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    final full = {
      'skill_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'skill_reference',
      'version': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputSkillReferenceParam.fromJson(_clone(wire));
        final peer = LiveInputSkillReferenceParam.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputSkillReferenceParam.fromJson(_clone(full));
      expect(
        _wire(model.skillId),
        (full as Map)['skill_id'],
        reason: 'skill_id',
      );
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
      expect(_wire(model.version), (full as Map)['version'], reason: 'version');
      expect(model.hasVersion, isTrue);
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputSkillReferenceParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required skill_id absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('skill_id');
      expect(
        () => LiveInputSkillReferenceParam.fromJson(wire),
        throwsA(_safe('skill_id')),
      );
    });
    test('known skill_id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['skill_id'] = 5;
      expect(
        () => LiveInputSkillReferenceParam.fromJson(wire),
        throwsA(_safe('skill_id')),
      );
      expect(
        () => LiveInputSkillReferenceParam.fromJson(
          _clone(full),
        ).copyWith(skillId: 5),
        throwsA(_safe('skill_id')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputSkillReferenceParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputSkillReferenceParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('optional version omit/null/clear and copy ownership', () {
      final model = LiveInputSkillReferenceParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearVersion: true);
      expect(omitted.rawJson.containsKey('version'), isFalse);
      expect(omitted.hasVersion, isFalse);
      expect(model.copyWith(version: model.version), model);
      expect(() => model.copyWith(version: null), throwsA(_safe('version')));
    });
    test('known version wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['version'] = 5;
      expect(
        () => LiveInputSkillReferenceParam.fromJson(wire),
        throwsA(_safe('version')),
      );
      expect(
        () => LiveInputSkillReferenceParam.fromJson(
          _clone(full),
        ).copyWith(version: 5),
        throwsA(_safe('version')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputSkillReferenceParam.fromJson(wire),
        throwsA(_safe('LiveInputSkillReferenceParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputSkillReferenceParam.fromJson(wire),
        throwsA(_safe('LiveInputSkillReferenceParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputSkillReferenceParam.fromJson(wire),
        throwsA(_safe('LiveInputSkillReferenceParam')),
      );
    });
  });
  group('SummaryTextContent', () {
    final minimal = {
      'type': 'summary_text',
      'text': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    final full = {'text': 'PRIVATE_LIVE_INPUT_PAYLOAD', 'type': 'summary_text'};
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputSummaryTextContent.fromJson(_clone(wire));
        final peer = LiveInputSummaryTextContent.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputSummaryTextContent.fromJson(_clone(full));
      expect(_wire(model.text), (full as Map)['text'], reason: 'text');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputSummaryTextContent.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required text absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('text');
      expect(
        () => LiveInputSummaryTextContent.fromJson(wire),
        throwsA(_safe('text')),
      );
    });
    test('known text wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['text'] = 5;
      expect(
        () => LiveInputSummaryTextContent.fromJson(wire),
        throwsA(_safe('text')),
      );
      expect(
        () => LiveInputSummaryTextContent.fromJson(
          _clone(full),
        ).copyWith(text: 5),
        throwsA(_safe('text')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputSummaryTextContent.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputSummaryTextContent.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputSummaryTextContent.fromJson(wire),
        throwsA(_safe('LiveInputSummaryTextContent')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputSummaryTextContent.fromJson(wire),
        throwsA(_safe('LiveInputSummaryTextContent')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputSummaryTextContent.fromJson(wire),
        throwsA(_safe('LiveInputSummaryTextContent')),
      );
    });
  });
  group('Tool', () {
    final minimal = {
      'type': 'function',
      'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'strict': false,
      'parameters': <String, dynamic>{},
    };
    final full = {
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
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputTool.fromJson(_clone(wire));
        final peer = LiveInputTool.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
  });
  group('ToolCallCaller', () {
    final minimal = {'type': 'direct'};
    final full = {'type': 'direct'};
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputToolCallCaller.fromJson(_clone(wire));
        final peer = LiveInputToolCallCaller.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
  });
  group('ToolCallCallerParam', () {
    final minimal = {'type': 'direct'};
    final full = {'type': 'direct'};
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputToolCallCallerParam.fromJson(_clone(wire));
        final peer = LiveInputToolCallCallerParam.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
  });
  group('ToolSearchCallItemParam', () {
    final minimal = {
      'type': 'tool_search_call',
      'arguments': <String, dynamic>{},
    };
    final full = {
      'arguments': <String, dynamic>{},
      'call_id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'execution': 'server',
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'status': 'in_progress',
      'type': 'tool_search_call',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputToolSearchCallItemParam.fromJson(_clone(wire));
        final peer = LiveInputToolSearchCallItemParam.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputToolSearchCallItemParam.fromJson(_clone(full));
      expect(
        _wire(model.arguments),
        (full as Map)['arguments'],
        reason: 'arguments',
      );
      expect(_wire(model.callId), (full as Map)['call_id'], reason: 'call_id');
      expect(model.hasCallId, isTrue);
      expect(
        _wire(model.execution),
        (full as Map)['execution'],
        reason: 'execution',
      );
      expect(model.hasExecution, isTrue);
      expect(_wire(model.id), (full as Map)['id'], reason: 'id');
      expect(model.hasId, isTrue);
      expect(_wire(model.status), (full as Map)['status'], reason: 'status');
      expect(model.hasStatus, isTrue);
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputToolSearchCallItemParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required arguments absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('arguments');
      expect(
        () => LiveInputToolSearchCallItemParam.fromJson(wire),
        throwsA(_safe('arguments')),
      );
    });
    test('known arguments wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['arguments'] = 5;
      expect(
        () => LiveInputToolSearchCallItemParam.fromJson(wire),
        throwsA(_safe('arguments')),
      );
      expect(
        () => LiveInputToolSearchCallItemParam.fromJson(
          _clone(full),
        ).copyWith(arguments: 5),
        throwsA(_safe('arguments')),
      );
    });
    test('optional call_id omit/null/clear and copy ownership', () {
      final model = LiveInputToolSearchCallItemParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearCallId: true);
      expect(omitted.rawJson.containsKey('call_id'), isFalse);
      expect(omitted.hasCallId, isFalse);
      expect(model.copyWith(callId: model.callId), model);
      final cleared = model.copyWith(callId: null);
      expect(cleared.rawJson.containsKey('call_id'), isTrue);
      expect(cleared.toJson()['call_id'], isNull);
      expect(cleared.hasCallId, isTrue);
    });
    test('known call_id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['call_id'] = 5;
      expect(
        () => LiveInputToolSearchCallItemParam.fromJson(wire),
        throwsA(_safe('call_id')),
      );
      expect(
        () => LiveInputToolSearchCallItemParam.fromJson(
          _clone(full),
        ).copyWith(callId: 5),
        throwsA(_safe('call_id')),
      );
    });
    test('optional execution omit/null/clear and copy ownership', () {
      final model = LiveInputToolSearchCallItemParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearExecution: true);
      expect(omitted.rawJson.containsKey('execution'), isFalse);
      expect(omitted.hasExecution, isFalse);
      expect(model.copyWith(execution: model.execution), model);
      expect(
        () => model.copyWith(execution: null),
        throwsA(_safe('execution')),
      );
    });
    test('known execution wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['execution'] = 5;
      expect(
        () => LiveInputToolSearchCallItemParam.fromJson(wire),
        throwsA(_safe('execution')),
      );
      expect(
        () => LiveInputToolSearchCallItemParam.fromJson(
          _clone(full),
        ).copyWith(execution: 5),
        throwsA(_safe('execution')),
      );
    });
    test('optional id omit/null/clear and copy ownership', () {
      final model = LiveInputToolSearchCallItemParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearId: true);
      expect(omitted.rawJson.containsKey('id'), isFalse);
      expect(omitted.hasId, isFalse);
      expect(model.copyWith(id: model.id), model);
      final cleared = model.copyWith(id: null);
      expect(cleared.rawJson.containsKey('id'), isTrue);
      expect(cleared.toJson()['id'], isNull);
      expect(cleared.hasId, isTrue);
    });
    test('known id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['id'] = 5;
      expect(
        () => LiveInputToolSearchCallItemParam.fromJson(wire),
        throwsA(_safe('id')),
      );
      expect(
        () => LiveInputToolSearchCallItemParam.fromJson(
          _clone(full),
        ).copyWith(id: 5),
        throwsA(_safe('id')),
      );
    });
    test('optional status omit/null/clear and copy ownership', () {
      final model = LiveInputToolSearchCallItemParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearStatus: true);
      expect(omitted.rawJson.containsKey('status'), isFalse);
      expect(omitted.hasStatus, isFalse);
      expect(model.copyWith(status: model.status), model);
      final cleared = model.copyWith(status: null);
      expect(cleared.rawJson.containsKey('status'), isTrue);
      expect(cleared.toJson()['status'], isNull);
      expect(cleared.hasStatus, isTrue);
    });
    test('known status wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['status'] = 5;
      expect(
        () => LiveInputToolSearchCallItemParam.fromJson(wire),
        throwsA(_safe('status')),
      );
      expect(
        () => LiveInputToolSearchCallItemParam.fromJson(
          _clone(full),
        ).copyWith(status: 5),
        throwsA(_safe('status')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputToolSearchCallItemParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputToolSearchCallItemParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputToolSearchCallItemParam.fromJson(wire),
        throwsA(_safe('LiveInputToolSearchCallItemParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputToolSearchCallItemParam.fromJson(wire),
        throwsA(_safe('LiveInputToolSearchCallItemParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputToolSearchCallItemParam.fromJson(wire),
        throwsA(_safe('LiveInputToolSearchCallItemParam')),
      );
    });
  });
  group('ToolSearchExecutionType', () {
    const minimal = 'server';
    const full = 'server';
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputToolSearchExecutionType.fromJson(_clone(wire));
        final peer = LiveInputToolSearchExecutionType.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('value copy and JSON ownership', () {
      final model = LiveInputToolSearchExecutionType.fromJson(_clone(full));
      expect(_wire(model.value), full);
      expect(model.copyWith(value: _clone(full)), model);
    });
  });
  group('ToolSearchOutputFunctionToolParam', () {
    final minimal = {'name': 'PRIVATE_LIVE_INPUT_PAYLOAD', 'type': 'function'};
    final full = {
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
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputToolSearchOutputFunctionToolParam.fromJson(
          _clone(wire),
        );
        final peer = LiveInputToolSearchOutputFunctionToolParam.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputToolSearchOutputFunctionToolParam.fromJson(
        _clone(full),
      );
      expect(
        _wire(model.allowedCallers),
        (full as Map)['allowed_callers'],
        reason: 'allowed_callers',
      );
      expect(model.hasAllowedCallers, isTrue);
      expect(_wire(model.async), (full as Map)['async'], reason: 'async');
      expect(model.hasAsync, isTrue);
      expect(
        _wire(model.deferLoading),
        (full as Map)['defer_loading'],
        reason: 'defer_loading',
      );
      expect(model.hasDeferLoading, isTrue);
      expect(
        _wire(model.description),
        (full as Map)['description'],
        reason: 'description',
      );
      expect(model.hasDescription, isTrue);
      expect(_wire(model.name), (full as Map)['name'], reason: 'name');
      expect(
        _wire(model.outputSchema),
        (full as Map)['output_schema'],
        reason: 'output_schema',
      );
      expect(model.hasOutputSchema, isTrue);
      expect(
        _wire(model.parameters),
        (full as Map)['parameters'],
        reason: 'parameters',
      );
      expect(model.hasParameters, isTrue);
      expect(_wire(model.strict), (full as Map)['strict'], reason: 'strict');
      expect(model.hasStrict, isTrue);
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputToolSearchOutputFunctionToolParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('optional allowed_callers omit/null/clear and copy ownership', () {
      final model = LiveInputToolSearchOutputFunctionToolParam.fromJson(
        _clone(full),
      );
      final omitted = model.copyWith(clearAllowedCallers: true);
      expect(omitted.rawJson.containsKey('allowed_callers'), isFalse);
      expect(omitted.hasAllowedCallers, isFalse);
      expect(model.copyWith(allowedCallers: model.allowedCallers), model);
      final cleared = model.copyWith(allowedCallers: null);
      expect(cleared.rawJson.containsKey('allowed_callers'), isTrue);
      expect(cleared.toJson()['allowed_callers'], isNull);
      expect(cleared.hasAllowedCallers, isTrue);
    });
    test('known allowed_callers wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['allowed_callers'] = 5;
      expect(
        () => LiveInputToolSearchOutputFunctionToolParam.fromJson(wire),
        throwsA(_safe('allowed_callers')),
      );
      expect(
        () => LiveInputToolSearchOutputFunctionToolParam.fromJson(
          _clone(full),
        ).copyWith(allowedCallers: 5),
        throwsA(_safe('allowed_callers')),
      );
    });
    test('optional async omit/null/clear and copy ownership', () {
      final model = LiveInputToolSearchOutputFunctionToolParam.fromJson(
        _clone(full),
      );
      final omitted = model.copyWith(clearAsync: true);
      expect(omitted.rawJson.containsKey('async'), isFalse);
      expect(omitted.hasAsync, isFalse);
      expect(model.copyWith(async: model.async), model);
      expect(() => model.copyWith(async: null), throwsA(_safe('async')));
    });
    test('known async wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['async'] = 5;
      expect(
        () => LiveInputToolSearchOutputFunctionToolParam.fromJson(wire),
        throwsA(_safe('async')),
      );
      expect(
        () => LiveInputToolSearchOutputFunctionToolParam.fromJson(
          _clone(full),
        ).copyWith(async: 5),
        throwsA(_safe('async')),
      );
    });
    test('optional defer_loading omit/null/clear and copy ownership', () {
      final model = LiveInputToolSearchOutputFunctionToolParam.fromJson(
        _clone(full),
      );
      final omitted = model.copyWith(clearDeferLoading: true);
      expect(omitted.rawJson.containsKey('defer_loading'), isFalse);
      expect(omitted.hasDeferLoading, isFalse);
      expect(model.copyWith(deferLoading: model.deferLoading), model);
      expect(
        () => model.copyWith(deferLoading: null),
        throwsA(_safe('defer_loading')),
      );
    });
    test('known defer_loading wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['defer_loading'] = 5;
      expect(
        () => LiveInputToolSearchOutputFunctionToolParam.fromJson(wire),
        throwsA(_safe('defer_loading')),
      );
      expect(
        () => LiveInputToolSearchOutputFunctionToolParam.fromJson(
          _clone(full),
        ).copyWith(deferLoading: 5),
        throwsA(_safe('defer_loading')),
      );
    });
    test('optional description omit/null/clear and copy ownership', () {
      final model = LiveInputToolSearchOutputFunctionToolParam.fromJson(
        _clone(full),
      );
      final omitted = model.copyWith(clearDescription: true);
      expect(omitted.rawJson.containsKey('description'), isFalse);
      expect(omitted.hasDescription, isFalse);
      expect(model.copyWith(description: model.description), model);
      final cleared = model.copyWith(description: null);
      expect(cleared.rawJson.containsKey('description'), isTrue);
      expect(cleared.toJson()['description'], isNull);
      expect(cleared.hasDescription, isTrue);
    });
    test('known description wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['description'] = 5;
      expect(
        () => LiveInputToolSearchOutputFunctionToolParam.fromJson(wire),
        throwsA(_safe('description')),
      );
      expect(
        () => LiveInputToolSearchOutputFunctionToolParam.fromJson(
          _clone(full),
        ).copyWith(description: 5),
        throwsA(_safe('description')),
      );
    });
    test('required name absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('name');
      expect(
        () => LiveInputToolSearchOutputFunctionToolParam.fromJson(wire),
        throwsA(_safe('name')),
      );
    });
    test('known name wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['name'] = 5;
      expect(
        () => LiveInputToolSearchOutputFunctionToolParam.fromJson(wire),
        throwsA(_safe('name')),
      );
      expect(
        () => LiveInputToolSearchOutputFunctionToolParam.fromJson(
          _clone(full),
        ).copyWith(name: 5),
        throwsA(_safe('name')),
      );
    });
    test('optional output_schema omit/null/clear and copy ownership', () {
      final model = LiveInputToolSearchOutputFunctionToolParam.fromJson(
        _clone(full),
      );
      final omitted = model.copyWith(clearOutputSchema: true);
      expect(omitted.rawJson.containsKey('output_schema'), isFalse);
      expect(omitted.hasOutputSchema, isFalse);
      expect(model.copyWith(outputSchema: model.outputSchema), model);
      final cleared = model.copyWith(outputSchema: null);
      expect(cleared.rawJson.containsKey('output_schema'), isTrue);
      expect(cleared.toJson()['output_schema'], isNull);
      expect(cleared.hasOutputSchema, isTrue);
    });
    test('known output_schema wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['output_schema'] = 5;
      expect(
        () => LiveInputToolSearchOutputFunctionToolParam.fromJson(wire),
        throwsA(_safe('output_schema')),
      );
      expect(
        () => LiveInputToolSearchOutputFunctionToolParam.fromJson(
          _clone(full),
        ).copyWith(outputSchema: 5),
        throwsA(_safe('output_schema')),
      );
    });
    test('optional parameters omit/null/clear and copy ownership', () {
      final model = LiveInputToolSearchOutputFunctionToolParam.fromJson(
        _clone(full),
      );
      final omitted = model.copyWith(clearParameters: true);
      expect(omitted.rawJson.containsKey('parameters'), isFalse);
      expect(omitted.hasParameters, isFalse);
      expect(model.copyWith(parameters: model.parameters), model);
      final cleared = model.copyWith(parameters: null);
      expect(cleared.rawJson.containsKey('parameters'), isTrue);
      expect(cleared.toJson()['parameters'], isNull);
      expect(cleared.hasParameters, isTrue);
    });
    test('known parameters wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['parameters'] = 5;
      expect(
        () => LiveInputToolSearchOutputFunctionToolParam.fromJson(wire),
        throwsA(_safe('parameters')),
      );
      expect(
        () => LiveInputToolSearchOutputFunctionToolParam.fromJson(
          _clone(full),
        ).copyWith(parameters: 5),
        throwsA(_safe('parameters')),
      );
    });
    test('optional strict omit/null/clear and copy ownership', () {
      final model = LiveInputToolSearchOutputFunctionToolParam.fromJson(
        _clone(full),
      );
      final omitted = model.copyWith(clearStrict: true);
      expect(omitted.rawJson.containsKey('strict'), isFalse);
      expect(omitted.hasStrict, isFalse);
      expect(model.copyWith(strict: model.strict), model);
      final cleared = model.copyWith(strict: null);
      expect(cleared.rawJson.containsKey('strict'), isTrue);
      expect(cleared.toJson()['strict'], isNull);
      expect(cleared.hasStrict, isTrue);
    });
    test('known strict wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['strict'] = 5;
      expect(
        () => LiveInputToolSearchOutputFunctionToolParam.fromJson(wire),
        throwsA(_safe('strict')),
      );
      expect(
        () => LiveInputToolSearchOutputFunctionToolParam.fromJson(
          _clone(full),
        ).copyWith(strict: 5),
        throwsA(_safe('strict')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputToolSearchOutputFunctionToolParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputToolSearchOutputFunctionToolParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputToolSearchOutputFunctionToolParam.fromJson(wire),
        throwsA(_safe('LiveInputToolSearchOutputFunctionToolParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputToolSearchOutputFunctionToolParam.fromJson(wire),
        throwsA(_safe('LiveInputToolSearchOutputFunctionToolParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputToolSearchOutputFunctionToolParam.fromJson(wire),
        throwsA(_safe('LiveInputToolSearchOutputFunctionToolParam')),
      );
    });
  });
  group('ToolSearchOutputItemParam', () {
    final minimal = {'type': 'tool_search_output', 'tools': <dynamic>[]};
    final full = {
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
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputToolSearchOutputItemParam.fromJson(_clone(wire));
        final peer = LiveInputToolSearchOutputItemParam.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputToolSearchOutputItemParam.fromJson(_clone(full));
      expect(_wire(model.callId), (full as Map)['call_id'], reason: 'call_id');
      expect(model.hasCallId, isTrue);
      expect(
        _wire(model.execution),
        (full as Map)['execution'],
        reason: 'execution',
      );
      expect(model.hasExecution, isTrue);
      expect(_wire(model.id), (full as Map)['id'], reason: 'id');
      expect(model.hasId, isTrue);
      expect(_wire(model.status), (full as Map)['status'], reason: 'status');
      expect(model.hasStatus, isTrue);
      expect(_wire(model.tools), (full as Map)['tools'], reason: 'tools');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputToolSearchOutputItemParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('optional call_id omit/null/clear and copy ownership', () {
      final model = LiveInputToolSearchOutputItemParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearCallId: true);
      expect(omitted.rawJson.containsKey('call_id'), isFalse);
      expect(omitted.hasCallId, isFalse);
      expect(model.copyWith(callId: model.callId), model);
      final cleared = model.copyWith(callId: null);
      expect(cleared.rawJson.containsKey('call_id'), isTrue);
      expect(cleared.toJson()['call_id'], isNull);
      expect(cleared.hasCallId, isTrue);
    });
    test('known call_id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['call_id'] = 5;
      expect(
        () => LiveInputToolSearchOutputItemParam.fromJson(wire),
        throwsA(_safe('call_id')),
      );
      expect(
        () => LiveInputToolSearchOutputItemParam.fromJson(
          _clone(full),
        ).copyWith(callId: 5),
        throwsA(_safe('call_id')),
      );
    });
    test('optional execution omit/null/clear and copy ownership', () {
      final model = LiveInputToolSearchOutputItemParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearExecution: true);
      expect(omitted.rawJson.containsKey('execution'), isFalse);
      expect(omitted.hasExecution, isFalse);
      expect(model.copyWith(execution: model.execution), model);
      expect(
        () => model.copyWith(execution: null),
        throwsA(_safe('execution')),
      );
    });
    test('known execution wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['execution'] = 5;
      expect(
        () => LiveInputToolSearchOutputItemParam.fromJson(wire),
        throwsA(_safe('execution')),
      );
      expect(
        () => LiveInputToolSearchOutputItemParam.fromJson(
          _clone(full),
        ).copyWith(execution: 5),
        throwsA(_safe('execution')),
      );
    });
    test('optional id omit/null/clear and copy ownership', () {
      final model = LiveInputToolSearchOutputItemParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearId: true);
      expect(omitted.rawJson.containsKey('id'), isFalse);
      expect(omitted.hasId, isFalse);
      expect(model.copyWith(id: model.id), model);
      final cleared = model.copyWith(id: null);
      expect(cleared.rawJson.containsKey('id'), isTrue);
      expect(cleared.toJson()['id'], isNull);
      expect(cleared.hasId, isTrue);
    });
    test('known id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['id'] = 5;
      expect(
        () => LiveInputToolSearchOutputItemParam.fromJson(wire),
        throwsA(_safe('id')),
      );
      expect(
        () => LiveInputToolSearchOutputItemParam.fromJson(
          _clone(full),
        ).copyWith(id: 5),
        throwsA(_safe('id')),
      );
    });
    test('optional status omit/null/clear and copy ownership', () {
      final model = LiveInputToolSearchOutputItemParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearStatus: true);
      expect(omitted.rawJson.containsKey('status'), isFalse);
      expect(omitted.hasStatus, isFalse);
      expect(model.copyWith(status: model.status), model);
      final cleared = model.copyWith(status: null);
      expect(cleared.rawJson.containsKey('status'), isTrue);
      expect(cleared.toJson()['status'], isNull);
      expect(cleared.hasStatus, isTrue);
    });
    test('known status wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['status'] = 5;
      expect(
        () => LiveInputToolSearchOutputItemParam.fromJson(wire),
        throwsA(_safe('status')),
      );
      expect(
        () => LiveInputToolSearchOutputItemParam.fromJson(
          _clone(full),
        ).copyWith(status: 5),
        throwsA(_safe('status')),
      );
    });
    test('required tools absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('tools');
      expect(
        () => LiveInputToolSearchOutputItemParam.fromJson(wire),
        throwsA(_safe('tools')),
      );
    });
    test('known tools wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['tools'] = 5;
      expect(
        () => LiveInputToolSearchOutputItemParam.fromJson(wire),
        throwsA(_safe('tools')),
      );
      expect(
        () => LiveInputToolSearchOutputItemParam.fromJson(
          _clone(full),
        ).copyWith(tools: 5),
        throwsA(_safe('tools')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputToolSearchOutputItemParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputToolSearchOutputItemParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputToolSearchOutputItemParam.fromJson(wire),
        throwsA(_safe('LiveInputToolSearchOutputItemParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputToolSearchOutputItemParam.fromJson(wire),
        throwsA(_safe('LiveInputToolSearchOutputItemParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputToolSearchOutputItemParam.fromJson(wire),
        throwsA(_safe('LiveInputToolSearchOutputItemParam')),
      );
    });
  });
  group('ToolSearchOutputNamespaceToolParam', () {
    final minimal = {
      'type': 'namespace',
      'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'description': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'tools': [
        {'name': 'PRIVATE_LIVE_INPUT_PAYLOAD', 'type': 'function'},
      ],
    };
    final full = {
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
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputToolSearchOutputNamespaceToolParam.fromJson(
          _clone(wire),
        );
        final peer = LiveInputToolSearchOutputNamespaceToolParam.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputToolSearchOutputNamespaceToolParam.fromJson(
        _clone(full),
      );
      expect(
        _wire(model.description),
        (full as Map)['description'],
        reason: 'description',
      );
      expect(_wire(model.name), (full as Map)['name'], reason: 'name');
      expect(_wire(model.tools), (full as Map)['tools'], reason: 'tools');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputToolSearchOutputNamespaceToolParam.fromJson(
        source,
      );
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required description absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('description');
      expect(
        () => LiveInputToolSearchOutputNamespaceToolParam.fromJson(wire),
        throwsA(_safe('description')),
      );
    });
    test('known description wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['description'] = 5;
      expect(
        () => LiveInputToolSearchOutputNamespaceToolParam.fromJson(wire),
        throwsA(_safe('description')),
      );
      expect(
        () => LiveInputToolSearchOutputNamespaceToolParam.fromJson(
          _clone(full),
        ).copyWith(description: 5),
        throwsA(_safe('description')),
      );
    });
    test('required name absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('name');
      expect(
        () => LiveInputToolSearchOutputNamespaceToolParam.fromJson(wire),
        throwsA(_safe('name')),
      );
    });
    test('known name wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['name'] = 5;
      expect(
        () => LiveInputToolSearchOutputNamespaceToolParam.fromJson(wire),
        throwsA(_safe('name')),
      );
      expect(
        () => LiveInputToolSearchOutputNamespaceToolParam.fromJson(
          _clone(full),
        ).copyWith(name: 5),
        throwsA(_safe('name')),
      );
    });
    test('required tools absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('tools');
      expect(
        () => LiveInputToolSearchOutputNamespaceToolParam.fromJson(wire),
        throwsA(_safe('tools')),
      );
    });
    test('known tools wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['tools'] = 5;
      expect(
        () => LiveInputToolSearchOutputNamespaceToolParam.fromJson(wire),
        throwsA(_safe('tools')),
      );
      expect(
        () => LiveInputToolSearchOutputNamespaceToolParam.fromJson(
          _clone(full),
        ).copyWith(tools: 5),
        throwsA(_safe('tools')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputToolSearchOutputNamespaceToolParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputToolSearchOutputNamespaceToolParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputToolSearchOutputNamespaceToolParam.fromJson(wire),
        throwsA(_safe('LiveInputToolSearchOutputNamespaceToolParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputToolSearchOutputNamespaceToolParam.fromJson(wire),
        throwsA(_safe('LiveInputToolSearchOutputNamespaceToolParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputToolSearchOutputNamespaceToolParam.fromJson(wire),
        throwsA(_safe('LiveInputToolSearchOutputNamespaceToolParam')),
      );
    });
  });
  group('ToolSearchOutputTool', () {
    final minimal = {
      'type': 'function',
      'name': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'strict': false,
      'parameters': <String, dynamic>{},
    };
    final full = {
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
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputToolSearchOutputTool.fromJson(_clone(wire));
        final peer = LiveInputToolSearchOutputTool.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
  });
  group('ToolSearchToolParam', () {
    final minimal = {'type': 'tool_search'};
    final full = {
      'description': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'execution': 'server',
      'parameters': <String, dynamic>{},
      'type': 'tool_search',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputToolSearchToolParam.fromJson(_clone(wire));
        final peer = LiveInputToolSearchToolParam.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputToolSearchToolParam.fromJson(_clone(full));
      expect(
        _wire(model.description),
        (full as Map)['description'],
        reason: 'description',
      );
      expect(model.hasDescription, isTrue);
      expect(
        _wire(model.execution),
        (full as Map)['execution'],
        reason: 'execution',
      );
      expect(model.hasExecution, isTrue);
      expect(
        _wire(model.parameters),
        (full as Map)['parameters'],
        reason: 'parameters',
      );
      expect(model.hasParameters, isTrue);
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputToolSearchToolParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('optional description omit/null/clear and copy ownership', () {
      final model = LiveInputToolSearchToolParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearDescription: true);
      expect(omitted.rawJson.containsKey('description'), isFalse);
      expect(omitted.hasDescription, isFalse);
      expect(model.copyWith(description: model.description), model);
      final cleared = model.copyWith(description: null);
      expect(cleared.rawJson.containsKey('description'), isTrue);
      expect(cleared.toJson()['description'], isNull);
      expect(cleared.hasDescription, isTrue);
    });
    test('known description wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['description'] = 5;
      expect(
        () => LiveInputToolSearchToolParam.fromJson(wire),
        throwsA(_safe('description')),
      );
      expect(
        () => LiveInputToolSearchToolParam.fromJson(
          _clone(full),
        ).copyWith(description: 5),
        throwsA(_safe('description')),
      );
    });
    test('optional execution omit/null/clear and copy ownership', () {
      final model = LiveInputToolSearchToolParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearExecution: true);
      expect(omitted.rawJson.containsKey('execution'), isFalse);
      expect(omitted.hasExecution, isFalse);
      expect(model.copyWith(execution: model.execution), model);
      expect(
        () => model.copyWith(execution: null),
        throwsA(_safe('execution')),
      );
    });
    test('known execution wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['execution'] = 5;
      expect(
        () => LiveInputToolSearchToolParam.fromJson(wire),
        throwsA(_safe('execution')),
      );
      expect(
        () => LiveInputToolSearchToolParam.fromJson(
          _clone(full),
        ).copyWith(execution: 5),
        throwsA(_safe('execution')),
      );
    });
    test('optional parameters omit/null/clear and copy ownership', () {
      final model = LiveInputToolSearchToolParam.fromJson(_clone(full));
      final omitted = model.copyWith(clearParameters: true);
      expect(omitted.rawJson.containsKey('parameters'), isFalse);
      expect(omitted.hasParameters, isFalse);
      expect(model.copyWith(parameters: model.parameters), model);
      final cleared = model.copyWith(parameters: null);
      expect(cleared.rawJson.containsKey('parameters'), isTrue);
      expect(cleared.toJson()['parameters'], isNull);
      expect(cleared.hasParameters, isTrue);
    });
    test('known parameters wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['parameters'] = 5;
      expect(
        () => LiveInputToolSearchToolParam.fromJson(wire),
        throwsA(_safe('parameters')),
      );
      expect(
        () => LiveInputToolSearchToolParam.fromJson(
          _clone(full),
        ).copyWith(parameters: 5),
        throwsA(_safe('parameters')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputToolSearchToolParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputToolSearchToolParam.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputToolSearchToolParam.fromJson(wire),
        throwsA(_safe('LiveInputToolSearchToolParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputToolSearchToolParam.fromJson(wire),
        throwsA(_safe('LiveInputToolSearchToolParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputToolSearchToolParam.fromJson(wire),
        throwsA(_safe('LiveInputToolSearchToolParam')),
      );
    });
  });
  group('TopLogProb', () {
    final minimal = {
      'token': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'logprob': 0,
      'bytes': <dynamic>[],
    };
    final full = {
      'bytes': [0],
      'logprob': 0,
      'token': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputTopLogProb.fromJson(_clone(wire));
        final peer = LiveInputTopLogProb.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputTopLogProb.fromJson(_clone(full));
      expect(_wire(model.bytes), (full as Map)['bytes'], reason: 'bytes');
      expect(_wire(model.logprob), (full as Map)['logprob'], reason: 'logprob');
      expect(_wire(model.token), (full as Map)['token'], reason: 'token');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputTopLogProb.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required bytes absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('bytes');
      expect(() => LiveInputTopLogProb.fromJson(wire), throwsA(_safe('bytes')));
    });
    test('known bytes wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['bytes'] = 5;
      expect(() => LiveInputTopLogProb.fromJson(wire), throwsA(_safe('bytes')));
      expect(
        () => LiveInputTopLogProb.fromJson(_clone(full)).copyWith(bytes: 5),
        throwsA(_safe('bytes')),
      );
    });
    test('required logprob absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('logprob');
      expect(
        () => LiveInputTopLogProb.fromJson(wire),
        throwsA(_safe('logprob')),
      );
    });
    test('known logprob wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['logprob'] = false;
      expect(
        () => LiveInputTopLogProb.fromJson(wire),
        throwsA(_safe('logprob')),
      );
      expect(
        () =>
            LiveInputTopLogProb.fromJson(_clone(full)).copyWith(logprob: false),
        throwsA(_safe('logprob')),
      );
    });
    test('required token absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('token');
      expect(() => LiveInputTopLogProb.fromJson(wire), throwsA(_safe('token')));
    });
    test('known token wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['token'] = 5;
      expect(() => LiveInputTopLogProb.fromJson(wire), throwsA(_safe('token')));
      expect(
        () => LiveInputTopLogProb.fromJson(_clone(full)).copyWith(token: 5),
        throwsA(_safe('token')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputTopLogProb.fromJson(wire),
        throwsA(_safe('LiveInputTopLogProb')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputTopLogProb.fromJson(wire),
        throwsA(_safe('LiveInputTopLogProb')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputTopLogProb.fromJson(wire),
        throwsA(_safe('LiveInputTopLogProb')),
      );
    });
  });
  group('TypeParam', () {
    final minimal = {'type': 'type', 'text': 'PRIVATE_LIVE_INPUT_PAYLOAD'};
    final full = {'text': 'PRIVATE_LIVE_INPUT_PAYLOAD', 'type': 'type'};
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputTypeParam.fromJson(_clone(wire));
        final peer = LiveInputTypeParam.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputTypeParam.fromJson(_clone(full));
      expect(_wire(model.text), (full as Map)['text'], reason: 'text');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputTypeParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required text absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('text');
      expect(() => LiveInputTypeParam.fromJson(wire), throwsA(_safe('text')));
    });
    test('known text wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['text'] = 5;
      expect(() => LiveInputTypeParam.fromJson(wire), throwsA(_safe('text')));
      expect(
        () => LiveInputTypeParam.fromJson(_clone(full)).copyWith(text: 5),
        throwsA(_safe('text')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(() => LiveInputTypeParam.fromJson(wire), throwsA(_safe('type')));
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(() => LiveInputTypeParam.fromJson(wire), throwsA(_safe('type')));
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputTypeParam.fromJson(wire),
        throwsA(_safe('LiveInputTypeParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputTypeParam.fromJson(wire),
        throwsA(_safe('LiveInputTypeParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputTypeParam.fromJson(wire),
        throwsA(_safe('LiveInputTypeParam')),
      );
    });
  });
  group('UrlCitationBody', () {
    final minimal = {
      'type': 'url_citation',
      'url': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'start_index': 0,
      'end_index': 0,
      'title': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    final full = {
      'end_index': 0,
      'start_index': 0,
      'title': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'url_citation',
      'url': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputUrlCitationBody.fromJson(_clone(wire));
        final peer = LiveInputUrlCitationBody.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputUrlCitationBody.fromJson(_clone(full));
      expect(
        _wire(model.endIndex),
        (full as Map)['end_index'],
        reason: 'end_index',
      );
      expect(
        _wire(model.startIndex),
        (full as Map)['start_index'],
        reason: 'start_index',
      );
      expect(_wire(model.title), (full as Map)['title'], reason: 'title');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
      expect(_wire(model.url), (full as Map)['url'], reason: 'url');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputUrlCitationBody.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required end_index absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('end_index');
      expect(
        () => LiveInputUrlCitationBody.fromJson(wire),
        throwsA(_safe('end_index')),
      );
    });
    test('known end_index wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['end_index'] = false;
      expect(
        () => LiveInputUrlCitationBody.fromJson(wire),
        throwsA(_safe('end_index')),
      );
      expect(
        () => LiveInputUrlCitationBody.fromJson(
          _clone(full),
        ).copyWith(endIndex: false),
        throwsA(_safe('end_index')),
      );
    });
    test('required start_index absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('start_index');
      expect(
        () => LiveInputUrlCitationBody.fromJson(wire),
        throwsA(_safe('start_index')),
      );
    });
    test('known start_index wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['start_index'] = false;
      expect(
        () => LiveInputUrlCitationBody.fromJson(wire),
        throwsA(_safe('start_index')),
      );
      expect(
        () => LiveInputUrlCitationBody.fromJson(
          _clone(full),
        ).copyWith(startIndex: false),
        throwsA(_safe('start_index')),
      );
    });
    test('required title absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('title');
      expect(
        () => LiveInputUrlCitationBody.fromJson(wire),
        throwsA(_safe('title')),
      );
    });
    test('known title wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['title'] = 5;
      expect(
        () => LiveInputUrlCitationBody.fromJson(wire),
        throwsA(_safe('title')),
      );
      expect(
        () =>
            LiveInputUrlCitationBody.fromJson(_clone(full)).copyWith(title: 5),
        throwsA(_safe('title')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputUrlCitationBody.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputUrlCitationBody.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('required url absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('url');
      expect(
        () => LiveInputUrlCitationBody.fromJson(wire),
        throwsA(_safe('url')),
      );
    });
    test('known url wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['url'] = 5;
      expect(
        () => LiveInputUrlCitationBody.fromJson(wire),
        throwsA(_safe('url')),
      );
      expect(
        () => LiveInputUrlCitationBody.fromJson(_clone(full)).copyWith(url: 5),
        throwsA(_safe('url')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputUrlCitationBody.fromJson(wire),
        throwsA(_safe('LiveInputUrlCitationBody')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputUrlCitationBody.fromJson(wire),
        throwsA(_safe('LiveInputUrlCitationBody')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputUrlCitationBody.fromJson(wire),
        throwsA(_safe('LiveInputUrlCitationBody')),
      );
    });
  });
  group('VectorStoreFileAttributes', () {
    final minimal = <String, dynamic>{};
    final full = <String, dynamic>{};
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputVectorStoreFileAttributes.fromJson(_clone(wire));
        final peer = LiveInputVectorStoreFileAttributes.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
  });
  group('WaitParam', () {
    final minimal = {'type': 'wait'};
    final full = {'type': 'wait'};
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputWaitParam.fromJson(_clone(wire));
        final peer = LiveInputWaitParam.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputWaitParam.fromJson(_clone(full));
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputWaitParam.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(() => LiveInputWaitParam.fromJson(wire), throwsA(_safe('type')));
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(() => LiveInputWaitParam.fromJson(wire), throwsA(_safe('type')));
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputWaitParam.fromJson(wire),
        throwsA(_safe('LiveInputWaitParam')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputWaitParam.fromJson(wire),
        throwsA(_safe('LiveInputWaitParam')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputWaitParam.fromJson(wire),
        throwsA(_safe('LiveInputWaitParam')),
      );
    });
  });
  group('WebSearchActionFind', () {
    final minimal = {
      'type': 'find_in_page',
      'url': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'pattern': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    final full = {
      'pattern': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'find_in_page',
      'url': 'PRIVATE_LIVE_INPUT_PAYLOAD',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputWebSearchActionFind.fromJson(_clone(wire));
        final peer = LiveInputWebSearchActionFind.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputWebSearchActionFind.fromJson(_clone(full));
      expect(_wire(model.pattern), (full as Map)['pattern'], reason: 'pattern');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
      expect(_wire(model.url), (full as Map)['url'], reason: 'url');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputWebSearchActionFind.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required pattern absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('pattern');
      expect(
        () => LiveInputWebSearchActionFind.fromJson(wire),
        throwsA(_safe('pattern')),
      );
    });
    test('known pattern wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['pattern'] = 5;
      expect(
        () => LiveInputWebSearchActionFind.fromJson(wire),
        throwsA(_safe('pattern')),
      );
      expect(
        () => LiveInputWebSearchActionFind.fromJson(
          _clone(full),
        ).copyWith(pattern: 5),
        throwsA(_safe('pattern')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputWebSearchActionFind.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputWebSearchActionFind.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('required url absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('url');
      expect(
        () => LiveInputWebSearchActionFind.fromJson(wire),
        throwsA(_safe('url')),
      );
    });
    test('known url wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['url'] = 5;
      expect(
        () => LiveInputWebSearchActionFind.fromJson(wire),
        throwsA(_safe('url')),
      );
      expect(
        () => LiveInputWebSearchActionFind.fromJson(
          _clone(full),
        ).copyWith(url: 5),
        throwsA(_safe('url')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputWebSearchActionFind.fromJson(wire),
        throwsA(_safe('LiveInputWebSearchActionFind')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputWebSearchActionFind.fromJson(wire),
        throwsA(_safe('LiveInputWebSearchActionFind')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputWebSearchActionFind.fromJson(wire),
        throwsA(_safe('LiveInputWebSearchActionFind')),
      );
    });
  });
  group('WebSearchActionOpenPage', () {
    final minimal = {'type': 'open_page'};
    final full = {'type': 'open_page', 'url': 'PRIVATE_LIVE_INPUT_PAYLOAD'};
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputWebSearchActionOpenPage.fromJson(_clone(wire));
        final peer = LiveInputWebSearchActionOpenPage.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputWebSearchActionOpenPage.fromJson(_clone(full));
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
      expect(_wire(model.url), (full as Map)['url'], reason: 'url');
      expect(model.hasUrl, isTrue);
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputWebSearchActionOpenPage.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputWebSearchActionOpenPage.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputWebSearchActionOpenPage.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('optional url omit/null/clear and copy ownership', () {
      final model = LiveInputWebSearchActionOpenPage.fromJson(_clone(full));
      final omitted = model.copyWith(clearUrl: true);
      expect(omitted.rawJson.containsKey('url'), isFalse);
      expect(omitted.hasUrl, isFalse);
      expect(model.copyWith(url: model.url), model);
      final cleared = model.copyWith(url: null);
      expect(cleared.rawJson.containsKey('url'), isTrue);
      expect(cleared.toJson()['url'], isNull);
      expect(cleared.hasUrl, isTrue);
    });
    test('known url wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['url'] = 5;
      expect(
        () => LiveInputWebSearchActionOpenPage.fromJson(wire),
        throwsA(_safe('url')),
      );
      expect(
        () => LiveInputWebSearchActionOpenPage.fromJson(
          _clone(full),
        ).copyWith(url: 5),
        throwsA(_safe('url')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputWebSearchActionOpenPage.fromJson(wire),
        throwsA(_safe('LiveInputWebSearchActionOpenPage')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputWebSearchActionOpenPage.fromJson(wire),
        throwsA(_safe('LiveInputWebSearchActionOpenPage')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputWebSearchActionOpenPage.fromJson(wire),
        throwsA(_safe('LiveInputWebSearchActionOpenPage')),
      );
    });
  });
  group('WebSearchActionSearch', () {
    final minimal = {'type': 'search'};
    final full = {
      'queries': ['PRIVATE_LIVE_INPUT_PAYLOAD'],
      'query': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'sources': [
        {'type': 'url', 'url': 'PRIVATE_LIVE_INPUT_PAYLOAD'},
      ],
      'type': 'search',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputWebSearchActionSearch.fromJson(_clone(wire));
        final peer = LiveInputWebSearchActionSearch.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputWebSearchActionSearch.fromJson(_clone(full));
      expect(_wire(model.queries), (full as Map)['queries'], reason: 'queries');
      expect(model.hasQueries, isTrue);
      expect(_wire(model.query), (full as Map)['query'], reason: 'query');
      expect(model.hasQuery, isTrue);
      expect(_wire(model.sources), (full as Map)['sources'], reason: 'sources');
      expect(model.hasSources, isTrue);
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputWebSearchActionSearch.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('optional queries omit/null/clear and copy ownership', () {
      final model = LiveInputWebSearchActionSearch.fromJson(_clone(full));
      final omitted = model.copyWith(clearQueries: true);
      expect(omitted.rawJson.containsKey('queries'), isFalse);
      expect(omitted.hasQueries, isFalse);
      expect(model.copyWith(queries: model.queries), model);
      expect(() => model.copyWith(queries: null), throwsA(_safe('queries')));
    });
    test('known queries wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['queries'] = 5;
      expect(
        () => LiveInputWebSearchActionSearch.fromJson(wire),
        throwsA(_safe('queries')),
      );
      expect(
        () => LiveInputWebSearchActionSearch.fromJson(
          _clone(full),
        ).copyWith(queries: 5),
        throwsA(_safe('queries')),
      );
    });
    test('optional query omit/null/clear and copy ownership', () {
      final model = LiveInputWebSearchActionSearch.fromJson(_clone(full));
      final omitted = model.copyWith(clearQuery: true);
      expect(omitted.rawJson.containsKey('query'), isFalse);
      expect(omitted.hasQuery, isFalse);
      expect(model.copyWith(query: model.query), model);
      expect(() => model.copyWith(query: null), throwsA(_safe('query')));
    });
    test('known query wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['query'] = 5;
      expect(
        () => LiveInputWebSearchActionSearch.fromJson(wire),
        throwsA(_safe('query')),
      );
      expect(
        () => LiveInputWebSearchActionSearch.fromJson(
          _clone(full),
        ).copyWith(query: 5),
        throwsA(_safe('query')),
      );
    });
    test('optional sources omit/null/clear and copy ownership', () {
      final model = LiveInputWebSearchActionSearch.fromJson(_clone(full));
      final omitted = model.copyWith(clearSources: true);
      expect(omitted.rawJson.containsKey('sources'), isFalse);
      expect(omitted.hasSources, isFalse);
      expect(model.copyWith(sources: model.sources), model);
      expect(() => model.copyWith(sources: null), throwsA(_safe('sources')));
    });
    test('known sources wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['sources'] = 5;
      expect(
        () => LiveInputWebSearchActionSearch.fromJson(wire),
        throwsA(_safe('sources')),
      );
      expect(
        () => LiveInputWebSearchActionSearch.fromJson(
          _clone(full),
        ).copyWith(sources: 5),
        throwsA(_safe('sources')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputWebSearchActionSearch.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputWebSearchActionSearch.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputWebSearchActionSearch.fromJson(wire),
        throwsA(_safe('LiveInputWebSearchActionSearch')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputWebSearchActionSearch.fromJson(wire),
        throwsA(_safe('LiveInputWebSearchActionSearch')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputWebSearchActionSearch.fromJson(wire),
        throwsA(_safe('LiveInputWebSearchActionSearch')),
      );
    });
  });
  group('WebSearchApproximateLocation', () {
    final minimal = <String, dynamic>{};
    final full = {
      'city': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'country': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'region': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'timezone': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'approximate',
    };
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputWebSearchApproximateLocation.fromJson(
          _clone(wire),
        );
        final peer = LiveInputWebSearchApproximateLocation.fromJson(
          _clone(wire),
        );
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
  });
  group('WebSearchCallStatus', () {
    const minimal = 'in_progress';
    const full = 'in_progress';
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputWebSearchCallStatus.fromJson(_clone(wire));
        final peer = LiveInputWebSearchCallStatus.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('value copy and JSON ownership', () {
      final model = LiveInputWebSearchCallStatus.fromJson(_clone(full));
      expect(_wire(model.value), full);
      expect(model.copyWith(value: _clone(full)), model);
    });
  });
  group('WebSearchPreviewTool', () {
    final minimal = {'type': 'web_search_preview'};
    final full = {
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
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputWebSearchPreviewTool.fromJson(_clone(wire));
        final peer = LiveInputWebSearchPreviewTool.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputWebSearchPreviewTool.fromJson(_clone(full));
      expect(
        _wire(model.searchContentTypes),
        (full as Map)['search_content_types'],
        reason: 'search_content_types',
      );
      expect(model.hasSearchContentTypes, isTrue);
      expect(
        _wire(model.searchContextSize),
        (full as Map)['search_context_size'],
        reason: 'search_context_size',
      );
      expect(model.hasSearchContextSize, isTrue);
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
      expect(
        _wire(model.userLocation),
        (full as Map)['user_location'],
        reason: 'user_location',
      );
      expect(model.hasUserLocation, isTrue);
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputWebSearchPreviewTool.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test(
      'optional search_content_types omit/null/clear and copy ownership',
      () {
        final model = LiveInputWebSearchPreviewTool.fromJson(_clone(full));
        final omitted = model.copyWith(clearSearchContentTypes: true);
        expect(omitted.rawJson.containsKey('search_content_types'), isFalse);
        expect(omitted.hasSearchContentTypes, isFalse);
        expect(
          model.copyWith(searchContentTypes: model.searchContentTypes),
          model,
        );
        expect(
          () => model.copyWith(searchContentTypes: null),
          throwsA(_safe('search_content_types')),
        );
      },
    );
    test('known search_content_types wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['search_content_types'] = 5;
      expect(
        () => LiveInputWebSearchPreviewTool.fromJson(wire),
        throwsA(_safe('search_content_types')),
      );
      expect(
        () => LiveInputWebSearchPreviewTool.fromJson(
          _clone(full),
        ).copyWith(searchContentTypes: 5),
        throwsA(_safe('search_content_types')),
      );
    });
    test('optional search_context_size omit/null/clear and copy ownership', () {
      final model = LiveInputWebSearchPreviewTool.fromJson(_clone(full));
      final omitted = model.copyWith(clearSearchContextSize: true);
      expect(omitted.rawJson.containsKey('search_context_size'), isFalse);
      expect(omitted.hasSearchContextSize, isFalse);
      expect(model.copyWith(searchContextSize: model.searchContextSize), model);
      expect(
        () => model.copyWith(searchContextSize: null),
        throwsA(_safe('search_context_size')),
      );
    });
    test('known search_context_size wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['search_context_size'] = 5;
      expect(
        () => LiveInputWebSearchPreviewTool.fromJson(wire),
        throwsA(_safe('search_context_size')),
      );
      expect(
        () => LiveInputWebSearchPreviewTool.fromJson(
          _clone(full),
        ).copyWith(searchContextSize: 5),
        throwsA(_safe('search_context_size')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputWebSearchPreviewTool.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputWebSearchPreviewTool.fromJson(wire),
        throwsA(_safe('type')),
      );
      expect(
        () => LiveInputWebSearchPreviewTool.fromJson(
          _clone(full),
        ).copyWith(type: 5),
        throwsA(_safe('type')),
      );
    });
    test('optional user_location omit/null/clear and copy ownership', () {
      final model = LiveInputWebSearchPreviewTool.fromJson(_clone(full));
      final omitted = model.copyWith(clearUserLocation: true);
      expect(omitted.rawJson.containsKey('user_location'), isFalse);
      expect(omitted.hasUserLocation, isFalse);
      expect(model.copyWith(userLocation: model.userLocation), model);
      final cleared = model.copyWith(userLocation: null);
      expect(cleared.rawJson.containsKey('user_location'), isTrue);
      expect(cleared.toJson()['user_location'], isNull);
      expect(cleared.hasUserLocation, isTrue);
    });
    test('known user_location wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['user_location'] = 5;
      expect(
        () => LiveInputWebSearchPreviewTool.fromJson(wire),
        throwsA(_safe('user_location')),
      );
      expect(
        () => LiveInputWebSearchPreviewTool.fromJson(
          _clone(full),
        ).copyWith(userLocation: 5),
        throwsA(_safe('user_location')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputWebSearchPreviewTool.fromJson(wire),
        throwsA(_safe('LiveInputWebSearchPreviewTool')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputWebSearchPreviewTool.fromJson(wire),
        throwsA(_safe('LiveInputWebSearchPreviewTool')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputWebSearchPreviewTool.fromJson(wire),
        throwsA(_safe('LiveInputWebSearchPreviewTool')),
      );
    });
  });
  group('WebSearchTool', () {
    final minimal = {'type': 'web_search'};
    final full = {
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
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputWebSearchTool.fromJson(_clone(wire));
        final peer = LiveInputWebSearchTool.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputWebSearchTool.fromJson(_clone(full));
      expect(
        _wire(model.externalWebAccess),
        (full as Map)['external_web_access'],
        reason: 'external_web_access',
      );
      expect(model.hasExternalWebAccess, isTrue);
      expect(_wire(model.filters), (full as Map)['filters'], reason: 'filters');
      expect(model.hasFilters, isTrue);
      expect(
        _wire(model.searchContextSize),
        (full as Map)['search_context_size'],
        reason: 'search_context_size',
      );
      expect(model.hasSearchContextSize, isTrue);
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
      expect(
        _wire(model.userLocation),
        (full as Map)['user_location'],
        reason: 'user_location',
      );
      expect(model.hasUserLocation, isTrue);
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputWebSearchTool.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('optional external_web_access omit/null/clear and copy ownership', () {
      final model = LiveInputWebSearchTool.fromJson(_clone(full));
      final omitted = model.copyWith(clearExternalWebAccess: true);
      expect(omitted.rawJson.containsKey('external_web_access'), isFalse);
      expect(omitted.hasExternalWebAccess, isFalse);
      expect(model.copyWith(externalWebAccess: model.externalWebAccess), model);
      expect(
        () => model.copyWith(externalWebAccess: null),
        throwsA(_safe('external_web_access')),
      );
    });
    test('known external_web_access wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['external_web_access'] = 5;
      expect(
        () => LiveInputWebSearchTool.fromJson(wire),
        throwsA(_safe('external_web_access')),
      );
      expect(
        () => LiveInputWebSearchTool.fromJson(
          _clone(full),
        ).copyWith(externalWebAccess: 5),
        throwsA(_safe('external_web_access')),
      );
    });
    test('optional filters omit/null/clear and copy ownership', () {
      final model = LiveInputWebSearchTool.fromJson(_clone(full));
      final omitted = model.copyWith(clearFilters: true);
      expect(omitted.rawJson.containsKey('filters'), isFalse);
      expect(omitted.hasFilters, isFalse);
      expect(model.copyWith(filters: model.filters), model);
      final cleared = model.copyWith(filters: null);
      expect(cleared.rawJson.containsKey('filters'), isTrue);
      expect(cleared.toJson()['filters'], isNull);
      expect(cleared.hasFilters, isTrue);
    });
    test('known filters wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['filters'] = 5;
      expect(
        () => LiveInputWebSearchTool.fromJson(wire),
        throwsA(_safe('filters')),
      );
      expect(
        () =>
            LiveInputWebSearchTool.fromJson(_clone(full)).copyWith(filters: 5),
        throwsA(_safe('filters')),
      );
    });
    test('optional search_context_size omit/null/clear and copy ownership', () {
      final model = LiveInputWebSearchTool.fromJson(_clone(full));
      final omitted = model.copyWith(clearSearchContextSize: true);
      expect(omitted.rawJson.containsKey('search_context_size'), isFalse);
      expect(omitted.hasSearchContextSize, isFalse);
      expect(model.copyWith(searchContextSize: model.searchContextSize), model);
      expect(
        () => model.copyWith(searchContextSize: null),
        throwsA(_safe('search_context_size')),
      );
    });
    test('known search_context_size wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['search_context_size'] = 5;
      expect(
        () => LiveInputWebSearchTool.fromJson(wire),
        throwsA(_safe('search_context_size')),
      );
      expect(
        () => LiveInputWebSearchTool.fromJson(
          _clone(full),
        ).copyWith(searchContextSize: 5),
        throwsA(_safe('search_context_size')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputWebSearchTool.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputWebSearchTool.fromJson(wire),
        throwsA(_safe('type')),
      );
      expect(
        () => LiveInputWebSearchTool.fromJson(_clone(full)).copyWith(type: 5),
        throwsA(_safe('type')),
      );
    });
    test('optional user_location omit/null/clear and copy ownership', () {
      final model = LiveInputWebSearchTool.fromJson(_clone(full));
      final omitted = model.copyWith(clearUserLocation: true);
      expect(omitted.rawJson.containsKey('user_location'), isFalse);
      expect(omitted.hasUserLocation, isFalse);
      expect(model.copyWith(userLocation: model.userLocation), model);
      final cleared = model.copyWith(userLocation: null);
      expect(cleared.rawJson.containsKey('user_location'), isTrue);
      expect(cleared.toJson()['user_location'], isNull);
      expect(cleared.hasUserLocation, isTrue);
    });
    test('known user_location wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['user_location'] = 5;
      expect(
        () => LiveInputWebSearchTool.fromJson(wire),
        throwsA(_safe('user_location')),
      );
      expect(
        () => LiveInputWebSearchTool.fromJson(
          _clone(full),
        ).copyWith(userLocation: 5),
        throwsA(_safe('user_location')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputWebSearchTool.fromJson(wire),
        throwsA(_safe('LiveInputWebSearchTool')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputWebSearchTool.fromJson(wire),
        throwsA(_safe('LiveInputWebSearchTool')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputWebSearchTool.fromJson(wire),
        throwsA(_safe('LiveInputWebSearchTool')),
      );
    });
  });
  group('WebSearchToolCall', () {
    final minimal = {
      'id': 'PRIVATE_LIVE_INPUT_PAYLOAD',
      'type': 'web_search_call',
      'status': 'in_progress',
    };
    final full = {
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
    test('minimal/full exact wire and value/hash contracts', () {
      for (final wire in [minimal, full]) {
        final model = LiveInputWebSearchToolCall.fromJson(_clone(wire));
        final peer = LiveInputWebSearchToolCall.fromJson(_clone(wire));
        expect(model.toJson(), wire);
        expect(model, peer);
        expect(model.hashCode, peer.hashCode);
        expect(model.toString(), isNot(contains(_private)));
        expect(model.copyWith(), model);
      }
    });
    test('every typed field exposes the complete canonical value', () {
      final model = LiveInputWebSearchToolCall.fromJson(_clone(full));
      expect(_wire(model.action), (full as Map)['action'], reason: 'action');
      expect(model.hasAction, isTrue);
      expect(_wire(model.id), (full as Map)['id'], reason: 'id');
      expect(_wire(model.status), (full as Map)['status'], reason: 'status');
      expect(_wire(model.type), (full as Map)['type'], reason: 'type');
    });
    test('external ownership and deeply immutable future JSON', () {
      final source = Map<String, dynamic>.from(_clone(full)! as Map);
      source['future'] = <String, dynamic>{
        'nested': <Object?>[_private],
      };
      final model = LiveInputWebSearchToolCall.fromJson(source);
      (source['future'] as Map)['nested'] = <Object?>[];
      expect((model.rawJson['future'] as Map)['nested'], [_private]);
      expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
      expect(
        () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model
            .copyWith(
              rawJson: {
                'future': {
                  'nested': [_private],
                },
              },
            )
            .toJson(),
        {
          ...(full as Map),
          'future': {
            'nested': [_private],
          },
        },
      );
    });
    test('optional action omit/null/clear and copy ownership', () {
      final model = LiveInputWebSearchToolCall.fromJson(_clone(full));
      final omitted = model.copyWith(clearAction: true);
      expect(omitted.rawJson.containsKey('action'), isFalse);
      expect(omitted.hasAction, isFalse);
      expect(model.copyWith(action: model.action), model);
      expect(() => model.copyWith(action: null), throwsA(_safe('action')));
    });
    test('known action wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['action'] = 5;
      expect(
        () => LiveInputWebSearchToolCall.fromJson(wire),
        throwsA(_safe('action')),
      );
      expect(
        () => LiveInputWebSearchToolCall.fromJson(
          _clone(full),
        ).copyWith(action: 5),
        throwsA(_safe('action')),
      );
    });
    test('required id absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('id');
      expect(
        () => LiveInputWebSearchToolCall.fromJson(wire),
        throwsA(_safe('id')),
      );
    });
    test('known id wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['id'] = 5;
      expect(
        () => LiveInputWebSearchToolCall.fromJson(wire),
        throwsA(_safe('id')),
      );
      expect(
        () => LiveInputWebSearchToolCall.fromJson(_clone(full)).copyWith(id: 5),
        throwsA(_safe('id')),
      );
    });
    test('required status absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('status');
      expect(
        () => LiveInputWebSearchToolCall.fromJson(wire),
        throwsA(_safe('status')),
      );
    });
    test('known status wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['status'] = 5;
      expect(
        () => LiveInputWebSearchToolCall.fromJson(wire),
        throwsA(_safe('status')),
      );
      expect(
        () => LiveInputWebSearchToolCall.fromJson(
          _clone(full),
        ).copyWith(status: 5),
        throwsA(_safe('status')),
      );
    });
    test('required type absence fails contextually', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map)
        ..remove('type');
      expect(
        () => LiveInputWebSearchToolCall.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('known type wrong value cannot become overflow', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire['type'] = 5;
      expect(
        () => LiveInputWebSearchToolCall.fromJson(wire),
        throwsA(_safe('type')),
      );
    });
    test('runtime Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('Infinity');
      expect(
        () => LiveInputWebSearchToolCall.fromJson(wire),
        throwsA(_safe('LiveInputWebSearchToolCall')),
      );
    });
    test('runtime -Infinity future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('-Infinity');
      expect(
        () => LiveInputWebSearchToolCall.fromJson(wire),
        throwsA(_safe('LiveInputWebSearchToolCall')),
      );
    });
    test('runtime NaN future metadata remains finite-only', () {
      final wire = Map<String, dynamic>.from(_clone(full)! as Map);
      wire[_private] = num.parse('NaN');
      expect(
        () => LiveInputWebSearchToolCall.fromJson(wire),
        throwsA(_safe('LiveInputWebSearchToolCall')),
      );
    });
  });
}
