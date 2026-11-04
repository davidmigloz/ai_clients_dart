import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

const _private = 'PRIVATE_LIVE_IMAGE_ERROR';

Map<String, dynamic> _item() => {
  'type': 'image_generation_call',
  'id': 'image-call',
  'status': 'failed',
  'result': null,
};

Map<String, dynamic> _error() => {
  'code': null,
  'type': 'moderation_blocked',
  'message': _private,
  'param': null,
  'moderation_details': {
    'moderation_stage': 'input',
    'categories': ['new_public_category'],
  },
};

Map<String, dynamic> _command(Map<String, dynamic> item) => {
  'type': 'response.item.create',
  'item': item,
};

Matcher _safe() => isA<FormatException>()
    .having((error) => error.message, 'context', contains('LiveInput'))
    .having((error) => error.source, 'source', isNull)
    .having((error) => error.offset, 'offset', isNull)
    .having((error) => error.toString(), 'privacy', isNot(contains(_private)));

void main() {
  test('primary, sideband and fork commands preserve typed image errors', () {
    final error = _error();
    final wire = _command({..._item(), 'error': error});
    final events = [
      LiveClientEvent.fromJson(wire),
      LiveSidebandClientEvent.fromJson(wire),
      LiveClientEvent.fromForkJson(wire),
    ];
    for (final event in events) {
      final command = event as LiveResponseItemCreateParam;
      final image = command.item as LiveInputImageGenToolCall;
      expect(image.status, 'failed');
      expect(image.result, isNull);
      expect(image.hasError, isTrue);
      expect(image.error, ImageGenerationCallError.fromJson(error));
      expect(image.error!.code, isNull);
      expect(image.error!.param, isNull);
      expect(
        image.error!.moderationDetails!.moderationStage,
        ImageModerationStage.input,
      );
      expect(image.error!.moderationDetails!.categories, [
        'new_public_category',
      ]);
      expect(command.toJson(), wire);
      expect(command.toString(), isNot(contains(_private)));
      expect(image.toString(), isNot(contains(_private)));
      expect(image.error.toString(), isNot(contains(_private)));
      expect(
        image.error!.moderationDetails.toString(),
        isNot(contains(_private)),
      );
    }
  });

  test('Responses output is replayable through the public Live adapter', () {
    final error = _error()..['future_error'] = {'private': _private};
    final output = ImageGenerationCallOutputItem(
      id: 'image-call',
      status: ImageGenerationCallStatus.failed,
      result: null,
      error: ImageGenerationCallError.fromJson(error),
    );
    final image =
        LiveInputItem.fromOutputItem(output) as LiveInputImageGenToolCall;
    expect(image.error, output.error);
    expect(image.toJson(), output.toJson());
    expect(
      LiveResponseItemCreateParam(item: image).toJson(),
      _command(output.toJson()),
    );
  });

  test('omission is preserved and clear removes the optional error', () {
    final absent = LiveInputImageGenToolCall.fromJson(_item());
    expect(absent.hasError, isFalse);
    expect(absent.error, isNull);
    expect(absent.toJson(), _item());
    final present = absent.copyWith(
      error: ImageGenerationCallError.fromJson(_error()),
    );
    expect(present.copyWith(), present);
    expect(
      present.copyWith(rawJson: {'error': null, 'future': true}).error,
      present.error,
    );
    expect(present.copyWith(clearError: true), absent);
    expect(present.copyWith(error: null, clearError: true), absent);
    expect(present.hasError, isTrue);
    expect(() => present.copyWith(error: null), throwsA(_safe()));
  });

  test('typed copy changes complete value while preserving owned metadata', () {
    final categories = ['input_category'];
    final future = <String, dynamic>{
      'nested': [_private],
    };
    final error = ImageGenerationCallError(
      code: 'moderation_blocked',
      type: 'moderation',
      message: _private,
      param: 'prompt',
      moderationDetails: ImageGenerationModerationDetails(
        moderationStage: ImageModerationStage.output,
        categories: categories,
        rawJson: {'future_details': future},
      ),
      rawJson: {'future_error': future},
    );
    final original = LiveInputImageGenToolCall.fromJson(_item());
    final copy = original.copyWith(error: error);
    categories[0] = 'mutated';
    (future['nested'] as List)[0] = 'mutated';
    expect(copy.error, error);
    expect(copy.error!.moderationDetails!.categories, ['input_category']);
    expect(copy.error!.rawJson['future_error'], {
      'nested': [_private],
    });
    expect(copy, isNot(original));
    final peer = LiveInputImageGenToolCall.fromJson(copy.toJson());
    expect(copy, peer);
    expect(copy.hashCode, peer.hashCode);
    expect(
      copy.copyWith(error: error.copyWith(message: 'changed')),
      isNot(copy),
    );
    expect(
      copy.copyWith(error: error.copyWith(rawJson: {'other': true})),
      isNot(copy),
    );
    expect(original.hasError, isFalse);
  });

  test(
    'parsed nested data and serialization remain detached and immutable',
    () {
      final error = _error()
        ..['future_error'] = {
          'nested': [_private],
        };
      final wire = {..._item(), 'error': error};
      final image = LiveInputImageGenToolCall.fromJson(wire);
      error['message'] = 'mutated';
      ((error['moderation_details'] as Map)['categories'] as List).clear();
      expect(image.error!.message, _private);
      expect(image.error!.moderationDetails!.categories, [
        'new_public_category',
      ]);
      expect(
        () => (image.rawJson['error'] as Map)['message'] = 'mutated',
        throwsUnsupportedError,
      );
      expect(
        () => image.error!.moderationDetails!.categories.clear(),
        throwsUnsupportedError,
      );
      expect(
        () => (image.error!.rawJson['future_error'] as Map).clear(),
        throwsUnsupportedError,
      );
      final serialized = image.toJson()..remove('error');
      expect(serialized.containsKey('error'), isFalse);
      expect(image.hasError, isTrue);
    },
  );

  for (final stage in ['input', 'output', 'unknown']) {
    test('canonical moderation stage $stage is replayable', () {
      final error = _error();
      (error['moderation_details'] as Map)['moderation_stage'] = stage;
      final image = LiveInputImageGenToolCall.fromJson({
        ..._item(),
        'error': error,
      });
      expect(image.error!.moderationDetails!.moderationStage.value, stage);
    });
  }

  test('error without optional moderation details remains replayable', () {
    final error = _error()..remove('moderation_details');
    final image = LiveInputImageGenToolCall.fromJson({
      ..._item(),
      'error': error,
    });
    expect(image.error!.moderationDetails, isNull);
    expect(image.error!.toJson(), error);
  });

  final malformed = <String, Object?>{
    'explicit null': null,
    'string': _private,
    'array': [_private],
    'missing code': _error()..remove('code'),
    'missing type': _error()..remove('type'),
    'missing message': _error()..remove('message'),
    'missing param': _error()..remove('param'),
    'invalid code': {..._error(), 'code': 1},
    'invalid type': {
      ..._error(),
      'type': [_private],
    },
    'invalid message': {..._error(), 'message': null},
    'invalid param': {..._error(), 'param': false},
    'null details': {..._error(), 'moderation_details': null},
    'missing stage': {
      ..._error(),
      'moderation_details': {'categories': <String>[]},
    },
    'missing categories': {
      ..._error(),
      'moderation_details': {'moderation_stage': 'input'},
    },
    'invalid categories': {
      ..._error(),
      'moderation_details': {
        'moderation_stage': 'input',
        'categories': [_private, 3],
      },
    },
    'invalid stage': {
      ..._error(),
      'moderation_details': {
        'moderation_stage': _private,
        'categories': <String>[],
      },
    },
  };
  for (final entry in malformed.entries) {
    test('public Live command rejects ${entry.key} image error privately', () {
      final wire = _command({..._item(), 'error': entry.value});
      expect(() => LiveClientEvent.fromJson(wire), throwsA(_safe()));
      expect(() => LiveSidebandClientEvent.fromJson(wire), throwsA(_safe()));
      expect(() => LiveClientEvent.fromForkJson(wire), throwsA(_safe()));
      expect(
        () => LiveInputImageGenToolCall.fromJson(
          _item(),
        ).copyWith(error: entry.value),
        throwsA(_safe()),
      );
    });
  }

  test(
    'received future moderation stages are not silently written by Live',
    () {
      final error = _error();
      (error['moderation_details'] as Map)['moderation_stage'] = _private;
      final received = ImageGenerationCallError.fromJson(error);
      expect(received.moderationDetails!.moderationStage.value, _private);
      expect(
        () => LiveInputImageGenToolCall.fromJson(
          _item(),
        ).copyWith(error: received),
        throwsA(_safe()),
      );
    },
  );

  for (final invalid in [double.nan, double.infinity, Object()]) {
    test('future error metadata rejects ${invalid.runtimeType} privately', () {
      final error = _error()..[_private] = invalid;
      expect(
        () => LiveClientEvent.fromJson(_command({..._item(), 'error': error})),
        throwsA(_safe()),
      );
    });
  }

  test('cyclic error metadata is rejected privately before replay', () {
    final cycle = <Object?>[];
    cycle.add(cycle);
    final error = _error()..[_private] = cycle;
    expect(
      () => LiveInputImageGenToolCall.fromJson({..._item(), 'error': error}),
      throwsA(_safe()),
    );
  });
}
