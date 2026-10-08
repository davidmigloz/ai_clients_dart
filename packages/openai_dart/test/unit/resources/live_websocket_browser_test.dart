@TestOn('browser')
library;

import 'dart:async';
import 'dart:js_interop';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

@JS('eval')
external JSAny? _evaluate(JSString source);
int _number(String source) => (_evaluate(source.toJS)! as JSNumber).toDartInt;
void _run(String source) => _evaluate(source.toJS);
const _secret = 'PRIVATE_BROWSER_LIVE';

void main() {
  setUp(() {
    _run(r'''
      globalThis.__liveOriginalWebSocket = globalThis.WebSocket;
      globalThis.__liveCreated = [];
      globalThis.WebSocket = class {
        constructor(url) {
          this.url = url; this.readyState = 1; this.protocol = '';
          this.handlers = {}; this.closeCount = 0; this.addCount = 0; this.removeCount = 0;
          this.emitClose = false; this.sent = [];
          globalThis.__liveCreated.push(this);
        }
        addEventListener(type, listener) { this.handlers[type] = listener; this.addCount++; }
        removeEventListener(type, listener) {
          if(this.handlers[type] === listener) { delete this.handlers[type]; this.removeCount++; }
        }
        send(data) { this.sent.push(data); }
        close(code, reason) {
          this.closeCount++; if(this.throwClose) throw new Error('PRIVATE_BROWSER_LIVE'); this.readyState = 2;
          if(this.emitClose) this.peerClose(code || 1000, reason || '');
        }
        peerClose(code, reason) {
          this.readyState = 3;
          const handler = this.handlers.close;
          if(handler) handler({code, reason});
        }
      };
    ''');
  });
  tearDown(() {
    _run(
      'globalThis.WebSocket = globalThis.__liveOriginalWebSocket; '
      'delete globalThis.__liveOriginalWebSocket; delete globalThis.__liveCreated;',
    );
  });

  test(
    'browser default rejects all headers before creating a DOM socket',
    () async {
      for (final headers in [
        {'authorization': _secret},
        {'OpenAI-Project': _secret},
        {'X-Future': _secret},
        {'PRIVATE_CUSTOM_HEADER_NAME': _secret},
      ]) {
        await expectLater(
          Future.sync(
            () => connectLiveWebSocket(
              Uri.parse('wss://example.invalid/private?token=$_secret'),
              headers: headers,
            ),
          ),
          throwsA(
            isA<LiveBrowserHeadersException>()
                .having(
                  (e) => e.toString(),
                  'header value redacted',
                  isNot(contains(_secret)),
                )
                .having(
                  (e) => e.toString(),
                  'header name redacted',
                  isNot(contains(headers.keys.single)),
                )
                .having(
                  (e) => e.message,
                  'explicit actionable key',
                  contains(headers.keys.single),
                ),
          ),
        );
      }
      expect(_number('__liveCreated.length'), 0);
    },
  );
  test(
    'browser normal close retains actual peer facts and releases every DOM listener',
    () async {
      final socket = await connectLiveWebSocket(
        Uri.parse('wss://example.invalid/proxy'),
      );
      final connection = LiveSidebandConnection(socket);
      final closing = connection.close(code: 3000, reason: _secret);
      expect(_number('__liveCreated[0].addCount'), 4);
      expect(_number('Object.keys(__liveCreated[0].handlers).length'), 4);
      _run("__liveCreated[0].peerClose(4004, '$_secret');");
      await closing;
      await connection.done;
      expect(connection.closeCode, 4004);
      expect(connection.closeReason, _secret);
      expect(_number('__liveCreated[0].removeCount'), 4);
      expect(_number('Object.keys(__liveCreated[0].handlers).length'), 0);
      expect(_number('__liveCreated[0].closeCount'), 1);
      expect(connection.isFinalized, isFalse);
      expect(connection.toString(), isNot(contains(_secret)));
    },
  );
  test(
    'browser timed-out owned close detaches DOM listeners without a fabricated peer close',
    () async {
      final socket = await connectLiveWebSocket(
        Uri.parse('wss://example.invalid/proxy'),
      );
      final connection = LiveSidebandConnection(socket);
      await expectLater(
        connection.close(timeout: const Duration(milliseconds: 5)),
        throwsA(isA<LiveTransportException>()),
      );
      await connection.done;
      expect(_number('__liveCreated[0].closeCount'), 1);
      expect(_number('__liveCreated[0].removeCount'), 4);
      expect(_number('Object.keys(__liveCreated[0].handlers).length'), 0);
      expect(connection.closeCode, isNull);
      expect(connection.closeReason, isNull);
      expect(connection.isFinalized, isFalse);
    },
  );
  test(
    'browser local close failure preserves cause without peer close facts',
    () async {
      final socket = await connectLiveWebSocket(
        Uri.parse('wss://example.invalid/proxy'),
      );
      final connection = LiveSidebandConnection(socket);
      _run('__liveCreated[0].throwClose = true;');
      await expectLater(
        connection.close(),
        throwsA(
          isA<LiveTransportException>()
              .having((e) => e.toString(), 'safe', isNot(contains(_secret)))
              .having(
                (e) => e.cause,
                'explicit browser cause',
                isA<ConnectionException>().having(
                  (e) => e.cause,
                  'original JS cause',
                  isNotNull,
                ),
              ),
        ),
      );
      await connection.done;
      expect(connection.closeCode, isNull);
      expect(connection.closeReason, isNull);
      expect(_number('__liveCreated[0].removeCount'), 4);
      expect(_number('__liveCreated[0].closeCount'), 1);
    },
  );

  test(
    'browser borrowed reader detaches only its listeners and keeps caller socket writable',
    () async {
      final socket = await connectLiveWebSocket(
        Uri.parse('wss://example.invalid/proxy'),
      );
      final connection = LiveSidebandConnection(socket, ownsSocket: false);
      await connection.close();
      await connection.done;
      expect(_number('__liveCreated[0].closeCount'), 0);
      expect(_number('__liveCreated[0].removeCount'), 4);
      socket.sendText(_secret);
      expect(_number('__liveCreated[0].sent.length'), 1);
      await socket.close(1000);
      expect(_number('__liveCreated[0].closeCount'), 1);
    },
  );
  test(
    'browser public connector rejects nonfinite close codes before DOM close',
    () async {
      final socket = await connectLiveWebSocket(
        Uri.parse('wss://example.invalid/proxy'),
      );
      final reader = socket.events.listen((_) {});
      for (final literal in ['Infinity', '-Infinity', 'NaN']) {
        final dynamic code = num.parse(literal);
        expect(
          () => socket.close(code),
          throwsA(code is int ? isA<ArgumentError>() : isA<TypeError>()),
        );
      }
      expect(_number('__liveCreated[0].closeCount'), 0);
      await reader.cancel();
      await socket.close();
      expect(_number('__liveCreated[0].closeCount'), 1);
    },
  );
}
