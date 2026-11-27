import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  test('decodes a resource with embedded image detail', () {
    const json = {
      'type': 'resource',
      'uri': 'fixture://preview',
      'content': {
        'type': 'image_url',
        'image_url': {'url': 'https://example.test/image.png', 'detail': 'low'},
      },
    };

    final part = ContentPart.fromJson(json) as ResourceContentPart;
    final image = part.content as ImageUrlContentPart;
    expect(image.detail, 'low');
    expect(part.uri, 'fixture://preview');
    expect(part.toJson(), json);
    expect(image.copyWith(detail: null).toJson()['image_url'], {
      'url': 'https://example.test/image.png',
    });
    expect(ContentPart.fromJson(json), part);
    expect(ContentPart.fromJson(json).hashCode, part.hashCode);
  });

  test('preserves future payload kinds and future image details', () {
    const json = {
      'type': 'resource',
      'uri': 'fixture://future',
      'content': {
        'type': 'new-format',
        'values': [1, 2],
      },
    };
    final part = ContentPart.fromJson(json) as ResourceContentPart;
    expect(part.content, isA<UnknownContentPart>());
    expect(part.toJson(), json);

    const futureImage = {
      'type': 'image_url',
      'image_url': {
        'url': 'https://example.test/image.png',
        'detail': 'future',
      },
    };
    expect(ContentPart.fromJson(futureImage).toJson(), futureImage);
  });

  test('resource-link metadata round-trips and can be cleared', () {
    const json = {
      'type': 'resource_link',
      'uri': 'fixture://result',
      'metadata': {'title': 'Result', 'position': 10, 'score': 0.5, 'ok': true},
    };

    final part = ContentPart.fromJson(json) as ResourceLinkContentPart;
    expect(part.toJson(), json);
    expect(part.copyWith(metadata: null).toJson(), {
      'type': 'resource_link',
      'uri': 'fixture://result',
    });
    expect(ContentPart.fromJson(json), part);
    expect(ContentPart.fromJson(json).hashCode, part.hashCode);
    expect(
      () => ContentPart.fromJson({
        ...json,
        'metadata': {
          'unexpected': ['nested'],
        },
      }),
      throwsFormatException,
    );
  });

  test('preserves the new built-in connector name', () {
    const json = {
      'type': 'tool_reference',
      'tool': 'mistral_mcp',
      'title': 'Search reference',
    };
    expect(ContentPart.fromJson(json).toJson(), json);
  });
}
