// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:openai_dart/openai_dart.dart';

import '../../test/unit/fixtures/http2/loopback_peer.dart';

/// Matched local public-client measurements; no keys or external API calls.
Future<void> main(List<String> arguments) async {
  final deadline = Timer(const Duration(minutes: 4), () {
    stderr.writeln('Bounded evaluation deadline exceeded');
    exit(124);
  });
  try {
    await _run(arguments);
  } finally {
    deadline.cancel();
  }
}

Future<void> _run(List<String> arguments) async {
  final samples = arguments.isEmpty ? 5 : int.parse(arguments.single);
  if (samples < 3 || samples > 10) throw ArgumentError('Use 3–10 samples');
  final results = <Map<String, dynamic>>[];
  for (final kind in ['json', 'sse']) {
    for (final temperature in ['cold', 'warm']) {
      for (final concurrency in [1, 8]) {
        for (var sample = 0; sample < samples; sample++) {
          final peer = await LoopbackPeer.start();
          try {
            // Alternate paired order to reduce order/warm-runtime bias.
            for (final protocol
                in sample.isEven ? ['h1', 'h2'] : ['h2', 'h1']) {
              stderr.writeln(
                '$kind $temperature concurrency=$concurrency sample=$sample $protocol',
              );
              final raw = protocol == 'h1' ? peer.http1() : peer.http2();
              final transport = _MeasuredClient(raw);
              final api = peer.openai(transport, mode: kind);
              try {
                final warmup = temperature == 'warm'
                    ? await _batch(api, kind, concurrency, 8)
                    : <_Outcome>[];
                transport.headersUs.clear();
                transport.firstBytesUs.clear();
                final before = await peer.command('stats');
                final stopwatch = Stopwatch()..start();
                final memory = _MemorySample();
                late final List<_Outcome> times;
                try {
                  times = await _batch(api, kind, concurrency, 8);
                } finally {
                  stopwatch.stop();
                  memory.stop();
                }
                final successful = times.where((t) => t.error == null).toList();
                final after = await peer.command('stats');
                final records = requestRecords(
                  after,
                ).skip(before['requests'] as int).toList();
                if (records.length > 8 ||
                    records.any(
                      (r) =>
                          r['protocol'] != (protocol == 'h1' ? '1.1' : '2.0'),
                    )) {
                  throw StateError('Fixture protocol/request mismatch');
                }
                results.add({
                  'kind': kind,
                  'temperature': temperature,
                  'concurrency': concurrency,
                  'protocol': protocol,
                  'sample': sample,
                  'requests': 8,
                  'events_per_request': kind == 'sse' ? 10 : 0,
                  'total_ms': stopwatch.elapsedMicroseconds / 1000,
                  'successful_requests': successful.length,
                  'failed_requests': times.length - successful.length,
                  'warmup_failures': warmup
                      .where((t) => t.error != null)
                      .length,
                  'failures': times
                      .where((t) => t.error != null)
                      .map((t) => t.error)
                      .toList(),
                  'peer_requests_received': records.length,
                  'peer_session_events': after['sessionEvents'],
                  'latency_ms': successful
                      .map((t) => t.latencyUs / 1000)
                      .toList(),
                  'first_event_ms': successful
                      .map((t) => t.firstUs / 1000)
                      .toList(),
                  'first_body_byte_ms': transport.firstBytesUs
                      .map((t) => t / 1000)
                      .toList(),
                  'headers_ms': transport.headersUs
                      .map((t) => t / 1000)
                      .toList(),
                  'successful_requests_per_second':
                      successful.length * 1e6 / stopwatch.elapsedMicroseconds,
                  'new_connections':
                      (after['connections'] as int) -
                      (before['connections'] as int),
                  'total_connections': after['connections'],
                  'h2_sessions': after['h2Sessions'],
                  'bytes_received_by_peer': records.fold<int>(
                    0,
                    (n, r) => n + (r['bodyBytes'] as int),
                  ),
                  'bytes_sent_by_peer': records.fold<int>(
                    0,
                    (n, r) => n + (r['sentBytes'] as int),
                  ),
                  ...memory.toJson(),
                });
              } finally {
                api.close();
                transport.close();
              }
            }
          } finally {
            await peer.close();
          }
        }
      }
    }
  }
  final memoryCases = <Map<String, dynamic>>[];
  for (final protocol in ['h1', 'h2']) {
    final peer = await LoopbackPeer.start();
    final transport = protocol == 'h1' ? peer.http1() : peer.http2();
    final api = peer.openai(transport);
    try {
      final payload = Uint8List(4 * 1024 * 1024);
      final uploadMemory = _MemorySample();
      late final FileObject file;
      try {
        file = await api.files.upload(
          bytes: payload,
          filename: 'fixture.bin',
          purpose: FilePurpose.assistants,
        );
      } finally {
        uploadMemory.stop();
      }
      memoryCases.add({
        'protocol': protocol,
        'case': 'public_multipart_4MiB',
        'payload_bytes': payload.length,
        'wire_bytes': file.bytes,
        ...uploadMemory.toJson(),
      });
      final request = http.Request('GET', Uri.parse('${peer.baseUrl}/download'))
        ..headers['x-fixture-mode'] = 'download';
      final response = await transport
          .send(request)
          .timeout(const Duration(seconds: 3));
      final downloadMemory = _MemorySample();
      final done = Completer<void>();
      var received = 0;
      final subscription = response.stream.listen(
        (chunk) {
          received += chunk.length;
        },
        onDone: done.complete,
        onError: done.completeError,
      )..pause();
      try {
        await Future<void>.delayed(const Duration(milliseconds: 300));
        final stats = await peer.command('stats');
        final paused = requestRecords(stats).last;
        subscription.resume();
        await done.future.timeout(const Duration(seconds: 3));
        downloadMemory.stop();
        memoryCases.add({
          'protocol': protocol,
          'case': 'paused_raw_response_4MiB',
          'pause_ms': 300,
          'peer_sent_while_paused': paused['sentBytes'],
          'peer_finished_while_paused': paused['finished'],
          'received_after_resume': received,
          ...downloadMemory.toJson(),
        });
      } finally {
        downloadMemory.stop();
        await subscription.cancel().timeout(const Duration(seconds: 2));
      }
    } finally {
      api.close();
      transport.close();
      await peer.close();
    }
  }
  print(
    jsonEncode({
      'schema': 1,
      'observed_at_utc': DateTime.now().toUtc().toIso8601String(),
      'platform': Platform.operatingSystem,
      'os_version': Platform.operatingSystemVersion,
      'dart': Platform.version,
      'node': (await Process.run('node', [
        '--version',
      ])).stdout.toString().trim(),
      'openssl': (await Process.run('openssl', [
        'version',
      ])).stdout.toString().trim(),
      'http': '1.6.0',
      'http2': '3.1.0',
      'samples_per_cell': samples,
      'limits': {
        'requests_per_batch': 8,
        'concurrency': [1, 8],
        'JSON_peer_delay_ms': 5,
        'SSE_events': 10,
        'SSE_interval_ms': 10,
        'SSE_event_padding_bytes': 4096,
        'memory_payload_bytes': 4 * 1024 * 1024,
        'RSS_interval_ms': 5,
        'client_max_connections_or_streams': 100,
        'timeout_seconds': 3,
        'whole_run_deadline_seconds': 240,
        'real_API_calls': 0,
        'API_cost_USD': 0,
      },
      'results': results,
      'memory_cases': memoryCases,
    }),
  );
}

