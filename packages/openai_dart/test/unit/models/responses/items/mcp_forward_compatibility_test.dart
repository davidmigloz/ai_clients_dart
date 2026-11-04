import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';
import 'package:web_socket/web_socket.dart' as ws;

void main() {
  group('MCP receive forward compatibility', () {
    test('unknown statuses use a fallback without changing known statuses', () {
      for (final value in [
        'in_progress',
        'calling',
        'completed',
        'incomplete',
        'failed',
      ]) {
        expect(McpCallStatus.fromJson(value).toJson(), value);
      }
      expect(McpCallStatus.fromJson('future_status'), McpCallStatus.unknown);
      expect(McpCallStatus.unknown.toJson(), 'unknown');
      final item =
          OutputItem.fromJson(_call(status: 'future_status'))
              as McpCallOutputItem;
      expect(item.status, McpCallStatus.unknown);
      expect(item.toJson()['status'], 'unknown');
      expect(
        item.copyWith(status: null).toJson().containsKey('status'),
        isFalse,
      );
      expect(
        (OutputItem.fromJson(_call()) as McpCallOutputItem).status,
        isNull,
      );
      expect(
        (OutputItem.fromJson({..._call(), 'status': null}) as McpCallOutputItem)
            .status,
        isNull,
      );
      expect(
        () => OutputItem.fromJson({..._call(), 'status': 1}),
        throwsFormatException,
      );
    });

    test('future errors retain complete JSON through calls and responses', () {
      final error = _futureError();
      final parsed = McpCallError.fromJson(error) as UnknownMcpCallError;
      expect(parsed.type, 'future_mcp_error');
      expect(parsed.rawJson, error);
      expect(parsed.toJson(), error);
      expect(UnknownMcpCallError.fromJson(error), parsed);
      expect(UnknownMcpCallError(rawJson: error), parsed);
      final response = Response.fromJson(_response(_call(error: error)));
      final item = response.output.single as McpCallOutputItem;
      expect(item.error, parsed);
      expect(item.toJson()['error'], error);
      expect(item.copyWith(error: null).toJson().containsKey('error'), isFalse);
      expect(Response.fromJson(response.toJson()), response);
    });

    test(
      'unknown error construction owns nested JSON and keeps stable hashes',
      () {
        final source = _futureError();
        final parsed = UnknownMcpCallError(rawJson: source);
        final expected = _futureError();
        final hash = parsed.hashCode;
        (source['details'] as Map)['retryable'] = true;
        ((source['details'] as Map)['attempts'] as List).add('caller edit');
        source['type'] = 'another_future_error';
        expect(parsed.toJson(), expected);
        expect(parsed.hashCode, hash);
        expect(parsed, UnknownMcpCallError.fromJson(expected));
        expect(
          parsed.hashCode,
          UnknownMcpCallError.fromJson(expected).hashCode,
        );
        expect(() => parsed.rawJson['new'] = true, throwsUnsupportedError);
        expect(
          () => (parsed.rawJson['details'] as Map)['retryable'] = true,
          throwsUnsupportedError,
        );
        expect(
          () =>
              ((parsed.toJson()['details'] as Map)['attempts'] as List).clear(),
          throwsUnsupportedError,
        );
      },
    );

    test('unknown copies retain extras and typed discriminator edits win', () {
      final parsed = UnknownMcpCallError.fromJson(_futureError());
      expect(parsed.copyWith(), parsed);
      expect(parsed.copyWith().hashCode, parsed.hashCode);
      final copied = parsed.copyWith(type: 'another_future_error');
      expect(copied, isNot(parsed));
      expect(copied.toJson(), {
        ..._futureError(),
        'type': 'another_future_error',
      });
      expect(copied, UnknownMcpCallError.fromJson(copied.toJson()));
      final replacement = <String, dynamic>{
        'type': 'raw_future_error',
        'nested': <dynamic>[1, null],
      };
      expect(parsed.copyWith(rawJson: replacement).toJson(), {
        'type': 'future_mcp_error',
        'nested': [1, null],
      });
      final replaced = parsed.copyWith(
        rawJson: replacement,
        type: 'typed_future_error',
      );
      (replacement['nested'] as List).add(2);
      expect(replaced.toJson(), {
        'type': 'typed_future_error',
        'nested': [1, null],
      });
      expect(replaced, isNot(copied));
      expect(parsed.type, 'future_mcp_error');
      expect(
        () => parsed.copyWith(type: 'mcp_protocol_error'),
        throwsFormatException,
      );
    });

    test(
      'unknown diagnostics redact the discriminator and all payload values',
      () {
        final error = UnknownMcpCallError.fromJson(const {
          'type': 'private_discriminator',
          'api_key': 'private_credential',
          'detail': {'message': 'private_message'},
        });
        final diagnostic = error.toString();
        expect(diagnostic, contains('UnknownMcpCallError'));
        for (final value in [
          'private_discriminator',
          'private_credential',
          'private_message',
          'api_key',
        ]) {
          expect(diagnostic, isNot(contains(value)));
        }
      },
    );

    for (final malformed in <Map<String, dynamic>>[
      {},
      {'type': null},
      {'type': 1},
      {'type': ''},
      {'type': <dynamic>[]},
    ]) {
      test('malformed unknown discriminator is rejected: $malformed', () {
        expect(() => McpCallError.fromJson(malformed), throwsFormatException);
        expect(
          () => UnknownMcpCallError.fromJson(malformed),
          throwsFormatException,
        );
        expect(
          () => UnknownMcpCallError(rawJson: malformed),
          throwsFormatException,
        );
      });
    }

    for (final known in [
      'mcp_protocol_error',
      'http_error',
      'mcp_tool_execution_error',
    ]) {
      test('$known cannot bypass known-field validation via the fallback', () {
        expect(
          () => McpCallError.fromJson({'type': known}),
          throwsFormatException,
        );
        expect(
          () => UnknownMcpCallError.fromJson({'type': known}),
          throwsFormatException,
        );
        expect(
          () => UnknownMcpCallError(rawJson: {'type': known}),
          throwsFormatException,
        );
      });
    }

    test(
      'required nullable tool-error content still retains explicit null',
      () {
        final error = McpCallError.fromJson(const {
          'type': 'mcp_tool_execution_error',
          'content': null,
        });
        expect(error, isA<McpToolExecutionError>());
        expect(error.toJson(), {
          'type': 'mcp_tool_execution_error',
          'content': null,
        });
      },
    );

    test(
      'invalid unknown JSON fails contextually without exposing payloads',
      () {
        final cycle = <dynamic>[];
        cycle.add(cycle);
        for (final invalid in <Object?>[
          double.nan,
          double.infinity,
          DateTime.utc(2026),
          {1: 'private value'},
          cycle,
        ]) {
          expect(
            () => UnknownMcpCallError.fromJson({
              'type': 'private_type',
              'private_key': invalid,
            }),
            throwsA(
              isA<FormatException>().having(
                (error) => error.message,
                'redacted context',
                allOf(
                  contains('UnknownMcpCallError'),
                  isNot(contains('private_')),
                ),
              ),
            ),
          );
        }
      },
    );

    test('future values decode through HTTP Responses create', () async {
      final item = _call(status: 'future_status', error: _futureError());
      final client = _httpClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/v1/responses');
        expect(request.headers['authorization'], 'Bearer fixture-key');
        expect(jsonDecode(request.body), _request.toJson());
        return http.Response(
          jsonEncode(_response(item)),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      addTearDown(client.close);
      final result = await client.responses.create(_request);
      _expectFutureCall(result.output.single as McpCallOutputItem);
    });

    test(
      'future values decode through public SSE item and terminal events',
      () async {
        final item = _call(status: 'future_status', error: _futureError());
        final frames = [
          {
            'type': 'response.output_item.done',
            'output_index': 0,
            'item': item,
          },
          {'type': 'response.completed', 'response': _response(item)},
        ];
        final client = _httpClient((request) async {
          expect(request.url.path, '/v1/responses');
          expect((jsonDecode(request.body) as Map)['stream'], isTrue);
          return http.Response(
            '${frames.map((frame) => 'data: ${jsonEncode(frame)}\n\n').join()}data: [DONE]\n\n',
            200,
            headers: {'content-type': 'text/event-stream'},
          );
        });
        addTearDown(client.close);
        final events = await client.responses.createStream(_request).toList();
        expect(events, hasLength(2));
        _expectFutureCall(
          (events.first as OutputItemDoneEvent).item as McpCallOutputItem,
        );
        _expectFutureCall(
          (events.last as ResponseCompletedEvent).response.output.single
              as McpCallOutputItem,
        );
      },
    );

    test('future values decode through public WebSocket envelopes', () async {
      final socket = _Socket();
      final client = OpenAIClient();
      final connection = await client.responses.connect(
        connector: (uri, {headers}) async => socket,
      );
      addTearDown(() async {
        await connection.close();
        client.close();
      });
      final item = _call(status: 'future_status', error: _futureError());
      final pending = connection.events.take(2).toList();
      socket
        ..frame({
          'type': 'response.output_item.done',
          'stream_id': 'mcp',
          'output_index': 0,
          'item': item,
        })
        ..frame({
          'type': 'response.completed',
          'stream_id': 'mcp',
          'response': _response(item),
        });
      final events = await pending;
      expect(events.map((event) => event.streamId), ['mcp', 'mcp']);
      final done = events.first as ResponsesStreamEvent;
      final terminal = events.last as ResponsesStreamEvent;
      _expectFutureCall(
        (done.event as OutputItemDoneEvent).item as McpCallOutputItem,
      );
      _expectFutureCall(
        (terminal.event as ResponseCompletedEvent).response.output.single
            as McpCallOutputItem,
      );
      expect((done.rawJson['item'] as Map)['status'], 'future_status');
      expect((done.toJson()['item'] as Map)['error'], _futureError());
    });
  });
}

const _request = CreateResponseRequest(
  model: 'fixture',
  input: ResponseInput.text('Search'),
);

Map<String, dynamic> _call({String? status, Map<String, dynamic>? error}) => {
  'type': 'mcp_call',
  'id': 'call_fixture',
  'arguments': '{}',
  'name': 'search',
  'server_label': 'docs',
  'status': ?status,
  'error': ?error,
};

Map<String, dynamic> _futureError() => {
  'type': 'future_mcp_error',
  'details': {
    'retryable': false,
    'attempts': <dynamic>[1, null, 'private detail'],
  },
  'nullable': null,
};

Map<String, dynamic> _response(Map<String, dynamic> item) => {
  'id': 'response_fixture',
  'object': 'response',
  'created_at': 1,
  'status': 'completed',
  'output': [item],
};

void _expectFutureCall(McpCallOutputItem call) {
  expect(call.status, McpCallStatus.unknown);
  expect(call.error, isA<UnknownMcpCallError>());
  expect(call.error!.toJson(), _futureError());
  expect(call.name, 'search');
  expect(call.serverLabel, 'docs');
}

OpenAIClient _httpClient(Future<http.Response> Function(http.Request) handle) =>
    OpenAIClient(
      config: const OpenAIConfig(
        authProvider: ApiKeyProvider('fixture-key'),
        retryPolicy: RetryPolicy(maxRetries: 0),
      ),
      httpClient: MockClient(handle),
    );

class _Socket implements ws.WebSocket {
  final _controller = StreamController<ws.WebSocketEvent>();
  void frame(Map<String, dynamic> json) =>
      _controller.add(ws.TextDataReceived(jsonEncode(json)));
  @override
  Stream<ws.WebSocketEvent> get events => _controller.stream;
  @override
  String get protocol => '';
  @override
  void sendText(String text) {}
  @override
  void sendBytes(Uint8List bytes) {}
  @override
  Future<void> close([int? code, String? reason]) async {
    if (_controller.isClosed) return;
    _controller.add(ws.CloseReceived(code ?? 1000, reason ?? ''));
    unawaited(_controller.close());
  }
}
