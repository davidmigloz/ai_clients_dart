// ignore_for_file: experimental_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:http2/client.dart';
import 'package:openai_dart/openai_dart.dart';

/// Local peer prerequisites: Node >=18 and OpenSSL. Ephemeral key stays in temp.
class LoopbackPeer {
  LoopbackPeer._(this.process, this.directory, this.ready);

  final Process process;
  final Directory directory;
  final Map<String, dynamic> ready;
  final _pending = <int, Completer<Map<String, dynamic>>>{};
  StreamSubscription<String>? _output;
  StreamSubscription<String>? _errors;
  int _sequence = 0;

  static Future<LoopbackPeer> start({int streamLimit = 100}) async {
    final directory = await Directory.systemTemp.createTemp('dart-http2-eval-');
    try {
      final cert = '${directory.path}/cert.pem';
      final key = '${directory.path}/key.pem';
      final generated = await Process.run('openssl', [
        'req',
        '-x509',
        '-newkey',
        'rsa:2048',
        '-nodes',
        '-days',
        '1',
        '-keyout',
        key,
        '-out',
        cert,
        '-subj',
        '/CN=localhost',
        '-addext',
        'subjectAltName=DNS:localhost,IP:127.0.0.1',
      ]).timeout(const Duration(seconds: 10));
      if (generated.exitCode != 0) {
        throw StateError('Fixture certificate generation failed');
      }
      final library = await Isolate.resolvePackageUri(
        Uri.parse('package:openai_dart/openai_dart.dart'),
      );
      if (library == null) {
        throw StateError('Package library was not resolved.');
      }
      final process = await Process.start('node', [
        library.resolve('../test/unit/fixtures/http2/peer.cjs').toFilePath(),
        key,
        cert,
        '$streamLimit',
      ]);
      final startup = Completer<LoopbackPeer>();
      LoopbackPeer? peer;
      final lines = process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter());
      final output = lines.listen((line) {
        final message = jsonDecode(line) as Map<String, dynamic>;
        if (message['ready'] == true) {
          peer = LoopbackPeer._(process, directory, message);
          startup.complete(peer);
        } else {
          peer?._pending.remove(message['command'])?.complete(message);
        }
      });
      final errors = process.stderr.transform(utf8.decoder).listen((_) {});
      try {
        final result = await startup.future.timeout(
          const Duration(seconds: 10),
        );
        result
          .._output = output
          .._errors = errors;
        return result;
      } catch (_) {
        process.kill();
        await output.cancel();
        await errors.cancel();
        rethrow;
      }
    } catch (_) {
      await directory.delete(recursive: true);
      rethrow;
    }
  }

  String get baseUrl => 'https://127.0.0.1:${ready['port']}/v1';
  SecurityContext get context =>
      SecurityContext(withTrustedRoots: false)
        ..setTrustedCertificates('${directory.path}/cert.pem');

  bool _isFixtureCertificate(X509Certificate certificate) =>
      certificate.pem.trim() ==
      File('${directory.path}/cert.pem').readAsStringSync().trim();

  Http2Client http2({int maxStreams = 100}) => Http2Client(
    context: context,
    onBadCertificate: _isFixtureCertificate,
    maxStreamsPerConnection: maxStreams,
    settingsTimeout: const Duration(seconds: 2),
  );

  bool _acceptFixture(X509Certificate certificate, String host, int port) =>
      host == '127.0.0.1' && _isFixtureCertificate(certificate);

  IOClient http1() => IOClient(
    HttpClient(context: context)
      ..badCertificateCallback = _acceptFixture
      ..maxConnectionsPerHost = 100
      ..idleTimeout = const Duration(seconds: 10),
  );

  OpenAIClient openai(
    http.Client transport, {
    String mode = 'json',
    http.Client Function()? streamFactory,
    String? url,
  }) => OpenAIClient(
    config: OpenAIConfig(
      baseUrl: url ?? baseUrl,
      authProvider: const ApiKeyProvider('fixture-only'),
      defaultHeaders: {'x-fixture-mode': mode},
      retryPolicy: const RetryPolicy(maxRetries: 0),
      timeout: const Duration(seconds: 3),
    ),
    httpClient: transport,
    streamClientFactory: streamFactory,
  );

  Future<Map<String, dynamic>> command(String action) {
    final id = ++_sequence;
    final completer = Completer<Map<String, dynamic>>();
    _pending[id] = completer;
    process.stdin.writeln(jsonEncode({'action': action, 'id': id}));
    return completer.future.timeout(const Duration(seconds: 3));
  }

  Future<void> close() async {
    try {
      await command('stop');
    } finally {
      process.kill();
      await process.stdin.close();
      await _output?.cancel();
      await _errors?.cancel();
      await process.exitCode.timeout(const Duration(seconds: 3));
      await directory.delete(recursive: true);
    }
  }
}

CreateResponseRequest fixtureRequest() => const CreateResponseRequest(
  model: 'fixture',
  input: ResponseInput.text('synthetic'),
);

List<Map<String, dynamic>> requestRecords(Map<String, dynamic> snapshot) =>
    (snapshot['records'] as List<dynamic>).cast<Map<String, dynamic>>();