class _Outcome {
  const _Outcome(this.latencyUs, this.firstUs, this.error);
  final int latencyUs;
  final int firstUs;
  final String? error;
}

Future<List<_Outcome>> _batch(
  OpenAIClient api,
  String kind,
  int concurrency,
  int count,
) async {
  final times = <_Outcome>[];
  Future<_Outcome> request() async {
    final watch = Stopwatch()..start();
    var first = 0;
    Future<void> execute() async {
      if (kind == 'json') {
        final response = await api.responses.create(fixtureRequest());
        if (response.id != 'resp_fixture') {
          throw StateError('Unexpected fixture response');
        }
        first = watch.elapsedMicroseconds;
      } else {
        var events = 0;
        await for (final _ in api.responses.createStream(fixtureRequest())) {
          if (events++ == 0) first = watch.elapsedMicroseconds;
        }
        if (events != 10) throw StateError('SSE fixture event mismatch');
      }
    }

    try {
      await execute().timeout(const Duration(seconds: 3));
      return _Outcome(watch.elapsedMicroseconds, first, null);
    } catch (error) {
      return _Outcome(
        watch.elapsedMicroseconds,
        first,
        error is http.ClientException
            ? 'ClientException: local transport failure'
            : error is TimeoutException
            ? 'TimeoutException: bounded request deadline'
            : 'Unexpected fixture failure',
      );
    }
  }

  for (var i = 0; i < count; i += concurrency) {
    times.addAll(
      await Future.wait([
        for (var j = 0; j < min(concurrency, count - i); j++) request(),
      ]),
    );
  }
  return times;
}

class _MeasuredClient extends http.BaseClient {
  _MeasuredClient(this.inner);
  final http.Client inner;
  final headersUs = <int>[];
  final firstBytesUs = <int>[];
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final watch = Stopwatch()..start();
    final response = await inner.send(request);
    headersUs.add(watch.elapsedMicroseconds);
    var first = true;
    return http.StreamedResponse(
      response.stream.map((bytes) {
        if (first && bytes.isNotEmpty) {
          first = false;
          firstBytesUs.add(watch.elapsedMicroseconds);
        }
        return bytes;
      }),
      response.statusCode,
      headers: response.headers,
      contentLength: response.contentLength,
      request: response.request,
      reasonPhrase: response.reasonPhrase,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
    );
  }

  @override
  void close() => inner.close();
}

class _MemorySample {
  _MemorySample() {
    _timer = Timer.periodic(const Duration(milliseconds: 5), (_) {
      peak = max(peak, ProcessInfo.currentRss);
    });
  }
  final int start = ProcessInfo.currentRss;
  int peak = ProcessInfo.currentRss;
  late final Timer _timer;
  void stop() {
    peak = max(peak, ProcessInfo.currentRss);
    _timer.cancel();
  }

  Map<String, int> toJson() => {
    'RSS_start': start,
    'RSS_sampled_peak': peak,
    'RSS_end': ProcessInfo.currentRss,
    'RSS_sampled_delta': max(0, peak - start),
  };
}
