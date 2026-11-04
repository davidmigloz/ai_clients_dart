import 'dart:typed_data';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

Map<String, dynamic> _usage() => {
  'input_tokens': 1,
  'output_tokens': 2,
  'total_tokens': 3,
  'input_tokens_details': {'text_tokens': 1, 'image_tokens': 0},
};

Map<String, dynamic> _completed(String type) => {
  'type': type,
  'b64_json': 'PRIVATE_IMAGE',
  'created_at': 1,
  'size': '1536x864',
  'quality': 'high',
  'background': 'transparent',
  'output_format': 'png',
  'usage': _usage(),
};

Map<String, dynamic> _error() => {
  'code': 'moderation_blocked',
  'type': 'image_generation_error',
  'message': 'PRIVATE explanation',
  'param': null,
  'moderation_details': {
    'moderation_stage': 'input',
    'categories': ['future_category'],
  },
};

void main() {
  group('image safety identifiers', () {
    test(
      'generation retains legacy user and does not invent fallback locally',
      () {
        final request = ImageGenerationRequest.fromJson(const {
          'model': 'gpt-image-2.5-flare',
          'prompt': 'Draw a bird',
          'user': 'PRIVATE legacy',
          'safety_identifier': '',
        });
        expect(request.toJson()['safety_identifier'], '');
        expect(request.toJson()['user'], 'PRIVATE legacy');
        expect(
          request.copyWith(safetyIdentifier: null).toJson(),
          isNot(contains('safety_identifier')),
        );
        expect(
          request.copyWith(safetyIdentifier: 'replacement'),
          isNot(request),
        );
        expect(request.copyWith(), request);
        expect(
          request.hashCode,
          ImageGenerationRequest.fromJson(request.toJson()).hashCode,
        );
        expect(request.toString(), isNot(contains('PRIVATE')));
      },
    );

    test('request bound counts Unicode code points and is unconditional', () {
      final exact = '😀' * 128;
      expect(
        ImageGenerationRequest(
          prompt: 'p',
          model: 'm',
          safetyIdentifier: exact,
        ).toJson()['safety_identifier'],
        exact,
      );
      expect(
        () => ImageGenerationRequest(
          prompt: 'p',
          model: 'm',
          safetyIdentifier: '😀' * 129,
        ).toJson(),
        throwsFormatException,
      );
      expect(
        () => ImageGenerationRequest.fromJson({
          'prompt': 'p',
          'model': 'm',
          'safety_identifier': 'x' * 129,
        }),
        throwsFormatException,
      );
      expect(
        () => ImageGenerationRequest.fromJson(const {
          'prompt': 'p',
          'model': 'm',
          'safety_identifier': 1,
        }),
        throwsFormatException,
      );
      expect(
        ImageGenerationRequest.fromJson(const {
          'prompt': 'p',
          'model': 'm',
          'safety_identifier': null,
        }).safetyIdentifier,
        isNull,
      );
    });

    test(
      'ordinary receive values do not inherit request-only length bounds',
      () {
        final response = ImageResponse.fromJson({
          'created': 1,
          'safety_identifier': '😀' * 129,
        });
        expect(response.safetyIdentifier, '😀' * 129);
        expect(response.data, isEmpty);
        expect(response.hasData, isFalse);
        expect(response.toJson(), {
          'created': 1,
          'safety_identifier': '😀' * 129,
        });
        expect(response.copyWith(), response);
        expect(response.copyWith(safetyIdentifier: null).toJson(), {
          'created': 1,
        });
        final empty = ImageResponse.fromJson(const {
          'created': 1,
          'data': <Object>[],
          'safety_identifier': null,
        });
        expect(empty.hasData, isTrue);
        expect(empty, isNot(ImageResponse.fromJson(const {'created': 1})));
        expect(
          () => ImageResponse.fromJson(const {'created': 1, 'data': null}),
          throwsFormatException,
        );
      },
    );

    test('ordinary response owns lists and copies every metadata field', () {
      final source = <GeneratedImage>[const GeneratedImage(b64Json: 'PRIVATE')];
      final response = ImageResponse(
        created: 1,
        data: source,
        safetyIdentifier: 'PRIVATE id',
      );
      source.clear();
      expect(response.data, hasLength(1));
      expect(response.data.clear, throwsUnsupportedError);
      expect(response.toString(), isNot(contains('PRIVATE')));
      expect(response.copyWith(created: 2), isNot(response));
      expect(response.copyWith(data: const []), isNot(response));
      expect(
        response.copyWith(size: ImageSize.size1024x1024).size,
        ImageSize.size1024x1024,
      );
      expect(
        response.copyWith(quality: ImageQuality.high).quality,
        ImageQuality.high,
      );
      expect(
        response.copyWith(background: ImageBackground.opaque).background,
        ImageBackground.opaque,
      );
      expect(
        response.copyWith(outputFormat: ImageOutputFormat.webp).outputFormat,
        ImageOutputFormat.webp,
      );
      expect(
        response
            .copyWith(usage: ImagesUsage.fromJson(_usage()))
            .usage
            ?.totalTokens,
        3,
      );
    });

    for (final type in ['image_generation.completed', 'image_edit.completed']) {
      test(
        '$type preserves the safety echo and copy/equality/private diagnostics',
        () {
          final json = {..._completed(type), 'safety_identifier': 'PRIVATE id'};
          if (type == 'image_generation.completed') {
            final value = ImageGenCompletedEvent.fromJson(json);
            expect(value.toJson(), json);
            expect(ImageGenCompletedEvent.fromJson(value.toJson()), value);
            expect(value.copyWith(), value);
            expect(
              value.copyWith(safetyIdentifier: null).safetyIdentifier,
              isNull,
            );
            expect(value.copyWith(safetyIdentifier: 'different'), isNot(value));
            expect(value.hashCode, value.copyWith().hashCode);
            expect(value.toString(), isNot(contains('PRIVATE')));
            expect(
              ImageGenCompletedEvent.fromJson({
                ...json,
                'safety_identifier': null,
              }).safetyIdentifier,
              isNull,
            );
            expect(
              () => ImageGenCompletedEvent.fromJson({
                ...json,
                'safety_identifier': 1,
              }),
              throwsFormatException,
            );
          } else {
            final value = ImageEditCompletedEvent.fromJson(json);
            expect(value.toJson(), json);
            expect(ImageEditCompletedEvent.fromJson(value.toJson()), value);
            expect(value.copyWith(), value);
            expect(
              value.copyWith(safetyIdentifier: null).safetyIdentifier,
              isNull,
            );
            expect(value.copyWith(safetyIdentifier: 'different'), isNot(value));
            expect(value.hashCode, value.copyWith().hashCode);
            expect(value.toString(), isNot(contains('PRIVATE')));
            expect(
              ImageEditCompletedEvent.fromJson({
                ...json,
                'safety_identifier': null,
              }).safetyIdentifier,
              isNull,
            );
            expect(
              () => ImageEditCompletedEvent.fromJson({
                ...json,
                'safety_identifier': 1,
              }),
              throwsFormatException,
            );
          }
        },
      );
    }
  });

  group('image edit markup', () {
    test('multipart bytes and copy values are independently owned', () {
      final image = Uint8List.fromList([1, 2]);
      final markup = Uint8List.fromList([0, 255, 128]);
      final request = ImageEditRequest(
        image: image,
        imageFilename: 'input.png',
        prompt: 'p',
        model: 'gpt-image-2.5-flare',
        markup: markup,
        safetyIdentifier: 'PRIVATE id',
      );
      image[0] = 9;
      markup[0] = 9;
      expect(request.image, [1, 2]);
      expect(request.markup, [0, 255, 128]);
      expect(() => request.markup![0] = 7, throwsUnsupportedError);
      expect(request.copyWith(), request);
      expect(request.copyWith().hashCode, request.hashCode);
      expect(request.copyWith(markup: null).markup, isNull);
      expect(request.copyWith(markupFilename: 'new.png'), isNot(request));
      expect(request.copyWith(safetyIdentifier: null).safetyIdentifier, isNull);
      expect(request.toString(), isNot(contains('PRIVATE')));
      expect(() => request.copyWith(mask: Uint8List(1)), throwsFormatException);
      expect(
        () => request.copyWith(safetyIdentifier: 'x' * 129),
        throwsFormatException,
      );
      expect(
        () => request.copyWith(inputFidelity: ImageInputFidelity.unknown),
        throwsFormatException,
      );
    });

    test('JSON references, owned images and all field values round-trip', () {
      final source = [const ImageReference.file('file_original')];
      final value = ImageEditJsonRequest(
        images: source,
        prompt: 'p',
        markup: const ImageReference.url('https://fixture.invalid/PRIVATE.png'),
        safetyIdentifier: 'PRIVATE id',
        model: 'gpt-image-2.5-sunburst',
        n: 1,
        quality: ImageQuality.high,
        inputFidelity: ImageInputFidelity.high,
        size: ImageSize.size1024x1024,
        outputFormat: ImageOutputFormat.png,
        outputCompression: 80,
        moderation: ImageModerationLevel.auto,
        background: ImageBackground.transparent,
        stream: false,
        partialImages: 1,
      );
      source.clear();
      expect(value.images, hasLength(1));
      expect(value.images.clear, throwsUnsupportedError);
      expect(value.toJson()['markup'], {
        'image_url': 'https://fixture.invalid/PRIVATE.png',
      });
      expect(ImageEditJsonRequest.fromJson(value.toJson()), value);
      expect(
        ImageEditJsonRequest.fromJson(value.toJson()).hashCode,
        value.hashCode,
      );
      expect(value.copyWith(), value);
      expect(value.copyWith(markup: null).markup, isNull);
      expect(value.copyWith(safetyIdentifier: null).safetyIdentifier, isNull);
      expect(value.toString(), isNot(contains('PRIVATE')));
      for (final copy in [
        value.copyWith(prompt: 'new'),
        value.copyWith(model: null),
        value.copyWith(n: 2),
        value.copyWith(quality: ImageQuality.max),
        value.copyWith(inputFidelity: null),
        value.copyWith(size: null),
        value.copyWith(outputFormat: null),
        value.copyWith(outputCompression: null),
        value.copyWith(moderation: null),
        value.copyWith(background: null),
        value.copyWith(stream: null),
        value.copyWith(partialImages: null),
      ]) {
        expect(copy, isNot(value));
      }
      expect(
        () => value.copyWith(mask: const ImageReference.file('mask')),
        throwsFormatException,
      );
      expect(
        () =>
            ImageEditJsonRequest.fromJson({...value.toJson(), 'markup': null}),
        throwsFormatException,
      );
      expect(() => value.copyWith(images: const []), throwsFormatException);
    });

    test(
      'references reject invalid combinations/extra fields and redact URLs',
      () {
        const ref = ImageReference.url('https://fixture.invalid/?key=PRIVATE');
        expect(ref.toString(), isNot(contains('PRIVATE')));
        expect(ref.copyWith(), ref);
        expect(ref.copyWith(imageUrl: null, fileId: 'file').toJson(), {
          'file_id': 'file',
        });
        expect(
          () =>
              ImageReference.fromJson(const {'image_url': 'x', 'file_id': 'y'}),
          throwsA(anyOf(isA<AssertionError>(), isA<FormatException>())),
        );
        expect(
          () => ImageReference.fromJson(const {'file_id': null}),
          throwsFormatException,
        );
        expect(
          () =>
              ImageReference.fromJson(const {'file_id': 'x', 'PRIVATE': true}),
          throwsFormatException,
        );
      },
    );
  });

  group('GA/beta image tool errors', () {
    test(
      'both protocols preserve failed/generating and all output metadata',
      () {
        for (final beta in [false, true]) {
          for (final status in ['failed', 'generating', 'future_PRIVATE']) {
            final json = <String, dynamic>{
              'type': 'image_generation_call',
              'id': 'image_call',
              'status': status,
              'result': null,
              'error': _error(),
              'size': '1536x864',
              'quality': 'max',
              'action': 'edit',
              'background': 'transparent',
              'output_format': 'png',
              'revised_prompt': 'PRIVATE prompt',
              if (beta) 'agent': {'agent_name': 'assistant'},
            };
            final value =
                OutputItem.fromJson(json) as ImageGenerationCallOutputItem;
            expect(value.status.value, status);
            expect(value.status.isKnown, status != 'future_PRIVATE');
            expect(value.toJson(), json);
            expect(
              value.error?.moderationDetails?.moderationStage,
              ImageModerationStage.input,
            );
            expect(value.error?.moderationDetails?.categories, [
              'future_category',
            ]);
            expect(value.copyWith(), value);
            expect(value.copyWith().hashCode, value.hashCode);
            expect(value.copyWith(error: null).error, isNull);
            expect(value.copyWith(result: 'new'), isNot(value));
            expect(value.toString(), isNot(contains('PRIVATE')));
            for (final key in ['status', 'result', 'id']) {
              expect(
                () => OutputItem.fromJson({...json}..remove(key)),
                throwsFormatException,
              );
            }
            expect(
              () => OutputItem.fromJson({...json, 'error': null}),
              throwsFormatException,
            );
          }
        }
      },
    );

    test(
      'required nullable errors, optional nonnull details and exact future stages',
      () {
        final json = {..._error(), 'code': null, 'param': null};
        final error = ImageGenerationCallError.fromJson(json);
        expect(error.toJson(), json);
        expect(error.copyWith(), error);
        expect(error.copyWith(code: 'different'), isNot(error));
        expect(error.copyWith(param: 'different'), isNot(error));
        expect(error.copyWith(type: 'different'), isNot(error));
        expect(error.copyWith(message: 'different'), isNot(error));
        expect(
          error.copyWith(moderationDetails: null).toJson(),
          isNot(contains('moderation_details')),
        );
        expect(error.toString(), isNot(contains('PRIVATE')));
        for (final key in ['code', 'param', 'type', 'message']) {
          expect(
            () => ImageGenerationCallError.fromJson({...json}..remove(key)),
            throwsFormatException,
          );
        }
        expect(
          () => ImageGenerationCallError.fromJson({
            ...json,
            'moderation_details': null,
          }),
          throwsFormatException,
        );
        final future = ImageGenerationModerationDetails.fromJson(const {
          'moderation_stage': 'future',
          'categories': <String>[],
        });
        expect(future.moderationStage.value, 'future');
        expect(future.moderationStage.isKnown, isFalse);
        expect(ImageModerationStage.unknown.isKnown, isTrue);
        expect(
          () => ImageGenerationModerationDetails.fromJson(const {
            'moderation_stage': 'input',
          }),
          throwsFormatException,
        );
      },
    );

    test(
      'future metadata and categories are finite, deeply owned and authoritative',
      () {
        final categories = ['PRIVATE category'];
        final extra = {
          'future': <String, dynamic>{
            'values': <int>[1],
          },
        };
        final details = ImageGenerationModerationDetails(
          moderationStage: ImageModerationStage.output,
          categories: categories,
          rawJson: extra,
        );
        categories.clear();
        (extra['future']!['values'] as List<int>).clear();
        expect(details.categories, ['PRIVATE category']);
        expect(details.rawJson['future'], {
          'values': [1],
        });
        expect(details.categories.clear, throwsUnsupportedError);
        expect(details.copyWith(), details);
        expect(details.copyWith(categories: const []), isNot(details));
        expect(details.toString(), isNot(contains('PRIVATE')));
        expect(
          () => details.copyWith(rawJson: {'categories': <String>[]}),
          throwsFormatException,
        );
        expect(
          () => details.copyWith(rawJson: {'future': double.nan}),
          throwsFormatException,
        );
        final cycle = <String, dynamic>{};
        cycle['self'] = cycle;
        expect(() => details.copyWith(rawJson: cycle), throwsFormatException);
        expect(
          () => details.copyWith(rawJson: {'future': Object()}),
          throwsFormatException,
        );
      },
    );
  });
}
