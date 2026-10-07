import 'dart:typed_data';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ImageGenerationRequest required model (IMG-01/04)', () {
    for (final model in [
      '',
      'future-provider/image-model-2030',
      'gpt-image-2.5-flare',
    ]) {
      test('retains explicit model verbatim: $model', () {
        final request = ImageGenerationRequest(prompt: '', model: model);
        expect(request.toJson(), {'prompt': '', 'model': model});
        expect(ImageGenerationRequest.fromJson(request.toJson()), request);
        expect(request.copyWith().model, model);
        expect(request.copyWith(model: null).model, model);
        expect(request.copyWith(model: 'replacement').model, 'replacement');
      });
    }
    for (final field in ['model', 'prompt']) {
      test('missing $field fails contextually', () {
        final json = {'model': 'fixture-model', 'prompt': 'Hello'}
          ..remove(field);
        expect(
          () => ImageGenerationRequest.fromJson(json),
          _invalidField(field),
        );
      });
      for (final invalid in <Object?>[
        null,
        7,
        false,
        <Object>[],
        <String, Object>{},
      ]) {
        test('malformed $field=$invalid fails contextually', () {
          final json = <String, dynamic>{
            'model': 'fixture-model',
            'prompt': 'Hello',
            field: invalid,
          };
          expect(
            () => ImageGenerationRequest.fromJson(json),
            _invalidField(field),
          );
        });
      }
    }

    const full = ImageGenerationRequest(
      prompt: 'prompt-private',
      model: 'fixture-generation',
      n: 2,
      quality: ImageQuality.max,
      responseFormat: ImageResponseFormat.b64Json,
      size: ImageSize.custom('1792x1344'),
      style: ImageStyle.vivid,
      user: 'user-private',
      background: ImageBackground.transparent,
      moderation: ImageModerationLevel.low,
      outputFormat: ImageOutputFormat.webp,
      outputCompression: 85,
      stream: true,
      partialImages: 3,
    );
    test('all 14 fields round-trip with matching value/hash contracts', () {
      expect(full.toJson(), {
        'prompt': 'prompt-private',
        'model': 'fixture-generation',
        'n': 2,
        'quality': 'max',
        'response_format': 'b64_json',
        'size': '1792x1344',
        'style': 'vivid',
        'user': 'user-private',
        'background': 'transparent',
        'moderation': 'low',
        'output_format': 'webp',
        'output_compression': 85,
        'stream': true,
        'partial_images': 3,
      });
      final restored = ImageGenerationRequest.fromJson(full.toJson());
      expect(restored, full);
      expect(restored.hashCode, full.hashCode);
      expect({restored, full, full.copyWith()}, hasLength(1));
      expect(full.copyWith(prompt: null, model: null), full);
    });
    final changes = <String, ImageGenerationRequest>{
      'prompt': full.copyWith(prompt: ''),
      'model': full.copyWith(model: ''),
      'n': full.copyWith(n: 0),
      'quality': full.copyWith(quality: ImageQuality.low),
      'responseFormat': full.copyWith(responseFormat: ImageResponseFormat.url),
      'size': full.copyWith(size: ImageSize.auto),
      'style': full.copyWith(style: ImageStyle.natural),
      'user': full.copyWith(user: ''),
      'background': full.copyWith(background: ImageBackground.opaque),
      'moderation': full.copyWith(moderation: ImageModerationLevel.auto),
      'outputFormat': full.copyWith(outputFormat: ImageOutputFormat.png),
      'outputCompression': full.copyWith(outputCompression: 0),
      'stream': full.copyWith(stream: false),
      'partialImages': full.copyWith(partialImages: 0),
    };
    final expectedChanges = <String, (String, Object)>{
      'prompt': ('prompt', ''),
      'model': ('model', ''),
      'n': ('n', 0),
      'quality': ('quality', 'low'),
      'responseFormat': ('response_format', 'url'),
      'size': ('size', 'auto'),
      'style': ('style', 'natural'),
      'user': ('user', ''),
      'background': ('background', 'opaque'),
      'moderation': ('moderation', 'auto'),
      'outputFormat': ('output_format', 'png'),
      'outputCompression': ('output_compression', 0),
      'stream': ('stream', false),
      'partialImages': ('partial_images', 0),
    };
    for (final entry in changes.entries) {
      test('${entry.key} participates in copy/equality/hash/diagnostics', () {
        expect(entry.value, isNot(full));
        final change = expectedChanges[entry.key]!;
        final expected = Map<String, dynamic>.of(full.toJson())
          ..[change.$1] = change.$2;
        expect(entry.value.toJson(), expected);
        final restored = ImageGenerationRequest.fromJson(entry.value.toJson());
        expect(restored, entry.value);
        expect(restored.hashCode, entry.value.hashCode);
        expect(entry.value.copyWith(), entry.value);
        expect(full.toString(), contains('${entry.key}:'));
      });
    }
    test('nullable members clear independently and omit their keys', () {
      final clearers = <String, ImageGenerationRequest>{
        'n': full.copyWith(n: null),
        'quality': full.copyWith(quality: null),
        'response_format': full.copyWith(responseFormat: null),
        'size': full.copyWith(size: null),
        'style': full.copyWith(style: null),
        'user': full.copyWith(user: null),
        'background': full.copyWith(background: null),
        'moderation': full.copyWith(moderation: null),
        'output_format': full.copyWith(outputFormat: null),
        'output_compression': full.copyWith(outputCompression: null),
        'stream': full.copyWith(stream: null),
        'partial_images': full.copyWith(partialImages: null),
      };
      for (final entry in clearers.entries) {
        final expected = Map<String, dynamic>.of(full.toJson())
          ..remove(entry.key);
        expect(entry.value.toJson(), expected, reason: entry.key);
        expect(
          ImageGenerationRequest.fromJson(entry.value.toJson()),
          entry.value,
        );
      }
      final cleared = full.copyWith(
        n: null,
        quality: null,
        responseFormat: null,
        size: null,
        style: null,
        user: null,
        background: null,
        moderation: null,
        outputFormat: null,
        outputCompression: null,
        stream: null,
        partialImages: null,
      );
      expect(cleared.toJson(), {'prompt': full.prompt, 'model': full.model});
      final explicitNull = ImageGenerationRequest.fromJson({
        'prompt': full.prompt,
        'model': full.model,
        for (final key in clearers.keys) key: null,
      });
      expect(explicitNull, cleared);
    });
    test('diagnostics summarize prompt and redact user', () {
      expect(full.toString(), isNot(contains('prompt-private')));
      expect(full.toString(), isNot(contains('user-private')));
      expect(full.toString(), contains('prompt: 14 chars'));
      expect(full.toString(), contains('user: [REDACTED]'));
      expect(
        const ImageGenerationRequest(prompt: '', model: '').toString(),
        contains('user: null'),
      );
    });
  });

  group('ImageEditRequest complete value contracts (IMG-02/04)', () {
    final full = _edit();
    test(
      'equal independent image/mask bytes deduplicate with matching hashes',
      () {
        final same = _edit();
        expect(identical(full.image, same.image), isFalse);
        expect(identical(full.mask, same.mask), isFalse);
        expect(same, full);
        expect(same.hashCode, full.hashCode);
        expect({same, full, full.copyWith()}, hasLength(1));
      },
    );
    final changes = <String, ImageEditRequest>{
      'image': full.copyWith(image: Uint8List.fromList([11, 23, 46])),
      'imageFilename': full.copyWith(imageFilename: ''),
      'prompt': full.copyWith(prompt: ''),
      'mask': full.copyWith(mask: Uint8List.fromList([67, 90])),
      'maskFilename': full.copyWith(maskFilename: ''),
      'model': full.copyWith(model: ''),
      'n': full.copyWith(n: 0),
      'size': full.copyWith(size: ImageSize.auto),
      'responseFormat': full.copyWith(
        responseFormat: ImageResponseFormat.b64Json,
      ),
      'user': full.copyWith(user: ''),
      'background': full.copyWith(background: ImageBackground.opaque),
      'inputFidelity': full.copyWith(inputFidelity: ImageInputFidelity.low),
      'quality': full.copyWith(quality: ImageQuality.low),
      'outputFormat': full.copyWith(outputFormat: ImageOutputFormat.png),
      'outputCompression': full.copyWith(outputCompression: 0),
      'moderation': full.copyWith(moderation: ImageModerationLevel.auto),
      'stream': full.copyWith(stream: false),
      'partialImages': full.copyWith(partialImages: 0),
    };
    final expectedChanges = <String, Object>{
      'image': [11, 23, 46],
      'imageFilename': '',
      'prompt': '',
      'mask': [67, 90],
      'maskFilename': '',
      'model': '',
      'n': 0,
      'size': ImageSize.auto,
      'responseFormat': ImageResponseFormat.b64Json,
      'user': '',
      'background': ImageBackground.opaque,
      'inputFidelity': ImageInputFidelity.low,
      'quality': ImageQuality.low,
      'outputFormat': ImageOutputFormat.png,
      'outputCompression': 0,
      'moderation': ImageModerationLevel.auto,
      'stream': false,
      'partialImages': 0,
    };
    for (final entry in changes.entries) {
      test('${entry.key} participates in copy/equality/hash/diagnostics', () {
        expect(entry.value, isNot(full));
        final expected = Map<String, Object?>.of(_editFields(full))
          ..[entry.key] = expectedChanges[entry.key];
        expect(_editFields(entry.value), expected);
        expect(entry.value.copyWith(), entry.value);
        expect(entry.value.copyWith().hashCode, entry.value.hashCode);
        expect(full.toString(), contains('${entry.key}:'));
      });
    }
    test(
      'required fields retain when omitted/null; model remains arbitrary',
      () {
        expect(full.copyWith(), full);
        expect(
          full.copyWith(
            image: null,
            imageFilename: null,
            prompt: null,
            model: null,
          ),
          full,
        );
        expect(
          full.copyWith(model: 'future-provider/image-edit-2030').model,
          'future-provider/image-edit-2030',
        );
        expect(full.copyWith(model: '').model, '');
      },
    );
    test('all nullable members clear independently', () {
      final clears =
          <String, (ImageEditRequest, Object? Function(ImageEditRequest))>{
            'mask': (full.copyWith(mask: null), (request) => request.mask),
            'maskFilename': (
              full.copyWith(maskFilename: null),
              (request) => request.maskFilename,
            ),
            'n': (full.copyWith(n: null), (request) => request.n),
            'size': (full.copyWith(size: null), (request) => request.size),
            'responseFormat': (
              full.copyWith(responseFormat: null),
              (request) => request.responseFormat,
            ),
            'user': (full.copyWith(user: null), (request) => request.user),
            'background': (
              full.copyWith(background: null),
              (request) => request.background,
            ),
            'inputFidelity': (
              full.copyWith(inputFidelity: null),
              (request) => request.inputFidelity,
            ),
            'quality': (
              full.copyWith(quality: null),
              (request) => request.quality,
            ),
            'outputFormat': (
              full.copyWith(outputFormat: null),
              (request) => request.outputFormat,
            ),
            'outputCompression': (
              full.copyWith(outputCompression: null),
              (request) => request.outputCompression,
            ),
            'moderation': (
              full.copyWith(moderation: null),
              (request) => request.moderation,
            ),
            'stream': (
              full.copyWith(stream: null),
              (request) => request.stream,
            ),
            'partialImages': (
              full.copyWith(partialImages: null),
              (request) => request.partialImages,
            ),
          };
      for (final entry in clears.entries) {
        expect(entry.value.$2(entry.value.$1), isNull, reason: entry.key);
        expect(entry.value.$1, isNot(full), reason: entry.key);
        expect(entry.value.$1.copyWith(), entry.value.$1);
      }
      final cleared = full.copyWith(
        mask: null,
        maskFilename: null,
        n: null,
        size: null,
        responseFormat: null,
        user: null,
        background: null,
        inputFidelity: null,
        quality: null,
        outputFormat: null,
        outputCompression: null,
        moderation: null,
        stream: null,
        partialImages: null,
      );
      final minimal = ImageEditRequest(
        image: Uint8List.fromList(full.image),
        imageFilename: full.imageFilename,
        prompt: full.prompt,
        model: full.model,
      );
      expect(cleared, minimal);
      expect(cleared.hashCode, minimal.hashCode);
      expect(cleared.mask, isNull);
      expect(cleared, isNot(cleared.copyWith(mask: Uint8List(0))));
      expect(full.copyWith(image: Uint8List(0)).image, isEmpty);
    });
    test('constructor and copy retain caller-owned buffers', () {
      final image = Uint8List.fromList([1, 2]);
      final mask = Uint8List.fromList([3, 4]);
      final request = ImageEditRequest(
        image: image,
        imageFilename: 'image.png',
        prompt: '',
        model: '',
        mask: mask,
      );
      expect(request.image, same(image));
      expect(request.mask, same(mask));
      expect(request.copyWith().image, same(image));
      expect(request.copyWith().mask, same(mask));
      final replacement = Uint8List.fromList([5]);
      final copy = request.copyWith(image: replacement, mask: replacement);
      expect(copy.image, same(replacement));
      expect(copy.mask, same(replacement));
      image[0] = 9;
      mask[0] = 8;
      expect(request.image, [9, 2]);
      expect(request.mask, [8, 4]);
    });
    test('diagnostics count opaque input bytes/names/text and redact user', () {
      final diagnostic = full.toString();
      for (final private in [
        'image-filename-private',
        'mask-filename-private',
        'prompt-private',
        'user-private',
      ]) {
        expect(diagnostic, isNot(contains(private)));
      }
      expect(diagnostic, contains('image: 3 bytes'));
      expect(diagnostic, contains('mask: 2 bytes'));
      expect(diagnostic, contains('user: [REDACTED]'));
      expect(
        full.copyWith(mask: null, maskFilename: null, user: null).toString(),
        contains('mask: null, maskFilename: null'),
      );
    });
  });

  test(
    'JSON editing and legacy variation keep optional model contracts (IMG-03)',
    () {
      const jsonEdit = ImageEditJsonRequest(
        images: [ImageReference.file('file-fixture')],
        prompt: 'Hello',
      );
      expect(jsonEdit.model, isNull);
      expect(jsonEdit.toJson().containsKey('model'), isFalse);
      final explicitNull = ImageEditJsonRequest.fromJson({
        ...jsonEdit.toJson(),
        'model': null,
      });
      expect(explicitNull.toJson(), jsonEdit.toJson());
      final chosen = ImageEditJsonRequest.fromJson({
        ...jsonEdit.toJson(),
        'model': 'future-model',
      });
      expect(chosen.toJson()['model'], 'future-model');
      expect(
        ImageEditJsonRequest.fromJson({
          ...chosen.toJson(),
          'model': null,
        }).toJson().containsKey('model'),
        isFalse,
      );
      final variation = ImageVariationRequest(
        image: Uint8List(0),
        imageFilename: 'image.png',
      );
      expect(variation.model, isNull);
    },
  );
}

