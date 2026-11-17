import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

const _svgUsage = SvgUsage(
  model: 'svg-author',
  inputTokens: 10,
  outputTokens: 4,
  totalTokens: 14,
  reasoningTokens: 2,
);

Map<String, dynamic> _command(Map<String, dynamic> item) => {
  'type': 'response.item.create',
  'item': item,
};

Map<String, dynamic> _outer(Map<String, dynamic> event) => {
  'type': 'response.event',
  'event_id': 'evt_live_fixture',
  'event': event,
};

void main() {
  test('Live item creation retains GIF and SVG tool settings', () {
    final gif =
        LiveInputImageGenTool.fromJson(const {
          'type': 'image_generation',
          'model': 'gpt-image-2.6-sunburst',
          'output_format': 'gif',
        }).copyWith(
          complexity: ImageComplexity.high,
          frameCount: 9,
          frameDurationMs: 200,
        );
    final svg = gif.copyWith(
      outputFormat: 'svg',
      clearFrameCount: true,
      clearFrameDurationMs: true,
      svg: const SvgOptions(
        model: 'svg-author',
        reasoning: SvgReasoning(effort: ReasoningEffort.high),
      ),
    );
    final wire = _command({
      'type': 'additional_tools',
      'role': 'developer',
      'tools': [gif.toJson(), svg.toJson()],
    });
    final parsed =
        LiveClientEvent.fromJson(wire) as LiveResponseItemCreateParam;
    final tools = (parsed.item as LiveInputAdditionalToolsItemParam).tools;
    final first = (tools[0] as LiveInputToolBranch8).value;
    final second = (tools[1] as LiveInputToolBranch8).value;
    expect(first.complexity, ImageComplexity.high);
    expect(first.outputFormat, 'gif');
    expect(first.frameCount, 9);
    expect(first.frameDurationMs, 200);
    expect(second.outputFormat, 'svg');
    expect(second.hasFrameCount, isFalse);
    expect(second.hasFrameDurationMs, isFalse);
    expect(second.svg!.model, 'svg-author');
    expect(second.svg!.reasoning!.effort, ReasoningEffort.high);
    expect(second.copyWith(clearSvg: true).hasSvg, isFalse);
    expect(() => gif.copyWith(frameCount: 17), throwsFormatException);
    expect(
      () => svg.copyWith(
        svg: {
          'reasoning': {'effort': null},
        },
      ),
      throwsFormatException,
    );
    expect(parsed.toJson(), wire);
    final received = LiveCompactResponse.fromJson({
      'tools': [gif.toJson(), svg.toJson()],
    });
    expect(received.tools, [gif.toJson(), svg.toJson()]);
  });

  for (final format in [ImageOutputFormat.gif, ImageOutputFormat.svg]) {
    test('Live output and replay preserve ${format.name} image calls', () {
      final usage = format == ImageOutputFormat.svg ? _svgUsage : null;
      final output = ImageGenerationCallOutputItem(
        id: 'image_fixture',
        status: ImageGenerationCallStatus.completed,
        result: null,
        outputFormat: format,
        svgUsage: usage,
      );
      final wire = output.toJson();
      final replay =
          LiveInputItem.fromOutputItem(output) as LiveInputImageGenToolCall;
      expect(replay.outputFormat!.value, format.toJson());
      expect(replay.svgUsage, usage);
      expect(replay.hasSvgUsage, usage != null);
      expect(replay.copyWith(clearSvgUsage: true).svgUsage, isNull);
      expect(
        replay.copyWith(svgUsage: _svgUsage).toJson()['svg_usage'],
        _svgUsage.toJson(),
      );
      final command = LiveResponseItemCreateParam(item: replay);
      expect(
        LiveSidebandClientEvent.fromJson(command.toJson()).toJson(),
        _command(wire),
      );
      final outer = _outer({
        'type': 'response.output_item.done',
        'item': wire,
        'output_index': 0,
        'sequence_number': 1,
      });
      final event =
          LiveResponsesEvent.fromJson(outer) as LiveResponsesGranularEvent;
      expect((event.granularEvent as OutputItemDoneEvent).item, output);
      expect(event.toJson(), outer);
    });
  }

  test('Live accepts up to 128 characters in function output namespaces', () {
    final namespace = 'N' * 128;
    final wire = {
      'type': 'function_call_output',
      'call_id': 'function_fixture',
      'output': 'complete',
      'namespace': namespace,
    };
    final item =
        LiveInputItem.fromJson(wire) as LiveInputFunctionCallOutputItemParam;
    expect(item.namespace, namespace);
    expect(LiveResponseItemCreateParam(item: item).toJson(), _command(wire));
    expect(
      () => item.copyWith(namespace: '${namespace}n'),
      throwsFormatException,
    );
    final outer = _outer({
      'type': 'response.completed',
      'response': {
        'instructions': [wire],
      },
    });
    final event =
        LiveResponsesEvent.fromJson(outer) as LiveResponsesLifecycleEvent;
    expect(event.response.instructions, [wire]);
    expect(event.toJson(), outer);
  });

  test(
    'Live compact responses accept 12h and preserve per-TTL cache counts',
    () {
      final usage = {
        'input_tokens': 20,
        'output_tokens': 5,
        'total_tokens': 25,
        'input_tokens_details': {
          'cached_tokens': 4,
          'cache_write_tokens': 12,
          'cache_write_tokens_details': {
            'ttl_30m_tokens': 2,
            'ttl_12h_tokens': 10,
          },
        },
        'output_tokens_details': {'reasoning_tokens': 1},
      };
      final wire = _outer({
        'type': 'response.completed',
        'response': {
          'prompt_cache_options': {'ttl': '12h', 'mode': 'implicit'},
          'usage': usage,
        },
      });
      final event =
          LiveResponsesEvent.fromJson(wire) as LiveResponsesLifecycleEvent;
      expect(event.response.promptCacheOptions?['ttl'], '12h');
      expect(event.response.usage, usage);
      expect(event.toJson(), wire);
      expect(
        () => event.response.copyWith(
          usage: {
            ...usage,
            'input_tokens_details': {
              'cached_tokens': 4,
              'cache_write_tokens': 12,
              'cache_write_tokens_details': {'ttl_12h_tokens': 10},
            },
          },
        ),
        throwsFormatException,
      );
    },
  );
}