Matcher _invalidField(String field) => throwsA(
  isA<FormatException>().having(
    (error) => error.message,
    'context',
    contains('ImageGenerationRequest.$field'),
  ),
);

Map<String, Object?> _editFields(ImageEditRequest request) => {
  'image': request.image,
  'imageFilename': request.imageFilename,
  'prompt': request.prompt,
  'mask': request.mask,
  'maskFilename': request.maskFilename,
  'model': request.model,
  'n': request.n,
  'size': request.size,
  'responseFormat': request.responseFormat,
  'user': request.user,
  'background': request.background,
  'inputFidelity': request.inputFidelity,
  'quality': request.quality,
  'outputFormat': request.outputFormat,
  'outputCompression': request.outputCompression,
  'moderation': request.moderation,
  'stream': request.stream,
  'partialImages': request.partialImages,
};

ImageEditRequest _edit() => ImageEditRequest(
  image: Uint8List.fromList([11, 23, 45]),
  imageFilename: 'image-filename-private',
  prompt: 'prompt-private',
  mask: Uint8List.fromList([67, 89]),
  maskFilename: 'mask-filename-private',
  model: 'fixture-edit',
  n: 2,
  size: const ImageSize.custom('1792x1344'),
  responseFormat: ImageResponseFormat.url,
  user: 'user-private',
  background: ImageBackground.transparent,
  inputFidelity: ImageInputFidelity.high,
  quality: ImageQuality.max,
  outputFormat: ImageOutputFormat.jpeg,
  outputCompression: 88,
  moderation: ImageModerationLevel.low,
  stream: true,
  partialImages: 4,
);
